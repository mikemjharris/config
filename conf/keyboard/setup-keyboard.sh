#!/bin/bash

#Got a new akko keyboard.  Wanted to remap some of the keys without remapping for all keybaords

# get the id for the keyboard we're using
KEYBOARD_ID=$(
  xinput list | 
    sed -n 's/.*Akko\skeyboard\s*id=\([0-9]*\).*/\1/p'
)

[ "$KEYBOARD_ID" ] || exit

# updload the new layout display
# TODO make the folder structure less brittle
xkbcomp -i $KEYBOARD_ID ~/.mh_config/new-layout.xkb $DISPLAY
