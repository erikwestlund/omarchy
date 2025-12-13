#!/usr/bin/env bash

# Post-install setup for Omarchy
# Run after install-packages.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Running post-install setup...${NC}"

# Framework laptop: remap rfkill key to F10 via hwdb
if grep -q "Framework" /sys/class/dmi/id/sys_vendor 2>/dev/null; then
    echo -e "${YELLOW}Setting up Framework keyboard hwdb...${NC}"
    sudo mkdir -p /etc/udev/hwdb.d
    cat << 'EOF' | sudo tee /etc/udev/hwdb.d/90-framework-toprow.hwdb > /dev/null
evdev:name:FRMW0001:00 32AC:0006:*
 KEYBOARD_KEY_100c6=f10
 KEYBOARD_KEY_100e8=f9
EOF
    sudo systemd-hwdb update
    sudo udevadm trigger -s input
    echo -e "${GREEN}✓${NC} Framework hwdb configured"
fi

# Enable Chrome/Chromium sync
if [[ -x "$HOME/.omarchy/scripts/chromium-enable-sync" ]]; then
    echo -e "${YELLOW}Enabling Chromium sync...${NC}"
    "$HOME/.omarchy/scripts/chromium-enable-sync"
    echo -e "${GREEN}✓${NC} Chromium sync enabled"
fi

# Install default theme
THEME_REPO="https://github.com/atif-1402/omarchy-rainynight-theme.git"
THEME_DIR="$HOME/.config/omarchy/themes/rainynight"
if [[ ! -d "$THEME_DIR" ]]; then
    echo -e "${YELLOW}Installing default theme (rainynight)...${NC}"
    omarchy-theme-install "$THEME_REPO"
    echo -e "${GREEN}✓${NC} Rainynight theme installed"
else
    echo -e "${GREEN}✓${NC} Rainynight theme already installed"
fi

# Install theme-set hook for customizations
HOOK_SRC="$HOME/code/omarchy/config/omarchy/hooks/theme-set"
HOOK_DEST="$HOME/.config/omarchy/hooks/theme-set"
if [[ -f "$HOOK_SRC" ]] && [[ ! -f "$HOOK_DEST" ]]; then
    cp "$HOOK_SRC" "$HOOK_DEST"
    chmod +x "$HOOK_DEST"
    echo -e "${GREEN}✓${NC} Theme-set hook installed"
fi

# Create Screenshots directory
mkdir -p "$HOME/Screenshots"
echo -e "${GREEN}✓${NC} Screenshots directory created"

echo -e "${GREEN}✓ Post-install setup complete!${NC}"
