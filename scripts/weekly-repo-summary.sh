#!/bin/bash
#
# Weekly Repository Summary - Wrapper Script
#
# This script provides a convenient wrapper around the Python script
# with common configuration options.

# Default configuration
WORKSPACE_DIR="${WORKSPACE_DIR:-./repos}"
DAYS_BACK="${DAYS_BACK:-7}"
OUTPUT_FORMAT="${OUTPUT_FORMAT:-text}"
MAIN_BRANCH="${MAIN_BRANCH:-main}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Help message
show_help() {
    cat << EOF
Weekly Repository Summary Script

Usage: $0 [OPTIONS]

Options:
    -f, --file FILE         Path to file containing repository URLs (one per line)
    -r, --repos REPOS       Comma-separated list of repository URLs
    -w, --workspace DIR     Workspace directory for cloning repos (default: ./repos)
    -d, --days DAYS         Number of days to look back (default: 7)
    -o, --output FILE       Output file path (prints to stdout if not specified)
    -j, --json              Output in JSON format (default: text)
    -b, --branch BRANCH     Main branch name (default: main)
    -h, --help              Show this help message

Environment Variables:
    REPO_LIST              Comma-separated list of repository URLs
    REPO_LIST_FILE         Path to file containing repository URLs
    WORKSPACE_DIR          Workspace directory (default: ./repos)
    DAYS_BACK             Number of days to look back (default: 7)
    OUTPUT_FORMAT         Output format: 'text' or 'json' (default: text)
    OUTPUT_FILE           Output file path
    MAIN_BRANCH           Main branch name (default: main)

Examples:
    # Using a file with repository URLs
    $0 --file repos.txt

    # Using command-line repository list
    $0 --repos "https://github.com/user/repo1,https://github.com/user/repo2"

    # Look back 14 days and output as JSON
    $0 --file repos.txt --days 14 --json

    # Using environment variables
    export REPO_LIST_FILE="repos.txt"
    export DAYS_BACK=14
    $0

    # Save output to file
    $0 --file repos.txt --output summary.txt

    # Pipe to LLM for summarization (example with Claude CLI)
    $0 --file repos.txt | claude "Please provide a concise summary of this week's development activity"

EOF
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--file)
            export REPO_LIST_FILE="$2"
            shift 2
            ;;
        -r|--repos)
            export REPO_LIST="$2"
            shift 2
            ;;
        -w|--workspace)
            export WORKSPACE_DIR="$2"
            shift 2
            ;;
        -d|--days)
            export DAYS_BACK="$2"
            shift 2
            ;;
        -o|--output)
            export OUTPUT_FILE="$2"
            shift 2
            ;;
        -j|--json)
            export OUTPUT_FORMAT="json"
            shift
            ;;
        -b|--branch)
            export MAIN_BRANCH="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not found"
    exit 1
fi

# Run the Python script
python3 "$SCRIPT_DIR/weekly-repo-summary.py"
