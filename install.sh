#!/bin/bash
# Arch-Deckify Installation Script
# Version: 1.0.0

# Source common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/lib/common.sh" ]]; then
    source "${SCRIPT_DIR}/lib/common.sh"
fi
if [[ -f "${SCRIPT_DIR}/lib/steamos_session.sh" ]]; then
    source "${SCRIPT_DIR}/lib/steamos_session.sh"
fi

log_info "Starting Arch-Deckify installation"

if [ "$EUID" -eq 0 ]; then
    msg_error "Run this script WITHOUT root/sudo privileges."
    log_error "Script was run as root"
    exit 1
fi

echo -e "\e[1;36m"
echo "  █████╗ ██████╗  ██████╗██╗  ██╗    ██████╗ ███████╗ ██████╗██╗  ██╗██╗███████╗██╗   ██╗"
echo " ██╔══██╗██╔══██╗██╔════╝██║  ██║    ██╔══██╗██╔════╝██╔════╝██║ ██╔╝██║██╔════╝╚██╗ ██╔╝"
echo " ███████║██████╔╝██║     ███████║    ██║  ██║█████╗  ██║     █████╔╝ ██║█████╗   ╚████╔╝ "
echo " ██╔══██║██╔══██╗██║     ██╔══██║    ██║  ██║██╔══╝  ██║     ██╔═██╗ ██║██╔══╝    ╚██╔╝  "
echo " ██║  ██║██║  ██║╚██████╗██║  ██║    ██████╔╝███████╗╚██████╗██║  ██╗██║██║        ██║   "
echo " ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝    ╚═════╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝   "
echo -e "\e[0m"
echo -e "\e[1;33mWelcome to Arch Deckify v${ARCH_DECKIFY_VERSION}\e[0m"
echo ""
msg_warning "This script mostly does not work on NVIDIA cards."
msg_info "This script has been made to work only on SDDM."
msg_info "You must make additional changes for other display managers."
echo ""

start_spinner "🔍 Checking for SDDM"
if ! pacman -Qs sddm > /dev/null 2>&1; then
    stop_spinner 1 "" "SDDM not found"
    msg_error "SDDM is not installed. See: https://unlbslk.github.io/arch-deckify/issues/#what-is-the-sddm-and-how-can-i-install-it"
    log_error "SDDM not found on system"
    exit 1
else
    stop_spinner 0 "SDDM is installed"
    log_info "SDDM found on system"
fi

sudo whoami || exit 1
echo

# Get available desktops using the library function
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
msg_success "'$selected_de' is selected."
log_info "User selected desktop session: $selected_de"

msg_step 1 18 "📦 Checking for AUR helper (yay or paru)"

if command -v yay &> /dev/null; then
    msg_skip "Yay is already installed"
    log_info "yay is already installed"
elif command -v paru &> /dev/null; then
    msg_skip "Paru is already installed"
    log_info "paru is already installed"
else
    msg_info "Neither yay nor paru found. Installing yay..."
    log_info "Installing yay from AUR"
    
    start_spinner "⚙ Installing base-devel and git"
    sudo pacman -S --needed base-devel git --noconfirm >/dev/null 2>&1 || exit 1
    stop_spinner 0 "Dependencies installed"

    cd ~ || exit 1
    
    start_spinner "⬇ Cloning yay from AUR"
    git clone https://aur.archlinux.org/yay.git >/dev/null 2>&1 || exit 1
    stop_spinner 0 "Yay repository cloned"
    
    cd yay || exit 1
    
    start_spinner "🔨 Building and installing yay"
    makepkg -si --noconfirm >/dev/null 2>&1 || exit 1
    stop_spinner 0 "Yay built and installed"

    if command -v yay &> /dev/null; then
        msg_success "Yay has been successfully installed"
        log_info "yay installed successfully"
    else
        msg_error "Failed to install yay"
        log_error "Failed to install yay"
        exit 1
    fi
fi

msg_step 2 18 "🔧 Checking and enabling multilib repository"
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    start_spinner "Enabling multilib repository"
    log_info "Enabling multilib repository"
    echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf >/dev/null || exit 1
    stop_spinner 0 "Multilib repository enabled"
else
    msg_skip "Multilib repository is already enabled"
    log_info "multilib repository already enabled"
fi

msg_step 3 18 "🔄 Updating the system"
log_info "Running system update"
start_spinner "Updating system packages"
sudo pacman -Syu --noconfirm >/dev/null 2>&1 || exit 1
stop_spinner 0 "System updated successfully"

msg_step 4 18 "🎮 Checking if Steam is installed"
if ! command -v steam &> /dev/null; then
    start_spinner "Installing Steam"
    log_info "Installing Steam"
    sudo pacman -S steam --noconfirm >/dev/null 2>&1 || exit 1
    stop_spinner 0 "Steam installed successfully"
else
    msg_skip "Steam is already installed"
    log_info "Steam already installed"
fi

msg_step 5 18 "📦 Installing gamescope-session-steam-git from AUR"
log_info "Installing gamescope-session-steam-git"
start_spinner "Installing gamescope-session-steam-git (this may take a while)"
yay -S --aur gamescope-session-steam-git --noconfirm --sudoloop >/dev/null 2>&1 || paru -S --aur gamescope-session-steam-git --noconfirm >/dev/null 2>&1 || exit 1
stop_spinner 0 "gamescope-session-steam-git installed"

CONFIG_FILE="/etc/sddm.conf"
msg_step 6 18 "🔧 Configuring auto-login for SDDM"
start_spinner "Writing SDDM configuration"
sudo tee /etc/sddm.conf > /dev/null <<EOF
[Autologin]
Relogin=true
Session=$selected_de
User=$(whoami)

[General]
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot

[Theme]
Current=

[Users]
MaximumUid=60513
MinimumUid=1000
EOF
stop_spinner 0 "Autologin configured for user: $(whoami)"

msg_step 7 18 "🔨 Creating /usr/bin/steamos-session-select"
if ! install_steamos_session_select "$selected_de"; then
    msg_error "Failed to create /usr/bin/steamos-session-select"
    log_error "Failed to install steamos-session-select"
    exit 1
fi
log_info "steamos-session-select created successfully"
msg_success "steamos-session-select has been configured"

msg_step 8 18 "🔧 Making SDDM session config editable without sudo password"
sudoers_file="/etc/sudoers.d/sddm_config_edit"
if [ ! -f "$sudoers_file" ]; then
    start_spinner "Configuring sudoers for SDDM"
    echo "ALL ALL=(ALL) NOPASSWD: /usr/bin/sed -i s/^Session=*/Session=*/ ${CONFIG_FILE}" | sudo tee "$sudoers_file" > /dev/null
    sudo chmod 440 "$sudoers_file"
    stop_spinner 0 "Sudoers configured for SDDM"
else
    msg_skip "Passwordless sudo for editing SDDM session config is already set"
fi

msg_step 9 18 "📦 Installing MangoHUD"
if ! pacman -Qs mangohud > /dev/null; then
    start_spinner "Installing MangoHUD"
    sudo pacman -S mangohud --noconfirm >/dev/null 2>&1
    stop_spinner 0 "MangoHUD installed"
else
    msg_skip "MangoHUD is already installed"
fi

msg_step 10 18 "📦 Installing wget"
if ! pacman -Qs wget > /dev/null; then
    start_spinner "Installing wget"
    sudo pacman -S wget --noconfirm >/dev/null 2>&1
    stop_spinner 0 "wget installed"
else
    msg_skip "wget is already installed"
fi

msg_step 11 18 "📦 Installing ntfs-3g (required for NTFS drives)"
if ! pacman -Qs ntfs-3g > /dev/null; then
    start_spinner "Installing ntfs-3g"
    sudo pacman -S ntfs-3g --noconfirm >/dev/null 2>&1
    stop_spinner 0 "ntfs-3g installed"
else
    msg_skip "ntfs-3g is already installed"
fi

msg_step 12 18 "📦 Installing Gamescope"
if ! pacman -Qs gamescope > /dev/null; then
    start_spinner "Installing Gamescope"
    sudo pacman -S gamescope --noconfirm >/dev/null 2>&1
    stop_spinner 0 "Gamescope installed"
else
    msg_skip "Gamescope is already installed"
fi

msg_step 13 18 "🔧 Making the brightness slider work"
start_spinner "Configuring brightness controls"
sudo usermod -a -G video "$(whoami)" || exit 1
if ! grep -q 'ACTION=="add", SUBSYSTEM=="backlight"' /etc/udev/rules.d/backlight.rules 2>/dev/null; then
    echo 'ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp video $sys$devpath/brightness", RUN+="/bin/chmod g+w $sys$devpath/brightness"' | sudo tee -a /etc/udev/rules.d/backlight.rules > /dev/null || exit 1
fi
stop_spinner 0 "Brightness controls configured"
msg_step 14 18 "⬇ Downloading Gaming Mode shortcut icons"

start_spinner "Creating directory and downloading icons"
mkdir -p ~/arch-deckify

if [ ! -f ~/arch-deckify/steam-gaming-return.png ]; then
  wget -q -P ~/arch-deckify/ https://raw.githubusercontent.com/unlbslk/arch-deckify/refs/heads/main/icons/steam-gaming-return.png
fi
if [ ! -f ~/arch-deckify/helper.png ]; then
  wget -q -P ~/arch-deckify/ https://raw.githubusercontent.com/unlbslk/arch-deckify/refs/heads/main/icons/helper.png
fi
stop_spinner 0 "Icons downloaded successfully"

msg_step 15 18 "🖥 Creating desktop shortcuts"
start_spinner "Creating desktop and application menu entries"

# Desktop icon
if [ ! -e "$(xdg-user-dir DESKTOP)/Return_to_Gaming_Mode.desktop" ]; then
    echo "[Desktop Entry]
    Name=Gaming Mode
    Exec=steamos-session-select gamescope
    Icon=$HOME/arch-deckify/steam-gaming-return.png
    Terminal=false
    Type=Application
    StartupNotify=false" > "$(xdg-user-dir DESKTOP)/Return_to_Gaming_Mode.desktop"
fi

if [ ! -e "$(xdg-user-dir DESKTOP)/Deckify_Tools.desktop" ]; then
    echo "[Desktop Entry]
    Name=Deckify Helper
    Exec=bash -c 'curl -sSL https://raw.githubusercontent.com/unlbslk/arch-deckify/refs/heads/main/gui_helper.sh | bash'
    Icon=$HOME/arch-deckify/helper.png
    Terminal=true
    Type=Application
    StartupNotify=false" > "$(xdg-user-dir DESKTOP)/Deckify_Tools.desktop"
fi

chmod +x "$(xdg-user-dir DESKTOP)/Return_to_Gaming_Mode.desktop"
chmod +x "$(xdg-user-dir DESKTOP)/Deckify_Tools.desktop"

# Application
if [ ! -e "/usr/share/applications/Return_to_Gaming_Mode.desktop" ]; then
    echo "[Desktop Entry]
    Name=Gaming Mode
    Exec=steamos-session-select gamescope
    Icon=$HOME/arch-deckify/steam-gaming-return.png
    Terminal=false
    Type=Application
    StartupNotify=false" > "$(xdg-user-dir)/Return_to_Gaming_Mode.desktop"
    chmod +x "$(xdg-user-dir)/Return_to_Gaming_Mode.desktop"
    sudo cp "$(xdg-user-dir)/Return_to_Gaming_Mode.desktop" "/usr/share/applications/"
    rm -rf "$(xdg-user-dir)/Return_to_Gaming_Mode.desktop"
fi

if [ ! -e "/usr/share/applications/Deckify_Tools.desktop" ]; then
    echo "[Desktop Entry]
    Name=Deckify Helper
    Exec=bash -c 'curl -sSL https://raw.githubusercontent.com/unlbslk/arch-deckify/refs/heads/main/gui_helper.sh | bash'
    Icon=$HOME/arch-deckify/helper.png
    Terminal=true
    Type=Application
    StartupNotify=false" > "$(xdg-user-dir)/Deckify_Tools.desktop"
    chmod +x "$(xdg-user-dir)/Deckify_Tools.desktop"
    sudo cp "$(xdg-user-dir)/Deckify_Tools.desktop" "/usr/share/applications/"
    rm -rf "$(xdg-user-dir)/Deckify_Tools.desktop"
fi

stop_spinner 0 "Desktop shortcuts created"

msg_step 16 18 "🔧 Enabling Bluetooth service"
start_spinner "Installing and enabling Bluetooth"
sudo pacman -S bluez bluez-utils --noconfirm >/dev/null 2>&1
sudo systemctl enable bluetooth.service >/dev/null 2>&1
sudo systemctl start bluetooth.service >/dev/null 2>&1
stop_spinner 0 "Bluetooth service enabled and started"


msg_step 17 18 "🔨 Creating system update script"
start_spinner "Generating system_update.sh"

update_script_path="$HOME/arch-deckify/system_update.sh"
cat <<EOL > "$update_script_path"
#!/bin/bash
AUR_HELPER=""; UPDATE_CMD=""; command -v yay &>/dev/null && AUR_HELPER="yay" && UPDATE_CMD="yay -Syu --sudoloop --noconfirm" || { command -v paru &>/dev/null && AUR_HELPER="paru" && UPDATE_CMD="paru -Syu --noconfirm"; }; [ -z "\$AUR_HELPER" ] && echo -e "\e[91mError: Neither yay nor paru is installed.\e[0m" && sleep 10 && exit 1; (konsole -e bash -c "clear; echo -e '\n\n\e[94mEnter your sudo password:\nYou can open keyboard by pressing GUIDE+X or PS+SQUARE on controller.\n\n\e[0m'; sudo rm -rf /var/lib/pacman/db.lck; \$UPDATE_CMD; echo -e '\n\e[96mSystem packages have been updated.\e[0m'; if flatpak --version &>/dev/null; then echo -e '\n\e[96mUpdating Flathub...\e[0m'; flatpak update -y; echo -e '\e[93mFlatpak updated.\e[0m'; else echo 'Skipped Flatpak.'; fi; echo -e '\e[93mFinished. This window will be closed in 5 seconds...\e[0m'; sleep 5; exit") || (gnome-terminal -- bash -c "clear; echo -e '\n\n\e[94mEnter your sudo password:\nYou can open keyboard by pressing GUIDE+X or PS+SQUARE on controller.\n\n\e[0m'; sudo rm -rf /var/lib/pacman/db.lck; \$UPDATE_CMD; echo -e '\e[96mSystem packages have been updated.\e[0m'; if flatpak --version &>/dev/null; then echo -e '\n\e[96mUpdating Flathub...\e[0m'; flatpak update -y; echo -e '\e[93mFlatpak updated.\e[0m'; else echo 'Skipped Flatpak.'; fi; echo -e '\n\e[93mExecuted. This window will be closed in 5 seconds...\e[0m\n'; sleep 5; exit") || (kgx -- bash -c "clear; echo -e '\n\n\e[94mEnter your sudo password:\nYou can open keyboard by pressing GUIDE+X or PS+SQUARE on controller.\n\n\e[0m'; sudo rm -rf /var/lib/pacman/db.lck; \$UPDATE_CMD; echo -e '\e[96mSystem packages have been updated.\e[0m'; if flatpak --version &>/dev/null; then echo -e '\n\e[96mUpdating Flathub...\e[0m'; flatpak update -y; echo -e '\e[93mFlatpak updated.\e[0m'; else echo 'Skipped Flatpak.'; fi; echo -e '\n\e[93mExecuted. This window will be closed in 5 seconds...\e[0m\n'; sleep 5; pkill kgx") || (kitty bash -c "clear; echo -e '\n\n\e[94mEnter your sudo password:\nYou can open keyboard by pressing GUIDE+X or PS+SQUARE on controller.\n\n\e[0m'; sudo rm -rf /var/lib/pacman/db.lck; \$UPDATE_CMD; echo -e '\e[96mSystem packages have been updated.\e[0m'; if flatpak --version &>/dev/null; then echo -e '\n\e[96mUpdating Flathub...\e[0m'; flatpak update -y; echo -e '\e[93mFlatpak updated.\e[0m'; else echo 'Skipped Flatpak.'; fi; echo -e '\n\e[93mExecuted. This window will be closed in 5 seconds...\e[0m\n'; sleep 5; exit") || (alacritty -e bash -c "clear; echo -e '\n\n\e[94mEnter your sudo password:\nYou can open keyboard by pressing GUIDE+X or PS+SQUARE on controller.\n\n\e[0m'; sudo rm -rf /var/lib/pacman/db.lck; \$UPDATE_CMD; echo -e '\e[96mSystem packages have been updated.\e[0m'; if flatpak --version &>/dev/null; then echo -e '\n\e[96mUpdating Flathub...\e[0m'; flatpak update -y; echo -e '\e[93mFlatpak updated.\e[0m'; else echo 'Skipped Flatpak.'; fi; echo -e '\n\e[93mExecuted. This window will be closed in 5 seconds...\e[0m\n'; sleep 5; exit")
EOL
chmod +x "$update_script_path"
stop_spinner 0 "system_update.sh created at $update_script_path"

msg_step 18 18 "✓ Installation complete!"
echo ""
msg_success "Installation is complete!"
echo -e "\e[1;33m🚀 We recommend you to reboot your system.\e[0m"
echo -e "\e[36m🎮 You can try by clicking the Gaming Mode shortcut.\e[0m"
echo ""
msg_info "You can update the system in Steam by adding the ~/arch-deckify/system_update.sh file to Steam as a non-Steam game while in desktop mode."
echo ""
