# Syncthing Setup

This role configures Syncthing on local machines to sync with the Syncthing server.

## Prerequisites

- Syncthing server running and accessible
- Syncthing installed and running locally (`systemctl --user status syncthing`)

## Local Setup (Ansible)

The ansible role automatically:
- Adds the Syncthing server as a device
- Configures folder syncing (Documents, Work, Chromium)

```bash
ANSIBLE_CONFIG=~/Omarchy/ansible/ansible.cfg ansible-playbook ~/Omarchy/ansible/playbook.yml -l laptop --tags syncthing
```

## Server Setup (Manual)

For each new device, you must configure the Syncthing server to accept it.

### 1. Access Syncthing Web UI

```
http://syncthing.lan:8384
```

### 2. Add the New Device

- Click **Add Remote Device**
- Enter the device ID (get it with `syncthing cli show system | jq -r '.myID'`)
- Give it a name
- Save

### 3. Share Folders with the Device

For each folder you want to sync:

- Click on the folder → **Edit**
- Go to **Sharing** tab
- Check the new device
- Save

Or to create a new folder:

- Click **Add Folder**
- Set Folder ID (must match on all devices, e.g., `chromium`)
- Set Folder Path on server
- Under **Sharing** tab: check the devices to sync with
- Save

## Chromium Profile Sync

### Important: Close Chromium before syncing

Syncing an open browser profile can cause corruption.

### Recommended .stignore

Create `~/.config/chromium/Default/.stignore` to skip cache files:

```
Cache
Code Cache
GPUCache
Service Worker
*.log
*.tmp
Cookies
Cookies-journal
```

### Folder Configuration

- Folder ID: `chromium`
- Local path: `~/.config/chromium/Default`
- Server path: `/data/syncthing/chromium` (or your preferred location)

## Useful Commands

```bash
# Get local device ID
syncthing cli show system | jq -r '.myID'

# List configured devices
syncthing cli config devices list

# List configured folders
syncthing cli config folders list

# Check folder status
syncthing cli show folder <folder-id>

# Force rescan
syncthing cli operations scan --folder <folder-id>
```

## Troubleshooting

### Devices not connecting

1. Check firewall allows port 22000 (TCP/UDP)
2. Verify server address: `syncthing cli config devices <device-id> dump-json | jq '.addresses'`
3. Check server is reachable: `nc -zv syncthing.lan 22000`

### Folder not syncing

1. Ensure folder ID matches exactly on all devices
2. Check folder is shared with the device on server
3. Look for errors: `syncthing cli show folder <folder-id>`
