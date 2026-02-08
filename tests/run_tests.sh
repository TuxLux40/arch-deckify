#!/bin/bash
# Test runner for Arch-Deckify
# Version: 1.0.0

# Color codes for output
RED='\e[91m'
GREEN='\e[92m'
YELLOW='\e[93m'
RESET='\e[0m'

TESTS_PASSED=0
TESTS_FAILED=0

# Test result tracking
test_result() {
    local test_name="$1"
    local result="$2"
    
    if [[ "$result" == "0" ]]; then
        echo -e "${GREEN}✓${RESET} ${test_name}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${RESET} ${test_name}"
        ((TESTS_FAILED++))
    fi
}

echo "Running Arch-Deckify Test Suite..."
echo "===================================="
echo

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Test 1: Check if lib/common.sh exists and is valid
echo "Testing library files..."
if [[ -f "${ROOT_DIR}/lib/common.sh" ]]; then
    if bash -n "${ROOT_DIR}/lib/common.sh" 2>/dev/null; then
        test_result "lib/common.sh syntax" 0
    else
        test_result "lib/common.sh syntax" 1
    fi
else
    test_result "lib/common.sh exists" 1
fi

# Test 2: Check if lib/steamos_session.sh exists and is valid
if [[ -f "${ROOT_DIR}/lib/steamos_session.sh" ]]; then
    if bash -n "${ROOT_DIR}/lib/steamos_session.sh" 2>/dev/null; then
        test_result "lib/steamos_session.sh syntax" 0
    else
        test_result "lib/steamos_session.sh syntax" 1
    fi
else
    test_result "lib/steamos_session.sh exists" 1
fi

# Test 3: Check main scripts
echo
echo "Testing main scripts..."
for script in install.sh system_update.sh change_default_desktop.sh gui_helper.sh setup_deckyloader.sh remove_deckyloader.sh; do
    if [[ -f "${ROOT_DIR}/$script" ]]; then
        if bash -n "${ROOT_DIR}/$script" 2>/dev/null; then
            test_result "$(basename $script) syntax" 0
        else
            test_result "$(basename $script) syntax" 1
        fi
    else
        test_result "$(basename $script) exists" 1
    fi
done

# Test 4: Check if scripts are executable
echo
echo "Testing script permissions..."
for script in install.sh system_update.sh change_default_desktop.sh gui_helper.sh setup_deckyloader.sh remove_deckyloader.sh; do
    if [[ -f "${ROOT_DIR}/$script" ]]; then
        if [[ -x "${ROOT_DIR}/$script" ]]; then
            test_result "$(basename $script) executable" 0
        else
            test_result "$(basename $script) executable" 1
        fi
    fi
done

# Test 5: Source library and test functions
echo
echo "Testing library functions..."
source "${ROOT_DIR}/lib/common.sh"

# Test logging initialization
if [[ -n "$LOG_FILE" ]]; then
    test_result "LOG_FILE variable set" 0
else
    test_result "LOG_FILE variable set" 1
fi

# Test command_exists function
if declare -f command_exists &>/dev/null; then
    test_result "command_exists function exists" 0
else
    test_result "command_exists function exists" 1
fi

# Test 6: Source steamos_session library and test functions
source "${ROOT_DIR}/lib/steamos_session.sh"

if declare -f generate_steamos_session_select &>/dev/null; then
    test_result "generate_steamos_session_select function exists" 0
else
    test_result "generate_steamos_session_select function exists" 1
fi

if declare -f get_available_desktops &>/dev/null; then
    test_result "get_available_desktops function exists" 0
else
    test_result "get_available_desktops function exists" 1
fi

# Summary
echo
echo "===================================="
echo "Test Results:"
echo -e "${GREEN}Passed: ${TESTS_PASSED}${RESET}"
echo -e "${RED}Failed: ${TESTS_FAILED}${RESET}"
echo "===================================="

if [[ "$TESTS_FAILED" -gt 0 ]]; then
    exit 1
fi

exit 0
