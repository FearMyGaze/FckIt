#!/bin/bash
# setup-performance.sh - System performance optimizations

set -euo pipefail

log() { echo -e "\033[0;32m[+]\033[0m $*"; }
warn() { echo -e "\033[1;33m[!]\033[0m $*"; }

log "Setting up performance optimizations..."

# CPU governor
log "Configuring CPU governor..."
sudo cpupower frequency-set -g performance 2>/dev/null || warn "cpupower not fully configured"

# Enable pstate HWP
if [[ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]]; then
    echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo >/dev/null 2>&1 || true
fi

# Intel GPU runtime PM
log "Enabling Intel GPU runtime PM..."
echo 1 | sudo tee /sys/module/i915/parameters/enable_guc >/dev/null 2>&1 || true
echo 1 | sudo tee /sys/module/i915/parameters/enable_psr >/dev/null 2>&1 || true
echo 1 | sudo tee /sys/module/i915/parameters/enable_fbc >/dev/null 2>&1 || true
echo 1 | sudo tee /sys/module/i915/parameters/enable_dc >/dev/null 2>&1 || true
echo 0 | sudo tee /sys/module/i915/parameters/disable_power_well >/dev/null 2>&1 || true

# NVMe power management
log "Configuring NVMe power management..."
echo 0 | sudo tee /sys/module/nvme_core/parameters/default_ps_max_latency_us >/dev/null 2>&1 || true

# Preload
log "Starting preload..."
sudo systemctl enable --now preload.service 2>/dev/null || warn "preload service not available"

# Earlyoom
log "Configuring earlyoom..."
sudo systemctl enable --now earlyoom.service 2>/dev/null || warn "earlyoom service not available"

# zram
log "Configuring zram..."
sudo systemctl enable --now systemd-zram-setup@zram0.service 2>/dev/null || warn "zram not configured"

# fstrim
log "Enabling fstrim timer..."
sudo systemctl enable --now fstrim.timer 2>/dev/null || warn "fstrim timer not available"

# sysctl
log "Applying sysctl settings..."
sudo sysctl --system 2>/dev/null || warn "sysctl apply failed"

log "Performance setup complete!"