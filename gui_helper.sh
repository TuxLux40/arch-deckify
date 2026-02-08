#!/bin/bash
# GUI Helper for Arch-Deckify
# Version: 1.0.0

# Source common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/steamos_session.sh"

log_info "Starting Arch-Deckify GUI Helper"

# Decky Loader path
PLUGIN_LOADER_PATH="${HOME}/homebrew"

# Ensure sudo access with proper credential caching
# This function validates sudo access once and relies on sudo's own credential caching
ensure_sudo() {
    if sudo -n true 2>/dev/null; then
        return 0
    fi

    while true; do
        local password
        password=$(zenity --password --title="Authentication Required" 2>/dev/null)
        
        if [[ -z "$password" ]]; then
            log_warn "User cancelled sudo authentication"
            return 1
        fi
        
        # Validate credentials and extend sudo timeout
        if echo "$password" | sudo -S -v >/dev/null 2>&1; then
            log_info "Sudo credentials validated successfully"
            # Password is no longer needed, sudo will cache it
            return 0
        else
            zenity --error --text="Wrong password. Please try again." 2>/dev/null
        fi
    done
}

# Run command with sudo (relies on sudo credential caching)
run_with_sudo() {
    if ! sudo -n true 2>/dev/null; then
        if ! ensure_sudo; then
            log_error "Failed to obtain sudo privileges"
            return 1
        fi
    fi
    
    log_debug "Running with sudo: $*"
    sudo "$@"
}

# Check if zenity is installed
if ! pacman -Qs zenity > /dev/null; then
    log_info "zenity not found, installing..."
    if ensure_sudo; then
        run_with_sudo pacman -S zenity --noconfirm || exit 1
    else
        log_error "Cannot install zenity without sudo privileges"
        exit 1
    fi
fi

while true; do
    allTools=(
        "Update System" "Updates all system packages"
        "Change Default Desktop" "Set your preferred desktop session"
    )

    if [ ! -d "$PLUGIN_LOADER_PATH" ]; then
        allTools+=("Install Decky Loader" "Install plugin loader for Steam")
    else
        allTools+=("Reinstall Decky Loader" "Reinstall plugin loader for Steam")
        allTools+=("Remove Decky Loader" "Remove plugin loader for Steam")
    fi

    if ! flatpak remote-list 2>/dev/null | grep -q '^flathub'; then
        allTools+=("Install Flathub" "Enable GUI application support")
    fi
    allTools+=("Additional Settings" "Additional settings for your system")
    allTools+=("Uninstall Script" "Uninstall Arch Deckify script")
    params=()
    for ((i=0; i<${#allTools[@]}; i+=2)); do
        params+=("FALSE" "${allTools[i]}" "${allTools[i+1]}")
    done

    SELECTION=$(zenity --title "Deckify Helper" \
        --list --radiolist \
        --height=500 --width=600 \
        --text="Please select the action you want to perform:" \
        --column "" --column "Component" --column "Description" \
        "${params[@]}")

    if [ $? -ne 0 ]; then
        echo "Cancelled."
        exit 1
    fi

    case "$SELECTION" in
        "Update System")
            ensure_sudo
            (
            echo "# Updating system packages..."
            yay -Syu --noconfirm --sudoloop || paru -Syu --noconfirm
            if flatpak --version &> /dev/null; then echo "# Updating flatpak packages..."; flatpak update -y; fi
            ) | zenity --progress --title="Updating System" --width=500 --auto-close --pulsate --no-cancel
            zenity --info --text="System was updated."
            ;;
        "Change Default Desktop")
    # Get available desktops using library function
    available_desktops=$(get_available_desktops)
    
    if [ -z "$available_desktops" ]; then
        zenity --error --text="No desktop sessions found."
        log_error "No desktop sessions found"
        break
    fi

    # Build params array for zenity
    params=()
    while IFS= read -r session; do
        params+=("$session" "$session")
    done <<< "$available_desktops"

    while true; do
        selected_de=$(zenity --list --radiolist --title="Select Default Desktop" \
            --height=400 --width=400 \
            --text="Choose your default desktop session:" \
            --column "Select" --column "Session" "${params[@]}")

        if [ $? -ne 0 ]; then
            log_info "User cancelled desktop selection"
            break
        fi

        if [ -z "$selected_de" ]; then
            zenity --warning --text="Please select a desktop."
            continue
        fi

        break
    done

    if [ -z "$selected_de" ]; then
        break
    fi

    ensure_sudo
    log_info "Installing steamos-session-select for desktop: $selected_de"
    
    if install_steamos_session_select "$selected_de"; then
        zenity --info --text="Default desktop session set to '${selected_de}'"
        log_info "Desktop session changed to: $selected_de"
    else
        zenity --error --text="Failed to set default desktop session"
        log_error "Failed to install steamos-session-select"
    fi
    ;;

        "Install Decky Loader")
            zenity --question --title="Install Decky Loader" \
                --text="Install the Decky Loader?\n\nThis is an UNOFFICIAL tool to enhance Steam with plugins. Proceed with caution."

            if [ $? -eq 0 ]; then
                ensure_sudo
                (
                    echo "# Installing dependencies..."
                    run_with_sudo pacman -S jq --noconfirm
                    echo "# Executing install script..."
                    curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh | sh
                    echo "# Restarting systemd service..."
                    run_with_sudo systemctl daemon-reexec
                    run_with_sudo systemctl restart plugin_loader.service
                ) | zenity --progress --title="Installing Decky Loader" --width=500 --auto-close --pulsate --no-cancel

                if [ -d "$PLUGIN_LOADER_PATH" ]; then
                    zenity --info --text="Decky Loader installed successfully."
                else
                    zenity --error --text="Decky Loader installation failed."
                fi
            fi
            ;;
        "Reinstall Decky Loader")
            ensure_sudo
            (
                echo "# Installing dependencies..."
                run_with_sudo pacman -S jq --noconfirm
                echo "# Executing install script..."
                curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh | sh
                echo "# Restarting systemd service..."
                run_with_sudo systemctl daemon-reexec
                run_with_sudo systemctl restart plugin_loader.service

            ) | zenity --progress --title="Reinstalling Decky Loader" --width=500 --auto-close --pulsate --no-cancel
            if [ -d "$PLUGIN_LOADER_PATH" ]; then
                zenity --info --text="Decky Loader reinstalled successfully."
            else
                zenity --error --text="Decky Loader reinstallation failed."
            fi
            ;;
        "Remove Decky Loader")

            ensure_sudo
            (
            echo "# Running uninstall script..."
            curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/uninstall.sh | sh
            run_with_sudo systemctl stop plugin_loader.service
            run_with_sudo rm -rf "${HOME}/homebrew"
            ) | zenity --progress --title="Uninstalling Decky Loader" --width=500 --auto-close --pulsate --no-cancel
            zenity --info --text="Decky Loader uninstalled."
            ;;
        "Uninstall Script")
            zenity --question --title="Uninstall Deckify Script" \
                --text="Are you sure to uninstall this script?\n\nThese will be REMOVED from your system (if installed):\n\n- Gamescope session\n- Gamescope package\n- Decky Loader\n- Gaming mode shortcuts\n- SDDM autologin (will be disabled)\n\nThese will NOT BE REMOVED from your system:\n\n- Steam\n- MangoHUD\n- Flatpak\n- Yay/Paru (AUR Helper)\n- ntfs-3g (NTFS Drivers)\n- Bluetooth services\n- KDE Plasma configs/themes etc."

            if [ $? -eq 0 ]; then
                ensure_sudo
                (
                echo "# Removing gamescope-session-steam-git..."
                yay -Rns --noconfirm gamescope-session-steam-git || paru -Rns --noconfirm gamescope-session-steam-git
                sleep 1
                echo "# Removing arch-deckify..."
                run_with_sudo rm -rf "/etc/sudoers.d/sddm_config_edit"
                rm -rf "${HOME}/arch-deckify"
                sleep 1
                echo "# Removing gamescope..."
                run_with_sudo pacman -R gamescope
                echo "# Removing shortcuts.."
                rm -rf "$(xdg-user-dir DESKTOP)/Return_to_Gaming_Mode.desktop"
                rm -rf "/usr/share/applications/Return_to_Gaming_Mode.desktop"
                rm -rf "$(xdg-user-dir DESKTOP)/Deckify_Tools.desktop"
                rm -rf "/usr/share/applications/Deckify_Tools.desktop"
                sleep 1
                if [ -d "$HOME/homebrew" ]; then
                    echo "# Uninstalling Decky Loader..."
                    curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/uninstall.sh | sh
                    run_with_sudo systemctl stop plugin_loader.service
                    run_with_sudo rm -rf "${HOME}/homebrew"
                else
                    echo "Decky Loader is not installed."
                fi
                echo "# Disabling SDDM autologin..."
                CONFIG_FILE="/etc/sddm.conf"
                sudo sed -i "s/^Relogin=true/Relogin=false/; s/^User=.*/User=/; s/^Session=.*/Session=/" "$CONFIG_FILE"
                sleep 1
                ) | zenity --progress --title="Uninstalling Script" --width=500 --auto-close --pulsate --no-cancel
                zenity --info --text="Deckify Script was uninstalled."
                exit
            fi
            ;;
        "Install Flathub")
            ensure_sudo
            (
                echo "# Installing Flatpak and Flathub..."
                run_with_sudo pacman -S flatpak --noconfirm
                run_with_sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            ) | zenity --progress --title="Installing Flathub" --width=500 --auto-close --pulsate --no-cancel

            if flatpak remote-list | grep -q '^flathub'; then
                zenity --info --text="Flathub installed successfully."
            else
                zenity --error --text="Failed to install Flathub."
            fi
            ;;
        "Additional Settings")
            ADDSET_SELECTION=$(zenity --title "Deckify Additional Settings" \
                --list --radiolist \
                --height=500 --width=600 \
                --text="Please select the action you want to perform:" \
                --column "" --column "Component" --column "Description" \
                "FALSE" "Install KDE Presets" "Install SteamOS KDE Plasma themes/configs")
                case "$ADDSET_SELECTION" in
                "Install KDE Presets")
                    zenity --question --text="The latest SteamOS KDE presets will be installed from the link below:
https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-main/os/x86_64/.
This includes themes like 'Vapor' and the 'Add to Steam' option for right-clicked apps, along with other settings that mirror SteamOS.
    Note: This is designed for SteamOS and may cause issues on your device.
⚠️ The downloaded file will merge with your system’s root directories (e.g., /etc/, /usr/). Conflicts may disrupt your system. Please check compatibility before proceeding.
Are you sure you want to continue?"

                if [ $? -eq 0 ]; then
                    ensure_sudo
                    (
                    echo "# Looking for latest version..."
                    url="https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-main/os/x86_64/"
                    files=$(curl -s "$url" | grep -oP 'steamdeck-kde-presets-[\d\.]+-[\d]+-any\.pkg\.tar\.zst')
                    latest=$(echo "$files" | sort -V | tail -n1)
                    if [ -z "$latest" ]; then
                        zenity --error --text="Cannot fetch the latest version of KDE presets."
                        exit 1
                    fi

                    echo "# Downloading latest version..."
                    echo "Latest steamdeck-kde-presets package is: $latest"
                    echo "Downloading..."
                    mkdir -p "${HOME}/arch-deckify"
                    curl -o "${HOME}/arch-deckify/${latest}" "${url}${latest}"
                    echo "Downloaded: $latest"
                    echo "# Installing latest version..."
                    sudo tar -I zstd -xvf  "${HOME}/arch-deckify/${latest}" -C /
                    rm -rf "${HOME}/arch-deckify/${latest}"
                    ) | zenity --progress --title="Installing KDE Presets" --width=500 --auto-close --pulsate --no-cancel
                    zenity --info --text="KDE presets was installed."

                fi
                    ;;
                *)
                echo "Unknown selection."
                ;;
                esac

            ;;
        *)
            echo "Unknown selection."
            ;;
    esac
done
