#!/usr/bin/env bash

# Bootstrap script - sync omarchy config to system
# Usage: ./bootstrap.sh [options]
#
# Options:
#   --home-only       Only sync home/ files (e.g., .aliases)
#   --config-only     Only sync config/ files
#   --system-only     Only sync system/ files (requires sudo)
#   --only <items>    Only sync specific items (comma-separated)
#                     e.g., --only aliases,hypr
#   --exclude <items> Exclude specific items (comma-separated)
#                     e.g., --exclude hypr,waybar
#   --no-git          Skip git pull
#   --dry-run         Show what would be synced without copying
#
# Examples:
#   ./bootstrap.sh --home-only              # Just sync .aliases etc.
#   ./bootstrap.sh --only hypr              # Just sync hypr config
#   ./bootstrap.sh --exclude hypr,waybar    # Sync all except hypr and waybar
#   ./bootstrap.sh --system-only            # Just sync udev rules etc.

set -e

# Get the directory of this script
OMARCHY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Default options
SYNC_HOME=true
SYNC_CONFIG=true
SYNC_SYSTEM=true
DO_GIT_PULL=true
DRY_RUN=false
ONLY_ITEMS=""
EXCLUDE_ITEMS=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --home-only)
            SYNC_HOME=true
            SYNC_CONFIG=false
            SYNC_SYSTEM=false
            shift
            ;;
        --config-only)
            SYNC_HOME=false
            SYNC_CONFIG=true
            SYNC_SYSTEM=false
            shift
            ;;
        --system-only)
            SYNC_HOME=false
            SYNC_CONFIG=false
            SYNC_SYSTEM=true
            shift
            ;;
        --only)
            ONLY_ITEMS="$2"
            shift 2
            ;;
        --exclude)
            EXCLUDE_ITEMS="$2"
            shift 2
            ;;
        --no-git)
            DO_GIT_PULL=false
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            head -24 "$0" | tail -21
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Check if item should be synced
should_sync() {
    local item=$1

    # If --only is set, item must be in the list
    if [[ -n "$ONLY_ITEMS" ]]; then
        if [[ ",$ONLY_ITEMS," == *",$item,"* ]]; then
            return 0
        else
            return 1
        fi
    fi

    # If --exclude is set, item must NOT be in the list
    if [[ -n "$EXCLUDE_ITEMS" ]]; then
        if [[ ",$EXCLUDE_ITEMS," == *",$item,"* ]]; then
            return 1
        fi
    fi

    return 0
}

# Function to safely copy a file
safe_copy() {
    local src=$1
    local dest=$2

    if [[ -f "$src" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "${YELLOW}[dry-run]${NC} Would copy: $src -> $dest"
        else
            mkdir -p "$(dirname "$dest")"
            cp "$src" "$dest"
            echo -e "${GREEN}✓${NC} Updated $(basename "$dest")"
        fi
    else
        echo -e "${YELLOW}!${NC} Source not found: $src"
    fi
}

# Function to safely copy a directory (recursive)
safe_copy_dir() {
    local src=$1
    local dest=$2

    if [[ -d "$src" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "${YELLOW}[dry-run]${NC} Would copy dir: $src -> $dest"
        else
            mkdir -p "$dest"
            cp -r "$src"/* "$dest"/ 2>/dev/null || true
            echo -e "${GREEN}✓${NC} Updated directory: $(basename "$dest")"
        fi
    else
        echo -e "${YELLOW}!${NC} Source directory not found: $src"
    fi
}

echo -e "${YELLOW}Updating omarchy config...${NC}"

# Pull latest changes
if [[ "$DO_GIT_PULL" == true ]]; then
    cd "$OMARCHY_DIR"
    git pull origin main 2>/dev/null && echo -e "${GREEN}✓ Pulled latest changes${NC}" || echo -e "${YELLOW}! Git pull skipped (no remote or offline)${NC}"
fi

# Copy home files (home/ -> ~/)
if [[ "$SYNC_HOME" == true ]]; then
    echo -e "${YELLOW}Syncing home files...${NC}"
    if [[ -d "$OMARCHY_DIR/home" ]]; then
        for file in "$OMARCHY_DIR/home"/.*; do
            if [[ -f "$file" ]]; then
                filename=$(basename "$file")
                # Strip leading dot for should_sync check (e.g., .aliases -> aliases)
                item_name="${filename#.}"
                if should_sync "$item_name"; then
                    safe_copy "$file" "$HOME/$filename"
                fi
            fi
        done
    fi
fi

# Copy config files (config/ -> ~/.config/)
if [[ "$SYNC_CONFIG" == true ]]; then
    echo -e "${YELLOW}Syncing config files...${NC}"
    if [[ -d "$OMARCHY_DIR/config" ]]; then
        for item in "$OMARCHY_DIR/config"/*; do
            itemname=$(basename "$item")
            if should_sync "$itemname"; then
                if [[ -d "$item" ]]; then
                    safe_copy_dir "$item" "$HOME/.config/$itemname"
                elif [[ -f "$item" ]]; then
                    safe_copy "$item" "$HOME/.config/$itemname"
                fi
            fi
        done
    fi
fi

# Ensure .bashrc sources .aliases
if [[ "$SYNC_HOME" == true ]] && should_sync "aliases"; then
    BASHRC="$HOME/.bashrc"
    ALIASES_SOURCE='[ -f ~/.aliases ] && source ~/.aliases'

    if [[ -f "$BASHRC" ]]; then
        if ! grep -q "source ~/.aliases\|\.aliases" "$BASHRC" 2>/dev/null; then
            if [[ "$DRY_RUN" == true ]]; then
                echo -e "${YELLOW}[dry-run]${NC} Would add aliases source line to .bashrc"
            else
                echo "" >> "$BASHRC"
                echo "# Omarchy aliases" >> "$BASHRC"
                echo "$ALIASES_SOURCE" >> "$BASHRC"
                echo -e "${GREEN}✓${NC} Added aliases source to .bashrc"
            fi
        else
            echo -e "${GREEN}✓${NC} .bashrc already sources .aliases"
        fi
    else
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "${YELLOW}[dry-run]${NC} Would create .bashrc with aliases source"
        else
            echo "# Omarchy aliases" > "$BASHRC"
            echo "$ALIASES_SOURCE" >> "$BASHRC"
            echo -e "${GREEN}✓${NC} Created .bashrc with aliases source"
        fi
    fi
fi

# Ensure .bashrc sources .bashrc.local
if [[ "$SYNC_HOME" == true ]] && should_sync "bashrc.local"; then
    BASHRC="$HOME/.bashrc"
    BASHRC_LOCAL_SOURCE='[ -f ~/.bashrc.local ] && source ~/.bashrc.local'

    if [[ -f "$BASHRC" ]]; then
        if ! grep -q "\.bashrc\.local" "$BASHRC" 2>/dev/null; then
            if [[ "$DRY_RUN" == true ]]; then
                echo -e "${YELLOW}[dry-run]${NC} Would add .bashrc.local source line to .bashrc"
            else
                echo "" >> "$BASHRC"
                echo "# Omarchy local config" >> "$BASHRC"
                echo "$BASHRC_LOCAL_SOURCE" >> "$BASHRC"
                echo -e "${GREEN}✓${NC} Added .bashrc.local source to .bashrc"
            fi
        else
            echo -e "${GREEN}✓${NC} .bashrc already sources .bashrc.local"
        fi
    fi
fi

# Copy system files (system/ -> /) - requires sudo
if [[ "$SYNC_SYSTEM" == true ]]; then
    if [[ -d "$OMARCHY_DIR/system" ]]; then
        echo -e "${YELLOW}Syncing system files (requires sudo)...${NC}"

        # Find all files in system/ and copy them to /
        while IFS= read -r -d '' file; do
            # Get relative path from system/
            rel_path="${file#$OMARCHY_DIR/system/}"
            dest="/$rel_path"

            if [[ "$DRY_RUN" == true ]]; then
                echo -e "${YELLOW}[dry-run]${NC} Would copy: $file -> $dest"
            else
                sudo mkdir -p "$(dirname "$dest")"
                sudo cp "$file" "$dest"
                echo -e "${GREEN}✓${NC} Updated $dest"
            fi
        done < <(find "$OMARCHY_DIR/system" -type f -print0)

        # Reload udev rules if any were updated
        if [[ "$DRY_RUN" != true ]] && [[ -d "$OMARCHY_DIR/system/etc/udev/rules.d" ]]; then
            sudo udevadm control --reload-rules
            sudo udevadm trigger
            echo -e "${GREEN}✓${NC} Reloaded udev rules"
        fi
    fi
fi

echo -e "${GREEN}✓ Omarchy config updated successfully!${NC}"
echo "Note: You may need to restart your terminal or run 'source ~/.bashrc' for changes to take effect"
