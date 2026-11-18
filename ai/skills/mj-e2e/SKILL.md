---
name: mj-e2e
description: End-to-end walkthrough of a branch - draft a test manifest from the PR diff, run it in a browser in a separate Remote Control session, screenshot each step (before/after if asked), review the shots against the PR, and publish an HTML walkthrough. Use for /mj-e2e plan|run|execute|rerun, or when asked to e2e-test a branch or make a walkthrough of a PR.
argument-hint: "plan [base] | run [manifest] | execute <manifest> | rerun [manifest]"
---

# mj-e2e: test a branch end to end, publish a walkthrough

Argument: `$ARGUMENTS` (empty means `plan`). Skill folder: `${CLAUDE_SKILL_DIR}` (scripts in `scripts/`,
the manifest template in `templates/`). Requires Node 24+ and Google Chrome; `scripts/` needs its npm
packages (`npm install --prefix ${CLAUDE_SKILL_DIR}` once; `ai/setup.sh` does it).

The pieces, all in the app's repo:
- `e2e/<feature>/manifest.yaml`: what changed, how to set up and seed, before/after or not, and the
  steps. Committed with the branch, reviewed like code. Template: `templates/manifest.example.yaml`.
- `e2e/<feature>/walkthrough.mjs`: the steps as a Playwright script, written by the first run and reused
  by reruns. Committed too.
- `.e2e/` (git-ignored): worktrees, logs and each run's output, `.e2e/runs/<run>/`.

`<feature>` is the branch name made into a slug (lowercase, `[a-z0-9-]`). `<run>` is the start time,
`YYYYMMDD-HHMMSS`.

## Rules
- **Seeded test data only.** Never point a run at production or at anyone's real data. Local servers get a
  fresh data dir under `.e2e/`, filled by the manifest's seed step. If the app can only be tested against
  real data, stop and say so.
- **Don't change the app's code** while running. Fix the walkthrough script, not the app. If the feature is
  broken, that's the finding: screenshot it, mark the step failed, carry on to the report.
- Leave the user's checkout alone: the branch and base run in worktrees under `.e2e/worktrees/`.
- Commit only `e2e/<feature>/` files, and only in `plan` or after `execute` writes `walkthrough.mjs`.

## plan [base]
Run in the app's repo, on the feature branch.
1. Base: the argument, else the PR's base (`gh pr view --json baseRefName,title,body,url`), else `main`.
2. Read what changed: `git diff <base>...HEAD`, `git log <base>..HEAD`, the PR title and body.
   Read enough of the app (README, how to start it, how data is seeded) to fill in `setup`.
3. Write `e2e/<feature>/manifest.yaml` from the template:
   - `summary`: 2-3 plain sentences on what the PR does for a user.
   - `changed`: the files or areas that changed, one line each, user-visible ones first.
   - `setup`: start command, port, readiness path, env, and seed commands that create everything the
     steps need (no reliance on existing data). Add a small seed script to the app (`e2e/seed.*`) if
     there's no way to seed yet, and say so.
   - `compare: true` when the change alters something that already existed (a layout, a flow, a
     calculation), so before/after is worth seeing; `false` for something wholly new.
   - 4-8 `steps`, in the order a person would click through: `do` (what to do, in words) and `expect`
     (what the screenshot should show, specific enough to check). Cover the main path first, then one
     or two edge cases the diff suggests.
4. Show the manifest and ask the user to OK or change it. Commit it (`e2e: walkthrough manifest for
   <feature>`) once agreed; don't push unless asked.

## run [manifest]
Starts the run in its own Remote Control session, so it can be watched from the Claude app.
1. Manifest: the argument, else `e2e/<feature>/manifest.yaml` for the current branch. It must exist
   (run `plan` first).
2. `${CLAUDE_SKILL_DIR}/scripts/launch.sh <manifest>`. It opens a tmux window running
   `claude --remote-control` in this repo with `/mj-e2e execute <manifest>`, and prints the tmux target.
3. Tell the user it's running, where to watch (the Claude app, or `tmux attach -t e2e`), and that the
   link to the walkthrough comes by Telegram (`tg-send`) when it's done.

## execute <manifest>
What the launched session does. Work through it without asking; report at the end.
1. `run=$(date +%Y%m%d-%H%M%S)`; `out=.e2e/runs/$run`; make it. Read the manifest.
2. **Worktrees**: `git worktree add --detach .e2e/worktrees/after <branch>`, and if `compare`,
   `.e2e/worktrees/before <base>`. Remove stale ones first (`git worktree remove --force`).
   Install dependencies in each the way the repo does (`npm ci`, `bundle install`, ...).
3. **Start and seed** each side per `setup`: after on `port`, before on `port + 1`, each with its own
   fresh data dir under `.e2e/`. Run in the background with logs in `$out/<side>-server.log`; poll
   `ready` until it answers (give up after 60 s and report the log). Run the seed commands against each.
4. **Script**: if `e2e/<feature>/walkthrough.mjs` exists, use it. Otherwise write it from the steps,
   using `templates/walkthrough.example.mjs` as the pattern: one `step(id, title, fn)` per manifest
   step, same ids, prefer role/text locators over CSS.
5. **Run** `node ${CLAUDE_SKILL_DIR}/scripts/run.mjs --script e2e/<feature>/walkthrough.mjs
   --base http://127.0.0.1:<port> --label after --out $out [--viewport phone|desktop]`, and the same
   with `--label before` on the before port if comparing. It writes `$out/<label>.json` and
   `$out/<label>-NN-<id>.png`. If a step fails because the *script* is wrong (bad locator, timing),
   fix the script and run again (up to 3 tries). If the *app* is wrong, keep the failure.
   The before side may lack the feature entirely; failures there are expected, not script bugs.
6. **Review**: look at every screenshot (Read them). For each step compare it with `expect` and with
   the PR summary; give `pass`, `unsure` or `fail` and one line why. Then an overall verdict and 2-4
   sentences: does the walkthrough show the PR doing what it says? Anything odd in the shots (layout,
   errors, empty states) goes in `issues`.
7. Write `$out/run.json` (see "run.json" below), then
   `node ${CLAUDE_SKILL_DIR}/scripts/report.mjs $out` to build `$out/index.html`.
8. **Publish** to the personal site: `node ${CLAUDE_SKILL_DIR}/scripts/publish.mjs $out` uploads the
   run to `/e2e/<app>/<feature>/<run>/` and prints the URL (the site's address: `E2E_API_URL` in
   `~/.config/mj-e2e.env`, else `PAPI_URL` in `~/.config/personal-site.env`). If the upload fails, don't
   change the site or its config: publish the run as a private claude.ai page instead (Artifact tool,
   `$out/index.html` with its PNGs as `files`, `root` = `$out`), and say why the site upload failed in
   the reply and the message. Then `tg-send "🧪 <title>: <verdict>. <url>"` if `tg-send` exists.
9. **Tidy**: stop the servers, remove the worktrees. If `walkthrough.mjs` is new or changed, commit it
   (`e2e: walkthrough script for <feature>`), not pushed.
10. Reply with the verdict, the URL, and any issues.

## rerun [manifest]
Same as `run`, but `execute` must reuse `walkthrough.mjs` as it is and only fix it if a step fails on
a locator. Use after new commits on the branch, to refresh the walkthrough.

## run.json
Written by `execute`, read by `report.mjs` and by the site's index:
```json
{
  "app": "health", "feature": "recipes", "run": "20261117-120000",
  "title": "Save and rate recipes", "branch": "recipes", "base": "main", "commit": "abc1234",
  "pr": "https://github.com/owner/repo/pull/12",
  "summary": "…", "changed": ["…"], "compare": true, "viewport": "phone",
  "steps": [{ "id": "open-recipes", "title": "…", "do": "…", "expect": "…",
              "verdict": "pass", "note": "Shows the seeded recipe with 4 stars." }],
  "review": { "verdict": "pass", "summary": "…", "issues": [] }
}
```
`report.mjs` takes the screenshots, errors and timings from `after.json` / `before.json`.
