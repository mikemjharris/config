#!/usr/bin/env python3
"""
Weekly Repository Summary Script

This script gathers commit data from multiple GitHub repositories over the past week,
categorizes commits by type (feat, fix, chore, etc.), and formats the data for
LLM summarization.

Environment Variables:
    REPO_LIST: Comma-separated list of repository URLs or names
    REPO_LIST_FILE: Path to a file containing repository URLs (one per line)
    WORKSPACE_DIR: Directory where repositories will be cloned (default: ./repos)
    DAYS_BACK: Number of days to look back for commits (default: 7)
    OUTPUT_FORMAT: Output format - 'json' or 'text' (default: 'text')
    MAIN_BRANCH: Name of the main branch to analyze (default: 'main')
"""

import os
import sys
import subprocess
import json
import re
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Dict, Tuple
from collections import defaultdict


class RepoSummaryGenerator:
    """Generates weekly summaries for git repositories."""

    COMMIT_CATEGORIES = {
        'feat': 'Features',
        'feature': 'Features',
        'fix': 'Bug Fixes',
        'bugfix': 'Bug Fixes',
        'docs': 'Documentation',
        'doc': 'Documentation',
        'style': 'Style Changes',
        'refactor': 'Refactoring',
        'perf': 'Performance Improvements',
        'test': 'Tests',
        'build': 'Build System',
        'ci': 'CI/CD',
        'chore': 'Chores',
        'revert': 'Reverts',
    }

    def __init__(self, workspace_dir: str = './repos', days_back: int = 7,
                 main_branch: str = 'main'):
        """
        Initialize the summary generator.

        Args:
            workspace_dir: Directory to store cloned repositories
            days_back: Number of days to look back for commits
            main_branch: Name of the main branch to analyze
        """
        self.workspace_dir = Path(workspace_dir).expanduser()
        self.workspace_dir.mkdir(parents=True, exist_ok=True)
        self.days_back = days_back
        self.main_branch = main_branch
        self.since_date = datetime.now() - timedelta(days=days_back)

    def run_command(self, cmd: List[str], cwd: Path = None,
                   check: bool = True) -> Tuple[bool, str, str]:
        """
        Run a shell command and return the result.

        Args:
            cmd: Command to run as a list of arguments
            cwd: Working directory for the command
            check: Whether to raise an exception on non-zero exit

        Returns:
            Tuple of (success, stdout, stderr)
        """
        try:
            result = subprocess.run(
                cmd,
                cwd=cwd,
                capture_output=True,
                text=True,
                check=check
            )
            return True, result.stdout, result.stderr
        except subprocess.CalledProcessError as e:
            if check:
                return False, e.stdout, e.stderr
            raise

    def get_repo_name(self, repo_url: str) -> str:
        """
        Extract repository name from URL or path.

        Args:
            repo_url: Repository URL or name

        Returns:
            Repository name
        """
        # Handle GitHub URLs
        if repo_url.startswith(('http://', 'https://', 'git@')):
            # Extract name from URL
            name = repo_url.rstrip('/').split('/')[-1]
            if name.endswith('.git'):
                name = name[:-4]
            return name
        else:
            # Assume it's already a name or local path
            return Path(repo_url).name

    def clone_or_update_repo(self, repo_url: str) -> Tuple[bool, Path]:
        """
        Clone a repository if it doesn't exist, otherwise update it.

        Args:
            repo_url: Repository URL or path

        Returns:
            Tuple of (success, repo_path)
        """
        repo_name = self.get_repo_name(repo_url)
        repo_path = self.workspace_dir / repo_name

        if repo_path.exists():
            print(f"  Updating existing repository: {repo_name}")
            # Fetch latest changes
            success, stdout, stderr = self.run_command(
                ['git', 'fetch', 'origin'],
                cwd=repo_path,
                check=False
            )
            if not success:
                print(f"  Warning: Failed to fetch updates for {repo_name}: {stderr}")
                return True, repo_path  # Continue with existing repo

            # Try to checkout main branch
            for branch in [self.main_branch, 'master']:
                success, _, _ = self.run_command(
                    ['git', 'checkout', branch],
                    cwd=repo_path,
                    check=False
                )
                if success:
                    self.main_branch = branch
                    break

            # Pull latest changes
            success, stdout, stderr = self.run_command(
                ['git', 'pull', 'origin', self.main_branch],
                cwd=repo_path,
                check=False
            )
            if not success:
                print(f"  Warning: Failed to pull updates for {repo_name}: {stderr}")
        else:
            print(f"  Cloning repository: {repo_name}")
            success, stdout, stderr = self.run_command(
                ['git', 'clone', repo_url, str(repo_path)],
                check=False
            )
            if not success:
                print(f"  Error: Failed to clone {repo_name}: {stderr}")
                return False, repo_path

        return True, repo_path

    def categorize_commit(self, message: str) -> str:
        """
        Categorize a commit based on its message prefix.

        Args:
            message: Commit message

        Returns:
            Category name
        """
        # Extract prefix (e.g., "feat:", "fix:", etc.)
        match = re.match(r'^(\w+)[\(\:]', message.lower())
        if match:
            prefix = match.group(1)
            if prefix in self.COMMIT_CATEGORIES:
                return self.COMMIT_CATEGORIES[prefix]

        return 'Other'

    def get_commits_from_repo(self, repo_path: Path) -> List[Dict]:
        """
        Get commits from the last week in the repository.

        Args:
            repo_path: Path to the repository

        Returns:
            List of commit dictionaries
        """
        since_str = self.since_date.strftime('%Y-%m-%d')

        # Get commit information: hash, author, date, message
        # Format: <hash>|<author>|<date>|<message>
        success, stdout, stderr = self.run_command(
            [
                'git', 'log',
                f'--since={since_str}',
                '--pretty=format:%H|%an|%ai|%s',
                self.main_branch
            ],
            cwd=repo_path,
            check=False
        )

        if not success:
            print(f"  Warning: Failed to get commits: {stderr}")
            return []

        commits = []
        for line in stdout.strip().split('\n'):
            if not line:
                continue

            try:
                commit_hash, author, date, message = line.split('|', 3)
                category = self.categorize_commit(message)

                commits.append({
                    'hash': commit_hash[:8],
                    'author': author,
                    'date': date,
                    'message': message,
                    'category': category
                })
            except ValueError:
                print(f"  Warning: Failed to parse commit line: {line}")
                continue

        return commits

    def format_as_text(self, all_data: Dict) -> str:
        """
        Format the collected data as human-readable text.

        Args:
            all_data: Dictionary containing all repository data

        Returns:
            Formatted text string
        """
        lines = []
        lines.append("=" * 80)
        lines.append(f"WEEKLY REPOSITORY SUMMARY")
        lines.append(f"Period: {self.since_date.strftime('%Y-%m-%d')} to {datetime.now().strftime('%Y-%m-%d')}")
        lines.append("=" * 80)
        lines.append("")

        total_commits = 0
        total_repos = len(all_data['repositories'])

        for repo_data in all_data['repositories']:
            repo_name = repo_data['name']
            commits = repo_data['commits']
            commit_count = len(commits)
            total_commits += commit_count

            lines.append(f"\n{'=' * 80}")
            lines.append(f"Repository: {repo_name}")
            lines.append(f"Commits: {commit_count}")
            lines.append(f"{'=' * 80}")

            if commit_count == 0:
                lines.append("  No commits in the specified time period.")
                continue

            # Group commits by category
            categorized = defaultdict(list)
            for commit in commits:
                categorized[commit['category']].append(commit)

            # Display by category
            for category in sorted(categorized.keys()):
                category_commits = categorized[category]
                lines.append(f"\n{category} ({len(category_commits)}):")
                lines.append("-" * 40)

                for commit in category_commits:
                    lines.append(f"  [{commit['hash']}] {commit['message']}")
                    lines.append(f"    Author: {commit['author']}")
                    lines.append(f"    Date: {commit['date']}")
                    lines.append("")

        # Summary
        lines.append("\n" + "=" * 80)
        lines.append("SUMMARY")
        lines.append("=" * 80)
        lines.append(f"Total repositories analyzed: {total_repos}")
        lines.append(f"Total commits: {total_commits}")

        # Category breakdown across all repos
        all_categories = defaultdict(int)
        for repo_data in all_data['repositories']:
            for commit in repo_data['commits']:
                all_categories[commit['category']] += 1

        if all_categories:
            lines.append("\nCommits by category:")
            for category in sorted(all_categories.keys()):
                lines.append(f"  {category}: {all_categories[category]}")

        lines.append("")
        return '\n'.join(lines)

    def format_as_json(self, all_data: Dict) -> str:
        """
        Format the collected data as JSON.

        Args:
            all_data: Dictionary containing all repository data

        Returns:
            JSON string
        """
        return json.dumps(all_data, indent=2)

    def generate_summary(self, repos: List[str], output_format: str = 'text') -> str:
        """
        Generate a summary for all specified repositories.

        Args:
            repos: List of repository URLs or names
            output_format: Output format ('text' or 'json')

        Returns:
            Formatted summary string
        """
        all_data = {
            'period': {
                'start': self.since_date.strftime('%Y-%m-%d'),
                'end': datetime.now().strftime('%Y-%m-%d'),
                'days': self.days_back
            },
            'repositories': []
        }

        print(f"\nAnalyzing {len(repos)} repositories...")
        print(f"Looking for commits since: {self.since_date.strftime('%Y-%m-%d')}\n")

        for repo_url in repos:
            repo_url = repo_url.strip()
            if not repo_url:
                continue

            print(f"Processing: {repo_url}")
            success, repo_path = self.clone_or_update_repo(repo_url)

            if not success:
                continue

            commits = self.get_commits_from_repo(repo_path)

            repo_data = {
                'name': self.get_repo_name(repo_url),
                'url': repo_url,
                'path': str(repo_path),
                'commits': commits,
                'commit_count': len(commits)
            }

            all_data['repositories'].append(repo_data)
            print(f"  Found {len(commits)} commits")

        # Format output
        if output_format.lower() == 'json':
            return self.format_as_json(all_data)
        else:
            return self.format_as_text(all_data)


def load_repos_from_file(file_path: str) -> List[str]:
    """
    Load repository URLs from a file.

    Args:
        file_path: Path to the file

    Returns:
        List of repository URLs
    """
    try:
        with open(file_path, 'r') as f:
            return [line.strip() for line in f if line.strip() and not line.startswith('#')]
    except FileNotFoundError:
        print(f"Error: File not found: {file_path}")
        return []
    except Exception as e:
        print(f"Error reading file {file_path}: {e}")
        return []


def main():
    """Main entry point for the script."""
    # Get configuration from environment variables
    repo_list = os.environ.get('REPO_LIST', '')
    repo_list_file = os.environ.get('REPO_LIST_FILE', '')
    workspace_dir = os.environ.get('WORKSPACE_DIR', './repos')
    days_back = int(os.environ.get('DAYS_BACK', '7'))
    output_format = os.environ.get('OUTPUT_FORMAT', 'text')
    main_branch = os.environ.get('MAIN_BRANCH', 'main')
    output_file = os.environ.get('OUTPUT_FILE', '')

    # Collect repository URLs
    repos = []

    if repo_list:
        repos.extend(repo_list.split(','))

    if repo_list_file:
        repos.extend(load_repos_from_file(repo_list_file))

    if not repos:
        print("Error: No repositories specified!")
        print("\nPlease set one of the following environment variables:")
        print("  REPO_LIST: Comma-separated list of repository URLs")
        print("  REPO_LIST_FILE: Path to a file containing repository URLs")
        print("\nExample:")
        print("  export REPO_LIST='https://github.com/user/repo1,https://github.com/user/repo2'")
        print("  python3 weekly-repo-summary.py")
        sys.exit(1)

    # Generate summary
    generator = RepoSummaryGenerator(
        workspace_dir=workspace_dir,
        days_back=days_back,
        main_branch=main_branch
    )

    summary = generator.generate_summary(repos, output_format)

    # Output results
    if output_file:
        with open(output_file, 'w') as f:
            f.write(summary)
        print(f"\nSummary written to: {output_file}")
    else:
        print("\n" + summary)


if __name__ == '__main__':
    main()
