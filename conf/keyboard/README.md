# Keyboard setup

Symlink 80-keyboard.rules to /etc/udev/rules.d/80-keyboard.rules

This checks when a device is added then runs the keyboard-lock.sh script

This creates a lock file in /tmp/keyboard.lock

Finally run:

Run ```./file-notify.sh /tmp/keyboard.lock /home/mike/working/config/conf/keyboard/setup-keyboard.sh &```

This checks when that lock file updates and when it does it runs the script we have that sets the keybaord to the correct layout.

Useful reference: [https://bbs.archlinux.org/viewtopic.php?pid=1626055#p1626055](link)
