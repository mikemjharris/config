# PR Comment Notifications Setup

This workflow monitors PR comments and approvals across all your GitHub repositories and sends notifications to Slack.

## Features

- **Mentions**: Get notified when someone mentions you in a PR comment
- **Comments on your PRs**: Track all non-bot comments on PRs you created
- **Approvals**: Know when your PRs get approved
- **Bot filtering**: Automatically excludes comments from bots
- **Hourly checks**: Runs every hour to keep you updated

## Setup

### 1. Add the GitHub Actions Workflow

Due to GitHub security restrictions, the workflow file needs to be added manually.

Create a file `.github/workflows/pr-comment-notifications.yml` with the following content:

```yaml
name: PR Comment Notifications

on:
  schedule:
    # Run every hour
    - cron: '0 * * * *'
  workflow_dispatch: # Allow manual trigger

jobs:
  check-pr-comments:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install requests

      - name: Check PR comments and send Slack notification
        env:
          GITHUB_TOKEN: ${{ secrets.PAT_TOKEN || secrets.GITHUB_TOKEN }}
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
          GITHUB_USERNAME: ${{ github.repository_owner }}
        run: |
          python scripts/check-pr-comments.py
```

Commit and push this file to enable the workflow.

### 2. Create a Slack Webhook

1. Go to https://api.slack.com/apps
2. Create a new app or select an existing one
3. Navigate to "Incoming Webhooks"
4. Activate incoming webhooks
5. Click "Add New Webhook to Workspace"
6. Select the channel where you want notifications
7. Copy the webhook URL

### 3. Add GitHub Secrets

Add the following secrets to your repository:

1. Go to your repository settings
2. Navigate to Secrets and variables > Actions
3. Add these secrets:

   - **SLACK_WEBHOOK_URL**: The webhook URL from step 1
   - **PAT_TOKEN** (optional): A GitHub Personal Access Token with `repo` scope
     - If not provided, the default `GITHUB_TOKEN` will be used
     - A PAT is recommended for accessing private repos and organizations
     - Create one at: https://github.com/settings/tokens

### 4. Verify the Workflow

Once you've added the workflow file from step 1, it will:
- Run automatically every hour
- Can be triggered manually from the Actions tab

### 5. Test It

You can test the workflow manually:

1. Go to the Actions tab in your repository
2. Select "PR Comment Notifications"
3. Click "Run workflow"
4. Check your Slack channel for the notification

## Customization

### Change Schedule

Edit `.github/workflows/pr-comment-notifications.yml`:

```yaml
on:
  schedule:
    # Run every hour (current setting)
    - cron: '0 * * * *'

    # Or run every 30 minutes
    # - cron: '*/30 * * * *'

    # Or run every 3 hours
    # - cron: '0 */3 * * *'

    # Or run at 9am and 5pm UTC (adjust for your timezone)
    # - cron: '0 9,17 * * *'
```

### Adjust Time Window

The script checks for activity in the last 70 minutes (to account for cron timing).

To change this, edit `scripts/check-pr-comments.py`:

```python
# Around line 36, change minutes=70 to your preferred value
self.since = datetime.utcnow() - timedelta(minutes=70)
```

### Filter Specific Repos

If you want to exclude certain repos, modify the `get_all_repos()` method in the script to filter them out.

## Troubleshooting

### No notifications received

1. Check that the workflow ran successfully in the Actions tab
2. Verify your Slack webhook URL is correct
3. Ensure you have PR activity in the last hour
4. Try running the workflow manually to test

### Missing comments

1. Verify the PAT_TOKEN has access to all your repos
2. Check that comments are within the time window (last 70 minutes by default)
3. Ensure comments aren't from bots (they're filtered out)

### Rate limiting

If you have many repositories, you might hit GitHub API rate limits:
- With `GITHUB_TOKEN`: 1,000 requests/hour
- With `PAT_TOKEN`: 5,000 requests/hour

Consider adjusting the schedule to run less frequently if needed.

## Example Notification

Your Slack notifications will look like this:

```
GitHub PR Notifications

🔔 You were mentioned (2)
- myorg/repo #123: Fix bug in authentication
  @coworker: @yourusername can you review this change?
  View comment

💬 Comments on your PRs (3)
- myorg/another-repo #456: Add new feature
  @reviewer: This looks good, just one small suggestion...
  View comment

✅ PR Approvals (1)
- myorg/project #789: Update dependencies
  Approved by @teamlead
  View approval
```
