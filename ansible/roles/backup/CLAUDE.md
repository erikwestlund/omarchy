# Backup Role

Configures automatic home directory backups to NAS using restic.

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│ systemd timer   │────▶│ nas-backup script│────▶│ NAS (restic)    │
│ (per-host sched)│     │ (~/.bin/)        │     │ /SystemSnapshots│
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

## Files Deployed

| Source | Destination | Method |
|--------|-------------|--------|
| `config/systemd/user/nas-backup.timer` | `~/.config/systemd/user/` | Symlink (via dotfiles) |
| `config/systemd/user/nas-backup.service` | `~/.config/systemd/user/` | Symlink (via dotfiles) |
| `home/bin/nas-backup` | `~/.bin/` | Symlink (via dotfiles) |
| `config/restic/excludes.txt` | `~/.config/restic/` | Copy (via this role) |
| - | `~/.config/restic/password` | Generated from vault |
| - | `nas-backup.timer.d/schedule.conf` | Drop-in (host-specific) |
| - | `nas-backup.service.d/environment.conf` | Drop-in (host-specific) |

## Variables

```yaml
# Defaults (roles/backup/defaults/main.yml)
backup_enabled: false
backup_calendar: "hourly"
backup_repository: /mnt/nas/SystemSnapshots
backup_nas_ip: "192.168.1.10"
backup_battery_threshold: 40
backup_ping_timeout: 1
backup_mount_timeout: 10
backup_nice_level: 19
backup_ionice_class: 3
```

Override per-host in `host_vars/desktop.yml` or `host_vars/laptop.yml`.

## Secrets

Requires `restic_password` in `vault/secrets.yml`.

## Script Behavior

The `nas-backup` script checks conditions before running:

1. **Battery check** (laptop only): Skip if below `backup_battery_threshold`
2. **Ping check**: Quick 1s ping to NAS IP, skip if unreachable
3. **Mount check**: Verify CIFS mount accessible via autofs
4. **Run backup**: With `nice`/`ionice` for low priority

All checks exit 0 on skip (not failures) so systemd doesn't mark as failed.

## Cleanup

Cleanup is NOT run on workstations. A separate job on the homelab server runs `restic forget --prune` with retention policy. See `scripts/nas-backup-cleanup.sh`.
