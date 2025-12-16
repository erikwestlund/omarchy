# VMs Role

Provisions virtual machines using libvirt/QEMU. Connects via RDP for best experience with dynamic resolution scaling.

## What it does

1. Adds user to libvirt groups
2. Starts libvirtd service
3. Sets up default NAT network (virbr0)
4. Configures UFW firewall rules for VM networking
5. Renames legacy `RDPWindows` VM to `win11` (migration)
6. Downloads virtio drivers if missing
7. Creates VMs defined in host_vars
8. Deploys RDP credentials from vault
9. Creates desktop entries for launcher

## Quick Start: Replicating on Another Machine

If you already have a Windows 11 VM and want to set up RDP with dynamic resolution:

### 1. Run Ansible to deploy the launcher script

```bash
ANSIBLE_CONFIG=~/Omarchy/ansible/ansible.cfg ansible-playbook ~/Omarchy/ansible/playbook.yml -l laptop --tags vms,dotfiles
```

### 2. Windows VM Configuration

#### Enable RDP in Windows
1. Settings → System → Remote Desktop → **On**
2. Click "Confirm" when prompted

#### Install virtio drivers (if not already done)
1. Download virtio-win.iso from https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
2. Mount it in the VM or copy to Windows
3. Run `virtio-win-guest-tools.exe` to install all drivers

#### For dynamic resolution to work
The virtio-win-guest-tools installer includes the QEMU Guest Agent and display drivers needed for resolution changes to propagate.

### 3. Set up RDP credentials

Create the credentials file so the launcher doesn't prompt for password:

```bash
mkdir -p ~/.config/windows-vm
chmod 700 ~/.config/windows-vm
cat > ~/.config/windows-vm/rdp-creds << 'EOF'
RDP_USER="erik"
RDP_PASS="password"
EOF
chmod 600 ~/.config/windows-vm/rdp-creds
```

Or add to ansible vault (`ansible/vault/secrets.yml`):
```yaml
vault_windows_vm_user: "erik"
vault_windows_vm_password: "your-password"
```

### 4. Add virtiofs shared folder (optional)

To share your home directory with the VM:

```bash
# Shut down VM first
virsh shutdown win11

# Edit VM to add shared memory and virtiofs
virsh edit win11
```

Add after `</currentMemory>`:
```xml
<memoryBacking>
  <source type="memfd"/>
  <access mode="shared"/>
</memoryBacking>
```

Add before `</devices>`:
```xml
<filesystem type="mount" accessmode="passthrough">
  <driver type="virtiofs"/>
  <source dir="/home/erik"/>
  <target dir="home"/>
</filesystem>
```

Then in Windows:
1. Install WinFsp from https://winfsp.dev/rel/
2. Install virtio-fs driver from virtio-win package
3. Mount: `net use Z: \\.\virtiofs\home`

### 5. Launch

Run `windows` from launcher or terminal. It will:
- Start the VM if not running
- Wait for IP and RDP port
- Connect with 2x HiDPI scaling and dynamic resolution

## Configuration

Define VMs in `host_vars/<machine>.yml`:

```yaml
vms:
  - name: win11
    desktop_name: Windows          # Name shown in launcher
    icon: "{{ ansible_facts.env.HOME }}/.local/share/applications/icons/windows.png"
    exec: "{{ ansible_facts.env.HOME }}/.bin/windows"  # Custom launcher script
    keywords: windows;             # Extra search keywords
    os_variant: win11
    ram_mb: 16384
    vcpus: 4
    disk_size_gb: 250
    iso: "{{ ansible_facts.env.HOME }}/NAS/ISOs/win-11.iso"
    virtio_iso: "{{ ansible_facts.env.HOME }}/NAS/ISOs/virtio-win.iso"
    tpm: true                      # TPM 2.0 emulation (required for Win11)
```

## Optional VM properties

- `exec`: Custom command for desktop entry (default: virt-viewer)
- `create_desktop_entry`: Set to false to skip desktop entry (default: true)
- `tpm`: Enable TPM emulation (default: true)

## Usage

```bash
# Create/provision VMs
ANSIBLE_CONFIG=~/Omarchy/ansible/ansible.cfg ansible-playbook ~/Omarchy/ansible/playbook.yml -l desktop --tags vms
```

## Requirements

- Windows ISO at `~/NAS/ISOs/win-11.iso`
- virtio drivers downloaded automatically from Fedora if missing
- Packages: libvirt, qemu, virt-install, virt-viewer, freerdp, swtpm (for TPM)

## Windows VM Setup

### During Installation

1. When Windows can't find a disk, click "Load driver"
2. Browse to the virtio CD (D: drive) → `viostor\w11\amd64`
3. This loads the storage driver so Windows can see the disk

### After Installation

1. Open the virtio CD (D:) and run `virtio-win-guest-tools.exe` to install all drivers
2. Enable Remote Desktop: Settings → System → Remote Desktop → On
3. The `windows` launcher script will connect via RDP automatically

## Connection Methods

The `windows` launcher script tries:
1. **RDP** (preferred) - smoother, native Windows protocol
2. **SPICE** (fallback) - if RDP unavailable

Manual connection:
```bash
xfreerdp3 /v:192.168.122.X /u:username /dynamic-resolution +clipboard /cert:ignore
```

## Troubleshooting

### VM has no network / no IP

The libvirt NAT network (virbr0) can conflict with UFW firewall. This role configures UFW rules automatically, but if issues persist:

```bash
# Check if virbr0 is up
ip addr show virbr0

# Check VM has network interface
virsh domiflist win11

# Check for DHCP lease
sudo virsh net-dhcp-leases default

# Manual fix: allow libvirt traffic
sudo ufw allow in on virbr0
sudo ufw allow out on virbr0
sudo ufw route allow in on virbr0
sudo ufw route allow out on virbr0
```

### VM network broken after restarting libvirt network

If you restart the default network while VM is running, the VM's virtual NIC may get detached:

```bash
# Reattach VM's vnet interface to bridge
sudo brctl addif virbr0 vnet0
```

### Can't get VM IP address

Try these methods in order:
```bash
# Method 1: virsh
virsh domifaddr win11

# Method 2: DHCP leases
sudo virsh net-dhcp-leases default

# Method 3: ARP table (ping broadcast first)
ping -c1 192.168.122.255
ip neigh | grep 52:54  # Look for VM MAC prefix
```

## Shared Folders (virtiofs)

The VM is configured with virtiofs to share the host home directory.

### Windows Setup

1. **Install WinFsp**: Download from https://winfsp.dev/rel/
2. **Install virtio-fs driver**:
   - Download virtio-win drivers if not already installed
   - Run the virtio-win-guest-tools.exe installer
   - Or manually install from `viofs\w11\amd64` directory

3. **Mount the share**:
   ```cmd
   net use Z: \\.\virtiofs\home
   ```
   Or it may auto-mount after driver installation.

### Troubleshooting virtiofs

If the share doesn't appear:
- Ensure WinFsp is installed and running
- Check Device Manager for "VirtIO FS Device"
- Try `sc query virtiofs` in cmd to check service status
- Reboot Windows after installing drivers
