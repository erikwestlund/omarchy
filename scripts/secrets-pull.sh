#!/usr/bin/env bash

# Pull secrets from R2 and place them in final locations

set -e

SECRETS_DIR="$HOME/.secrets"
CONFIG_FILE="$SECRETS_DIR/config"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: No config found. Run secrets-setup first."
    exit 1
fi

# Load config as environment variables
set -a
source "$CONFIG_FILE"
set +a

echo "Pulling secrets from R2..."

# Sync from R2 to local
rclone sync "r2:$BUCKET" "$SECRETS_DIR" \
    --exclude "config" \
    --verbose

# Fix permissions on secrets dir
chmod 700 "$SECRETS_DIR"

# Place SSH keys
if [[ -d "$SECRETS_DIR/ssh" ]]; then
    echo "Placing SSH keys..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    cp -r "$SECRETS_DIR/ssh/"* "$HOME/.ssh/" 2>/dev/null || true

    # Fix SSH permissions
    find "$HOME/.ssh" -type f -name "*.pub" -exec chmod 644 {} \;
    find "$HOME/.ssh" -type f ! -name "*.pub" ! -name "known_hosts" ! -name "authorized_keys" ! -name "config" -exec chmod 600 {} \;
    [[ -f "$HOME/.ssh/config" ]] && chmod 600 "$HOME/.ssh/config"
    [[ -f "$HOME/.ssh/known_hosts" ]] && chmod 644 "$HOME/.ssh/known_hosts"
    [[ -f "$HOME/.ssh/authorized_keys" ]] && chmod 600 "$HOME/.ssh/authorized_keys"
fi

# Place GPG keys
if [[ -d "$SECRETS_DIR/gpg" ]]; then
    echo "Placing GPG keys..."
    # Import GPG keys if gpg is available
    if command -v gpg &> /dev/null; then
        for key in "$SECRETS_DIR/gpg/"*.asc "$SECRETS_DIR/gpg/"*.gpg; do
            [[ -f "$key" ]] && gpg --import "$key" 2>/dev/null || true
        done
    fi
fi

# Place any other dotfiles from secrets
if [[ -d "$SECRETS_DIR/dotfiles" ]]; then
    echo "Placing secret dotfiles..."
    cp -r "$SECRETS_DIR/dotfiles/"* "$HOME/" 2>/dev/null || true
fi

echo "Done."
