#!/bin/sh

#####################################################
######                                         ######
######     __     __          ______  _        ######
######     \ \   / /         |  ____|(_)       ######
######      \ \_/ /__ _  ____| |__    _        ######
######       \   // _  ||_  /|  __|  | |       ######
######        | || (_| | / / | |     | |       ######
######        |_| \__,_|/___||_|     |_|       ######
######                                         ######
######    https://github.com/jackyaz/YazFi/    ######
######                                         ######
#####################################################
######   Credit to @RMerlin for the original   ######
######    guest network DHCP script and for    ######
######        AsusWRT-Merlin firmware          ######
#####################################################

######            Shellcheck directives        ######
# shellcheck disable=SC2034
# shellcheck disable=SC1090
#####################################################

### Start of script variables ###
readonly YAZFI_NAME="YazFi"
readonly YAZFI_CONF_OLD="/jffs/configs/$YAZFI_NAME.config"
readonly YAZFI_CONF="/jffs/configs/$YAZFI_NAME/$YAZFI_NAME.config"
readonly YAZFI_VERSION="v3.1.0"
readonly YAZFI_BRANCH="master"
readonly YAZFI_REPO="https://raw.githubusercontent.com/jackyaz/YazFi/""$YAZFI_BRANCH""/YazFi"
### End of script variables ###

### Start of output format variables ###
readonly CRIT="\\e[41m"
readonly ERR="\\e[31m"
readonly WARN="\\e[33m"
readonly PASS="\\e[32m"
### End of output format variables ###

### Start of router environment variables ###
readonly LAN="$(nvram get lan_ipaddr)"
readonly IFACELIST="wl0.1 wl0.2 wl0.3 wl1.1 wl1.2 wl1.3 wl2.1 wl2.2 wl2.3"
### End of router environment variables ###

### Start of path variables ###
readonly DNSCONF="/jffs/configs/dnsmasq.conf.add"
readonly TMPCONF="/jffs/configs/tmpdnsmasq.conf.add"
readonly YAZFI_BLOCKDHCPFILE="/jffs/configs/$YAZFI_NAME/$YAZFI_NAME.blockdhcp"
### End of path variables ###

### Start of firewall variables ###
readonly INPT="$YAZFI_NAME""INPUT"
readonly FWRD="$YAZFI_NAME""FORWARD"
readonly LGRJT="$YAZFI_NAME""REJECT"
readonly DNSFLTR="$YAZFI_NAME""DNSFILTER"
readonly CHAINS="$INPT $FWRD $LGRJT"
readonly NATCHAINS="$DNSFLTR"
BLOCKDHCP=""
if [ -f "$YAZFI_BLOCKDHCPFILE" ]; then
	BLOCKDHCP="true"
else
	BLOCKDHCP="false"
fi
### End of firewall variables ###

### Start of VPN clientlist variables ###
VPN_IP_LIST_ORIG_1=""
VPN_IP_LIST_ORIG_2=""
VPN_IP_LIST_ORIG_3=""
VPN_IP_LIST_ORIG_4=""
VPN_IP_LIST_ORIG_5=""
VPN_IP_LIST_NEW_1=""
VPN_IP_LIST_NEW_2=""
VPN_IP_LIST_NEW_3=""
VPN_IP_LIST_NEW_4=""
VPN_IP_LIST_NEW_5=""
### End of VPN clientlist variables ###

# $1 = print to syslog, $2 = message to print, $3 = log level
Print_Output(){
	if [ "$1" = "true" ]; then
		logger -t "$YAZFI_NAME" "$2"
		printf "\\e[1m$3%s: $2\\e[0m\\n\\n" "$YAZFI_NAME"
	else
		printf "\\e[1m$3%s: $2\\e[0m\\n\\n" "$YAZFI_NAME"
	fi
}

Escape_Sed(){
	sed -e 's/</\\</g;s/>/\\>/g;s/ /\\ /g'
}

Get_Iface_Var(){
	echo "$1" | sed -e 's/\.//g'
}

Get_Guest_Name(){
	VPN_NVRAM=""
	
	if echo "$1" | grep -q "wl0"; then
		VPN_NVRAM="2.4GHz Guest $(echo "$1" | cut -f2 -d".")"
	elif echo "$1" | grep -q "wl1"; then
		VPN_NVRAM="5GHz1 Guest $(echo "$1" | cut -f2 -d".")"
	else
		VPN_NVRAM="5GHz2 Guest $(echo "$1" | cut -f2 -d".")"
	fi
	
	echo "$VPN_NVRAM"
}

Iface_Manage(){
	case $1 in
		create)
			ifconfig "$2" "$(eval echo '$'"$(Get_Iface_Var "$2")"_IPADDR | cut -f1-3 -d".").$(nvram get lan_ipaddr | cut -f4 -d".")" netmask 255.255.255.0
		;;
		delete)
			ifconfig "$2" 0.0.0.0
		;;
		deleteall)
			for IFACE in $IFACELIST; do
				Iface_Manage delete "$IFACE"
			done
		;;
	esac
}

Iface_BounceClients(){
	Print_Output "true" "Forcing YazFi Guest WiFi clients to reauthenticate" "$PASS"
	
	for IFACE in $IFACELIST; do
		wl -i "$IFACE" deauthenticate >/dev/null 2>&1
	done
}

Auto_ServiceEvent(){
	case $1 in
		create)
			if [ -f /jffs/scripts/service-event ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$YAZFI_NAME"' Guest Networks' /jffs/scripts/service-event)
				# shellcheck disable=SC2016
				STARTUPLINECOUNTEX=$(grep -cx "/jffs/scripts/$YAZFI_NAME bounceclients"' "$1" "$2" &'' # '"$YAZFI_NAME"' Guest Networks' /jffs/scripts/service-event)
				
				if [ "$STARTUPLINECOUNT" -gt 1 ] || { [ "$STARTUPLINECOUNTEX" -eq 0 ] && [ "$STARTUPLINECOUNT" -gt 0 ]; }; then
					sed -i -e '/# '"$YAZFI_NAME"' Guest Networks/d' /jffs/scripts/service-event
				fi
				
				if [ "$STARTUPLINECOUNTEX" -eq 0 ]; then
					# shellcheck disable=SC2016
					echo "/jffs/scripts/$YAZFI_NAME bounceclients"' "$1" "$2" &'' # '"$YAZFI_NAME"' Guest Networks' >> /jffs/scripts/service-event
				fi
			else
				echo "#!/bin/sh" > /jffs/scripts/service-event
				echo "" >> /jffs/scripts/service-event
				# shellcheck disable=SC2016
				echo "/jffs/scripts/$YAZFI_NAME bounceclients"' "$1" "$2" &'' # '"$YAZFI_NAME"' Guest Networks' >> /jffs/scripts/service-event
				chmod 0755 /jffs/scripts/service-event
			fi
		;;
		delete)
			if [ -f /jffs/scripts/service-event ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$YAZFI_NAME"' Guest Networks' /jffs/scripts/service-event)
				
				if [ "$STARTUPLINECOUNT" -gt 0 ]; then
					sed -i -e '/# '"$YAZFI_NAME"' Guest Networks/d' /jffs/scripts/service-event
				fi
			fi
		;;
	esac
}

Auto_Block_DHCP(){
	case $1 in
		delete)
			if [ -f /jffs/scripts/dnsmasq.postconf ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$YAZFI_NAME"' Guest Networks' /jffs/scripts/dnsmasq.postconf)
				
				if [ "$STARTUPLINECOUNT" -gt 0 ]; then
					sed -i -e '/# '"$YAZFI_NAME"' Guest Networks/d' /jffs/scripts/dnsmasq.postconf
				fi
			fi
		;;
	esac
}

Auto_Startup(){
	case $1 in
		create)
			if [ -f /jffs/scripts/firewall-start ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$YAZFI_NAME"' Guest Networks' /jffs/scripts/firewall-start)
				STARTUPLINECOUNTEX=$(grep -cx "/jffs/scripts/$YAZFI_NAME runnow"' # '"$YAZFI_NAME"' Guest Networks' /jffs/scripts/firewall-start)
				
				if [ "$STARTUPLINECOUNT" -gt 1 ] || { [ "$STARTUPLINECOUNTEX" -eq 0 ] && [ "$STARTUPLINECOUNT" -gt 0 ]; }; then
					sed -i -e '/# '"$YAZFI_NAME"' Guest Networks/d' /jffs/scripts/firewall-start
				fi
				
				if [ "$STARTUPLINECOUNTEX" -eq 0 ]; then
					echo "/jffs/scripts/$YAZFI_NAME runnow"' # '"$YAZFI_NAME"' Guest Networks' >> /jffs/scripts/firewall-start
				fi
			else
				echo "#!/bin/sh" > /jffs/scripts/firewall-start
				echo "" >> /jffs/scripts/firewall-start
				echo "/jffs/scripts/$YAZFI_NAME runnow"' # '"$YAZFI_NAME"' Guest Networks' >> /jffs/scripts/firewall-start
				chmod 0755 /jffs/scripts/firewall-start
			fi
		;;
		delete)
			if [ -f /jffs/scripts/firewall-start ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$YAZFI_NAME"' Guest Networks' /jffs/scripts/firewall-start)
				
				if [ "$STARTUPLINECOUNT" -gt 0 ]; then
					sed -i -e '/# '"$YAZFI_NAME"' Guest Networks/d' /jffs/scripts/firewall-start
				fi
			fi
		;;
	esac
}

### Code for this function courtesy of https://github.com/decoderman- credit to @thelonelycoder ###
Firmware_Version_Check(){
	echo "$1" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'
}
############################################################################

### Code for these functions inspired by https://github.com/Adamm00 - credit to @Adamm ###
Check_Lock(){
	if [ -f "/tmp/$YAZFI_NAME.lock" ]; then
		ageoflock=$(($(date +%s) - $(date +%s -r /tmp/$YAZFI_NAME.lock)))
		if [ "$ageoflock" -gt 120 ]; then
			Print_Output "true" "Stale lock file found (>120 seconds old) - purging lock" "$ERR"
			kill "$(sed -n '1p' /tmp/$YAZFI_NAME.lock)" >/dev/null 2>&1
			Clear_Lock
			echo "$$" > "/tmp/$YAZFI_NAME.lock"
			return 0
		else
			Print_Output "true" "Lock file found (age: $ageoflock seconds) - stopping to prevent duplicate runs" "$ERR"
			exit 1
		fi
	else
		echo "$$" > "/tmp/$YAZFI_NAME.lock"
		return 0
	fi
}

Clear_Lock(){
	rm -f "/tmp/$YAZFI_NAME.lock" 2>/dev/null
	return 0
}

Update_Version(){
	if [ -z "$1" ]; then
		localver=$(grep "YAZFI_VERSION=" /jffs/scripts/$YAZFI_NAME | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
		/usr/sbin/curl -fsL --retry 3 "$YAZFI_REPO.sh" | grep -qF "jackyaz" || { Print_Output "true" "404 error detected - stopping update" "$ERR"; Clear_Lock; exit 1; }
		serverver=$(/usr/sbin/curl -fsL --retry 3 "$YAZFI_REPO" | grep "YAZFI_VERSION=" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
		if [ "$localver" != "$serverver" ]; then
			Print_Output "true" "New version of $YAZFI_NAME available - updating to $serverver" "$PASS"
			/usr/sbin/curl -fsL --retry 3 "$YAZFI_REPO.sh" -o "/jffs/scripts/$YAZFI_NAME" && Print_Output "true" "YazFi successfully updated - restarting firewall to apply update"
			chmod 0755 "/jffs/scripts/$YAZFI_NAME"
			Clear_Lock
			service restart_firewall >/dev/null 2>&1
			exit 0
		else
			Print_Output "true" "No new version - latest is $localver" "$WARN"
			Clear_Lock
		fi
	fi
	
	case "$1" in
		force)
			serverver=$(/usr/sbin/curl -fsL --retry 3 "$YAZFI_REPO.sh" | grep "YAZFI_VERSION=" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
			Print_Output "true" "Downloading latest version ($serverver) of $YAZFI_NAME" "$PASS"
			/usr/sbin/curl -fsL --retry 3 "$YAZFI_REPO.sh" -o "/jffs/scripts/$YAZFI_NAME" && Print_Output "true" "YazFi successfully updated - restarting firewall to apply update"
			chmod 0755 "/jffs/scripts/$YAZFI_NAME"
			Clear_Lock
			service restart_firewall >/dev/null 2>&1
			exit 0
		;;
	esac
}
############################################################################

IP_Local(){
	if echo "$1" | grep -qE '(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)'; then
		return 0
	elif [ "$1" = "127.0.0.1" ]; then
		return 0
	else
		return 1
	fi
}

IP_Router(){
	if [ "$1" = "$(nvram get lan_ipaddr)" ] || [ "$1" = "127.0.0.1" ]; then
		return 0
	elif [ "$1" = "$(eval echo '$'"$(Get_Iface_Var "$2")""_IPADDR" | cut -f1-3 -d".").""$(nvram get lan_ipaddr | cut -f4 -d".")" ]; then
		return 0
	else
		return 1
	fi
}

Validate_IFACE(){
	if [ "$(nvram get "$IFACE""_bss_enabled")" -eq 0 ]; then
		Print_Output "false" "$1 - Interface not enabled/configured in Web GUI (Guest Network menu)" "$ERR"
		return 1
	else
		return 0
	fi
}

Validate_IP(){
	if expr "$2" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
		for i in 1 2 3 4; do
			if [ "$(echo "$2" | cut -d. -f$i)" -gt 255 ]; then
				Print_Output "false" "$1 - Octet $i ($(echo "$2" | cut -d. -f$i)) - is invalid, must be less than 255" "$ERR"
				return 1
			fi
		done
		
		if [ "$3" != "DNS" ]; then
			if IP_Local "$2"; then
				return 0
			else
				Print_Output "false" "$1 - $2 - Non-local IP address block used" "$ERR"
				return 1
			fi
		else
			return 0
		fi
	else
		Print_Output "false" "$1 - $2 - is not a valid IPv4 address, valid format is 1.2.3.4" "$ERR"
		return 1
	fi
}

Validate_Number(){
	if [ "$2" -eq "$2" ] 2>/dev/null; then
		return 0
	else
		formatted="$(echo "$1" | sed -e 's/|/ /g')"
		if [ -z "$3" ]; then
			Print_Output "false" "$formatted - $2 is not a number" "$ERR"
		fi
		return 1
	fi
}

Validate_DHCP(){
	if ! Validate_Number "$1" "$2"; then
		return 1
	elif ! Validate_Number "$1" "$3"; then
		return 1
	fi
	
	if [ "$2" -gt "$3" ] || { [ "$2" -lt 2 ] || [ "$2" -gt 254 ]; } || { [ "$3" -lt 2 ] || [ "$3" -gt 254 ]; }; then
		Print_Output "false" "$1 - $2 to $3 - both numbers must be between 2 and 254, $2 must be less than $3" "$ERR"
		return 1
	else
		return 0
	fi
}

Validate_VPNClientNo(){
	if ! Validate_Number "$1" "$2"; then
		return 1
	fi
	
	if [ "$2" -lt 1 ] || [ "$2" -gt 5 ]; then
		Print_Output "false" "$1 - $2 - must be between 1 and 5" "$ERR"
		return 1
	else
		return 0
	fi
}

Validate_TrueFalse(){
	case "$2" in
		true|TRUE|false|FALSE)
			return 0
		;;
		*)
			Print_Output "false" "$1 - $2 - must be either true or false" "$ERR"
			return 1
		;;
	esac
}

Conf_Validate(){
	
	CONF_VALIDATED="true"
	NETWORKS_ENABLED="false"
	
	for IFACE in $IFACELIST; do
		IFACETMP="$(Get_Iface_Var "$IFACE")"
		IPADDRTMP=""
		ENABLEDTMP=""
		REDIRECTTMP=""
		IFACE_PASS="true"
		
		# Validate _ENABLED
		if [ -z "$(eval echo '$'"$IFACETMP""_ENABLED")" ]; then
			ENABLEDTMP="false"
			sed -i -e "s/""$IFACETMP""_ENABLED=/""$IFACETMP""_ENABLED=false/" "$YAZFI_CONF"
			Print_Output "false" "$IFACETMP""_ENABLED is blank, setting to false" "$WARN"
		elif ! Validate_TrueFalse "$IFACETMP""_ENABLED" "$(eval echo '$'"$IFACETMP""_ENABLED")"; then
			ENABLEDTMP="false"
			IFACE_PASS="false"
		else
			ENABLEDTMP="$(eval echo '$'"$IFACETMP""_ENABLED")"
		fi
		
		if [ "$ENABLEDTMP" = "true" ]; then
			NETWORKS_ENABLED="true"
			# Validate interface is enabled in GUI
			if ! Validate_IFACE "$IFACE"; then
				IFACE_PASS="false"
			fi
			
			# Only validate interfaces enabled in config file
			if [ "$(eval echo '$'"$IFACETMP""_ENABLED")" = "true" ]; then
				# Validate _IPADDR
				if [ -z "$(eval echo '$'"$IFACETMP""_IPADDR")" ]; then
					IPADDRTMP="$(echo "$LAN" | cut -f1-2 -d".").$(($(echo "$LAN" | cut -f3 -d".")+1))"
					
					COUNTER=1
					until [ "$(grep -o "$IPADDRTMP".0 $YAZFI_CONF | wc -l)" -eq 0 ] && [ "$(ifconfig -a | grep -o "$IPADDRTMP"."$(nvram get lan_ipaddr | cut -f4 -d".")" | wc -l )" -eq 0 ]; do
						IPADDRTMP="$(echo "$LAN" | cut -f1-2 -d".").$(($(echo "$LAN" | cut -f3 -d".")+COUNTER))"
						COUNTER=$((COUNTER + 1))
					done
					
					sed -i -e "s/""$IFACETMP""_IPADDR=/""$IFACETMP""_IPADDR=""$IPADDRTMP"".0/" "$YAZFI_CONF"
					Print_Output "false" "$IFACETMP""_IPADDR is blank, setting to next available subnet above primary LAN subnet" "$WARN"
				elif ! Validate_IP "$IFACETMP""_IPADDR" "$(eval echo '$'"$IFACETMP""_IPADDR")"; then
					IFACE_PASS="false"
				else
					
					IPADDRTMP="$(eval echo '$'"$IFACETMP""_IPADDR" | cut -f1-3 -d".")"
					
					# Set last octet to 0
					if [ "$(eval echo '$'"$IFACETMP""_IPADDR" | cut -f4 -d".")" -ne 0 ]; then
						sed -i -e "s/""$IFACETMP""_IPADDR=$(eval echo '$'"$IFACETMP""_IPADDR")/""$IFACETMP""_IPADDR=""$IPADDRTMP"".0/" "$YAZFI_CONF"
						Print_Output "false" "$IFACETMP""_IPADDR setting last octet to 0" "$WARN"
					fi
					
					if [ "$(grep -o "$IPADDRTMP".0 $YAZFI_CONF | wc -l )" -gt 1 ] || [ "$(ifconfig -a | grep -o "$IPADDRTMP"."$(nvram get lan_ipaddr | cut -f4 -d".")" | wc -l )" -gt 1 ]; then
						Print_Output "false" "$IFACETMP""_IPADDR ($(eval echo '$'"$IFACETMP""_IPADDR")) has been used for another interface already" "$ERR"
						IFACE_PASS="false"
					fi
				fi
				
				#Validate _DHCPSTART and _DHCPEND
				if [ -z "$(eval echo '$'"$IFACETMP""_DHCPSTART")" ]; then
					sed -i -e "s/""$IFACETMP""_DHCPSTART=/""$IFACETMP""_DHCPSTART=2/" "$YAZFI_CONF"
					Print_Output "false" "$IFACETMP""_DHCPSTART is blank, setting to 2" "$WARN"
				fi
				
				if [ -z "$(eval echo '$'"$IFACETMP""_DHCPEND")" ]; then
					sed -i -e "s/""$IFACETMP""_DHCPEND=/""$IFACETMP""_DHCPEND=254/" "$YAZFI_CONF"
					Print_Output "false" "$IFACETMP""_DHCPEND is blank, setting to 254" "$WARN"
				fi
				
				if [ ! -z "$(eval echo '$'"$IFACETMP""_DHCPSTART")" ] && [ ! -z "$(eval echo '$'"$IFACETMP""_DHCPEND")" ]; then
					if ! Validate_DHCP "$IFACETMP""_DHCPSTART|and|""$IFACETMP""_DHCPEND" "$(eval echo '$'"$IFACETMP""_DHCPSTART")" "$(eval echo '$'"$IFACETMP""_DHCPEND")"; then
					IFACE_PASS="false"
					fi
				fi
				
				# Validate _DNS1
				if [ -z "$(eval echo '$'"$IFACETMP""_DNS1")" ]; then
					if [ ! -z "$(eval echo '$'"$IFACETMP""_IPADDR")" ]; then
						sed -i -e "s/""$IFACETMP""_DNS1=/""$IFACETMP""_DNS1=$(eval echo '$'"$IFACETMP""_IPADDR" | cut -f1-3 -d".").$(nvram get lan_ipaddr | cut -f4 -d".")/" "$YAZFI_CONF"
						Print_Output "false" "$IFACETMP""_DNS1 is blank, setting to $(eval echo '$'"$IFACETMP""_IPADDR" | cut -f1-3 -d".").$(nvram get lan_ipaddr | cut -f4 -d".")" "$WARN"
					else
						sed -i -e "s/""$IFACETMP""_DNS1=/""$IFACETMP""_DNS1=$IPADDRTMP.$(nvram get lan_ipaddr | cut -f4 -d".")/" "$YAZFI_CONF"
						Print_Output "false" "$IFACETMP""_DNS1 is blank, setting to $IPADDRTMP.$(nvram get lan_ipaddr | cut -f4 -d".")" "$WARN"
					fi
				elif ! Validate_IP "$IFACETMP""_DNS1" "$(eval echo '$'"$IFACETMP""_DNS1")" "DNS"; then
					IFACE_PASS="false"
				fi
				
				# Validate _DNS2
				if [ -z "$(eval echo '$'"$IFACETMP""_DNS2")" ]; then
					if [ ! -z "$(eval echo '$'"$IFACETMP""_IPADDR")" ]; then
						sed -i -e "s/""$IFACETMP""_DNS2=/""$IFACETMP""_DNS2=$(eval echo '$'"$IFACETMP""_IPADDR" | cut -f1-3 -d".").$(nvram get lan_ipaddr | cut -f4 -d".")/" "$YAZFI_CONF"
						Print_Output "false" "$IFACETMP""_DNS2 is blank, setting to $(eval echo '$'"$IFACETMP""_IPADDR" | cut -f1-3 -d".").$(nvram get lan_ipaddr | cut -f4 -d".")" "$WARN"
					else
						sed -i -e "s/""$IFACETMP""_DNS2=/""$IFACETMP""_DNS2=$IPADDRTMP.$(nvram get lan_ipaddr | cut -f4 -d".")/" "$YAZFI_CONF"
						Print_Output "false" "$IFACETMP""_DNS2 is blank, setting to $IPADDRTMP.$(nvram get lan_ipaddr | cut -f4 -d".")" "$WARN"
					fi
				elif ! Validate_IP "$IFACETMP""_DNS2" "$(eval echo '$'"$IFACETMP""_DNS2")" "DNS"; then
					IFACE_PASS="false"
				fi
				
				# Validate _FORCEDNS
				if [ -z "$(eval echo '$'"$IFACETMP""_FORCEDNS")" ]; then
					sed -i -e "s/""$IFACETMP""_FORCEDNS=/""$IFACETMP""_FORCEDNS=false/" "$YAZFI_CONF"
					Print_Output "false" "$IFACETMP""_FORCEDNS is blank, setting to false" "$WARN"
				elif ! Validate_TrueFalse "$IFACETMP""_FORCEDNS" "$(eval echo '$'"$IFACETMP""_FORCEDNS")"; then
					IFACE_PASS="false"
				fi
				
				# Validate _REDIRECTALLTOVPN
				if [ -z "$(eval echo '$'"$IFACETMP""_REDIRECTALLTOVPN")" ]; then
					REDIRECTTMP="false"
					sed -i -e "s/""$IFACETMP""_REDIRECTALLTOVPN=/""$IFACETMP""_REDIRECTALLTOVPN=false/" "$YAZFI_CONF"
					Print_Output "false" "$IFACETMP""_REDIRECTALLTOVPN is blank, setting to false" "$WARN"
				elif ! Validate_TrueFalse "$IFACETMP""_REDIRECTALLTOVPN" "$(eval echo '$'"$IFACETMP""_REDIRECTALLTOVPN")"; then
					REDIRECTTMP="false"
					IFACE_PASS="false"
				else
					REDIRECTTMP="$(eval echo '$'"$IFACETMP""_REDIRECTALLTOVPN")"
				fi
				
				# Validate _VPNCLIENTNUMBER if _REDIRECTALLTOVPN is enabled
				if [ "$REDIRECTTMP" = "true" ]; then
					if [ -z "$(eval echo '$'"$IFACETMP""_VPNCLIENTNUMBER")" ]; then
						Print_Output "false" "$IFACETMP""_VPNCLIENTNUMBER is blank" "$ERR"
						IFACE_PASS="false"
					elif ! Validate_VPNClientNo "$IFACETMP""_VPNCLIENTNUMBER" "$(eval echo '$'"$IFACETMP""_VPNCLIENTNUMBER")"; then
						IFACE_PASS="false"
					else
						#Validate VPN client is configured for policy routing
						if [ "$(nvram get vpn_client"$(eval echo '$'"$IFACETMP""_VPNCLIENTNUMBER")"_rgw)" -lt 2 ]; then
							Print_Output "false" "VPN Client $(eval echo '$'"$IFACETMP""_VPNCLIENTNUMBER") is not configured for Policy Routing" "$ERR"
							IFACE_PASS="false"
						fi
					fi
				fi
				
				# Validate _LANACCESS
				if [ -z "$(eval echo '$'"$IFACETMP""_LANACCESS")" ]; then
					sed -i -e "s/""$IFACETMP""_LANACCESS=/""$IFACETMP""_LANACCESS=false/" "$YAZFI_CONF"
					Print_Output "false" "$IFACETMP""_LANACCESS is blank, setting to false" "$WARN"
				elif ! Validate_TrueFalse "$IFACETMP""_LANACCESS" "$(eval echo '$'"$IFACETMP""_LANACCESS")"; then
					IFACE_PASS="false"
				fi
				
				# Validate _CLIENTISOLATION
				if [ -z "$(eval echo '$'"$IFACETMP""_CLIENTISOLATION")" ]; then
					sed -i -e "s/""$IFACETMP""_CLIENTISOLATION=/""$IFACETMP""_CLIENTISOLATION=true/" "$YAZFI_CONF"
					Print_Output "false" "$IFACETMP""_CLIENTISOLATION is blank, setting to true" "$WARN"
				elif ! Validate_TrueFalse "$IFACETMP""_CLIENTISOLATION" "$(eval echo '$'"$IFACETMP""_CLIENTISOLATION")"; then
					IFACE_PASS="false"
				fi
				
				# Print success message
				if [ "$IFACE_PASS" = "true" ]; then
					Print_Output "false" "$IFACE passed validation" "$PASS"
				fi
			fi
		fi
		
		# Print failure message
		if [ "$IFACE_PASS" = "false" ]; then
			Print_Output "false" "$IFACE failed validation" "$CRIT"
			CONF_VALIDATED="false"
		fi
	done
	
	if [ "$NETWORKS_ENABLED" = "true" ]; then
		if [ "$CONF_VALIDATED" = "true" ]; then
			return 0
		else
			Clear_Lock
			return 1
		fi
	else
		Print_Output "true" "No YazFi guests are enabled in the configuration file!" "$CRIT"
		return 1
	fi
}

Conf_Download(){
	mkdir -p "/jffs/configs/$YAZFI_NAME/"
	/usr/sbin/curl -s --retry 3 "$YAZFI_REPO.config.example" -o "$1"
	chmod 0644 "$1"
	dos2unix "$1"
	echo ""
	echo ""
	Print_Output "false" "Please edit $YAZFI_CONF with your desired settings using option 2 from the YazFi menu."
	sleep 1
	echo ""
	Print_Output "false" "When finished, run YazFi using option 1 from the YazFi menu."
	Clear_Lock
}

Conf_Exists(){
	if [ -f "$YAZFI_CONF" ]; then
		dos2unix "$YAZFI_CONF"
		chmod 0644 "$YAZFI_CONF"
		sed -i -e 's/"//g' "$YAZFI_CONF"
		. "$YAZFI_CONF"
		return 0
	elif [ -f "$YAZFI_CONF_OLD" ]; then
		Print_Output "true" "$YAZFI_NAME.conf found in old directory, moving to new $YAZFI_NAME directory" "$WARN"
		mkdir -p "/jffs/configs/$YAZFI_NAME"
		cp "$YAZFI_CONF_OLD" "$YAZFI_CONF_OLD.bak"
		mv "$YAZFI_CONF_OLD" "$YAZFI_CONF"
		Conf_Exists
	else
		return 1
	fi
}

Firewall_Chains(){
	FWRDSTART="$(iptables -nvL FORWARD --line | grep -E "ACCEPT     all.*state RELATED,ESTABLISHED" | tail -1 | awk '{print $1}')"
	
	case $1 in
		create)
			for CHAIN in $CHAINS; do
				if ! iptables -n -L "$CHAIN" >/dev/null 2>&1; then
					iptables -N "$CHAIN"
					case $CHAIN in
						$INPT)
							iptables -I INPUT -j "$CHAIN"
						;;
						$FWRD)
							iptables -I FORWARD "$FWRDSTART" -j "$CHAIN"
						;;
						$LGRJT)
							iptables -I "$LGRJT" -j REJECT
							
							# Optional rule to log all rejected packets to syslog
							#iptables -I $LGRJT -j LOG --log-prefix "REJECT " --log-tcp-sequence --log-tcp-options --log-ip-options
						;;
					esac
				fi
			done
			for CHAIN in $NATCHAINS; do
				if ! iptables -t nat -n -L "$CHAIN" >/dev/null 2>&1; then
					iptables -t nat -N "$CHAIN"
					case $CHAIN in
						$DNSFLTR)
							### DNSFilter rules - credit to @RMerlin for the original implementation in Asuswrt ###
							iptables -t nat -A PREROUTING -p udp -m udp --dport 53 -j "$CHAIN"
							iptables -t nat -A PREROUTING -p tcp -m tcp --dport 53 -j "$CHAIN"
							###
						;;
					esac
				fi
			done
		;;
		deleteall)
			for CHAIN in $CHAINS; do
				if iptables -n -L "$CHAIN" >/dev/null 2>&1; then
					case $CHAIN in
						$INPT)
							iptables -D INPUT -j "$CHAIN"
						;;
						$FWRD)
							iptables -D FORWARD "$((FWRDSTART+1))"
						;;
						$LGRJT)
							iptables -D "$LGRJT" -j REJECT
						;;
					esac
					
					iptables -F "$CHAIN"
					iptables -X "$CHAIN"
				fi
			done
			for CHAIN in $NATCHAINS; do
				if ! iptables -t nat -n -L "$CHAIN" >/dev/null 2>&1; then
					case $CHAIN in
						$DNSFLTR)
							iptables -t nat -D PREROUTING -p udp -m udp --dport 53 -j "$CHAIN"
							iptables -t nat -D PREROUTING -p tcp -m tcp --dport 53 -j "$CHAIN"
						;;
					esac
					
					iptables -F "$CHAIN"
					iptables -X "$CHAIN"
				fi
			done
		;;
	esac
}

Firewall_Rules(){
	ACTIONS=""
	IFACE="$2"
	IFACE_WAN=""
	
	if [ "$(nvram get wan0_proto)" = "pppoe" ] || [ "$(nvram get wan0_proto)" = "pptp" ] || [ "$(nvram get wan0_proto)" = "l2tp" ]; then
		IFACE_WAN="ppp0"
	else
		IFACE_WAN="$(nvram get wan0_ifname)"
	fi
	
	case $1 in
		create)
			ACTIONS="-D -I"
		;;
		delete)
			ACTIONS="-D"
		;;
	esac
	
	for ACTION in $ACTIONS; do
		
		### Start of bridge rules ###
		
		# Un-bridge all frames entering br0 for IPv4, IPv6 and ARP to be processed by iptables
		ebtables -t broute "$ACTION" BROUTING -p ipv4 -i "$IFACE" -j DROP
		ebtables -t broute "$ACTION" BROUTING -p ipv6 -i "$IFACE" -j DROP
		ebtables -t broute "$ACTION" BROUTING -p arp -i "$IFACE" -j DROP
		
		ebtables "$ACTION" FORWARD -i "$IFACE" -j DROP
		ebtables "$ACTION" FORWARD -o "$IFACE" -j DROP
		
		ebtables -t broute -D BROUTING -p IPv4 -i "$IFACE" --ip-dst "$LAN"/24 --ip-proto tcp -j DROP
		ebtables -t broute -D BROUTING -p IPv4 -i "$IFACE" --ip-dst "$LAN" --ip-proto icmp -j ACCEPT
		ebtables -t broute -D BROUTING -p IPv4 -i "$IFACE" --ip-dst "$LAN"/24 --ip-proto icmp -j DROP
		### End of bridge rules ###
		
		### Start of IP firewall rules ###
		
		iptables "$ACTION" "$FWRD" -i "$IFACE" -j ACCEPT
		
		if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_LANACCESS")" = "false" ]; then
			iptables "$ACTION" "$FWRD" ! -i "$IFACE_WAN" -o "$IFACE" -j "$LGRJT"
			iptables "$ACTION" "$FWRD" -i "$IFACE" ! -o "$IFACE_WAN" -j "$LGRJT"
		else
			iptables -D "$FWRD" ! -i "$IFACE_WAN" -o "$IFACE" -j "$LGRJT"
			iptables -D "$FWRD" -i "$IFACE" ! -o "$IFACE_WAN" -j "$LGRJT"
		fi
		
		iptables "$ACTION" "$INPT" -i "$IFACE" -j "$LGRJT"
		iptables "$ACTION" "$INPT" -i "$IFACE" -p icmp -j ACCEPT
		iptables "$ACTION" "$INPT" -i "$IFACE" -p udp -m multiport --dports 67,123 -j ACCEPT
		
		ENABLED_WINS="$(nvram get smbd_wins)"
		ENABLED_SAMBA="$(nvram get enable_samba)"
		if ! Validate_Number "" "$ENABLED_SAMBA" "silent"; then ENABLED_SAMBA=0; fi
		if ! Validate_Number "" "$ENABLED_WINS" "silent"; then ENABLED_WINS=0; fi
		
		if [ "$ENABLED_WINS" -eq 1 ] && [ "$ENABLED_SAMBA" -eq 1 ]; then
			iptables "$ACTION" "$INPT" -i "$IFACE" -p udp -m multiport --dports 137,138 -j ACCEPT
		else
			iptables -D "$INPT" -i "$IFACE" -p udp -m multiport --dports 137,138 -j ACCEPT
		fi
		
		if IP_Local "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_DNS1")" || IP_Local "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_DNS2")"; then
			RULES=$(iptables -nvL $INPT --line-number | grep "$IFACE" | grep "pt:53" | awk '{print $1}' | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
			for RULENO in $RULES; do
				iptables -D "$INPT" "$RULENO"
			done
			
			RULES=$(iptables -nvL $FWRD --line-number | grep "$IFACE" | grep "pt:53" | awk '{print $1}' | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
			for RULENO in $RULES; do
				iptables -D "$FWRD" "$RULENO"
			done
			
			if IP_Router "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_DNS1")" "$IFACE" || IP_Router "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_DNS2")" "$IFACE"; then
				if ifconfig "br0:pixelserv-tls" | grep -q "inet addr:" >/dev/null 2>&1; then
					IP_PXLSRV=$(ifconfig br0:pixelserv-tls | grep "inet addr:" | cut -d: -f2 | awk '{print $1}')
					iptables "$ACTION" "$INPT" -i "$IFACE" -d "$IP_PXLSRV" -p tcp -m multiport --dports 80,443 -j ACCEPT
				else
					RULES=$(iptables -nvL $INPT --line-number | grep "$IFACE" | grep "multiport dports 80,443" | awk '{print $1}' | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
					for RULENO in $RULES; do
						iptables -D "$INPT" "$RULENO"
					done
				fi
				
				for PROTO in tcp udp; do
					iptables "$ACTION" "$INPT" -i "$IFACE" -p "$PROTO" --dport 53 -j ACCEPT
				done
			fi
			if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_DNS1")" != "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_DNS2")" ]; then
				if IP_Local "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_DNS1")" && ! IP_Router "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_DNS1")" "$IFACE"; then
					for PROTO in tcp udp; do
						iptables "$ACTION" "$FWRD" -i "$IFACE" -d "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_DNS1")" -p "$PROTO" --dport 53 -j ACCEPT
						iptables "$ACTION" "$FWRD" -o "$IFACE" -s "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_DNS1")" -p "$PROTO" --sport 53 -j ACCEPT
					done
				fi
				if IP_Local "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_DNS2")" && ! IP_Router "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_DNS2")" "$IFACE"; then
					for PROTO in tcp udp; do
						iptables "$ACTION" "$FWRD" -i "$IFACE" -d "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_DNS2")" -p "$PROTO" --dport 53 -j ACCEPT
						iptables "$ACTION" "$FWRD" -o "$IFACE" -s "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_DNS2")" -p "$PROTO" --sport 53 -j ACCEPT
					done
				fi
			else
				if ! IP_Router "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_DNS1")" "$IFACE"; then
					for PROTO in tcp udp; do
						iptables "$ACTION" "$FWRD" -i "$IFACE" -d "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_DNS1")" -p "$PROTO" --dport 53 -j ACCEPT
						iptables "$ACTION" "$FWRD" -o "$IFACE" -s "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_DNS1")" -p "$PROTO" --sport 53 -j ACCEPT
					done
				fi
			fi
		else
			RULES=$(iptables -nvL $INPT --line-number | grep "$IFACE" | grep "pt:53" | awk '{print $1}' | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
			for RULENO in $RULES; do
				iptables -D "$INPT" "$RULENO"
			done
			
			RULES=$(iptables -nvL $FWRD --line-number | grep "$IFACE" | grep "pt:53" | awk '{print $1}' | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
			for RULENO in $RULES; do
				iptables -D "$FWRD" "$RULENO"
			done
		fi
		
		### DNSFilter rules - credit to @RMerlin for the original implementation in Asuswrt ###
		if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_FORCEDNS")" = "true" ]; then
			RULES=$(iptables -t nat -nvL $DNSFLTR --line-number | grep "$IFACE" | awk '{print $1}' | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
			for RULENO in $RULES; do
				iptables -t nat -D "$DNSFLTR" "$RULENO"
			done
			
			VPNDNS="$(nvram get "vpn_client""$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_VPNCLIENTNUMBER")""_adns")"
			if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_REDIRECTALLTOVPN")" = "true" ] && [ "$VPNDNS" -lt 3 ]; then
				iptables -t nat "$ACTION" "$DNSFLTR" -i "$IFACE" -j DNAT --to-destination "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_DNS1")"
			elif [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_REDIRECTALLTOVPN")" = "false" ]; then
				iptables -t nat "$ACTION" "$DNSFLTR" -i "$IFACE" -j DNAT --to-destination "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_DNS1")"
			fi
		else
			RULES=$(iptables -t nat -nvL $DNSFLTR --line-number | grep "$IFACE" | awk '{print $1}' | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
			for RULENO in $RULES; do
				iptables -t nat -D "$DNSFLTR" "$RULENO"
			done
		fi
		###
		
		### End of IP firewall rules ###
	done
}

Firewall_NVRAM(){
	case $1 in
		create)
			# shellcheck disable=SC2140
			nvram set "$2""_ap_isolate"="1"
		;;
		delete)
			# shellcheck disable=SC2140
			nvram set "$2""_ap_isolate"="0"
		;;
		deleteall)
			for IFACE in $IFACELIST; do
				Firewall_NVRAM delete "$IFACE" 2>/dev/null
			done
		;;
	esac
}

Routing_RPDB(){
	case $1 in
		create)
			ip route del "$(eval echo '$'"$(Get_Iface_Var "$2")""_IPADDR" | cut -f1-3 -d".")".0/24 dev "$2" proto kernel table ovpnc"$3" src "$(eval echo '$'"$(Get_Iface_Var "$2")""_IPADDR" | cut -f1-3 -d".")"."$(nvram get lan_ipaddr | cut -f4 -d".")"
			ip route add "$(eval echo '$'"$(Get_Iface_Var "$2")""_IPADDR" | cut -f1-3 -d".")".0/24 dev "$2" proto kernel table ovpnc"$3" src "$(eval echo '$'"$(Get_Iface_Var "$2")""_IPADDR" | cut -f1-3 -d".")"."$(nvram get lan_ipaddr | cut -f4 -d".")"
		;;
		delete)
			COUNTER=1
			until [ $COUNTER -gt 5 ]; do
				ip route del "$(ip route show table ovpnc"$COUNTER" | grep "$2" | awk '{ print $1 }')" dev "$2" proto kernel table ovpnc"$COUNTER" src "$(ip route show table ovpnc"$COUNTER" | grep "$2" | awk '{ print $9 }')" 2>/dev/null
				COUNTER=$((COUNTER + 1))
			done
		;;
		deleteall)
			for IFACE in $IFACELIST; do
				Routing_RPDB delete "$IFACE" 2>/dev/null
			done
		;;
	esac
	
	ip route flush cache
}

Routing_RPDB_LAN(){
	case $1 in
		create)
			COUNTER=1
			until [ $COUNTER -gt 5 ]; do
				if ifconfig "tun1$COUNTER" >/dev/null 2>&1; then
					ip route del "$(eval echo '$'"$(Get_Iface_Var "$2")""_IPADDR" | cut -f1-3 -d".")".0/24 dev "$2" proto kernel table ovpnc"$COUNTER" src "$(eval echo '$'"$(Get_Iface_Var "$2")""_IPADDR" | cut -f1-3 -d".")"."$(nvram get lan_ipaddr | cut -f4 -d".")"
					ip route add "$(eval echo '$'"$(Get_Iface_Var "$2")""_IPADDR" | cut -f1-3 -d".")".0/24 dev "$2" proto kernel table ovpnc"$COUNTER" src "$(eval echo '$'"$(Get_Iface_Var "$2")""_IPADDR" | cut -f1-3 -d".")"."$(nvram get lan_ipaddr | cut -f4 -d".")"
				fi
				COUNTER=$((COUNTER+1))
			done
		;;
	esac
}

Routing_FWNAT(){
	case $1 in
		create)
			for ACTION in -D -I; do
				modprobe xt_comment
				iptables -t nat "$ACTION" POSTROUTING -s "$(eval echo '$'"$(Get_Iface_Var "$2")""_IPADDR" | cut -f1-3 -d".")".0/24 -o tun1"$3" -m comment --comment "$(Get_Guest_Name "$2")" -j MASQUERADE
				iptables "$ACTION" "$FWRD" -i "$2" -o tun1"$3" -j ACCEPT
				iptables "$ACTION" "$FWRD" -i tun1"$3" -o "$2" -j ACCEPT
			done
		;;
		delete)
			RULES=$(iptables -t nat -nvL POSTROUTING --line-number | grep "$(Get_Guest_Name "$2")" | awk '{print $1}' | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
			for RULENO in $RULES; do
				iptables -t nat -D POSTROUTING "$RULENO"
			done
			
			RULES=$(iptables -nvL $FWRD --line-number | grep "$2" | grep "tun1" | awk '{print $1}' | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
			for RULENO in $RULES; do
				iptables -D "$FWRD" "$RULENO"
			done
		;;
		deleteall)
			for IFACE in $IFACELIST; do
				Routing_FWNAT delete "$IFACE" 2>/dev/null
			done
		;;
	esac
}

Routing_NVRAM(){
	case $1 in
		initialise)
			COUNTER=1
			until [ $COUNTER -gt 5 ]; do
				eval "VPN_IP_LIST_ORIG_"$COUNTER="$(echo "$(nvram get "vpn_client""$COUNTER""_clientlist")""$(nvram get "vpn_client""$COUNTER""_clientlist1")""$(nvram get "vpn_client""$COUNTER""_clientlist2")""$(nvram get "vpn_client""$COUNTER""_clientlist3")""$(nvram get "vpn_client""$COUNTER""_clientlist4")""$(nvram get "vpn_client""$COUNTER""_clientlist5")" | Escape_Sed)"
				eval "VPN_IP_LIST_NEW_"$COUNTER="$(eval echo '$'"VPN_IP_LIST_ORIG_"$COUNTER | Escape_Sed)"
				COUNTER=$((COUNTER + 1))
			done
		;;
		create)
			VPN_NVRAM="$(Get_Guest_Name "$2")"
			VPN_IFACE_NVRAM="<$VPN_NVRAM>$(eval echo '$'"$(Get_Iface_Var "$2")""_IPADDR" | cut -f1-3 -d".").0/24>0.0.0.0>VPN"
			VPN_IFACE_NVRAM_SAFE="$(echo "$VPN_IFACE_NVRAM" | sed -e 's/\//\\\//g;s/\./\\./g;s/ /\\ /g')"
			
			# Check if guest network has already been added to policy routing for VPN client. If not, append to list.
			if ! eval echo '$'"VPN_IP_LIST_ORIG_""$3" | grep -q "$VPN_IFACE_NVRAM"; then
				eval "VPN_IP_LIST_NEW_""$3"="$(echo "$(eval echo '$'"VPN_IP_LIST_NEW_""$3")""$VPN_IFACE_NVRAM" | Escape_Sed)"
			fi
			
			# Remove guest interface from any other VPN clients (i.e. config has changed from client 2 to client 1)
			COUNTER=1
			until [ $COUNTER -gt 5 ]; do
				if [ $COUNTER -eq "$3" ]; then
					COUNTER=$((COUNTER + 1))
					continue
				fi
				eval "VPN_IP_LIST_NEW_"$COUNTER="$(eval echo '$'"VPN_IP_LIST_NEW_""$COUNTER" | sed -e "s/$VPN_IFACE_NVRAM_SAFE//g" | Escape_Sed)"
				COUNTER=$((COUNTER + 1))
			done
		;;
		delete)
			COUNTER=1
			until [ $COUNTER -gt 5 ]; do
				VPN_NVRAM="$(Get_Guest_Name "$2")"
				# shellcheck disable=SC2005
				# shellcheck disable=SC2086
				eval "VPN_IP_LIST_NEW_"$COUNTER="$(echo "$(eval echo '$'"VPN_IP_LIST_NEW_"$COUNTER)" | sed -e "s/$(echo '<'$VPN_NVRAM |  sed -e 's/\//\\\//g' | sed -e 's/ /\\ /g').*>VPN//g" | Escape_Sed)"
				COUNTER=$((COUNTER + 1))
			done
		;;
		deleteall)
			Routing_NVRAM initialise 2>/dev/null
			
			for IFACE in $IFACELIST; do
				Routing_NVRAM delete "$IFACE" 2>/dev/null
			done
			
			Routing_NVRAM save 2>/dev/null
		;;
		save)
			COUNTER=1
			until [ $COUNTER -gt 5 ]; do
				if [ "$(eval echo '$'"VPN_IP_LIST_ORIG_"$COUNTER)" != "$(eval echo '$'"VPN_IP_LIST_NEW_"$COUNTER)" ]; then
					Print_Output "true" "VPN Client $COUNTER client list has changed, restarting VPN Client $COUNTER"
					
					# shellcheck disable=SC2140
					if [ "$(uname -m)" = "aarch64" ]; then
						fullstring="$(eval echo '$'"VPN_IP_LIST_NEW_"$COUNTER)"
						nvram set "vpn_client""$COUNTER""_clientlist"="$(echo "$fullstring" | cut -c0-255)"
						nvram set "vpn_client""$COUNTER""_clientlist1"="$(echo "$fullstring" | cut -c256-510)"
						nvram set "vpn_client""$COUNTER""_clientlist2"="$(echo "$fullstring" | cut -c511-765)"
						nvram set "vpn_client""$COUNTER""_clientlist3"="$(echo "$fullstring" | cut -c766-1020)"
						nvram set "vpn_client""$COUNTER""_clientlist4"="$(echo "$fullstring" | cut -c1021-1275)"
						nvram set "vpn_client""$COUNTER""_clientlist5"="$(echo "$fullstring" | cut -c1276-1530)"
					else
						nvram set "vpn_client""$COUNTER""_clientlist"="$(eval echo '$'"VPN_IP_LIST_NEW_"$COUNTER)"
					fi
					nvram commit
					service restart_vpnclient$COUNTER >/dev/null 2>&1
				fi
				COUNTER=$((COUNTER + 1))
			done
		;;
	esac
}

DHCP_Conf_Block(){
	case $1 in
		delete)
			DHCPBLOCK_BR0=$(grep -c '# '"$YAZFI_NAME"' Guest Networks' $DNSCONF)
			
			if [ "$DHCPBLOCK_BR0" -gt 0 ]; then
				sed -i -e '/# '"$YAZFI_NAME"' Guest Networks/d' $DNSCONF
			fi
		;;
	esac
}

DHCP_Conf(){
	case $1 in
		initialise)
			if [ -f $DNSCONF ]; then
				cp $DNSCONF $TMPCONF
			else
				touch $TMPCONF
			fi
		;;
		create)
			CONFSTRING=""
			ENABLED_WINS="$(nvram get smbd_wins)"
			ENABLED_SAMBA="$(nvram get enable_samba)"
			if ! Validate_Number "" "$ENABLED_SAMBA" "silent"; then ENABLED_SAMBA=0; fi
			if ! Validate_Number "" "$ENABLED_WINS" "silent"; then ENABLED_WINS=0; fi
			
			if [ "$ENABLED_WINS" -eq 1 ] && [ "$ENABLED_SAMBA" -eq 1 ]; then
				CONFSTRING="interface=$2||||dhcp-range=$2,$(eval echo '$'"$(Get_Iface_Var "$2")""_IPADDR" | cut -f1-3 -d".").$(eval echo '$'"$(Get_Iface_Var "$2")""_DHCPSTART"),$(eval echo '$'"$(Get_Iface_Var "$2")""_IPADDR" | cut -f1-3 -d".").$(eval echo '$'"$(Get_Iface_Var "$2")""_DHCPEND"),255.255.255.0,43200s||||dhcp-option=$2,3,$(eval echo '$'"$(Get_Iface_Var "$2")""_IPADDR" | cut -f1-3 -d".").$(nvram get lan_ipaddr | cut -f4 -d".")||||dhcp-option=$2,6,$(eval echo '$'"$(Get_Iface_Var "$2")""_DNS1"),$(eval echo '$'"$(Get_Iface_Var "$2")""_DNS2")||||dhcp-option=$2,44,$(nvram get lan_ipaddr)"
			else
				CONFSTRING="interface=$2||||dhcp-range=$2,$(eval echo '$'"$(Get_Iface_Var "$2")""_IPADDR" | cut -f1-3 -d".").$(eval echo '$'"$(Get_Iface_Var "$2")""_DHCPSTART"),$(eval echo '$'"$(Get_Iface_Var "$2")""_IPADDR" | cut -f1-3 -d".").$(eval echo '$'"$(Get_Iface_Var "$2")""_DHCPEND"),255.255.255.0,43200s||||dhcp-option=$2,3,$(eval echo '$'"$(Get_Iface_Var "$2")""_IPADDR" | cut -f1-3 -d".").$(nvram get lan_ipaddr | cut -f4 -d".")||||dhcp-option=$2,6,$(eval echo '$'"$(Get_Iface_Var "$2")""_DNS1"),$(eval echo '$'"$(Get_Iface_Var "$2")""_DNS2")"
			fi
			BEGIN="### Start of script-generated configuration for interface $2 ###"
			END="### End of script-generated configuration for interface $2 ###"
			if grep -q "### Start of script-generated configuration for interface $2 ###" $TMPCONF; then
				# shellcheck disable=SC1003
				sed -i -e '/'"$BEGIN"'/,/'"$END"'/c\'"$BEGIN"'||||'"$CONFSTRING"'||||'"$END" $TMPCONF
			else
				printf "\\n%s\\n%s\\n%s\\n" "$BEGIN" "$CONFSTRING" "$END" >> $TMPCONF
			fi
		;;
		delete)
			BEGIN="### Start of script-generated configuration for interface $2 ###"
			END="### End of script-generated configuration for interface $2 ###"
			if grep -q "### Start of script-generated configuration for interface $2 ###" $TMPCONF; then
				# shellcheck disable=SC1003
				sed -i -e '/'"$BEGIN"'/,/'"$END"'/c\'"" $TMPCONF
			fi
		;;
		deleteall)
			DHCP_Conf initialise 2>/dev/null
			for IFACE in $IFACELIST; do
				BEGIN="### Start of script-generated configuration for interface $IFACE ###"
				END="### End of script-generated configuration for interface $2 ###"
				if grep -q "### Start of script-generated configuration for interface $2 ###" $TMPCONF; then
					# shellcheck disable=SC1003
					sed -i -e '/'"$BEGIN"'/,/'"$END"'/c\'"" $TMPCONF
				fi
			done
			
			DHCP_Conf save 2>/dev/null
		;;
		save)
			sed -i -e 's/||||/\n/g' $TMPCONF
			
			if ! diff -q $DNSCONF $TMPCONF >/dev/null 2>&1; then
				cp $TMPCONF $DNSCONF
				service restart_dnsmasq >/dev/null 2>&1
				Print_Output "true" "DHCP configuration updated"
				sleep 2
				Iface_BounceClients 2>/dev/null
			fi
			
			rm -f $TMPCONF
		;;
	esac
}

Config_Networks(){
	Print_Output "true" "YazFi $YAZFI_VERSION starting up"
	WIRELESSRESTART="false"
	
	if ! Conf_Exists; then
		Conf_Download $YAZFI_CONF
		exit 1
	fi
	
	if ! Conf_Validate; then
		exit 1
	fi
	
	. $YAZFI_CONF
	
	Auto_Startup create 2>/dev/null
	Auto_ServiceEvent create 2>/dev/null
	
	DHCP_Conf initialise 2>/dev/null
	
	Routing_NVRAM initialise 2>/dev/null
	
	Firewall_Chains create 2>/dev/null
	
	for IFACE in $IFACELIST; do
		VPNCLIENTNO=$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_VPNCLIENTNUMBER")
		
		if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_ENABLED")" = "true" ]; then
			Iface_Manage create "$IFACE" 2>/dev/null
			
			Firewall_Rules create "$IFACE" 2>/dev/null
			
			if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_REDIRECTALLTOVPN")" = "true" ]; then
				Print_Output "true" "$IFACE (SSID: $(nvram get "$IFACE""_ssid")) - VPN redirection enabled, sending all interface internet traffic over VPN Client $VPNCLIENTNO"
				
				Routing_NVRAM create "$IFACE" "$VPNCLIENTNO" 2>/dev/null
				
				Routing_RPDB create "$IFACE" "$VPNCLIENTNO" 2>/dev/null
				
				Routing_FWNAT create "$IFACE" "$VPNCLIENTNO" 2>/dev/null
			else
				Print_Output "true" "$IFACE (SSID: $(nvram get "$IFACE""_ssid")) - sending all interface internet traffic over WAN interface"
				
				# Remove guest interface from VPN client routing table
				Routing_RPDB delete "$IFACE" 2>/dev/null
				
				# Remove guest interface VPN NAT rules and interface access
				Routing_FWNAT delete "$IFACE" 2>/dev/null
				
				# Remove guest interface from all policy routing
				Routing_NVRAM delete "$IFACE" 2>/dev/null
			fi
			
			if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_CLIENTISOLATION")" = "true" ]; then
				ISOBEFORE="$(nvram get "$IFACE""_ap_isolate")"
				if ! Validate_Number "" "$ISOBEFORE" "silent"; then ISOBEFORE=0; fi
				Firewall_NVRAM create "$IFACE" 2>/dev/null
				ISOAFTER="$(nvram get "$IFACE""_ap_isolate")"
				if ! Validate_Number "" "$ISOAFTER" "silent"; then ISOAFTER=0; fi
				if [ "$ISOBEFORE" -ne "$ISOAFTER" ]; then
					WIRELESSRESTART="true"
				fi
			else
				ISOBEFORE="$(nvram get "$IFACE""_ap_isolate")"
				if ! Validate_Number "" "$ISOBEFORE" "silent"; then ISOBEFORE=0; fi
				Firewall_NVRAM delete "$IFACE" 2>/dev/null
				ISOAFTER="$(nvram get "$IFACE""_ap_isolate")"
				if ! Validate_Number "" "$ISOAFTER" "silent"; then ISOAFTER=0; fi
				if [ "$ISOBEFORE" -ne "$ISOAFTER" ]; then
					WIRELESSRESTART="true"
				fi
			fi
			
			#Routing_RPDB_LAN create "$IFACE" 2>/dev/null
			
			DHCP_Conf create "$IFACE" 2>/dev/null
			
			sleep 1
		else
			#Remove firewall rules for guest interface
			Firewall_Rules delete "$IFACE" 2>/dev/null
			
			#Reset guest interface ISOLATION
			ISOBEFORE="$(nvram get "$IFACE""_ap_isolate")"
			if ! Validate_Number "" "$ISOBEFORE" "silent"; then ISOBEFORE=0; fi
			Firewall_NVRAM delete "$IFACE" 2>/dev/null
			ISOAFTER="$(nvram get "$IFACE""_ap_isolate")"
			if ! Validate_Number "" "$ISOAFTER" "silent"; then ISOAFTER=0; fi
			if [ "$ISOBEFORE" -ne "$ISOAFTER" ]; then
				WIRELESSRESTART="true"
			fi
			
			#Remove guest interface
			Iface_Manage delete "$IFACE" 2>/dev/null
			
			# Remove dnsmasq entries for this interface
			DHCP_Conf delete "$IFACE" 2>/dev/null
			
			# Remove guest interface from all policy routing
			Routing_NVRAM delete "$IFACE" 2>/dev/null
			
			# Remove guest interface from VPN client routing table
			Routing_RPDB delete "$IFACE" 2>/dev/null
			
			# Remove guest interface VPN NAT rules and interface access
			Routing_FWNAT delete "$IFACE" 2>/dev/null
		fi
	done
	
	Routing_NVRAM save 2>/dev/null
	
	DHCP_Conf save 2>/dev/null
	
	#Clean DHCP blocking
	if [ "$BLOCKDHCP" = "true" ]; then
		Auto_Block_DHCP delete 2>/dev/null
		DHCP_Conf_Block delete 2>/dev/null
		rm -f "$YAZFI_BLOCKDHCPFILE" 2>/dev/null
		service restart_dnsmasq >/dev/null 2>&1
	fi
	
	if [ "$WIRELESSRESTART" = "true" ]; then
		nvram commit
		Clear_Lock
		service restart_wireless >/dev/null 2>&1
	fi
	
	Print_Output "true" "YazFi $YAZFI_VERSION completed successfully" "$PASS"
}

Shortcut_YazFi(){
	case $1 in
		create)
			if [ -d "/opt/bin" ] && [ ! -f "/opt/bin/$YAZFI_NAME" ] && [ -f "/jffs/scripts/$YAZFI_NAME" ]; then
				ln -s /jffs/scripts/$YAZFI_NAME /opt/bin
				chmod 0755 /opt/bin/$YAZFI_NAME
			fi
		;;
		delete)
			if [ -f "/opt/bin/$YAZFI_NAME" ]; then
				rm -f /opt/bin/$YAZFI_NAME
			fi
		;;
	esac
}

PressEnter(){
	while true; do
		printf "Press enter to continue..."
		read -r "key"
		case "$key" in
			*)
				break;
			;;
		esac
	done
	return 0
}

ScriptHeader(){
	clear
	printf "\\n"
	printf "\\e[1m#####################################################\\e[0m\\n"
	printf "\\e[1m######                                         ######\\e[0m\\n"
	printf "\\e[1m######     __     __          ______  _        ######\\e[0m\\n"
	printf "\\e[1m######     \ \   / /         |  ____|(_)       ######\\e[0m\\n"
	printf "\\e[1m######      \ \_/ /__ _  ____| |__    _        ######\\e[0m\\n"
	printf "\\e[1m######       \   // _  ||_  /|  __|  | |       ######\\e[0m\\n"
	printf "\\e[1m######        | || (_| | / / | |     | |       ######\\e[0m\\n"
	printf "\\e[1m######        |_| \__,_|/___||_|     |_|       ######\\e[0m\\n"
	printf "\\e[1m######                                         ######\\e[0m\\n"
	printf "\\e[1m######                 %s                  ######\\e[0m\\n" "$YAZFI_VERSION"
	printf "\\e[1m######                                         ######\\e[0m\\n"
	printf "\\e[1m######    https://github.com/jackyaz/YazFi/    ######\\e[0m\\n"
	printf "\\e[1m######                                         ######\\e[0m\\n"
	printf "\\e[1m#####################################################\\e[0m\\n"
	printf "\\n"
}

MainMenu(){
	Shortcut_YazFi create
	printf "1.    Apply %s settings\\n" "$YAZFI_NAME"
	printf "2.    Edit %s configuration\\n" "$YAZFI_NAME"
	printf "3.    Check for updates\\n"
	printf "4.    Show connected clients using %s\\n" "$YAZFI_NAME"
	printf "5.    Uninstall %s\\n" "$YAZFI_NAME"
	printf "d.    Generate %s diagnostics\\n" "$YAZFI_NAME"
	printf "e.    Exit YazFi\\n"
	printf "\\n"
	printf "\\e[1m#####################################################\\e[0m\\n"
	printf "\\n"
	
	while true; do
		printf "Choose an option:    "
		read -r "menu"
		case "$menu" in
			1)
				printf "\\n"
				Menu_RunNow
				PressEnter
				break
			;;
			2)
				printf "\\n"
				Menu_Edit
				break
			;;
			3)
				printf "\\n"
				Menu_Update
				PressEnter
				break
			;;
			3f)
				printf "\\n"
				Menu_ForceUpdate
				PressEnter
				break
			;;
			4)
				printf "\\n"
				Menu_Status
				PressEnter
				break
			;;
			5)
				while true; do
					printf "\\n\\e[1mAre you sure you want to uninstall YazFi? (y/n)\\e[0m\\n"
					read -r "confirm"
					case "$confirm" in
						y|Y)
							Menu_Uninstall
							exit 0
						;;
						*)
							break
						;;
					esac
				done
			;;
			d)
				ScriptHeader
				Menu_Diagnostics
				PressEnter
				break
			;;
			e)
				ScriptHeader
				printf "\\n\\e[1mThanks for using %s!\\e[0m\\n\\n\\n" "$YAZFI_NAME"
				exit 0
			;;
			*)
				printf "\\nPlease choose a valid option\\n\\n"
			;;
		esac
	done
	
	ScriptHeader
	MainMenu
}

Check_Requirements(){
	CHECKSFAILED="false"
	
	if [ "$(nvram get sw_mode)" -ne 1 ]; then
		Print_Output "true" "Device is not running in router mode - non-router modes are not supported" "$ERR"
		CHECKSFAILED="true"
	fi
	
	if ! modprobe xt_comment 2>/dev/null; then
		Print_Output "true" "Router does not support xt_comment module for iptables. Is a newer firmware available?" "$ERR"
		CHECKSFAILED="true"
	fi
	
	if [ "$(nvram get jffs2_scripts)" -ne 1 ]; then
		nvram set jffs2_scripts=1
		nvram commit
		Print_Output "true" "Custom JFFS Scripts enabled" "$WARN"
	fi
	
	if [ "$(nvram get wl0_radio)" -eq 0 ] && [ "$(nvram get wl1_radio)" -eq 0 ] && [ "$(nvram get wl_radio)" -eq 0 ]; then
		Print_Output "true" "No wireless radios are enabled!" "$ERR"
		CHECKSFAILED="true"
	fi
	
	if [ "$(Firmware_Version_Check "$(nvram get buildno)")" -lt "$(Firmware_Version_Check 384.5)" ] && [ "$(Firmware_Version_Check "$(nvram get buildno)")" -ne "$(Firmware_Version_Check 374.43)" ]; then
		Print_Output "true" "Older Merlin firmware detected - service-event requires 384.5 or later" "$WARN"
		Print_Output "true" "Please update to benefit from $YAZFI_NAME detecting wireless restarts" "$WARN"
	elif [ "$(Firmware_Version_Check "$(nvram get buildno)")" -eq "$(Firmware_Version_Check 374.43)" ]; then
		Print_Output "true" "John's fork detected - service-event requires 374.43_32D6j9527 or later" "$WARN"
		Print_Output "true" "Please update to benefit from $YAZFI_NAME detecting wireless restarts" "$WARN"
	fi
	
	if [ "$CHECKSFAILED" = "false" ]; then
		return 0
	else
		return 1
	fi
}

Menu_Install(){
	Check_Lock
	Print_Output "true" "Welcome to YazFi $YAZFI_VERSION, a script by JackYaz"
	sleep 1
	
	Print_Output "true" "Checking your router meets the requirements for $YAZFI_NAME"
	
	if ! Check_Requirements; then
		Print_Output "true" "Requirements for $YAZFI_NAME not met, please see above for the reason(s)" "$CRIT"
		PressEnter
		Clear_Lock
		exit 1
	fi
	
	if ! Conf_Exists; then
		Conf_Download "$YAZFI_CONF"
	else
		Print_Output "false" "Existing $YAZFI_CONF found. This will be kept by $YAZFI_NAME"
		Conf_Download $YAZFI_CONF".example"
	fi
	
	Shortcut_YazFi create
	echo ""
	echo ""
	Print_Output "true" "You can access YazFi's menu via amtm (if installed) with /jffs/scripts/$YAZFI_NAME or simply $YAZFI_NAME"
	PressEnter
	Clear_Lock
}

Menu_Edit(){
	Check_Lock
	texteditor=""
	exitmenu="false"
	while true; do
		printf "\\n\\e[1mA choice of text editors is available:\\e[0m\\n"
		printf "1.    nano (recommended for beginners)\\n"
		printf "2.    vi\\n"
		printf "e.    Exit to main menu\\n"
		printf "\\n\\e[1mWhich editor would you like to use?\\e[0m\\n"
		read -r "editor"
		case "$editor" in
			1)
				texteditor="nano -K"
				break;
			;;
			2)
				texteditor="vi"
				break;
			;;
			e)
				exitmenu="true"
				break;
			;;
			*)
				printf "\\nInvalid option, continuing using nano\\n\\n"
				texteditor="nano -K"
				sleep 2
				break
			;;
		esac
	done
	
	if [ "$exitmenu" != "true" ]; then
		$texteditor $YAZFI_CONF
	fi
	
	Clear_Lock
}

Menu_RunNow(){
	Check_Lock
	Config_Networks
	Clear_Lock
}

Menu_Update(){
	Check_Lock
	sleep 1
	Update_Version
	Clear_Lock
}

Menu_ForceUpdate(){
	Check_Lock
	sleep 1
	Update_Version force
	Clear_Lock
}

Menu_Uninstall(){
	Check_Lock
	Print_Output "true" "Removing YazFi..." "$PASS"
	Auto_Startup delete 2>/dev/null
	Auto_ServiceEvent delete 2>/dev/null
	Routing_NVRAM deleteall 2>/dev/null
	Routing_FWNAT deleteall 2>/dev/null
	Routing_RPDB deleteall 2>/dev/null
	Firewall_Chains deleteall 2>/dev/null
	Firewall_NVRAM deleteall "$IFACE" 2>/dev/null
	Iface_Manage deleteall 2>/dev/null
	DHCP_Conf deleteall 2>/dev/null
	while true; do
		printf "\\n\\e[1mDo you want to delete YazFi configuration file(s)? (y/n)\\e[0m\\n"
		read -r "confirm"
		case "$confirm" in
			y|Y)
				rm -rf "/jffs/configs/$YAZFI_NAME" 2>/dev/null
				break
			;;
			*)
				break
			;;
		esac
	done
	Shortcut_YazFi delete
	rm -f "/jffs/scripts/$YAZFI_NAME" 2>/dev/null
	Clear_Lock
	Print_Output "true" "Restarting firewall to complete uninstall" "$PASS"
	service restart_firewall >/dev/null 2>&1
}

Menu_BounceClients(){
	Check_Lock
	Iface_BounceClients
	Clear_Lock
}

Menu_Status(){
	### This function suggested by @HuskyHerder, code inspired by @ColinTaylor's wireless monitor script ###
	Check_Lock
	sleep 1
	. "$YAZFI_CONF"
	
	Print_Output "false" "Querying router for connected WiFi clients..." "$PASS"
	
	for IFACE in $IFACELIST; do
		if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")""_ENABLED")" = "true" ]; then
			printf "%75s\\n\\n" "" |tr " " "-"
			printf "\\e[1mINTERFACE: %-5s\\e[0m\\n" "$IFACE"
			printf "\\e[1mSSID: %-20s\\e[0m\\n\\n" "$(nvram get "$IFACE""_ssid")"
			IFACE_MACS="$(wl -i "$IFACE" assoclist)"
			if [ "$IFACE_MACS" != "" ]; then
				printf "\\e[1m%-20s%-20s%-20s\\e[0m\\n" "HOSTNAME" "IP ADDRESS" "MAC"
				# shellcheck disable=SC2039
				IFS=$'\n'
				for GUEST_MAC in $IFACE_MACS; do
					GUEST_MACADDR="${GUEST_MAC#* }"
					GUEST_ARPINFO="$(arp -a | grep "$IFACE" | grep -i "$GUEST_MACADDR")"
					GUEST_HOST="$(echo "$GUEST_ARPINFO" | awk '{print $1}' | cut -f1 -d ".")"
					if [ "$GUEST_HOST" = "?" ]; then
						GUEST_HOST=$(grep "$GUEST_MACADDR" /var/lib/misc/dnsmasq.leases | awk '{print $4}')
					fi
					
					if [ "$GUEST_HOST" = "?" ] || [ "${#GUEST_HOST}" -le 1 ]; then
						GUEST_HOST="Unknown"
					fi
					
					GUEST_IPADDR="$(echo "$GUEST_ARPINFO" | awk '{print $2}' | sed -e 's/(//g;s/)//g')"
					printf "%-20s%-20s%-20s\\e[0m\\n" "$GUEST_HOST" "$GUEST_IPADDR" "$GUEST_MACADDR"
				done
				unset IFS
			else
				printf "\\e[1m\\e[33mNo clients connected\\e[0m\\n\\n"
			fi
		fi
	done
	
	printf "%75s\\n\\n" "" |tr " " "-"
	
	Print_Output "false" "Query complete, please see above for results" "$PASS"
	Clear_Lock
	#######################################################################################################
}

Menu_Diagnostics(){
	printf "\\n\\e[1mThis will collect the following. Files are encrypted with a unique random passphrase.\\e[0m\\n"
	printf "\\n\\e[1m - iptables rules\\e[0m"
	printf "\\n\\e[1m - ebtables rules\\e[0m"
	printf "\\n\\e[1m - %s\\e[0m" "$YAZFI_CONF"
	printf "\\n\\e[1m - %s\\e[0m" "$DNSCONF"
	printf "\\n\\e[1m - /jffs/scripts/firewall-start\\e[0m"
	printf "\\n\\e[1m - /jffs/scripts/service-event\\e[0m\\n\\n"
	while true; do
		printf "\\n\\e[1mDo you want to continue? (y/n)\\e[0m\\n"
		read -r "confirm"
		case "$confirm" in
			y|Y)
				break
			;;
			n|N)
				printf "\\n\\e[1mUser declined, returning to menu\\e[0m\\n\\n"
				return 1
			;;
			*)
				printf "\\nPlease choose a valid option (y/n)\\n\\n"
			;;
		esac
	done
	
	printf "\\n\\n\\e[1mGenerating %s diagnostics...\\e[0m\\n\\n" "$YAZFI_NAME"
	
	DIAGPATH="/tmp/""$YAZFI_NAME""Diag"
	mkdir -p "$DIAGPATH"
	
	iptables-save > "$DIAGPATH""/iptables.txt"
	
	ebtables -L > "$DIAGPATH""/ebtables.txt"
	echo "" >> "$DIAGPATH""/ebtables.txt"
	ebtables -t broute -L >> "$DIAGPATH""/ebtables.txt"
	
	cp "$YAZFI_CONF" "$DIAGPATH""/""$YAZFI_NAME"".conf"
	cp "$DNSCONF" "$DIAGPATH""/dnsmasq.conf.add"
	cp "/jffs/scripts/firewall-start" "$DIAGPATH""/firewall-start"
	cp "/jffs/scripts/service-event" "$DIAGPATH""/service-event"
	
	SEC=$(< /dev/urandom tr -cd 'a-z0-9' | head -c 32)
	tar -czf "/tmp/$YAZFI_NAME.tar.gz" -C "$DIAGPATH" .
	/usr/sbin/openssl enc -aes-256-cbc -k "$SEC" -e -in "/tmp/$YAZFI_NAME.tar.gz" -out "/tmp/YazFi.tar.gz.enc"
	
	Print_Output "true" "Diagnostics saved to /tmp/$YAZFI_NAME.tar.gz.enc with passphrase $SEC" "$PASS"
	
	rm -f "/tmp/$YAZFI_NAME.tar.gz" 2>/dev/null
	rm -rf "$DIAGPATH" 2>/dev/null 2>/dev/null
	SEC=""
}

if [ -z "$1" ]; then
	Check_Lock
	Auto_Startup create 2>/dev/null
	Auto_ServiceEvent create 2>/dev/null
	Clear_Lock
	ScriptHeader
	MainMenu
	exit 0
fi

case "$1" in
	install)
		Menu_Install
		exit 0
	;;
	runnow)
		Menu_RunNow
		exit 0
	;;
	update)
		Menu_Update
		exit 0
	;;
	forceupdate)
		Menu_ForceUpdate
		exit 0
	;;
	uninstall)
		Menu_Uninstall
		exit 0
	;;
	bounceclients)
		if [ -z "$2" ] && [ -z "$3" ]; then
			Menu_BounceClients
		elif [ "$2" = "restart" ] && [ "$3" = "wireless" ]; then
			Check_Lock
			Print_Output "true" "Wireless restarted - sleeping 30s before running YazFi" "$PASS"
			sleep 30
			Config_Networks
			Iface_BounceClients
			Clear_Lock
		fi
		exit 0
	;;
	status)
		Menu_Status
		exit 0
	;;
	*)
		Check_Lock
		echo "Command not recognised, please try again"
		Clear_Lock
		exit 1
	;;
esac
