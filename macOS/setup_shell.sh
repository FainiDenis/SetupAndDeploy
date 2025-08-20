#!/bin/zsh

# ============================================================================
# Shell Environment Setup Script
# Installs Oh My Zsh, plugins, and configures aliases
# ============================================================================

ZSHRC_FILE="$HOME/.zshrc"
OHMYZSH_INSTALL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
ZSH_SYNTAX_HIGHLIGHTING_URL="https://github.com/zsh-users/zsh-syntax-highlighting.git"
ZSH_AUTOSUGGESTIONS_URL="https://github.com/zsh-users/zsh-autosuggestions.git"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

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

# Install Oh My Zsh
task_start "Checking for Oh My Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    task_start "Installing Oh My Zsh"
    # Prevent Oh My Zsh from auto-loading during installation
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL $OHMYZSH_INSTALL_URL)" &&
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

# Configure plugins in .zshrc
task_start "Configuring Oh My Zsh plugins"
if ! grep -q "plugins=(git zsh-syntax-highlighting zsh-autosuggestions)" "$ZSHRC_FILE" 2>/dev/null; then
    # Replace the plugins line or add it if it doesn't exist
    if grep -q "^plugins=" "$ZSHRC_FILE"; then
        sed -i '' 's/^plugins=.*/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' "$ZSHRC_FILE"
    else
        echo "plugins=(git zsh-syntax-highlighting zsh-autosuggestions)" >> "$ZSHRC_FILE"
    fi
    task_result "Changed" "Oh My Zsh plugins configured"
else
    task_result "OK" "Oh My Zsh plugins already configured"
fi