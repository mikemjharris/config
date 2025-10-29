# PR Notifications Setup

This workflow sends Slack notifications every 30 minutes for:
- Comments on your PRs (non-bot)
- Comments that mention you (@mikemjharris)
- PR approvals on your PRs

## Setup Instructions

### 1. Create a Slack Webhook

1. Go to https://api.slack.com/apps
2. Create a new app or select an existing one
3. Go to "Incoming Webhooks" and activate it
4. Click "Add New Webhook to Workspace"
5. Select the channel where you want notifications
6. Copy the webhook URL (looks like: `https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXX`)

### 2. Add GitHub Secrets

In your GitHub repository settings:

1. Go to Settings → Secrets and variables → Actions
2. Add a new repository secret:
   - Name: `SLACK_WEBHOOK_URL`
   - Value: Your Slack webhook URL from step 1

**Note:** `GITHUB_TOKEN` is automatically provided by GitHub Actions, no need to add it.

### 3. Enable GitHub Actions

1. Push this repository to GitHub
2. Go to the Actions tab
3. Enable workflows if prompted
4. The workflow will run automatically every 30 minutes
5. You can also trigger it manually from the Actions tab

## Testing

To test the workflow manually:

1. Go to Actions tab in your GitHub repo
2. Select "PR Notifications" workflow
3. Click "Run workflow"
4. Check your Slack channel for notifications

## Customization

### Change notification frequency

Edit `.github/workflows/pr-notifications.yml`:

```yaml
schedule:
  - cron: '*/30 * * * *'  # Every 30 minutes
  # Examples:
  # - cron: '0 * * * *'   # Every hour
  # - cron: '0 9,17 * * *' # 9am and 5pm daily
```

### Filter specific repositories

Edit `.github/scripts/pr-notifications.js` and add at the top:

```javascript
const REPO_WHITELIST = ['owner/repo1', 'owner/repo2'];
```

Then add this check in the notification loop:

```javascript
if (REPO_WHITELIST.length > 0 && !REPO_WHITELIST.includes(repoFullName)) {
  continue;
}
```

### Add more bot filters

Edit the `BOT_USERS` array in `.github/scripts/pr-notifications.js`:

```javascript
const BOT_USERS = ['dependabot', 'renovate', 'github-actions', 'codecov', 'vercel', 'your-bot-name'];
```

## Troubleshooting

### No notifications received

1. Check the Actions tab for workflow runs
2. Look at the workflow logs for errors
3. Verify the Slack webhook URL is correct
4. Make sure you have notifications in the time window (last 30 minutes)

### Too many notifications

1. Increase the time window in the workflow schedule
2. Add more bots to the filter list
3. Add a repository whitelist

### Rate limiting

GitHub API has rate limits. If you hit them:
1. Reduce the frequency of the workflow
2. Add a repository whitelist to check fewer repos
