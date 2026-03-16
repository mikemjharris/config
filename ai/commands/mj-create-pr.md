---
allowed-tools: Bash(git *), Bash(gh *)
argument-hint: [optional-custom-title] [base-branch]
description: Create a PR with auto-formatted title and description; auto-detects parent branch with open PR
---

## Current Git Context
- Branch: !`git branch --show-current`
- Local branches: !`git branch --format='%(refname:short)'`
- Open PRs: !`gh pr list --json headRefName,baseRefName,number,title 2>/dev/null || echo "[]"`
- Recent commits vs main: !`git log main..HEAD --oneline 2>/dev/null || echo "No commits"`
- Diff summary: !`git diff main...HEAD --stat 2>/dev/null || echo "No changes"`

## Create Pull Request Command

Your task is to create a pull request using the GitHub CLI with an auto-generated title and description.

**Arguments**:
- $1 (optional): Custom PR title (if not provided, auto-generate from branch name)
- $2 (optional): Base branch name (if not provided, auto-detect or use main)

### Step 1: Determine Base Branch

First, intelligently determine what branch this PR should be based on:

1. **If user provided base branch as $2**: Use that branch
2. **Otherwise, try to auto-detect parent branch**:
   - Get current branch: `git branch --show-current`
   - List local branches: `git branch --format='%(refname:short)'`
   - Check for open PRs: `gh pr list --json headRefName,baseRefName,number,title`

   **Auto-detection logic**:
   - Find branches (other than current and main) that have open PRs
   - Check if the current branch was likely created from any of them using:
     - `git merge-base --is-ancestor <candidate-branch> HEAD`
     - Look at recent branch activity in reflog
   - If a parent branch with an open PR is found, use that as base
   - Common pattern: If current branch is `feat/foo-part2` and `feat/foo` has a PR, use `feat/foo`

3. **Fallback**: Use `main` as the base branch

**Set BASE_BRANCH** to the determined branch and inform the user which base was chosen.

### Step 2: Gather Git Context

Run these commands to understand the changes against the base branch (where BASE_BRANCH is the branch determined in Step 1):

- Recent commits on this branch: `git log <BASE_BRANCH>..HEAD --oneline`
- Summary of changes: `git diff <BASE_BRANCH>...HEAD --stat`
- Full diff: `git diff <BASE_BRANCH>...HEAD`

### Step 3: Generate PR Title

Create a clear, descriptive title:

1. Get the current branch name: `git branch --show-current`
2. Format it nicely:
   - Remove common prefixes (`feat/`, `fix/`, `refactor/`, `docs/`, `test/`, `chore/`)
   - Replace hyphens and underscores with spaces
   - Capitalize appropriately
   - Add back the prefix if meaningful (e.g., "feat:", "fix:")

Examples:
- `feat/array-cops` → "feat: Array Cops"
- `fix/validation-bug` → "fix: Validation Bug"
- `update-dependencies` → "Update Dependencies"

**If the user provided a custom title as an argument ($1), use that instead.**

### Step 4: Generate PR Description

Analyze the git diff and commits to create a concise description:

1. **Dependency Warning** (if base is not main):
   ```
   ⚠️ **Depends on**: #<parent-pr-number>
   This PR should be merged after the parent PR is merged.

   ```

2. **Summary**: Write 1-2 sentences describing the overall change

3. **Key Changes**: List the main changes as bullet points (3-5 items)

4. **Technical Details**: Mention any important technical decisions if relevant

Format:
```
[If based on non-main branch, include dependency warning]

[Brief summary of what this PR accomplishes]

## Changes
- Key change 1
- Key change 2
- Key change 3

## Technical Notes
[Any important context about the implementation]
```

Keep it concise but informative - focus on *why* and *what*, not just listing files changed.

### Step 5: Create the Pull Request

Use the GitHub CLI to create the PR as a **draft** (so you can review before marking ready):

```bash
gh pr create --title "<GENERATED_TITLE>" --body "<GENERATED_DESCRIPTION>" --base "<BASE_BRANCH>" --draft
```

**Important**:
- Always create as `--draft` initially
- Use the determined base branch from Step 1
- If base is NOT main, add a note in the PR description: "⚠️ This PR is based on #<parent-pr-number> and should be merged after that PR"
- After creating, output the PR URL

### Step 6: Confirm Success

After creating the PR:
1. Display the PR URL prominently
2. Show which base branch was used (especially if not main)
3. Summarize what title and description were used
4. If based on another branch with a PR, remind the user about the dependency
5. Remind the user it's a draft and they can mark it ready when satisfied

### Error Handling

If there are any issues:
- No commits to push → let the user know they need to commit first
- Not on a feature branch → warn them
- `gh` not installed → provide installation instructions
- No changes vs the base branch → explain there's nothing to create a PR for
- Base branch doesn't exist → fall back to main and notify user

### Notes

- This command expects you're on a feature branch (not main)
- It intelligently detects if you've branched from another feature branch with an open PR
- For stacked PRs (branched from non-main), it creates the PR against the parent branch
- All changes should be committed before running this
- The PR is created as a draft for safety

### Usage Examples

```bash
# Auto-detect base branch (will use parent branch with PR if found, else main)
/mj-create-pr

# Auto-detect base branch with custom title
/mj-create-pr "Add new feature"

# Explicitly specify base branch
/mj-create-pr "" feat/parent-branch

# Custom title and explicit base branch
/mj-create-pr "My Custom Title" feat/parent-branch
```
