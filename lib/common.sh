#!/usr/bin/bash
# Common functions and utilities for arch-deckify
# Version: 1.0.0

# Script version
ARCH_DECKIFY_VERSION="1.0.0"

# Logging configuration
LOG_FILE="${HOME}/.arch-deckify.log"
LOG_ENABLED="${ARCH_DECKIFY_LOG:-1}"

# ============================================================================
# Color Definitions
# ============================================================================
# Regular colors
export COLOR_RESET='\e[0m'
export COLOR_BLACK='\e[30m'
export COLOR_RED='\e[31m'
export COLOR_GREEN='\e[32m'
export COLOR_YELLOW='\e[33m'
export COLOR_BLUE='\e[34m'
export COLOR_MAGENTA='\e[35m'
export COLOR_CYAN='\e[36m'
export COLOR_WHITE='\e[37m'
export COLOR_GRAY='\e[90m'

# Bold colors
export COLOR_BOLD_RED='\e[1;31m'
export COLOR_BOLD_GREEN='\e[1;32m'
export COLOR_BOLD_YELLOW='\e[1;33m'
export COLOR_BOLD_BLUE='\e[1;34m'
export COLOR_BOLD_MAGENTA='\e[1;35m'
export COLOR_BOLD_CYAN='\e[1;36m'
export COLOR_BOLD_WHITE='\e[1;37m'

# ============================================================================
# Icon/Emoji Definitions
# ============================================================================
export ICON_SUCCESS="✓"
export ICON_ERROR="✗"
export ICON_WARNING="⚠"
export ICON_INFO="ℹ"
export ICON_ARROW="➜"
export ICON_PACKAGE="📦"
export ICON_DOWNLOAD="⬇"
export ICON_INSTALL="⚙"
export ICON_CONFIG="🔧"
export ICON_CHECK="🔍"
export ICON_DESKTOP="🖥"
export ICON_STEAM="🎮"
export ICON_UPDATE="🔄"
export ICON_SKIP="⏭"
export ICON_ROCKET="🚀"
export ICON_WRENCH="🔨"

# Spinner characters
SPINNER_CHARS=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
SPINNER_PID=""

# Initialize log file
init_log() {
    if [[ "${LOG_ENABLED}" == "1" ]]; then
        mkdir -p "$(dirname "${LOG_FILE}")"
        touch "${LOG_FILE}" 2>/dev/null || true
    fi
}

# Log function with timestamp
log() {
    local level="$1"
    shift
    local message="$*"
    
    if [[ "${LOG_ENABLED}" == "1" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${level}] ${message}" >> "${LOG_FILE}"
    fi
    
    # Also print to stderr for ERROR and WARN
    if [[ "${level}" == "ERROR" ]] || [[ "${level}" == "WARN" ]]; then
        echo "[${level}] ${message}" >&2
    fi
}

# Log info message
log_info() {
    log "INFO" "$@"
}

# Log warning message
log_warn() {
    log "WARN" "$@"
}

# Log error message
log_error() {
    log "ERROR" "$@"
}

# Log debug message
log_debug() {
    log "DEBUG" "$@"
}

# ============================================================================
# Spinner Functions (like nala)
# ============================================================================

# Start a spinner with a message
# Usage: start_spinner "Message"
start_spinner() {
    local message="$1"
    local i=0
    
    # Hide cursor
    tput civis 2>/dev/null || true
    
    while true; do
        echo -ne "\r\e[36m${SPINNER_CHARS[$i]}\e[0m ${message}  "
        i=$(( (i + 1) % ${#SPINNER_CHARS[@]} ))
        sleep 0.1
    done &
    
    SPINNER_PID=$!
}

# Stop the spinner and show completion status
# Usage: stop_spinner [exit_code] [success_message] [error_message]
stop_spinner() {
    local exit_code="${1:-0}"
    local success_msg="${2:-Done}"
    local error_msg="${3:-Failed}"
    
    if [[ -n "$SPINNER_PID" ]]; then
        kill "$SPINNER_PID" 2>/dev/null || true
        wait "$SPINNER_PID" 2>/dev/null || true
        SPINNER_PID=""
    fi
    
    # Clear the spinner line
    echo -ne "\r$(tput el)"
    
    # Show cursor
    tput cnorm 2>/dev/null || true
    
    if [[ $exit_code -eq 0 ]]; then
        echo -e "\e[32m${ICON_SUCCESS}\e[0m ${success_msg}"
    else
        echo -e "\e[31m${ICON_ERROR}\e[0m ${error_msg}"
    fi
}

# ============================================================================
# Status Message Functions
# ============================================================================

# Print a step message with number
# Usage: msg_step <step_number> <total_steps> <message>
msg_step() {
    local step="$1"
    local total="$2"
    local message="$3"
    echo -e "\n\e[1;34m[${step}/${total}]\e[0m \e[1;37m${message}\e[0m"
}

# Print an info message
# Usage: msg_info <message>
msg_info() {
    echo -e "\e[36m${ICON_INFO}\e[0m  ${1}"
}

# Print a success message
# Usage: msg_success <message>
msg_success() {
    echo -e "\e[32m${ICON_SUCCESS}\e[0m  ${1}"
}

# Print a warning message
# Usage: msg_warning <message>
msg_warning() {
    echo -e "\e[33m${ICON_WARNING}\e[0m  ${1}"
}

# Print an error message
# Usage: msg_error <message>
msg_error() {
    echo -e "\e[31m${ICON_ERROR}\e[0m  ${1}" >&2
}

# Print a skip message
# Usage: msg_skip <message>
msg_skip() {
    echo -e "\e[90m${ICON_SKIP}\e[0m  \e[90m${1}\e[0m"
}

# Print an action message with icon
# Usage: msg_action <icon> <message>
msg_action() {
    local icon="$1"
    local message="$2"
    echo -e "\e[36m${icon}\e[0m  ${message}"
}

# Run command with spinner
# Usage: run_with_spinner "Message" command [args...]
run_with_spinner() {
    local message="$1"
    shift
    local cmd="$@"
    
    start_spinner "$message"
    
    # Run command and capture output and exit code
    local output
    local exit_code
    output=$($cmd 2>&1)
    exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        stop_spinner 0 "$message"
    else
        stop_spinner 1 "$message" "$message (Failed)"
        # Log the error output
        log_error "Command failed: $cmd"
        log_error "Output: $output"
    fi
    
    return $exit_code
}

# ============================================================================
# Original Functions
# ============================================================================


# Verify SHA256 checksum
# Usage: verify_checksum <file> <expected_checksum>
verify_checksum() {
    local file="$1"
    local expected="$2"
    
    if [[ -z "${file}" ]] || [[ -z "${expected}" ]]; then
        log_error "verify_checksum: Missing file or checksum argument"
        return 1
    fi
    
    if [[ ! -f "${file}" ]]; then
        log_error "verify_checksum: File not found: ${file}"
        return 1
    fi
    
    local actual
    actual=$(sha256sum "${file}" | cut -d' ' -f1)
    
    if [[ "${actual}" != "${expected}" ]]; then
        log_error "Checksum verification failed for ${file}"
        log_error "Expected: ${expected}"
        log_error "Actual: ${actual}"
        return 1
    fi
    
    log_info "Checksum verified for ${file}"
    return 0
}

# Safe download with optional checksum verification
# Usage: safe_download <url> <output_file> [expected_checksum]
safe_download() {
    local url="$1"
    local output="$2"
    local checksum="${3:-}"
    
    log_info "Downloading ${url} to ${output}"
    
    if ! wget -q -O "${output}" "${url}"; then
        log_error "Failed to download ${url}"
        return 1
    fi
    
    if [[ -n "${checksum}" ]]; then
        if ! verify_checksum "${output}" "${checksum}"; then
            rm -f "${output}"
            return 1
        fi
    fi
    
    return 0
}

# Validate user input against a list of valid options
# Usage: validate_input <user_input> <valid_option1> <valid_option2> ...
validate_input() {
    local input="$1"
    shift
    local valid_options=("$@")
    
    for option in "${valid_options[@]}"; do
        if [[ "${input}" == "${option}" ]]; then
            return 0
        fi
    done
    
    return 1
}

# Check if command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Run command with error handling
# Usage: run_cmd <command> <error_message>
run_cmd() {
    local cmd="$1"
    local error_msg="${2:-Command failed}"
    
    log_debug "Running: ${cmd}"
    
    if ! eval "${cmd}"; then
        log_error "${error_msg}"
        return 1
    fi
    
    return 0
}

# Initialize logging on source
init_log
