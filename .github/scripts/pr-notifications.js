#!/usr/bin/env node

const https = require('https');
const fs = require('fs');
const path = require('path');

// Load .env file if it exists (for local testing)
const envPath = path.join(__dirname, '../../.env');
if (fs.existsSync(envPath)) {
  const envFile = fs.readFileSync(envPath, 'utf8');
  envFile.split('\n').forEach(line => {
    const match = line.match(/^([^=:#]+)=(.*)$/);
    if (match) {
      const key = match[1].trim();
      const value = match[2].trim();
      if (!process.env[key]) {
        process.env[key] = value;
      }
    }
  });
}

const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const SLACK_WEBHOOK_URL = process.env.SLACK_WEBHOOK_URL;
const GITHUB_USERNAME = process.env.GITHUB_USERNAME || 'mikemjharris';

// Time window: last 30 minutes (plus 5 min buffer)
// For testing, use a longer window if TESTING env var is set
const TESTING = process.env.TESTING === 'true';
const SINCE = TESTING
  ? new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString() // 24 hours for testing
  : new Date(Date.now() - 35 * 60 * 1000).toISOString();

// Bot usernames to filter out
const BOT_USERS = ['dependabot', 'renovate', 'github-actions', 'codecov', 'vercel', 'coderabbitai'];

function makeGitHubRequest(path) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'api.github.com',
      path: path,
      method: 'GET',
      headers: {
        'Authorization': `token ${GITHUB_TOKEN}`,
        'User-Agent': 'PR-Notifications-Script',
        'Accept': 'application/vnd.github.v3+json'
      }
    };

    https.get(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        if (res.statusCode === 200) {
          resolve(JSON.parse(data));
        } else {
          reject(new Error(`GitHub API error: ${res.statusCode} - ${data}`));
        }
      });
    }).on('error', reject);
  });
}

function sendSlackMessage(blocks) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify({ blocks });
    const url = new URL(SLACK_WEBHOOK_URL);

    const options = {
      hostname: url.hostname,
      path: url.pathname + url.search,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload)
      }
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        if (res.statusCode === 200 || res.statusCode === 201) {
          resolve(data);
        } else {
          reject(new Error(`Slack API error: ${res.statusCode} - ${data}`));
        }
      });
    });

    req.on('error', reject);
    req.write(payload);
    req.end();
  });
}

function isBot(username) {
  // Check if username contains [bot] (GitHub convention)
  if (username.toLowerCase().includes('[bot]')) {
    return true;
  }
  // Check against known bot usernames
  return BOT_USERS.some(bot => username.toLowerCase().includes(bot.toLowerCase()));
}

function escapeSlackText(text) {
  // Escape special characters for Slack mrkdwn and limit length
  // Note: Don't escape > at the start of lines (it's markdown quote syntax)
  return text
    .replace(/\r\n/g, '\n')  // Normalize line endings
    .replace(/\r/g, '\n')     // Normalize line endings
    .replace(/&/g, '&amp;')
    .replace(/<(?!http)/g, '&lt;')  // Escape < except in URLs
    .substring(0, 2900); // Stay well under 3000 char limit
}

async function getNotifications() {
  try {
    console.log(`Fetching notifications since ${SINCE}...`);

    // Get notifications for the user
    const notifications = await makeGitHubRequest(
      `/notifications?since=${SINCE}&participating=true&per_page=100`
    );

    console.log(`Found ${notifications.length} notifications`);

    const relevantNotifications = [];

    for (const notif of notifications) {
      // Only process pull request notifications
      if (!notif.subject.url || !notif.subject.url.includes('/pulls/')) {
        continue;
      }

      const repoFullName = notif.repository.full_name;

      console.log(`\nNotification details:`);
      console.log(`  Repository: ${repoFullName}`);
      console.log(`  Subject: ${notif.subject.title}`);
      console.log(`  Subject URL: ${notif.subject.url}`);
      console.log(`  Subject Type: ${notif.subject.type}`);
      console.log(`  Reason: ${notif.reason}`);

      // Extract PR number from the API URL
      // URL format: https://api.github.com/repos/owner/repo/pulls/123
      const urlParts = notif.subject.url.split('/');
      const prNumber = urlParts[urlParts.length - 1];

      console.log(`  Extracted PR number: ${prNumber}`);

      // Get PR details - use the full API path from the notification
      let pr;
      try {
        // The subject.url is already an API path, extract just the path part
        const apiPath = notif.subject.url.replace('https://api.github.com', '');
        console.log(`  Fetching PR from API path: ${apiPath}`);
        pr = await makeGitHubRequest(apiPath);
        console.log(`  ✓ Successfully fetched PR #${prNumber}`);
      } catch (error) {
        console.log(`  ✗ Failed to fetch PR #${prNumber}: ${error.message}`);
        continue;
      }

      // Get comments (issue comments)
      const comments = await makeGitHubRequest(
        `/repos/${repoFullName}/issues/${prNumber}/comments?since=${SINCE}`
      );

      // Get review comments (code review comments)
      const reviewComments = await makeGitHubRequest(
        `/repos/${repoFullName}/pulls/${prNumber}/comments?since=${SINCE}`
      );

      // Get reviews
      const reviews = await makeGitHubRequest(
        `/repos/${repoFullName}/pulls/${prNumber}/reviews`
      );

      // Filter recent reviews
      const recentReviews = reviews.filter(r =>
        new Date(r.submitted_at) > new Date(SINCE) &&
        !isBot(r.user.login)
      );

      // Check for approvals
      const approvals = recentReviews.filter(r => r.state === 'APPROVED');

      // Check if PR author is the user
      const isMyPR = pr.user.login === GITHUB_USERNAME;

      // Filter comments (non-bot, not by me, and either mentions me or is on my PR)
      const relevantComments = comments.filter(c => {
        if (isBot(c.user.login)) return false;
        if (c.user.login === GITHUB_USERNAME) return false; // Exclude my own comments
        if (c.body.includes(`@${GITHUB_USERNAME}`)) return true;
        if (isMyPR) return true;
        return false;
      });

      const relevantReviewComments = reviewComments.filter(c => {
        if (isBot(c.user.login)) return false;
        if (c.user.login === GITHUB_USERNAME) return false; // Exclude my own comments
        if (c.body.includes(`@${GITHUB_USERNAME}`)) return true;
        if (isMyPR) return true;
        return false;
      });

      if (relevantComments.length > 0 || relevantReviewComments.length > 0 || approvals.length > 0) {
        relevantNotifications.push({
          repo: repoFullName,
          prNumber,
          prTitle: pr.title,
          prUrl: pr.html_url,
          isMyPR,
          comments: relevantComments,
          reviewComments: relevantReviewComments,
          approvals
        });
      }
    }

    return relevantNotifications;
  } catch (error) {
    console.error('Error fetching notifications:', error);
    throw error;
  }
}

async function formatAndSendNotifications(notifications) {
  if (notifications.length === 0) {
    console.log('No relevant notifications to send');
    return;
  }

  const blocks = [
    {
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: `*🔔 PR Updates (${notifications.length})*`
      }
    },
    {
      type: 'divider'
    }
  ];

  for (const notif of notifications) {
    // PR header
    blocks.push({
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: `*<${notif.prUrl}|${escapeSlackText(notif.repo)}#${notif.prNumber}>* ${notif.isMyPR ? '(Your PR)' : ''}\n${escapeSlackText(notif.prTitle)}`
      }
    });

    // Approvals
    if (notif.approvals.length > 0) {
      for (const approval of notif.approvals) {
        const body = approval.body ? `\n_${escapeSlackText(approval.body)}_` : '';
        blocks.push({
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: `✅ *Approved* by ${escapeSlackText(approval.user.login)}${body}`
          }
        });
      }
    }

    // Comments
    for (const comment of notif.comments) {
      const mention = comment.body.includes(`@${GITHUB_USERNAME}`) ? '📢 ' : '';
      // Remove quote markers and escape
      const cleanBody = comment.body.replace(/^>\s*/gm, '').substring(0, 200);
      const truncated = escapeSlackText(cleanBody);
      blocks.push({
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: `${mention}💬 *${escapeSlackText(comment.user.login)}*: ${truncated}${comment.body.length > 200 ? '...' : ''}`
        }
      });
    }

    // Review comments
    for (const comment of notif.reviewComments) {
      const mention = comment.body.includes(`@${GITHUB_USERNAME}`) ? '📢 ' : '';
      // Remove quote markers and escape
      const cleanBody = comment.body.replace(/^>\s*/gm, '').substring(0, 200);
      const truncated = escapeSlackText(cleanBody);
      blocks.push({
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: `${mention}💭 *${escapeSlackText(comment.user.login)}* (code review): ${truncated}${comment.body.length > 200 ? '...' : ''}`
        }
      });
    }

    blocks.push({
      type: 'divider'
    });
  }

  console.log(`Sending ${notifications.length} notifications to Slack...`);
  if (TESTING) {
    const payload = JSON.stringify({ blocks }, null, 2);
    console.log('Slack payload:', payload);
    require('fs').writeFileSync('/tmp/slack-payload.json', payload);
    console.log('Payload written to /tmp/slack-payload.json');
  }
  await sendSlackMessage(blocks);
  console.log('Notifications sent successfully!');
}

async function main() {
  try {
    if (!GITHUB_TOKEN) {
      throw new Error('GITHUB_TOKEN environment variable is required');
    }
    if (!SLACK_WEBHOOK_URL) {
      throw new Error('SLACK_WEBHOOK_URL environment variable is required');
    }

    const notifications = await getNotifications();
    await formatAndSendNotifications(notifications);
  } catch (error) {
    console.error('Error in main:', error);
    process.exit(1);
  }
}

main();
