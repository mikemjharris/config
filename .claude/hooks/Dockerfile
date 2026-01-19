# Dockerfile to test Claude Code hooks in simulated web environment
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    libyaml-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Create a test user (similar to web environment)
RUN useradd -m -s /bin/bash testuser
USER testuser
WORKDIR /home/testuser

# Install rbenv and ruby-build
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Set up rbenv in PATH
ENV PATH="/home/testuser/.rbenv/bin:/home/testuser/.rbenv/shims:${PATH}"
RUN echo 'eval "$(rbenv init - bash)"' >> ~/.bashrc

# Simulate Claude Code web environment variables
ENV CLAUDE_CODE_REMOTE=true
ENV CLAUDE_PROJECT_DIR=/home/testuser/project

# Create project directory
RUN mkdir -p /home/testuser/project

# Copy the hook script
COPY --chown=testuser:testuser install-ruby.sh /home/testuser/project/.claude/hooks/install-ruby.sh
RUN chmod +x /home/testuser/project/.claude/hooks/install-ruby.sh

# Set working directory to project
WORKDIR /home/testuser/project

# Default command runs the hook and then drops into bash
CMD ["/bin/bash", "-c", "eval \"$(rbenv init - bash)\" && ./.claude/hooks/install-ruby.sh && echo '' && echo '=== Testing Ruby ===' && ruby --version && gem --version && /bin/bash"]
