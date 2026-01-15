# NAS Backups

Automatic home directory backups to the NAS using restic.

## How It Works

- **What**: Backs up `/home/erik` to NAS share `SystemSnapshots`
- **When**: Desktop every 15 min, laptop hourly
- **Tool**: restic (deduplicating backup)
- **Skips**: When NAS offline, or laptop battery <40%

## Commands

### Check backup status
```bash
systemctl --user status nas-backup.timer
systemctl --user list-timers | grep nas
```

### View logs
```bash
journalctl --user -u nas-backup.service
```

### Manual backup
```bash
systemctl --user start nas-backup.service
```

### List snapshots
```bash
restic -r /mnt/nas/SystemSnapshots snapshots
restic -r /mnt/nas/SystemSnapshots snapshots --tag desktop
restic -r /mnt/nas/SystemSnapshots snapshots --tag laptop
```

## Browsing & Restoring

### Browse with file manager (FUSE mount)
```bash
mkdir -p /tmp/restic-browse
restic -r /mnt/nas/SystemSnapshots mount /tmp/restic-browse

# Open in file manager - snapshots organized by date
nautilus /tmp/restic-browse/snapshots/

# Unmount when done
fusermount -u /tmp/restic-browse
```

### Restore specific files
```bash
# Restore to temp directory
restic -r /mnt/nas/SystemSnapshots restore latest \
    --target /tmp/restore \
    --include "/home/erik/Projects/myproject"

# Restore from specific snapshot
restic -r /mnt/nas/SystemSnapshots restore abc123 \
    --target /tmp/restore \
    --include "/home/erik/Documents"
```

### Restore in place (overwrites current files)
```bash
restic -r /mnt/nas/SystemSnapshots restore latest \
    --target / \
    --include "/home/erik/.config/hypr"
```

## Configuration

Settings in `ansible/host_vars/`:

| Variable | Desktop | Laptop | Description |
|----------|---------|--------|-------------|
| `backup_enabled` | true | true | Enable/disable backups |
| `backup_calendar` | `*:0/15` | `hourly` | Systemd timer schedule |
| `backup_battery_threshold` | - | 40 | Skip below this battery % |

All defaults in `ansible/roles/backup/defaults/main.yml`.

## Excludes

Patterns in `config/restic/excludes.txt`:
- Caches (`.cache`, `node_modules`, `__pycache__`)
- Large files (`*.iso`, `*.qcow2`)
- Git objects (`.git/objects`)
- Package caches (`.cargo/registry`, `.m2/repository`)

## Cleanup

Cleanup runs on homelab server (not on workstations) to avoid slowdowns. Retention policy:
- 24 hourly
- 7 daily
- 4 weekly
- 6 monthly

## Relationship to System Snapshots

| Feature | System Snapshots (snapper) | NAS Backups (restic) |
|---------|---------------------------|---------------------|
| Scope | System (`/`) | Home (`/home/erik`) |
| Location | Local btrfs | NAS (off-site) |
| Restore | Boot via Limine | Manual restore |
| Use case | System rollback | Data recovery |
