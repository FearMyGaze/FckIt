# F#ckIt! — Arch Linux + Hyprland/Minflair + Limine

A minimal, performant Arch Linux setup for ThinkPad T480s (Intel UHD 620) with:
- **Hyprland** + **Minflair** (Quickshell-based desktop)
- **Limine** bootloader (fast, simple UEFI)
- **Wine + Bottles** for Windows apps
- **Doom Emacs** + **Zed** editors
- **Vulkan/Intel GPU** optimizations
- Full **performance tuning** (kernel, CPU, memory, SSD, battery)

---

## Requirements

- ThinkPad T480s (or similar Intel 8th gen UHD 620)
- UEFI boot mode
- Secure Boot **disabled** in BIOS
- No disk encryption (ext4 root)
- Internet connection (ethernet recommended for install)
- 8GB+ RAM recommended

---

## BIOS Settings (ThinkPad T480s)

Before installing, configure BIOS (F1 on boot):

```
Security → Secure Boot → Disabled
Security → Intel SGX → Disabled
Config → Power → Intel SpeedStep → Enabled
Config → Power → CPU Power Management → Enabled
Config → Thunderbolt → Security Level → No Security (if using TB)
Startup → UEFI/Legacy Boot → UEFI Only
```

---

## Installation Methods

### Method 1: archinstall (Recommended - Easiest)

#### 1. Boot Arch ISO & Run archinstall
```bash
# Boot Arch ISO, verify UEFI
ls /sys/firmware/efi/efivars

# Run archinstall with our profile
archinstall --config ~/FckIt/archinstall-profile.json
# Or copy profile first: cp ~/FckIt/archinstall-profile.json /tmp/ && archinstall --config /tmp/archinstall-profile.json
```

**Note**: You'll need to copy the profile to the ISO environment first. Easiest way:
```bash
# On another machine, upload profile to a gist/pastebin, then on ISO:
curl -L <your-gist-url> -o /tmp/archinstall-profile.json
archinstall --config /tmp/archinstall-profile.json
```

Or run `archinstall` interactively and select:
- Disk: `/dev/nvme0n1` → 512M ESP + rest ext4
- No bootloader
- Hostname: `t480s`
- User: `giorgos` (wheel, video, docker, seat, zsh)
- Packages: (see profile for full list)
- Services: NetworkManager, bluetooth, power-profiles-daemon, thermald, tlp

#### 2. Reboot & Run Post-Install Script
```bash
# Login as your user
git clone https://github.com/youruser/FckIt.git ~/FckIt
cd ~/FckIt
chmod +x bootstrap-post-archinstall.sh
./bootstrap-post-archinstall.sh

# Reboot when done
sudo reboot
```

---

### Method 2: Manual Install (Full Control)

<details>
<summary>Click to expand manual installation steps</summary>

#### Step 1: Boot Arch Linux ISO
```bash
# Write ISO to USB
sudo dd if=archlinux-*.iso of=/dev/sdX bs=4M status=progress && sync
```

#### Step 2: Network & Time
```bash
ping archlinux.org
timedatectl set-ntp true
```

#### Step 3: Partition Disk
```bash
wipefs -a /dev/nvme0n1
parted /dev/nvme0n1 --script \
  mklabel gpt \
  mkpart ESP fat32 1MiB 513MiB \
  set 1 esp on \
  mkpart root ext4 513MiB 100%
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2
mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
```

#### Step 4: Base Install
```bash
pacstrap -K /mnt base linux linux-firmware intel-ucode \
  networkmanager sudo git base-devel vim man-db man-pages texinfo
genfstab -U /mnt >> /mnt/etc/fstab
```

#### Step 5: System Configuration (chroot)
```bash
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Europe/Athens /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "el_GR.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "t480s" > /etc/hostname
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   t480s.localdomain t480s
EOF
passwd
useradd -m -G wheel,video,docker,seat -s /bin/zsh giorgos
passwd giorgos
EDITOR=vim visudo  # Uncomment %wheel ALL=(ALL:ALL) ALL
systemctl enable NetworkManager
exit
umount -R /mnt
reboot
```

#### Step 6: Post-Reboot Setup
```bash
git clone https://github.com/youruser/FckIt.git ~/FckIt
cd ~/FckIt
chmod +x bootstrap.sh
./bootstrap.sh
sudo reboot
```
</details>

---

## What bootstrap-post-archinstall.sh Does

Since archinstall handles base system, this script only does the F#ckIt! customization:

1. **Installs yay** (AUR helper)
2. **Installs overlay packages** (Minflair extras, Wine, Vulkan, Editors, ThinkPad, Performance)
3. **Installs Bottles** (Flatpak)
4. **Installs Zed Editor** (official script)
5. **Installs Doom Emacs** (git clone + doom install)
6. **Installs Minflair v2.0.1** (Hyprland + Quickshell + SDDM)
7. **Installs Limine** to ESP partition
8. **Stows configs** (user + system via sudo)
9. **Runs setup scripts** (ThinkPad, performance, gaming, editors)
10. **Enables systemd services** (zram, earlyoom, fstrim, battery-threshold, preload, cpupower)
11. **Rebuilds initramfs** with i915 firmware
12. **Updates Limine**

---

## Post-Install Verification

```bash
# Bootloader
limine-install --info /dev/nvme0n1

# Vulkan
vulkaninfo | grep -iE "device name|driver version|vulkan version"

# Intel GPU
intel_gpu_top

# Battery thresholds (should show 75 / 80)
cat /sys/class/power_supply/BAT0/charge_start_threshold
cat /sys/class/power_supply/BAT0/charge_stop_threshold

# zram
zramctl

# earlyoom
systemctl status earlyoom

# Minflair/Quickshell logs
qs log

# ThinkPad sensors
sensors
```

---

## Key Bindings (Minflair + Custom)

| Key | Action |
|-----|--------|
| `Super + Return` | Kitty terminal |
| `Super + Shift + Return` | Dropdown terminal |
| `Super + E` | Zed editor |
| `Super + Shift + E` | Doom Emacs |
| `Super + B` | Firefox |
| `Super + F` | Yazi file manager |
| `Super + Space` | App launcher |
| `Super + G` | Gaming mode ON |
| `Super + Shift + G` | Gaming mode OFF |
| `Super + Delete` | Power menu |
| `Print` | Screenshot region → clipboard |
| `Shift + Print` | Screenshot region → file |
| `Super + Shift + R` | Reload Hyprland |
| `Super + Shift + Q` | Reload Quickshell |

---

## Maintenance

```bash
# Full system update
yay -Syu

# Update Minflair
cd ~/.dotfiles && git pull && ./install.sh --update

# Update dotfiles
cd ~/FckIt && git pull
stow -d stow -t ~ hypr quickshell emacs zed user
sudo stow -d stow -t / system

# After kernel update
sudo mkinitcpio -P
sudo limine-install /dev/nvme0n1

# Cleanup
yay -Sc
paccache -r
journalctl --vacuum-time=2weeks
```

---

## Troubleshooting

### Minflair issues
```bash
qs log
systemctl --user restart quickshell
```

### Limine not booting
```bash
# From live USB
mount /dev/nvme0n1p2 /mnt
mount /dev/nvme0n1p1 /mnt/boot
arch-chroot /mnt
limine-install /dev/nvme0n1
```

### Battery thresholds not working
```bash
lsmod | grep thinkpad
echo 75 | sudo tee /sys/class/power_supply/BAT0/charge_start_threshold
echo 80 | sudo tee /sys/class/power_supply/BAT0/charge_stop_threshold
```

### Vulkan not working
```bash
VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/intel_icd.x86_64.json vulkaninfo
cat /sys/module/i915/parameters/enable_guc
cat /sys/module/i915/parameters/enable_psr
```

### Audio issues
```bash
systemctl --user restart pipewire wireplumber
```

---

## Structure

```
FckIt/
├── archinstall-profile.json    # archinstall profile
├── bootstrap-post-archinstall.sh  # Post-archinstall setup (USE THIS)
├── bootstrap.sh                # Full manual install (alternative)
├── packages/                   # Package lists (7 files)
├── config/
│   ├── limine/limine.conf      # Limine config
│   ├── hypr/                   # Hyprland overlays
│   ├── quickshell/             # Quickshell user config
│   ├── emacs/                  # Doom Emacs config
│   ├── zed/settings.json       # Zed settings
│   ├── system/                 # /etc configs
│   └── user/                   # User configs (~)
├── scripts/                    # Setup scripts (5 files)
├── stow/                       # Symlink farm
└── docs/README.md
```

---

## License

MIT — Do whatever the fuck you want.