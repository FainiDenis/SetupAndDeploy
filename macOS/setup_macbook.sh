#!/bin/zsh

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

# ============================================================
# Functions and Main Script
# ============================================================

# Simple logging
log() {
    echo "[SETUP] $1"
}

# Check if Homebrew is installed
log "Checking for Homebrew..."
if ! command -v brew &>/dev/null; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL $HOMEBREW_INSTALL_URL)"
else
    log "Homebrew already installed"
fi

# Update Homebrew
log "Updating Homebrew..."
brew update

# Install Homebrew packages
log "Installing Homebrew packages..."
homebrew_packages=(
    git
    curl
    python3
    ansible
    tree
    htop
    mas         # Mac App Store CLI
)
for package in "${homebrew_packages[@]}"; do
    if ! brew list --formula | grep -q "^$package\$"; then
        log "Installing $package..."
        brew install "$package"
    else
        log "$package already installed"
    fi
done

# Install Homebrew Cask
log "Setting up Homebrew Cask..."
brew tap homebrew/cask

# Install Cask packages
log "Installing Cask packages..."
cask_packages=(
    firefox
    zoom
    rectangle
    displaylink
    tailscale
    wireshark
    tuxera-ntfs
    mountain-duck
    hazel
    vlc
    appcleaner
    iterm2
    stremio
    visual-studio-code
    windows-app
    libreoffice
)
for package in "${cask_packages[@]}"; do
    if ! brew list --cask | grep -q "^$package\$"; then
        log "Installing $package..."
        brew install --cask "$package"
    else
        log "$package already installed"
    fi
done

# Install Mac App Store applications
log "Installing Mac App Store applications..."
mas_apps=(
    897118787  # Shazam
    885367198  # Evermusic
    1530145038 # Amperfy Music
)

# Check system architecture and install Java JDK
log "Checking system architecture..."
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    JAVA_URL="$JAVA_JDK_ARM64_URL"
    log "Detected arm64 architecture"
else
    JAVA_URL="$JAVA_JDK_X64_URL"
    log "Detected x86_64 architecture"
fi

log "Checking for Java JDK $JAVA_VERSION..."
if [ ! -d "$JAVA_INSTALL_DIR" ]; then
    log "Downloading and installing Java JDK $JAVA_VERSION..."
    curl -L "$JAVA_URL" -o /tmp/jdk-$JAVA_VERSION.dmg
    hdiutil attach /tmp/jdk-$JAVA_VERSION.dmg -mountpoint /Volumes/JDK
    sudo installer -pkg /Volumes/JDK/*.pkg -target /
    hdiutil detach /Volumes/JDK
    rm /tmp/jdk-$JAVA_VERSION.dmg
else
    log "Java JDK $JAVA_VERSION is already installed"
fi

# Set JAVA_HOME in .zshrc
log "Setting JAVA_HOME..."
if ! grep -q "export JAVA_HOME=" "$ZSHRC_FILE" 2>/dev/null; then
    echo "export JAVA_HOME=$JAVA_INSTALL_DIR" >> "$ZSHRC_FILE"
    log "JAVA_HOME set to $JAVA_INSTALL_DIR"
else
    log "JAVA_HOME already set"
fi

# Install Maven
log "Checking for Maven..."
if [ ! -d "$MAVEN_HOME" ]; then
    log "Downloading and installing Maven..."
    curl -L "$MAVEN_BIN_URL" -o /tmp/maven.zip
    sudo mkdir -p "$MAVEN_INSTALL_DIR"
    sudo unzip /tmp/maven.zip -d "$MAVEN_INSTALL_DIR"
    rm /tmp/maven.zip
else
    log "Maven already installed"
fi

# Set MAVEN_HOME in .zshrc
log "Setting MAVEN_HOME..."
if ! grep -q "export MAVEN_HOME=" "$ZSHRC_FILE" 2>/dev/null; then
    echo "export MAVEN_HOME=$MAVEN_HOME" >> "$ZSHRC_FILE"
    echo "export PATH=\$MAVEN_HOME/bin:\$PATH" >> "$ZSHRC_FILE"
    log "MAVEN_HOME set to $MAVEN_HOME"
else
    log "MAVEN_HOME already set"
fi

# Set up Git configuration
log "Setting up Git..."
if [ ! -f "$GIT_CONFIG_FILE" ]; then
    log "Creating Git configuration..."
    cat > "$GIT_CONFIG_FILE" << EOL
[user]
    name = $GIT_USER_NAME
    email = $GIT_USER_EMAIL
[core]
    editor = code --wait
EOL
else
    log "Git configuration already exists"
fi

# Set up Git ignore file
if [ ! -f "$GIT_IGNORE_FILE" ]; then
    log "Creating Git ignore file..."
    cat > "$GIT_IGNORE_FILE" << EOL
# macOS specific files
.DS_Store               # macOS Finder metadata
.AppleDouble            # macOS AppleDouble files
.LSOverride             # macOS Finder metadata
._*                     # macOS resource fork files
.Spotlight-V100         # macOS Spotlight index
.Trashes                # macOS Trash directory
*.tmp                   # Temporary files
*.temp                  # Temporary files
*.bak                   # Backup files
*.swp                   # Swap files
*.log                   # Log files
node_modules/           # Node.js dependencies
__pycache__/            # Python cache files
*.pyc                   # Python bytecode files
*.pyo                   # Python optimized bytecode files
venv/                   # Python virtual environments
.env                    # Environment variables
.vscode/                # Visual Studio Code
*.orig                  # Original files
*.rej                   # Reject files
*.swo                   # Swap files
*.swp                   # Swap files
*.zip                   # Zip files
*.tar.gz                # Tarball files
*.rar                   # RAR files
EOL
else
    log "Git ignore file already exists"
fi

# Configure macOS settings
log "Configuring macOS settings..."
# Show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles -bool true
killall Finder

# Set screenshot location
mkdir -p "$SCREENSHOT_DIR"
defaults write com.apple.screencapture location "$SCREENSHOT_DIR"
killall SystemUIServer

# Set Dock to auto-hide and size
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int "$DOCK_TILE_SIZE"
killall Dock

# Set mouse tracking speed
defaults write -g com.apple.mouse.scaling "$MOUSE_SCALING"

# Disable .DS_Store on network drives
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Set built-in display to more space to 1680x1050
# defaults write com.apple.display "DisplayResolutionEnabled" -bool true      # Enable display resolution settings
defaults write com.apple.display "DisplayResolution" -string "1680x1050"    # Set resolution to 1680x1050 (more space)

# Set Finder to list view
defaults write com.apple.finder FXPreferredViewStyle -string "$FINDER_VIEW_STYLE"

# Create ls aliases
if ! grep -q "alias ls='tree -C'" "$ZSHRC_FILE" 2>/dev/null; then
    log "Adding ls aliases..."
    echo "alias ls='tree -C'" >> "$ZSHRC_FILE"
    echo "alias ll='ls -l'" >> "$ZSHRC_FILE"
    echo "alias la='ls -la'" >> "$ZSHRC_FILE"
else
    log "aliases already exist"
fi

# Organize folders
log "Organizing folders..."
mkdir -p ~/Documents/{Projects,Personal,Work,Archives}
mkdir -p ~/Downloads/{Compressed,Media,Temporary}

# Install Oh My Zsh
log "Checking for Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL $OHMYZSH_INSTALL_URL)" --unattended
else
    log "Oh My Zsh already installed"
fi

# Install Zsh plugins
log "Installing Zsh plugins..."
if [ ! -d "$ZSH_CUSTOM/zsh-syntax-highlighting" ]; then
    log "Installing zsh-syntax-highlighting..."
    git clone "$ZSH_SYNTAX_HIGHLIGHTING_URL" "$ZSH_CUSTOM/zsh-syntax-highlighting"
else
    log "zsh-syntax-highlighting already installed"
fi

if [ ! -d "$ZSH_CUSTOM/zsh-autosuggestions" ]; then
    log "Installing zsh-autosuggestions..."
    git clone "$ZSH_AUTOSUGGESTIONS_URL" "$ZSH_CUSTOM/zsh-autosuggestions"
else
    log "zsh-autosuggestions already installed"
fi

log "Setup completed!"