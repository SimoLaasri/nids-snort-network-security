#!/usr/bin/env bash
set -euo pipefail

# Install the services used as controlled attack surfaces.
sudo apt update
sudo apt install apache2 openssh-server vsftpd samba -y

# Enable the services at boot and start them now.
sudo systemctl enable --now apache2 ssh vsftpd smbd

# The report assigns the victim address 192.168.50.20/24.
# Apply the address using the victim's normal Ubuntu network configuration.
