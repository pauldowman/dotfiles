#!/bin/bash

DOTFILEDIR=$(realpath "$(dirname "$0")")

find "$DOTFILEDIR" -type f -not -name "install.sh" -not -path "*/.*" -print0 | while IFS= read -r -d '' FILE; do
    REL_PATH="${FILE#$DOTFILEDIR/}"
    TARGET_DIR="$HOME/.$(dirname "$REL_PATH")"
    mkdir -p "$TARGET_DIR"
    echo "Installing $REL_PATH => $HOME/.$REL_PATH"
    ln -sf "$FILE" "$HOME/.$REL_PATH"
done

if [ -f "$DOTFILEDIR/gnupg/pubkey.asc" ]; then
    gpg --import "$DOTFILEDIR/gnupg/pubkey.asc" 2>/dev/null || true
fi
