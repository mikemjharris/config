---
allowed-tools: Bash(git *), Bash(gh *), Read, Grep, Glob, Agent
argument-hint: [base-branch]
description: Analyze branch changes and plan how to split into small commits and multiple focused PRs
---

## Current Git Context
- Branch: !`git branch --show-current`
- Open PRs (all): !`gh pr list --json headRefName,baseRefName,number,title --limit 20 2>/dev/null || echo "[]"`
- Commits vs main: !`git log main..HEAD --oneline 2>/dev/null || echo "No commits ahead of main"`
- Files changed vs main: !`git diff main...HEAD --stat 2>/dev/null || echo "No changes"`
- Total line changes: !`git diff main...HEAD --shortstat 2>/dev/null || echo "No changes"`

## Split PR Analysis Command

Your task is to analyze the current branch and produce a detailed plan for splitting the work into small, focused, independently mergeable pull requests with clean commit histories.

**Arguments**:
- $1 (optional): Base branch to compare against (default: `main`)

### Step 1: Determine Base Branch

First, intelligently determine what branch this work should be compared against:

1. **If user provided `$1`**: Use that as the base branch
2. **Otherwise, try to auto-detect a parent branch**:
   - Get current branch: `git branch --show-current`
   - List local branches: `git branch --format='%(refname:short)'`
   - Check for open PRs: `gh pr list --json headRefName,baseRefName,number,title`

   **Auto-detection logic**:
   - Find branches (other than current and main) that have open PRs
   - Check if the current branch was likely created from any of them using:
     - `git merge-base --is-ancestor <candidate-branch> HEAD` - does this branch contain the candidate's commits?
     - `git log --oneline <candidate-branch>..HEAD` - how many commits diverge?
   - If a parent branch with an open PR is found, use that as the base
   - Common pattern: If current branch is `feat/foo-part2` and `feat/foo` has a PR, use `feat/foo`
   - If multiple candidates match, pick the one with the fewest diverging commits (closest ancestor)

3. **Fallback**: Use `main` as the base branch

Set **BASE_BRANCH** to the determined branch and **inform the user which base was chosen and why**. If a parent branch was detected, note:
- The parent branch name and its PR number
- How many commits are on the current branch vs that parent
- This is important because the split plan should only cover changes NOT already in the parent PR

### Step 2: Gather Full Context

Run these commands to understand all changes:

```bash
# All commits on this branch
git log <BASE_BRANCH>..HEAD --oneline --reverse

# Full file change summary
git diff <BASE_BRANCH>...HEAD --stat

# Line count summary
git diff <BASE_BRANCH>...HEAD --shortstat

# Full diff for detailed analysis
git diff <BASE_BRANCH>...HEAD
```

Also check for any migration/schema files:
```bash
git diff <BASE_BRANCH>...HEAD --name-only | grep -E "db/migrate|migrations|schema"
```

And check for test files:
```bash
git diff <BASE_BRANCH>...HEAD --name-only | grep -E "(spec/|test/|__tests__/|\.test\.|\.spec\.)"
```

### Step 3: Launch PR Splitter Agent

Use the Agent tool to launch the `pr-splitter` agent with subagent_type set appropriately. Pass all the context gathered above to the agent for analysis.

The agent will:
1. Categorize every changed file by layer (schema, data, API, frontend, etc.)
2. Identify natural PR boundaries
3. Plan small commits within each PR
4. Produce a detailed implementation plan with exact git commands
5. Verify each PR is independently deployable

### Step 4: Present Results

After the agent completes, present the results to the user with:

1. **Summary**: How many PRs are recommended and why
2. **PR dependency chain**: Visual showing the order
3. **For each PR**: Title, files, commits, and justification
4. **Implementation plan**: Step-by-step commands to restructure

### Important Notes

- This command is for **analysis and planning only** - it does NOT restructure commits or create PRs
- The user should review the plan before taking any action
- If the branch is already small enough for one PR, say so - don't force unnecessary splits
- Always recommend creating a backup branch before any restructuring
- Consider existing open PRs when suggesting the split (avoid conflicts with in-progress work)
