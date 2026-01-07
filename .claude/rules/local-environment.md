# Local CLI Environment Guidelines

**Active when**: `CLAUDE_CODE_REMOTE=""` or not set (Claude Code CLI)

## Environment Characteristics

### Execution Context
- Runs on your local Mac machine
- Full access to local system and tools
- Persistent state across sessions
- Direct filesystem access

### System Access
- Full local user permissions
- Access to all installed tools
- Docker daemon available
- tmux sessions accessible
- All development tools (node, python, ruby, etc.)

### Ruby Setup
- Use your local rbenv setup
- Ruby installation hooks are skipped in CLI
- Manage Ruby versions with local rbenv commands

### Network Access
- Full network access
- Direct git operations with your credentials
- No proxy or restrictions
- Can access any service or API

### Tool Availability
- All Claude Code tools available
- Direct bash access to system commands
- Docker and docker-compose available
- Full tmux control
- Access to local services (databases, etc.)

## Best Practices for CLI

### Development Workflow
- Use local Docker services
- Access tmux sessions for background processes
- Direct git operations with your GitHub credentials

### File Operations
- Prefer Read/Write/Edit tools (faster, better UX)
- Bash commands available when needed

### Git Operations
- Uses your local git config and credentials
- SSH keys work as configured
- GPG signing if configured

### Local Services
- Can start/stop Docker containers
- Access local databases
- Run local web servers
- Interact with tmux sessions

## Commands to Use

Common patterns for local CLI:

```bash
# Docker operations
docker ps
docker-compose up
~/working/config/local-exec/get-docker-service.sh

# tmux operations
tmux list-sessions
tmux list-windows
tmux list-panes

# Local development
./bin/local-install.sh
./scripts/weekly-repo-summary.sh

# Git with local credentials
git push origin main
gh pr create

# Ruby management
rbenv install 3.4.4
rbenv global 3.4.4
```

## Advantages

- Full system access
- Persistent sessions
- Local development tools
- Docker and containers
- tmux multiplexing
- Direct network access
- Your SSH keys and GPG
- Local file system

## Environment Detection

Check if you're in CLI environment:

```bash
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then
  echo "Running in CLI environment"
fi
```

## Personal Preferences

Add personal, machine-specific preferences to:
- `~/.claude/CLAUDE.md` - Global personal preferences
- `./CLAUDE.local.md` - Project-specific personal preferences (gitignored)
