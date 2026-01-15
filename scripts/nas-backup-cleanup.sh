#!/bin/bash
# Cleanup old restic snapshots on NAS
# Run this on your homelab server via cron, e.g.:
#   0 3 * * * /path/to/nas-backup-cleanup.sh >> /var/log/restic-cleanup.log 2>&1
#
# Retention policy:
#   - 24 hourly snapshots
#   - 7 daily snapshots
#   - 4 weekly snapshots
#   - 6 monthly snapshots

set -e

REPO="${RESTIC_REPOSITORY:-/path/to/nas/SystemSnapshots}"
PASSWORD_FILE="${RESTIC_PASSWORD_FILE:-/path/to/restic-password}"

# Check repository is accessible
if [[ ! -d "$REPO" ]]; then
    echo "Error: Repository not found at $REPO"
    exit 1
fi

if [[ ! -f "$PASSWORD_FILE" ]]; then
    echo "Error: Password file not found at $PASSWORD_FILE"
    exit 1
fi

echo "=== Restic cleanup started: $(date) ==="

# Run forget with retention policy
restic -r "$REPO" \
    --password-file "$PASSWORD_FILE" \
    forget \
    --keep-hourly 24 \
    --keep-daily 7 \
    --keep-weekly 4 \
    --keep-monthly 6 \
    --prune

echo "=== Restic cleanup completed: $(date) ==="
