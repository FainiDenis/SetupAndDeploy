#!/bin/zsh

# ============================================================================
# macOS Configuration Script
# Configures system settings, Finder, Dock, and other preferences
# ============================================================================

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
task_result "Changed" "Screenshots location set to $SCREENSHOT_DIR"

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