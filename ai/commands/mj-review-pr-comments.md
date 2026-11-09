---
allowed-tools: Bash(gh *), Read, Grep, Glob, Agent
description: Fetch PR comments and reviews, then create a plan to address the feedback
---

## Current PR Context
!`gh pr view --json number,title,body,url,reviews,comments,reviewRequests 2>/dev/null || echo "No PR found for current branch"`

Use the Agent tool to launch the `mj-review-pr-comments` agent to fetch and analyze all PR comments and reviews for the current branch.
