#!/bin/bash

# The workspace name (with your specific spacing)
WS_NAME="  !"
#WS_NAME="10"
# Your hashed passcode
TARGET_HASH="380930db28d12ba6f443449a6f7836bf2f49127ac6ece83143607f9aec785e2f"

# Get user input
INPUT=$(zenity --password --title="Restricted Access")

# Exit if user cancels
[ -z "$INPUT" ] && exit 1

# Check the hash
CURRENT_HASH=$(echo -n "$INPUT" | sha256sum | awk '{print $1}')

if [ "$CURRENT_HASH" == "$TARGET_HASH" ]; then
    # If a command was passed (like 'move'), execute that, otherwise just switch
    if [ "$1" == "move" ]; then
        i3-msg "move container to workspace $WS_NAME"
    else
        i3-msg "workspace $WS_NAME"
    fi
else
    notify-send "Access Denied" "Incorrect Passcode" -u critical
fi
