#!/usr/bin/env bash
set -euo pipefail

# Reconstructed helper for an isolated Ubuntu / Snort 2 lab.
# Networking is reviewed and applied manually; this script never applies Netplan.
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

sudo apt update
sudo apt install -y snort snort-rules-default python3
if ! snort -V 2>&1 | grep -Eq 'Version[[:space:]]+2\.'; then
    echo 'This helper requires Snort 2.x; Snort 3 uses a different configuration.' >&2
    exit 1
fi

backup_suffix="$(date -u +%Y%m%dT%H%M%S)-$$"
sudo cp -p /etc/snort/snort.conf "/etc/snort/snort.conf.portfolio-${backup_suffix}"
if sudo test -f /etc/snort/rules/local.rules; then
    sudo cp -p /etc/snort/rules/local.rules "/etc/snort/rules/local.rules.portfolio-${backup_suffix}"
fi
sudo install -m 0644 "$repo_dir/rules/local.rules" /etc/snort/rules/local.rules

sudo python3 - <<'PY'
from pathlib import Path
import re

config = Path('/etc/snort/snort.conf')
text = config.read_text()
for name, value in {
    'HOME_NET': '192.168.50.0/24',
    'HTTP_SERVERS': '192.168.50.20/32',
    'SSH_SERVERS': '192.168.50.20/32',
}.items():
    pattern = rf'(?m)^\s*(?:ipvar|var)\s+{name}\s+[^\n]*$'
    text, count = re.subn(pattern, f'ipvar {name} {value}', text)
    if not count:
        raise SystemExit(f'Missing {name}; configure this Snort distribution manually.')
if not re.search(r'(?m)^\s*include\s+\$RULE_PATH/local\.rules\s*(?:#.*)?$', text):
    text += '\ninclude $RULE_PATH/local.rules\n'
config.write_text(text)
PY

sudo snort -T -c /etc/snort/snort.conf
echo 'Rules installed and configuration checked. Review docs/lab-guide.md before starting capture.'
