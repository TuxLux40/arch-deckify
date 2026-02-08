#!/usr/bin/bash
# SteamOS Session Select script generation library
# Version: 1.0.0

# Generate steamos-session-select script content
# Usage: generate_steamos_session_select <desktop_session_name>
generate_steamos_session_select() {
    local selected_de="$1"
    
    if [[ -z "${selected_de}" ]]; then
        echo "Error: Desktop session name is required" >&2
        return 1
    fi
    
    cat << 'EOF'
#!/usr/bin/bash

CONFIG_FILE="/etc/sddm.conf"

# If no arguments are provided, list valid arguments
if [ $# -eq 0 ]; then
    echo "Valid arguments: plasma, gamescope"
    exit 0
fi

# If the argument is "plasma"
# IMPORTANT: If you want to use a desktop environment other than KDE Plasma, do not change the IF command. 
# Steam always runs this file as "steamos-session-select plasma" to switch to the desktop. 
# Instead, change the code below that edits the config file.

if [ "$1" == "plasma" ] || [ "$1" == "desktop" ]; then
    
    echo "Switching session to Desktop."
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "SDDM config file could not be found at ${CONFIG_FILE}."
        exit 1
    fi
EOF
    echo "    NEW_SESSION='${selected_de}' # For other desktops, change here."
    cat << 'EOF'
    sudo sed -i "s/^Session=.*/Session=${NEW_SESSION}/" "$CONFIG_FILE" || exit 1
    steam -shutdown

# If the argument is "gamescope"
elif [ "$1" == "gamescope" ]; then
    
    echo "Switching session to Gamescope."
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "SDDM config file could not be found at ${CONFIG_FILE}."
        exit 1
    fi
    NEW_SESSION="gamescope-session-steam"
    sudo sed -i "s/^Session=.*/Session=${NEW_SESSION}/" "$CONFIG_FILE" || exit 1
    dbus-send --session --type=method_call --print-reply --dest=org.kde.Shutdown /Shutdown org.kde.Shutdown.logout || gnome-session-quit --logout --no-prompt || cinnamon-session-quit --logout --no-prompt || loginctl terminate-session "$XDG_SESSION_ID"
else
    echo "Valid arguments are: plasma, gamescope."
    exit 1
fi
EOF
}

# Install steamos-session-select script
# Usage: install_steamos_session_select <desktop_session_name>
install_steamos_session_select() {
    local selected_de="$1"
    
    if [[ -z "${selected_de}" ]]; then
        echo "Error: Desktop session name is required" >&2
        return 1
    fi
    
    # Generate and install the script
    if ! generate_steamos_session_select "${selected_de}" | sudo tee /usr/bin/steamos-session-select > /dev/null; then
        echo "Error: Failed to create /usr/bin/steamos-session-select" >&2
        return 1
    fi
    
    # Make it executable
    if ! sudo chmod +x /usr/bin/steamos-session-select; then
        echo "Error: Failed to make /usr/bin/steamos-session-select executable" >&2
        return 1
    fi
    
    return 0
}

# Get available desktop sessions
# Returns a list of desktop session names (one per line)
get_available_desktops() {
    find /usr/share/wayland-sessions/ -maxdepth 1 -name "*.desktop" 2>/dev/null \
        | sed 's|.*/||; s/\.desktop$//' \
        | grep -v 'gamescope' \
        || true
}

# Validate desktop session name
# Usage: validate_desktop_session <session_name>
validate_desktop_session() {
    local session_name="$1"
    local available_desktops
    
    available_desktops=$(get_available_desktops)
    
    if [[ -z "${available_desktops}" ]]; then
        echo "Error: No desktop sessions found" >&2
        return 1
    fi
    
    if echo "${available_desktops}" | grep -q -w "^${session_name}$"; then
        return 0
    else
        return 1
    fi
}
