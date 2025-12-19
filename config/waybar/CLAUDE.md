# Waybar Configuration

Status bar configuration for Hyprland.

## Files

| File | Purpose |
|------|---------|
| `config.jsonc` | Module configuration |
| `style.css` | Styling |
| `scripts/` | Custom module scripts |

## Scripts

| Script | Purpose |
|--------|---------|
| `workspace.sh` | Workspace indicator with window counts |
| `weather.sh` | Weather display |
| `media.sh` | Media player info |
| `vpn.sh` | VPN status |
| `tailscale.sh` | Tailscale status |
| `connectivity.sh` | Network connectivity check |
| `sysinfo.sh` | System info |
| `darkman.sh` | Dark/light mode indicator |

## Host-Specific Config

Ansible deploys `waybar-host.css` with per-machine styling (font sizes, margins, border radius). These values come from `host_vars/`.

The `config.jsonc` is also modified by ansible to set margins and height per machine.

## Styling Notes

Colors use the current Omarchy theme. The bar inherits from theme CSS variables.

## Hyprland IPC

Scripts can query Hyprland state:

```bash
hyprctl activeworkspace -j     # Active workspace
hyprctl workspaces -j          # All workspaces
hyprctl clients -j             # All windows
```

## Dependencies

- `jq` - JSON parsing
- `socat` - IPC socket communication (for event listening)
