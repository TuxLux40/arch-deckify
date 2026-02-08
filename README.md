
<div align="center">
	<br />
	<p>
	<img src="https://raw.githubusercontent.com/unlbslk/arch-deckify/refs/heads/main/banner.png" width="500" alt="Banner" /></a>
	</p>
	<br />
	<p>
</div>

# 🎮 Arch-Deckify
A script to easily set up a SteamOS-like gaming environment on Arch Linux.
This script is designed to bring SteamOS-style session switching to Arch Linux. It automates the installation and setup of a **Gaming Mode (Gamescope)** and a **Desktop Mode (Wayland session)**, along with configuration for **SDDM** and several optional components.
> 🌐 For more information, see the documents page: https://unlbslk.github.io/arch-deckify/
## 📌 Features:
- **Wayland Session Selector**: Allows you to choose a desktop session for your system.
- **Gamescope Gaming Mode**: Switch to a full-screen gaming experience similar to SteamOS. It uses [gamescope-session-steam](https://github.com/ChimeraOS/gamescope-session-steam) (Thanks to ChimeraOS team for this).
- **GUI Helper**: Easy configuration with GUI made with Zenity.
- **SDDM Configuration**: Automatically configures SDDM for autologin.
- **Shortcut Creation**: Adds a desktop shortcut for easy switching to Gaming Mode.
- **Optional Tools**: Offers installation of **Flatpak**, **Decky Loader**.
- **Session Switcher**: Shortcuts to easily switch between desktop and game mode.
- **Easy To Uninstall**: You can uninstall the script easily.

## ⛓️ Requirements:
- Arch Linux (or an Arch-based distribution)
- SDDM display manager
- A compatible GPU (NVIDIA hardware may face issues)
- A gamepad for best UI experience
- KDE Plasma Desktop (<ins>Other desktops are also supported</ins>, but KDE Plasma is recommended for the best experience.)


# 🧭 How to install?

**Run this command in your terminal and follow the instructions:**
```bash
bash <(curl -sSL https://raw.githubusercontent.com/unlbslk/arch-deckify/refs/heads/main/install.sh)
```

> ℹ️ See the docs for more information: https://unlbslk.github.io/arch-deckify/installation/


## ⚠️ Important Notice (READ BEFORE INSTALLING)

Please note that running this script may modify important system configurations, files, and settings. In some cases, it could lead to system instability, configuration loss, or make the system unbootable. Restoring the system to a working state may require advanced technical knowledge. Before executing directly, check the content of the script.

By using this script, you acknowledge that **you** are fully responsible for any issues that arise, including but not limited to data loss, system corruption, or any unforeseen consequences. It is highly recommended that you back up your important data and configurations before proceeding. Use this script at your own risk. 

## ⚙️ What this script does:

`1.`Prompts you to choose a default session for desktop mode.

`2.` Installs yay from AUR if neither yay/paru is not installed.

`3.` Enables the multilib repository, updates the system, and installs Steam if it's not already installed.

`4.` Installs gamescope-session-steam-git from the AUR (includes gamescope and other dependencies).

`5.` Generates an sddm.conf file in /etc/ to enable autologin and session switching.

`6.` Adds a sudoers rule to allow session switching without a password.

`7.` Creates a steamos-session-select file, allowing switching back to desktop mode from within Steam.

`8.` Installs these packages: gamescope, mangohud(for FPS counter), wget, ntfs-3g(for NTFS drive support)

`9.` Adds a udev rule for backlight control, enabling brightness adjustment within Steam.

`10.` Creates desktop and application shortcuts for Gaming Mode and a GUI Helper, adds a system update script, and enables Bluetooth services.

The GUI Helper allows you to manually install additional tools like Decky Loader.

### Session Switching
**The** `steamos-session-select` **command allows you to switch between Gamescope (Gaming Mode) and your selected Wayland session. Example usage:**
```bash
steamos-session-select gamescope  # Switch to Gaming Mode
steamos-session-select desktop     # Switch to Desktop (to your selected session)
```
You can also switch between Gaming Mode and Desktop Mode easily using the Steam interface or the desktop shortcut created during setup.

### Change Default Desktop
**To change the session used when switching to Desktop Mode, run the following script:**
```bash
bash <(curl -sSL https://raw.githubusercontent.com/unlbslk/arch-deckify/refs/heads/main/change_default_desktop.sh)
```

### Updating System
You can update the system in Steam by adding the `~/arch-deckify/system_update.sh` file to Steam as a non-Steam game while in desktop mode.
> In order for the system update script to work, at least one of the supported terminals (konsole, gnome-terminal, kitty, alacritty) must be installed.

**Unfortunately, system updates are not possible through Steam settings.**

### Decky Plugin Loader
The Decky Loader is an **unofficial** community-driven tool that allows you to install and manage plugins for your Steam interface. While not essential for system functionality, it provides additional customization options for SteamOS. (https://decky.xyz/)
Please note that it is **not an official tool** and may cause issues. Any potential risks or problems are the user's responsibility.

**To install Decky Loader:**
```bash
bash <(curl -sSL https://raw.githubusercontent.com/unlbslk/arch-deckify/refs/heads/main/setup_deckyloader.sh)
```
**To remove Decky Loader:**
```bash
bash <(curl -sSL https://raw.githubusercontent.com/unlbslk/arch-deckify/refs/heads/main/remove_deckyloader.sh)
```

## Disclaimer

All logos, trademarks, and names related to **Steam**, **SteamOS**, **Steam Deck**, **Valve**, **Deckify** and other software such as **Plasma** and **Arch** are the property of their respective owners. These logos and names are used for reference and informational purposes only. This project is not affiliated with, endorsed, or sponsored by **Valve**, **Steam**, **SteamOS**, **Steam Deck**, **Plasma**, **Arch Linux**, **Flatpak**, **Decky Loader**, **Deckify** or any of their respective organizations. All rights reserved to the original trademark holders.





## 🛠️ Development

### Testing
This project includes automated tests to ensure code quality:

```bash
# Run all tests
bash tests/run_tests.sh

# Run shellcheck on all scripts
shellcheck *.sh lib/*.sh
```

### Project Structure
```
arch-deckify/
├── lib/                          # Shared library functions
│   ├── common.sh                 # Common utilities, logging
│   └── steamos_session.sh        # Session management functions
├── tests/                        # Test suite
│   └── run_tests.sh              # Main test runner
├── .github/workflows/            # CI/CD configuration
│   └── ci.yml                    # GitHub Actions workflow
├── install.sh                    # Main installation script
├── system_update.sh              # System update utility
├── change_default_desktop.sh     # Desktop session changer
├── gui_helper.sh                 # GUI helper tool
├── setup_deckyloader.sh          # Decky Loader installer
├── remove_deckyloader.sh         # Decky Loader remover
├── CHANGELOG.md                  # Version history
└── CONTRIBUTING.md               # Contribution guidelines
```

### Features

#### Logging System
All scripts now include comprehensive logging to `~/.arch-deckify.log`:
- Installation steps
- Errors and warnings
- User selections
- Configuration changes

#### Error Handling
Enhanced error handling with:
- Exit codes for all critical operations
- Detailed error messages
- Graceful failure handling

#### Security Improvements
- Removed insecure password storage in environment variables
- Added framework for SHA256 checksum validation
- Safer download methods (no direct pipe to bash)
- Input validation for user choices

### Contributing
We welcome contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Commit message format (Conventional Commits)
- Code style guidelines
- Testing requirements
- Pull request process

### CI/CD
This project uses GitHub Actions for continuous integration:
- ShellCheck analysis on all scripts
- Syntax validation
- Automated test execution

