# PR Creation with Automated Review

Scripts for creating pull requests with intelligent base branch detection and automated Claude AI code review.

## Scripts

### 1. `create-pr-with-review.sh`

Creates a PR with smart base branch detection and optional automated review.

**Features:**
- Analyzes git history to suggest the best base branch
- Detects if your branch should be based on another feature branch with an open PR
- Interactive prompts for title and body (like `gh pr create`)
- Optionally runs automated Claude review agents
- Posts review results as PR comments

**Usage:**
```bash
./scripts/create-pr-with-review.sh
```

**Interactive Flow:**
1. Script analyzes git history to suggest base branch
2. Prompts for base branch (with intelligent default)
3. Shows commits that will be in the PR
4. Prompts for PR title
5. Prompts for PR body (multi-line, Ctrl+D to finish)
6. Confirms before creating PR
7. Creates PR on GitHub
8. Asks if you want to run automated review agents

### 2. `run-pr-agent-review.sh`

Runs specialized Claude AI review agents on an existing PR using your local Claude CLI.

**Features:**
- Uses **local Claude CLI** (no API key needed)
- Fetches PR diff and details
- Runs specialized review agents powered by Claude's Task system:

  **Specialized Agents:**
  - **rails-db**: Rails database performance (rails-query-optimizer agent)
  - **rails-react**: Rails/React code review (rails-react-code-reviewer agent)
  - **code-quality**: Code quality and style guide adherence
  - **silent-failures**: Silent error detection and fallback analysis
  - **code-simplification**: Code simplification opportunities
  - **test-coverage**: Test coverage and quality analysis
  - **type-design**: Type design review (encapsulation, invariants)
  - **comments**: Comment accuracy and documentation quality

  **Generic Agents:**
  - **security**: Security vulnerability scan
  - **performance**: Performance analysis

- Optionally posts results as PR comments

**Usage:**
```bash
# List available agents
./scripts/run-pr-agent-review.sh list

# Run all specialized agents on PR #123
./scripts/run-pr-agent-review.sh 123

# Run specific agents
./scripts/run-pr-agent-review.sh 123 rails-db           # Rails DB performance
./scripts/run-pr-agent-review.sh 123 rails-react        # Rails/React review
./scripts/run-pr-agent-review.sh 123 code-quality       # Code quality
./scripts/run-pr-agent-review.sh 123 silent-failures    # Silent errors
./scripts/run-pr-agent-review.sh 123 test-coverage      # Test coverage
./scripts/run-pr-agent-review.sh 123 security           # Security scan
```

**Agent Types:**
- `all` (default): Run all specialized agents
- `rails-db`: Rails database performance analysis
- `rails-react`: Rails/React code review
- `code-quality`: Code quality and style
- `silent-failures`: Silent error detection
- `code-simplification`: Simplification suggestions
- `test-coverage`: Test coverage analysis
- `type-design`: Type design review
- `comments`: Comment quality review
- `security`: Security vulnerability scan
- `performance`: Performance analysis

## Setup

### Prerequisites

1. **GitHub CLI** (`gh`):
   ```bash
   brew install gh
   gh auth login
   ```

2. **Claude Code CLI** (for automated reviews):
   ```bash
   # Install Claude Code CLI
   brew install anthropics/claude/claude

   # Login to Claude
   claude auth login
   ```

   The review script uses your local Claude CLI - no API key needed!
   It leverages Claude's specialized agents (Task tool) for intelligent analysis.

### Installation

Scripts are already in the `scripts/` directory and marked as executable:
```bash
ls -l scripts/create-pr-with-review.sh
ls -l scripts/run-pr-agent-review.sh
```

### Optional: Add Aliases

Add to your `~/.bashrc` or `~/.zshrc`:
```bash
# PR creation with review
alias pr-create='~/working/config/scripts/create-pr-with-review.sh'
alias pr-review='~/working/config/scripts/run-pr-agent-review.sh'
```

Then use:
```bash
pr-create        # Create PR with review
pr-review 123    # Review existing PR
```

## Examples

### Example 1: Create a Simple Feature PR

```bash
$ ./scripts/create-pr-with-review.sh
ℹ Current branch: feature/add-user-profile

ℹ Analyzing git history to suggest base branch...
ℹ Suggested base branch: main

? Enter base branch (press Enter for 'main'): [Enter]

ℹ Commits that will be in the PR:
abc123 feat: add user profile page
def456 fix: update navigation

? Title: Add user profile page

? Body:
This PR adds a new user profile page.

Changes:
- New ProfileController
- Profile view and styles
- Navigation link
[Ctrl+D]

⚠ Ready to create PR:
  Base: main
  Head: feature/add-user-profile
  Title: Add user profile page

? Create PR? (y/n) y

✓ PR created: https://github.com/user/repo/pull/123

? Run automated Claude review agents? (y/n) y

ℹ Running Database Performance agent...
✓ Database Performance review saved to: /tmp/claude-pr-review-123/Database Performance-review.md

[... other agents ...]

✓ Review complete!
? Post review summary as PR comment? (y/n) y

✓ Review posted to PR!
✓ Done! 🎉
```

### Example 2: Create PR Based on Another Feature Branch

```bash
$ git checkout -b feature/extend-user-profile

$ ./scripts/create-pr-with-review.sh
ℹ Current branch: feature/extend-user-profile

ℹ Analyzing git history to suggest base branch...
ℹ Found branch with open PR: feature/add-user-profile
ℹ Suggested base branch: feature/add-user-profile

? Enter base branch (press Enter for 'feature/add-user-profile'): [Enter]

# ... rest of flow creates PR based on feature/add-user-profile
```

### Example 3: Review Existing PR with All Agents

```bash
$ ./scripts/run-pr-agent-review.sh 123
✓ PR #123: Add user profile page
ℹ Base: main → Head: feature/add-user-profile
ℹ URL: https://github.com/user/repo/pull/123

ℹ Fetching latest changes...
ℹ Generating diff...

ℹ Running Rails Database Performance agent...
✓ Rails Database Performance review completed

ℹ Running Rails/React Code Review agent...
✓ Rails/React Code Review review completed

ℹ Running Code Quality Review agent...
✓ Code Quality Review review completed

ℹ Running Silent Failure Analysis agent...
✓ Silent Failure Analysis review completed

ℹ Running Test Coverage Analysis agent...
✓ Test Coverage Analysis review completed

✓ Review complete!

ℹ Results saved to: /tmp/claude-pr-review-123
Rails Database Performance-review.md
Rails/React Code Review-review.md
Code Quality Review-review.md
Silent Failure Analysis-review.md
Test Coverage Analysis-review.md

? Post review summary as PR comment? (y/n) y

✓ Review posted to PR!
✓ Done! 🎉
```

### Example 4: List Available Agents

```bash
$ ./scripts/run-pr-agent-review.sh list
Available Claude Review Agents:

  all                  - Run all specialized agents (recommended)

Specialized Agents:
  rails-db            - Rails database performance (N+1, indexes, queries)
  rails-react         - Rails/React code review (conventions, patterns)
  code-quality        - Code quality and style guide adherence
  silent-failures     - Silent error detection (catch blocks, fallbacks)
  code-simplification - Code simplification opportunities
  test-coverage       - Test coverage and quality analysis
  type-design         - Type design review (encapsulation, invariants)
  comments            - Comment accuracy and documentation quality

Generic Agents:
  security            - Security vulnerability scan
  performance         - Performance analysis
```

### Example 5: Run Specific Agent

```bash
$ ./scripts/run-pr-agent-review.sh 123 rails-db
✓ PR #123: Add user profile page
ℹ Base: main → Head: feature/add-user-profile

ℹ Running Rails Database Performance agent...
✓ Rails Database Performance review completed

✓ Review complete!

# Review finds N+1 query in ProfileController
# Suggests adding .includes(:posts) to eager load
```

## Review Output

### Review Files

Each agent creates a markdown file with:
- Summary of findings
- Specific issues with file:line references
- Severity levels (high/medium/low)
- Recommendations for fixes

Example output location:
```
/tmp/claude-pr-review-123/
├── Database Performance-review.md
├── Security-review.md
├── Code Quality-review.md
└── Test Coverage-review.md
```

### PR Comments

If you choose to post to the PR, agents create a collapsible comment:

```markdown
## 🤖 Automated Code Review Results

_Generated by Claude AI agents_

<details>
<summary><strong>Database Performance</strong></summary>

# Database Performance Review

**PR:** https://github.com/user/repo/pull/123
**Base:** main → **Head:** feature/add-user-profile

## Summary
Found 2 potential issues...

[... full review ...]
</details>

[... other agents ...]
```

## Base Branch Detection Logic

The script intelligently suggests base branches by:

1. **Checking for branches with open PRs** that contain your branch's base commit
2. **Looking at branch creation history** (git reflog)
3. **Defaulting to main/master** if no feature branch is detected

This helps create PR stacks where feature B builds on feature A:
```
main
 └─ feature/add-user-profile (PR #123)
     └─ feature/extend-user-profile (PR #124)
```

## Customization

### Add Custom Specialized Agents

Edit `run-pr-agent-review.sh` and add to the `AGENTS` array:

```bash
# Using a specialized subagent
AGENTS[custom]="subagent|your-custom-agent|Custom Review|Using the your-custom-agent agent, analyze for:
- Your custom checks
- Specific patterns
- Domain-specific rules"
```

### Add Custom Direct Agents

For simple prompts without specialized agents:

```bash
# Using direct Claude call
AGENTS[custom]="direct||Custom Analysis|Analyze this PR for:
- Your specific patterns
- Custom requirements
- Domain-specific issues

Provide file:line references for any findings."
```

### Modify Review Prompts

Each agent has a prompt in the `AGENTS` array. Customize to focus on your needs:

```bash
AGENTS[rails-db]="subagent|rails-query-optimizer|Rails DB Performance|Using the rails-query-optimizer agent, check:
- Your team's specific DB patterns
- Custom ActiveRecord usage
- Project-specific performance requirements"
```

## Troubleshooting

### "gh: command not found"
Install GitHub CLI:
```bash
brew install gh
gh auth login
```

### "claude: command not found"
Install Claude Code CLI:
```bash
brew install anthropics/claude/claude
claude auth login
```

### "PR not found"
Ensure you have access to the repository:
```bash
gh auth status
gh repo view
```

### "Unable to generate diff"
The script needs access to both base and head branches:
```bash
git fetch origin
```

### Agent not producing output
Check Claude CLI is working:
```bash
claude --version
echo "test" | claude "analyze this"
```

If Claude CLI works but agents don't, check:
- You're in a git repository
- PR exists and has changes
- You have network access (Claude CLI needs to connect)

## Tips

1. **Run reviews early**: Catch issues before code review
2. **Use specific agents**: Run `db` or `security` only when needed
3. **Keep reviews local**: Don't post every review to PRs
4. **Customize prompts**: Tailor agents to your project's needs
5. **Stack PRs**: Use base branch detection to create feature stacks

## Integration with CI/CD

You can integrate these scripts into your CI/CD pipeline:

```yaml
# .github/workflows/pr-review.yml
name: Automated PR Review
on: pull_request

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      - name: Run Claude review
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          GH_TOKEN: ${{ github.token }}
        run: |
          ./scripts/run-pr-agent-review.sh ${{ github.event.pull_request.number }} all
```
