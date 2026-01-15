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
│   ├── playbook.yml      # Main entry point (workstations)
│   ├── restic-server.yml # Restic backup server (Proxmox VM)
│   ├── windows-vm.yml    # Optional Windows VM setup
│   ├── inventory.yml     # Hosts: laptop, desktop, restic, hatchery
│   ├── group_vars/       # Shared config (packages, dotfiles lists)
│   ├── host_vars/        # Per-machine settings
│   ├── vault/            # Encrypted secrets (ansible-vault)
│   └── roles/            # dotfiles, packages, keyd, proxmox-vm, etc.
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
└── docs/manual/          # Omarchy manual reference
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

Status bar config in `config/waybar/`. Files: `config.jsonc` (modules), `style.css` (styling), `scripts/` (custom modules).

### Layout

- **Left**: Workspace indicators (U, 1-12) with window counts
- **Center**: Media player, update indicator
- **Right**: VPN, tray, tmux, bluetooth, network, audio, CPU, battery (laptop only), dark mode, weather, clock

### Custom Scripts

| Script | Purpose |
|--------|---------|
| `workspace.sh` | Workspace window counts |
| `darkman.sh` | Light/dark mode indicator |
| `weather.sh` | Weather display |
| `vpn.sh` / `tailscale.sh` / `pia.sh` | VPN status |
| `tmux.sh` | Active tmux sessions |

### Host-Specific Changes

Ansible modifies the deployed config per machine:
- **Laptop**: Adds battery module
- **Desktop**: Adds extra CPU icon spacing (no battery)
- **Both**: Applies margins/height from `host_vars/`, deploys `waybar-host.css` with font sizes

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

## Aliases

After running ansible, these are available (defined in `home/.aliases`):

### Navigation

| Alias | Action |
|-------|--------|
| `..` / `...` / `....` | Go up 1/2/3 directories |
| `~` | cd to home |
| `-` | cd to previous directory |
| `dl` / `dt` | cd to Downloads / Desktop |
| `p` / `projects` | cd to ~/Projects |
| `pm` | cd to ~/Omarchy/projects |

### Omarchy

| Alias | Action |
|-------|--------|
| `om` | Run full ansible playbook |
| `om --tags X` | Run specific tags |
| `om-laptop` / `om-desktop` | Force target machine |
| `om-dotfiles` / `om-config` | Deploy dotfiles |
| `om-packages` | Deploy packages |
| `om-apps` / `om-software` | Deploy packages + webapps |
| `om-webapps` | Deploy webapps only |
| `om-secrets` | Deploy secrets |
| `om-keyd` | Deploy keyboard config |
| `om-vscode` | Deploy VS Code settings |
| `om-vscode-ext` | Deploy VS Code + install extensions |
| `om-framework` | Deploy Framework laptop config |
| `om-nas` | Deploy NAS mounts |
| `om-syncthing` | Deploy Syncthing config |
| `om-sshd` | Deploy SSH server config |
| `om-printer` | Deploy printer config |
| `om-chromium` | Deploy Chromium config |
| `om-snapper` | Deploy Snapper snapshots |
| `om-cleanup` | Run cleanup tasks |
| `om-remotes` | Deploy remote configs |
| `om-dnsmasq` | Deploy dnsmasq |
| `om-caddy` | Deploy Caddy |
| `om-vpn` | Deploy VPN config |
| `om-gpu` | Deploy GPU config |
| `om-openrgb` | Deploy OpenRGB |
| `om-sync` | Git pull && push Omarchy repo |
| `omarchy` / `oma` | cd to ~/Omarchy |

### Git

| Alias | Action |
|-------|--------|
| `g` | git |
| `s` / `gs` | git status |
| `gsv` | git status -v |
| `gb` | git branch |
| `ga` | git add |
| `gap` | git add -p (patch mode) |
| `gc` | git commit --verbose |
| `gca` | git commit -a --verbose |
| `gcm` | git commit -m |
| `gcam` | git commit -a -m |
| `gam` | git commit --amend --verbose |
| `gm` | git merge |
| `gd` | git diff |
| `gds` | git diff --stat |
| `gdc` | git diff --cached |
| `co` / `gco` | git checkout |
| `gcob` | git checkout -b |
| `ac` / `gac` | git add . && git commit -am |
| `wippush` | git add . && commit "wip" && push |
| `rao` / `grao` | git remote add origin |
| `ghclone user/repo` | Clone from GitHub via SSH |
| `pushmain` / `pullmain` | push/pull origin main |
| `pushmaster` / `pullmaster` | push/pull origin master |
| `pushdev` / `pulldev` | push/pull origin dev |
| `pushstaging` / `pullstaging` | push/pull origin staging |
| `pushall` | git push --all origin |

### Docker

| Alias | Action |
|-------|--------|
| `d` | docker |
| `dc` | docker compose |
| `dcu` / `dcd` | docker compose up / down |
| `dcb` | docker compose build |
| `dps` / `dpsa` | docker ps / docker ps -a |
| `di` | docker images |
| `dls` / `dlsa` | docker container ls / ls -a |
| `dclean` | docker system prune -f |
| `dcleanall` | docker system prune -a -f |

### Tmux

| Alias | Action |
|-------|--------|
| `tmnew NAME` | tmux new -s NAME |
| `tma NAME` | tmux attach -t NAME |
| `tmd` | tmux detach |
| `tmk NAME` | tmux kill-session -t NAME |
| `tmkk` | tmux kill-server |
| `tmls` | tmux ls |

### Arch Linux (pacman/yay)

| Alias | Action |
|-------|--------|
| `pac` | sudo pacman |
| `pacs` | sudo pacman -S (install) |
| `pacr` / `pacrs` | sudo pacman -R / -Rs (remove) |
| `pacu` | sudo pacman -Syu (update) |
| `pacq` / `pacqs` | pacman -Q / -Qs (query) |
| `pacss` | pacman -Ss (search) |
| `yays` | yay -S (install AUR) |
| `yayu` | yay -Syu (update all) |
| `yayss` | yay -Ss (search AUR) |

### Secrets

| Alias | Action |
|-------|--------|
| `vault-edit` | Edit ansible vault |
| `secrets-pull` | Pull & decrypt from B2 |
| `secrets-push` | Encrypt & push to B2 |

### VS Code

| Alias | Action |
|-------|--------|
| `vspush` | Push local settings to repo |
| `vspull` | Pull repo settings to local |
| `vscode-sync` | Deploy via ansible |

### Calendar

| Alias | Action |
|-------|--------|
| `cal` | Show week calendar |
| `calm` | Show month calendar |
| `agenda` | Show upcoming events |
| `today` | Show today's events |

### Files & Output

| Alias | Action |
|-------|--------|
| `ls` | ls --color=auto |
| `l` | ls -lF |
| `la` | ls -lAF |
| `lsd` | List directories only |
| `clip` | Copy to clipboard |
| `c` | Copy without newline |
| `path` | Print PATH entries |

### Network & System

| Alias | Action |
|-------|--------|
| `myip` | Get public IP |
| `localip` | Get local IP |
| `flushdns` | Flush DNS cache |
| `week` | Get week number |
| `afk` | Lock screen |
| `reload` | Reload shell |

### HTTP Methods

| Alias | Action |
|-------|--------|
| `GET` / `POST` / `PUT` / `DELETE` | curl -X METHOD |
| `HEAD` | curl -I |
| `OPTIONS` | curl -X OPTIONS |

### Media & Hardware

| Alias | Action |
|-------|--------|
| `stfu` | Mute audio |
| `pumpitup` | Volume to 100% |
| `nvme-info` | Show NVMe SMART info |
| `printer-status` | Show printer status |
| `printer-reset` | Reset printer connection |

### Waybar

| Alias | Action |
|-------|--------|
| `waybar-start` | Start waybar |
| `waybar-restart` | Restart waybar |

### Python

| Alias | Action |
|-------|--------|
| `pvenv` | Activate venv |
| `pym` | python manage.py |
| `rundj` | python manage.py runserver |

### Laravel/PHP (Docker)

Auto-detects if in `~/Projects/{name}` with `{name}-php` container running:

| Command | Action |
|---------|--------|
| `php` | Run PHP (container or local) |
| `art` | Run php artisan |
| `composer` | Run composer |

### NeoVim

| Alias | Action |
|-------|--------|
| `nv` | nvim |

### Windows VM

| Alias | Action |
|-------|--------|
| `win-spice` | Connect via SPICE (for setup) |
| `windows` | Launch via RDP (daily use) |

### Other

| Alias | Action |
|-------|--------|
| `ap` | ansible-playbook |
| `map` | xargs -n1 |
| `ksteam` | Kill Steam |

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

### Project Artifacts

Large project files (inputs, outputs, databases) are synced to NAS rather than git. Use `artifacts-push` and `artifacts-pull` to sync.

```bash
artifacts-push              # Push all projects with .artifacts file
artifacts-push project      # Push specific project
artifacts-pull              # Pull all projects from NAS
artifacts-pull project      # Pull specific project
```

When inside a project directory, both commands operate on that project.

#### .artifacts File

Create a `.artifacts` file in your project root to specify which files/directories to sync:

```
# Lines starting with # are comments
inputs/
outputs/
results/
*.db
```

**Auto-detection**: Projects with `framework.db` at the root are automatically detected and use default patterns (`inputs/`, `outputs/`, `framework.db`) without needing a `.artifacts` file.

Artifacts are stored on NAS at `/mnt/nas/WorkArtifacts/{project}/`.

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

# Restic backup password
restic_password: "..."

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

## Restic Backup Server

A dedicated VM on the Proxmox homelab for backup management:
- **Cleanup job**: Daily at 3am, prunes old snapshots (24 hourly, 7 daily, 4 weekly, 6 monthly)
- **Backrest**: Web UI for browsing/restoring snapshots at http://restic.lan:9898

### Deploy/Redeploy

```bash
ANSIBLE_CONFIG=~/Omarchy/ansible/ansible.cfg ansible-playbook ~/Omarchy/ansible/restic-server.yml
```

This will:
1. Create/recreate VM 106 on Proxmox (hatchery.lan) from Ubuntu 24.04 cloud image
2. Configure cloud-init with SSH key
3. Mount NAS share (`//192.168.1.10/SystemSnapshots`)
4. Install restic and set up cleanup timer
5. Install Backrest web UI

### Configuration

The playbook is at `ansible/restic-server.yml`. Key settings:

| Setting | Value |
|---------|-------|
| VM ID | 106 |
| Hostname | restic |
| IP | 192.168.1.27 (DHCP, MAC: BC:24:11:3C:FC:F2) |
| Memory | 1GB |
| Storage | bolt (ZFS) |
| NAS Mount | `/mnt/nas/SystemSnapshots` |

### Backrest Setup

After deployment, open http://restic.lan:9898 and add your repository:
- **Path**: `/mnt/nas/SystemSnapshots`
- **Password**: (from vault: `restic_password`)

### Manual Cleanup

```bash
ssh restic.lan "sudo /usr/local/bin/restic-cleanup"
```

### Proxmox VM Role

The `proxmox-vm` role can deploy VMs from cloud images to Proxmox. Used by `restic-server.yml` but reusable for other VMs:

```yaml
- hosts: localhost
  vars:
    proxmox_host: hatchery.lan
    vm_id: 107
    vm_name: myvm
    vm_memory: 2048
    vm_mac_address: "AA:BB:CC:DD:EE:FF"
    cloud_image_url: "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
    cloudinit_user: erik
    proxmox_storage: bolt
  roles:
    - proxmox-vm
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
