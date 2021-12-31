# YazFi - enhanced AsusWRT-Merlin Guest WiFi Networks
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/a2cf9bdec17b4b6f9b6e113f802be694)](https://app.codacy.com/app/jackyaz/YazFi?utm_source=github.com&utm_medium=referral&utm_content=jackyaz/YazFi&utm_campaign=Badge_Grade_Dashboard)
![Shellcheck](https://github.com/jackyaz/YazFi/actions/workflows/shellcheck.yml/badge.svg)

## v4.4.0
### Updated on 2021-12-26
## About
Feature expansion of guest WiFi networks on AsusWRT-Merlin, including, but not limited to:

*   Dedicated VPN WiFi networks
*   Separate subnets for organisation of devices
*   Restrict guests to only contact router for ICMP, DHCP, DNS, NTP and NetBIOS
*   Allow guest networks to make use of pixelserv-tls (if installed)
*   Allow guests to use a local DNS server
*   Extend DNS Filter to guest networks

YazFi is free to use under the [GNU General Public License version 3](https://opensource.org/licenses/GPL-3.0) (GPL 3.0).

### Supporting development
Love the script and want to support future development? Any and all donations gratefully received!

[**PayPal donation**](https://paypal.me/jackyaz21)

## Supported firmware versions
### Core YazFi features
You must be running firmware no older than:
*   [Asuswrt-Merlin](https://asuswrt.lostrealm.ca/) 384.5
*   [john9527 fork](https://www.snbforums.com/threads/fork-asuswrt-merlin-374-43-lts-releases-v37ea.18914/) 374.43_32D6j9527

### WebUI page for YazFi
You must be running firmware Merlin 384.15/384.13_4 or Fork 43E5 (or later) [Asuswrt-Merlin](https://asuswrt.lostrealm.ca/)

## Installation
Using your preferred SSH client/terminal, copy and paste the following command, then press Enter:

```sh
/usr/sbin/curl -fsL --retry 3 "https://jackyaz.io/YazFi/master/install/YazFi.sh" -o /jffs/scripts/YazFi && chmod 0755 /jffs/scripts/YazFi && /jffs/scripts/YazFi install
```

Please then follow instructions shown on-screen. An explanation of the settings is provided in the [FAQs](#explanation-of-yazfi-settings)

## Usage
### WebUI
YazFi can be configured via the WebUI, in the Guest Network section.

### Command Line
To launch the YazFi menu after installation, use:
```sh
YazFi
```

If you do not have Entware installed, you will need to use the full path:
```sh
/jffs/scripts/YazFi
```

## Screenshots

![WebUI](https://puu.sh/HgmLl/178327b437.png)

![CLI](https://puu.sh/HgmF1/5a8ae7ed82.png)

## Help
Please post about any issues and problems here: [Asuswrt-Merlin AddOns on SNBForums](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=13)

## FAQs
### Explanation of YazFi settings
#### wl01_ENABLED
Enable YazFi for this Guest Network (true/false)

#### wl01_IPADDR
IP address/subnet to use for Guest Network

#### wl01_DHCPSTART
Start of DHCP pool (2-253)

#### wl01_DHCPEND
End of DHCP pool (3-254)

#### wl01_DNS1
IP address for primary DNS resolver

#### wl01_DNS2
IP address for secondary DNS resolver

#### wl01_FORCEDNS
Should Guest Network DNS requests be forced/redirected to DNS1? (true/false)
N.B. This setting is ignored if sending to VPN, and VPN Client's DNS configuration is Exclusive

#### wl01_REDIRECTALLTOVPN
Should Guest Network traffic be sent via VPN? (true/false)

#### wl01_VPNCLIENTNUMBER
The number of the VPN Client to send traffic through (1-5)

#### wl01_TWOWAYTOGUEST
Should LAN/Guest Network traffic have unrestricted access to each other? (true/false)
Cannot be enabled if _ONEWAYTOGUEST is enabled

#### wl01_ONEWAYTOGUEST
Should LAN be able to initiate connections to Guest Network clients (but not the opposite)? (true/false)
Cannot be enabled if _TWOWAYTOGUEST is enabled

#### wl01_CLIENTISOLATION
Should Guest Network radio prevent clients from talking to each other? (true/false)

### Custom firewall rules
Yes. YazFi supports calling custom scripts after setting up the guest network. To use a user script, create your script file the appropriate directory with a .sh extension. e.g.
```sh
/jffs/addons/YazFi.d/userscripts.d/myscript.sh
```
Remember to make it executable with
```sh
chmod +x /jffs/addons/YazFi.d/userscripts.d/myscript.sh
```
An example script to allow a guest on 2.4GHz guest 1 to talk to a specific IP address on the LAN:
```sh
#!/bin/sh
iptables -I YazFiFORWARD -i wl0.1 -o br0 -d 192.168.1.50 -j ACCEPT
```
The above will work if "One way" access to the guest enabled. With no access enabled, the script would be:
```sh
#!/bin/sh
iptables -I YazFiFORWARD -i wl0.1 -o br0 -d 192.168.1.50 -j ACCEPT
iptables -I YazFiFORWARD -i br0 -o wl0.1 -s 192.168.1.50 -j ACCEPT
```

### Scarf Gateway
Installs and updates for this addon are redirected via the [Scarf Gateway](https://about.scarf.sh/scarf-gateway) by [Scarf](https://about.scarf.sh/about). This allows me to gather data on the number of new installations of my addons, how often users check for updates and more. This is purely for my use to actually see some usage data from my addons so that I can see the value provided by my continued work. It does not mean I am going to start charging to use my addons. My addons have been, are, and will always be completely free to use.

Please refer to Scarf's [Privacy Policy](https://about.scarf.sh/privacy) for more information about the data that is collected and how it is processed.
