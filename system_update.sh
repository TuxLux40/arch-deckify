#!/bin/bash
# System Update Script for Arch-Deckify
# Version: 1.0.0
# This script updates system packages using yay or paru, and optionally updates Flatpak packages

# Detect AUR helper (yay or paru)
detect_aur_helper() {
    if command -v yay &>/dev/null; then
        echo "yay"
    elif command -v paru &>/dev/null; then
        echo "paru"
    else
        echo ""
    fi
}

# Get update command for the detected AUR helper
get_update_command() {
    local helper="$1"
    case "$helper" in
        yay)
            echo "yay -Syu --sudoloop --noconfirm"
            ;;
        paru)
            echo "paru -Syu --noconfirm"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Main update logic executed in terminal
run_update() {
    clear
    echo -e '\n\n\e[94mEnter your sudo password:\nYou can open keyboard by pressing GUIDE+X or PS+SQUARE on controller.\n\n\e[0m'
    
    # Remove stale pacman lock file
    sudo rm -rf /var/lib/pacman/db.lck || exit 1
    
    # Run system update
    $UPDATE_CMD || exit 1
    echo -e '\n\e[96mSystem packages have been updated.\e[0m'
    
    # Update Flatpak if available
    if flatpak --version &>/dev/null; then
        echo -e '\n\e[96mUpdating Flathub...\e[0m'
        flatpak update -y || exit 1
        echo -e '\e[93mFlatpak updated.\e[0m'
    else
        echo 'Skipped Flatpak (not installed).'
    fi
    
    echo -e '\e[93mFinished. This window will be closed in 5 seconds...\e[0m'
    sleep 5
}

# Try to launch update in available terminal emulator
launch_in_terminal() {
    # Export the update command and function for use in subshells
    export UPDATE_CMD="$1"
    export -f run_update
    
    # Try konsole
    if command -v konsole &>/dev/null; then
        konsole -e bash -c "run_update"
        return $?
    fi
    
    # Try gnome-terminal
    if command -v gnome-terminal &>/dev/null; then
        gnome-terminal -- bash -c "run_update"
        return $?
    fi
    
    # Try kgx (GNOME Console)
    if command -v kgx &>/dev/null; then
        kgx -- bash -c "run_update"
        return $?
    fi
    
    # Try kitty
    if command -v kitty &>/dev/null; then
        kitty bash -c "run_update"
        return $?
    fi
    
    # Try alacritty
    if command -v alacritty &>/dev/null; then
        alacritty -e bash -c "run_update"
        return $?
    fi
    
    # No terminal found
    echo -e "\e[91mError: No supported terminal emulator found.\e[0m"
    echo "Please install one of: konsole, gnome-terminal, kgx, kitty, or alacritty"
    return 1
}

# Main script execution
main() {
    # Detect AUR helper
    AUR_HELPER=$(detect_aur_helper)
    
    if [[ -z "$AUR_HELPER" ]]; then
        echo -e "\e[91mError: Neither yay nor paru is installed.\e[0m"
        sleep 10
        exit 1
    fi
    
    # Get update command
    UPDATE_CMD=$(get_update_command "$AUR_HELPER")
    
    # Launch update in terminal
    launch_in_terminal "$UPDATE_CMD" || exit 1
}

# Run main function
main
