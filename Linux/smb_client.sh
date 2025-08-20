#!/bin/bash

# Exit on error
set -e

# Function to handle errors
error_exit() {
    echo "$1" 1>&2
    exit 1
}

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo."
    exit 1
fi

# Check if SMB is already mounted
if mount | grep -q "cifs"; then
    echo "An SMB share is already mounted. Exiting the script."
    exit 1
fi

# Check if cifs-utils and openssl are installed
if ! dpkg -l | grep -q cifs-utils; then
    echo "Installing required packages..."
    if ! apt-get update; then
        error_exit "Failed to update package list."
    fi

    if ! apt-get install -y cifs-utils openssl; then
        error_exit "Failed to install cifs-utils and openssl."
    fi
else
    echo "cifs-utils is already installed. Skipping installation."
fi

# Prompt for user input
read -p "Enter SMB server IP address: " SMB_SERVER_IP
read -p "Enter SMB share name (e.g., shared_folder): " SMB_SHARE_NAME
read -p "Enter SMB_USERNAME: " SMB_USERNAME
read -s -p "Enter SMB_PASSWORD: " SMB_PASSWORD
echo

MOUNT_POINT="/mnt/media/smb"
UID=$(id -u)
GID=$(id -g)

# Encrypt the smb password
ENCRYPTED_SMB_PASSWORD=$(echo "$SMB_PASSWORD" | openssl enc -aes-256-cbc -a -salt -pass pass:your_secret_key)

# Create mount point directory
if ! mkdir -p "$MOUNT_POINT"; then
    error_exit "Failed to create mount point directory."
fi

# Create credentials file
CREDENTIALS_FILE="/etc/samba/credentials"
if ! mkdir -p /etc/samba; then
    error_exit "Failed to create /etc/samba directory."
fi
{
    echo "SMB_USERNAME=$SMB_USERNAME"
    echo "SMB_PASSWORD=$ENCRYPTED_SMB_PASSWORD"
} > "$CREDENTIALS_FILE" || error_exit "Failed to write to credentials file."
chmod 600 "$CREDENTIALS_FILE" || error_exit "Failed to set permissions on credentials file."

# Test mount
echo "Testing SMB mount..."
if ! mount -t cifs "//${SMB_SERVER_IP}/${SMB_SHARE_NAME}" "$MOUNT_POINT" -o credentials="$CREDENTIALS_FILE",uid=${UID},gid=${GID}; then
    echo "Test mount failed. Please check your inputs and try again."
    rm -f "$CREDENTIALS_FILE"
    rmdir "$MOUNT_POINT"
    exit 1
else
    echo "Test mount successful."
    umount "$MOUNT_POINT" || error_exit "Failed to unmount test mount."
fi

# Add to fstab for mounting at boot
fstab_entry="//${SMB_SERVER_IP}/${SMB_SHARE_NAME} ${MOUNT_POINT} cifs credentials=${CREDENTIALS_FILE},uid=${UID},gid=${GID} 0 0"
if ! grep -Fx "$fstab_entry" /etc/fstab > /dev/null; then
    echo "$fstab_entry" >> /etc/fstab || error_exit "Failed to add entry to /etc/fstab."
    echo "Added mount to /etc/fstab."
else
    echo "Mount already exists in /etc/fstab."
fi

# Test fstab mount
if ! mount -a; then
    error_exit "Failed to mount from fstab. Please check /etc/fstab and credentials."
else
    echo "SMB share successfully configured and mounted."
fi

echo "Setup complete. SMB share will mount automatically on boot."
