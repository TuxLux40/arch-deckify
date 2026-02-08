#!/bin/bash
# Decky Loader Setup Script for Arch-Deckify
# Version: 1.0.0

# Source common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/lib/common.sh" ]]; then
    source "${SCRIPT_DIR}/lib/common.sh"
fi

echo -e "\e[1;36m📦 Decky Loader Setup\e[0m"
echo ""
log_info "Starting Decky Loader installation"

# Install dependencies
msg_step 1 3 "📦 Installing dependencies"
log_info "Installing jq dependency"
start_spinner "Installing jq"
sudo pacman -S jq --noconfirm >/dev/null 2>&1 || exit 1
stop_spinner 0 "jq installed successfully"

# Download and install Decky Loader
# Note: For security, download to a temp file first, then execute
msg_step 2 3 "⬇ Downloading Decky Loader installer"
TEMP_INSTALLER="/tmp/decky_install_$$.sh"

log_info "Downloading Decky Loader installer to ${TEMP_INSTALLER}"
start_spinner "Downloading Decky Loader installer"
if ! curl -L -o "${TEMP_INSTALLER}" https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh 2>/dev/null; then
    stop_spinner 1 "" "Failed to download installer"
    log_error "Failed to download Decky Loader installer"
    msg_error "Failed to download installer"
    rm -f "${TEMP_INSTALLER}"
    exit 1
fi
stop_spinner 0 "Installer downloaded successfully"

# Execute the installer
msg_info "Running Decky Loader installer..."
log_info "Executing Decky Loader installer"
start_spinner "Installing Decky Loader"
if ! sh "${TEMP_INSTALLER}" >/dev/null 2>&1; then
    stop_spinner 1 "" "Installation failed"
    log_error "Decky Loader installation failed"
    msg_error "Installation failed"
    rm -f "${TEMP_INSTALLER}"
    exit 1
fi
stop_spinner 0 "Decky Loader installed successfully"

# Clean up
rm -f "${TEMP_INSTALLER}"

# Configure systemd service
msg_step 3 3 "🔧 Configuring Decky Loader service"
log_info "Configuring plugin_loader.service"
start_spinner "Configuring systemd service"
sudo sed -i 's~TimeoutStopSec=.*$~TimeoutStopSec=2~g' /etc/systemd/system/plugin_loader.service || exit 1
sudo systemctl daemon-reload >/dev/null 2>&1 || exit 1
sudo systemctl restart plugin_loader.service >/dev/null 2>&1 || exit 1
stop_spinner 0 "Service configured and restarted"

echo ""
msg_success "Decky Loader installation completed successfully!"
log_info "Decky Loader installation completed successfully"