#!/bin/sh
# Reviewers spawned by cross-agent-review are headless; only notify for the interactive session.
[ -n "$REVIEW_ACTIVE" ] && exit 0
NAME="${1:-Agent}"
PANE_TTY=$(tmux display-message -p '#{pane_tty}' 2>/dev/null)
if [ -n "$PANE_TTY" ]; then
  printf '\033Ptmux;\033\033]9;%s is done\007\033\\' "$NAME" > "$PANE_TTY"
else
  printf '\033]9;%s is done\007' "$NAME"
fi
