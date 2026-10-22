#!/bin/bash
# setup-editors.sh - Doom Emacs and Zed configuration

set -euo pipefail

log() { echo -e "\033[0;32m[+]\033[0m $*"; }
warn() { echo -e "\033[1;33m[!]\033[0m $*"; }

log "Setting up editors..."

# Doom Emacs sync
log "Syncing Doom Emacs..."
if [[ -d ~/.config/emacs ]]; then
    ~/.config/emacs/bin/doom sync 2>/dev/null || warn "Doom sync failed"
    ~/.config/emacs/bin/doom doctor 2>/dev/null || warn "Doom doctor found issues"
else
    warn "Doom Emacs not installed"
fi

# Zed config
log "Configuring Zed..."
mkdir -p ~/.config/zed
if [[ -f config/zed/settings.json ]]; then
    cp config/zed/settings.json ~/.config/zed/settings.json
    log "Zed settings applied"
else
    warn "Zed settings.json not found"
fi

# Install Zed themes
log "Installing Catppuccin theme for Zed..."
# Zed themes are built-in, Catppuccin Mocha is included

log "Editors setup complete!"
info "Doom Emacs: run 'doom sync' after config changes"
info "Zed: restart to apply settings"