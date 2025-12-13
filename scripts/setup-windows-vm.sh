#!/usr/bin/env bash

# Setup Windows VM with RDP access
# Creates a Windows VM optimized for Office work via Remote Desktop
#
# Usage: ./setup-windows-vm.sh
#
# After running:
#   1. Complete Windows installation in virt-manager
#   2. Enable RDP in Windows (Settings > System > Remote Desktop)
#   3. Launch with: windows (or from app launcher)

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# VM Configuration - optimized for Office work
DISK_SIZE="64G"
RAM_MB="8192"      # 8GB RAM
CPUS="2"           # 2 vCPUs (pinned to P-cores)
VM_NAME="RDPWindows"
VM_IP="192.168.122.50"

echo -e "${YELLOW}Setting up Windows VM...${NC}"

# =============================================================================
# Step 1: Enable and start libvirt
# =============================================================================
echo -e "${YELLOW}Configuring libvirt...${NC}"

sudo systemctl enable --now libvirtd.service
sudo systemctl enable --now virtlogd.service

# Add user to libvirt group
sudo usermod -aG libvirt "$USER"
sudo usermod -aG kvm "$USER"

# Create and start default network
sudo virsh net-define /usr/share/libvirt/networks/default.xml 2>/dev/null || true
sudo virsh net-start default 2>/dev/null || true
sudo virsh net-autostart default 2>/dev/null || true

echo -e "${GREEN}✓${NC} Libvirt configured"

# =============================================================================
# Step 2: Download Windows ISO (if not present)
# =============================================================================
ISO_DIR="$HOME/ISOs"
WIN_ISO="$ISO_DIR/Win11.iso"

mkdir -p "$ISO_DIR"

if [[ ! -f "$WIN_ISO" ]]; then
    echo -e "${YELLOW}Downloading Windows 11 ISO...${NC}"

    # Install quickget if not present
    if ! command -v quickget &> /dev/null; then
        yay -S --needed --noconfirm quickemu
    fi

    cd "$ISO_DIR"
    quickget windows 11

    if ls windows-11/*.iso 1> /dev/null 2>&1; then
        mv windows-11/*.iso "$WIN_ISO"
        rm -rf windows-11/
        echo -e "${GREEN}✓${NC} Windows 11 ISO downloaded: $WIN_ISO"
    else
        echo -e "${RED}Failed to download Windows ISO${NC}"
        echo "Download manually from: https://www.microsoft.com/software-download/windows11"
        echo "Save to: $WIN_ISO"
        exit 1
    fi
else
    echo -e "${GREEN}✓${NC} Windows ISO found: $WIN_ISO"
fi

# Download VirtIO drivers
VIRTIO_ISO="$ISO_DIR/virtio-win.iso"
if [[ ! -f "$VIRTIO_ISO" ]]; then
    echo -e "${YELLOW}Downloading VirtIO drivers...${NC}"
    curl -L -o "$VIRTIO_ISO" https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
    echo -e "${GREEN}✓${NC} VirtIO drivers downloaded"
else
    echo -e "${GREEN}✓${NC} VirtIO drivers found"
fi

# =============================================================================
# Step 3: Create Windows VM
# =============================================================================
echo -e "${YELLOW}Creating Windows VM...${NC}"

VM_DISK="/var/lib/libvirt/images/${VM_NAME}.qcow2"

if sudo virsh --connect qemu:///system list --all | grep -q "$VM_NAME"; then
    echo -e "${YELLOW}VM '$VM_NAME' already exists. Skipping creation.${NC}"
else
    # Copy ISO to libvirt storage
    LIBVIRT_ISO="/var/lib/libvirt/images/Win11.iso"
    if [[ ! -f "$LIBVIRT_ISO" ]]; then
        sudo cp "$WIN_ISO" "$LIBVIRT_ISO"
    fi

    # Create disk
    if [[ ! -f "$VM_DISK" ]]; then
        sudo qemu-img create -f qcow2 "$VM_DISK" "$DISK_SIZE"
        echo -e "${GREEN}✓${NC} Created ${DISK_SIZE} disk"
    fi

    # Create VM
    sudo virt-install \
        --connect qemu:///system \
        --name "$VM_NAME" \
        --ram "$RAM_MB" \
        --vcpus "$CPUS" \
        --cpu host-model \
        --disk path="$VM_DISK",format=qcow2 \
        --cdrom "$LIBVIRT_ISO" \
        --os-variant win11 \
        --network network=default \
        --graphics spice \
        --video qxl \
        --boot uefi \
        --noautoconsole

    echo -e "${GREEN}✓${NC} VM created"
fi

# =============================================================================
# Step 4: Configure P-core CPU pinning
# =============================================================================
echo -e "${YELLOW}Configuring CPU pinning to P-cores...${NC}"

# Export VM XML, add cputune for P-core pinning, and redefine
TEMP_XML=$(mktemp)
sudo virsh -c qemu:///system dumpxml "$VM_NAME" > "$TEMP_XML"

# Check if cputune already exists
if ! grep -q "<cputune>" "$TEMP_XML"; then
    # Add cputune section after vcpu element (pin to CPUs 0 and 1 - P-cores)
    sed -i '/<\/vcpu>/a\  <cputune>\n    <vcpupin vcpu="0" cpuset="0"/>\n    <vcpupin vcpu="1" cpuset="1"/>\n  </cputune>' "$TEMP_XML"

    # Remove domain id attribute (required for virsh define)
    sed -i "s/<domain type='kvm' id='[0-9]*'>/<domain type='kvm'>/" "$TEMP_XML"

    sudo virsh -c qemu:///system define "$TEMP_XML"
    echo -e "${GREEN}✓${NC} CPU pinning configured (vCPUs 0-1 → P-cores 0-1)"
else
    echo -e "${GREEN}✓${NC} CPU pinning already configured"
fi

rm -f "$TEMP_XML"

# =============================================================================
# Step 5: Configure networking
# =============================================================================
echo -e "${YELLOW}Configuring network...${NC}"

VM_MAC=$(sudo virsh -c qemu:///system domiflist "$VM_NAME" 2>/dev/null | grep -oE '([0-9a-f]{2}:){5}[0-9a-f]{2}' | head -1)

if [[ -n "$VM_MAC" ]]; then
    sudo virsh -c qemu:///system net-update default add ip-dhcp-host \
        "<host mac='$VM_MAC' name='$VM_NAME' ip='$VM_IP'/>" \
        --live --config 2>/dev/null || true
    echo -e "${GREEN}✓${NC} DHCP reservation: $VM_IP"
fi

if ! grep -q "$VM_NAME" /etc/hosts; then
    echo "$VM_IP $VM_NAME" | sudo tee -a /etc/hosts > /dev/null
    echo -e "${GREEN}✓${NC} Added to /etc/hosts"
fi

# =============================================================================
# Step 6: Create launcher script and desktop entry
# =============================================================================
echo -e "${YELLOW}Creating launcher...${NC}"

mkdir -p "$HOME/.local/bin"

# Create windows launcher script
cat > "$HOME/.local/bin/windows" << 'LAUNCHER'
#!/bin/bash
# Windows VM launcher - auto-starts VM and connects via RDP
export LIBVIRT_DEFAULT_URI="qemu:///system"

# Start VM if not running
if ! virsh list --state-running --name | grep -q "RDPWindows"; then
    notify-send "Windows VM" "Starting VM..." -t 5000
    virsh start RDPWindows >/dev/null 2>&1
    sleep 10
fi

# Wait for RDP to be ready (30 sec timeout)
for i in {1..30}; do
    if timeout 1 bash -c ">/dev/tcp/192.168.122.50/3389" 2>/dev/null; then
        break
    fi
    sleep 1
done

# Get monitor dimensions for proper sizing
MONITOR_INFO=$(hyprctl monitors -j 2>/dev/null | jq -r '.[0] | "\(.width)x\((.height | tonumber) - (22 * .scale | tonumber))"')
SIZE="${MONITOR_INFO:-2256x1460}"

# Connect via RDP with home drive mounted
exec xfreerdp3 /v:192.168.122.50 "/u:Erik Westlund" /p:password \
    /cert:ignore \
    /size:"$SIZE" \
    /gfx:AVC444 \
    -grab-keyboard \
    /drive:home,"$HOME" \
    /title:"Windows VM"
LAUNCHER

chmod +x "$HOME/.local/bin/windows"
echo -e "${GREEN}✓${NC} Created ~/.local/bin/windows"

# Create desktop entry for app launcher
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/windows-vm.desktop" << DESKTOP
[Desktop Entry]
Name=Windows
Comment=Connect to Windows VM via RDP
Exec=uwsm app -- $HOME/.local/bin/windows
Icon=windows
Terminal=false
Type=Application
Categories=System;
DESKTOP

echo -e "${GREEN}✓${NC} Created desktop entry (appears in app launcher)"

# =============================================================================
# Done
# =============================================================================
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Windows VM setup complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo "1. LOG OUT and back in (for libvirt group)"
echo ""
echo "2. Start VM and complete Windows installation:"
echo -e "   ${GREEN}virsh -c qemu:///system start RDPWindows${NC}"
echo -e "   ${GREEN}virt-manager --connect qemu:///system --show-domain-console RDPWindows${NC}"
echo ""
echo "3. During Windows install:"
echo "   - Press Shift+F10, type OOBE\\BYPASSNRO, Enter (to skip internet)"
echo "   - Create local account WITH A PASSWORD (required for RDP)"
echo ""
echo "4. Install VirtIO drivers in Windows:"
echo "   - In virt-manager: View → Details → Add Hardware → CDROM"
echo "   - Browse to ~/ISOs/virtio-win.iso"
echo "   - Run virtio-win-gt-x64.msi from the CD"
echo ""
echo "5. Enable Remote Desktop in Windows:"
echo "   Settings → System → Remote Desktop → On"
echo ""
echo "6. Update credentials in ~/.local/bin/windows:"
echo "   Change /u: and /p: to match your Windows account"
echo ""
echo "7. Launch Windows:"
echo -e "   ${GREEN}windows${NC}  (from terminal or Super+Space → Windows)"
echo ""
echo -e "${YELLOW}VM specs: 8GB RAM, 2 CPUs (P-cores), 64GB disk${NC}"
echo ""
