# System Snapshots

## Creating Snapshots

Create a snapshot using:
```bash
omarchy-snapshot create
```

## Booting and Restoring Snapshots

Access and restore snapshots through the Limine bootloader.

## Restoration Scope

- Restores `/root` but not `/home`

## Availability

System snapshots are only available with the Limine bootloader (not GRUB or systemd-boot).
