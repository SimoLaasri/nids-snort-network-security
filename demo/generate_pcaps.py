"""Write deterministic, single-packet Ethernet captures without opening a socket."""

import struct
from ipaddress import IPv4Address
from pathlib import Path


def checksum(data):
    if len(data) % 2:
        data += b"\x00"
    total = sum(value for (value,) in struct.iter_unpack("!H", data))
    while total > 0xFFFF:
        total = (total & 0xFFFF) + (total >> 16)
    return ~total & 0xFFFF


def build_frame(payload):
    source = IPv4Address("192.0.2.10").packed
    destination = IPv4Address("198.51.100.20").packed
    udp_protocol = 17
    udp_length = 8 + len(payload)
    udp_header = struct.pack("!HHHH", 40000, 5514, udp_length, 0)
    pseudo_header = source + destination + struct.pack("!BBH", 0, udp_protocol, udp_length)
    udp_checksum = checksum(pseudo_header + udp_header + payload) or 0xFFFF
    udp_header = udp_header[:6] + struct.pack("!H", udp_checksum)

    ipv4_header = struct.pack(
        "!BBHHHBBH4s4s", 0x45, 0, 20 + udp_length, 1, 0, 64, udp_protocol, 0,
        source, destination,
    )
    ipv4_header = ipv4_header[:10] + struct.pack("!H", checksum(ipv4_header)) + ipv4_header[12:]
    ethernet_header = bytes.fromhex("020000000002 020000000001 0800")
    return ethernet_header + ipv4_header + udp_header + payload


def write_capture(path, payload):
    frame = build_frame(payload)
    # Little-endian PCAP 2.4, microsecond timestamps, Ethernet link type.
    global_header = struct.pack("<IHHiIII", 0xA1B2C3D4, 2, 4, 0, 0, 65535, 1)
    packet_header = struct.pack("<IIII", 1704067200, 0, len(frame), len(frame))
    path.write_bytes(global_header + packet_header + frame)


if __name__ == "__main__":
    demo = Path(__file__).resolve().parent
    write_capture(demo / "match.pcap", b"LAB-IDS-CHECK demo v1\n")
    write_capture(demo / "benign.pcap", b"LAB-APP-CHECK demo v1\n")
