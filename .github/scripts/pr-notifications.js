#!/usr/bin/env node

const https = require('https');

const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const SLACK_WEBHOOK_URL = process.env.SLACK_WEBHOOK_URL;
const GITHUB_USERNAME = process.env.GITHUB_USERNAME || 'mikemjharris';

// Time window: last 30 minutes (plus 5 min buffer)
const SINCE = new Date(Date.now() - 35 * 60 * 1000).toISOString();

// Bot usernames to filter out
const BOT_USERS = ['dependabot', 'renovate', 'github-actions', 'codecov', 'vercel'];

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
        'Content-Length': payload.length
      }
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        if (res.statusCode === 200) {
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
  return BOT_USERS.some(bot => username.toLowerCase().includes(bot.toLowerCase()));
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

      // Extract PR number from the API URL
      // URL format: https://api.github.com/repos/owner/repo/pulls/123
      const urlParts = notif.subject.url.split('/');
      const prNumber = urlParts[urlParts.length - 1];

      console.log(`Checking PR #${prNumber} in ${repoFullName}...`);

      // Get PR details - use the full API path from the notification
      let pr;
      try {
        // The subject.url is already an API path, extract just the path part
        const apiPath = notif.subject.url.replace('https://api.github.com', '');
        pr = await makeGitHubRequest(apiPath);
      } catch (error) {
        console.log(`Failed to fetch PR #${prNumber}: ${error.message}`);
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

      // Filter comments (non-bot, and either mentions me or is on my PR)
      const relevantComments = comments.filter(c => {
        if (isBot(c.user.login)) return false;
        if (c.body.includes(`@${GITHUB_USERNAME}`)) return true;
        if (isMyPR) return true;
        return false;
      });

      const relevantReviewComments = reviewComments.filter(c => {
        if (isBot(c.user.login)) return false;
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
      type: 'header',
      text: {
        type: 'plain_text',
        text: `🔔 PR Updates (${notifications.length})`,
        emoji: true
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
        text: `*<${notif.prUrl}|${notif.repo}#${notif.prNumber}>* ${notif.isMyPR ? '(Your PR)' : ''}\n${notif.prTitle}`
      }
    });

    // Approvals
    if (notif.approvals.length > 0) {
      for (const approval of notif.approvals) {
        blocks.push({
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: `✅ *Approved* by ${approval.user.login}${approval.body ? `\n>${approval.body}` : ''}`
          }
        });
      }
    }

    // Comments
    for (const comment of notif.comments) {
      const mention = comment.body.includes(`@${GITHUB_USERNAME}`) ? '📢 ' : '';
      blocks.push({
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: `${mention}💬 *${comment.user.login}*: ${comment.body.substring(0, 200)}${comment.body.length > 200 ? '...' : ''}`
        }
      });
    }

    // Review comments
    for (const comment of notif.reviewComments) {
      const mention = comment.body.includes(`@${GITHUB_USERNAME}`) ? '📢 ' : '';
      blocks.push({
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: `${mention}💭 *${comment.user.login}* (code review): ${comment.body.substring(0, 200)}${comment.body.length > 200 ? '...' : ''}`
        }
      });
    }

    blocks.push({
      type: 'divider'
    });
  }

  console.log(`Sending ${notifications.length} notifications to Slack...`);
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
