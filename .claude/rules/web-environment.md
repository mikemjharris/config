# Web Environment Guidelines

**Active when**: `CLAUDE_CODE_REMOTE="true"` (Claude Code on the web)

## Environment Characteristics

### Execution Context
- Runs in isolated, ephemeral cloud VMs
- Sessions are temporary - no persistent state between sessions
- All operations are sandboxed for security

### Ruby Setup
- Ruby 3.4.4 is automatically installed via rbenv on session start
- Hook script: `.claude/hooks/install-ruby.sh`
- Global Ruby version is set automatically
- Hook logs available at `~/.claude-hooks.log`

### Network Access
- Limited to Anthropic's default allowlisted domains
- GitHub operations use Anthropic's secure proxy
- Configure custom domains in environment settings if needed
- Web searches are available via WebSearch tool

### Tool Availability
- All Claude Code tools available (Read, Write, Edit, Bash, etc.)
- Git operations work through secure proxy
- Docker may not be available (check with `docker --version`)
- No access to local tmux sessions

## Best Practices for Web

### Session Initialization
- SessionStart hooks handle environment setup
- Ruby installation is automatic
- Check tool availability with test commands

### File Operations
- Use Read/Write/Edit tools for file operations
- Bash file commands work but tools are preferred

### Git Operations
- All git commands work normally
- Authentication handled by secure proxy
- Can clone, commit, push, pull without credentials

### Persistent Data
- No persistence between sessions
- Clone repos fresh each session if needed
- Use cloud storage for session-independent data

## Commands to Use

Prefer these patterns in web environment:

```bash
# Check Ruby installation
ruby --version
rbenv versions

# Check hook logs if something went wrong
cat ~/.claude-hooks.log

# Git operations work normally
git status
git log
gh pr list

# Web searches available
# Use WebSearch tool for up-to-date information

# File operations
# Prefer Read/Write/Edit tools over cat/echo
```

## Limitations

- No local Docker daemon access (usually)
- No local tmux session access
- No direct filesystem outside project
- Network limited to allowlisted domains
- No sudo access

## Environment Detection

Check if you're in web environment:

```bash
if [ "$CLAUDE_CODE_REMOTE" = "true" ]; then
  echo "Running in web environment"
fi
```
