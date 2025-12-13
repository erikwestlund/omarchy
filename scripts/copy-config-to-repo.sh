#!/usr/bin/env bash

# Pull a file from ~/.config into the repo
# Usage: ./scripts/pull-config.sh <path>
# Example: ./scripts/pull-config.sh hypr/bindings.conf

set -e

if [[ -z "$1" ]]; then
    echo "Usage: pull-config <path>"
    echo "Example: pull-config hypr/bindings.conf"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SOURCE="$HOME/.config/$1"
DEST="$REPO_DIR/config/$1"

if [[ ! -e "$SOURCE" ]]; then
    echo "Error: $SOURCE does not exist"
    exit 1
fi

if [[ -e "$DEST" ]]; then
    echo "Warning: $DEST already exists in repo"
    read -p "Overwrite? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted"
        exit 1
    fi
fi

mkdir -p "$(dirname "$DEST")"
cp -r "$SOURCE" "$DEST"
echo "Copied $SOURCE -> $DEST"
