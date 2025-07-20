# Ansible Playbook Automation Setup

This repository automates system configuration tasks on Debian/Ubuntu-based systems (e.g., Ubuntu, Debian, Proxmox, or Docker containers) using Ansible playbooks and a Bash script (`setup.sh`). The playbooks handle system updates, admin user setup, system hardening, firewall configuration, and SMB share mounting. Sensitive data is secured using Ansible Vault.

## Repository Structure

### Playbooks:
- `update_system.yml`: Updates and upgrades system packages.
- `setup_admin_user.yml`: Creates an admin user with a secure password.
- `harden_system.yml`: Applies security hardening (e.g., disables root SSH login).
- `configure_firewall.yml`: Configures UFW, allowing port 8006/tcp for Proxmox servers.
- `mount_smb.yml`: Mounts an SMB share and adds it to `/etc/fstab`.

### Script:
- `setup.sh`: Installs Ansible, prompts for a vault password, runs selected playbooks, and uninstalls Ansible.

### Vault File:
- `group_vars/all/vars.yml`: Stores sensitive variables (encrypted).

## Prerequisites

- **Operating System**: Debian/Ubuntu-based (e.g., Ubuntu, Debian, Proxmox, or Docker).
- **Permissions**: Root or sudo access for installing Ansible and modifying system files.
- **Network**: Internet access for Ansible installation and SMB server access (if applicable).


## Ansible Vault Setup

Sensitive variables (e.g., `admin_username`, `admin_password`, `smb_username`, `smb_password`, `smb_server`, `smb_mount_point`) are stored in an encrypted `group_vars/all/vars.yml` file to prevent exposure in a public repository.

### Steps
1. Clone the repository and navigate into it:
    ```bash
    git clone https://github.com/FainiDenis/SetupAndDeploy.git && cd SetupAndDeploy
    ```

2. Create an encrypted vault file
   ```bash
   ansible-vault create ./Ansible/group_vars/all/vars.yml
   ```

3. When prompted, set a strong Vault password. Save this password securely. In the editor that opens, define the variables by replacing placeholders with your actual information:
    ```yaml
    admin_username: adminuser
    admin_password: your_secure_password
    smb_server: "//192.168.1.1/share"
    smb_username: smbuser
    smb_password: your_smb_password
    smb_mount_point: /mnt/smbshare
    ```
4. Save and exit the editor. The file is now encrypted and protected.
5. Run the setup script
   ```bash
   ./setup.sh
   ```
6. Follow the on-screen menu to select and execute the desired Playbook tasks.