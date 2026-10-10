# Linux System Info

[Get-LinuxSystemInfo.sh](Get-LinuxSystemInfo.sh) is a Bash utility that collects Linux system information and prints a colored report to the terminal. It does not change system configuration.

Use it for troubleshooting, system inventory and monitoring support activities.

## Requirements

- Linux with Bash and standard GNU command-line utilities.
- System information tools: `hostname`, `uname`, `uptime`, `free`, `lscpu`, `who`, `lsblk` and `df`.
- Network tools: `ip`, `ping` and `wget`.
- Text-processing tools: `grep` with Perl-compatible regex support (`-P`), `awk`, `sed`, `cut`, `sort`, `tr` and `wc`.
- Read access to operating-system release files and `/etc/resolv.conf`.

Package-manager detection checks `rpm`, then `dpkg`, then `pacman`. It reports the first recognized tool; all three are not required.

External connectivity is used for the Internet check and public IP lookup. Local information can still be collected when these requests fail.

## Usage

From the project directory:

```bash
chmod +x Get-LinuxSystemInfo.sh
./Get-LinuxSystemInfo.sh
```

Alternatively, run it through Bash without changing executable permissions:

```bash
bash Get-LinuxSystemInfo.sh
```

The script accepts no arguments. It has no command-line options for selecting sections or exporting structured output.

## Collected information

| Section           | Information                                                                              |
| ----------------- | ---------------------------------------------------------------------------------------- |
| System            | Hostname, uptime, operating-system name/version, kernel and architecture.                |
| Package manager   | Detected RPM, dpkg or pacman information.                                                |
| Memory            | Total and free RAM, swap and combined totals when available.                             |
| CPU               | Logical CPU count and processor model.                                                   |
| Load and sessions | Load averages and unique logged-in usernames.                                            |
| Storage           | Block devices, filesystem types, sizes, mountpoints, labels and filesystem utilization.  |
| DNS               | Nameserver entries from `/etc/resolv.conf`.                                              |
| Connectivity      | Result of a single ping to `google.com`.                                                 |
| Public IP         | Response from `ipecho.net/plain`.                                                        |
| Network           | IPv4 addresses and MAC address lines returned by the script's parsing of `ip addr show`. |

## Example output

The following example omits terminal colors and uses representative system values. The hostname and all IP addresses are replaced with placeholders. Available rows and formatting vary by host.

```text
Hostname = <HOSTNAME>
Uptime = 1 hour, 37 minutes
Operating system = GNU/Linux
OS full name = Oracle Linux Server - Version: 9.6; Like: fedora
Kernel name = Linux
Kernel release = 5.15.0-313.189.5.1.el9uek.x86_64
Machine architecture = x86_64
Package manager = RPM version 4.16.1.3
Memory = Total: 3.4G - Free: 681M (Swap total: 2.0G - Swap free: 1.7G) -> Tot: 5.5G - Free: 2.4G
CPU = 3 - Model: AMD Ryzen 7 6800H with Radeon Graphics
Load average = 0.02, 0.10, 0.15
Users connected = root
Disk partitions =
  NAME        FSTYPE         SIZE MOUNTPOINT LABEL
  sda                         20G
  ├─sda1                       1M
  ├─sda2      xfs              2G /boot
  └─sda3      LVM2_member     18G
    ├─rl-root xfs             16G /
    └─rl-swap swap             2G [SWAP]
Disk utilization =
  /: 2.2G/16G (14%)
  /boot: 443M/2.0G (23%)
DNS server = <DNS_SERVER_ADDRESS>
Internet = connected
External IP address = <PUBLIC_IP_ADDRESS>
Network interfaces info =
  lo         IP address: <LOOPBACK_IP_ADDRESS>
  enp0s3     IP address: <INTERFACE_IP_ADDRESS>
```

The real report includes hostnames, usernames, hardware details, disk labels and network addresses. Anonymize these fields before sharing it.

## Network behavior

The Internet check runs `ping -c 1 google.com`. A successful ping produces `connected`; a failed ping produces `not connected`. DNS problems or blocked ICMP can cause a failure even when other Internet traffic works.

The public IP lookup runs `wget -T 20 -qO- ipecho.net/plain`. This contacts an external service over HTTP and reports the address visible to that service, which may be a NAT or proxy address. An empty response is displayed as `???`. The script has no option to disable these network requests.

## Limitations and troubleshooting

- `???` indicates information that could not be detected or parsed in sections that use this fallback. Other missing commands can produce stderr messages or incomplete output.
- OS identification prefers `/etc/os-release`, then `/etc/lsb-release`. If no file matching `/etc/*release*` exists, the script stops with a warning.
- Memory reports the `free` column, rather than the `available` memory estimate.
- Filesystem utilization includes only `df` rows whose device starts with `/dev`; it is not a complete inventory of network or virtual filesystems. Block-device output filters lines containing `loop`.
- Network output covers IPv4 and MAC addresses, not IPv6. MAC rows use the final field of the parsed line as their label, which may not identify the interface correctly.
- The report is intended for human inspection. Exit codes do not provide a reliable overall health assessment, and there are no monitoring thresholds or JSON output.

## Project layout

```text
Linux-System-Info/
|-- Get-LinuxSystemInfo.sh
|-- README.md
`-- LICENSE
```

## License

Released under the MIT License. See [LICENSE](LICENSE).
