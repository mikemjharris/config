---
allowed-tools: Bash(mj-followups list*), Bash(mj-followups run *), Bash(mj-followups done *), Read
argument-hint: "[all | run <number> | done <number>]"
description: List your local follow-ups with numbers, and run or close one by its number
---

## Follow-ups

List the follow-ups saved on this box, numbered, and run or close one by its
number. `/mj-follow-up` (singular) creates them.

User input: `$ARGUMENTS`

If `command -v mj-followups` finds nothing, tell the user to run
`~/working/config/ai/setup.sh`.

### List (no input, `list` or `all`)

```bash
mj-followups list          # add --all for `all`: done ones too
```

Show the table exactly as printed, in a code block, then one line: "Run one
with `/mj-follow-ups run <number>`."

### Run (`run <number>`)

```bash
mj-followups run <number>
```

The numbers come from the last list, saved for 12 hours. If it says there's
no recent list or no such number, run `mj-followups list`, show the table, and
ask which one they meant. Don't guess.

A headless run takes up to 15 minutes, so run it in the background and say so.
When it finishes, give the user its `SUMMARY:` or `NEEDS_YOU:` lines and the
result file's path. On `needs_you`, offer to open it interactively with
`mj-followups run <number> --interactive`. An interactive one opens a tmux
window: say which.

A reminder-only follow-up has nothing to run: read its `followup.json` and
give the user the summary and the "What to check next time" list.

### Done (`done <number>`)

```bash
mj-followups done <number>
```
