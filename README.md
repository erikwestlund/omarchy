# Omarchy Configuration

Personal configuration for [Omarchy](https://omarchy.org) (Arch Linux + Hyprland).

## Quick Start (New Machine)

```bash
# 1. Clone repo
git clone https://github.com/erikwestlund/omarchy ~/Omarchy

# 2. Install ansible and rclone
yay -S ansible rclone
ansible-galaxy collection install community.general kewlfft.aur

# 3. Set up vault password
echo "your-vault-password" > ~/.vault_pass
chmod 600 ~/.vault_pass

# 4. Identify this machine
echo "laptop" > ~/.machine   # or "desktop"

# 5. Download vault from B2 (see secure notes for B2 creds)
rclone copy :b2,account=$B2_KEY,key=$B2_SECRET:erik-secrets/bootstrap/secrets.yml \
  ~/Omarchy/ansible/vault/

# 6. Run playbook (aliases not available yet, use full command)
# -K prompts for sudo password
ANSIBLE_CONFIG=~/Omarchy/ansible/ansible.cfg ansible-playbook ~/Omarchy/ansible/playbook.yml -l laptop -K  # or desktop

# 7. Switch to SSH remote
git -C ~/Omarchy remote set-url origin git@github.com:erikwestlund/omarchy.git

# 8. Load SSH key (deployed by secrets role in step 6)
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519

# 9. Reload shell to get aliases, then use 'om' for future runs
exec bash
```

## Machines

Machines are defined in `ansible/inventory.yml` with per-machine config in `ansible/host_vars/`:

| Machine | File | Description |
|---------|------|-------------|
| laptop | `host_vars/laptop.yml` | Framework laptop |
| desktop | `host_vars/desktop.yml` | Desktop workstation |

The `~/.machine` file determines which host ansible targets when using `om`.

### Key Differences

| Setting | Laptop | Desktop |
|---------|--------|---------|
| `split_windows` | true (small screen) | false (big screen) |
| `show_battery` | true | - |
| `keyboards` | framework, logitech, logitech-bluetooth | logitech |
| `is_framework` | true | false |
| `cpu_governor` | power-profiles-daemon | performance |
| `hypr_gaps_in` | 2 | 3 |
| `hypr_gaps_out` | 4 | 6 |
| `hypr_rounding` | 16 | 12 |
| `snapper_enabled` | false | true |

Host vars also control: waybar styling, Windows VM RDP settings, extra packages.

## Structure

```
omarchy/
├── ansible/              # Ansible playbooks and roles
│   ├── playbook.yml      # Main entry point
│   ├── windows-vm.yml    # Optional Windows VM setup
│   ├── inventory.yml     # Hosts: laptop, desktop, minio-dev
│   ├── group_vars/       # Shared config (packages, dotfiles lists)
│   ├── host_vars/        # Per-machine settings
│   ├── vault/            # Encrypted secrets (ansible-vault)
│   └── roles/            # dotfiles, packages, keyd, secrets, nas, syncthing, etc.
├── home/                 # Files symlinked to ~/
│   ├── .aliases          # Shell aliases (includes project shortcuts)
│   ├── .bashrc           # Bash config
│   ├── .bashrc.local     # Machine-local bash config
│   ├── .tmux.conf        # Tmux config
│   ├── .gitconfig        # Git config
│   ├── .cheatsheet       # Personal cheatsheet
│   └── bin/              # Scripts copied to ~/.bin/
├── config/               # Directories synced to ~/.config/
│   ├── hypr/             # Hyprland (bindings, looknfeel, monitors)
│   ├── waybar/           # Status bar
│   ├── starship.toml     # Shell prompt
│   ├── ghostty/          # Terminal
│   ├── vscode/           # VS Code settings
│   ├── positron/         # Positron IDE settings
│   ├── omarchy/          # Omarchy theme config
│   └── ...
├── local/                # Local data (icons, etc.)
├── system/               # System files (copied with sudo)
│   └── etc/              # → /etc/
├── projects/             # Project launcher scripts
├── scripts/              # Setup/utility scripts
├── docs/manual/          # Omarchy manual reference
└── bootstrap.sh          # Initial setup script
```

## Applications

Packages and apps managed by ansible. See `ansible/group_vars/all.yml` for full lists.

### Installed via Pacman

| Category | Packages |
|----------|----------|
| Core | coreutils, findutils, grep, sed, rsync, rclone, age, htop, iotop, tree, openssh, gnupg, wget, curl |
| Archive | p7zip, pigz |
| Network | iperf3, lynx, tailscale, syncthing, openconnect, webkit2gtk |
| Hardware | bolt, fwupd, lm_sensors, nvme-cli |
| Development | cmake, pkg-config, imagemagick, ffmpeg, yt-dlp, python-pip, nodejs, npm, jq, socat |
| Shell | zsh, tmux |
| Fonts | inter-font, ttf-font-awesome, ttf-jetbrains-mono |
| Git | git-lfs |
| R/Stats | r, gcc-fortran |
| LaTeX | texlive-basic, texlive-latex, texlive-latexrecommended, texlive-latexextra, texlive-fontsrecommended, texlive-xetex, texlive-bibtexextra |
| Browsers | firefox |
| Media | vlc, isoimagewriter |
| Gaming | steam, lutris, gnutls, lib32-gnutls |
| Desktop | flameshot, cliphist, wl-clipboard, wtype, bluez-utils, darkman, geoclue, wev |
| Virtualization | libvirt, qemu-full, virt-manager, virt-viewer, dnsmasq, bridge-utils, edk2-ovmf, swtpm, freerdp, remmina, libvncserver, openbsd-netcat |

### Installed via AUR

| Category | Packages |
|----------|----------|
| Dev Tools | sublime-text-4, visual-studio-code-bin, openai-codex, opencode-bin, stripe-cli, nvm, nodejs-nodemon, nodejs-vite, tableplus, beekeeper-studio-bin, sublime-merge, insomnia-bin, ansible, doctl-bin |
| Communication | slack-desktop, zoom, bluebubbles-bin |
| R Ecosystem | rstudio-desktop-bin, quarto-cli-bin, positron-ide-devel-bin |
| Research | zotero |
| Hyprland | hyprswitch |
| Calendar | morgen-bin, gcalcli |
| Benchmarking | geekbench |
| VPN | pulse-secure, piavpn-bin |
| Remote | icaclient |
| Email | fastmail |
| Office | onlyoffice-bin |

### Web Apps

Installed as Chromium desktop entries: Outlook, Outlook Calendar (Day/Week views), Word, Excel, PowerPoint, Teams, Claude, Plex

### Removed (Omarchy defaults we don't use)

**Packages**: alacritty, kdenlive, signal-desktop, xournalpp

**Web apps**: Figma, Fizzy, Google Contacts, Google Messages, Google Photos, Google Maps, HEY, WhatsApp, X

## Waybar

The status bar at the top of the screen. Config in `config/waybar/`.

### Files

| File | Purpose |
|------|---------|
| `config.jsonc` | Module layout and behavior |
| `style.css` | Styling |
| `scripts/` | Custom module scripts |

### Layout

The config defines two bar profiles:
- **external** - for external monitors (DP-*, HDMI-*)
- **laptop** - for built-in display (eDP-1)

Each bar has three sections:
- **Left**: Workspace indicators (U, 1-12)
- **Center**: Media player, update indicator, screen recording
- **Right**: VPN, tailscale, tray, tmux, bluetooth, network, audio, CPU, battery, dark mode, weather, clock

### Workspace Indicators

Each workspace (U, 1-12) has its own module that shows:
- Window count in that workspace
- Visual indicator when workspace is active
- Click to switch to that workspace

The workspace script (`scripts/workspace.sh`) queries Hyprland for window counts.

### Custom Modules

| Module | Script | Purpose |
|--------|--------|---------|
| `custom/darkman` | `darkman.sh` | Light/dark mode toggle |
| `custom/weather` | `weather.sh` | Weather display |
| `custom/media` | `media.sh` | Now playing info |
| `custom/vpn` | `vpn.sh` | JHU VPN status |
| `custom/tailscale` | `tailscale.sh` | Tailscale status |
| `custom/pia` | `pia.sh` | PIA VPN status |
| `custom/tmux` | `tmux.sh` | Active tmux sessions |
| `custom/workspace` | `workspace.sh` | Workspace window counts |

### Host-Specific Styling

Ansible deploys `waybar-host.css` with per-machine values from `host_vars/`:
- Font sizes
- Margins and padding
- Border radius

## Light/Dark Mode

Uses [darkman](https://darkman.whynothugo.nl/) for GTK theme switching.

### Configuration

Darkman is configured for **manual mode only** - it won't auto-switch at sunrise/sunset. Toggle manually via the waybar widget or command line.

Config in `config/darkman/config.yaml`:
```yaml
usegeoclue: false    # Disables automatic switching
portal: true         # Exposes mode to apps via XDG portal
dbusserver: true     # Required for toggle command
```

### Usage

- **Click waybar widget** - Toggle between light/dark
- `darkman set light` - Set light mode
- `darkman set dark` - Set dark mode
- `darkman toggle` - Toggle current mode
- `darkman get` - Print current mode

### What Changes

When mode changes, darkman runs scripts in `~/.local/share/darkman/`:
- `gtk-theme.sh` - Sets GTK theme (Adwaita/Adwaita-dark) and color-scheme preference

Apps that respect the XDG portal color-scheme setting will follow automatically.

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
| `home/bin/*` | `~/.bin/*` | Copy (mode 0755) |
| `config/dir/` | `~/.config/dir/` | Symlink or Copy* |
| `config/starship.toml` | `~/.config/starship.toml` | Symlink |
| `system/etc/*` | `/etc/*` | Copy (sudo) |

*Config dirs are either symlinked or copied depending on whether ansible processing is needed:

**Symlinked** (no processing): darkman, elephant, ghostty, omarchy, projects, systemd, wireplumber, xdg-desktop-portal

**Copied** (templates/mode changes): hypr, waybar

**Special handling**: vscode, positron (managed by vscode role)

## Key Aliases

After running ansible, these are available (defined in `home/.aliases`):

### Omarchy

| Alias | Action |
|-------|--------|
| `om` | Run full ansible playbook |
| `om --tags X` | Run specific tags (dotfiles, packages, keyd, secrets, webapps, vscode) |
| `om-laptop` / `om-desktop` | Force target machine |
| `om-config` | Shortcut for `om --tags dotfiles` |
| `om-packages` | Shortcut for `om --tags packages` |
| `om-apps` | Shortcut for `om --tags packages,webapps` |
| `omarchy` / `oma` | cd to ~/Omarchy |

### Git

| Alias | Action |
|-------|--------|
| `s` / `gs` | git status |
| `co` / `gco` | git checkout |
| `ac` | git add . && git commit -am |
| `pushmain` / `pullmain` | push/pull origin main |
| `ghclone user/repo` | Clone from GitHub via SSH |
| `wippush` | git add . && commit "wip" && push |

### Docker

| Alias | Action |
|-------|--------|
| `d` / `dc` | docker / docker compose |
| `dcu` / `dcd` | docker compose up/down |
| `dps` / `dpsa` | docker ps / docker ps -a |

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

### VS Code

| Alias | Action |
|-------|--------|
| `vspush` | Push local VS Code settings to repo |
| `vspull` | Pull repo VS Code settings to local |
| `vscode-sync` | Deploy VS Code settings via ansible |

### Windows VM

| Alias | Action |
|-------|--------|
| `win-spice` | Connect to Windows VM via SPICE (for setup) |
| `windows` | Launch Windows VM via RDP (daily use) |

## Projects

Projects have launcher scripts in `~/Omarchy/projects/{project}/`:

| File | Purpose |
|------|---------|
| `launch` | Open VS Code/Positron, start docker, switch workspace |
| `kill` | Stop docker, close windows |
| `tmux.sh` | Launch tmux session |
| `bootstrap` | One-time project setup (clone, install deps) |
| `*.code-workspace` | VS Code workspace file |

### Project Aliases

Each project gets aliases based on its short name (defined in `home/.aliases`):

| Pattern | Example (alias: `fw`) |
|---------|----------------------|
| `l{alias}` | `lfw` - launch project |
| `k{alias}` | `kfw` - kill project |
| `tm{alias}` | `tmfw` - tmux session |
| `b{alias}` | `bfw` - bootstrap project |
| `pm{alias}` | `pmfw` - cd to project management dir |
| `vs{alias}` | `vsfw` - open in VS Code |
| `nv{alias}` | `nvfw` - open in NeoVim |
| `p{alias}` | `pfw` - open in Positron (if applicable) |
| `d{alias}` | `dfw` - docker compose up (if applicable) |
| `dd{alias}` | `ddfw` - docker compose down (if applicable) |
| `{alias}` | `fw` - cd to project code dir |

### Create/Remove Projects

```bash
pm-new      # Interactive project scaffolding
pm-remove   # Remove project and aliases
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
| GitHub PAT | Docker login to ghcr.io |

### Vault Variables

The ansible vault (`ansible/vault/secrets.yml`) must contain these secrets:

```yaml
# B2 storage (for secrets backup)
b2_key_id: "..."
b2_app_key: "..."
b2_bucket: "..."

# Age encryption
age_secret_key: "AGE-SECRET-KEY-..."
age_public_key: "age1..."

# NAS credentials
nas_erik_username: "..."
nas_erik_password: "..."

# GitHub Container Registry (optional - for pulling private images)
github_username: "your-github-username"
github_pat: "ghp_..."  # needs read:packages scope
```

Edit the vault with:
```bash
vault-edit
```

## Framework Laptop

The Framework laptop has keyboard remapping via keyd:

- F1-F12 are default (media keys require Fn)
- Alt and Super are swapped (macOS muscle memory)
- Only affects internal keyboard

```bash
om --tags keyd        # Deploy keyboard config
sudo keyd reload      # Reload after changes
```

## Windows VM (Optional)

A Windows 11 VM using libvirt/QEMU. Not part of the default Omarchy setup.

### 1. Copy ISO

```bash
sudo cp /mnt/nas/ISOs/win-11-min.iso /var/lib/libvirt/images/
sudo chown libvirt-qemu:libvirt-qemu /var/lib/libvirt/images/win-11-min.iso
```

### 2. Create VM

```bash
ANSIBLE_CONFIG=~/Omarchy/ansible/ansible.cfg \
  ansible-playbook ~/Omarchy/ansible/windows-vm.yml -l desktop -K  # or laptop
```

### 3. Install Windows

Connect via SPICE for initial installation:

```bash
win-spice   # or: virt-viewer --connect qemu:///system win11
```

- **Be patient** - there will be delays during installation
- When Windows restarts, relaunch `win-spice` to reconnect
- If prompted for drivers: storage is in `viostor`, network is in `netkvm`

### 4. Enable Remote Desktop in Windows

In Windows: **Settings > System > Remote Desktop** → Enable

This is required for the "Windows" launcher to work.

### 5. Configure RDP Credentials

Add your Windows password to the vault:

```bash
vault-edit
```

Add:
```yaml
windows_vm_user: "your-windows-username"
windows_vm_password: "your-windows-password"
```

Re-run the playbook to deploy credentials:

```bash
ANSIBLE_CONFIG=~/Omarchy/ansible/ansible.cfg \
  ansible-playbook ~/Omarchy/ansible/windows-vm.yml -l desktop -K
```

### 6. Launch via RDP

Use the "Windows" app from the launcher, or:

```bash
~/.bin/windows
```

This connects via RDP with auto-resize support.

### Optional: RDP Settings

Configure resolution/scaling in `host_vars/desktop.yml`:

```yaml
windows_vm_resolution: "1920x1080"
windows_vm_scale: "100"  # 200 for HiDPI
```

## Adding a New Machine

1. Add host to `ansible/inventory.yml`
2. Create `ansible/host_vars/<hostname>.yml` (copy from existing)
3. Run: `om -l <hostname>`

## Useful Shortcuts

| Shortcut | Action |
|----------|--------|
| Super + Space | App launcher |
| Super + Alt + Space | Omarchy menu |
| Super + K | Show all hotkeys |
| Super + Return | Terminal |

## Troubleshooting

### Black Screen / Broken Lock Screen After Laptop Suspend

**Symptom**: After resuming from suspend, the lock screen is broken or you see a black screen requiring a hard reboot.

**Cause**: The display stack isn't fully ready when hyprlock/hypridle tries to interact with it after resume. This is a known issue with Hyprland on some hardware.

**Fix**: A delay is added after resume before turning on DPMS. Configured in `ansible/host_vars/laptop.yml`:

```yaml
hypridle_after_sleep_delay: 1  # seconds to wait after resume
```

This deploys a custom `~/.config/hypr/hypridle.conf` with:
```
after_sleep_cmd = sleep 1 && hyprctl dispatch dpms on
```

**To adjust**: Increase the delay value if issues persist (try 2).

**To revert**: Set `hypridle_after_sleep_delay: 0` in `host_vars/laptop.yml` and re-run `om --tags dotfiles`, or delete `~/.config/hypr/hypridle.conf`.

**References**:
- https://github.com/basecamp/omarchy/issues/3293
- https://github.com/basecamp/omarchy/issues/1147

### Escape Sequences Appearing in Tmux

**Symptom**: Raw escape codes like `]10;rgb:a9a9/b1b1/d6d6` or `]11;rgb:1a1a/1b1b/2626` appear when attaching to tmux or after switching focus.

**Cause**: Tmux's `escape-time` set too low (especially 0) causes it to timeout before receiving terminal responses to capability queries (OSC 10/11 color queries, device attributes). These responses then leak as visible text.

**Fix**: Set `escape-time` to at least 50ms in `home/.tmux.conf`:

```tmux
set -s escape-time 50
```

Then reload:
```bash
tmux source-file ~/.tmux.conf
```

**Why it happens**:
- Applications (like Starship) query terminal colors during initialization
- With `escape-time 0`, tmux gives up immediately waiting for responses
- Terminal responses arrive "too late" and display as raw text
- 50ms provides enough time while remaining responsive for Escape key detection

**References**:
- [OSC terminal color query leak issue](https://github.com/anthropics/claude-code/issues/12910)
- [Tmux escape sequence timing problem](https://github.com/PowerShell/Win32-OpenSSH/issues/2275)

## Reference

- [Omarchy Website](https://omarchy.org)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- Local docs in `docs/manual/`
- See `CLAUDE.md` for AI assistant instructions
