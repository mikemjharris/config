# Keyboard setup - LINUX (keyd, current)

`./setup-keyd.sh` installs [keyd](https://github.com/rvaiya/keyd) and links `keyd/default.conf` to `/etc/keyd/default.conf`.
keyd remaps at the input-device level, so it works on Wayland (the Ubuntu default), X11 and the console.

- Caps Lock → Ctrl
- Alt+C / Alt+V → copy / paste (sent as Ctrl+Insert / Shift+Insert so terminals work too)
- Win+H/J/K/L → Left / Down / Up / Right

Edit `keyd/default.conf`, then `sudo keyd reload`. If a remap ever locks you out, `Backspace+Escape+Enter` kills keyd.

# Keyboard setup - LINUX (xkbcomp, legacy X11 only)


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

