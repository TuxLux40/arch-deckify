#!/bin/bash
# Remove Decky Loader Script for Arch-Deckify
# Version: 1.0.0

# Source common library for colors and icons
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/lib/common.sh" ]]; then
    source "${SCRIPT_DIR}/lib/common.sh"
fi

echo -e "\e[1;31m⚠ Decky Loader Uninstallation\e[0m"
echo ""
read -p "$(echo -e '\e[33m')Do you really want to uninstall Decky Loader? (y/n): $(echo -e '\e[0m')" confirm

if [[ $confirm == "y" || $confirm == "Y" ]]; then
    msg_info "Downloading uninstaller..."
    curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/uninstall.sh | sh
else
    msg_info "Uninstallation cancelled."
fi
