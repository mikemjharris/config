# Claude Code Hooks Setup

This configuration includes Claude Code hooks that run automatically in web instances.

## Hook Configuration

Hooks are configured in `.claude/settings.local.json` and scripts are stored in `.claude/hooks/`.

### Current Hooks

#### 1. Ruby Installation Hook (`install-ruby.sh`)
- **Trigger**: `SessionStart` - Runs when a new Claude Code session starts
- **Environment**: Web only (checks `CLAUDE_CODE_REMOTE="true"`)
- **Purpose**: Automatically installs Ruby 3.4.4 using rbenv if not already installed
- **Location**: `.claude/hooks/install-ruby.sh`
- **Timeout**: 600 seconds (10 minutes) - Ruby compilation can take 5-10 minutes
- **Logging**: All output logged to `claude.log` in project root

## Environment Detection

The hooks use the `CLAUDE_CODE_REMOTE` environment variable to determine the execution context:

- `CLAUDE_CODE_REMOTE="true"` → Running in Claude Code **web** instance
- `CLAUDE_CODE_REMOTE=""` or not set → Running in Claude Code **CLI**

This ensures hooks only run in the cloud (web) environment and not on local machines.

## Testing Hooks

### Test Environment Detection
Run the test script to verify environment detection:

```bash
.claude/hooks/test-hook.sh
```

### Test Ruby Installation Hook
You can manually test the Ruby installation hook:

```bash
.claude/hooks/install-ruby.sh
```

In CLI environment, it should output:
```
Skipping Ruby installation - not in web environment
```

In web environment, it will:
1. Check if rbenv is installed
2. Check if Ruby 3.4.4 is already installed
3. Install Ruby 3.4.4 if needed
4. Set it as the global version

## Hook Events Available

- `SessionStart` - When a new session starts (used for Ruby hook)
- `SessionEnd` - When a session ends
- `PreToolUse` - Before any tool executes (can block execution)
- `PostToolUse` - After any tool executes
- `UserPromptSubmit` - When user submits a prompt
- `Stop` / `SubagentStop` - When agent finishes

## Adding New Hooks

### Step 1: Create Hook Script

Create a new script in `.claude/hooks/`:

```bash
#!/bin/bash
# Only run in web environment
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then
  echo "Skipping - not in web environment"
  exit 0
fi

# Your hook logic here
echo "Running in web instance!"
exit 0
```

### Step 2: Make Executable

```bash
chmod +x .claude/hooks/your-hook.sh
```

### Step 3: Add to Settings

Edit `.claude/settings.local.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/your-hook.sh"
          }
        ]
      }
    ]
  }
}
```

## Permissions

Hook scripts need appropriate permissions in the settings. Common patterns:

- `Bash(rbenv:*)` - Allow rbenv commands
- `Bash(gem:*)` - Allow gem commands
- `Bash(bundle:*)` - Allow bundle commands

Add these to the `permissions.allow` array in settings.

## Security Notes

- Hooks run with your user's full permissions
- Always validate hook scripts before adding them
- Use web-only checks (`CLAUDE_CODE_REMOTE`) for cloud-specific operations
- Hooks timeout after 60 seconds by default (configurable with `timeout` parameter in seconds)
- Failed hooks will block execution in `PreToolUse` events
- Long-running hooks (like Ruby compilation) should have explicit timeout values (e.g., 600 seconds)

## Debugging

To see hook execution logs:
1. In CLI: Run `claude --debug`
2. In Web: Check browser console or session logs
3. Check `claude.log` in project root for detailed hook execution logs

The `claude.log` file contains:
- Timestamp of session start
- All commands executed by hooks
- Command output and errors
- Environment variables at hook execution time

## Additional Resources

- Claude Code hooks documentation: Use `/hooks` command in Claude Code
- Full hook reference: See Claude Code docs
