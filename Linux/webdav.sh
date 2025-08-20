#!/bin/bash

# Fixed variables
MOUNT_POINT="/mnt/media/webdav"
CREDENTIALS_FILE="/etc/davfs2/secrets"
DAVFS2_CONF="/etc/davfs2/davfs2.conf"
UID=$(id -u)
GID=$(id -g)

# Exit on error
set -e

# Function to handle errors
error_exit() {
    echo "$1" 1>&2
    exit 1
}

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo."
    exit 1
fi

# Check if WebDAV is already mounted
if mount | grep -q $MOUNT_POINT; then
    echo "An WebDAV share is already mounted. Exiting the script."
    exit 1
fi

# Prompt user for WebDAV details
read -p "Enter WebDAV URL (e.g., https://your-webdav-server.com/dav): " WEBDAV_URL
read -p "Enter WebDAV username: " WEBDAV_USER
read -s -p "Enter WebDAV password: " WEBDAV_PASS
echo

# Check if davfs2 is installed
if ! dpkg -l | grep -q davfs2; then
    echo "Installing davfs2..."
    if ! apt-get update; then
        error_exit "Failed to update package list."
    fi
    if ! apt-get install -y davfs2; then
        error_exit "Failed to install davfs2."
    fi
else
    echo "davfs2 is already installed. Skipping installation."
fi

# Create mount point
echo "Creating mount point at $MOUNT_POINT..."
if ! mkdir -p "$MOUNT_POINT"; then
    error_exit "Failed to create mount point."
fi
if ! chown $UID:$GID "$MOUNT_POINT"; then
    error_exit "Failed to change ownership of mount point."
fi
if ! chmod 700 "$MOUNT_POINT"; then
    error_exit "Failed to set permissions on mount point."
fi

# Configure credentials
echo "Configuring WebDAV credentials..."
if ! mkdir -p /etc/davfs2; then
    error_exit "Failed to create davfs2 directory."
fi
if ! echo "$WEBDAV_URL $WEBDAV_USER $WEBDAV_PASS" >> "$CREDENTIALS_FILE"; then
    error_exit "Failed to write credentials to file."
fi
if ! chown $UID:$GID "$CREDENTIALS_FILE"; then
    error_exit "Failed to change ownership of credentials file."
fi
if ! chmod 600 "$CREDENTIALS_FILE"; then
    error_exit "Failed to set permissions on credentials file."
fi

# Add entry to /etc/fstab
echo "Adding WebDAV mount to /etc/fstab..."
if ! echo "$WEBDAV_URL $MOUNT_POINT davfs rw,auto,uid=$UID,gid=$GID 0 0" >> /etc/fstab; then
    error_exit "Failed to add entry to /etc/fstab."
fi

# Configure davfs2 to allow non-root users to mount
echo "Configuring davfs2 for user mounting..."
if ! echo "use_locks 0" >> "$DAVFS2_CONF"; then
    error_exit "Failed to configure davfs2 for user mounting."
fi

# Test the mount
echo "Testing WebDAV mount..."
if ! mount "$MOUNT_POINT"; then
    error_exit "Mount failed. Check your WebDAV URL, credentials, or network."
fi
echo "Mount successful. Filesystem mounted at $MOUNT_POINT."
if ! ls -l "$MOUNT_POINT"; then
    error_exit "Failed to list files in the mounted directory."
fi

echo "Setup complete. WebDAV share will mount automatically on boot at $MOUNT_POINT for user with UID:GID $UID:$GID."