---
name: mj-project-baseline
description: Make sure a project has the baseline every repo should have - a CLAUDE.md, CI on pull requests and main, and linting and formatting with the standard tools for its stack - and add whatever is missing. Use when creating a new project or repository, when asked to set up or check a project's CI, linting, formatting or CLAUDE.md, or for /mj-project-baseline.
argument-hint: "[check]"
---

# mj-project-baseline: CLAUDE.md, CI, linting and formatting

Argument: `$ARGUMENTS`. `check` only reports what's there and what's missing; otherwise add what's missing.

## 1. Look first
- Work out the stack from the files: `package.json`, `pyproject.toml`/`requirements.txt`, `Gemfile`, `go.mod`,
  `Cargo.toml`, `*.tf`, shell scripts, Dockerfile. A repo can have several; cover each part.
- Find what exists already: `CLAUDE.md` (root and folders), `.github/workflows/` (or other CI), linter and
  formatter configs, and the scripts that run them. Extend what's there rather than adding a second tool for
  the same job (for example, keep Standard if the repo uses it rather than adding RuboCop).
- Report in a short table, per item: there / partly / missing. For `check`, stop here.

## 2. CLAUDE.md
At the root, short (aim for under ~100 lines; it's loaded every session):
- What the project is and who uses it, in two or three lines.
- How the pieces fit: the main folders, what runs where, where data lives.
- Commands: install, run locally, test, lint, format. Exact commands that work.
- Conventions a newcomer would get wrong, and anything that must never go in git (secrets, personal data).
- Where decisions or design notes live, if anywhere.
Add a `CLAUDE.md` in a folder only when that area has its own rules (an API server, a frontend, a jobs folder).
Describe what the code does now, checked against the code; don't copy the README wholesale.

## 3. Linting and formatting
Recommended rules only: catch real mistakes, don't argue style (that's the formatter's job). Defaults:

| Stack | Lint | Format |
|---|---|---|
| JavaScript | ESLint, flat config, `@eslint/js` recommended + `globals` | Prettier |
| TypeScript | ESLint + `typescript-eslint` recommended, and `tsc --noEmit` | Prettier |
| Python | Ruff (`ruff check`) | Ruff (`ruff format`) |
| Ruby | RuboCop (plus `rubocop-rails`/`rubocop-rspec` where used) | RuboCop (`-a`) |
| Go | `go vet` + golangci-lint (or staticcheck) | gofmt |
| Rust | `cargo clippy -- -D warnings` | rustfmt (`cargo fmt --check`) |
| Shell | ShellCheck | shfmt |
| Terraform | `terraform validate` + TFLint | `terraform fmt -check -recursive` |
| CSS/HTML/JSON/YAML | (none needed) | Prettier, if there's Node in the repo |

- Add a command for each: `lint`, `format` (writes) and `format:check` (CI) as npm scripts, a Makefile or
  `bin/` scripts, whatever the repo already uses. Pin the tool versions (lockfile, `pyproject`, `Gemfile.lock`).
- Leave hand-wrapped docs (Markdown) out of the formatter unless the repo already formats them.
- Pin the runtime version in a file CI reads (`.nvmrc`, `.python-version`, `.ruby-version`, `.tool-versions`).

### Adding them to code that already exists
1. Config and lint fixes first, in one commit. Fix what the linter finds; if something is deliberate, disable
   that rule on that line with a reason. Don't switch rules off wholesale to get to green.
2. The reformat in its own commit with no other changes ("Format everything with <tool> (no code changes)").
   Then add its hash to `.git-blame-ignore-revs` in a follow-up commit, and run
   `git config blame.ignoreRevsFile .git-blame-ignore-revs`.
3. Run the formatter twice: some (Prettier with long method chains) settle on the second pass.
4. Run the tests and start the app after the reformat, and look at it if it has a UI, before calling it done.
5. Say in the PR that branches opened before it will conflict, and to run the formatter on them before merging.

## 4. CI
GitHub Actions unless the repo uses something else. On `pull_request` and on pushes to the main branch:
- Check out, set up the runtime from the version file, with the package manager's cache.
- Install from the lockfile (`npm ci`, `uv sync --frozen`, `bundle install` with the lockfile).
- Lint, format check, tests; the build or a Docker build if the project has one; a smoke check that it starts
  is worth having for a server.
- Deploy jobs only on main, `needs:` the checks, with OIDC to the cloud rather than stored keys.
- Pin actions to a major version (`actions/checkout@v4` style) or a SHA if the repo already does.
- If there are no tests yet, add one real smoke test (it imports, the server answers, the CLI prints help)
  so CI has something meaningful to run, and say so.

## 5. Finish
- Run every new command locally and see it pass: lint, format check, tests.
- Record the commands in CLAUDE.md (and the README if it lists commands).
- Separate commits for: CLAUDE.md, CI, lint/format config and fixes, the reformat. Open a draft PR unless the
  user asked otherwise, and say plainly what was added, what it found, and anything left out and why.
