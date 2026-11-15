# Replay a Snort rule against two PCAPs

The two synthetic captures contain one UDP packet each from `192.0.2.10:40000` to `198.51.100.20:5514`. The packet in `match.pcap` begins with `LAB-IDS-CHECK`, and the packet in `benign.pcap` begins with `LAB-APP-CHECK`. The captures share the same endpoints and payload length.

## Replay

Use Snort 2.9.20 on Linux. It is available as the [Ubuntu 24.04 Snort package](https://packages.ubuntu.com/noble/snort). Start in the repository root with Snort already installed.

```bash
cd demo
log_dir=$(mktemp -d)
snort -q -A console -K none -l "$log_dir" -c snort.conf -r match.pcap
snort -q -A console -K none -l "$log_dir" -c snort.conf -r benign.pcap
```

Snort reads the captures offline. The demo uses a single [local rule](marker.rules) and needs no live interface or external ruleset.

| Capture | Expected result |
| --- | --- |
| [`match.pcap`](match.pcap) | One alert containing `[1:1000101:1] LAB UDP marker detected` and `192.0.2.10:40000 -> 198.51.100.20:5514` |
| [`benign.pcap`](benign.pcap) | Zero alerts |

The [GitHub Actions replay](https://github.com/SimoLaasri/nids-snort-network-security/actions/workflows/pcap-replay.yml) checks both outcomes. To regenerate the captures, run `python3 generate_pcaps.py` from this directory. The generator uses Python's standard library, fixed addresses and timestamps, and valid IPv4 and UDP checksums.

## Interpret the alert

The rule matches UDP traffic to `198.51.100.20:5514` when the first 13 payload bytes are `LAB-IDS-CHECK`. This establishes that the sensor saw the marker at that destination. It says nothing about who sent it or whether an application received or acted on it. A legitimate diagnostic program sending that prefix would produce the same alert. The benign capture checks one comparison case, so it cannot establish a false-positive rate.

To investigate, open the capture in Wireshark and apply `ip.dst == 198.51.100.20 && udp.dstport == 5514`. Check the UDP payload and compare the alert timestamp and endpoints to the frame. In a real investigation, identify the source process from endpoint telemetry, confirm the destination service with the asset inventory, and check its logs for what happened at that time.
