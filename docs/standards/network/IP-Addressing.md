# IP Addressing Strategy

This page documents IP address allocation strategy across VLANs. Defines static IP ranges for infrastructure devices and DHCP pools for clients.

## Overview

All VLANs follow a consistent /24 subnet pattern:

- **x.x.X.1** — OPNsense gateway
- **x.x.X.10-99** — Static IPs (infrastructure, servers, network gear)
- **x.x.X.100-254** — DHCP pool (clients, temporary devices)

## VLAN 10 (Management)

Network devices only.

```txt
10.0.10.1 — OPNsense interface
10.0.10.10-49 — Switches, network gear
10.0.10.50-60 — Wireless APs
10.0.10.61-99 — Reserved
10.0.10.100-254 — DHCP pool
```

## VLAN 20 (Infrastructure)

Proxmox nodes and compute resources.

```txt
10.0.20.1 — OPNsense interface
10.0.20.10-50 — Proxmox nodes (static, required for cluster)
10.0.20.51-99 — Reserved for future infrastructure
10.0.20.100-254 — DHCP pool
```

## VLAN 30 (Trusted)

Personal devices.

```txt
10.0.30.1 — OPNsense interface
10.0.30.100-254 — DHCP pool
```

## VLAN 35 (Shared)

Friends/family and personal auxiliary devices.

```txt
10.0.35.1 — OPNsense interface
10.0.35.100-254 — DHCP pool
```

## VLAN 40 (DMZ)

Internet-facing services.

```txt
10.0.40.1 — OPNsense interface
10.0.40.10-99 — Static IPs for DMZ services (reverse proxy, etc.)
10.0.40.100-254 — DHCP pool
```

## VLAN 50 (Services)

Internal services and applications.

```txt
10.0.50.1 — OPNsense interface
10.0.50.10-99 — Static IPs for services (Home Assistant, Jellyfin, etc.)
10.0.50.100-254 — DHCP pool
```

## VLAN 60 (Lab)

Experimental workloads.

```txt
10.0.60.1 — OPNsense interface
10.0.60.10-99 — Lab infrastructure (test VMs, containers)
10.0.60.100-254 — DHCP pool
```

## VLAN 70 (IoT)

Smart home devices.

```txt
10.0.70.1 — OPNsense interface
10.0.70.10-99 — Static IPs for critical IoT (Zigbee hub, Z-Wave hub, etc.)
10.0.70.100-254 — DHCP pool (bulbs, sensors, switches)
```

## VLAN 80 (Isolated)

Untrusted IoT devices.

```txt
10.0.80.1 — OPNsense interface
10.0.80.100-254 — DHCP pool (IP cameras, etc.)
```

## VLAN 90 (Guest)

Guest and untrusted devices.

```txt
10.0.90.1 — OPNsense interface
10.0.90.100-254 — DHCP pool
```

## VLAN 100 (WireGuard)

Remote VPN access.

```txt
10.0.100.1 — OPNsense interface / WireGuard server
10.0.100.2-254 — WireGuard client pool
```

## General Rules

- Always use static IPs (10-99 range) for infrastructure devices that require reliable addressing
- Proxmox nodes should have static IPs for cluster communication
- DHCP pools (100-254) for client devices only
- Never use 10.x.x.0 or 10.x.x.255 (network/broadcast addresses)
- Reserve 10-99 ranges even if not fully populated for future growth
