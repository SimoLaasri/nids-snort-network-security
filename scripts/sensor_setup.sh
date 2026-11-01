#!/usr/bin/env bash
set -euo pipefail

# Install Snort and the default community rules on Ubuntu.
sudo apt update
sudo apt install snort snort-rules-default -y

# Apply the stealth Netplan configuration for the capture interface.
sudo install -m 0644 configs/netplan-stealth.yaml /etc/netplan/00-installer-config.yaml
sudo netplan apply

# Enable passive capture on the sensor interface.
sudo ip link set dev ens34 promisc on

# Install the project rules and validate the Snort configuration.
sudo install -m 0644 rules/local.rules /etc/snort/rules/local.rules
sudo snort -T -c /etc/snort/snort.conf

# Start Snort in console alert mode on the stealth interface.
sudo snort -A console -q -c /etc/snort/snort.conf -i ens34
