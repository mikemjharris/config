**Config to get things working the way I want them to**

This includes things like setting up a new laptop, documentation on getting things set up, config files (.zshrc/.vimrc) etc.

**Contents**
- command-line-alias:  List of alias to use on the command line.  Append to current ./.zshrc or ./bashrc
- latest-commits: Loops through latest commits and outputs latest along with numbering so you can select 


**To install on a remote box**  

```curl -fsSL "https://raw.githubusercontent.com/mikemjharris/config/master/bin/install.sh" | bash -e```


**Notes to myself (cause - memory)**
At the moment I symlink my .vimrc and .tmux.conf files to this repo.  As such any changes I do are in one place and will get pushed up to the repo.
TODO - only add changes that makes sense for a remote server and are not in need of any other installations such as pathogen
