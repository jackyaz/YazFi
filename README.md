# YazFi - enhanced AsusWRT-Merlin Guest WiFi Networks
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/a2cf9bdec17b4b6f9b6e113f802be694)](https://app.codacy.com/app/jackyaz/YazFi?utm_source=github.com&utm_medium=referral&utm_content=jackyaz/YazFi&utm_campaign=Badge_Grade_Dashboard)
[![Build Status](https://travis-ci.com/jackyaz/YazFi.svg?branch=master)](https://travis-ci.com/jackyaz/YazFi)

## v4.1.5
### Updated on 2020-12-22
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

[**Buy me a coffee**](https://www.buymeacoffee.com/jackyaz)

![Menu UI](https://puu.sh/CNwF7/a095903835.png)

![Web UI](https://puu.sh/FbJeV/0f32c1da9d.png)

## Supported Models
All modes supported by [Asuswrt-Merlin](https://asuswrt.lostrealm.ca/about). Models confirmed to work are below:
*   RT-AC56U
*   RT-AC66U
*   RT-AC68U
*   RT-AC86U
*   RT-AC87U (2.4GHz guests only)
*   RT-AC88U
*   RT-AC3100
*   RT-AC3200
*   RT-AC5300
*   RT-AX88U (clientisolation is not supported and is forced to false)

### Supported firmware versions
#### Core YazFi features
You must be running firmware no older than:
*   [Asuswrt-Merlin](https://asuswrt.lostrealm.ca/) 384.5
*   [john9527 fork](https://www.snbforums.com/threads/fork-asuswrt-merlin-374-43-lts-releases-v37ea.18914/) 374.43_32D6j9527

#### WebUI page for YazFi
You must be running firmware no older than:
*   [Asuswrt-Merlin](https://asuswrt.lostrealm.ca/) 384.15

## Installation
Using your preferred SSH client/terminal, copy and paste the following command, then press Enter:

```sh
/usr/sbin/curl --retry 3 "https://raw.githubusercontent.com/jackyaz/YazFi/master/YazFi.sh" -o "/jffs/scripts/YazFi" && chmod 0755 /jffs/scripts/YazFi && /jffs/scripts/YazFi install
```

Please then follow instructions shown on-screen. An explanation of the settings is provided in the [FAQs](#explanation-of-yazfi-settings)

## Usage
To launch the YazFi menu after installation, use:
```sh
YazFi
```

If you do not have Entware installed, you will need to use the full path:
```sh
/jffs/scripts/YazFi
```

## Updating
Launch YazFi and select option u

## Help
Please post about any issues and problems here: [YazFi on SNBForums](https://www.snbforums.com/threads/yazfi-enhanced-asuswrt-merlin-guest-wifi-networks.45924/)

## FAQs
### I haven't used scripts before on AsusWRT-Merlin
If this is the first time you are using scripts, don't panic! In your router's WebUI, go to the Administration area of the left menu, and then the System tab. Set Enable JFFS custom scripts and configs to Yes.

Further reading about scripts is available here: [AsusWRT-Merlin User-scripts](https://github.com/RMerl/asuswrt-merlin/wiki/User-scripts)

![WebUI enable scripts](https://puu.sh/A3wnG/00a43283ed.png)

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
