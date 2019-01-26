# YazFi - enhanced AsusWRT-Merlin Guest WiFi Networks
## v2.3.8
## About

Feature expansion of guest WiFi networks on AsusWRT-Merlin, including, but not limited to:

*  Dedicated VPN WiFi networks
*  Separate subnets for enhanced organisation of devices
*  Restrict guests to only contact router for DHCP, DNS and NTP
*  Allow guest networks to make use of pixelserv-tls (if installed)
*  Allow guests to use a local DNS server
*  Extend DNS Filter to guest networks

## Supported Models

All models running Asuswrt-Merlin 384.5/john9527's fork 374.43_32D6j9527 and later, and have the Guest Network feature should be supported by this script. That being said, I will maintain a list of confirmed supported models as per user reports.
*  RT-AC56U
*  RT-AC66U
*  RT-AC68U
*  RT-AC86U
*  RT-AC87U (2.4GHz guests only)
*  RT-AC88U
*  RT-AC3200
*  RT-AC5300

## Installation

Using your preferred SSH client/terminal, copy and paste the following command, then press Enter:

```
/usr/sbin/curl --retry 3 "https://raw.githubusercontent.com/jackyaz/YazFi/master/YazFi" -o "/jffs/scripts/YazFi" && chmod 0755 /jffs/scripts/YazFi && /jffs/scripts/YazFi install
```

Please then follow instructions shown in the SSH client/terminal session.

For ease of reference, a sample configuration file is available here: [Sample Config file](https://raw.githubusercontent.com/jackyaz/YazFi/master/YazFi.config.sample)

### I haven't used scripts before on AsusWRT-Merlin, what do I do?

If this is the first time you are using scripts, don't panic! In your router's WebUI, go to the Administration area of the left menu, and then the System tab. Set Enable JFFS custom scripts and configs to Yes.
Further reading about scripts is available here: [AsusWRT-Merlin User-scripts](https://github.com/RMerl/asuswrt-merlin/wiki/User-scripts)

![WebUI enable scripts](https://puu.sh/A3wnG/00a43283ed.png)

## Updating

Using your preferred SSH client/terminal, copy and paste the following command, then press Enter:

```
/jffs/scripts/YazFi update
```

To force a re-install of the current version, use the following command instead (requires YazFi 2.3.7 or later):

```
/jffs/scripts/YazFi forceupdate
```

## Help

Please post about any issues and problems here: [YazFi on SNBForums](https://www.snbforums.com/threads/yazfi-enhanced-asuswrt-merlin-guest-wifi-networks.45924/)

## FAQs

What do each of the settings mean?

### wl01_ENABLED
Enable YazFi for this Guest Network

### wl01_IPADDR
IP address/subnet to use for Guest Network

### wl01_DHCPSTART
Start of DHCP pool (2-253)

### wl01_DHCPEND
End of DHCP pool (3-254)

### wl01_DNS1
IP address for primary DNS resolver

### wl01_DNS2
IP address for secondary DNS resolver

### wl01_FORCEDNS
Should Guest Network DNS requests be forced/redirected to DNS1? (true/false)
N.B. This setting is ignored if sending to VPN, and VPN Client's DNS configuration is Exclusive

### wl01_REDIRECTALLTOVPN
Should Guest Network traffic be sent via VPN? (true/false)

### wl01_VPNCLIENTNUMBER
The number of the VPN Client to send traffic through (1-5)

### wl01_LANACCESS
Not implemented

### wl01_CLIENTISOLATION
Not implemented

## Known Issues/Limitations

The script overrides the "Access Intranet" WebUI setting (except for DNS). If you want guests to be able to access other Intranet resources, do not include the guest network in YazFi.

![Access Intranet settings](https://puu.sh/zYWp9/a5541ed706.png)

### Donations

Love the script and want to support future development? Any and all donations gratefully received!
[PayPal donation](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=JFQLSCWJJUGZ6)
