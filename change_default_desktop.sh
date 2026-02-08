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

echo -e "\e[1;36m🖥 Change Default Desktop Session\e[0m"
echo ""
log_info "Starting desktop session change"

if [ ! -f /usr/bin/steamos-session-select ]; then
  msg_warning "/usr/bin/steamos-session-select not found on this system."
  msg_info "This file will be created now..."
  log_warn "steamos-session-select not found"
fi

# Get available desktops using library function
available_desktops=$(get_available_desktops)

if [ -z "$available_desktops" ]; then
    msg_error "No wayland session for desktop mode was found on your system."
    log_error "No wayland sessions found"
    exit 1
fi

# Use interactive selection
selected_de=$(select_desktop_session_interactive)
if [ -z "$selected_de" ]; then
    msg_error "No desktop session selected."
    log_error "User cancelled desktop selection"
    exit 1
fi

echo ""
log_info "User selected desktop session: $selected_de"

# Install steamos-session-select with new desktop session
start_spinner "Updating steamos-session-select"
if ! install_steamos_session_select "$selected_de" >/dev/null 2>&1; then
    stop_spinner 1 "" "Failed to update steamos-session-select"
    msg_error "Failed to update steamos-session-select"
    log_error "Failed to update steamos-session-select"
    exit 1
fi
stop_spinner 0 "Desktop session updated successfully"

msg_success "'$selected_de' is now the default desktop session"
log_info "Desktop session changed successfully to: $selected_de"
echo ""
