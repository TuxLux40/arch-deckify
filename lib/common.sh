#!/usr/bin/bash
# Common functions and utilities for arch-deckify
# Version: 1.0.0

# Script version
ARCH_DECKIFY_VERSION="1.0.0"

# Logging configuration
LOG_FILE="${HOME}/.arch-deckify.log"
LOG_ENABLED="${ARCH_DECKIFY_LOG:-1}"

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
