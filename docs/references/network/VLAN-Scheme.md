# VLAN Scheme

## Overview

| VLAN | Name           | Purpose                                                   |
|------|----------------|-----------------------------------------------------------|
| 10   | Management     | Network switches, etc.                                    |
| 20   | Infrastructure | Servers, hypervisors, etc.                                |
| 30   | Trusted        | Personal devices (eg. PC, laptop, phone)                  |
| 35   | Shared         | Friends/family devices (access to certain services)       |
| 40   | DMZ            | Internet-facing services (eg. Nginx)                      |
| 50   | Services       | Self-hosted apps (eg. Nextcloud, Jellyfin)                |
| 60   | Lab            | Experimental stuff                                        |
| 70   | IoT            | Smart devices (eg. smart bulb)                            |
| 80   | Isolated       | Completely untrusted devices (eg. IP camera)              |
| 90   | Guest          | Untrusted devices (guest devices, work laptop)            |
| 100  | WireGuard      | VPN (same as Trusted)                                     |

---

## VLAN Guidelines

### VLAN 10 — Management

Manages and monitors network devices.

- Network devices include things like: managed switches, network appliances, OPNsense, etc.
- Accessible from Trusted (30) and Wireguard (100)

### VLAN 20 — Infrastructure

Servers, hypervisors, and compute resources.

- Proxmox nodes, hypervisors, bare metal compute
- Accessed from: Trusted (30) or WireGuard (100)
- Can reach: Internet, Services (50), other Infrastructure nodes (20)

### VLAN 30 — Trusted

Primary working VLAN. Daily-driven devices goes here with lots of access

- Desktop PC, laptop
- Can reach: Management (10), Infrastructure (20), DMZ (40), Services (50), Lab (60), IoT (70), Isolated (80)

### VLAN 35 — Shared

Personal secondary devices and trusted guests with limited access.

- Personal secondary devices, friend/family devices, trusted guest devices
- Can reach: Internal reverse proxy (Services 50) on ports 80/443, Lab (60), IoT (70)
- Cannot reach: Management (10), Infrastructure (20), DMZ (40), Isolated (80), Guest (90)

### VLAN 40 — DMZ

Internet-facing services. Anything that accepts public inbound traffic lives here.

- Reverse proxy, public websites, etc.
- Cloud VPS WireGuard tunnel terminates and routes to here
- Can only reach Services (50) on specific defined ports — nothing else internal

### VLAN 50 — Services

Internal self-hosted apps and backend services. No public exposure directly.

- Home Assistant, Vaultwarden, Jellyfin, Nextcloud, Immich, Paperless, etc.
- Accessed externally via DMZ nginx only, never directly
- Can reach: Internet, IoT (70), Isolated (80) for Home Assistant polling/access
  - **Notes**: Unifi controller has access to Unifi devices on Management (10)

### VLAN 60 — Lab

Experimental and non-prod workloads. Isolated from all internal infrastructure.

- Lab Proxmox cluster, test VMs/containers, dev environments, anything experimental
- Can reach internet but nothing internal
- Trusted (30), Lab (60), and WireGuard (100) can reach Lab for access

### VLAN 70 — IoT

General smart home devices. Internet allowed but strictly no internal access.

- Smart bulbs, plugs, sensors, Zigbee devices, robot vacuum, etc.
- Cannot initiate connections to any internal VLAN
- Home Assistant (VLAN 50) polls these devices, not the other way around

### VLAN 80 — Isolated

Completely air-gapped from internet and internal network.

- IP cameras, other untrusted IoT devices (eg. smart TVs)
- Should have 0 internet access, prevent devices phoning home (eg. sketchy IoT devices)
- Only VLAN 50 (Services) can initiate connections inbound for stream access

### VLAN 90 — Guest

Devices with only internet access. For untrusted devices such as visitor devices, work devices, etc.

- Untrusted devices (eg. work laptop)
- Can reach: Internet only
- Cannot reach: Any internal VLANs

### VLAN 100 — WireGuard (Personal Remote Access)

Remote access VPN. Grants same access as Trusted when away from home.

- Phone/laptop when connecting remotely via WireGuard
- Inherits Trusted (30) access rules
- Note: the cloud VPS tunnel is separate infrastructure, not this VLAN

---

## General Rules

- Default deny all inter-VLAN traffic, explicitly allow only what is listed above
- Management (10) and Infrastructure (20) are never destinations from non-trusted VLANs (Trusted/WireGuard should always initiate)
- When unsure where a new service goes:
  - public facing = DMZ (40)
  - internal and used regularly = Services (50)
  - experimental = Lab (60)
  - application/management software = Services (50) (not Management 10)
- New IoT/smart home devices always go to IoT (70), Guest (90) if don't trust at all
- IP cameras should go to Isolated (80)
