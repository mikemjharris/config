# Use a recent Node.js LTS image on Debian
FROM node:20-bullseye

# Install basic deps, Neovim dependencies, and zsh
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ripgrep \
    fd-find \
    python3-pip \
    cmake \
    unzip \
    zsh \
    fonts-powerline \
    ruby \
    ruby-dev \
    && rm -rf /var/lib/apt/lists/*

# Install latest Neovim from release
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz \
    && tar xzf nvim-linux64.tar.gz \
    && cp -r nvim-linux64/* /usr \
    && rm -rf nvim-linux64.tar.gz nvim-linux64

# Install TypeScript and common development tools
RUN npm install -g typescript ts-node @types/node

# Install rbenv and ruby-build
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build && \
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc && \
    . ~/.bashrc && \
    ~/.rbenv/bin/rbenv install 3.2.2 && \
    ~/.rbenv/bin/rbenv global 3.2.2

# Install Solargraph
RUN ~/.rbenv/shims/gem install solargraph solargraph-rails

# Modify existing node user and group
RUN groupmod -n developer node && \
    usermod -l developer node && \
    usermod -d /home/developer -m developer && \
    usermod -s /bin/zsh developer

# Copy Neovim configuration before switching user to ensure proper permissions
COPY --chown=developer:developer ../conf/new-nvim-setup/ /home/developer/.config/nvim/

# Switch to the developer user
USER developer
WORKDIR /home/developer

# Setup rbenv for developer user
RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc && \
    echo 'eval "$(rbenv init -)"' >> ~/.zshrc

# Install Neovim plugins using Lazy.nvim and run Mason to install LSPs
RUN nvim --headless "+Lazy! sync" +qa && \
    nvim --headless "+MasonInstall typescript-language-server lua-language-server pyright solargraph" +qa

# Install Oh My Zsh and plugins
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install custom plugins after Oh My Zsh is set up
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Configure zsh with additional PATH settings for LSP servers
RUN echo 'export TERM=xterm-256color\n\
export ZSH="/home/developer/.oh-my-zsh"\n\
export PATH=$PATH:/usr/local/bin:$HOME/.local/bin:$HOME/.rbenv/bin:$HOME/.rbenv/shims\n\
\n\
# Oh My Zsh configuration\n\
ZSH_THEME="robbyrussell"\n\
plugins=(git node npm zsh-autosuggestions zsh-syntax-highlighting)\n\
\n\
# Source Oh My Zsh\n\
source $ZSH/oh-my-zsh.sh\n\
\n\
# Node settings\n\
export NVM_DIR="$HOME/.nvm"\n\
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"\n\
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"\n\
\n\
# Initialize rbenv\n\
eval "$(rbenv init -)"\n\
\n\
# Aliases\n\
alias vim="nvim"\n\
alias ls="ls --color=auto"\n\
' > ~/.zshrc

# Override the default Node.js entrypoint
ENTRYPOINT ["/bin/zsh"]

