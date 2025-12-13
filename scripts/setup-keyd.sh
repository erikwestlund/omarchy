#!/bin/bash

# Setup keyd to swap F-keys with media keys on Framework laptop
# This makes F1 the default (no Fn needed), and Fn+F1 for media functions

set -e

echo "Installing keyd..."
sudo pacman -S --noconfirm --needed keyd

echo "Creating keyd config..."
sudo tee /etc/keyd/default.conf > /dev/null << 'EOF'
[ids]
# Framework laptop internal keyboard
0001:0001
# Framework hotkey device (media keys, rfkill, etc)
32ac:0006

[main]
# Swap Alt and Super (Meta)
leftalt = leftmeta
leftmeta = leftalt
rightalt = rightmeta
rightmeta = rightalt

# Swap media keys with F-keys
# Without Fn: get F-key
# With Fn: get media function
mute = f1
volumedown = f2
volumeup = f3
previoussong = f4
playpause = f5
nextsong = f6
brightnessdown = f7
brightnessup = f8
# rfkill is remapped to f10 via hwdb, so we just need the reverse mapping
sysrq = f11
media = f12

f1 = mute
f2 = volumedown
f3 = volumeup
f4 = previoussong
f5 = playpause
f6 = nextsong
f7 = brightnessdown
f8 = brightnessup
# f10 comes from hwdb as f10 already, no remap needed
# Fn+F10 sends actual f10 which we leave alone
f11 = sysrq
f12 = media

# F9 hardware sends meta+p combo (becomes alt+p after swap)
# Convert to F9 so bare F9 works for workspace switching
# NOTE: Alt+F9 broken by EC firmware (clears modifiers) - use Super+Shift+9 instead
[alt]
p = f9
EOF

echo "Creating Logitech Bolt config (swap Alt/Super to match Framework)..."
sudo tee /etc/keyd/logitech.conf > /dev/null << 'EOF'
[ids]
# Logitech Bolt USB Receiver
046d:c548

[main]
# Swap Alt and Super to match Framework layout
# MX Keys: cmd|alt key -> Super, opt|start key -> Alt
leftalt = leftmeta
leftmeta = leftalt
rightalt = rightmeta
rightmeta = rightalt
EOF

echo "Creating mac-like shortcuts config (all keyboards)..."
sudo tee /etc/keyd/mac-shortcuts.conf > /dev/null << 'EOF'
[ids]
*

[main]

[meta]
# Mac-like shortcuts: Super+key -> Ctrl+key
a = C-a
EOF

echo "Enabling and starting keyd..."
sudo systemctl enable --now keyd
sudo keyd reload

echo "Done! Test: press mute key (should act as F1), press Fn+mute (should mute)"
echo "Mac shortcuts: Super+A = Select All, Super+L = Location bar"
