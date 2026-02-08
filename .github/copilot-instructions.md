# Arch-Deckify Project Guidelines

A Bash-based SteamOS-like gaming environment installer for Arch Linux with modular libraries and consistent CLI UX.

## Architecture

**Library System**: Two core libraries provide reusable functionality:
- [`lib/common.sh`](lib/common.sh) - Logging, UI output (spinners, colors, icons), utilities
- [`lib/steamos_session.sh`](lib/steamos_session.sh) - Desktop session detection and `steamos-session-select` generation

**Script Pattern**: All scripts source libraries using absolute paths:
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -f "${SCRIPT_DIR}/lib/common.sh" ]] && source "${SCRIPT_DIR}/lib/common.sh"
```

**Key Files**:
- [`install.sh`](install.sh) - Main 18-step installation orchestrator
- [`setup_deckyloader.sh`](setup_deckyloader.sh) - Optional plugin loader setup
- [`system_update.sh`](system_update.sh) - Multi-terminal yay/paru wrapper
- [`change_default_desktop.sh`](change_default_desktop.sh) - Desktop session switcher

## Code Style

**Bash Conventions** (see [`lib/common.sh`](lib/common.sh) for examples):
```bash
#!/usr/bin/bash               # Shebang
UPPERCASE_CONSTANTS="value"   # Exported/global vars
lowercase_locals="value"      # Function-scoped vars
[[ "$var" == "value" ]]       # Use double brackets
command >/dev/null 2>&1       # Suppress all output
```

**Root Prevention**: All user-facing scripts reject root execution:
```bash
[ "$EUID" -eq 0 ] && { msg_error "Run WITHOUT sudo"; exit 1; }
```

**Error Handling**: Explicit exits on failure, early sudo caching:
```bash
sudo whoami || exit 1                    # Cache credentials early
sudo pacman -S pkg --noconfirm || exit 1 # Exit on failure
```

## UI/UX Conventions

**Dual Logging** (file + console):
```bash
log_info "Technical detail"    # → ~/.arch-deckify.log
msg_info "User-facing message"  # → Console with ℹ icon
```

**Status Messages** - Use these functions from [`lib/common.sh`](lib/common.sh):
```bash
msg_step 5 18 "📦 Installing Steam"      # Numbered steps
msg_success "Installation complete"       # Green ✓
msg_error "SDDM not found"                # Red ✗ (to stderr)
msg_warning "NVIDIA may have issues"      # Yellow ⚠
msg_skip "Already installed"              # Gray ⏭
```

**Spinners** - Suppress verbose output during long operations:
```bash
start_spinner "⚙ Building package"
makepkg -si --noconfirm >/dev/null 2>&1 || exit 1
stop_spinner 0 "Package built" "Build failed"
```

**Colors/Icons**: Always use direct ANSI codes (`\e[36m`) and Unicode emojis (`📦`) - NOT variables like `${COLOR_CYAN}` or `${ICON_PACKAGE}` (variables don't expand in all contexts).

## Key Functions

From [`lib/common.sh`](lib/common.sh):
- `start_spinner` / `stop_spinner` - Nala-style animated progress
- `msg_step` / `msg_info` / `msg_success` / `msg_error` / `msg_warning` / `msg_skip` - Formatted output
- `log_info` / `log_warn` / `log_error` / `log_debug` - File logging
- `command_exists` / `verify_checksum` / `safe_download` - Utilities

From [`lib/steamos_session.sh`](lib/steamos_session.sh):
- `select_desktop_session_interactive()` - Numbered menu for Wayland sessions (output to stderr, return selection)
- `install_steamos_session_select <session>` - Generate `/usr/bin/steamos-session-select`
- `get_available_desktops` / `validate_desktop_session` - Session management

## Build and Test

```bash
# Run tests
bash tests/run_tests.sh

# Install locally (requires Arch Linux + SDDM)
./install.sh

# Syntax check
bash -n <script.sh>
```

## Project Conventions

**Multi-Step Operations**: Always number steps clearly (see [`install.sh`](install.sh) for 18-step example):
```bash
msg_step 1 18 "📦 Checking for AUR helper"
msg_step 2 18 "🔧 Enabling multilib"
```

**Package Manager Operations**: Suppress output and avoid interactive prompts:
```bash
sudo pacman -S pkg --noconfirm >/dev/null 2>&1 || exit 1
yay -S pkg --noconfirm --sudoloop >/dev/null 2>&1 || paru -S pkg --noconfirm >/dev/null 2>&1
```

**Interactive Selection**: Output prompts to stderr so return value is clean:
```bash
echo -e "\e[36m➜\e[0m Select option:" >&2
read -r choice
echo "$selected_value"  # Only this goes to stdout
```

**Terminal Detection**: [`system_update.sh`](system_update.sh) tries multiple emulators (konsole → gnome-terminal → kgx → kitty → alacritty).

## Security

- No hardcoded credentials/tokens
- `steamos-session-select` requires sudoers rule for SDDM config editing
- Downloads verify sources (GitHub releases, AUR)
- `/etc/sudoers.d/` rules have 440 permissions

## Common Pitfalls

1. **Don't use `$COLOR_*` or `$ICON_*` variables** - Use direct ANSI/emoji codes
2. **Always suppress pacman/yay output** - Use `>/dev/null 2>&1` or spinners
3. **Clean up spinners** - Call `stop_spinner` or scripts may hang
4. **Check EUID** - Reject root except for explicit sudo commands
5. **Cache sudo early** - `sudo whoami || exit 1` at script start
