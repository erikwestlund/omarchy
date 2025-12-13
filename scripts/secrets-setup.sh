#!/usr/bin/env bash

# Setup rclone for R2 secrets sync
# Creates ~/.secrets/config with R2 credentials

set -e

SECRETS_DIR="$HOME/.secrets"
CONFIG_FILE="$SECRETS_DIR/config"

echo "Omarchy Secrets Setup"
echo "====================="
echo

# Check for rclone
if ! command -v rclone &> /dev/null; then
    echo "rclone not found. Install it first:"
    echo "  sudo pacman -S rclone"
    exit 1
fi

# Create secrets directory
mkdir -p "$SECRETS_DIR"
chmod 700 "$SECRETS_DIR"

# Check if already configured
if [[ -f "$CONFIG_FILE" ]]; then
    echo "Config already exists at $CONFIG_FILE"
    read -p "Overwrite? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted"
        exit 1
    fi
fi

# Gather R2 credentials
echo "Enter your Cloudflare R2 credentials:"
echo
read -p "Account ID: " account_id
read -p "Bucket name: " bucket_name
read -p "Access Key ID: " access_key
read -s -p "Secret Access Key: " secret_key
echo
echo

# Write config
cat > "$CONFIG_FILE" << EOF
RCLONE_CONFIG_R2_TYPE=s3
RCLONE_CONFIG_R2_PROVIDER=Cloudflare
RCLONE_CONFIG_R2_ACCESS_KEY_ID=$access_key
RCLONE_CONFIG_R2_SECRET_ACCESS_KEY=$secret_key
RCLONE_CONFIG_R2_ENDPOINT=https://${account_id}.r2.cloudflarestorage.com
RCLONE_CONFIG_R2_ACL=private
BUCKET=$bucket_name
EOF

chmod 600 "$CONFIG_FILE"

echo "Config saved to $CONFIG_FILE"
echo
echo "Test with: secrets-pull"
