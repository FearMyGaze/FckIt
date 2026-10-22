#!/bin/bash
# bootstrap.sh - Main installer for F#ckIt!
# Run after base Arch install (as regular user with sudo access)

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[+]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[-]${NC} $*"; exit 1; }
info() { echo -e "${BLUE}[i]${NC} $*"; }

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    error "Don't run as root! Run as your regular user."
fi

# Check sudo access
sudo -v || error "Need sudo access"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

log "Starting F#ckIt! bootstrap..."

# 1. Install yay (AUR helper)
log "Installing yay..."
if ! command -v yay &> /dev/null; then
    sudo pacman -S --needed --noconfirm base-devel git
    cd /tmp
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
    cd "$SCRIPT_DIR"
else
    info "yay already installed"
fi

# 2. Install base packages
log "Installing base packages..."
yay -S --needed --noconfirm - < packages/base.txt

# 3. Enable essential services
log "Enabling essential services..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
sudo systemctl enable --now power-profiles-daemon
sudo systemctl enable --now thermald
sudo systemctl enable --now tlp

# 4. Install Minflair (stable tag v2.0.1)
log "Installing Minflair (v2.0.1)..."
if [[ ! -d ~/.dotfiles ]]; then
    git clone --depth 1 --branch v2.0.1 https://github.com/t4lentles5/minflair.git ~/.dotfiles
else
    info "Minflair already cloned, updating..."
    cd ~/.dotfiles && git fetch && git checkout v2.0.1 && cd "$SCRIPT_DIR"
fi

cd ~/.dotfiles
chmod +x install.sh
./install.sh
cd "$SCRIPT_DIR"

# 5. Install overlay packages
log "Installing overlay packages..."
yay -S --needed --noconfirm - < packages/minflair-overlay.txt
yay -S --needed --noconfirm - < packages/wine-bottles.txt
yay -S --needed --noconfirm - < packages/vulkan-intel.txt
yay -S --needed --noconfirm - < packages/editors.txt
yay -S --needed --noconfirm - < packages/thinkpad.txt
yay -S --needed --noconfirm - < packages/performance.txt

# 6. Install Bottles via Flatpak
log "Installing Bottles (Flatpak)..."
flatpak install -y flathub com.usebottles.bottles || warn "Flatpak install failed, install manually later"

# 7. Install Zed Editor
log "Installing Zed Editor..."
if ! command -v zed &> /dev/null; then
    curl -f https://zed.dev/install.sh | sh
else
    info "Zed already installed"
fi

# 8. Install Doom Emacs
log "Installing Doom Emacs..."
if [[ ! -d ~/.config/emacs ]]; then
    git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
    ~/.config/emacs/bin/doom install
else
    info "Doom Emacs already installed"
fi

# 9. Install Limine bootloader
log "Installing Limine bootloader..."
./scripts/install-limine.sh

# 10. Stow configs
log "Stowing user configs..."
stow -d stow -t ~ hypr quickshell emacs zed user

log "Stowing system configs (requires sudo)..."
sudo stow -d stow -t / system

# 11. Run setup scripts
log "Running setup scripts..."
./scripts/setup-thinkpad.sh
./scripts/setup-performance.sh
./scripts/setup-gaming.sh
./scripts/setup-editors.sh

# 12. Enable systemd services
log "Enabling systemd services..."
sudo systemctl enable --now systemd-zram-setup@zram0.service
sudo systemctl enable --now earlyoom.service
sudo systemctl enable --now fstrim.timer
sudo systemctl enable --now battery-threshold.service
sudo systemctl enable --now preload.service
sudo systemctl enable --now cpupower.service

# 13. Rebuild initramfs
log "Rebuilding initramfs..."
sudo mkinitcpio -P

# 14. Update Limine
log "Updating Limine..."
sudo limine-install /dev/nvme0n1 2>/dev/null || warn "Limine install failed, check ESP device"

log "F#ckIt! bootstrap complete!"
warn "REBOOT REQUIRED: sudo reboot"