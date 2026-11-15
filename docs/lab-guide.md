# Lab setup and validation

These instructions explain the reconstructed helpers. The original multi-VM environment is no longer available, and these steps have not been run against a new Snort lab.

## Prepare the VMs

Create the Host-Only network and assign the target `192.168.50.20/24` and Kali `192.168.50.130/24`. Give the sensor a management NIC and a separate capture NIC attached to the lab segment. Verify interface names with `ip -br addr`.

The report uses Snort 2.9 on Ubuntu Server 22.04. Confirm package availability and inspect `snort -V` before continuing. The examples do not apply to Snort 3.

`scripts/victim_setup.sh` installs Apache, OpenSSH, vsftpd, and Samba. It does not deliberately make these services vulnerable, enable root SSH login, configure anonymous FTP, or create SMB shares. These details affect test outcomes and must be configured separately in an isolated lab if needed.

## Install the sensor rules

Run `bash scripts/sensor_setup.sh` on the sensor. The script:

1. Installs Snort and the packaged default rules.
2. Confirms the installed engine is Snort 2.x.
3. Backs up `snort.conf` and any existing `local.rules`.
4. Installs this repository's local rules and sets `HOME_NET`, `HTTP_SERVERS`, and `SSH_SERVERS` in the existing full configuration.
5. Ensures the local rule include exists and runs `snort -T`.

It does not replace the entire Snort configuration with the small variable excerpt. It also does not replace Netplan or start packet capture automatically. Review `configs/netplan-stealth.yaml` against your actual interfaces and configure networking separately.

## Capture and alerts

First complete the traffic visibility check in [architecture.md](architecture.md). Then validate and start Snort in console mode:

```bash
sudo snort -T -c /etc/snort/snort.conf -i ens34
sudo snort -A console -q -c /etc/snort/snort.conf -i ens34
```

This displays alerts in the terminal. For a separate run using fast file alerts:

```bash
sudo mkdir -p /var/log/snort
sudo snort -A fast -q -c /etc/snort/snort.conf -i ens34 -l /var/log/snort
```

With this Snort 2 invocation, inspect `/var/log/snort/alert`. The report uses a different configured filename, `snort.alert.fast`; that name is not guaranteed by console mode or by this command.

## Generate one event at a time

On Kali, `bash scripts/attack_commands.sh` prints available scenarios without generating traffic. Choose `http`, `xmas`, `smb`, `nmap`, or `ssh`. The HTTP scenario uses `curl --path-as-is` so curl does not normalize away the traversal sequence. An HTTP error response does not necessarily prevent the request from matching a network signature.

The optional SSH scenario requires `LAB_USER` and `PASSWORD_LIST` pointing to a small local lab fixture. It does not enable root login or use a large password list by default. SSH banners are only a connection-rate signal; the rule cannot inspect encrypted password failures.

Record the timestamp, command, observed packets, alert SID, and target response for each test. The supplied sample log is historical evidence from the report, not the expected output of a fresh automated test.
