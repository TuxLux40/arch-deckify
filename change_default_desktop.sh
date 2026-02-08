#!/bin/bash
# Change Default Desktop Script for Arch-Deckify
# Version: 1.0.0

# Source common libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/lib/common.sh" ]]; then
    source "${SCRIPT_DIR}/lib/common.sh"
fi
if [[ -f "${SCRIPT_DIR}/lib/steamos_session.sh" ]]; then
    source "${SCRIPT_DIR}/lib/steamos_session.sh"
fi

log_info "Starting desktop session change"

if [ ! -f /usr/bin/steamos-session-select ]; then
  echo -e "\e[31m[ERROR] \e[0m/usr/bin/steamos-session-select not found on this system. The script may have been deleted, not installed, or interrupted during installation for some reason. If the installation is incomplete, please install again. This script will create this file again now."
  log_warn "steamos-session-select not found"
fi

# Get available desktops using library function
available_desktops=$(get_available_desktops)

if [ -z "$available_desktops" ]; then
    echo -e "\e[31m[ERROR] \e[0mNo wayland session for desktop mode was found on your system."
    log_error "No wayland sessions found"
    exit 1
fi

while true; do
    echo -e "\n\e[95mCurrent Wayland sessions in the system:\n\e[0m"
    echo "$available_desktops"
    echo -e "\n\e[95mWhich one should be used when switching from Steam to desktop mode?\n\e[0m"
    read -r -p "Enter a session name: " user_choice

    if validate_desktop_session "$user_choice"; then
        selected_de="$user_choice"
        log_info "User selected desktop session: $selected_de"
        
        # Install steamos-session-select with new desktop session
        if ! install_steamos_session_select "$selected_de"; then
            echo -e "\e[31m[ERROR]\e[0m Failed to update steamos-session-select"
            log_error "Failed to update steamos-session-select"
            exit 1
        fi
        
        echo -e "\e[93m'$user_choice' is selected.\e[0m\n"
        log_info "Desktop session changed successfully to: $selected_de"
        break
    else
        echo -e "\n\e[31m[ERROR] \e[93m No desktop named '$user_choice' found.\e[0m\n\n"
        log_warn "Invalid desktop selection: $user_choice"
    fi
done
