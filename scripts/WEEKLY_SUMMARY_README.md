# Weekly Repository Summary Script

A powerful script to gather and summarize commits from multiple Git repositories over a specified time period. The script categorizes commits by type (features, bug fixes, chores, etc.) and formats the data for easy review or LLM-based summarization.

## Features

- 📊 Analyze multiple repositories in a single run
- 🔄 Automatically clone or update repositories
- 📅 Filter commits by time period (default: last 7 days)
- 🏷️ Categorize commits by conventional commit prefixes (feat, fix, chore, etc.)
- 📝 Output in text or JSON format
- 🤖 LLM-ready output for automated summarization
- ⚙️ Flexible configuration via environment variables or command-line arguments

## Quick Start

### 1. Create a Repository List

Create a file with your repository URLs (one per line):

```bash
cat > repos.txt << EOF
https://github.com/yourorg/repo1
https://github.com/yourorg/repo2
https://github.com/yourorg/repo3
EOF
```

Or copy the example file:

```bash
cp repos.example.txt repos.txt
# Edit repos.txt to add your repositories
```

### 2. Run the Script

**Using the bash wrapper (recommended):**

```bash
./weekly-repo-summary.sh --file repos.txt
```

**Using Python directly:**

```bash
export REPO_LIST_FILE="repos.txt"
python3 weekly-repo-summary.py
```

### 3. Review the Summary

The script will output a formatted summary showing:
- Commits grouped by repository
- Commits categorized by type
- Author and date information
- Overall statistics

## Usage

### Command-Line Options

```bash
./weekly-repo-summary.sh [OPTIONS]

Options:
  -f, --file FILE         Path to file containing repository URLs
  -r, --repos REPOS       Comma-separated list of repository URLs
  -w, --workspace DIR     Workspace directory for cloning repos (default: ./repos)
  -d, --days DAYS         Number of days to look back (default: 7)
  -o, --output FILE       Output file path (prints to stdout if not specified)
  -j, --json              Output in JSON format (default: text)
  -b, --branch BRANCH     Main branch name (default: main)
  -h, --help              Show help message
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `REPO_LIST` | Comma-separated list of repository URLs | - |
| `REPO_LIST_FILE` | Path to file containing repository URLs | - |
| `WORKSPACE_DIR` | Directory where repos will be cloned | `./repos` |
| `DAYS_BACK` | Number of days to look back | `7` |
| `OUTPUT_FORMAT` | Output format: 'text' or 'json' | `text` |
| `OUTPUT_FILE` | Path to save output file | - |
| `MAIN_BRANCH` | Main branch name to analyze | `main` |

## Examples

### Basic Usage

Analyze repositories from a file:

```bash
./weekly-repo-summary.sh --file repos.txt
```

### Using Repository List

Analyze specific repositories without a file:

```bash
./weekly-repo-summary.sh --repos "https://github.com/user/repo1,https://github.com/user/repo2"
```

### Custom Time Period

Look back 14 days instead of 7:

```bash
./weekly-repo-summary.sh --file repos.txt --days 14
```

### JSON Output

Get output in JSON format for programmatic processing:

```bash
./weekly-repo-summary.sh --file repos.txt --json
```

### Save to File

Save the summary to a file:

```bash
./weekly-repo-summary.sh --file repos.txt --output weekly-summary.txt
```

### Using Environment Variables

```bash
export REPO_LIST_FILE="repos.txt"
export DAYS_BACK=14
export OUTPUT_FORMAT="json"
export WORKSPACE_DIR="/tmp/repo-analysis"

./weekly-repo-summary.sh
```

## LLM Integration

The script is designed to work seamlessly with LLMs for generating human-readable summaries.

### Option 1: Pipe to LLM CLI

If you have Claude CLI or another LLM tool installed:

```bash
./weekly-repo-summary.sh --file repos.txt | claude "Please provide a concise executive summary of this week's development activity, highlighting key features, bug fixes, and any notable trends."
```

### Option 2: Save and Process

```bash
# Generate summary
./weekly-repo-summary.sh --file repos.txt --output summary.txt

# Process with your LLM tool
claude < summary.txt "Analyze this commit history and provide insights on: 1) Main development focus areas, 2) Team productivity trends, 3) Code quality indicators"
```

### Option 3: JSON for Structured Processing

```bash
./weekly-repo-summary.sh --file repos.txt --json --output summary.json

# Use with API or custom processing
curl -X POST https://api.anthropic.com/v1/messages \
  -H "content-type: application/json" \
  -d "{\"messages\": [{\"role\": \"user\", \"content\": \"Summarize this: $(cat summary.json)\"}]}"
```

## Commit Categories

The script automatically categorizes commits based on conventional commit prefixes:

| Prefix | Category |
|--------|----------|
| `feat:`, `feature:` | Features |
| `fix:`, `bugfix:` | Bug Fixes |
| `docs:`, `doc:` | Documentation |
| `style:` | Style Changes |
| `refactor:` | Refactoring |
| `perf:` | Performance Improvements |
| `test:` | Tests |
| `build:` | Build System |
| `ci:` | CI/CD |
| `chore:` | Chores |
| `revert:` | Reverts |

Commits without recognized prefixes are categorized as "Other".

## Output Format

### Text Format

```
================================================================================
WEEKLY REPOSITORY SUMMARY
Period: 2025-10-23 to 2025-10-30
================================================================================

================================================================================
Repository: my-project
Commits: 15
================================================================================

Features (5):
----------------------------------------
  [a1b2c3d4] feat: add user authentication
    Author: Jane Doe
    Date: 2025-10-28 14:30:00 +0000

  [e5f6g7h8] feat(api): implement REST endpoints
    Author: John Smith
    Date: 2025-10-27 10:15:00 +0000

Bug Fixes (3):
----------------------------------------
  [i9j0k1l2] fix: resolve login timeout issue
    Author: Jane Doe
    Date: 2025-10-26 16:45:00 +0000

...

================================================================================
SUMMARY
================================================================================
Total repositories analyzed: 3
Total commits: 42

Commits by category:
  Features: 15
  Bug Fixes: 10
  Documentation: 5
  Chores: 8
  Other: 4
```

### JSON Format

```json
{
  "period": {
    "start": "2025-10-23",
    "end": "2025-10-30",
    "days": 7
  },
  "repositories": [
    {
      "name": "my-project",
      "url": "https://github.com/user/my-project",
      "path": "/path/to/repos/my-project",
      "commits": [
        {
          "hash": "a1b2c3d4",
          "author": "Jane Doe",
          "date": "2025-10-28 14:30:00 +0000",
          "message": "feat: add user authentication",
          "category": "Features"
        }
      ],
      "commit_count": 15
    }
  ]
}
```

## Troubleshooting

### Permission Denied

If you get a permission error, make sure the scripts are executable:

```bash
chmod +x weekly-repo-summary.sh
chmod +x weekly-repo-summary.py
```

### Git Authentication Issues

If you have trouble cloning private repositories:

1. **HTTPS**: Use a personal access token in the URL
   ```
   https://USERNAME:TOKEN@github.com/user/repo.git
   ```

2. **SSH**: Ensure your SSH keys are set up
   ```bash
   ssh-add ~/.ssh/id_rsa
   ```

### Python Not Found

Ensure Python 3 is installed:

```bash
python3 --version
```

If not installed, install it using your package manager:

```bash
# Ubuntu/Debian
sudo apt-get install python3

# macOS
brew install python3
```

### Repository Not Found

Make sure the repository URLs are correct and you have access to them. Test manually:

```bash
git clone REPO_URL
```

## Advanced Usage

### Analyzing Different Branches

By default, the script analyzes the `main` branch. To analyze a different branch:

```bash
./weekly-repo-summary.sh --file repos.txt --branch develop
```

### Custom Workspace Directory

Store cloned repositories in a specific location:

```bash
./weekly-repo-summary.sh --file repos.txt --workspace /tmp/my-analysis
```

### Automated Weekly Reports

Set up a cron job to generate weekly reports automatically:

```bash
# Edit crontab
crontab -e

# Add this line to run every Monday at 9 AM
0 9 * * 1 /path/to/weekly-repo-summary.sh --file /path/to/repos.txt --output /path/to/reports/weekly-$(date +\%Y-\%m-\%d).txt
```

### Integration with CI/CD

Use in GitHub Actions, GitLab CI, or other CI/CD systems:

```yaml
# .github/workflows/weekly-summary.yml
name: Weekly Repository Summary

on:
  schedule:
    - cron: '0 9 * * 1'  # Every Monday at 9 AM

jobs:
  summary:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Generate Summary
        run: |
          ./scripts/weekly-repo-summary.sh --file repos.txt --output summary.txt

      - name: Upload Summary
        uses: actions/upload-artifact@v2
        with:
          name: weekly-summary
          path: summary.txt
```

## Requirements

- Python 3.6 or higher
- Git
- Access to the repositories you want to analyze

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests.

## License

This script is part of the config repository and follows the same license.

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the examples
3. Open an issue in the repository
