# Every project has a baseline: CLAUDE.md, CI, linting and formatting

When creating a new project or repository, set these up as part of creating it, not later:

1. **A CLAUDE.md**: what the project is, how the pieces fit, how to run, test, lint and format it, its
   conventions, and anything that must stay out of git. Add folder-level CLAUDE.md files for distinct areas.
2. **CI** that runs on every pull request and on the main branch: install, lint, format check, tests (and the
   build, if there is one). Deploy only after those pass.
3. **Linting and formatting** with the standard tools for the stack, a command to run each, and the format
   check in CI.

Use the `mj-project-baseline` skill for the tools to pick per technology and how to add them to a repo that
already has code. When working in an existing repo that is missing any of the three, mention it once and
offer to add it; don't add it unasked in the middle of other work.
