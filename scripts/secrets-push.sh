#!/usr/bin/env bash

# Push secrets from local to R2

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

echo "This will sync ~/.secrets to R2 (excluding config)."
echo "Remote files not in local will be DELETED."
read -p "Continue? [y/N] " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted"
    exit 1
fi

echo "Pushing secrets to R2..."

# Sync from local to R2
rclone sync "$SECRETS_DIR" "r2:$BUCKET" \
    --exclude "config" \
    --verbose

echo "Done."
