#!/bin/bash
# install-limine.sh - Install Limine bootloader to ESP

set -euo pipefail

log() { echo -e "\033[0;32m[+]\033[0m $*"; }
warn() { echo -e "\033[1;33m[!]\033[0m $*"; }
error() { echo -e "\033[0;31m[-]\033[0m $*"; exit 1; }

# Check if limine is installed
if ! command -v limine-install &> /dev/null; then
    log "Installing limine..."
    yay -S --needed --noconfirm limine
fi

# Find ESP partition
ESP_DEVICE=$(findmnt -n -o SOURCE /boot 2>/dev/null || findmnt -n -o SOURCE /efi 2>/dev/null || echo "")

if [[ -z "$ESP_DEVICE" ]]; then
    # Try to find ESP by label/type
    ESP_DEVICE=$(lsblk -nrpo NAME,PARTTYPE | grep 'c12a7328-f81f-11d2-ba4b-00a0c93ec93b' | head -1 | awk '{print $1}')
fi

if [[ -z "$ESP_DEVICE" ]]; then
    error "Could not find ESP partition. Specify manually: limine-install /dev/nvme0n1"
fi

log "Found ESP: $ESP_DEVICE"

# Install limine
log "Installing Limine to $ESP_DEVICE..."
sudo limine-install "$ESP_DEVICE"

# Copy limine.conf to ESP
ESP_MOUNT=$(findmnt -n -o TARGET "$ESP_DEVICE" 2>/dev/null)
if [[ -z "$ESP_MOUNT" ]]; then
    # Try common mount points
    for mnt in /boot /efi /boot/efi; do
        if findmnt "$mnt" &>/dev/null; then
            ESP_MOUNT="$mnt"
            break
        fi
    done
fi

if [[ -n "$ESP_MOUNT" ]]; then
    log "Copying limine.conf to $ESP_MOUNT..."
    sudo cp config/limine/limine.conf "$ESP_MOUNT/limine.conf"
    
    # Update PARTUUID in limine.conf
    ROOT_PARTUUID=$(findmnt -n -o PARTUUID / 2>/dev/null || blkid -s PARTUUID -o value "$(findmnt -n -o SOURCE /)")
    if [[ -n "$ROOT_PARTUUID" ]]; then
        log "Setting root PARTUUID: $ROOT_PARTUUID"
        sudo sed -i "s/ROOT_PARTUUID/$ROOT_PARTUUID/g" "$ESP_MOUNT/limine.conf"
    fi
else
    warn "Could not determine ESP mount point. Copy limine.conf manually."
fi

log "Limine installation complete!"