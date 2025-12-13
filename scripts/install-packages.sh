#!/usr/bin/env bash

# Install packages for Omarchy setup
# Uses omarchy-pkg-add for official repos, yay for AUR

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Installing packages...${NC}"

# =============================================================================
# Official Repo Packages (via omarchy-pkg-add)
# =============================================================================

echo -e "${YELLOW}Installing official repo packages...${NC}"

PACMAN_PKGS=(
    # Core utilities
    coreutils
    findutils
    grep
    sed
    rsync
    rclone
    htop
    tree
    openssh
    gnupg
    wget
    curl

    # Archive tools
    p7zip
    pigz

    # Network
    iperf3
    lynx

    # Development
    cmake
    pkg-config
    imagemagick
    ffmpeg
    yt-dlp
    python-pip
    nodejs
    npm
    jq
    socat

    # Shell
    zsh

    # Fonts
    inter-font
    ttf-font-awesome

    # Git
    git-lfs

    # R and stats
    r
    gcc-fortran  # Required for R packages

    # LaTeX (minimal for Quarto)
    texlive-basic
    texlive-latex
    texlive-latexrecommended
    texlive-latexextra
    texlive-fontsrecommended
    texlive-xetex
    texlive-bibtexextra

    # Browsers
    firefox

    # Media
    vlc

    # Screenshots
    flameshot

    # Clipboard manager
    cliphist
    wl-clipboard

    # Wayland debugging
    wev

    # Virtualization (Windows VM via RDP)
    libvirt
    qemu-full
    virt-manager
    virt-viewer
    dnsmasq
    bridge-utils
    edk2-ovmf
    freerdp
)

omarchy-pkg-add "${PACMAN_PKGS[@]}"

# =============================================================================
# AUR Packages (via yay)
# =============================================================================

echo -e "${YELLOW}Installing AUR packages...${NC}"

AUR_PKGS=(
    # Dev tools
    visual-studio-code-bin
    openai-codex-bin
    nvm
    tableplus
    sublime-merge
    insomnia-bin
    ansible
    doctl-bin

    # Communication
    slack-desktop
    zoom
    teams-for-linux

    # R ecosystem
    rstudio-desktop-bin
    quarto-cli-bin

    # Browser
    google-chrome

    # Research
    zotero

    # Hyprland utilities
    hyprswitch
)

yay -S --needed --noconfirm "${AUR_PKGS[@]}"

# =============================================================================
# Post-install setup
# =============================================================================

echo -e "${YELLOW}Running post-install setup...${NC}"

# Set up NVM
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"
if [[ -s "/usr/share/nvm/init-nvm.sh" ]]; then
    source /usr/share/nvm/init-nvm.sh
    nvm install --lts
    nvm use --lts
    nvm alias default 'lts/*'
    echo -e "${GREEN}✓${NC} Node.js $(node --version) installed via NVM"

    # Install Claude Code via npm
    npm install -g @anthropic-ai/claude-code
    echo -e "${GREEN}✓${NC} Claude Code installed via npm"
fi

# Git config
git config --global init.defaultBranch main
git config --global pull.rebase false
echo -e "${GREEN}✓${NC} Git configured"

# Create common directories
mkdir -p "$HOME/code"
mkdir -p "$HOME/code/projects"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
echo -e "${GREEN}✓${NC} Common directories created"

echo -e "${GREEN}✓ Package installation complete!${NC}"
echo ""
echo "Manual steps:"
echo "  1. Sign in to 1Password: op signin"
echo "  2. Sign in to Slack, Zoom, Teams"
echo "  3. Configure VS Code settings sync"
echo "  4. Run 'secrets-pull' to sync SSH keys"
