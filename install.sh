#!/bin/bash

DOTFILEDIR=$(realpath "$(dirname "$0")")

find "$DOTFILEDIR" \( -type f -o -type l \) -not -name "install.sh" -not -path "*/.*" -not -path "*/devcontainer/*" -print0 | while IFS= read -r -d '' FILE; do
    REL_PATH="${FILE#$DOTFILEDIR/}"
    TARGET_DIR="$HOME/.$(dirname "$REL_PATH")"
    mkdir -p "$TARGET_DIR"
    echo "Installing $REL_PATH => $HOME/.$REL_PATH"
    ln -sf "$FILE" "$HOME/.$REL_PATH"
done

if [ -f "$DOTFILEDIR/gnupg/pubkey.asc" ]; then
    gpg --no-autostart --import "$DOTFILEDIR/gnupg/pubkey.asc" 2>/dev/null || true
fi

# Install devcontainer-specific overrides
if [ -n "$REMOTE_CONTAINERS" ] || [ -n "$CODESPACES" ] || [ -f "/.dockerenv" ]; then
    find "$DOTFILEDIR/devcontainer" \( -type f -o -type l \) -not -path "*/.*" -print0 2>/dev/null | while IFS= read -r -d '' FILE; do
        REL_PATH="${FILE#$DOTFILEDIR/devcontainer/}"
        TARGET_DIR="$HOME/.$(dirname "$REL_PATH")"
        mkdir -p "$TARGET_DIR"
        echo "Installing (devcontainer) $REL_PATH => $HOME/.$REL_PATH"
        ln -sf "$FILE" "$HOME/.$REL_PATH"
    done
fi
