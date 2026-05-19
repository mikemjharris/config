# PR Review Scripts - Quick Start

🎉 **Updated to use local Claude CLI with specialized agents!**

## What Changed

✅ **No API key needed** - Uses your local `claude` command
✅ **Specialized agents** - Leverages Claude's Task system with expert agents
✅ **10 review types** - From Rails DB performance to security scans

## Quick Commands

```bash
# Create PR with smart base detection + optional review
pr-create

# Review an existing PR with all agents
pr-review 123

# Review with specific agent
pr-review 123 rails-db

# List all available agents
pr-review list
```

## Available Specialized Agents

### 🚄 Rails/Web Specific
- **rails-db** - N+1 queries, missing indexes, ActiveRecord optimization
- **rails-react** - Rails conventions, React patterns, code organization

### 🔍 Code Quality
- **code-quality** - Style guide adherence, code smells, best practices
- **silent-failures** - Catch blocks that hide errors, poor error handling
- **code-simplification** - Overly complex code, refactoring opportunities
- **type-design** - Type safety, encapsulation, invariants

### 🧪 Testing & Documentation
- **test-coverage** - Missing tests, edge cases, test quality
- **comments** - Comment accuracy, documentation completeness

### 🔒 Security & Performance
- **security** - SQL injection, XSS, auth issues, data exposure
- **performance** - Inefficient algorithms, memory issues, slow operations

## How It Works

### 1. Create PR (`pr-create`)

```bash
$ pr-create

ℹ Current branch: feature/user-dashboard
ℹ Analyzing git history...
ℹ Found branch with open PR: feature/user-auth
ℹ Suggested base branch: feature/user-auth

? Enter base branch (press Enter for 'feature/user-auth'): [Enter]

? Title: Add user dashboard with activity feed

? Body:
Builds on user-auth feature to add:
- Dashboard view
- Activity feed component
- User stats widget
[Ctrl+D]

✓ PR created: https://github.com/org/repo/pull/124

? Run automated Claude review agents? (y/n) y

[Agents run...]

✓ Done! 🎉
```

**Smart Features:**
- Detects if you should base on another feature branch
- Creates PR stacks (feature B on feature A)
- Shows commit preview before creating
- Optionally runs full review suite

### 2. Review Existing PR (`pr-review`)

```bash
$ pr-review 123

✓ PR #123: Add user profile page
ℹ Base: main → Head: feature/add-user-profile

ℹ Running Rails Database Performance agent...
  → Found N+1 query in ProfileController#show
  → Suggest: User.includes(:posts).find(params[:id])

ℹ Running Silent Failure Analysis agent...
  → Warning: rescue block on line 45 swallows errors
  → Suggest: Log error or re-raise

ℹ Running Test Coverage Analysis agent...
  → Missing edge case: user with no posts
  → Suggest: Add test for empty state

✓ Review complete!

? Post review summary as PR comment? (y/n) y

✓ Review posted to PR!
```

## Setup (One-Time)

```bash
# 1. GitHub CLI (if not installed)
brew install gh
gh auth login

# 2. Claude Code CLI (if not installed)
brew install anthropics/claude/claude
claude auth login

# 3. Source aliases (if not already in your shell)
source ~/.bash_aliases
```

## Example Workflows

### Workflow 1: Feature on Feature Branch

```bash
# Working on auth feature
git checkout -b feature/user-auth
# ... make changes ...
pr-create  # Creates PR: main <- feature/user-auth

# Now add profile feature on top
git checkout -b feature/user-profile
# ... make changes ...
pr-create  # Detects and suggests: feature/user-auth <- feature/user-profile
```

Result: PR stack where profile builds on auth!

### Workflow 2: Quick Security Check

```bash
# Before requesting review, check security
pr-review 123 security

# Review finds potential issues
# Fix them, push, then ask for human review
```

### Workflow 3: Pre-merge Checks

```bash
# Run all specialized agents before merging
pr-review 123

# Address any issues found
# Re-run specific agents to verify fixes
pr-review 123 rails-db
pr-review 123 test-coverage
```

## Agent Details

### Rails DB Performance (`rails-db`)
Uses: `rails-query-optimizer` agent
Checks:
- N+1 queries from missing `includes`/`joins`
- Missing database indexes
- Inefficient queries (Ruby filtering vs SQL)
- Large data loads without pagination
- Suboptimal ActiveRecord usage

### Rails/React Review (`rails-react`)
Uses: `rails-react-code-reviewer` agent
Checks:
- Rails conventions (models, controllers, views)
- React component patterns
- Code organization
- Project-specific patterns from CLAUDE.md

### Code Quality (`code-quality`)
Uses: `code-reviewer` agent from pr-review-toolkit
Checks:
- Style guide violations
- Code complexity
- Naming conventions
- Duplicate code
- Best practice adherence

### Silent Failures (`silent-failures`)
Uses: `silent-failure-hunter` agent
Checks:
- Rescue blocks that swallow errors
- Empty catch blocks
- Missing error logging
- Inappropriate fallback behavior
- Silent error suppression

### Test Coverage (`test-coverage`)
Uses: `pr-test-analyzer` agent
Checks:
- New features without tests
- Missing edge cases
- Test quality (tests that pass when broken)
- Permission tests
- Integration test coverage

## Tips & Tricks

### 1. Run Specific Agents During Development
```bash
# Just added DB code? Check DB performance
pr-review 123 rails-db

# Just added tests? Check coverage
pr-review 123 test-coverage
```

### 2. Don't Post Every Review to PR
- Review locally first
- Fix issues
- Only post final summary to PR

### 3. Create PR Stacks
- Use base branch detection for dependent features
- Easier to review small PRs
- Can merge incrementally

### 4. Customize Agents
Edit `scripts/run-pr-agent-review.sh` to add custom agents:
```bash
AGENTS[custom]="subagent|your-agent|Custom Check|..."
```

## Files Created

```
scripts/
├── create-pr-with-review.sh      # Interactive PR creation
├── run-pr-agent-review.sh        # Run review agents
├── README-PR-REVIEW.md           # Full documentation
└── PR-REVIEW-QUICK-START.md      # This file

conf/
└── .bash_aliases                 # Updated with pr-create/pr-review
```

## Need Help?

```bash
# List available agents
pr-review list

# Read full docs
cat scripts/README-PR-REVIEW.md

# Test Claude CLI
echo "test" | claude "analyze this"
```

## Advanced: CI/CD Integration

Add to `.github/workflows/pr-review.yml`:

```yaml
name: Automated PR Review
on: pull_request

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Install Claude CLI
        run: |
          # Install Claude CLI
          # (Claude CLI installation commands)

      - name: Run Reviews
        env:
          GH_TOKEN: ${{ github.token }}
        run: |
          ./scripts/run-pr-agent-review.sh ${{ github.event.pull_request.number }} all
```

## What's Next?

Try it out:
```bash
# On any branch
pr-create

# Or review an existing PR
pr-review <pr-number>
```

Happy reviewing! 🚀
