# Linux OS Info

Bash utility that collects and displays useful informations about a Linux system.

## Collected Informations

- Hostname
- Uptime
- Operating system type/name
- Kernel name/version
- Machine architecture
- Package manager information
- Memory details
- CPU information
- Load average
- Users connected
- Disk partitions/utilization
- DNS configuration
- External IP address
- Network interfaces

## Use Cases

- Linux troubleshooting
- System inventory
- Monitoring support activities

## Usage

```bash
./GetLinuxOS.sh
```

## Output

```bash
Hostname = localhost.localdomain
Uptime = 1 hour, 37 minutes
Operating system = GNU/Linux
OS full name = Oracle Linux Server - Version: 9.6; Like: fedora
Kernel name = Linux
Kernel release = 5.15.0-313.189.5.1.el9uek.x86_64
Machine architecture = x86_64
Package manager = RPM version 4.16.1.3
Memory = Total: 3.4G - Free: 681M (Swap total: 2.0G - Swap free: 1.7G) -> Tot: 5.5G - Free: 2.4G
CPU = 3 - Model: AMD Ryzen 7 6800H with Radeon Graphics
Load average =  0.02, 0.10, 0.15
Users connected = root
Disk partitions =
  NAME        FSTYPE         SIZE MOUNTPOINT LABEL
  sda                         20G
  ├─sda1                       1M
  ├─sda2      xfs              2G /boot
  └─sda3      LVM2_member     18G
    ├─rl-root xfs             16G /
    └─rl-swap swap             2G [SWAP]
  sr0         iso9660     1000,9M            Rocky-10-2-x86_64-dvd
Disk utilization =
  /: 2,2G/16G (14%)
  /boot: 443M/2,0G (23%)
DNS server =  <DNS_SERVER>
Internet = connected
External IP address = <EXTERNAL_IP>
Network interfaces info =
  lo         IP address: 127.0.0.1
  enp0s3     IP address: <INTERFACE_IP>
```

Privacy note: In the example output, network interface IP addresses, external IP address and DNS server IP addresses have been replaced with placeholders to avoid exposing actual network details. The script reports the real values when run.
