#!/bin/zsh

# ============================================================================
# Package Installation Script
# Installs Homebrew packages, casks, and Mac App Store applications
# ============================================================================

# Check if Homebrew is installed
task_start "Checking for Homebrew"
if ! command -v brew &>/dev/null; then
    task_start "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && 
    task_result "Changed" "Homebrew installed"
else
    task_result "OK" "Homebrew already installed"
fi

# Update Homebrew
task_start "Updating Homebrew"
brew update && task_result "Changed" "Homebrew updated"

# Install Homebrew packages
task_start "Installing Homebrew packages"
homebrew_packages=(
    git
    curl
    python3
    ansible
    tree
    htop
    mas
)

for package in "${homebrew_packages[@]}"; do
    task_start "Installing $package"
    if ! brew list --formula | grep -q "^$package\$"; then
        brew install "$package" && task_result "Changed" "$package installed"
    else
        task_result "OK" "$package already installed"
    fi
done

# Install Cask packages
task_start "Installing Cask packages"
cask_packages=(
    firefox
    zoom
    rectangle
    displaylink
    tailscale
    tuxera-ntfs
    mountain-duck
    hazel
    vlc
    appcleaner
    iterm2
    stremio
    wireshark
    visual-studio-code
    windows-app
    libreoffice
    oracle-jdk
)

for package in "${cask_packages[@]}"; do
    task_start "Installing $package"
    if ! brew list --cask | grep -q "^$package\$"; then
        brew install --cask "$package" && task_result "Changed" "$package installed"
    else
        task_result "OK" "$package already installed"
    fi
done

# Install Mac App Store applications
task_start "Installing Mac App Store applications"
mas_apps=(
    "897118787:Shazam"
    "1564384601:Evermusic"
    "1530145038:Amperfy Music"
)

for app in "${mas_apps[@]}"; do
    app_id=${app%%:*}
    app_name=${app#*:}
    task_start "Installing $app_name"
    mas install "$app_id" && task_result "Changed" "$app_name installed"
done