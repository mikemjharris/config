---
allowed-tools: Bash(gh *), Bash(git *), Read, Grep, Glob, Agent
description: Run full PR review workflow - fetch comments and review code quality
---

## PR Context
!`gh pr view --json number,title,body,url,reviews,comments,reviewRequests 2>/dev/null || echo "No PR found"`

## Branch Changes
!`git diff --name-only main...HEAD 2>/dev/null || echo "No changes found"`

## Recent Commits
!`git log main..HEAD --oneline 2>/dev/null || echo "No commits"`

Run a comprehensive PR review by launching these agents in sequence:

## Step 1: Gather PR Feedback

Use the Agent tool to launch the `mj-review-pr-comments` agent. This will:
- Fetch all PR comments and reviews using `gh` CLI
- Fetch inline code review comments
- Analyze and categorize the feedback
- Create a prioritized list of issues to address

Wait for this agent to complete and capture its findings.

## Step 2: Review Code Quality

Use the Agent tool to launch the `mj-code-reviewer` agent. This will:
- Review all changes on the current branch vs main
- Check conventions and patterns
- Verify best practices
- Identify security and performance issues
- Compare against CLAUDE.md patterns

Wait for this agent to complete and capture its findings.

## Step 3: Synthesize Findings

Combine the results from both agents into a single action plan:

### PR Feedback Items
[List items from mj-review-pr-comments agent]

### Code Quality Items
[List items from mj-code-reviewer agent]

### Combined Priority Order
Create a single prioritized list that merges both sources:
1. Critical issues (security, correctness, blocking PR feedback)
2. Important items (reviewer requests, convention violations)
3. Suggestions (nice-to-haves from both sources)

### Recommended Approach
Suggest an order for addressing the items, noting any dependencies between them.

Ask the user if they want to start implementing the fixes.
