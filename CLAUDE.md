# Omarchy Configuration Repository

Personal configuration for Omarchy (Arch Linux + Hyprland).

## CRITICAL: All Config Changes Go Through This Repo

**NEVER modify system or user config files directly.** All configuration changes must:
1. Be made in this repository first
2. Be synced to the system via Ansible

This ensures all configuration is tracked, reproducible, and can be restored.

## Structure

```
omarchy/
├── ansible/          # Ansible playbooks and roles
│   ├── playbook.yml  # Main playbook (runs everything)
│   └── roles/        # dotfiles, packages, keyd, framework, secrets
├── home/             # Files copied to ~/
├── config/           # Directories copied to ~/.config/
├── system/           # System files copied to / (requires sudo)
│   └── etc/          # Files copied to /etc/
│       └── udev/rules.d/  # udev rules
├── scripts/          # Setup scripts
└── docs/manual/      # Omarchy manual reference
```

## Workflow

**Ansible is the source of truth.** Running ansible MUST always return the machine to the desired state defined in this repo. If something on the system differs from what ansible would deploy, the repo/ansible config needs updating.

1. Edit files in this repo
2. Sync to system using Ansible:

```bash
# Run from any directory using ANSIBLE_CONFIG
ANSIBLE_CONFIG=~/Omarchy/ansible/ansible.cfg ansible-playbook ~/Omarchy/ansible/playbook.yml -l laptop

# Sync specific tags only
ANSIBLE_CONFIG=~/Omarchy/ansible/ansible.cfg ansible-playbook ~/Omarchy/ansible/playbook.yml -l laptop --tags dotfiles
ANSIBLE_CONFIG=~/Omarchy/ansible/ansible.cfg ansible-playbook ~/Omarchy/ansible/playbook.yml -l laptop --tags packages
ANSIBLE_CONFIG=~/Omarchy/ansible/ansible.cfg ansible-playbook ~/Omarchy/ansible/playbook.yml -l laptop --tags keyd
ANSIBLE_CONFIG=~/Omarchy/ansible/ansible.cfg ansible-playbook ~/Omarchy/ansible/playbook.yml -l laptop --tags secrets
```

**Note:** Vault password file must exist at `/home/erik/.vault_pass` (configured in ansible.cfg).

**Iterative debugging:** When testing changes, you can copy files directly to the system (e.g., `sudo cp` for /etc files) without running full ansible. But always update the repo first, and ensure ansible would deploy the same result. You don't need to run all roles - use `--tags` to run only what's needed.

3. Changes go:
   - `home/.foo` → `~/.foo`
   - `config/bar/` → `~/.config/bar/`
   - `system/etc/foo` → `/etc/foo` (with sudo)

## Key Paths on System

- `~/.config/hypr/` - Hyprland config (bindings, input, monitors)
- `~/.config/waybar/` - Status bar
- `~/.config/starship.toml` - Shell prompt
- `~/.config/omarchy/[theme]/` - Theme-specific files
- `/etc/udev/rules.d/` - udev rules (device permissions, etc.)

## Omarchy Basics

- **Super + Space** - App launcher
- **Super + Alt + Space** - Omarchy menu (installs, settings, updates)
- **Super + K** - Show all hotkeys
- **Super + Ctrl + Shift + Space** - Theme switcher
- Updates via menu, not `pacman -Syu` directly

## Home Infrastructure

- **NAS** (192.168.1.10) - Storage server, CIFS shares via autofs at `~/NAS/`
- **Syncthing VM** (192.168.1.12 / syncthing.lan / erikwestlund.ddns.net) - File sync server, backs up to NAS for redundancy

These are separate systems. The `nas` Ansible role handles NAS mounts, `syncthing` role handles sync config.

## Notes

- This is Arch Linux, not macOS
- Config subdirectories have their own CLAUDE.md files for specifics
- Reference `docs/manual/` for Omarchy documentation
