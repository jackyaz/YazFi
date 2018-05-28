# YazFi - enhanced AsusWRT-Merlin Guest WiFi Networks
## v2.0.0
## About

Feature expansion of guest WiFi networks on AsusWRT-Merlin, including, but not limited to:

* Dedicated VPN WiFi networks
* Separate subnets for enhanced organisation of devices
* Allow guest networks to make use of pixelserv-tls (if installed)

## Supported Models

All Asus models that are supported by Merlin, and have the Guest Network feature should be supported by this script. That being said, I will maintain a list of confirmed supported models as per user reports.
* RT-AC56U
* RT-AC68U
* RT-AC86U
* RT-AC87U (2.4GHz guests only)
* RT-AC3200
* RT-AC5300

## Installation

Using your preferred SSH client/terminal, copy and paste the following command, then press Enter:

```
/usr/sbin/curl --retry 3 "https://raw.githubusercontent.com/jackyaz/YazFi/master/YazFi" -o "/jffs/scripts/YazFi" && chmod 0755 /jffs/scripts/YazFi && /jffs/scripts/YazFi install
```

Please then follow instructions shown in the SSH client/terminal session.

For ease of reference, a sample configuration file is available here: https://raw.githubusercontent.com/jackyaz/YazFi/master/YazFi.config.sample

### I haven't used scripts before on AsusWRT-Merlin, what do I do?

If this is the first time you are using scripts, don't panic! In your router's WebUI, go to the Administration area of the left menu, and then the System tab. Set Enable JFFS custom scripts and configs to Yes. Further reading about scripts is available here: https://github.com/RMerl/asuswrt-merlin/wiki/User-scripts

![WebUI enable scripts](https://puu.sh/A3wnG/00a43283ed.png)

## Updating

Using your preferred SSH client/terminal, copy and paste the following command, then press Enter:

```
/jffs/scripts/YazFi update
```

## Help

Please post about any issues and problems here: https://www.snbforums.com/threads/yazfi-enhanced-asuswrt-merlin-guest-wifi-networks.45924/

## Known Issues/Limitations

The script overrides the "Access Intranet" WebUI setting (for now, see "Upcoming Features" above). If you want guests to be able to access Intranet resources, do not include the network in YazFi.

![Access Intranet settings](https://puu.sh/zYWp9/a5541ed706.png)

### Donations

Love the script and want to support future development? Any and all donations gratefully received!
[PayPal donation](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=JFQLSCWJJUGZ6)
