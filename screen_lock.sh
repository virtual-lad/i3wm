#!/bin/bash

# 1. Define paths
ICON=".config/i3/lock_icon.png"
SCREENSHOT="/tmp/screenshot.png"
BG_DONE="/tmp/background_done.png"
FINAL="/tmp/lock_screen.png"

# 2. Check if the icon exists. If not, just pixelate and lock.
if [ ! -f "$ICON" ]; then
    scrot $SCREENSHOT
    convert $SCREENSHOT -scale 10% -scale 1000% $FINAL
    i3lock -i $FINAL
    rm $SCREENSHOT $FINAL
    exit 0 # Done
fi

# 3. IF THE ICON EXISTS: Process the layers.
# Layer A: Take screenshot and pixelate it completely.
scrot $SCREENSHOT
convert $SCREENSHOT -scale 10% -scale 1000% $BG_DONE

# Layer B: Composite (stamp) the SHARP icon onto the FINISHED blurry BG.
# This command is much stricter about layers.
composite -gravity center "$ICON" $BG_DONE $FINAL

# 4. Lock the system
i3lock -i $FINAL

# 5. Cleanup
rm $SCREENSHOT $BG_DONE $FINAL
