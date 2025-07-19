#!/bin/zsh

# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo"
    exit 1
fi

# Exit immediately if a command exits with a non-zero status
set -e

# Install Homebrew if it's not already installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Install Ansible if it's not already installed
if ! command -v ansible &> /dev/null; then
    echo "Installing Ansible..."
    brew install ansible
else
    echo "Ansible is already installed."
fi

# Run the Ansible playbook from a GitHub repository
PLAYBOOK_URL="https://raw.githubusercontent.com/FainiDenis/SetupAndDeploy/refs/heads/main/macOS/setup_macbook.yml"

echo "Running Ansible playbook..."
ansible-playbook -i localhost, -c local "$PLAYBOOK_URL"

# Uninstall Ansible
echo "Uninstalling Ansible..."
brew uninstall ansible

echo "Setup complete!"
