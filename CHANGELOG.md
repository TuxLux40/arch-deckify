# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Commit Message Format

We follow conventional commits format for better change tracking:

### Types:
- **feat**: A new feature
- **fix**: A bug fix
- **refactor**: Code refactoring without changing functionality
- **docs**: Documentation only changes
- **style**: Code style changes (formatting, missing semi-colons, etc)
- **test**: Adding or updating tests
- **chore**: Changes to build process or auxiliary tools

### Examples:
```
feat: Add SHA256 checksum validation for downloads
fix: Resolve password handling security issue in gui_helper.sh
refactor: Extract steamos-session-select to separate library
docs: Update installation instructions in README
test: Add unit tests for library functions
chore: Set up GitHub Actions CI/CD pipeline
```

## [Unreleased]

### Added
- Library structure with common.sh and steamos_session.sh
- Logging system to ~/.arch-deckify.log
- Comprehensive error handling with exit codes
- Test suite with 18 automated tests
- GitHub Actions CI/CD pipeline
- .gitignore for build artifacts

### Changed
- Refactored system_update.sh for better readability
- Improved password handling in gui_helper.sh (removed PASSWORD environment variable)
- Updated install.sh to use library functions
- Updated change_default_desktop.sh to use library functions
- Enhanced setup_deckyloader.sh with proper error handling

### Security
- Improved download security by avoiding direct pipe to bash
- Removed insecure password storage in environment variables
- Added framework for SHA256 checksum validation

## [1.0.0] - Initial Release

### Added
- Initial Arch-Deckify installation script
- SteamOS-like session switching
- SDDM auto-login configuration
- Decky Loader support
- GUI Helper tool with Zenity
- System update functionality
