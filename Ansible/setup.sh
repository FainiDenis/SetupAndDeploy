#!/bin/bash

# This script is designed to be run on Linux Debian-based systems.
# It will install Ansible if it is not already installed, and then prompt the user to
# select an Ansible playbook to run. The user can choose from a list of available
# playbooks, or exit the script. The selected playbook will be executed using Ansible,
# and a success message will be displayed upon completion. The user will then be prompted
# to run another playbook or exit the script. The script is designed to be user-friendly
# and easy to use, with clear instructions and prompts for the user.

# Check if Ansible is not installed then install it
if ! command -v ansible &> /dev/null; then
    echo "Ansible is not installed. Installing Ansible..."
    sudo apt update && sudo apt install -y ansible

else
    echo "Ansible is already installed."
fi

# prompts for the vault password, storing it temporarily in .vault_pass.txt with restricted permissions.
if [ ! -f ~/.vault_pass.txt ]; then
    echo "Please enter your Ansible vault password:"
    read -s vault_password
    echo "$vault_password" > ~/.vault_pass.txt
    chmod 600 ~/.vault_pass.txt
else
    echo "Vault password file already exists."
fi

# Display Ansible playbooks and prompt user to select one with number option
echo "Available Ansible playbooks:"
echo "---------------------------------"
echo "1. Update and Upgrade System"
echo "2. Configure firewall with UFW"
echo "3. Hardening Linux system"
echo "4. Mount SMB share"
echo "5. Setup Admin User"
echo "6. All Playbooks"
echo "7. Exit"
read -p "Select a playbook to run (1-7): " choice
# Run the selected Ansible playbook
case $choice in
    1)
        ansible-playbook update_upgrade_system.yml --vault-password-file ~/.vault_pass.txt
        ;;
    2)
        ansible-playbook --configure_firewall.yml --vault-password-file ~/.vault_pass.txt
        ;;
    3)
        ansible-playbook harden_system.yml --vault-password-file ~/.vault_pass.txt
        ;;
    4)
        ansible-playbook mount_smb.yml --vault-password-file ~/.vault_pass.txt
        ;;
    5)
        ansible-playbook setup_admin_user.yml --vault-password-file ~/.vault_pass.txt
        ;;
    6)
        ansible-playbook update_upgrade_system.yml --vault-password-file ~/.vault_pass.txt
        ansible-playbook configure_firewall.yml --vault-password-file ~/.vault_pass.txt
        ansible-playbook harden_system.yml --vault-password-file ~/.vault_pass.txt
        ansible-playbook mount_smb.yml --vault-password-file ~/.vault_pass.txt
        ansible-playbook setup_admin_user.yml --vault-password-file ~/.vault_pass.txt
        ;;
    7)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice. Exiting..."
        exit 1
        ;;
esac

# Display success message
echo "Ansible playbook executed successfully."
# Prompt user to run the script again
read -p "Do you want to run another playbook? (y/n): " run
if [[ $run == "y" || $run == "Y" ]]; then
    exec $0
else
    echo "Exiting..."
    echo "Uninstalling Ansible..."
    sudo apt remove -y ansible
    sudo apt autoremove -y
    echo "Ansible uninstalled successfully."
    rm -f ~/.vault_pass.txt  # Clean up the vault password file
    echo "Vault password file removed."
    exit 0
fi
# End of script