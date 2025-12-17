# Config to setup laptops/systems how I want

This repo includes a bunch of scripts to help me setup computers how I want them.  There are scripts for a new box to install relevant programs.  In addition there are script to set up dot files and other config. This config can either be cloned and linked locally or a one off install (e.g. working on a remote box). 

As of Nov 2019 my usual setup is linux laptop with Ubuntu and Gnome desktop.  Usually use a combination of tmux/vim. I'm currently experimenting with using Windows Substation for Linux (WSL) so there are some specific setups for that.

The docs are ok ish - I know what I need at various stages and have tried to detail it here but I'm guessing that most of the setup will only be relevant to me so full docs and comments are kinda lite.  Feel free to message me if you have questions about how anything works.

## Repository Structure

This repository is organized into several key directories:

```
config/
├── .github/          # GitHub Actions workflows
│   ├── workflows/    # Auto-rebase and PR notifications
│   └── scripts/      # Workflow support scripts
├── bin/              # Installation and utility scripts
│   ├── install-*.sh  # System setup scripts
│   ├── commit-msg.sh # Git hooks for commit validation
│   ├── pre-commit.sh # Branch naming validation
│   ├── pre-push.sh   # WIP commit prevention
│   └── daily-note.sh # Daily note generation
├── conf/             # Configuration files
│   ├── .bash_aliases # Bash aliases and shortcuts
│   ├── .bashrc       # Bash configuration
│   ├── .tmux.conf    # Tmux configuration
│   ├── .vimrc        # Vim configuration
│   ├── .git-templates/ # Git hook templates
│   ├── new-nvim-setup/ # Neovim configuration
│   └── tmux/         # Additional tmux configs
├── local-exec/       # Development environment launchers
│   └── dev           # Tmux session manager
├── scripts/          # Standalone utility scripts
│   └── weekly-repo-summary.sh # Commit analysis tool
└── Dockerfile        # Docker development environment
```

### Key Directories

- **bin/**: Installation scripts and git hooks for setting up systems and maintaining code quality
- **conf/**: Dotfiles and configuration for various tools (bash, vim, tmux, neovim, etc.)
- **local-exec/**: Scripts for launching pre-configured development environments
- **scripts/**: Standalone utility scripts for repository analysis and other tasks
- **.github/**: GitHub Actions workflows for automation (auto-rebase, PR notifications)

## Applications
When setting up a new computer you often need to install many things.  These scripts install most of the programs you might need such as git, ruby, mysql etc.

If on a mac then you will want to install brew and it's dependencies  
- `./bin/install-brew-packages.sh`

If on linux:
- `./bin/install-linux.sh`
- `./bin/install-linux-apps.sh`


## Config

### Working Locally
Working locally I clone this repo - the install scripts symlink all the releavant files which means if I make any config updates they are reflected in the repo and can be commited and saved. 

- clone repo `git clone git@github.com:mikemjharris/config.git`
- `cd config`
- ./bin/local-install.sh

Recently (13-04-2022) added in neovim installation - that's not included in the script (and indeed the script isn't as smooth as I'd like) for nvim sym link the new-nvim-config folder to ~/.config/nvim

### Remote Box
On remote box you might not want to clone and do a full symlinking etc. as this requires setting up ssh keys etc.
This script will do a one off copy of tmux/vim/bash config on a remote box (or anywhere). 
```
curl -fsSL "https://raw.githubusercontent.com/mikemjharris/config/master/bin/install.sh" | bash -e
```
### WSL - windows subsystem for Linux
Most of this setup should work as it does for a standard ubuntu setup. A few things to note:
- Use Windows Terminal not Windows console (it solves many font and display issues)
- My normal setup mixes dark mode in the terminal with light in vim - the terminal seems to force the same colour in all situations. As such I've set a light theme for the terminal - see `robbyrussell-light.zsh-theme` for instructions.

## Scripts

### Weekly Repository Summary
A powerful script to analyze commit activity across multiple Git repositories. Perfect for generating weekly development summaries and insights.

**Quick start:**
```bash
# Create a list of repositories to analyze
cp scripts/repos.example.txt scripts/repos.txt
# Edit repos.txt to add your repository URLs

# Run the summary
./scripts/weekly-repo-summary.sh --file scripts/repos.txt
```

**Features:**
- Analyzes commits from multiple repositories
- Categorizes commits by type (feat, fix, chore, etc.)
- Outputs in text or JSON format
- LLM-ready for automated summarization

For detailed usage and examples, see [scripts/WEEKLY_SUMMARY_README.md](scripts/WEEKLY_SUMMARY_README.md)

## VS Code
Just started using VS code and wanted a backup of extensions.  To install extensions on a new computer:
`cat ./conf/code-extensions.txt | xargs -n 1 code --install-extension`
To backup this (or similar):
`code --list-extensions >> ./conf/code-extensions.txt`

Also run:
`ln -s ./conf/settings.json ~/.config/Code/User/settings.json`

Note: since setting this up have not continued with vscode - reverting back to VIM (and specifically Neovim)

### **Notes - Other useful applications**
Most applications are installed in above scripts - these are some others that I find interestings - this is pretty old now
as mainly using linux apps rather than mac.
- http://lightheadsw.com/caffeine/  - prevent computer from sleeping - useful for presentations  
- http://www.irradiatedsoftware.com/sizeup/  - mac window manager  
- https://www.gimp.org/downloads/ - gimp for designing stuff  
- https://hluk.github.io/CopyQ/ - copyq - clipboard manager

