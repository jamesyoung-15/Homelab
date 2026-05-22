# OpnSense: Configuring Unbound and dnsmasq for DNS and DHCP

Since ISC has been deprecated, I have moved to dnsmasq for my DHCP server (recommended by OpnSense docs). For DNS, I use Unbound DNS and dnsmasq DNS server together. Unbound has plenty of features, such as blocklists that removes the need for Adguard/Pi-Hole. The reason for adding dnsmasq DNS server is since I use dnsmasq for DHCP, it allows me to have local hostname DNS resolution on my network.

Most of this guide is optional, new out-of-the-box OpnSense should work fine.

## My Setup Steps

### Basic Dnsmasq DNS & DHCP Settings

First make sure dnsmasq DHCP and DNS is enabled and that a DNS request can be forwarded to dnsmasq DNS by changing the listen port.

Go to `Services -> Dnsmasq DNS & DHCP -> General`. Change the following:

- Make sure `Enable` checkbox is checked
- Set `DNS -> Listen port` to something like `53053` to enable dnsmasq DNS
- Make sure `DNS Query Forwarding -> Do not forward to system defined DNS servers` checkbox is checked to prevent using DNS servers from `System -> General`

### dnsmasq DHCP Ranges

DHCP range settings in `Services -> Dnsmasq DNS & DHCP -> DHCP Ranges`. For now I only use IPv4, may look into IPv6 later on. See the IP addressing guide for my ranges.

### Forward Local Domains from Unbound DNS to dnsmasq DNS

We need to forward Local Domains from Unbound DNS to dnsmasq DNS, do this in `Services -> Unbound DNS -> Query Forwarding`, add entries:

1. Forward local domain to dnsmasq DNS

    ```txt
    Domain: internal
    Server IP: 127.0.0.1
    Server Port: 53053
    Description: Forward local domain to dnsmasq DNS
    ```

2. Forward reverse DNS lookup to dnsmasq DNS

    ``` txt
    Domain: 15.10.in-addr.arpa
    Server IP: 127.0.0.1
    Server Port: 53053
    Description: Forward reverse DNS lookup to dnsmasq DNS
    ```

    For domain, the format is the (minus the client portion of the IP address) in reverse with `.in-addr.arpa` appended to it. So above example something like 10.15.0.0/16.

### Dnsmasq DNS & DHCP Hosts

In `Services -> Dnsmasq DNS & DHCP -> Hosts`, this is where static DHCP reservations can be defined.

### Unbound Block Lists

Todo, currently have no block lists enabled, relying on client's adblocks for now but will slowly start adding DNS blocklists.

## References

- [ISC DHCP Migration Guide](https://homenetworkguy.com/how-to/migrate-from-isc-dhcp-to-dnsmasq-or-kea-dhcp-in-opnsense/#assumptions)
- [OpnSense DHCP Docs](https://docs.opnsense.org/manual/dhcp.html#)
- [OpnSense dnsmasq DNS and DHCP Docs](https://docs.opnsense.org/manual/dnsmasq.html)
