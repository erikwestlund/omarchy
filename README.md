# Omarchy Configuration

Personal configuration for [Omarchy](https://omarchy.com) (Arch Linux + Hyprland).

## Structure

```
omarchy/
├── ansible/              # Ansible playbooks and roles
│   ├── playbook.yml      # Main entry point
│   ├── inventory.yml     # Hosts: laptop, desktop
│   ├── group_vars/       # Shared config (packages, dotfiles lists)
│   ├── host_vars/        # Per-machine settings
│   ├── vault/            # Encrypted secrets
│   └── roles/            # dotfiles, packages, keyd, secrets, etc.
├── home/                 # Files symlinked to ~/
│   ├── .aliases          # Shell aliases
│   ├── .bashrc           # Bash config
│   ├── .bashrc.local     # Machine-local bash config
│   ├── .tmux.conf        # Tmux config
│   ├── .gitconfig        # Git config
│   └── bin/              # Scripts copied to ~/.bin/
├── config/               # Directories synced to ~/.config/
│   ├── hypr/             # Hyprland (bindings, looknfeel, monitors)
│   ├── waybar/           # Status bar
│   ├── starship.toml     # Shell prompt
│   ├── ghostty/          # Terminal
│   ├── vscode/           # VS Code settings
│   └── ...
├── system/               # System files (copied with sudo)
│   └── etc/              # → /etc/
├── projects/             # Project launcher scripts
├── scripts/              # Setup scripts
└── docs/manual/          # Omarchy manual reference
```

## Workflow

**All config changes go through this repo.** Never edit system files directly.

1. Edit files in this repo
2. Run ansible to deploy:

```bash
om                    # Full playbook (uses ~/.machine for target)
om --tags dotfiles    # Just dotfiles
om --tags packages    # Just packages
om --tags keyd        # Just keyboard
om --tags secrets     # Just secrets
```

Or explicitly specify target:

```bash
om-laptop             # Force laptop target
om-desktop            # Force desktop target
```

### How Files Are Deployed

| Source | Destination | Method |
|--------|-------------|--------|
| `home/.foo` | `~/.foo` | Symlink |
| `home/bin/*` | `~/.bin/*` | Copy |
| `config/dir/` | `~/.config/dir/` | Symlink or Copy* |
| `config/starship.toml` | `~/.config/starship.toml` | Symlink |
| `system/etc/*` | `/etc/*` | Copy (sudo) |

*Some config dirs are symlinked, others copied (for ansible templating). See `group_vars/all.yml` for lists.

## Quick Start (New Machine)

```bash
# 1. Clone repo
git clone https://github.com/erikwestlund/omarchy ~/Omarchy

# 2. Install ansible
yay -S ansible
ansible-galaxy collection install community.general

# 3. Set up vault password
echo "your-vault-password" > ~/.vault_pass
chmod 600 ~/.vault_pass

# 4. Identify this machine
echo "laptop" > ~/.machine   # or "desktop"

# 5. Download vault from B2 (see secure notes for B2 creds)
rclone copy :b2,account=$B2_KEY,key=$B2_SECRET:erik-secrets/bootstrap/secrets.yml \
  ~/Omarchy/ansible/vault/

# 6. Run playbook
om

# 7. Switch to SSH remote
git -C ~/Omarchy remote set-url origin git@github.com:erikwestlund/omarchy.git
```

## Key Aliases

After running ansible, these are available:

### Omarchy

| Alias | Action |
|-------|--------|
| `om` | Run full ansible playbook |
| `om --tags X` | Run specific tags (dotfiles, packages, keyd, secrets) |
| `om-laptop` / `om-desktop` | Force target machine |
| `omarchy` / `oma` | cd to ~/Omarchy |

### Git

| Alias | Action |
|-------|--------|
| `s` / `gs` | git status |
| `co` / `gco` | git checkout |
| `ac` | git add . && git commit -am |
| `pushmain` / `pullmain` | push/pull origin main |
| `ghclone user/repo` | Clone from GitHub via SSH |

### Docker

| Alias | Action |
|-------|--------|
| `d` / `dc` | docker / docker compose |
| `dcu` / `dcd` | docker compose up/down |
| `dps` | docker ps |

### Tmux

| Alias | Action |
|-------|--------|
| `tmnew NAME` | tmux new -s NAME |
| `tma NAME` | tmux attach -t NAME |
| `tmls` | tmux ls |

### Secrets

| Alias | Action |
|-------|--------|
| `vault-edit` | Edit ansible vault |
| `secrets-pull` | Pull & decrypt from B2 |
| `secrets-push` | Encrypt & push to B2 |

## Projects

Projects have launcher scripts in `~/Omarchy/projects/{project}/`:

| File | Purpose |
|------|---------|
| `launch` | Open VS Code, start docker, switch workspace |
| `kill` | Stop docker, close windows |
| `tmux.sh` | Launch tmux session |

### Project Aliases

Each project gets aliases based on its short name:

| Pattern | Example (alias: `fw`) |
|---------|----------------------|
| `p{alias}` | `pfw` - launch project |
| `pk{alias}` | `pkfw` - kill project |
| `tm{alias}` | `tmfw` - tmux session |
| `pm{alias}` | `pmfw` - cd to project management dir |
| `{alias}` | `fw` - cd to project code dir |

### Create New Project

```bash
pm-new    # Interactive project scaffolding
```

## Secrets

Secrets are encrypted with age and stored in Backblaze B2. Ansible vault stores B2/age credentials.

```bash
# Pull secrets from B2 to ~/.secrets/
secrets-pull

# Push local changes to B2
secrets-push

# Deploy to system locations (symlinks)
om --tags secrets
```

### What Gets Deployed

| Secret | Destination |
|--------|-------------|
| SSH keys | `~/.ssh` (symlink) |
| AWS creds | `~/.aws` (symlink) |
| GPG keys | Imported to GPG |
| Hosts file | `/etc/hosts` (copy) |

## Framework Laptop

The Framework laptop has keyboard remapping via keyd:

- F1-F12 are default (media keys require Fn)
- Alt and Super are swapped (macOS muscle memory)
- Only affects internal keyboard

```bash
om --tags keyd        # Deploy keyboard config
sudo keyd reload      # Reload after changes
```

## Adding a New Machine

1. Add host to `ansible/inventory.yml`
2. Create `ansible/host_vars/<hostname>.yml`
3. Run: `om-<hostname>` or `om -l <hostname>`

## Useful Shortcuts

| Shortcut | Action |
|----------|--------|
| Super + Space | App launcher |
| Super + Alt + Space | Omarchy menu |
| Super + K | Show all hotkeys |
| Super + Return | Terminal |

## Reference

- [Omarchy Manual](https://learn.omacom.io/2/the-omarchy-manual/91/welcome-to-omarchy)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- See `CLAUDE.md` for AI assistant instructions
