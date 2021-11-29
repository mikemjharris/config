# Keyboard setup - LINUX

Symlink 80-keyboard.rules to /etc/udev/rules.d/80-keyboard.rules

This checks when a device is added then runs the keyboard-lock.sh script

This creates a lock file in /tmp/keyboard.lock

Finally run:

Run ```./file-notify.sh /tmp/keyboard.lock /home/mike/working/config/conf/keyboard/setup-keyboard.sh &```

This checks when that lock file updates and when it does it runs the script we have that sets the keybaord to the correct layout.

Useful reference: [https://bbs.archlinux.org/viewtopic.php?pid=1626055#p1626055](link)


## Keyboard setup windows
Install the keyboard layout library.
Map keys to the correct layout then build the project and install the keyboard. (alternatively install using the 'mjk' foleder in this directory)
Win + Space switches keyboards (i've mapped the new keyboard to US so that it appears in my english settings).

