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

const STATE_FILE = path.join(__dirname, '../../.github/state/notified-state.json');

function loadState() {
  if (fs.existsSync(STATE_FILE)) {
    try {
      return JSON.parse(fs.readFileSync(STATE_FILE, 'utf8'));
    } catch (e) {
      console.log('Could not parse state file, starting fresh');
    }
  }
  return { notified_reviews: [] };
}

function saveState(state) {
  const dir = path.dirname(STATE_FILE);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  fs.writeFileSync(STATE_FILE, JSON.stringify(state, null, 2));
}

function pruneState(state) {
  const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
  state.notified_reviews = state.notified_reviews.filter(
    entry => new Date(entry.notified_at) > sevenDaysAgo
  );
  return state;
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

async function getNotifications(notifiedKeys) {
  try {
    console.log(`Fetching notifications since ${SINCE}...`);

    // Get notifications for the user
    const notifications = await makeGitHubRequest(
      `/notifications?since=${SINCE}&participating=true&per_page=100`
    );

    console.log(`Found ${notifications.length} notifications`);

    // Also fetch recently updated PRs where user is author to catch approvals/reviews
    console.log(`Fetching recently updated PRs where you're author...`);
    // Search for PRs updated since SINCE (GitHub requires YYYY-MM-DD format)
    const sinceDate = new Date(SINCE).toISOString().split('T')[0]; // Format as YYYY-MM-DD
    const searchQuery = `type:pr author:${GITHUB_USERNAME} updated:>=${sinceDate}`;
    console.log(`  Search query: ${searchQuery}`);
    const myPRs = await makeGitHubRequest(
      `/search/issues?q=${encodeURIComponent(searchQuery)}&per_page=100`
    );
    console.log(`  Found ${myPRs.total_count} PRs where you're the author (updated since ${sinceDate})`);

    // Convert PRs to notification-like format
    const prNotifications = myPRs.items.map(pr => ({
      subject: {
        title: pr.title,
        url: pr.pull_request.url,
        type: 'PullRequest'
      },
      repository: {
        full_name: pr.repository_url.replace('https://api.github.com/repos/', '')
      },
      reason: 'author'
    }));

    // Combine notifications and open PRs, removing duplicates
    const allNotifications = [...notifications];
    const notificationUrls = new Set(notifications.map(n => n.subject.url));

    for (const prNotif of prNotifications) {
      if (!notificationUrls.has(prNotif.subject.url)) {
        allNotifications.push(prNotif);
      }
    }

    console.log(`Total notifications to process: ${allNotifications.length}`);

    const relevantNotifications = [];

    for (const notif of allNotifications) {
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
      console.log(`  Found ${comments.length} issue comments`);

      // Get review comments (code review comments)
      const reviewComments = await makeGitHubRequest(
        `/repos/${repoFullName}/pulls/${prNumber}/comments?since=${SINCE}`
      );
      console.log(`  Found ${reviewComments.length} review comments`);

      // Get reviews
      const reviews = await makeGitHubRequest(
        `/repos/${repoFullName}/pulls/${prNumber}/reviews`
      );

      // Check if PR author is the user (needed for review filter below)
      const isMyPR = pr.user.login === GITHUB_USERNAME;

      // Filter reviews: exclude bots and own reviews.
      // For own PRs, use state-based dedup instead of time window to avoid
      // missing reviews that fell between polling cycles.
      const recentReviews = reviews.filter(r => {
        if (isBot(r.user.login)) return false;
        if (r.user.login === GITHUB_USERNAME) return false;
        if (isMyPR) {
          const key = `${repoFullName}#${prNumber}:${r.id}`;
          return !notifiedKeys.has(key);
        }
        return new Date(r.submitted_at) > new Date(SINCE);
      });
      console.log(`  Found ${recentReviews.length} recent reviews (excluding bots and own reviews)`);

      // Check for approvals
      const approvals = recentReviews.filter(r => r.state === 'APPROVED');

      // Get review-level comments (comments that are part of the review body, not on specific lines)
      const reviewLevelComments = recentReviews.filter(r =>
        r.body && r.body.trim() !== '' && r.state !== 'APPROVED' // Don't duplicate approval bodies
      );

      // Check if user is a requested reviewer
      const isReviewer = pr.requested_reviewers?.some(r => r.login === GITHUB_USERNAME) ||
                         pr.requested_teams?.length > 0; // Could enhance team check if needed

      console.log(`  isMyPR: ${isMyPR}, isReviewer: ${isReviewer}`);

      // Check if this is a new PR (created since SINCE)
      const isNewPR = new Date(pr.created_at) > new Date(SINCE);
      console.log(`  PR created at: ${pr.created_at}, isNewPR: ${isNewPR}`);

      // Filter comments (non-bot, not by me, and either mentions me or is on my PR or I'm a reviewer)
      const relevantComments = comments.filter(c => {
        console.log(`  Checking issue comment from: ${c.user.login}`);
        const botCheck = isBot(c.user.login);
        console.log(`    isBot: ${botCheck}`);
        if (botCheck) {
          console.log(`    ✗ Filtered out (bot)`);
          return false;
        }
        if (c.user.login === GITHUB_USERNAME) {
          console.log(`    ✗ Filtered out (own comment)`);
          return false;
        }
        const hasMention = c.body.includes(`@${GITHUB_USERNAME}`);
        console.log(`    mentions me: ${hasMention}, isMyPR: ${isMyPR}, isReviewer: ${isReviewer}`);
        if (hasMention) return true;
        if (isMyPR) return true;
        if (isReviewer) return true;
        console.log(`    ✗ Filtered out (not relevant)`);
        return false;
      });

      const relevantReviewComments = reviewComments.filter(c => {
        console.log(`  Checking review comment from: ${c.user.login}`);
        const botCheck = isBot(c.user.login);
        console.log(`    isBot: ${botCheck}`);
        if (botCheck) {
          console.log(`    ✗ Filtered out (bot)`);
          return false;
        }
        if (c.user.login === GITHUB_USERNAME) {
          console.log(`    ✗ Filtered out (own comment)`);
          return false;
        }
        const hasMention = c.body.includes(`@${GITHUB_USERNAME}`);
        console.log(`    mentions me: ${hasMention}, isMyPR: ${isMyPR}, isReviewer: ${isReviewer}`);
        if (hasMention) return true;
        if (isMyPR) return true;
        if (isReviewer) return true;
        console.log(`    ✗ Filtered out (not relevant)`);
        return false;
      });

      console.log(`  After filtering: ${relevantComments.length} relevant issue comments, ${relevantReviewComments.length} relevant review comments, ${reviewLevelComments.length} review-level comments, ${approvals.length} approvals`);

      // Include if:
      // - There are relevant comments/reviews/approvals
      // - OR it's a new PR where I'm a reviewer
      if (relevantComments.length > 0 || relevantReviewComments.length > 0 || reviewLevelComments.length > 0 || approvals.length > 0 || (isNewPR && isReviewer)) {
        console.log(`  ✓ Adding to notifications list`);
        relevantNotifications.push({
          repo: repoFullName,
          prNumber,
          prTitle: pr.title,
          prUrl: pr.html_url,
          isMyPR,
          isReviewer,
          isNewPR: isNewPR && isReviewer,
          comments: relevantComments,
          reviewComments: relevantReviewComments,
          reviewLevelComments,
          approvals
        });
      } else {
        console.log(`  ✗ No relevant activity, skipping`);
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
    let prLabel = '';
    if (notif.isMyPR) {
      prLabel = '(Your PR)';
    } else if (notif.isReviewer) {
      prLabel = '(Review Requested)';
    }
    if (notif.isNewPR) {
      prLabel += ' 🆕';
    }

    blocks.push({
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: `*<${notif.prUrl}|${escapeSlackText(notif.repo)}#${notif.prNumber}>* ${prLabel}\n${escapeSlackText(notif.prTitle)}`
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

    // Review comments (on specific lines of code)
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

    // Review-level comments (general review comments, not on specific lines)
    for (const review of notif.reviewLevelComments || []) {
      const mention = review.body.includes(`@${GITHUB_USERNAME}`) ? '📢 ' : '';
      // Remove quote markers and escape
      const cleanBody = review.body.replace(/^>\s*/gm, '').substring(0, 200);
      const truncated = escapeSlackText(cleanBody);
      const stateEmoji = review.state === 'CHANGES_REQUESTED' ? '🔄' :
                         review.state === 'COMMENTED' ? '💬' : '📝';
      blocks.push({
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: `${mention}${stateEmoji} *${escapeSlackText(review.user.login)}* reviewed: ${truncated}${review.body.length > 200 ? '...' : ''}`
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

    // Load and prune state for review deduplication
    const state = pruneState(loadState());
    const notifiedKeys = new Set(state.notified_reviews.map(e => e.key));
    console.log(`Loaded ${notifiedKeys.size} previously notified reviews from state`);

    const notifications = await getNotifications(notifiedKeys);
    await formatAndSendNotifications(notifications);

    // Track notified reviews so we don't re-send them
    for (const notif of notifications) {
      for (const review of [...notif.approvals, ...notif.reviewLevelComments]) {
        state.notified_reviews.push({
          key: `${notif.repo}#${notif.prNumber}:${review.id}`,
          notified_at: new Date().toISOString()
        });
      }
    }
    saveState(state);
    console.log(`State saved with ${state.notified_reviews.length} tracked reviews`);
  } catch (error) {
    console.error('Error in main:', error);
    process.exit(1);
  }
}

main();
