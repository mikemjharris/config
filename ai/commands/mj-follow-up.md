---
allowed-tools: Bash(mj-followups *), Bash(mkdir -p ~/.mj-followups/*), Read, Write, AskUserQuestion
argument-hint: [optional-title]
description: Save a dated re-check of this investigation as a local follow-up
---

## Follow up

Turn the investigation in this conversation into a **follow-up**: a dated
re-check ("run this query again next week and compare") saved on this box under
`~/.mj-followups/`. Nothing leaves the box and nothing runs on its own;
`/mj-follow-ups` lists them and runs one when asked.

If `command -v mj-followups` finds nothing, tell the user to run
`~/working/config/ai/setup.sh`, which links it into `~/.local/bin`.

### Step 1: Settle the details, asking as little as possible

Work everything out from the request and the conversation. Ask only when a
choice is genuinely open, and then put every open question in **one**
AskUserQuestion call. Tell the user what you settled on when you show it.

1. **Title**: what to re-check, at most 120 characters, no trailing
   punctuation. `$1` if given, otherwise written from the conversation.
2. **Due**: the time the user asked for, in this box's local time, as ISO 8601
   with its offset. When they didn't name one, use `mj-followups next-monday`
   (09:00 next Monday). "Tomorrow" is 09:00 tomorrow; a bare date is 09:00
   that day.
3. **Runs or reminder**: give it a `run` when the analysis can be repeated by a
   fresh Claude from a prompt and scripts. Leave `run` out when the re-check
   needs a person (a judgement call, a conversation); it's then a reminder.
4. **Mode**: `headless` (`claude -p`, 15-minute limit, result saved to
   `runs/`) unless the run will likely need the user (an SSO login, a judgement
   call); then `interactive`, which opens a tmux window.

### Step 2: Write it

Write it yourself, for someone who wasn't in the conversation. **Never paste
the transcript or raw tool output** (logs, query dumps, stack traces).

The folder is `~/.mj-followups/<due date, YYYY-MM-DD>-<slug>/`, the slug being
the title in lowercase words joined by `-`, at most 40 characters. If that
folder exists, add `-2`, `-3`, and so on.

`followup.json`:

```json
{
  "title": "Re-check assess page speed after the resize",
  "due_at": "2026-11-16T09:00:00+00:00",
  "summary": "## What happened\n...\n\n## What to check next time\n1. ...",
  "baseline": "| page | p75 s | loads |\n|---|---|---|\n| Admin assessment show | 2.63 | 412 |",
  "links": [{ "label": "PR #123", "url": "https://github.com/..." }],
  "run": {
    "prompt": "Run scripts/page_speed.py and compare with the baseline ...",
    "mode": "headless",
    "workdir": "~/dev/app/assessor-rails",
    "allowed_tools": ["Bash(sentry-query speed *)"]
  }
}
```

- **summary** (markdown): what was investigated, what was found, what changed
  (PRs, deploys, with dates), and a numbered "What to check next time" list.
- **baseline** (optional, markdown): the numbers to compare against, from
  numbers already in the conversation. Don't run new queries to fill it.
- **links** (optional): PRs, tickets, dashboards, the session URL if known.
- **run.prompt**: restates the analysis for a fresh Claude with no context:
  what to run, against what, over which period, and how to lay the result out
  beside the baseline.
- **run.workdir** (optional): a repo checkout the prompt needs. Left out, it
  runs in the follow-up's own folder.
- **run.allowed_tools** (optional): anything beyond the folder's own
  `scripts/`, which a headless run may always run. Each rule names an exact
  command, e.g. `Bash(sentry-query speed *)` or `Bash(bin/rails runner
  /Users/<you>/.mj-followups/<dir>/scripts/bloat.rb)` (full paths, no `~`). `mj-followups` refuses bare `Bash`, `Edit`, `Write`,
  `WebFetch`, `Agent` and the like, a program with any arguments
  (`Bash(curl *)`), `env`, `xargs`, `sudo`, `bash -c` and `python3 -c`.

Write each script the analysis used to `scripts/<name>` beside it, reading the
original file rather than retyping it. Leave out any key with nothing in it.

### Step 3: Check and show it

For one with a `run`:

```bash
mj-followups check ~/.mj-followups/<dir>
mj-followups run <dir> --dry-run
```

On a `FIX` line, narrow the rule or fix the field and check again.

Show the user the folder path, the title, the due time, and for a `run` the
prompt in full, the mode, where it runs, and every allowed tool rule. Say
plainly that a headless run can use those rules without asking. Then stop:
the follow-up is saved. Mention `mj-followups done <dir>` to drop it and
`/mj-follow-ups` to list or run it.
