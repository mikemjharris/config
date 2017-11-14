**Config to get things working the way I want them to**

This includes things like setting up a new laptop, documentation on getting things set up, config files (.zshrc/.vimrc) etc.

**Contents**
- command-line-alias:  List of alias to use on the command line.  Append to current ./.zshrc or ./bashrc
- latest-commits: Loops through latest commits and outputs latest along with numbering so you can select 


**To install on a remote box**

```
curl -fsSL "https://raw.githubusercontent.com/mikemjharris/config/master/bin/install.sh" | bash -e
```

**If working locally**
The above works fine for a one off install but I often find myself using the config on a number of machines and updating as I go along.
In this case I want the various .rc files symlinked to a copy of this repo.  Any changes can easily then be commited and pushed back.

In this case:
- clone this repo
- cd bin
- ./local-install.sh
If on a mac then you will want to install brew and it's dependencies
- ./bin/install-brew-packages.sh

**Other useful applications**  
http://lightheadsw.com/caffeine/  - prevent computer from sleeping - useful for presentations
http://www.irradiatedsoftware.com/sizeup/  - mac window manager
https://www.gimp.org/downloads/ - gimp for designing stuff

