#!/bin/bash
# Quick test script using mock rbenv - faster than full Ruby installation
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "Quick Hook Test (Mock rbenv)"
echo "=========================================="
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed or not in PATH"
    exit 1
fi

# Build the Docker image
echo "=== Building Test Image ==="
docker build -f Dockerfile.quick -t claude-hooks-quick-test . || exit 1
echo "✓ Docker image built"
echo ""

# Test 1: Default version
echo "=========================================="
echo "Test 1: Default Ruby version (3.4.4)"
echo "=========================================="
docker run --rm claude-hooks-quick-test /bin/bash -c "./.claude/hooks/install-ruby.sh"
echo ""

# Test 2: With .ruby-version file
echo "=========================================="
echo "Test 2: With .ruby-version file (3.3.0)"
echo "=========================================="
docker run --rm claude-hooks-quick-test /bin/bash -c "
    echo '3.3.0' > .ruby-version && \
    ./.claude/hooks/install-ruby.sh
"
echo ""

# Test 3: CLI environment (should skip)
echo "=========================================="
echo "Test 3: CLI Environment (should skip)"
echo "=========================================="
docker run --rm -e CLAUDE_CODE_REMOTE="" claude-hooks-quick-test /bin/bash -c "./.claude/hooks/install-ruby.sh"
echo ""

# Test 4: Already installed
echo "=========================================="
echo "Test 4: Already installed (idempotency)"
echo "=========================================="
docker run --rm claude-hooks-quick-test /bin/bash -c "
    # Simulate already having the version
    mkdir -p ~/.rbenv && \
    echo '3.4.4' > ~/.rbenv/version && \
    echo '#!/bin/bash' > ~/.rbenv/bin/rbenv && \
    echo 'case \"\$1\" in' >> ~/.rbenv/bin/rbenv && \
    echo '  --version) echo \"rbenv 1.2.0-mock\" ;;' >> ~/.rbenv/bin/rbenv && \
    echo '  versions) echo \"  3.4.4\" ;;' >> ~/.rbenv/bin/rbenv && \
    echo '  global) echo \"Setting global to \$2\"; echo \"\$2\" > ~/.rbenv/version ;;' >> ~/.rbenv/bin/rbenv && \
    echo '  rehash) echo \"Rehashing shims\" ;;' >> ~/.rbenv/bin/rbenv && \
    echo 'esac' >> ~/.rbenv/bin/rbenv && \
    chmod +x ~/.rbenv/bin/rbenv && \
    ./.claude/hooks/install-ruby.sh
"
echo ""

echo "=========================================="
echo "✓ All quick tests complete!"
echo "=========================================="
echo ""
echo "To run full tests with real Ruby installation:"
echo "  ./test-in-docker.sh"
echo ""
echo "To clean up:"
echo "  docker rmi claude-hooks-quick-test"
echo "  docker rmi claude-hooks-test"
