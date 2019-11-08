**Config to get things working the way I want them to**

This repo includes a bunch of scripts to help me setup computers how I want them.  There are scripts for a new box to install relevant programs.  In addition there are script to set up dot files and other config. This config can either be cloned and linked locally or a one off install (e.g. working on a remote box). 

As of Nov 2019 my usual setup is linux laptop with Ubuntu 18 and Gnome desktop.  Usually use a combination of tmux/vim.

*Applications*
When setting up a new computer you often need to install many things.  These scripts install most of the programs you might need such as git, ruby, mysql etc.

If on a mac then you will want to install brew and it's dependencies
- `./bin/install-brew-packages.sh`

If on linux:
- `./bin/install-linux.sh`
- `./bin/install-linux-apps.sh`


*Config*

**Working Locally**  
Working locally I clone this repo - the install scripts symlink all the releavant files which means if I make any config updates they are reflected in the repo and can be commited and saved. 

- clone repo `git clone git@github.com:mikemjharris/config.git`
- `cd config`
- ./bin/local-install.sh

**Remote Box**
On remote box you might not want to clone and do a full symlinking etc. as this requires setting up ssh keys etc.
This script will do a one off copy of tmux/vim/bash config on a remote box (or anywhere). 
```
curl -fsSL "https://raw.githubusercontent.com/mikemjharris/config/master/bin/install.sh" | bash -e
```


**Notes - Other useful applications**  
Most applications are installed in above scripts - these are some others that I find interestings.
- http://lightheadsw.com/caffeine/  - prevent computer from sleeping - useful for presentations  
- http://www.irradiatedsoftware.com/sizeup/  - mac window manager  
- https://www.gimp.org/downloads/ - gimp for designing stuff  

