#!/bin/sh

if bash -c "command -v tput" > /dev/null 2>&1; then
    tput "$*"
elif [ "$1" = "colors" ]; then
    case "$TERM" in
        xterm-256color|screen-256color|tmux-256color|rxvt-unicode-256color)
            echo 256
            ;;
        xterm-color|screen|tmux|rxvt|xterm|linux)
            echo 8
            ;;
        vt100|vt220|vt102|dumb)
            echo 2
            ;;
        *)
            echo 0
        ;;
    esac
fi
