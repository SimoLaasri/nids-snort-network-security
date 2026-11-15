# Laboratory architecture

The lab has a Kali traffic generator, an Ubuntu target, and a separate Ubuntu Snort sensor. The sensor observes traffic passively; it does not route or block it.

| Component | Interface/address | Role |
|---|---|---|
| Kali | `192.168.50.130/24` | Controlled traffic generation |
| Ubuntu target | `192.168.50.20/24` | HTTP, SSH, FTP, and SMB services |
| Sensor management | `ens33`, DHCP on management network | Administration and package installation |
| Sensor capture | `ens34`, no assigned lab IPv4 address | Capture on the Host-Only lab segment |

The report calls the VMware network `VMnet2`. Interface names and VMware network identifiers are local configuration choices; check them before applying any example.

## Traffic visibility

Host-Only networking separates the lab from the physical LAN when no participant forwards or bridges traffic outside it. Promiscuous mode is a separate setting: it allows receipt of traffic already delivered by the virtual switch. It does not instruct the switch to copy every other VM's unicast frames.

The report's Figure 2.5 shows the sensor capturing ICMP exchanges between lab hosts. For a rebuild:

1. Put the target, Kali, and the sensor capture NIC on the same intended lab segment.
2. Check the virtual networking platform's support for promiscuous delivery or configure a supported mirror/TAP path.
3. On the sensor, run `sudo tcpdump -ni ens34 'host 192.168.50.130 and host 192.168.50.20'`.
4. Generate traffic between Kali and the target. Confirm that the sensor sees both sides of that exchange before investigating Snort rules.

No packets arriving at the sensor is a visibility problem, not evidence that the traffic was harmless.

## Interface configuration

`configs/netplan-stealth.yaml` disables DHCP and router advertisements on the example capture NIC. It is a report-based example, not a complete guarantee of an address-free interface: IPv6 link-local addressing can still exist. Inspect `ip addr show dev ens34` and, if the lab requires no link-local address, configure `link-local: []` after checking the installed Netplan version.

Review all existing Netplan files before making changes. Do not overwrite a management configuration blindly or apply it remotely without a recovery path. Promiscuous mode can be enabled for the lab with `sudo ip link set dev ens34 promisc on`; that runtime setting may not survive a reboot.

## Detection flow

1. Kali sends a selected request to the lab target.
2. A verified copy of the traffic reaches the capture NIC.
3. Snort decodes it and evaluates the configured rules.
4. Console alerts or file alerts are reviewed alongside packet captures.
5. Target service responses and host logs are checked separately when assessing outcome.
