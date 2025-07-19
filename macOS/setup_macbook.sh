#!/bin/bash

# ============================================================================
#
# macOS Setup Script for new or reset MacBook OS
# This script automates the setup of a new macOS environment
# by installing essential software, configuring system settings,
# and personalizing the environment.
# Usage: Run this script in the terminal after resetting your MacBook.
#
# ============================================================================

# ============================================================
# Global Variables for Easy Configuration
# ============================================================
# User details
GIT_USER_NAME="Denis Faini"         # Change this to your name
GIT_USER_EMAIL="dtf8841@rit.edu"    # Change this to your email

# File Versions
JAVA_VERSION="24"           # Change this to the desired Java version
MAVEN_VERSION="3.9.11"      # Change this to the desired Maven version

# File paths
GIT_CONFIG_FILE="$HOME/.gitconfig"
GIT_IGNORE_FILE="$HOME/.gitignore"
ZSHRC_FILE="$HOME/.zshrc"
SCREENSHOT_DIR="$HOME/Screenshots"
JAVA_INSTALL_DIR="/Library/Java/JavaVirtualMachines/jdk-$JAVA_VERSION.jdk/Contents/Home"
MAVEN_INSTALL_DIR="/usr/local/maven"
MAVEN_HOME="$MAVEN_INSTALL_DIR/apache-maven-$MAVEN_VERSION"

# Configuration settings
DOCK_TILE_SIZE=30               # Size of Dock icons
MOUSE_SCALING=3.0               # Mouse tracking speed
FINDER_VIEW_STYLE="Nlsv"        # Finder view style (list view)

# Repository URLs
HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
OHMYZSH_INSTALL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
ZSH_SYNTAX_HIGHLIGHTING_URL="https://github.com/zsh-users/zsh-syntax-highlighting.git"
ZSH_AUTOSUGGESTIONS_URL="https://github.com/zsh-users/zsh-autosuggestions.git"
JAVA_JDK_ARM64_URL="https://download.oracle.com/java/$JAVA_VERSION/latest/jdk-$JAVA_VERSION_macos-aarch64_bin.dmg"
JAVA_JDK_X64_URL="https://download.oracle.com/java/$JAVA_VERSION/latest/jdk-$JAVA_VERSION_macos-x64_bin.dmg"
MAVEN_BIN_URL="https://dlcdn.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.zip"

# Zsh plugins directory
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

# ANSI Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print task start with better colored output fomatting
task_start() {
    echo -e "\n${BLUE}[TASK] $1${NC}"
}

# Print task result (OK, Changed, or ailed)
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

# ============================================================
# Main Script
# ============================================================

# Check if Homebrew is installed
task_start "Checking for Homebrew"
if ! command -v brew &>/dev/null; then
    task_start "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL $HOMEBREW_INSTALL_URL)" && task_result "Changed" "Homebrew installed"
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

# Check system architecture and select Java JDK URL
task_start "Checking system architecture"
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    JAVA_URL="$JAVA_JDK_ARM64_URL"
    task_result "OK" "Detected arm64 architecture"
else
    JAVA_URL="$JAVA_JDK_X64_URL"
    task_result "OK" "Detected x86_64 architecture"
fi

# Install Java JDK
task_start "Checking for Java JDK $JAVA_VERSION"
if [ ! -d "$JAVA_INSTALL_DIR" ]; then
    task_start "Downloading and installing Java JDK $JAVA_VERSION"
    curl -L "$JAVA_URL" -o /tmp/jdk-$JAVA_VERSION.dmg &&
    hdiutil attach /tmp/jdk-$JAVA_VERSION.dmg -mountpoint /Volumes/JDK &&
    sudo installer -pkg /Volumes/JDK/*.pkg -target / &&
    hdiutil detach /Volumes/JDK &&
    rm /tmp/jdk-$JAVA_VERSION.dmg &&
    task_result "Changed" "Java JDK $JAVA_VERSION installed"
else
    task_result "OK" "Java JDK $JAVA_VERSION already installed"
fi

# Set JAVA_HOME in .zshrc
task_start "Setting JAVA_HOME"
if ! grep -q "export JAVA_HOME=" "$ZSHRC_FILE" 2>/dev/null; then
    echo "export JAVA_HOME=$JAVA_INSTALL_DIR" >> "$ZSHRC_FILE" &&
    task_result "Changed" "JAVA_HOME set to $JAVA_INSTALL_DIR"
else
    task_result "OK" "JAVA_HOME already set"
fi

# Install Maven
task_start "Checking for Maven"
if [ ! -d "$MAVEN_HOME" ]; then
    task_start "Downloading and installing Maven"
    curl -L "$MAVEN_BIN_URL" -o /tmp/maven.zip &&
    sudo mkdir -p "$MAVEN_INSTALL_DIR" &&
    sudo unzip /tmp/maven.zip -d "$MAVEN_INSTALL_DIR" &&
    rm /tmp/maven.zip &&
    task_result "Changed" "Maven installed"
else
    task_result "OK" "Maven already installed"
fi

# Set MAVEN_HOME in .zshrc
task_start "Setting MAVEN_HOME"
if ! grep -q "export MAVEN_HOME=" "$ZSHRC_FILE" 2>/dev/null; then
    echo "export MAVEN_HOME=$MAVEN_HOME" >> "$ZSHRC_FILE" &&
    echo "export PATH=\$MAVEN_HOME/bin:\$PATH" >> "$ZSHRC_FILE" &&
    task_result "Changed" "MAVEN_HOME set to $MAVEN_HOME"
else
    task_result "OK" "MAVEN_HOME already set"
fi

# Set up Git configuration
task_start "Setting up Git"
if [ ! -f "$GIT_CONFIG_FILE" ]; then
    task_start "Creating Git configuration"
    cat > "$GIT_CONFIG_FILE" << EOL
[user]
    name = $GIT_USER_NAME
    email = $GIT_USER_EMAIL
[core]
    editor = code --wait
EOL
    task_result "Changed" "Git configuration created"
else
    task_result "OK" "Git configuration already exists"
fi

# Set up Git ignore file
task_start "Setting up Git ignore file"
if [ ! -f "$GIT_IGNORE_FILE" ]; then
    task_start "Creating Git ignore file"
    cat > "$GIT_IGNORE_FILE" << EOL
# macOS specific files
.DS_Store
.AppleDouble
.LSOverride
._*
.Spotlight-V100
.Trashes
*.tmp
*.temp
*.bak
*.swp
*.log
node_modules/
__pycache__/
*.pyc
*.pyo
venv/
.env
.vscode/
*.orig
*.rej
*.swo
*.swp
*.zip
*.tar.gz
*.rar
EOL
    task_result "Changed" "Git ignore file created"
else
    task_result "OK" "Git ignore file already exists"
fi

# Configure macOS settings
task_start "Configuring macOS settings"

task_start "Show hidden files in Finder"
defaults write com.apple.finder AppleShowAllFiles -bool true &&
killall Finder &&
task_result "Changed" "Hidden files enabled in Finder"

task_start "Set screenshot location"
mkdir -p "$SCREENSHOT_DIR" &&
defaults write com.apple.screencapture location "$SCREENSHOT_DIR" &&
killall SystemUIServer &&
task_result "Changed" "Screenshot location set to $SCREENSHOT_DIR"

task_start "Set Dock to auto-hide and size"
defaults write com.apple.dock autohide -bool true &&
defaults write com.apple.dock tilesize -int "$DOCK_TILE_SIZE" &&
killall Dock &&
task_result "Changed" "Dock configured"

task_start "Set mouse tracking speed"
defaults write -g com.apple.mouse.scaling "$MOUSE_SCALING" &&
task_result "Changed" "Mouse tracking speed set to $MOUSE_SCALING"

task_start "Disable .DS_Store on network drives"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true &&
task_result "Changed" ".DS_Store disabled on network drives"

task_start "Set Finder to list view"
defaults write com.apple.finder FXPreferredViewStyle -string "$FINDER_VIEW_STYLE" &&
task_result "Changed" "Finder set to list view"

task_start "Set Dark Mode"
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark" &&
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true &&
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true' &&
task_result "Changed" "Dark Mode enabled"   

# Create ls aliases
task_start "Creating ls aliases"
if ! grep -q "alias ls='tree -C'" "$ZSHRC_FILE" 2>/dev/null; then
    echo "alias ls='tree -C'" >> "$ZSHRC_FILE" &&
    echo "alias ll='ls -l'" >> "$ZSHRC_FILE" &&
    echo "alias la='ls -la'" >> "$ZSHRC_FILE" &&
    task_result "Changed" "ls aliases added"
else
    task_result "OK" "ls aliases already exist"
fi

# Organize folders
task_start "Organizing folders"
mkdir -p ~/Documents/{Projects,Personal,Work,Archives} &&
mkdir -p ~/Downloads/{Compressed,Media,Temporary} &&
task_result "Changed" "Folders organized"

# Install Oh My Zsh
task_start "Checking for Oh My Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    task_start "Installing Oh My Zsh"
    sh -c "$(curl -fsSL $OHMYZSH_INSTALL_URL)" --unattended &&
    task_result "Changed" "Oh My Zsh installed"
else
    task_result "OK" "Oh My Zsh already installed"
fi

# Install Zsh plugins
task_start "Installing zsh-syntax-highlighting plugin"
if [ ! -d "$ZSH_CUSTOM/zsh-syntax-highlighting" ]; then
    git clone "$ZSH_SYNTAX_HIGHLIGHTING_URL" "$ZSH_CUSTOM/zsh-syntax-highlighting" &&
    task_result "Changed" "zsh-syntax-highlighting installed"
else
    task_result "OK" "zsh-syntax-highlighting already installed"
fi

task_start "Installing zsh-autosuggestions plugin"
if [ ! -d "$ZSH_CUSTOM/zsh-autosuggestions" ]; then
    git clone "$ZSH_AUTOSUGGESTIONS_URL" "$ZSH_CUSTOM/zsh-autosuggestions" &&
    task_result "Changed" "zsh-autosuggestions installed"
else
    task_result "OK" "zsh-autosuggestions already installed"
fi

task_start "Setup complete"
task_result "OK" "macOS setup completed successfully"