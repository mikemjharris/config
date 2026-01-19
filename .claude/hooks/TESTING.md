# Testing Claude Code Hooks in Docker

This directory contains Docker-based testing infrastructure for Claude Code hooks.

## Quick Start

### Fast Test (Recommended for Development)
Uses mock rbenv - completes in ~30 seconds:
```bash
cd .claude/hooks
./quick-test.sh
```

### Full Test (Real Ruby Installation)
Actually installs Ruby - takes 5-10 minutes:
```bash
cd .claude/hooks
./test-in-docker.sh
```

## Test Files

- **`Dockerfile.quick`** - Mock rbenv for fast testing
- **`Dockerfile`** - Full rbenv with real Ruby installation
- **`quick-test.sh`** - Run fast tests with mock rbenv
- **`test-in-docker.sh`** - Run full tests with real Ruby

## Test Scenarios

Both test scripts cover:

1. **Default Version Test** - Uses default Ruby 3.4.4
2. **Custom Version Test** - Uses .ruby-version file
3. **CLI Environment Test** - Verifies skip logic when not in web
4. **Idempotency Test** - Verifies script works when Ruby already installed

## Manual Testing

### Interactive Docker Session

Quick (mock rbenv):
```bash
docker build -f Dockerfile.quick -t claude-hooks-quick-test .
docker run -it --rm claude-hooks-quick-test /bin/bash
```

Full (real Ruby):
```bash
docker build -t claude-hooks-test .
docker run -it --rm claude-hooks-test /bin/bash
```

Once inside:
```bash
# Run the hook
./.claude/hooks/install-ruby.sh

# Test with custom version
echo "3.3.0" > .ruby-version
./.claude/hooks/install-ruby.sh

# Verify Ruby
ruby --version
gem --version
```

### Test Specific Scenarios

Test environment detection:
```bash
docker run --rm -e CLAUDE_CODE_REMOTE="true" claude-hooks-quick-test
docker run --rm -e CLAUDE_CODE_REMOTE="" claude-hooks-quick-test
```

Test with custom Ruby version:
```bash
docker run --rm claude-hooks-quick-test /bin/bash -c "
  echo '3.3.6' > .ruby-version && \
  ./.claude/hooks/install-ruby.sh
"
```

## Cleanup

Remove test images:
```bash
docker rmi claude-hooks-quick-test
docker rmi claude-hooks-test
```

## CI/CD Integration

You can add these tests to CI:

```yaml
# .github/workflows/test-hooks.yml
name: Test Hooks
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run hook tests
        run: cd .claude/hooks && ./quick-test.sh
```

## Troubleshooting

### Docker not found
```bash
# Install Docker Desktop or Docker Engine
# macOS: brew install --cask docker
# Linux: https://docs.docker.com/engine/install/
```

### Permission denied
```bash
chmod +x .claude/hooks/*.sh
```

### Build fails
```bash
# Clean up and rebuild
docker system prune -f
docker build --no-cache -t claude-hooks-quick-test .
```

## Development Workflow

1. Make changes to `install-ruby.sh`
2. Run quick test: `./quick-test.sh`
3. If quick test passes, run full test: `./test-in-docker.sh`
4. Commit changes once all tests pass

## Mock vs Real Testing

### Quick Test (Mock rbenv)
- **Speed**: ~30 seconds
- **Purpose**: Test hook logic, environment detection, error handling
- **Use when**: Developing hook logic, checking environment variables

### Full Test (Real Ruby)
- **Speed**: 5-10 minutes
- **Purpose**: Test actual Ruby installation, verify rbenv integration
- **Use when**: Before committing, testing Ruby version compatibility

## Expected Output

Successful quick test output:
```
==========================================
Quick Hook Test (Mock rbenv)
==========================================

=== Building Test Image ===
✓ Docker image built

==========================================
Test 1: Default Ruby version (3.4.4)
==========================================
==========================================
Ruby Installation Hook Starting
==========================================

=== Environment Check ===
CLAUDE_CODE_REMOTE: true
✓ Running in Claude Code web instance
...
✓ All quick tests complete!
==========================================
```
