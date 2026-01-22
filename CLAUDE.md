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
│   ├── playbook.yml  # Main entry point
│   ├── windows-vm.yml # Optional Windows VM setup
│   ├── inventory.yml # Hosts: laptop, desktop, minio-dev
│   ├── group_vars/   # Shared config (packages, dotfile lists)
│   ├── host_vars/    # Per-machine settings (laptop.yml, desktop.yml)
│   ├── vault/        # Encrypted secrets (ansible-vault)
│   └── roles/        # dotfiles, packages, keyd, secrets, nas, syncthing, etc.
├── home/             # Dotfiles symlinked to ~/
├── config/           # Config dirs/files → ~/.config/ (symlink or copy)
├── local/            # Local data (icons, etc.)
├── system/           # System files copied to / (requires sudo)
├── projects/         # Project launcher scripts
├── scripts/          # Setup/utility scripts
└── docs/manual/      # Omarchy manual reference
```

## Symlink vs Copy Rules

**Rule: Symlink everything possible. Copy only when ansible processing is required.**

| Method | When to use |
|--------|-------------|
| **Symlink** | No ansible processing needed beyond creating the link |
| **Copy** | Ansible must process the file (templates, mode changes, in-place modifications) |

### Currently Symlinked
- `home/` dotfiles → `~/` (defined in `home_dotfiles` variable)
- `config/` directories in `config_dirs_symlink`: darkman, elephant, ghostty, omarchy, projects, systemd, wireplumber, xdg-desktop-portal
- `config/starship.toml` → `~/.config/starship.toml`

### Currently Copied (require ansible processing)
- `config/` directories in `config_dirs_copy`: hypr, waybar (templates, mode changes)
- `config/vscode/`, `config/positron/` - managed by vscode role
- `home/bin/` → `~/.bin/` - needs mode 0755
- `system/` - needs sudo, different ownership

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

**Iterative debugging:** For symlinked files, edits in the repo are immediately live on the system - no ansible run needed. For copied files, you can copy directly to the system (e.g., `sudo cp` for /etc files) without running full ansible. Always update the repo first, and ensure ansible would deploy the same result. Use `--tags` to run only what's needed.

3. Changes go:
   - `home/.foo` → `~/.foo` (symlink)
   - `config/bar/` → `~/.config/bar/` (symlink or copy depending on processing needs)
   - `system/etc/foo` → `/etc/foo` (copy with sudo)

## Key Paths on System

- `~/.config/hypr/` - Hyprland config (bindings, input, monitors)
- `~/.config/waybar/` - Status bar
- `~/.config/starship.toml` - Shell prompt
- `~/.config/omarchy/[theme]/` - Theme-specific files
- `/etc/udev/rules.d/` - udev rules (device permissions, etc.)

## Keybindings

Keybindings come from multiple sources and are merged at runtime:

| Source | Location | Description |
|--------|----------|-------------|
| **Omarchy base** | `/usr/share/omarchy/hypr/` | Default Omarchy bindings (read-only, from package) |
| **This repo** | `config/hypr/bindings.conf` | Personal overrides and additions |
| **Omarchy scripts** | `/usr/share/omarchy/bin/` | Scripts referenced by base bindings |
| **Personal scripts** | `home/bin/` | Custom scripts for bindings |

### Resolving Active Bindings

To see all active bindings at runtime:
```bash
hyprctl binds                    # All bindings with details
hyprctl binds | grep -i "key"    # Search for specific key
Alt+K                            # Opens hotkey viewer (GUI)
```

### Adding/Modifying Bindings

1. Check if binding exists in Omarchy base (`/usr/share/omarchy/hypr/`)
2. Override or add in `config/hypr/bindings.conf`
3. Use `hyprctl reload` to apply changes (or they auto-apply for symlinked files)

### Cheatsheet

Personal quick-reference: `home/.cheatsheet` (view with `Super+Alt+H`)

## Omarchy Basics

- **Super + Space** - App launcher
- **Super + Alt + Space** - Omarchy menu (installs, settings, updates)
- **Super + K** - Show all hotkeys
- **Super + Ctrl + Shift + Space** - Theme switcher
- Updates via menu, not `pacman -Syu` directly

## Home Infrastructure

- **NAS** (nas.lan) - Storage server, CIFS shares via autofs at `/mnt/nas/`
- **Syncthing** (syncthing.lan) - File sync server, backs up to NAS for redundancy

The `nas` Ansible role handles NAS mounts, `syncthing` role handles sync config.

## Optional Heavy Packages

Some packages are excluded from the default install because they compile from source and take a long time. These are available as opt-in roles.

### V8 (for R packages like ggdag)

The `v8-r` AUR package provides Google's V8 JavaScript engine, required by R packages that embed JavaScript (e.g., `ggdag` via `dagitty`). It compiles from source and takes 30+ minutes.

**Not installed by default.** To install:

```bash
om-v8   # or: om --tags v8 -e install_v8=true
```

After installing, you can use R packages that depend on V8:
```r
install.packages("V8")
install.packages("ggdag")
```

## Notes

- This is Arch Linux, not macOS
- Config subdirectories have their own CLAUDE.md files for specifics
- Reference `docs/manual/` for Omarchy documentation
