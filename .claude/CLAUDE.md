# Config Repository - Claude Code Context

This repository contains personal configuration files, scripts, and development environment setup.

## Environment-Specific Guidelines

### Web Environment (Claude Code on the web)
When `CLAUDE_CODE_REMOTE="true"`:
- See @rules/web-environment.md for web-specific guidelines
- Ruby 3.4.4 is automatically installed via rbenv on session start
- Network access is limited to allowlisted domains
- All operations run in isolated cloud VMs

### Local CLI Environment
When running Claude Code CLI:
- See @rules/local-environment.md for CLI-specific guidelines
- Full access to local system tools and Docker
- Direct git operations with your credentials
- Can interact with tmux sessions and local services

## Repository Structure

```
/Users/mike/working/config/
├── bin/                 # Executable scripts and utilities
├── conf/                # Configuration files (.bashrc, .gitconfig, etc.)
├── local-exec/          # Local execution scripts
├── scripts/             # Utility scripts
└── .claude/             # Claude Code configuration
    ├── hooks/           # Hook scripts for automation
    ├── rules/           # Environment-specific rules
    └── settings.local.json  # Settings and permissions
```

## Common Tasks

### Configuration Management
- Edit shell configs in `conf/`
- Install configs with `bin/local-install.sh`

### Development Scripts
- Weekly repo summaries: `scripts/weekly-repo-summary.sh`
- PR notifications: `.github/scripts/pr-notifications.js`

## Important Notes

- CLAUDE.local.md contains your personal preferences (not in git)
- Hooks in `.claude/hooks/` provide environment-specific setup
- Permissions configured in `.claude/settings.local.json`
