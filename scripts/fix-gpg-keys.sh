#!/bin/bash
# fix-gpg-keys.sh - Refresh expired GPG keys for pacman
# Run when you haven't updated in a while and get key errors

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[+]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[-]${NC} $*"; exit 1; }
info() { echo -e "${BLUE}[i]${NC} $*"; }

log "Fixing GPG keys for pacman..."

# 1. Initialize pacman keyring if needed
log "Initializing pacman keyring..."
sudo pacman-key --init

# 2. Populate with Arch Linux keys
log "Populating Arch Linux keys..."
sudo pacman-key --populate archlinux

# 3. Refresh keys from keyservers
log "Refreshing keys from keyservers..."
sudo pacman-key --refresh-keys

# 4. If refresh fails, try alternative keyservers
if [[ $? -ne 0 ]]; then
    warn "Key refresh failed, trying alternative keyservers..."
    
    # Try keys.openpgp.org
    sudo pacman-key --keyserver hkps://keys.openpgp.org --refresh-keys
    
    # Try keyserver.ubuntu.com
    sudo pacman-key --keyserver hkps://keyserver.ubuntu.com --refresh-keys
    
    # Try pgp.mit.edu
    sudo pacman-key --keyserver hkps://pgp.mit.edu --refresh-keys
fi

# 5. Update archlinux-keyring package first (often fixes key issues)
log "Updating archlinux-keyring..."
sudo pacman -Sy --noconfirm archlinux-keyring

# 6. Re-populate after keyring update
log "Re-populating keys after keyring update..."
sudo pacman-key --populate archlinux

# 7. Verify
log "Verifying keyring..."
pacman-key --list-keys 2>/dev/null | head -20

log "GPG keys fixed! You can now run: yay -Syu"