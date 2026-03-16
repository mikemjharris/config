---
allowed-tools: Bash(git *), Read, Grep, Glob, Agent
description: Analyze code for N+1 queries, inefficient data access, and performance issues
argument-hint: [file-path-or-pattern]
---

## Changed Files on Branch
!`git diff --name-only main...HEAD 2>/dev/null || echo "No branch changes found"`

## Unstaged Changes
!`git diff --name-only 2>/dev/null`

## Staged Changes
!`git diff --cached --name-only 2>/dev/null`

## Performance Analysis Command

Analyze code for performance issues, particularly N+1 queries, missing eager loading, inefficient data access, and other bottlenecks.

**Arguments**:
- $1 (optional): Specific file, directory, or pattern to analyze

### Step 1: Determine Scope

Figure out what code to analyze:

1. **If user provided a specific path as $1**: Focus analysis on that file or pattern
   - Single file: Analyze just that file
   - Directory: Analyze all relevant files in that directory
   - Pattern: Use the pattern to find matching files

2. **If no argument provided**: Analyze recent changes
   - Get unstaged changes: `git diff --name-only`
   - Get staged changes: `git diff --cached --name-only`
   - Get committed changes on current branch: `git diff --name-only main...HEAD`
   - Filter for relevant files (controllers, models, services, data access layers, views)
   - If no changes found, ask the user what they want to analyze

3. **Inform the user** about what scope was determined

### Step 2: Launch Performance Analysis

Use the Task tool to launch the `performance-analyzer` agent with a clear prompt:

```
Analyze the following files for performance issues, focusing on N+1 queries, missing eager loading, and inefficient data access patterns:

[List the files determined from Step 1]

For each file:
1. Identify all database queries and data access patterns
2. Check for missing eager loading / batch loading
3. Trace data access through to views/output
4. Detect N+1 query patterns
5. Provide specific fixes with verification steps
```

**Important**:
- Include the full file paths in the prompt
- Mention if specific areas should be prioritized
- Request analysis of the complete flow from entry point through output
- Ask for verification steps

### Step 3: Review Findings

After the agent completes:
1. Summarize the key findings (number of critical/important/minor issues)
2. Highlight the most impactful fixes
3. Estimate overall performance improvement
4. Ask the user if they want to implement the recommended fixes

### Usage Examples

```bash
# Analyze recent changes on current branch
/mj-analyze-performance

# Analyze a specific file
/mj-analyze-performance app/controllers/users_controller.rb

# Analyze all files in a directory
/mj-analyze-performance app/controllers

# Analyze a specific area
/mj-analyze-performance src/services/
```

### When to Use This Command

Use this command when:
- You've just implemented a feature that loads data and renders output
- Performance issues are reported (slow loads, high query counts)
- Monitoring shows high query counts or slow responses
- You want to proactively check code before merging
- Refactoring code that involves data access patterns
- Before creating a PR with data access changes
