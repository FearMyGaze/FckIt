#!/bin/bash
# setup-gaming.sh - Wine, Bottles, Vulkan setup for gaming

set -euo pipefail

log() { echo -e "\033[0;32m[+]\033[0m $*"; }
warn() { echo -e "\033[1;33m[!]\033[0m $*"; }

log "Setting up gaming environment..."

# Vulkan verification
log "Verifying Vulkan installation..."
vulkaninfo --summary 2>/dev/null | grep -E "(deviceName|driverVersion|Vulkan version)" || warn "Vulkan verification failed"

# DXVK
log "Setting up DXVK..."
if command -v setup_dxvk &> /dev/null; then
    setup_dxvk install --user 2>/dev/null || warn "DXVK user install failed"
else
    warn "setup_dxvk not found, install dxvk package"
fi

# VKD3D-Proton
log "Setting up VKD3D-Proton..."
# Usually handled by Bottles/Proton-GE

# Wine configuration
log "Configuring Wine..."
WINEPREFIX=~/.wine winecfg -v 2>/dev/null || wineboot -u 2>/dev/null || warn "Wine prefix creation failed"

# Enable FSR in Wine
log "Enabling FSR support..."
mkdir -p ~/.wine/drive_c/windows/system32
# FSR DLLs would go here if needed

# GameMode
log "Installing gamemode..."
yay -S --needed --noconfirm gamemode lib32-gamemode 2>/dev/null || warn "gamemode install failed"

# MangoHud
log "Installing MangoHud..."
yay -S --needed --noconfirm mangohud lib32-mangohud 2>/dev/null || warn "MangoHud install failed"

# Verify 32-bit Vulkan
log "Verifying 32-bit Vulkan..."
VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/intel_icd.i686.json vulkaninfo --summary 2>/dev/null | head -20 || warn "32-bit Vulkan verification failed"

log "Gaming setup complete!"
info "Use Bottles (flatpak) to manage Wine prefixes and install DXVK/VKD3D per prefix"
info "Launch games with: gamemoderun mangohud <game>"