#!/usr/bin/env python3
"""
Check for PR comments and approvals across all repos and send Slack notifications.

This script:
- Fetches all repos accessible to the user
- Checks for comments on PRs (mentions, comments on user's PRs, approvals)
- Excludes bot comments
- Sends a summary to Slack
"""

import os
import sys
import requests
from datetime import datetime, timedelta
from typing import List, Dict, Any
import json


class GitHubPRMonitor:
    def __init__(self, token: str, username: str):
        self.token = token
        self.username = username
        self.headers = {
            "Authorization": f"token {token}",
            "Accept": "application/vnd.github.v3+json"
        }
        self.base_url = "https://api.github.com"

        # Time window to check (default: last 70 minutes to account for hourly cron)
        self.since = datetime.utcnow() - timedelta(minutes=70)

    def is_bot(self, user: Dict[str, Any]) -> bool:
        """Check if a user is a bot."""
        return user.get("type") == "Bot" or user.get("login", "").endswith("[bot]")

    def get_all_repos(self) -> List[Dict[str, Any]]:
        """Fetch all repos the user has access to."""
        repos = []
        page = 1

        print(f"Fetching repositories for {self.username}...")

        while True:
            # Get repos owned by the user
            url = f"{self.base_url}/user/repos"
            params = {
                "affiliation": "owner,collaborator,organization_member",
                "per_page": 100,
                "page": page
            }

            response = requests.get(url, headers=self.headers, params=params)

            if response.status_code != 200:
                print(f"Error fetching repos: {response.status_code}")
                print(response.text)
                break

            data = response.json()

            if not data:
                break

            repos.extend(data)
            page += 1

        print(f"Found {len(repos)} repositories")
        return repos

    def get_open_prs(self, repo: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Get all open PRs for a repository."""
        owner = repo["owner"]["login"]
        repo_name = repo["name"]

        url = f"{self.base_url}/repos/{owner}/{repo_name}/pulls"
        params = {"state": "open", "per_page": 100}

        response = requests.get(url, headers=self.headers, params=params)

        if response.status_code != 200:
            return []

        return response.json()

    def get_pr_comments(self, repo: Dict[str, Any], pr: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Get all comments for a PR (issue comments and review comments)."""
        owner = repo["owner"]["login"]
        repo_name = repo["name"]
        pr_number = pr["number"]

        comments = []

        # Get issue comments
        url = f"{self.base_url}/repos/{owner}/{repo_name}/issues/{pr_number}/comments"
        response = requests.get(url, headers=self.headers)
        if response.status_code == 200:
            comments.extend(response.json())

        # Get review comments
        url = f"{self.base_url}/repos/{owner}/{repo_name}/pulls/{pr_number}/comments"
        response = requests.get(url, headers=self.headers)
        if response.status_code == 200:
            comments.extend(response.json())

        return comments

    def get_pr_reviews(self, repo: Dict[str, Any], pr: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Get all reviews for a PR."""
        owner = repo["owner"]["login"]
        repo_name = repo["name"]
        pr_number = pr["number"]

        url = f"{self.base_url}/repos/{owner}/{repo_name}/pulls/{pr_number}/reviews"
        response = requests.get(url, headers=self.headers)

        if response.status_code != 200:
            return []

        return response.json()

    def check_all_repos(self) -> Dict[str, List[Dict[str, Any]]]:
        """Check all repos for relevant PR activity."""
        results = {
            "mentions": [],
            "my_pr_comments": [],
            "approvals": []
        }

        repos = self.get_all_repos()

        for repo in repos:
            repo_name = f"{repo['owner']['login']}/{repo['name']}"
            print(f"Checking {repo_name}...")

            prs = self.get_open_prs(repo)

            for pr in prs:
                pr_author = pr["user"]["login"]
                pr_number = pr["number"]
                pr_title = pr["title"]
                pr_url = pr["html_url"]

                is_my_pr = pr_author == self.username

                # Get comments
                comments = self.get_pr_comments(repo, pr)

                for comment in comments:
                    comment_author = comment["user"]
                    comment_body = comment.get("body", "")
                    comment_created = datetime.strptime(
                        comment["created_at"], "%Y-%m-%dT%H:%M:%SZ"
                    )

                    # Skip if comment is too old
                    if comment_created < self.since:
                        continue

                    # Skip bot comments
                    if self.is_bot(comment_author):
                        continue

                    # Check for mentions
                    if f"@{self.username}" in comment_body:
                        results["mentions"].append({
                            "repo": repo_name,
                            "pr_number": pr_number,
                            "pr_title": pr_title,
                            "pr_url": pr_url,
                            "comment_author": comment_author["login"],
                            "comment_body": comment_body,
                            "comment_url": comment["html_url"]
                        })

                    # Check for comments on my PRs
                    elif is_my_pr and comment_author["login"] != self.username:
                        results["my_pr_comments"].append({
                            "repo": repo_name,
                            "pr_number": pr_number,
                            "pr_title": pr_title,
                            "pr_url": pr_url,
                            "comment_author": comment_author["login"],
                            "comment_body": comment_body,
                            "comment_url": comment["html_url"]
                        })

                # Check for approvals on my PRs
                if is_my_pr:
                    reviews = self.get_pr_reviews(repo, pr)

                    for review in reviews:
                        review_author = review["user"]
                        review_state = review.get("state", "")
                        review_submitted = datetime.strptime(
                            review["submitted_at"], "%Y-%m-%dT%H:%M:%SZ"
                        ) if review.get("submitted_at") else None

                        # Skip if review is too old
                        if review_submitted and review_submitted < self.since:
                            continue

                        # Skip bot reviews
                        if self.is_bot(review_author):
                            continue

                        # Check for approvals
                        if review_state == "APPROVED":
                            results["approvals"].append({
                                "repo": repo_name,
                                "pr_number": pr_number,
                                "pr_title": pr_title,
                                "pr_url": pr_url,
                                "reviewer": review_author["login"],
                                "review_url": review["html_url"]
                            })

        return results

    def format_slack_message(self, results: Dict[str, List[Dict[str, Any]]]) -> Dict[str, Any]:
        """Format results as a Slack message."""
        blocks = []
        has_notifications = False

        # Header
        blocks.append({
            "type": "header",
            "text": {
                "type": "plain_text",
                "text": "GitHub PR Notifications"
            }
        })

        # Mentions
        if results["mentions"]:
            has_notifications = True
            blocks.append({
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"*:eyes: You were mentioned ({len(results['mentions'])})*"
                }
            })

            for mention in results["mentions"][:5]:  # Limit to 5 per category
                blocks.append({
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": (
                            f"*<{mention['pr_url']}|{mention['repo']} #{mention['pr_number']}>*: {mention['pr_title']}\n"
                            f"@{mention['comment_author']}: {mention['comment_body'][:200]}..."
                            f"\n<{mention['comment_url']}|View comment>"
                        )
                    }
                })

            if len(results["mentions"]) > 5:
                blocks.append({
                    "type": "context",
                    "elements": [{
                        "type": "mrkdwn",
                        "text": f"_...and {len(results['mentions']) - 5} more mentions_"
                    }]
                })

            blocks.append({"type": "divider"})

        # Comments on my PRs
        if results["my_pr_comments"]:
            has_notifications = True
            blocks.append({
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"*:speech_balloon: Comments on your PRs ({len(results['my_pr_comments'])})*"
                }
            })

            for comment in results["my_pr_comments"][:5]:
                blocks.append({
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": (
                            f"*<{comment['pr_url']}|{comment['repo']} #{comment['pr_number']}>*: {comment['pr_title']}\n"
                            f"@{comment['comment_author']}: {comment['comment_body'][:200]}..."
                            f"\n<{comment['comment_url']}|View comment>"
                        )
                    }
                })

            if len(results["my_pr_comments"]) > 5:
                blocks.append({
                    "type": "context",
                    "elements": [{
                        "type": "mrkdwn",
                        "text": f"_...and {len(results['my_pr_comments']) - 5} more comments_"
                    }]
                })

            blocks.append({"type": "divider"})

        # Approvals
        if results["approvals"]:
            has_notifications = True
            blocks.append({
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"*:white_check_mark: PR Approvals ({len(results['approvals'])})*"
                }
            })

            for approval in results["approvals"][:5]:
                blocks.append({
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": (
                            f"*<{approval['pr_url']}|{approval['repo']} #{approval['pr_number']}>*: {approval['pr_title']}\n"
                            f"Approved by @{approval['reviewer']}\n"
                            f"<{approval['review_url']}|View approval>"
                        )
                    }
                })

            if len(results["approvals"]) > 5:
                blocks.append({
                    "type": "context",
                    "elements": [{
                        "type": "mrkdwn",
                        "text": f"_...and {len(results['approvals']) - 5} more approvals_"
                    }]
                })

        # No notifications
        if not has_notifications:
            blocks.append({
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": "_No new PR activity in the last hour_"
                }
            })

        return {"blocks": blocks}

    def send_to_slack(self, webhook_url: str, results: Dict[str, List[Dict[str, Any]]]):
        """Send results to Slack."""
        if not webhook_url:
            print("No Slack webhook URL provided. Skipping Slack notification.")
            return

        message = self.format_slack_message(results)

        response = requests.post(webhook_url, json=message)

        if response.status_code == 200:
            print("Slack notification sent successfully")
        else:
            print(f"Error sending Slack notification: {response.status_code}")
            print(response.text)


def main():
    token = os.environ.get("GITHUB_TOKEN")
    webhook_url = os.environ.get("SLACK_WEBHOOK_URL")
    username = os.environ.get("GITHUB_USERNAME")

    if not token:
        print("Error: GITHUB_TOKEN environment variable not set")
        sys.exit(1)

    if not username:
        print("Error: GITHUB_USERNAME environment variable not set")
        sys.exit(1)

    monitor = GitHubPRMonitor(token, username)
    results = monitor.check_all_repos()

    # Print summary
    print("\n" + "="*50)
    print("SUMMARY")
    print("="*50)
    print(f"Mentions: {len(results['mentions'])}")
    print(f"Comments on your PRs: {len(results['my_pr_comments'])}")
    print(f"Approvals: {len(results['approvals'])}")

    # Send to Slack
    if webhook_url:
        monitor.send_to_slack(webhook_url, results)
    else:
        print("\nNote: Set SLACK_WEBHOOK_URL secret to enable Slack notifications")
        print("\nResults (would be sent to Slack):")
        print(json.dumps(results, indent=2))


if __name__ == "__main__":
    main()
