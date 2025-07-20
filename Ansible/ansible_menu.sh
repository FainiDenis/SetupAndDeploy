#!/bin/bash

# Exit on error
set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Ansible
install_ansible() {
    echo "Checking if Ansible is installed..."
    if ! command_exists ansible; then
        echo "Installing Ansible..."
        sudo apt-get update
        sudo apt-get install -y software-properties-common
        sudo add-apt-repository --yes --update ppa:ansible/ansible
        sudo apt-get install -y ansible
        echo "Ansible installed successfully."
    else
        echo "Ansible is already installed."
    fi
}

# Function to uninstall Ansible
uninstall_ansible() {
    echo "Uninstalling Ansible..."
    sudo apt-get remove -y ansible
    sudo apt-get autoremove -y
    sudo apt-get purge -y ansible
    sudo rm -rf /etc/ansible
    echo "Ansible uninstalled successfully."
}

# Function to check if playbooks exist
check_playbooks() {
    local playbooks=("$@")
    for playbook in "${playbooks[@]}"; do
        if [[ ! -f "$playbook" ]]; then
            echo "Error: Playbook $playbook not found in the current directory."
            exit 1
        fi
    done
}

# Function to display menu and get user selection
display_menu() {
    local playbooks=("$@")
    echo "Available Ansible Playbooks:"
    for i in "${!playbooks[@]}"; do
        echo "$((i+1)). ${playbooks[i]}"
    done
    echo "$(( ${#playbooks[@]} + 1 )). Run all playbooks"
    echo "$(( ${#playbooks[@]} + 2 )). Exit"
    read -p "Select an option (1-$(( ${#playbooks[@]} + 2 ))): " choice
    echo "$choice"
}

# Function to run selected playbook(s)
run_playbooks() {
    local choice="$1"
    local playbooks=("${@:2}")
    local vault_pass_file=".vault_pass.txt"

    # Check if group_vars/all/vars.yml exists (indicating possible vault usage)
    if [[ -f "group_vars/all/vars.yml" ]]; then
        read -p "Is group_vars/all/vars.yml encrypted with Ansible Vault? (y/n): " vault_answer
        if [[ "$vault_answer" =~ ^[Yy]$ ]]; then
            read -s -p "Enter Ansible Vault password: " vault_pass
            echo
            echo "$vault_pass" > "$vault_pass_file"
            chmod 600 "$vault_pass_file"
            vault_option="--vault-password-file=$vault_pass_file"
        else
            vault_option=""
        fi
    else
        vault_option=""
    fi

    if [[ "$choice" -eq $(( ${#playbooks[@]} + 1 )) ]]; then
        echo "Running all playbooks..."
        for playbook in "${playbooks[@]}"; do
            echo "Running $playbook..."
            ansible-playbook $vault_option "$playbook" || {
                echo "Error running $playbook"
                rm -f "$vault_pass_file"
                exit 1
            }
        done
    elif [[ "$choice" -ge 1 && "$choice" -le ${#playbooks[@]} ]]; then
        local selected_playbook="${playbooks[$((choice-1))]}"
        echo "Running $selected_playbook..."
        ansible-playbook $vault_option "$selected_playbook" || {
            echo "Error running $selected_playbook"
            rm -f "$vault_pass_file"
            exit 1
        }
    elif [[ "$choice" -eq $(( ${#playbooks[@]} + 2 )) ]]; then
        echo "Exiting without running any playbooks."
        rm -f "$vault_pass_file"
        return 1
    else
        echo "Invalid choice. Exiting."
        rm -f "$vault_pass_file"
        return 1
    fi

    # Clean up vault password file if it exists
    rm -f "$vault_pass_file"
}

# Main script
echo "Ansible Playbook Menu"

# List of playbooks
playbooks=(
    "update_system.yml"
    "setup_admin_user.yml"
    "harden_system.yml"
    "configure_firewall.yml"
    "mount_smb.yml"
)

# Check if playbooks exist
check_playbooks "${playbooks[@]}"

# Install Ansible
install_ansible

# Display menu and get user choice
choice=$(display_menu "${playbooks[@]}")

# Run selected playbook(s)
run_playbooks "$choice" "${playbooks[@]}"

# Uninstall Ansible
uninstall_ansible

echo "All tasks completed successfully."