#!/bin/sh
PANE_TTY=$(tmux display-message -p '#{pane_tty}' 2>/dev/null)
if [ -n "$PANE_TTY" ]; then
  printf '\033Ptmux;\033\033]9;Claude is done\007\033\\' > "$PANE_TTY"
fi
