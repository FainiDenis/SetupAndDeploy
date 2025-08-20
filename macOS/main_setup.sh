#!/bin/zsh

# ============================================================================
# Main macOS Setup Script for new or reset MacBook OS
# This script orchestrates all setup modules
# Usage: Run this script in the terminal after resetting your MacBook.
# ============================================================================

# Global Variables for Easy Configuration
export GIT_USER_NAME="Denis Faini"
export GIT_USER_EMAIL="dtf8841@rit.edu"
export JAVA_VERSION="24"
export MAVEN_VERSION="3.9.11"
export DOCK_TILE_SIZE=30
export MOUSE_SCALING=3.0
export FINDER_VIEW_STYLE="Nlsv"
export SCREENSHOT_DIR="$HOME/Screenshots"

# ANSI Color Codes
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export NC='\033[0m'

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"

# Utility functions
task_start() {
    echo -e "\n${BLUE}[TASK] $1${NC}"
}

task_result() {
    local status=$1
    local message=$2
    if [ "$status" = "OK" ]; then
        echo -e "    ${GREEN}$message ... OK${NC}"
    elif [ "$status" = "Changed" ]; then
        echo -e "    ${YELLOW}$message ... Changed${NC}"
    else
        echo -e "    ${RED}$message ... Failed${NC}"
        exit 1
    fi
}

# Export utility functions for use in other scripts
export -f task_start task_result

echo -e "${BLUE}============================================================================${NC}"
echo -e "${BLUE}macOS Setup Script for new or reset MacBook OS${NC}"
echo -e "${BLUE}This script automates the setup of a new macOS environment${NC}"
echo -e "${BLUE}============================================================================${NC}"

# Run setup modules in order
task_start "Running Package Installation"
zsh "$SCRIPT_DIR/install_packages.sh"

task_start "Running Development Environment Setup"
zsh "$SCRIPT_DIR/setup_development.sh"

task_start "Running macOS Configuration"
zsh "$SCRIPT_DIR/configure_macos.sh"

task_start "Running Shell Environment Setup"
zsh "$SCRIPT_DIR/setup_shell.sh"

# Final message
task_start "Setup complete"
task_result "OK" "macOS setup completed successfully"
echo -e "\n${YELLOW}Note: Some changes (like Oh My Zsh) will only take effect when you start a new zsh session.${NC}"
echo -e "${YELLOW}Please run 'zsh' to start a new session with all your new settings.${NC}"
