# Contributing to Arch-Deckify

Thank you for your interest in contributing to Arch-Deckify! This document provides guidelines and instructions for contributing.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/arch-deckify.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test your changes: `bash tests/run_tests.sh`
6. Commit your changes (see commit message format below)
7. Push to your fork: `git push origin feature/your-feature-name`
8. Create a Pull Request

## Development Setup

### Prerequisites
- Arch Linux or Arch-based distribution
- shellcheck for linting: `sudo pacman -S shellcheck`
- Basic shell scripting knowledge

### Running Tests
```bash
cd arch-deckify
bash tests/run_tests.sh
```

### Running Shellcheck
```bash
shellcheck *.sh lib/*.sh
```

## Commit Message Format

We use [Conventional Commits](https://www.conventionalcommits.org/) for clear and structured commit history.

### Format
```
<type>: <description>

[optional body]

[optional footer]
```

### Types
- **feat**: A new feature for the user
- **fix**: A bug fix
- **refactor**: Code refactoring without changing functionality
- **docs**: Documentation only changes
- **style**: Code style/formatting changes
- **test**: Adding or updating tests
- **chore**: Maintenance tasks, build changes, etc.
- **perf**: Performance improvements
- **ci**: Changes to CI/CD configuration

### Examples

#### Feature
```
feat: Add support for GNOME desktop session

- Detect GNOME session in Wayland sessions
- Update steamos-session-select for GNOME compatibility
```

#### Bug Fix
```
fix: Resolve permission issue in brightness control

The brightness slider wasn't working due to incorrect
video group permissions. Fixed by adding user to video
group during installation.
```

#### Refactoring
```
refactor: Extract session management to library

- Create lib/steamos_session.sh
- Move session selection logic to library
- Update all scripts to use library functions
```

#### Documentation
```
docs: Update installation instructions

Add troubleshooting section for NVIDIA GPU users
```

## Code Style Guidelines

### Shell Scripts
1. **Use bash shebang**: `#!/bin/bash`
2. **Add version header**: Include version comment at top of file
3. **Use functions**: Break code into reusable functions
4. **Error handling**: Add `|| exit 1` after critical commands
5. **Logging**: Use log_* functions from common.sh
6. **Variable quoting**: Always quote variables: `"${var}"`
7. **Shellcheck clean**: Scripts should pass shellcheck without warnings

### Example Script Structure
```bash
#!/bin/bash
# Script Name and Purpose
# Version: 1.0.0

# Source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

log_info "Starting script"

# Main function
main() {
    # Your code here
    command || exit 1
}

# Execute main
main
```

## Testing

### Test Requirements
- All scripts must have syntax validation tests
- Library functions should have unit tests
- New features should include tests

### Test Structure
```bash
# Test example
test_result() {
    local test_name="$1"
    local result="$2"
    
    if [[ "$result" == "0" ]]; then
        echo "✓ ${test_name}"
    else
        echo "✗ ${test_name}"
    fi
}
```

## Pull Request Process

1. **Update tests**: Add tests for new functionality
2. **Run tests**: Ensure all tests pass
3. **Run shellcheck**: Fix all warnings
4. **Update CHANGELOG.md**: Add entry for your changes
5. **Update documentation**: Update README if needed
6. **Write clear PR description**: Explain what and why

### PR Checklist
- [ ] Tests pass
- [ ] Shellcheck warnings fixed
- [ ] CHANGELOG.md updated
- [ ] Documentation updated (if needed)
- [ ] Commit messages follow convention
- [ ] Code follows style guidelines

## Security

### Reporting Security Issues
Please report security vulnerabilities privately to the maintainers.

### Security Best Practices
1. Never store passwords in environment variables
2. Validate checksums for downloaded files
3. Use `sudo` appropriately with minimal scope
4. Sanitize user inputs
5. Avoid `curl | bash` patterns

## Questions?

Feel free to open an issue for:
- Questions about contributing
- Feature requests
- Bug reports
- General discussion

Thank you for contributing to Arch-Deckify!
