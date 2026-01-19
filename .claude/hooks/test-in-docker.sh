#!/bin/bash
# Script to test Claude Code hooks in Docker
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "Testing Claude Code Hooks in Docker"
echo "=========================================="
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed or not in PATH"
    exit 1
fi

# Build the Docker image
echo "=== Building Docker Image ==="
docker build -t claude-hooks-test .
echo "✓ Docker image built"
echo ""

# Run different test scenarios
echo "=========================================="
echo "Test 1: Default Ruby version (3.4.4)"
echo "=========================================="
docker run --rm claude-hooks-test /bin/bash -c "eval \"\$(rbenv init - bash)\" && ./.claude/hooks/install-ruby.sh"
echo ""

echo "=========================================="
echo "Test 2: With .ruby-version file (3.3.0)"
echo "=========================================="
docker run --rm claude-hooks-test /bin/bash -c "
    eval \"\$(rbenv init - bash)\" && \
    echo '3.3.0' > .ruby-version && \
    ./.claude/hooks/install-ruby.sh && \
    echo '' && \
    echo '=== Verification ===' && \
    ruby --version
"
echo ""

echo "=========================================="
echo "Test 3: CLI Environment (should skip)"
echo "=========================================="
docker run --rm -e CLAUDE_CODE_REMOTE="" claude-hooks-test /bin/bash -c "./.claude/hooks/install-ruby.sh"
echo ""

echo "=========================================="
echo "Test 4: Already installed (idempotency)"
echo "=========================================="
docker run --rm claude-hooks-test /bin/bash -c "
    eval \"\$(rbenv init - bash)\" && \
    echo 'Running hook first time...' && \
    ./.claude/hooks/install-ruby.sh && \
    echo '' && \
    echo 'Running hook second time (should be faster)...' && \
    ./.claude/hooks/install-ruby.sh
"
echo ""

echo "=========================================="
echo "✓ All tests complete!"
echo "=========================================="
echo ""
echo "To run interactively:"
echo "  docker run -it --rm claude-hooks-test /bin/bash"
echo ""
echo "To clean up:"
echo "  docker rmi claude-hooks-test"
