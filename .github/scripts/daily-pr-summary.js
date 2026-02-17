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
const TESTING = process.env.TESTING === 'true';

const BOT_USERS = ['dependabot', 'renovate', 'github-actions', 'codecov', 'vercel', 'coderabbitai'];

function makeGitHubRequest(apiPath) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'api.github.com',
      path: apiPath,
      method: 'GET',
      headers: {
        'Authorization': `token ${GITHUB_TOKEN}`,
        'User-Agent': 'Daily-PR-Summary-Script',
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

    if (TESTING) {
      console.log('Slack payload:', JSON.stringify({ blocks }, null, 2));
      fs.writeFileSync('/tmp/slack-payload.json', JSON.stringify({ blocks }, null, 2));
      console.log('Payload written to /tmp/slack-payload.json');
      resolve('ok');
      return;
    }

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
  if (username.toLowerCase().includes('[bot]')) return true;
  return BOT_USERS.some(bot => username.toLowerCase().includes(bot.toLowerCase()));
}

function escapeSlackText(text) {
  return text
    .replace(/\r\n/g, '\n')
    .replace(/\r/g, '\n')
    .replace(/&/g, '&amp;')
    .replace(/<(?!http)/g, '&lt;')
    .substring(0, 2900);
}

function formatAge(createdAt) {
  const ms = Date.now() - new Date(createdAt).getTime();
  const hours = Math.floor(ms / (1000 * 60 * 60));
  if (hours < 24) return hours === 1 ? '1h ago' : `${hours}h ago`;
  const days = Math.floor(hours / 24);
  return days === 1 ? '1d ago' : `${days}d ago`;
}

// Determine the review status of a PR based on its reviews
function getReviewStatus(reviews) {
  // Sort reviews by submission time, newest first
  const sorted = [...reviews]
    .filter(r => !isBot(r.user.login))
    .sort((a, b) => new Date(b.submitted_at) - new Date(a.submitted_at));

  // Track latest review state per reviewer
  const latestByReviewer = new Map();
  for (const review of sorted) {
    if (!latestByReviewer.has(review.user.login)) {
      latestByReviewer.set(review.user.login, review.state);
    }
  }

  const states = [...latestByReviewer.values()];

  if (states.includes('CHANGES_REQUESTED')) {
    return { status: 'changes_requested', emoji: '🔄', label: 'changes requested' };
  }
  if (states.includes('APPROVED')) {
    return { status: 'approved', emoji: '✅', label: 'approved' };
  }
  if (states.length > 0) {
    return { status: 'reviewed', emoji: '💬', label: 'reviewed, awaiting approval' };
  }
  return { status: 'waiting', emoji: '⏳', label: 'waiting for review' };
}

// Count outstanding comments from others (comments after the author's last reply)
function countOutstandingComments(comments, prAuthor) {
  const nonBotComments = comments.filter(c => !isBot(c.user.login));

  // Find the timestamp of the author's last comment
  const authorComments = nonBotComments.filter(c => c.user.login === prAuthor);
  const lastAuthorComment = authorComments.length > 0
    ? new Date(Math.max(...authorComments.map(c => new Date(c.created_at || c.submitted_at).getTime())))
    : new Date(0);

  // Count comments from others after the author's last reply
  return nonBotComments.filter(c =>
    c.user.login !== prAuthor &&
    new Date(c.created_at || c.submitted_at) > lastAuthorComment
  ).length;
}

async function getMyOpenPRs() {
  console.log('Fetching your open PRs...');
  const searchQuery = `type:pr author:${GITHUB_USERNAME} state:open`;
  const result = await makeGitHubRequest(
    `/search/issues?q=${encodeURIComponent(searchQuery)}&per_page=100&sort=updated&order=desc`
  );
  console.log(`Found ${result.total_count} open PRs`);

  const prs = [];
  for (const item of result.items) {
    const repoFullName = item.repository_url.replace('https://api.github.com/repos/', '');
    const prNumber = item.number;

    console.log(`  Processing ${repoFullName}#${prNumber}: ${item.title}`);

    // Fetch reviews
    const reviews = await makeGitHubRequest(
      `/repos/${repoFullName}/pulls/${prNumber}/reviews`
    );

    // Fetch issue comments and review comments for outstanding count
    const issueComments = await makeGitHubRequest(
      `/repos/${repoFullName}/issues/${prNumber}/comments?per_page=100`
    );
    const reviewComments = await makeGitHubRequest(
      `/repos/${repoFullName}/pulls/${prNumber}/comments?per_page=100`
    );

    const allComments = [...issueComments, ...reviewComments];
    const reviewStatus = getReviewStatus(reviews);
    const outstandingComments = countOutstandingComments(allComments, GITHUB_USERNAME);

    console.log(`    Review status: ${reviewStatus.label}, outstanding comments: ${outstandingComments}`);

    prs.push({
      repo: repoFullName,
      number: prNumber,
      title: item.title,
      url: item.html_url,
      createdAt: item.created_at,
      reviewStatus,
      outstandingComments
    });
  }

  return prs;
}

async function getPRsAwaitingMyReview() {
  console.log('Fetching PRs awaiting your review...');
  const searchQuery = `type:pr review-requested:${GITHUB_USERNAME} state:open`;
  const result = await makeGitHubRequest(
    `/search/issues?q=${encodeURIComponent(searchQuery)}&per_page=100&sort=updated&order=desc`
  );
  console.log(`Found ${result.total_count} PRs awaiting your review`);

  return result.items.map(item => ({
    repo: item.repository_url.replace('https://api.github.com/repos/', ''),
    number: item.number,
    title: item.title,
    url: item.html_url,
    author: item.user.login,
    createdAt: item.created_at
  }));
}

function buildSlackBlocks(myPRs, awaitingReview) {
  const blocks = [
    {
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: '*:clipboard: Daily PR Summary*'
      }
    },
    { type: 'divider' }
  ];

  // Section 1: Your Open PRs
  blocks.push({
    type: 'section',
    text: {
      type: 'mrkdwn',
      text: `*Your Open PRs (${myPRs.length})*`
    }
  });

  if (myPRs.length === 0) {
    blocks.push({
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: '_No open PRs_'
      }
    });
  } else {
    for (const pr of myPRs) {
      const commentInfo = pr.outstandingComments > 0
        ? `, ${pr.outstandingComments} comment${pr.outstandingComments === 1 ? '' : 's'}`
        : '';
      const age = formatAge(pr.createdAt);
      const repoShort = pr.repo.split('/').pop();

      blocks.push({
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: `${pr.reviewStatus.emoji} <${pr.url}|${escapeSlackText(repoShort)}#${pr.number}> — ${escapeSlackText(pr.title)} (${pr.reviewStatus.label}${commentInfo}, ${age})`
        }
      });
    }
  }

  blocks.push({ type: 'divider' });

  // Section 2: PRs Awaiting Your Review
  blocks.push({
    type: 'section',
    text: {
      type: 'mrkdwn',
      text: `*Awaiting Your Review (${awaitingReview.length})*`
    }
  });

  if (awaitingReview.length === 0) {
    blocks.push({
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: '_No PRs awaiting your review_'
      }
    });
  } else {
    for (const pr of awaitingReview) {
      const age = formatAge(pr.createdAt);
      const repoShort = pr.repo.split('/').pop();

      blocks.push({
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: `:eyes: <${pr.url}|${escapeSlackText(repoShort)}#${pr.number}> — ${escapeSlackText(pr.title)} (by ${escapeSlackText(pr.author)}, ${age})`
        }
      });
    }
  }

  blocks.push({ type: 'divider' });

  return blocks;
}

async function main() {
  try {
    if (!GITHUB_TOKEN) {
      throw new Error('GITHUB_TOKEN environment variable is required');
    }
    if (!SLACK_WEBHOOK_URL) {
      throw new Error('SLACK_WEBHOOK_URL environment variable is required');
    }

    const myPRs = await getMyOpenPRs();
    const awaitingReview = await getPRsAwaitingMyReview();

    const blocks = buildSlackBlocks(myPRs, awaitingReview);

    console.log(`\nSummary: ${myPRs.length} open PRs, ${awaitingReview.length} awaiting your review`);
    await sendSlackMessage(blocks);
    console.log('Daily summary sent successfully!');
  } catch (error) {
    console.error('Error in main:', error);
    process.exit(1);
  }
}

main();
