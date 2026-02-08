#!/bin/bash
# Decky Loader Setup Script for Arch-Deckify
# Version: 1.0.0

# Source common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/lib/common.sh" ]]; then
    source "${SCRIPT_DIR}/lib/common.sh"
fi

log_info "Starting Decky Loader installation"

# Install dependencies
echo "Installing dependencies..."
log_info "Installing jq dependency"
sudo pacman -S jq --noconfirm || exit 1

# Download and install Decky Loader
# Note: For security, download to a temp file first, then execute
echo "Downloading Decky Loader installer..."
TEMP_INSTALLER="/tmp/decky_install_$$.sh"

log_info "Downloading Decky Loader installer to ${TEMP_INSTALLER}"
if ! curl -L -o "${TEMP_INSTALLER}" https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh; then
    log_error "Failed to download Decky Loader installer"
    echo -e "\e[91mError:\e[0m Failed to download installer"
    rm -f "${TEMP_INSTALLER}"
    exit 1
fi

# Execute the installer
echo "Running Decky Loader installer..."
log_info "Executing Decky Loader installer"
if ! sh "${TEMP_INSTALLER}"; then
    log_error "Decky Loader installation failed"
    echo -e "\e[91mError:\e[0m Installation failed"
    rm -f "${TEMP_INSTALLER}"
    exit 1
fi

# Clean up
rm -f "${TEMP_INSTALLER}"

# Configure systemd service
echo "Configuring Decky Loader service..."
log_info "Configuring plugin_loader.service"
sudo sed -i 's~TimeoutStopSec=.*$~TimeoutStopSec=2~g' /etc/systemd/system/plugin_loader.service || exit 1
sudo systemctl daemon-reload || exit 1
sudo systemctl restart plugin_loader.service || exit 1

echo "Installed Decky Loader."
log_info "Decky Loader installation completed successfully"