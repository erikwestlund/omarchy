# Omarchy Configuration

Personal configuration for [Omarchy](https://omarchy.com) (Arch Linux + Hyprland).

## Quick Start (First Time Setup)

```bash
# 1. Clone the repo
git clone https://github.com/erikwestlund/omarchy ~/Omarchy
cd ~/Omarchy

# 2. Add to .bashrc (one-time, everything else is managed)
echo '[ -f ~/.bashrc.local ] && source ~/.bashrc.local' >> ~/.bashrc

# 3. Install Ansible (required to run playbook)
yay -S ansible

# 4. Install Ansible collections
ansible-galaxy collection install community.general

# 5. Set up passwordless sudo (required for AUR helpers)
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/nopasswd
sudo chmod 440 /etc/sudoers.d/nopasswd

# 6. Set up vault password
echo "your-secret-password" > ~/.vault_pass
chmod 600 ~/.vault_pass

# 7. Identify this machine (used by om-* aliases)
echo "desktop" > ~/.machine    # or "laptop" for Framework laptop
chmod 600 ~/.machine

# 8. Download vault from B2 and run playbook (see Secrets section)
om    # Uses ~/.machine to determine target
```

After first run, use the aliases:

```bash
source ~/.aliases
om-all          # Run full playbook (uses ~/.machine)
om-config       # Sync dotfiles only
om-packages     # Install packages only
om-webapps      # Install web apps only
om-apps         # Packages + webapps
om-laptop       # Force laptop target
om-desktop      # Force desktop target
```

## Ansible

Configuration is managed via Ansible for idempotency and multi-machine support.

### Structure

```
ansible/
├── playbook.yml          # Main entry point
├── inventory.yml         # Hosts: laptop, desktop
├── ansible.cfg           # Ansible settings
├── requirements.yml      # Required collections
├── group_vars/
│   └── all.yml           # Shared packages and config
├── host_vars/
│   ├── laptop.yml        # Framework laptop settings
│   └── desktop.yml       # Desktop settings
├── vault/
│   └── secrets.yml       # Encrypted secrets (SSH, GPG keys)
└── roles/
    ├── packages/         # pacman + AUR packages
    ├── dotfiles/         # Config sync (~/.config/)
    ├── keyd/             # Keyboard remapping
    ├── framework/        # Framework laptop specifics
    └── secrets/          # Deploy SSH/GPG keys from vault
```

### Usage

```bash
cd ~/Omarchy/ansible

# Full setup
ansible-playbook playbook.yml --limit laptop

# Only packages
ansible-playbook playbook.yml --limit laptop --tags packages

# Only dotfiles
ansible-playbook playbook.yml --limit laptop --tags dotfiles

# Only secrets
ansible-playbook playbook.yml --limit laptop --tags secrets

# Dry run (check mode)
ansible-playbook playbook.yml --limit laptop --check

# Prompt for vault password (if no ~/.vault_pass file)
ansible-playbook playbook.yml --limit laptop --ask-vault-pass
```

### Aliases

After running the playbook once, these aliases are available (reads `~/.machine` for target):

```bash
om-all          # Full playbook
om-config       # Sync dotfiles only
om-packages     # Install packages only
om-webapps      # Install web apps only
om-apps         # Packages + webapps
om-secrets      # Sync secrets only
om-keyd         # Keyboard config only
om-laptop       # Force laptop target
om-desktop      # Force desktop target
ap              # ansible-playbook
```

### Vault (Secrets)

Secrets are encrypted with Ansible Vault and stored in git.

```bash
# Create secrets file from example
cp ansible/vault/secrets.yml.example ansible/vault/secrets.yml

# Edit and add your keys
nano ansible/vault/secrets.yml

# Encrypt it
ansible-vault encrypt ansible/vault/secrets.yml

# Edit encrypted file later
ansible-vault edit ansible/vault/secrets.yml

# View encrypted file
ansible-vault view ansible/vault/secrets.yml
```

### Adding a New Machine

1. Add host to `ansible/inventory.yml`
2. Create `ansible/host_vars/<hostname>.yml`
3. Run: `ansible-playbook playbook.yml --limit <hostname>`

### Legacy Scripts

The bash scripts still work for quick manual operations:

```bash
./bootstrap.sh                    # Sync dotfiles only
./scripts/setup-windows-vm.sh     # Windows VM setup (not in Ansible)
./scripts/secrets-*.sh            # Manual secrets sync (deprecated, use vault)
```

## Default Theme

This config uses [Rainy Night](https://github.com/atif-1402/omarchy-rainynight-theme) as the default theme. It's automatically installed via `post-install.sh`.

## Theme Customizations

Preferences that persist across all themes are set in config files that load AFTER the theme:

| Customization | File | Example |
|---------------|------|---------|
| Borders, gaps, rounding | `config/hypr/looknfeel.conf` | `border_size = 3` |
| Bar fonts, colors | `config/waybar/style.css` | `font-family: 'Inter'` |
| Keybindings | `config/hypr/bindings.conf` | Custom shortcuts |

These files are sourced after the theme, so they override theme defaults.

For post-theme-change scripts, use `config/omarchy/hooks/theme-set` (installed via `post-install.sh`).

## Structure

```
omarchy/
├── ansible/                  # Ansible playbooks and roles
│   ├── playbook.yml          # Main entry point
│   ├── inventory.yml         # Host definitions
│   ├── group_vars/           # Shared variables
│   ├── host_vars/            # Per-host variables
│   ├── vault/                # Encrypted secrets
│   └── roles/                # Ansible roles
├── bootstrap.sh              # Legacy: sync config to system
├── home/                     # Files copied to ~/
│   └── .aliases              # Shell aliases
├── config/                   # Directories copied to ~/.config/
│   ├── hypr/                 # Hyprland config
│   ├── khal/                 # Calendar CLI config
│   ├── vdirsyncer/           # Calendar sync config
│   ├── solaar/               # Logitech device settings
│   └── waybar/               # Waybar config
├── scripts/
│   ├── setup-windows-vm.sh       # Windows VM setup
│   ├── copy-config-to-repo.sh    # Copy file from ~/.config to repo
│   └── secrets-*.sh              # Legacy secrets sync (use vault instead)
└── docs/manual/              # Omarchy manual reference
```

## Bootstrap Options

```bash
# Sync everything
./bootstrap.sh

# Just home files (.aliases, etc.)
./bootstrap.sh --home-only

# Just config files
./bootstrap.sh --config-only

# Only specific items
./bootstrap.sh --only aliases,hypr

# Exclude specific items
./bootstrap.sh --exclude hypr,waybar

# Preview without copying
./bootstrap.sh --dry-run

# Skip git pull
./bootstrap.sh --no-git
```

## Config Sync Scripts

```bash
# Copy a file from system to repo (warns if exists)
./scripts/copy-config-to-repo.sh hypr/bindings.conf

# Push changes to system - just use bootstrap
./bootstrap.sh --only hypr
```

## Secrets Management

Secrets are stored encrypted (age) in Backblaze B2 and deployed via Ansible.

### Architecture

```
Ansible Vault (ansible/vault/secrets.yml)
    └── Contains B2 credentials + age keys (encrypted with vault password)

B2 Bucket (erik-secrets)
    └── Contains actual secrets encrypted with age (SSH, AWS, etc.)

~/.secrets/
    └── Local decrypted secrets (symlinked to ~/.ssh, ~/.aws, etc.)
```

### Vault Template

```yaml
---
# Backblaze B2 credentials
vault_b2_key_id: "your-b2-key-id"
vault_b2_app_key: "your-b2-application-key"
vault_b2_bucket: "your-bucket-name"

# Age encryption key (generate with: age-keygen)
vault_age_secret_key: "AGE-SECRET-KEY-1XXXXXXX..."
vault_age_public_key: "age1xxxxxxx..."
```

### First-Time Setup

```bash
# 1. Create vault with B2/age credentials
cp ansible/vault/secrets.yml.example ansible/vault/secrets.yml
nano ansible/vault/secrets.yml    # Add B2 key ID, app key, bucket, age keys
ansible-vault encrypt ansible/vault/secrets.yml

# 2. Set up vault password file
echo "your-vault-password" > ~/.vault_pass
chmod 600 ~/.vault_pass

# 3. Run secrets role (pulls from B2, deploys to system)
om-secrets
```

### What Gets Deployed

| Secret | Source | Destination | Method |
|--------|--------|-------------|--------|
| SSH keys | `~/.secrets/ssh/` | `~/.ssh` | Symlink |
| AWS credentials | `~/.secrets/aws/` | `~/.aws` | Symlink |
| Rclone config | `~/.secrets/rclone/` | `~/.config/rclone` | Symlink |
| Hosts file | `~/.secrets/hosts` | `/etc/hosts` | Copy |
| GPG keys | `~/.secrets/gpg/` | Imported to GPG | Import |
| Git config | - | `~/.gitconfig` | SSH URL rewrite for GitHub |

### Daily Workflow

```bash
# Edit a secret locally
nano ~/.secrets/hosts              # or ~/.ssh/config, etc.

# Backup to B2
secrets-push

# Deploy to system (if needed, e.g., /etc/hosts)
om-secrets
```

### Commands

| Command | Description |
|---------|-------------|
| `vault-edit` | Edit Ansible vault (B2/age credentials) |
| `vault-push` | Push vault file to B2 (after editing) |
| `secrets-pull` | Pull from B2, decrypt to ~/.secrets |
| `secrets-push` | Encrypt ~/.secrets, push to B2 |
| `om-secrets` | Deploy secrets to system locations |

### B2 Bucket Structure

```
erik-secrets/
├── bootstrap/
│   └── secrets.yml      # Ansible vault (encrypted, for new machine setup)
├── secrets/             # Age-encrypted secrets
│   ├── ssh/
│   │   ├── config.age
│   │   ├── github.age
│   │   ├── erik.age
│   │   └── legacy/
│   ├── aws/
│   │   ├── config.age
│   │   └── credentials.age
│   ├── rclone/
│   │   └── rclone.conf.age
│   └── hosts.age
└── ...
```

### New Machine Bootstrap

The vault file is stored in B2 (not in git). See your secure notes for full bootstrap instructions including B2 credentials.

Quick reference (requires B2 creds from notes):

```bash
# 1. Install tools
yay -S ansible rclone age

# 2. Clone repo via HTTPS
git clone https://github.com/erikwestlund/omarchy ~/Omarchy

# 3. Download vault from B2 (see notes for B2_KEY and B2_SECRET)
rclone copy :b2,account=$B2_KEY,key=$B2_SECRET:erik-secrets/bootstrap/secrets.yml \
  ~/Omarchy/ansible/vault/

# 4. Set up vault password and machine type
echo "your-vault-password" > ~/.vault_pass && chmod 600 ~/.vault_pass
echo "laptop" > ~/.machine    # or "desktop"

# 5. Run playbook
cd ~/Omarchy
ansible-galaxy collection install community.general
ansible-playbook -i ansible/inventory.yml ansible/playbook.yml \
  --vault-password-file ~/.vault_pass --limit laptop

# 6. Switch to SSH and source aliases
git remote set-url origin git@github.com:erikwestlund/omarchy.git
source ~/.aliases
```

## Packages Installed

The `install-packages.sh` script installs:

### Official Repos (pacman)
- Core: coreutils, rsync, rclone, htop, tree, gnupg, wget, curl
- Dev: cmake, imagemagick, ffmpeg, nodejs, npm, jq, socat
- R: r, gcc-fortran
- LaTeX: texlive-basic, texlive-latex, texlive-xetex, etc.
- Apps: firefox, vlc
- Virtualization: libvirt, qemu-full, virt-manager, freerdp, dialog

### AUR (yay)
- Dev: visual-studio-code-bin, claude-code, openai-codex-bin, tableplus, sublime-merge
- Comms: slack-desktop, zoom, teams-for-linux
- R ecosystem: rstudio-desktop-bin, quarto-cli-bin
- Browser: google-chrome
- Research: zotero

### Via Omarchy Menu
- Docker (Install > Development > Docker)
- Tailscale (Install > Service > Tailscale)

## Aliases

Key aliases defined in `home/.aliases`:

```bash
# Navigation
s, gs          # git status
co, gco        # git checkout
ac             # git add . && git commit -am
pushmain       # git push origin main
pullmain       # git pull origin main
ghclone        # ghclone user/repo [dir] - clone from GitHub via SSH

# Docker
d, dc, dcu, dcd, dps

# Omarchy
omarchy        # cd ~/Omarchy
om-laptop      # Run playbook on laptop
om-desktop     # Run playbook on desktop

# Ansible
ap             # ansible-playbook

# Secrets
vault-edit     # Edit Ansible vault
vault-push     # Push vault to B2 after editing
secrets-pull   # Pull & decrypt from B2
secrets-push   # Encrypt & push to B2

# Calendar
calsync        # Sync calendars (vdirsyncer)
cal            # Show calendar view
agenda         # Next 7 days
today          # Today's events
```

## Calendar (khal + vdirsyncer)

CLI calendar that syncs with Google Calendar and Outlook.

### Setup

1. **Google Calendar OAuth credentials:**
   ```bash
   # Go to https://console.cloud.google.com/apis/credentials
   # Create OAuth 2.0 Client ID (Desktop app)
   # Edit config with your credentials:
   nano ~/.config/vdirsyncer/config
   ```

2. **Initialize and discover calendars:**
   ```bash
   mkdir -p ~/.local/share/vdirsyncer/{status,calendars}
   vdirsyncer discover google
   # Follow OAuth flow in browser
   vdirsyncer sync
   ```

3. **Enable auto-sync timer:**
   ```bash
   systemctl --user enable --now vdirsyncer.timer
   ```

### Usage

```bash
khal calendar              # Calendar view
khal list today 7d         # Next 7 days
khal list today today      # Today only
khal new 2025-01-15 10:00 Meeting with Bob  # Add event
```

### Hotkey

Bind to a key in Hyprland for quick agenda popup:

```conf
# In ~/.config/hypr/bindings.conf
bind = , XF86Calculator, exec, ~/.config/hypr/scripts/agenda.sh
```

### Files

| File | Purpose |
|------|---------|
| `config/vdirsyncer/config` | Calendar sync configuration |
| `config/khal/config` | Calendar display settings |
| `config/hypr/scripts/agenda.sh` | Agenda popup script |
| `config/systemd/user/vdirsyncer.*` | Auto-sync timer |

## Framework Laptop Keyboard Setup

On Framework laptops, the top row defaults to media keys (mute, volume, brightness, etc.) with F1-F12 requiring the Fn key. This configuration swaps that behavior so F-keys are default.

### What It Does

- **F1-F12 are default** (no Fn key needed)
- **Fn + F1-F12** triggers media functions (mute, volume, brightness, etc.)
- **Alt and Super are swapped** (for macOS-like muscle memory)
- **Only affects the internal keyboard** — external keyboards are untouched

### Components

1. **keyd** (`/etc/keyd/default.conf`) — swaps keycodes for F1-F8, F11-F12, and Alt/Super
2. **hwdb** (`/etc/udev/hwdb.d/90-framework-toprow.hwdb`) — remaps rfkill (F10) at kernel level since it can't be intercepted by keyd
3. **F9** — sends Super+P from firmware, intercepted by keyd

### Setup

```bash
# Run the keyd setup script
./scripts/setup-keyd.sh

# Run post-install for hwdb (Framework rfkill fix)
./scripts/post-install.sh
```

### Key Mappings

| Physical Key | Default (no Fn) | With Fn |
|--------------|-----------------|---------|
| Mute icon | F1 | Mute |
| Vol Down | F2 | Volume Down |
| Vol Up | F3 | Volume Up |
| Prev Track | F4 | Previous Song |
| Play/Pause | F5 | Play/Pause |
| Next Track | F6 | Next Song |
| Bright Down | F7 | Brightness Down |
| Bright Up | F8 | Brightness Up |
| Display icon | F9 | (Super+P) |
| Airplane | F10 | Airplane Mode |
| Print Screen | F11 | Print Screen |
| Framework | F12 | Media Key |

### Troubleshooting

```bash
# Check keyd status
sudo systemctl status keyd

# Monitor key events (stop keyd first to see raw events)
sudo systemctl stop keyd && sudo keyd -m

# Reload keyd config
sudo keyd reload

# Check hwdb rule
cat /etc/udev/hwdb.d/90-framework-toprow.hwdb

# Reapply hwdb
sudo systemd-hwdb update && sudo udevadm trigger -s input
```

### Technical Notes

- The internal keyboard is device `0001:0001` (AT Translated Set 2 keyboard)
- Media keys come from a separate device `32ac:0006` (FRMW0001:00)
- F10 (rfkill) is handled by the kernel before keyd can intercept, hence the hwdb workaround
- F9 sends `Super+P` from firmware (display toggle), keyd intercepts this combo

## Logitech Keyboard Setup (Bolt)

External Logitech keyboards connected via Bolt USB receivers are also configured for consistent behavior.

### What It Does

- **Alt and Super are swapped** (matches Framework layout)
- **F1-F12 are default** (fn-swap disabled via Solaar)
- **OS mode set to Linux** (prevents hardware-level modifier swapping)

### Setup

```bash
# Install Solaar for Logitech device management
sudo pacman -S solaar

# Run keyd setup (includes Logitech Bolt config)
./scripts/setup-keyd.sh

# Sync Solaar config
./bootstrap.sh
```

### Pairing New Devices

1. Open `solaar` GUI
2. Click on Bolt Receiver → Pair new device
3. Hold device's connect button for 3 seconds
4. After pairing, configure the keyboard:

```bash
solaar config "KEYBOARD_NAME" multiplatform Linux
solaar config "KEYBOARD_NAME" fn-swap false
```

### Configured Devices

| Device | Settings |
|--------|----------|
| MX Keys Mini | multiplatform=Linux, fn-swap=false |
| MX Keys S | multiplatform=Linux, fn-swap=false |

### Files

| File | Purpose |
|------|---------|
| `/etc/keyd/logitech.conf` | Alt/Super swap for Bolt receivers (046d:c548) |
| `config/solaar/config.yaml` | Solaar device settings (synced via bootstrap) |

### Troubleshooting

```bash
# Check if Bolt receiver is detected
lsusb | grep -i logitech

# Show paired devices
solaar show

# Check keyd is matching Logitech devices
journalctl -u keyd | grep -i logitech

# Reload keyd after config changes
sudo keyd reload
```

## Hyprland Workspace Plan

Custom workspace bindings (in `config/hypr/bindings.conf`):

| Shortcut | Action |
|----------|--------|
| F1-F12 | Switch to workspace 1-12 |
| Alt + F1-F12 | Move window to workspace 1-12 |
| Ctrl + F1-F12 | Launch workspace project |
| Super + grave | Toggle utility workspace |
| Alt + h/j/k/l | Move focus (vim-style) |
| Alt + Shift + h/j/k/l | Swap windows |

See `config/hypr/CLAUDE.md` for full workspace implementation plan.

## Post-Install Checklist

1. [ ] Run `./scripts/install-packages.sh`
2. [ ] Run `./bootstrap.sh --home-only` and `source ~/.bashrc`
3. [ ] Run `./scripts/post-install.sh` (theme, hooks)
4. [ ] Run `./scripts/setup-keyd.sh` (keyboard remapping)
5. [ ] Run `./bootstrap.sh` to sync config (including Solaar settings)
6. [ ] Run `secrets-setup` and `secrets-pull`
7. [ ] Pair Logitech keyboards in Solaar if needed
8. [ ] Install Docker via Omarchy menu (Super + Alt + Space > Install > Development > Docker)
9. [ ] Install Tailscale via Omarchy menu if needed
10. [ ] Sign in to 1Password, Slack, Zoom, Teams
11. [ ] Configure VS Code settings sync
12. [ ] Test aliases: `s`, `bootomarchy`, etc.

## Useful Omarchy Shortcuts

| Shortcut | Action |
|----------|--------|
| Super + Space | App launcher |
| Super + Alt + Space | Omarchy menu |
| Super + K | Show all hotkeys |
| Super + Return | Terminal |
| Super + Shift + B | Browser |
| Super + Shift + D | Lazydocker |
| Super + Shift + T | btop |

## Windows VM (WinApps)

Run Windows applications seamlessly on Linux via RDP RemoteApp.

### Setup

```bash
./scripts/setup-windows-vm.sh
```

This installs libvirt, QEMU, virt-manager, FreeRDP, and creates a Windows 11 VM.

### Windows Installation

1. **Log out and back in** (for libvirt group membership)

2. **Start the VM and open virt-manager:**
   ```bash
   virsh -c qemu:///system start RDPWindows
   virt-manager --connect qemu:///system --show-domain-console RDPWindows
   ```

3. **During Windows setup - bypass internet requirement:**
   - Press `Shift + F10` to open command prompt
   - Type: `OOBE\BYPASSNRO` and press Enter
   - System reboots, then click "I don't have internet"
   - Click "Continue with limited setup"

4. **Create a local account with a PASSWORD** (RDP requires a password)

5. **After reaching desktop, install VirtIO drivers:**
   - Open File Explorer
   - Navigate to the VirtIO CD drive (~/ISOs/virtio-win.iso should be attached)
   - Run `virtio-win-gt-x64.msi` to install all drivers
   - If CD not attached: In virt-manager, View → Details → Add Hardware → Storage → CDROM → browse to `~/ISOs/virtio-win.iso`

6. **Configure static IP (if DHCP doesn't work):**
   - Settings → Network & Internet → Ethernet → Edit IP assignment
   - Set to Manual, enable IPv4:
     - IP: `192.168.122.50`
     - Subnet: `255.255.255.0`
     - Gateway: `192.168.122.1`
     - DNS: `8.8.8.8`

7. **Enable Remote Desktop:**
   - Settings → System → Remote Desktop → On

8. **(Optional) Set up auto-login:**
   - Run `netplwiz` → uncheck "Users must enter a username" → enter password

9. **(Optional) Debloat Windows:**
   ```powershell
   # PowerShell (Admin)
   irm christitus.com/win | iex
   ```

10. **(Optional) Install Office:**
    ```powershell
    # Install Chocolatey first
    Set-ExecutionPolicy Bypass -Scope Process -Force
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    # Install Office
    choco install microsoft-office-deployment -y
    ```

11. **Update WinApps config with your credentials:**
    ```bash
    nano ~/.config/winapps/winapps.conf
    ```
    Set `RDP_USER` and `RDP_PASS` to your Windows username/password.

12. **Install WinApps:**
    ```bash
    cd /tmp && git clone https://github.com/winapps-org/winapps.git
    cd winapps && ./setup.sh --user
    ```
    Select: **libvirt** → **Pre-existing** → **RDPWindows**

### Usage

```bash
windows    # Full Windows desktop
explorer   # File Explorer
word       # Microsoft Word
excel      # Microsoft Excel
outlook    # Microsoft Outlook
powershell # PowerShell
```

### Hyprland Window Rules

FreeRDP windows are configured to float (not tile) at 1600x1000, centered. See `config/hypr/looknfeel.conf`.

### Troubleshooting

**VM has no network:**
```bash
# Check if UFW is blocking (run these if needed)
sudo ufw allow in on virbr0
sudo ufw allow out on virbr0
sudo ufw route allow in on virbr0
sudo ufw route allow out on virbr0

# Restart libvirtd (fixes bridge not attaching VM interface)
sudo systemctl restart libvirtd

# Then restart the VM
virsh -c qemu:///system destroy RDPWindows
virsh -c qemu:///system start RDPWindows

# Or restart just the virtual network
virsh -c qemu:///system net-destroy default
virsh -c qemu:///system net-start default
```

**Check if VM interface is on bridge:**
```bash
brctl show virbr0  # Should list vnet0 or vnet1 under interfaces
```

**RDP grabs keyboard/mouse:**
The config includes `/grab-keyboard:off /grab-mouse:off` flags. If still grabbing, check `~/.config/winapps/winapps.conf`.

**Can't see RDP window:**
Hyprland window rules should float it. Check if it's on another workspace. Try `Super + Tab` to see all windows.

**VM Configuration:**
- RAM: 12GB
- CPUs: 4
- Disk: 64GB
- Static IP: 192.168.122.50

### Files

| File | Purpose |
|------|---------|
| `scripts/setup-windows-vm.sh` | Setup script |
| `~/.config/winapps/winapps.conf` | WinApps credentials and settings |
| `~/ISOs/Win11.iso` | Windows 11 ISO |
| `~/ISOs/virtio-win.iso` | VirtIO guest drivers |
| `config/hypr/looknfeel.conf` | FreeRDP window rules |

## Tmux

Tmux is configured with sensible defaults in `home/.tmux.conf`.

### Configuration

| Setting | Value | Why |
|---------|-------|-----|
| `base-index` | 1 | Windows start at 1 (easier to reach than 0) |
| `pane-base-index` | 1 | Panes also start at 1 |
| `renumber-windows` | on | Closing a window renumbers remaining |
| `history-limit` | 10000 | Larger scrollback buffer |
| `mouse` | on | Mouse support enabled |
| `escape-time` | 0 | No delay for escape key |

Reload config with `prefix + r`.

## Project Management

Projects use a consistent structure for launching dev environments.

### Structure

```
~/ProjectManagement/
└── {project}/
    └── tmux.sh          # Tmux session launcher

~/Projects/
└── {project}/           # Actual project code
```

### Aliases

| Alias | Action |
|-------|--------|
| `tm{alias}` | Launch/attach tmux session |
| `pm{alias}` | cd to ~/ProjectManagement/{project} |

Example: `tmom` launches Omarchy tmux, `pmom` goes to its management dir.

### Tmux Script Pattern

Scripts use auto-incrementing `TABNO` for easy reordering:

```bash
#!/bin/bash
SESSION="myproject"
PROJECT_DIR="$HOME/Projects/myproject"

tmux has-session -t $SESSION 2>/dev/null
if [ $? = 0 ]; then
    tmux attach-session -t $SESSION
    exit 0
fi

TABNO=1

# --- zsh ---
tmux new-session -d -s $SESSION -n "zsh" -c "$PROJECT_DIR"
TABNO=$((TABNO+1))

# --- claude-o ---
tmux new-window -t $SESSION:$TABNO -n "claude-o" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "claude --model opus" C-m
TABNO=$((TABNO+1))

# --- claude-s ---
tmux new-window -t $SESSION:$TABNO -n "claude-s" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION:$TABNO "claude --model sonnet" C-m
TABNO=$((TABNO+1))

# ... more windows ...

tmux select-window -t $SESSION:1
tmux attach-session -t $SESSION
```

To reorder windows, just cut/paste the blocks - TABNO auto-increments.

### Current Projects

| Project | Alias | Path |
|---------|-------|------|
| Omarchy | om | ~/Omarchy |

## Reference

- [Omarchy Manual](https://learn.omacom.io/2/the-omarchy-manual/91/welcome-to-omarchy)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [WinApps GitHub](https://github.com/winapps-org/winapps)
- Local docs: `docs/manual/`
