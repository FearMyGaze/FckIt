#!/bin/bash
# setup-thinkpad.sh - ThinkPad T480s specific setup

set -euo pipefail

log() { echo -e "\033[0;32m[+]\033[0m $*"; }
warn() { echo -e "\033[1;33m[!]\033[0m $*"; }

log "Setting up ThinkPad T480s..."

# Load kernel modules
log "Loading ThinkPad kernel modules..."
sudo modprobe thinkpad_acpi || warn "thinkpad_acpi not loaded"
sudo modprobe nct6775 || warn "nct6775 not loaded (may need reboot after DKMS build)"
sudo modprobe acpi_call || warn "acpi_call not loaded"

# Enable thinkpad_acpi features
log "Configuring thinkpad_acpi..."
echo 1 | sudo tee /sys/module/thinkpad_acpi/parameters/fan_control >/dev/null 2>&1 || true
echo 1 | sudo tee /sys/module/thinkpad_acpi/parameters/brightness_mode >/dev/null 2>&1 || true

# Set initial battery thresholds
log "Setting battery charge thresholds (75/80)..."
echo 75 | sudo tee /sys/class/power_supply/BAT0/charge_start_threshold >/dev/null 2>&1 || warn "Could not set start threshold"
echo 80 | sudo tee /sys/class/power_supply/BAT0/charge_stop_threshold >/dev/null 2>&1 || warn "Could not stop threshold"

# Configure trackpoint
log "Configuring TrackPoint..."
echo 200 | sudo tee /sys/devices/platform/i8042/serio1/serio2/sensitivity >/dev/null 2>&1 || true
echo 180 | sudo tee /sys/devices/platform/i8042/serio1/serio2/speed >/dev/null 2>&1 || true

# Configure thinkfan
log "Setting up thinkfan..."
sudo mkdir -p /etc/thinkfan
cat << 'EOF' | sudo tee /etc/thinkfan.conf >/dev/null
tp_fan /proc/acpi/ibm/fan
hwmon /sys/class/hwmon/hwmon0/temp1_input
(0,     0,      40)
(1,     35,     45)
(2,     40,     50)
(3,     45,     55)
(4,     50,     60)
(5,     55,     65)
(7,     60,     32767)
EOF

# Enable thinkfan service
sudo systemctl enable --now thinkfan.service 2>/dev/null || warn "thinkfan service not available"

# Sensors detection
log "Running sensors-detect..."
sudo sensors-detect --auto 2>/dev/null || true

log "ThinkPad setup complete!"