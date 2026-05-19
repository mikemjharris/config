#!/bin/bash

# Run Claude agent review on a PR
#
# This script uses local Claude CLI to run specialized code review agents
# on a pull request. No API key needed - uses your local Claude installation.
#
# Usage:
#   ./scripts/run-pr-agent-review.sh <pr-number> [agent-type]
#   ./scripts/run-pr-agent-review.sh list  # List available agents
#
# Agent types:
#   - all (default): Run all specialized agents
#   - rails-db: Rails database performance (N+1 queries, indexes)
#   - rails-react: Rails/React code review
#   - code-quality: Code quality and style guide adherence
#   - silent-failures: Silent error detection
#   - code-simplification: Code simplification suggestions
#   - test-coverage: Test coverage analysis
#   - type-design: Type design review
#   - comments: Comment quality review
#   - security: Security vulnerability scan
#   - performance: Performance analysis

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }

# Function to list available agents
list_agents() {
    echo "Available Claude Review Agents:"
    echo ""
    echo "  ${GREEN}all${NC}                  - Run all specialized agents (recommended)"
    echo ""
    echo "${BLUE}Specialized Agents:${NC}"
    echo "  ${GREEN}rails-db${NC}            - Rails database performance (N+1, indexes, queries)"
    echo "  ${GREEN}rails-react${NC}         - Rails/React code review (conventions, patterns)"
    echo "  ${GREEN}code-quality${NC}        - Code quality and style guide adherence"
    echo "  ${GREEN}silent-failures${NC}     - Silent error detection (catch blocks, fallbacks)"
    echo "  ${GREEN}code-simplification${NC} - Code simplification opportunities"
    echo "  ${GREEN}test-coverage${NC}       - Test coverage and quality analysis"
    echo "  ${GREEN}type-design${NC}         - Type design review (encapsulation, invariants)"
    echo "  ${GREEN}comments${NC}            - Comment accuracy and documentation quality"
    echo ""
    echo "${BLUE}Generic Agents:${NC}"
    echo "  ${GREEN}security${NC}            - Security vulnerability scan"
    echo "  ${GREEN}performance${NC}         - Performance analysis"
    echo ""
    echo "Usage:"
    echo "  $0 <pr-number>              # Run all agents"
    echo "  $0 <pr-number> rails-db     # Run specific agent"
    echo "  $0 list                     # Show this list"
}

# Check for list command
if [ "$1" = "list" ] || [ "$1" = "--list" ] || [ "$1" = "-l" ]; then
    list_agents
    exit 0
fi

# Check arguments
if [ $# -lt 1 ]; then
    log_error "Usage: $0 <pr-number> [agent-type]"
    echo ""
    echo "Run '$0 list' to see available agent types"
    exit 1
fi

PR_NUMBER=$1
AGENT_TYPE=${2:-all}

# Verify PR exists
if ! gh pr view "$PR_NUMBER" &>/dev/null; then
    log_error "PR #$PR_NUMBER not found"
    exit 1
fi

# Get PR details
log_info "Fetching PR details..."
PR_DETAILS=$(gh pr view "$PR_NUMBER" --json number,title,baseRefName,headRefName,url)
PR_URL=$(echo "$PR_DETAILS" | jq -r '.url')
BASE_BRANCH=$(echo "$PR_DETAILS" | jq -r '.baseRefName')
HEAD_BRANCH=$(echo "$PR_DETAILS" | jq -r '.headRefName')
PR_TITLE=$(echo "$PR_DETAILS" | jq -r '.title')

log_success "PR #$PR_NUMBER: $PR_TITLE"
log_info "Base: $BASE_BRANCH → Head: $HEAD_BRANCH"
log_info "URL: $PR_URL"
echo ""

# Fetch the branches
log_info "Fetching latest changes..."
git fetch origin "$BASE_BRANCH" "$HEAD_BRANCH" 2>/dev/null || true

# Get the diff
log_info "Generating diff..."
DIFF=$(git diff "origin/$BASE_BRANCH...origin/$HEAD_BRANCH" 2>/dev/null || \
       git diff "$BASE_BRANCH...$HEAD_BRANCH" 2>/dev/null || \
       echo "Unable to generate diff")

if [ -z "$DIFF" ]; then
    log_error "No diff found. Branches may be identical."
    exit 1
fi

# Create output directory
OUTPUT_DIR="/tmp/claude-pr-review-$PR_NUMBER"
mkdir -p "$OUTPUT_DIR"

# Function to run Claude agent using local CLI
run_claude_agent() {
    local agent_type=$1
    local agent_name=$2
    local output_file="$OUTPUT_DIR/${agent_name}-review.md"

    log_info "Running $agent_name agent..."

    # Create a temporary file with the diff and context
    local temp_context="/tmp/claude-agent-context-$$.md"
    cat > "$temp_context" <<EOF
# PR Context

**PR Number:** #$PR_NUMBER
**URL:** $PR_URL
**Title:** $PR_TITLE
**Base:** $BASE_BRANCH → **Head:** $HEAD_BRANCH

# Diff

\`\`\`diff
$DIFF
\`\`\`
EOF

    # Create the output file with header
    {
        echo "# $agent_name Review"
        echo ""
        echo "**PR:** $PR_URL (#$PR_NUMBER)"
        echo "**Base:** $BASE_BRANCH → **Head:** $HEAD_BRANCH"
        echo ""
        echo "---"
        echo ""
    } > "$output_file"

    # Run the Claude agent based on type
    case "$agent_type" in
        "subagent")
            # Use Task tool with specialized subagent
            local subagent_type=$3
            local agent_prompt=$4

            # Create agent input file
            local agent_input="/tmp/claude-agent-input-$$.txt"
            cat > "$agent_input" <<EOF
$agent_prompt

Review the following pull request:

$(cat "$temp_context")
EOF

            # Launch Claude agent via CLI
            claude --no-stream <<AGENT_EOF >> "$output_file" 2>&1
Please analyze this PR using the $subagent_type agent.

$(cat "$agent_input")
AGENT_EOF

            rm -f "$agent_input"
            ;;

        "direct")
            # Direct Claude CLI call with specific prompt
            local agent_prompt=$3

            claude --no-stream <<DIRECT_EOF >> "$output_file" 2>&1
$(cat "$temp_context")

---

$agent_prompt
DIRECT_EOF
            ;;

        *)
            log_error "Unknown agent type: $agent_type"
            return 1
            ;;
    esac

    rm -f "$temp_context"

    # Check if output file has content
    if [ -s "$output_file" ]; then
        log_success "$agent_name review completed: $output_file"
    else
        log_warning "$agent_name review produced no output"
    fi
}

# Define agent configurations
# Format: "agent_type|subagent_name|Display Name|Prompt"
declare -A AGENTS

AGENTS[rails-db]="subagent|rails-query-optimizer|Rails Database Performance|Using the rails-query-optimizer agent, analyze this PR for:
- N+1 queries (missing includes/joins)
- Missing database indexes
- Inefficient queries
- Large data loads without pagination
- Suboptimal ActiveRecord usage"

AGENTS[rails-react]="subagent|rails-react-code-reviewer|Rails/React Code Review|Using the rails-react-code-reviewer agent, review this PR for:
- Rails conventions and best practices
- React component patterns
- Code organization and structure
- Adherence to project patterns"

AGENTS[code-quality]="subagent|pr-review-toolkit:code-reviewer|Code Quality Review|Using the code-reviewer agent, analyze for:
- Style guide violations
- Code quality issues
- Inconsistent patterns
- Best practice violations"

AGENTS[silent-failures]="subagent|pr-review-toolkit:silent-failure-hunter|Silent Failure Analysis|Using the silent-failure-hunter agent, check for:
- Silent error suppression
- Inadequate error handling
- Inappropriate fallback behavior
- Missing error logging"

AGENTS[code-simplification]="subagent|pr-review-toolkit:code-simplifier|Code Simplification|Using the code-simplifier agent, identify:
- Overly complex code
- Opportunities for simplification
- Redundant logic
- Better patterns to use"

AGENTS[test-coverage]="subagent|pr-review-toolkit:pr-test-analyzer|Test Coverage Analysis|Using the pr-test-analyzer agent, review:
- Test coverage completeness
- Missing edge cases
- Test quality issues
- Critical gaps in testing"

AGENTS[type-design]="subagent|pr-review-toolkit:type-design-analyzer|Type Design Review|Using the type-design-analyzer agent, analyze:
- Type design quality
- Encapsulation strength
- Invariant expression
- Type safety improvements"

AGENTS[comments]="subagent|pr-review-toolkit:comment-analyzer|Comment Quality Review|Using the comment-analyzer agent, check:
- Comment accuracy
- Documentation completeness
- Potential for comment rot
- Long-term maintainability"

# Generic agents (using direct Claude calls)
AGENTS[security]="direct||Security Review|Analyze this PR for security vulnerabilities:
- SQL injection risks
- XSS vulnerabilities
- Missing authorization checks
- Exposed sensitive data
- CSRF vulnerabilities
- Insecure direct object references
- Mass assignment issues

Provide specific file:line references for any issues found."

AGENTS[performance]="direct||Performance Analysis|Analyze this PR for performance issues:
- Inefficient algorithms
- Unnecessary iterations
- Memory leaks
- Expensive operations in loops
- Missing caching opportunities
- Unnecessary database calls

Provide specific recommendations with file:line references."

# Run the requested agents
run_agents() {
    case $AGENT_TYPE in
        all)
            # Run all specialized agents
            for agent_key in rails-db rails-react code-quality silent-failures test-coverage; do
                if [ -n "${AGENTS[$agent_key]}" ]; then
                    IFS='|' read -r agent_type subagent_name display_name prompt <<< "${AGENTS[$agent_key]}"
                    if [ "$agent_type" = "subagent" ]; then
                        run_claude_agent "subagent" "$display_name" "$subagent_name" "$prompt"
                    else
                        run_claude_agent "direct" "$display_name" "$prompt"
                    fi
                    echo ""
                fi
            done
            ;;
        *)
            # Run specific agent
            if [ -n "${AGENTS[$AGENT_TYPE]}" ]; then
                IFS='|' read -r agent_type subagent_name display_name prompt <<< "${AGENTS[$AGENT_TYPE]}"
                if [ "$agent_type" = "subagent" ]; then
                    run_claude_agent "subagent" "$display_name" "$subagent_name" "$prompt"
                else
                    run_claude_agent "direct" "$display_name" "$prompt"
                fi
            else
                log_error "Unknown agent type: $AGENT_TYPE"
                echo ""
                echo "Available agent types:"
                echo "  all                  - Run all specialized agents"
                echo "  rails-db            - Rails database performance"
                echo "  rails-react         - Rails/React code review"
                echo "  code-quality        - Code quality and style"
                echo "  silent-failures     - Silent error detection"
                echo "  code-simplification - Code simplification suggestions"
                echo "  test-coverage       - Test coverage analysis"
                echo "  type-design         - Type design review"
                echo "  comments            - Comment quality review"
                echo "  security            - Security vulnerability scan"
                echo "  performance         - Performance analysis"
                exit 1
            fi
            ;;
    esac
}

# Run the agents
run_agents

# Display summary
echo ""
log_success "Review complete!"
echo ""
log_info "Results saved to: $OUTPUT_DIR"
ls -1 "$OUTPUT_DIR"
echo ""

# Ask if user wants to post results to PR
read -p "$(echo -e ${YELLOW}?${NC}) Post review summary as PR comment? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Posting review to PR..."

    # Combine all reviews into a single comment
    COMMENT="## 🤖 Automated Code Review Results\n\n"
    COMMENT+="_Generated by Claude AI agents_\n\n"

    for review_file in "$OUTPUT_DIR"/*-review.md; do
        if [ -f "$review_file" ]; then
            agent_name=$(basename "$review_file" -review.md)
            COMMENT+="<details>\n"
            COMMENT+="<summary><strong>$agent_name</strong></summary>\n\n"
            COMMENT+="$(cat "$review_file")\n\n"
            COMMENT+="</details>\n\n"
        fi
    done

    COMMENT+="---\n"
    COMMENT+="_Full review details: \`$OUTPUT_DIR\`_"

    echo -e "$COMMENT" | gh pr comment "$PR_NUMBER" --body-file -

    log_success "Review posted to PR!"
    log_info "View at: $PR_URL"
fi

log_success "Done! 🎉"
