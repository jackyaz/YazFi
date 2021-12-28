#!/bin/sh

#############################################
##                                         ##
##     __     __          ______  _        ##
##     \ \   / /         |  ____|(_)       ##
##      \ \_/ /__ _  ____| |__    _        ##
##       \   // _  ||_  /|  __|  | |       ##
##        | || (_| | / / | |     | |       ##
##        |_| \__,_|/___||_|     |_|       ##
##                                         ##
##    https://github.com/jackyaz/YazFi/    ##
##                                         ##
#############################################
##   Credit to @RMerlin for the original   ##
##    guest network DHCP script and for    ##
##         AsusWRT-Merlin firmware         ##
#############################################

######       Shellcheck directives     ######
# shellcheck disable=SC1003
# shellcheck disable=SC1090
# shellcheck disable=SC2005
# shellcheck disable=SC2016
# shellcheck disable=SC2018
# shellcheck disable=SC2019
# shellcheck disable=SC2034
# shellcheck disable=SC2039
# shellcheck disable=SC2059
# shellcheck disable=SC2086
# shellcheck disable=SC2140
# shellcheck disable=SC2155
# shellcheck disable=SC3003
#############################################

### Start of script variables ###
readonly SCRIPT_NAME="YazFi"
readonly SCRIPT_CONF="/jffs/addons/$SCRIPT_NAME.d/config"
readonly YAZFI_VERSION="v4.3.4"
readonly SCRIPT_VERSION="v4.3.4"
SCRIPT_BRANCH="master"
SCRIPT_REPO="https://raw.githubusercontent.com/jackyaz/$SCRIPT_NAME/$SCRIPT_BRANCH"
readonly SCRIPT_DIR="/jffs/addons/$SCRIPT_NAME.d"
readonly USER_SCRIPT_DIR="$SCRIPT_DIR/userscripts.d"
readonly SCRIPT_WEBPAGE_DIR="$(readlink /www/user)"
readonly SCRIPT_WEB_DIR="$SCRIPT_WEBPAGE_DIR/$SCRIPT_NAME"
readonly SHARED_DIR="/jffs/addons/shared-jy"
readonly SHARED_REPO="https://raw.githubusercontent.com/jackyaz/shared-jy/master"
readonly SHARED_WEB_DIR="$SCRIPT_WEBPAGE_DIR/shared-jy"
### End of script variables ###

### Start of output format variables ###
readonly CRIT="\\e[41m"
readonly ERR="\\e[31m"
readonly WARN="\\e[33m"
readonly PASS="\\e[32m"
readonly BOLD="\\e[1m"
readonly SETTING="${BOLD}\\e[36m"
readonly CLEARFORMAT="\\e[0m"
### End of output format variables ###

### Start of router environment variables ###
readonly LAN="$(nvram get lan_ipaddr)"
[ -z "$(nvram get odmpid)" ] && ROUTER_MODEL=$(nvram get productid) || ROUTER_MODEL=$(nvram get odmpid)
readonly IFACELIST_FULL="wl0.1 wl0.2 wl0.3 wl1.1 wl1.2 wl1.3 wl2.1 wl2.2 wl2.3"
IFACELIST="$(echo "$(nvram get wl0_vifnames) $(nvram get wl1_vifnames) $(nvram get wl2_vifnames)" | awk '{$1=$1;print}')"
### End of router environment variables ###

### Start of path variables ###
readonly DNSCONF="$SCRIPT_DIR/.dnsmasq"
readonly TMPCONF="$SCRIPT_DIR/.dnsmasq.tmp"
### End of path variables ###

### Start of firewall variables ###
readonly INPT="${SCRIPT_NAME}INPUT"
readonly FWRD="${SCRIPT_NAME}FORWARD"
readonly LGRJT="${SCRIPT_NAME}REJECT"
readonly DNSFLTR="${SCRIPT_NAME}DNSFILTER"
readonly DNSFLTR_DOT="${SCRIPT_NAME}DNSFILTER_DOT"
readonly CHAINS="$INPT $FWRD $LGRJT $DNSFLTR_DOT"
readonly NATCHAINS="$DNSFLTR"
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
		logger -t "$SCRIPT_NAME" "$2"
	fi
	printf "${BOLD}${3}%s${CLEARFORMAT}\\n\\n" "$2"
}

Generate_Random_String(){
	PASSLENGTH=16
	if Validate_Number "" "$1" silent; then
		if [ "$1" -le 32 ] && [ "$1" -ge 8 ]; then
			PASSLENGTH="$1"
		else
			printf "${BOLD}Number is not between 8 and 32, using default of 16 characters${CLEARFORMAT}\\n"
		fi
	else
		printf "${BOLD}Invalid number provided, using default of 16 characters${CLEARFORMAT}\\n"
	fi
	
	< /dev/urandom tr -cd 'A-Za-z0-9' | head -c "$PASSLENGTH"
}

Escape_Sed(){
	sed -e 's/</\\</g;s/>/\\>/g;s/ /\\ /g'
}

Get_Iface_Var(){
	echo "$1" | sed -e 's/\.//g'
}

Get_Guest_Name(){
	if echo "$1" | grep -q "wl0"; then
		echo "YazFi 2.4GHz $(echo "$1" | cut -f2 -d".")"
	elif echo "$1" | grep -q "wl1"; then
		echo "YazFi 5GHz $(echo "$1" | cut -f2 -d".")"
	else
		echo "YazFi 5GHz2 $(echo "$1" | cut -f2 -d".")"
	fi
}

Get_Guest_Name_Old(){
	if echo "$1" | grep -q "wl0"; then
		echo "2.4GHz Guest $(echo "$1" | cut -f2 -d".")"
	elif echo "$1" | grep -q "wl1"; then
		echo "5GHz1 Guest $(echo "$1" | cut -f2 -d".")"
	else
		echo "5GHz2 Guest $(echo "$1" | cut -f2 -d".")"
	fi
}

Set_WiFi_Passphrase(){
	nvram set "${1}_wpa_psk"="$2"
	nvram set "${1}_auth_mode_x"="psk2"
	nvram set "${1}_akm"="psk2"
	nvram commit
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
	Print_Output true "Forcing $SCRIPT_NAME Guest WiFi clients to reauthenticate" "$PASS"
	
	for IFACE in $IFACELIST; do
		wl -i "$IFACE" radio off >/dev/null 2>&1
	done
	
	sleep 10
	
	for IFACE in $IFACELIST; do
		wl -i "$IFACE" radio on >/dev/null 2>&1
	done
	
	ARPDUMP="$(arp -an)"
	for IFACE in $IFACELIST; do
		if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_ENABLED")" = "true" ]; then
			IFACE_MACS="$(wl -i "$IFACE" assoclist)"
			if [ "$IFACE_MACS" != "" ]; then
				IFS=$'\n'
				for GUEST_MAC in $IFACE_MACS; do
					GUEST_MACADDR="${GUEST_MAC#* }"
					GUEST_ARPINFO="$(arp -an | grep -i "$GUEST_MACADDR")"
					for ARP_ENTRY in $GUEST_ARPINFO; do
						GUEST_IPADDR="$(echo "$GUEST_ARPINFO" | awk '{print $2}' | sed -e 's/(//g;s/)//g')"
						arp -d "$GUEST_IPADDR"
					done
				done
				unset IFS
			fi
		fi
	done
	
	ip -s -s neigh flush all >/dev/null 2>&1
	killall networkmap
	sleep 5
	if [ -z "$(pidof networkmap)" ]; then
		networkmap >/dev/null 2>&1 &
	fi
}

Auto_DNSMASQ(){
	case $1 in
		create)
			if [ -f /jffs/scripts/dnsmasq.postconf ]; then
				STARTUPLINECOUNT=$(grep -c "# $SCRIPT_NAME" /jffs/scripts/dnsmasq.postconf)
				STARTUPLINECOUNTEX=$(grep -cx "cat $DNSCONF >> /etc/dnsmasq.conf # $SCRIPT_NAME" /jffs/scripts/dnsmasq.postconf)
				
				if [ "$STARTUPLINECOUNT" -gt 1 ] || { [ "$STARTUPLINECOUNTEX" -eq 0 ] && [ "$STARTUPLINECOUNT" -gt 0 ]; }; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/dnsmasq.postconf
				fi
				
				if [ "$STARTUPLINECOUNTEX" -eq 0 ]; then
					echo "cat $DNSCONF >> /etc/dnsmasq.conf # $SCRIPT_NAME" >> /jffs/scripts/dnsmasq.postconf
				fi
				
				if [ "$(grep -c "NextDNS" /jffs/scripts/dnsmasq.postconf)" -gt 0 ]; then
					sed -i '/exit 0/d' /jffs/scripts/dnsmasq.postconf
				fi
			else
				echo "#!/bin/sh" > /jffs/scripts/dnsmasq.postconf
				echo "" >> /jffs/scripts/dnsmasq.postconf
				echo "cat $DNSCONF >> /etc/dnsmasq.conf # $SCRIPT_NAME" >> /jffs/scripts/dnsmasq.postconf
				chmod 0755 /jffs/scripts/dnsmasq.postconf
			fi
		;;
		delete)
			if [ -f /jffs/scripts/dnsmasq.postconf ]; then
				STARTUPLINECOUNT=$(grep -c "# $SCRIPT_NAME" /jffs/scripts/dnsmasq.postconf)
				
				if [ "$STARTUPLINECOUNT" -gt 0 ]; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/dnsmasq.postconf
				fi
			fi
		;;
	esac
}

Auto_ServiceEvent(){
	case $1 in
		create)
			if [ -f /jffs/scripts/service-event ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME Guest Networks" /jffs/scripts/service-event)
				STARTUPLINECOUNTEX=$(grep -cx 'if echo "$2" | /bin/grep -q "'"$SCRIPT_NAME"'" || { \[ "$1" = "restart" \] && \[ "$2" = "wireless" \]; }; then { /jffs/scripts/'"$SCRIPT_NAME"' service_event "$@" & }; fi # '"$SCRIPT_NAME Guest Networks" /jffs/scripts/service-event)
				
				if [ "$STARTUPLINECOUNT" -gt 1 ] || { [ "$STARTUPLINECOUNTEX" -eq 0 ] && [ "$STARTUPLINECOUNT" -gt 0 ]; }; then
					sed -i -e '/# '"$SCRIPT_NAME"' Guest Networks/d' /jffs/scripts/service-event
				fi
				
				if [ "$STARTUPLINECOUNTEX" -eq 0 ]; then
					echo 'if echo "$2" | /bin/grep -q "'"$SCRIPT_NAME"'" || { [ "$1" = "restart" ] && [ "$2" = "wireless" ]; }; then { /jffs/scripts/'"$SCRIPT_NAME"' service_event "$@" & }; fi # '"$SCRIPT_NAME Guest Networks" >> /jffs/scripts/service-event
				fi
			else
				echo "#!/bin/sh" > /jffs/scripts/service-event
				echo "" >> /jffs/scripts/service-event
				echo 'if echo "$2" | /bin/grep -q "'"$SCRIPT_NAME"'" || { [ "$1" = "restart" ] && [ "$2" = "wireless" ]; }; then { /jffs/scripts/'"$SCRIPT_NAME"' service_event "$@" & }; fi # '"$SCRIPT_NAME Guest Networks" >> /jffs/scripts/service-event
				chmod 0755 /jffs/scripts/service-event
			fi
		;;
		delete)
			if [ -f /jffs/scripts/service-event ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME"' Guest Networks' /jffs/scripts/service-event)
				
				if [ "$STARTUPLINECOUNT" -gt 0 ]; then
					sed -i -e '/# '"$SCRIPT_NAME"' Guest Networks/d' /jffs/scripts/service-event
				fi
			fi
		;;
	esac
}

Auto_ServiceStart(){
	case $1 in
		create)
			if [ -f /jffs/scripts/services-start ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME" /jffs/scripts/services-start)
				STARTUPLINECOUNTEX=$(grep -cx "/jffs/scripts/$SCRIPT_NAME startup & # $SCRIPT_NAME" /jffs/scripts/services-start)
				
				if [ "$STARTUPLINECOUNT" -gt 1 ] || { [ "$STARTUPLINECOUNTEX" -eq 0 ] && [ "$STARTUPLINECOUNT" -gt 0 ]; }; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/services-start
				fi
				
				if [ "$STARTUPLINECOUNTEX" -eq 0 ]; then
					echo "/jffs/scripts/$SCRIPT_NAME startup & # $SCRIPT_NAME" >> /jffs/scripts/services-start
				fi
			else
				echo "#!/bin/sh" > /jffs/scripts/services-start
				echo "" >> /jffs/scripts/services-start
				echo "/jffs/scripts/$SCRIPT_NAME startup & # $SCRIPT_NAME" >> /jffs/scripts/services-start
				chmod 0755 /jffs/scripts/services-start
			fi
		;;
		delete)
			if [ -f /jffs/scripts/services-start ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME" /jffs/scripts/services-start)
				
				if [ "$STARTUPLINECOUNT" -gt 0 ]; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/services-start
				fi
			fi
		;;
	esac
}

Auto_Startup(){
	case $1 in
		create)
			if [ -f /jffs/scripts/firewall-start ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME"' Guest Networks' /jffs/scripts/firewall-start)
				STARTUPLINECOUNTEX=$(grep -cx "/jffs/scripts/$SCRIPT_NAME runnow & # $SCRIPT_NAME Guest Networks" /jffs/scripts/firewall-start)
				
				if [ "$STARTUPLINECOUNT" -gt 1 ] || { [ "$STARTUPLINECOUNTEX" -eq 0 ] && [ "$STARTUPLINECOUNT" -gt 0 ]; }; then
					sed -i -e '/# '"$SCRIPT_NAME"' Guest Networks/d' /jffs/scripts/firewall-start
				fi
				
				if [ "$STARTUPLINECOUNTEX" -eq 0 ]; then
					echo "/jffs/scripts/$SCRIPT_NAME runnow & # $SCRIPT_NAME Guest Networks" >> /jffs/scripts/firewall-start
				fi
			else
				echo "#!/bin/sh" > /jffs/scripts/firewall-start
				echo "" >> /jffs/scripts/firewall-start
				echo "/jffs/scripts/$SCRIPT_NAME runnow & # $SCRIPT_NAME Guest Networks" >> /jffs/scripts/firewall-start
				chmod 0755 /jffs/scripts/firewall-start
			fi
		;;
		delete)
			if [ -f /jffs/scripts/firewall-start ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME"' Guest Networks' /jffs/scripts/firewall-start)
				
				if [ "$STARTUPLINECOUNT" -gt 0 ]; then
					sed -i -e '/# '"$SCRIPT_NAME"' Guest Networks/d' /jffs/scripts/firewall-start
				fi
			fi
		;;
	esac
}

Auto_OpenVPNEvent(){
	case $1 in
		create)
			if [ -f /jffs/scripts/openvpn-event ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME" /jffs/scripts/openvpn-event)
				STARTUPLINECOUNTEX=$(grep -cx "/jffs/scripts/$SCRIPT_NAME openvpn "'$1 $script_type & # '"$SCRIPT_NAME" /jffs/scripts/openvpn-event)
				
				if [ "$STARTUPLINECOUNT" -gt 1 ] || { [ "$STARTUPLINECOUNTEX" -eq 0 ] && [ "$STARTUPLINECOUNT" -gt 0 ]; }; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/openvpn-event
				fi
				
				if [ "$STARTUPLINECOUNTEX" -eq 0 ]; then
					sed -i '2 i /jffs/scripts/'"$SCRIPT_NAME"' openvpn $1 $script_type & # '"$SCRIPT_NAME" /jffs/scripts/openvpn-event
				fi
			else
				echo "#!/bin/sh" > /jffs/scripts/openvpn-event
				echo "" >> /jffs/scripts/openvpn-event
				echo "/jffs/scripts/$SCRIPT_NAME openvpn "'$1 $script_type & # '"$SCRIPT_NAME" >> /jffs/scripts/openvpn-event
				chmod 0755 /jffs/scripts/openvpn-event
			fi
		;;
		delete)
			if [ -f /jffs/scripts/openvpn-event ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME" /jffs/scripts/openvpn-event)
				
				if [ "$STARTUPLINECOUNT" -gt 0 ]; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/openvpn-event
				fi
			fi
		;;
	esac
}

Auto_Cron(){
	case $1 in
		create)
			STARTUPLINECOUNT=$(cru l | grep -c "$SCRIPT_NAME")
			
			if [ "$STARTUPLINECOUNT" -eq 0 ]; then
				cru a "$SCRIPT_NAME" "*/10 * * * * /jffs/scripts/$SCRIPT_NAME check"
			fi
		;;
		delete)
			STARTUPLINECOUNT=$(cru l | grep -c "$SCRIPT_NAME")
			
			if [ "$STARTUPLINECOUNT" -gt 0 ]; then
				cru d "$SCRIPT_NAME"
			fi
		;;
	esac
}

Avahi_Conf(){
	case $1 in
		create)
			if [ -f /jffs/scripts/avahi-daemon.postconf ]; then
				STARTUPLINECOUNT=$(grep -c "$SCRIPT_NAME" /jffs/scripts/avahi-daemon.postconf)
				
				if [ "$STARTUPLINECOUNT" -eq 0 ]; then
					{
					echo 'echo "" >> "$1"'
					echo 'echo "[reflector]" >> "$1" # '"$SCRIPT_NAME"
					echo 'echo "enable-reflector=yes" >> "$1" # '"$SCRIPT_NAME"
					echo "sed -i '/^\[Server\]/a cache-entries-max=0' "'"$1" # '"$SCRIPT_NAME"
					} >> /jffs/scripts/avahi-daemon.postconf
					service restart_mdns >/dev/null 2>&1
				fi
			else
				{
				echo '#!/bin/sh'
				echo 'echo "" >> "$1"'
				echo 'echo "[reflector]" >> "$1" # '"$SCRIPT_NAME"
				echo 'echo "enable-reflector=yes" >> "$1" # '"$SCRIPT_NAME"
				echo "sed -i '/^\[Server\]/a cache-entries-max=0' "'"$1" # '"$SCRIPT_NAME"
				} > /jffs/scripts/avahi-daemon.postconf
				chmod 0755 /jffs/scripts/avahi-daemon.postconf
				service restart_mdns >/dev/null 2>&1
			fi
		;;
		delete)
			if [ -f /jffs/scripts/avahi-daemon.postconf ]; then
				STARTUPLINECOUNT=$(grep -c "$SCRIPT_NAME" /jffs/scripts/avahi-daemon.postconf)
				
				if [ "$STARTUPLINECOUNT" -gt 0 ]; then
					sed -i -e '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/avahi-daemon.postconf
					service restart_mdns >/dev/null 2>&1
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

Firmware_Version_WebUI(){
	if nvram get rc_support | grep -qF "am_addons"; then
		return 0
	else
		return 1
	fi
}

### Code for these functions inspired by https://github.com/Adamm00 - credit to @Adamm ###
Check_Lock(){
	if [ -f "/tmp/$SCRIPT_NAME.lock" ]; then
		ageoflock=$(($(date +%s) - $(date +%s -r /tmp/$SCRIPT_NAME.lock)))
		if [ "$ageoflock" -gt 600 ]; then
			Print_Output true "Stale lock file found (>600 seconds old) - purging lock" "$ERR"
			kill "$(sed -n '1p' /tmp/$SCRIPT_NAME.lock)" >/dev/null 2>&1
			Clear_Lock
			echo "$$" > "/tmp/$SCRIPT_NAME.lock"
			return 0
		else
			Print_Output true "Lock file found (age: $ageoflock seconds) - stopping to prevent duplicate runs" "$ERR"
			if [ -z "$1" ]; then
				exit 1
			else
				return 1
			fi
		fi
	else
		echo "$$" > "/tmp/$SCRIPT_NAME.lock"
		return 0
	fi
}

Clear_Lock(){
	rm -f "/tmp/$SCRIPT_NAME.lock" 2>/dev/null
	return 0
}
############################################################################

Set_Version_Custom_Settings(){
	SETTINGSFILE="/jffs/addons/custom_settings.txt"
	case "$1" in
		local)
			if [ -f "$SETTINGSFILE" ]; then
				if [ "$(grep -c "yazfi_version_local" $SETTINGSFILE)" -gt 0 ]; then
					if [ "$SCRIPT_VERSION" != "$(grep "yazfi_version_local" /jffs/addons/custom_settings.txt | cut -f2 -d' ')" ]; then
						sed -i "s/yazfi_version_local.*/yazfi_version_local $2/" "$SETTINGSFILE"
					fi
				else
					echo "yazfi_version_local $2" >> "$SETTINGSFILE"
				fi
			else
				echo "yazfi_version_local $2" >> "$SETTINGSFILE"
			fi
		;;
		server)
			if [ -f "$SETTINGSFILE" ]; then
				if [ "$(grep -c "yazfi_version_server" $SETTINGSFILE)" -gt 0 ]; then
					if [ "$2" != "$(grep "yazfi_version_server" /jffs/addons/custom_settings.txt | cut -f2 -d' ')" ]; then
						sed -i "s/yazfi_version_server.*/yazfi_version_server $2/" "$SETTINGSFILE"
					fi
				else
					echo "yazfi_version_server $2" >> "$SETTINGSFILE"
				fi
			else
				echo "yazfi_version_server $2" >> "$SETTINGSFILE"
			fi
		;;
	esac
}

Update_Check(){
	echo 'var updatestatus = "InProgress";' > "$SCRIPT_WEB_DIR/detect_update.js"
	doupdate="false"
	localver=$(grep "SCRIPT_VERSION=" "/jffs/scripts/$SCRIPT_NAME" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
	/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.sh" | grep -qF "jackyaz" || { Print_Output true "404 error detected - stopping update" "$ERR"; return 1; }
	serverver=$(/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.sh" | grep "SCRIPT_VERSION=" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
	if [ "$localver" != "$serverver" ]; then
		doupdate="version"
		Set_Version_Custom_Settings server "$serverver"
		echo 'var updatestatus = "'"$serverver"'";'  > "$SCRIPT_WEB_DIR/detect_update.js"
	else
		localmd5="$(md5sum "/jffs/scripts/$SCRIPT_NAME" | awk '{print $1}')"
		remotemd5="$(curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.sh" | md5sum | awk '{print $1}')"
		if [ "$localmd5" != "$remotemd5" ]; then
			doupdate="md5"
			Set_Version_Custom_Settings server "$serverver-hotfix"
			echo 'var updatestatus = "'"$serverver-hotfix"'";'  > "$SCRIPT_WEB_DIR/detect_update.js"
		fi
	fi
	if [ "$doupdate" = "false" ]; then
		echo 'var updatestatus = "None";'  > "$SCRIPT_WEB_DIR/detect_update.js"
	fi
	echo "$doupdate,$localver,$serverver"
}

Update_Version(){
	if [ -z "$1" ]; then
		updatecheckresult="$(Update_Check)"
		isupdate="$(echo "$updatecheckresult" | cut -f1 -d',')"
		localver="$(echo "$updatecheckresult" | cut -f2 -d',')"
		serverver="$(echo "$updatecheckresult" | cut -f3 -d',')"
		
		if [ "$isupdate" = "version" ]; then
			Print_Output true "New version of $SCRIPT_NAME available - $serverver" "$PASS"
		elif [ "$isupdate" = "md5" ]; then
			Print_Output true "MD5 hash of $SCRIPT_NAME does not match - hotfix available - $serverver" "$PASS"
		fi
		
		if [ "$isupdate" != "false" ]; then
			printf "\\n${BOLD}Do you want to continue with the update? (y/n)${CLEARFORMAT}  "
			read -r confirm
			case "$confirm" in
				y|Y)
					if Firmware_Version_WebUI ; then
						Update_File shared-jy.tar.gz
						Update_File YazFi_www.asp
					else
						Print_Output true "WebUI is only supported on firmware versions with addon support" "$WARN"
					fi
					
					/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.sh" -o "/jffs/scripts/$SCRIPT_NAME" && Print_Output true "$SCRIPT_NAME successfully updated - restarting firewall to apply update"
					chmod 0755 "/jffs/scripts/$SCRIPT_NAME"
					Set_Version_Custom_Settings local "$serverver"
					Set_Version_Custom_Settings server "$serverver"
					Clear_Lock
					service restart_firewall >/dev/null 2>&1
					PressEnter
					exec "$0"
					exit 0
				;;
				*)
					printf "\\n"
					Clear_Lock
					return 1
				;;
			esac
		else
			Print_Output true "No updates available - latest is $localver" "$WARN"
			Clear_Lock
		fi
	fi
	
	if [ "$1" = "force" ]; then
		serverver=$(/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.sh" | grep "SCRIPT_VERSION=" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
		Print_Output true "Downloading latest version ($serverver) of $SCRIPT_NAME" "$PASS"
		if Firmware_Version_WebUI ; then
			Update_File shared-jy.tar.gz
			Update_File YazFi_www.asp
		else
			Print_Output true "WebUI is only supported on firmware versions with addon support" "$WARN"
		fi
		/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.sh" -o "/jffs/scripts/$SCRIPT_NAME" && Print_Output true "$SCRIPT_NAME successfully updated - restarting firewall to apply update"
		chmod 0755 "/jffs/scripts/$SCRIPT_NAME"
		Set_Version_Custom_Settings local "$serverver"
		Set_Version_Custom_Settings server "$serverver"
		Clear_Lock
		service restart_firewall >/dev/null 2>&1
		if [ -z "$2" ]; then
			PressEnter
			exec "$0"
		elif [ "$2" = "unattended" ]; then
			exec "$0" postupdate
		fi
		exit 0
	fi
}

Update_File(){
	if [ "$1" = "YazFi_www.asp" ]; then
		tmpfile="/tmp/$1"
		Download_File "$SCRIPT_REPO/$1" "$tmpfile"
		if ! diff -q "$tmpfile" "$SCRIPT_DIR/$1" >/dev/null 2>&1; then
			if [ -f "$SCRIPT_DIR/$1" ]; then
				Get_WebUI_Page "$SCRIPT_DIR/$1"
				sed -i "\\~$MyPage~d" /tmp/menuTree.js
				rm -f "$SCRIPT_WEBPAGE_DIR/$MyPage" 2>/dev/null
			fi
			Download_File "$SCRIPT_REPO/$1" "$SCRIPT_DIR/$1"
			Print_Output true "New version of $1 downloaded" "$PASS"
			Mount_WebUI
		fi
		rm -f "$tmpfile"
	elif [ "$1" = "shared-jy.tar.gz" ]; then
		if [ ! -f "$SHARED_DIR/$1.md5" ]; then
			Download_File "$SHARED_REPO/$1" "$SHARED_DIR/$1"
			Download_File "$SHARED_REPO/$1.md5" "$SHARED_DIR/$1.md5"
			tar -xzf "$SHARED_DIR/$1" -C "$SHARED_DIR"
			rm -f "$SHARED_DIR/$1"
			Print_Output true "New version of $1 downloaded" "$PASS"
		else
			localmd5="$(cat "$SHARED_DIR/$1.md5")"
			remotemd5="$(curl -fsL --retry 3 "$SHARED_REPO/$1.md5")"
			if [ "$localmd5" != "$remotemd5" ]; then
				Download_File "$SHARED_REPO/$1" "$SHARED_DIR/$1"
				Download_File "$SHARED_REPO/$1.md5" "$SHARED_DIR/$1.md5"
				tar -xzf "$SHARED_DIR/$1" -C "$SHARED_DIR"
				rm -f "$SHARED_DIR/$1"
				Print_Output true "New version of $1 downloaded" "$PASS"
			fi
		fi
	else
		return 1
	fi
}

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
	elif [ "$1" = "$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".").$(nvram get lan_ipaddr | cut -f4 -d".")" ]; then
		return 0
	else
		return 1
	fi
}

Validate_Enabled_IFACE(){
	IFACE_TEST="$(nvram get "${1}_bss_enabled")"
	if ! Validate_Number "" "$IFACE_TEST" silent; then IFACE_TEST=0; fi
	if [ "$IFACE_TEST" -eq 0 ]; then
		if [ -z "$2" ]; then
			Print_Output false "$1 - Interface not enabled/configured in Web GUI (Guest Network menu)" "$ERR"
		fi
		return 1
	else
		return 0
	fi
}

Validate_Exists_IFACE(){
	validiface=""
	for IFACE_EXIST in $IFACELIST; do
		if [ "$1" = "$IFACE_EXIST" ]; then
			validiface="true"
		fi
	done
	
	if [ "$validiface" = "true" ]; then
		return 0
	else
		if [ -z "$2" ]; then
			Print_Output false "$1 - Interface not supported on this router" "$ERR"
		fi
		return 1
	fi
}

Validate_IP(){
	if expr "$2" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
		for i in 1 2 3 4; do
			if [ "$(echo "$2" | cut -d. -f$i)" -gt 255 ]; then
				Print_Output false "$1 - Octet $i ($(echo "$2" | cut -d. -f$i)) - is invalid, must be less than 255" "$ERR"
				return 1
			fi
		done
		
		if [ "$3" != "DNS" ]; then
			if IP_Local "$2"; then
				return 0
			else
				Print_Output false "$1 - $2 - Non-local IP address block used" "$ERR"
				return 1
			fi
		else
			return 0
		fi
	else
		Print_Output false "$1 - $2 - is not a valid IPv4 address, valid format is 1.2.3.4" "$ERR"
		return 1
	fi
}

Validate_Number(){
	if [ "$2" -eq "$2" ] 2>/dev/null; then
		return 0
	else
		formatted="$(echo "$1" | sed -e 's/|/ /g')"
		if [ -z "$3" ]; then
			Print_Output false "$formatted - $2 is not a number" "$ERR"
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
		Print_Output false "$1 - $2 to $3 - both numbers must be between 2 and 254, $2 must be less than $3" "$ERR"
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
		Print_Output false "$1 - $2 - must be between 1 and 5" "$ERR"
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
			Print_Output false "$1 - $2 - must be either true or false" "$ERR"
			return 1
		;;
	esac
}

Validate_String(){
		if expr "$1" : '[a-zA-Z0-9][a-zA-Z0-9]*$' >/dev/null; then
			return 0
		else
			Print_Output false "String contains non-alphanumeric characters, these will be removed" "$ERR"
			return 1
		fi
}

Conf_FromSettings(){
	SETTINGSFILE="/jffs/addons/custom_settings.txt"
	TMPFILE="/tmp/yazfi_settings.txt"
	if [ -f "$SETTINGSFILE" ]; then
		if [ "$(grep "yazfi_" $SETTINGSFILE | grep -v "version" -c)" -gt 0 ]; then
			Print_Output true "Updated settings from WebUI found, merging into $SCRIPT_CONF" "$PASS"
			cp -a "$SCRIPT_CONF" "$SCRIPT_CONF.bak"
			grep "yazfi_" "$SETTINGSFILE" | grep -v "version" > "$TMPFILE"
			sed -i "s/yazfi_//g;s/ /=/g" "$TMPFILE"
			while IFS='' read -r line || [ -n "$line" ]; do
				SETTINGNAME="$(echo "$line" | cut -f1 -d'=' | awk 'BEGIN{FS="_"}{ print $1 "_" toupper($2) }')"
				SETTINGVALUE="$(echo "$line" | cut -f2 -d'=')"
				sed -i "s/$SETTINGNAME=.*/$SETTINGNAME=$SETTINGVALUE/" "$SCRIPT_CONF"
			done < "$TMPFILE"
			grep 'yazfi_version' "$SETTINGSFILE" > "$TMPFILE"
			sed -i "\\~yazfi_~d" "$SETTINGSFILE"
			mv "$SETTINGSFILE" "$SETTINGSFILE.bak"
			cat "$SETTINGSFILE.bak" "$TMPFILE" > "$SETTINGSFILE"
			rm -f "$TMPFILE"
			rm -f "$SETTINGSFILE.bak"
			Print_Output true "Merge of updated settings from WebUI completed successfully" "$PASS"
		else
			Print_Output false "No updated settings from WebUI found, no merge into $SCRIPT_CONF necessary" "$PASS"
		fi
	fi
}

Conf_FixBlanks(){
	if ! Conf_Exists; then
		Conf_Download "$SCRIPT_CONF"
		Clear_Lock
		return 1
	fi
	
	cp -a "$SCRIPT_CONF" "$SCRIPT_CONF.bak"
	
	for IFACEBLANK in $IFACELIST_FULL; do
		IFACETMPBLANK="$(Get_Iface_Var "$IFACEBLANK")"
		IPADDRTMPBLANK=""
		
		if [ -z "$(eval echo '$'"${IFACETMPBLANK}_IPADDR")" ]; then
			IPADDRTMPBLANK="192.168.0"
			
			COUNTER=0
			until [ "$(grep -o "$IPADDRTMPBLANK" $SCRIPT_CONF | wc -l)" -eq 0 ] && [ "$(ifconfig -a | grep -o "$IPADDRTMPBLANK" | wc -l )" -eq 0 ]; do
				IPADDRTMPBLANK="192.168.$COUNTER"
				COUNTER=$((COUNTER + 1))
			done
			
			sed -i -e "s/${IFACETMPBLANK}_IPADDR=/${IFACETMPBLANK}_IPADDR=${IPADDRTMPBLANK}.0/" "$SCRIPT_CONF"
			Print_Output false "${IFACETMPBLANK}_IPADDR is blank, setting to next available subnet" "$WARN"
		fi
		
		if [ -z "$(eval echo '$'"${IFACETMPBLANK}_DHCPSTART")" ]; then
			sed -i -e "s/${IFACETMPBLANK}_DHCPSTART=/${IFACETMPBLANK}_DHCPSTART=2/" "$SCRIPT_CONF"
			Print_Output false "${IFACETMPBLANK}_DHCPSTART is blank, setting to 2" "$WARN"
		fi
		
		if [ -z "$(eval echo '$'"${IFACETMPBLANK}_DHCPEND")" ]; then
			sed -i -e "s/${IFACETMPBLANK}_DHCPEND=/${IFACETMPBLANK}_DHCPEND=254/" "$SCRIPT_CONF"
			Print_Output false "${IFACETMPBLANK}_DHCPEND is blank, setting to 254" "$WARN"
		fi
		
		if [ -z "$(eval echo '$'"${IFACETMPBLANK}_DNS1")" ]; then
			if [ -n "$(eval echo '$'"${IFACETMPBLANK}_IPADDR")" ]; then
				sed -i -e "s/${IFACETMPBLANK}_DNS1=/${IFACETMPBLANK}_DNS1=$(eval echo '$'"${IFACETMPBLANK}_IPADDR" | cut -f1-3 -d".").$(nvram get lan_ipaddr | cut -f4 -d".")/" "$SCRIPT_CONF"
				Print_Output false "${IFACETMPBLANK}_DNS1 is blank, setting to $(eval echo '$'"${IFACETMPBLANK}_IPADDR" | cut -f1-3 -d".").$(nvram get lan_ipaddr | cut -f4 -d".")" "$WARN"
			else
				sed -i -e "s/${IFACETMPBLANK}_DNS1=/${IFACETMPBLANK}_DNS1=$IPADDRTMPBLANK.$(nvram get lan_ipaddr | cut -f4 -d".")/" "$SCRIPT_CONF"
				Print_Output false "${IFACETMPBLANK}_DNS1 is blank, setting to $IPADDRTMPBLANK.$(nvram get lan_ipaddr | cut -f4 -d".")" "$WARN"
			fi
		fi
		
		if [ -z "$(eval echo '$'"${IFACETMPBLANK}_DNS2")" ]; then
			if [ -n "$(eval echo '$'"${IFACETMPBLANK}_IPADDR")" ]; then
				sed -i -e "s/${IFACETMPBLANK}_DNS2=/${IFACETMPBLANK}_DNS2=$(eval echo '$'"${IFACETMPBLANK}_IPADDR" | cut -f1-3 -d".").$(nvram get lan_ipaddr | cut -f4 -d".")/" "$SCRIPT_CONF"
				Print_Output false "${IFACETMPBLANK}_DNS2 is blank, setting to $(eval echo '$'"${IFACETMPBLANK}_IPADDR" | cut -f1-3 -d".").$(nvram get lan_ipaddr | cut -f4 -d".")" "$WARN"
			else
				sed -i -e "s/${IFACETMPBLANK}_DNS2=/${IFACETMPBLANK}_DNS2=$IPADDRTMPBLANK.$(nvram get lan_ipaddr | cut -f4 -d".")/" "$SCRIPT_CONF"
				Print_Output false "${IFACETMPBLANK}_DNS2 is blank, setting to $IPADDRTMPBLANK.$(nvram get lan_ipaddr | cut -f4 -d".")" "$WARN"
			fi
		fi
		
		if [ -z "$(eval echo '$'"${IFACETMPBLANK}_FORCEDNS")" ]; then
			sed -i -e "s/${IFACETMPBLANK}_FORCEDNS=/${IFACETMPBLANK}_FORCEDNS=false/" "$SCRIPT_CONF"
			Print_Output false "${IFACETMPBLANK}_FORCEDNS is blank, setting to false" "$WARN"
		fi
		
		if [ -z "$(eval echo '$'"${IFACETMPBLANK}_REDIRECTALLTOVPN")" ]; then
			REDIRECTTMP="false"
			sed -i -e "s/${IFACETMPBLANK}_REDIRECTALLTOVPN=/${IFACETMPBLANK}_REDIRECTALLTOVPN=false/" "$SCRIPT_CONF"
			Print_Output false "${IFACETMPBLANK}_REDIRECTALLTOVPN is blank, setting to false" "$WARN"
		fi
		
		if [ -z "$(eval echo '$'"${IFACETMPBLANK}_VPNCLIENTNUMBER")" ]; then
			sed -i -e "s/${IFACETMPBLANK}_VPNCLIENTNUMBER=/${IFACETMPBLANK}_VPNCLIENTNUMBER=1/" "$SCRIPT_CONF"
			Print_Output false "${IFACETMPBLANK}_VPNCLIENTNUMBER is blank, setting to 1" "$WARN"
		fi
		
		if [ -z "$(eval echo '$'"${IFACETMPBLANK}_TWOWAYTOGUEST")" ]; then
			sed -i -e "s/${IFACETMPBLANK}_TWOWAYTOGUEST=/${IFACETMPBLANK}_TWOWAYTOGUEST=false/" "$SCRIPT_CONF"
			Print_Output false "${IFACETMPBLANK}_TWOWAYTOGUEST is blank, setting to false" "$WARN"
		fi
		
		if [ -z "$(eval echo '$'"${IFACETMPBLANK}_ONEWAYTOGUEST")" ]; then
			sed -i -e "s/${IFACETMPBLANK}_ONEWAYTOGUEST=/${IFACETMPBLANK}_ONEWAYTOGUEST=false/" "$SCRIPT_CONF"
			Print_Output false "${IFACETMPBLANK}_ONEWAYTOGUEST is blank, setting to false" "$WARN"
		fi
		
		if [ -z "$(eval echo '$'"${IFACETMPBLANK}_CLIENTISOLATION")" ]; then
			sed -i -e "s/${IFACETMPBLANK}_CLIENTISOLATION=/${IFACETMPBLANK}_CLIENTISOLATION=false/" "$SCRIPT_CONF"
			Print_Output false "${IFACETMPBLANK}_CLIENTISOLATION is blank, setting to false" "$WARN"
		fi
	done
}

Conf_Validate(){
	CONF_VALIDATED="true"
	NETWORKS_ENABLED="false"
	
	Conf_FixBlanks
	
	for IFACE in $IFACELIST_FULL; do
		IFACETMP="$(Get_Iface_Var "$IFACE")"
		IPADDRTMP=""
		ENABLEDTMP=""
		REDIRECTTMP=""
		IFACE_PASS="true"
		
		if [ -z "$(eval echo '$'"${IFACETMP}_ENABLED")" ]; then
			ENABLEDTMP="false"
			sed -i -e "s/${IFACETMP}_ENABLED=/${IFACETMP}_ENABLED=false/" "$SCRIPT_CONF"
			Print_Output false "${IFACETMP}_ENABLED is blank, setting to false" "$WARN"
		elif ! Validate_TrueFalse "${IFACETMP}_ENABLED" "$(eval echo '$'"${IFACETMP}_ENABLED")"; then
			ENABLEDTMP="false"
			IFACE_PASS="false"
		else
			ENABLEDTMP="$(eval echo '$'"${IFACETMP}_ENABLED")"
		fi
		
		if ! Validate_Exists_IFACE "$IFACE" silent && [ "$ENABLEDTMP" = "true" ]; then
			IFACE_PASS="false"
			Print_Output false "$IFACE - Interface not supported on this router" "$ERR"
		else
			if [ "$ENABLEDTMP" = "true" ]; then
				NETWORKS_ENABLED="true"
				
				if ! Validate_Enabled_IFACE "$IFACE"; then
					IFACE_PASS="false"
				fi
				
				if [ "$(eval echo '$'"${IFACETMP}_ENABLED")" = "true" ]; then
					if ! Validate_IP "${IFACETMP}_IPADDR" "$(eval echo '$'"${IFACETMP}_IPADDR")"; then
						IFACE_PASS="false"
					else
						IPADDRTMP="$(eval echo '$'"${IFACETMP}_IPADDR" | cut -f1-3 -d".")"
						
						if [ "$(eval echo '$'"${IFACETMP}_IPADDR" | cut -f4 -d".")" -ne 0 ]; then
							sed -i -e "s/${IFACETMP}_IPADDR=$(eval echo '$'"${IFACETMP}_IPADDR")/${IFACETMP}_IPADDR=$IPADDRTMP.0/" "$SCRIPT_CONF"
							Print_Output false "${IFACETMP}_IPADDR setting last octet to 0" "$WARN"
						fi
						
						if [ "$(ifconfig -a | grep -o "inet addr:$IPADDRTMP.$(nvram get lan_ipaddr | cut -f4 -d'.')"  | sed 's/inet addr://' | wc -l )" -gt 1 ]; then
							Print_Output false "${IFACETMP}_IPADDR ($(eval echo '$'"${IFACETMP}_IPADDR")) has been used for another interface already" "$ERR"
							IFACE_PASS="false"
						fi
					fi
					
					if [ -n "$(eval echo '$'"${IFACETMP}_DHCPSTART")" ] && [ -n "$(eval echo '$'"${IFACETMP}_DHCPEND")" ]; then
						if ! Validate_DHCP "${IFACETMP}_DHCPSTART|and|${IFACETMP}_DHCPEND" "$(eval echo '$'"${IFACETMP}_DHCPSTART")" "$(eval echo '$'"${IFACETMP}_DHCPEND")"; then
						IFACE_PASS="false"
						fi
					fi
					
					if ! Validate_TrueFalse "${IFACETMP}_FORCEDNS" "$(eval echo '$'"${IFACETMP}_FORCEDNS")"; then
						IFACE_PASS="false"
					else
						if [ "$(eval echo '$'"${IFACETMP}_FORCEDNS")" = "true" ]; then
							Print_Output false "$IFACE has FORCEDNS enabled, setting DNS2 to match DNS1..." "$WARN"
							sed -i -e "s/${IFACETMP}_DNS2=.*/${IFACETMP}_DNS2=$(eval echo '$'"${IFACETMP}_DNS1")/" "$SCRIPT_CONF"
						fi
					fi
					
					if ! Validate_IP "${IFACETMP}_DNS1" "$(eval echo '$'"${IFACETMP}_DNS1")" "DNS"; then
						IFACE_PASS="false"
					fi
					
					if ! Validate_IP "${IFACETMP}_DNS2" "$(eval echo '$'"${IFACETMP}_DNS2")" "DNS"; then
						IFACE_PASS="false"
					fi
					
					if ! Validate_TrueFalse "${IFACETMP}_REDIRECTALLTOVPN" "$(eval echo '$'"${IFACETMP}_REDIRECTALLTOVPN")"; then
						REDIRECTTMP="false"
						IFACE_PASS="false"
					else
						REDIRECTTMP="$(eval echo '$'"${IFACETMP}_REDIRECTALLTOVPN")"
					fi
					
					if [ "$REDIRECTTMP" = "true" ]; then
						if ! Validate_VPNClientNo "${IFACETMP}_VPNCLIENTNUMBER" "$(eval echo '$'"${IFACETMP}_VPNCLIENTNUMBER")"; then
							IFACE_PASS="false"
						else
							if [ "$(nvram get vpn_client"$(eval echo '$'"${IFACETMP}_VPNCLIENTNUMBER")"_rgw)" -ne 2 ]; then
								Print_Output false "VPN Client $(eval echo '$'"${IFACETMP}_VPNCLIENTNUMBER") is not configured for Policy Routing, enabling it..." "$WARN"
								nvram set vpn_client"$(eval echo '$'"${IFACETMP}_VPNCLIENTNUMBER")"_rgw=2
								nvram commit
							fi
						fi
					fi
					
					if ! Validate_TrueFalse "${IFACETMP}_TWOWAYTOGUEST" "$(eval echo '$'"${IFACETMP}_TWOWAYTOGUEST")"; then
						IFACE_PASS="false"
					fi
					
					if ! Validate_TrueFalse "${IFACETMP}_ONEWAYTOGUEST" "$(eval echo '$'"${IFACETMP}_ONEWAYTOGUEST")"; then
						IFACE_PASS="false"
					fi
					
					if [ "$(eval echo '$'"${IFACETMP}_ONEWAYTOGUEST")" = "true" ] && [ "$(eval echo '$'"${IFACETMP}_TWOWAYTOGUEST")" = "true" ]; then
						Print_Output false "$(eval echo '$'"${IFACETMP}_ONEWAYTOGUEST") & $(eval echo '$'"${IFACETMP}_TWOWAYTOGUEST") cannot both be true" "$ERR"
						IFACE_PASS="false"
					fi
					
					if ! Validate_TrueFalse "${IFACETMP}_CLIENTISOLATION" "$(eval echo '$'"${IFACETMP}_CLIENTISOLATION")"; then
						IFACE_PASS="false"
					fi
					
					if [ "$(Firmware_Version_Check "$(nvram get buildno)")" -lt "$(Firmware_Version_Check 386.1)" ]; then
						if [ "$ROUTER_MODEL" = "RT-AX88U" ] || [ "$ROUTER_MODEL" = "RT-AX3000" ]; then
							sed -i -e "s/${IFACETMP}_CLIENTISOLATION=true/${IFACETMP}_CLIENTISOLATION=false/" "$SCRIPT_CONF"
						fi
					fi
					
					if [ "$IFACE_PASS" = "true" ]; then
						Print_Output false "$IFACE passed validation" "$PASS"
					fi
				fi
			fi
		fi
		
		if [ "$IFACE_PASS" = "false" ]; then
			IFACELIST="$(echo "$IFACELIST" | sed 's/'"$IFACE"'//;s/  / /')"
			Print_Output false "$IFACE failed validation, removing from list" "$CRIT"
		fi
	done
	
	if [ "$NETWORKS_ENABLED" = "false" ]; then
		Print_Output true "No $SCRIPT_NAME guests are enabled in the configuration file!" "$CRIT"
	fi
	
	return 0
}

Create_Dirs(){
	if [ ! -d "$SCRIPT_DIR" ]; then
		mkdir -p "$SCRIPT_DIR"
	fi
	
	if [ ! -d "$USER_SCRIPT_DIR" ]; then
		mkdir -p "$USER_SCRIPT_DIR"
	fi
	
	if [ ! -d "$SCRIPT_WEBPAGE_DIR" ]; then
		mkdir -p "$SCRIPT_WEBPAGE_DIR"
	fi
		
	if [ ! -d "$SCRIPT_WEB_DIR" ]; then
		mkdir -p "$SCRIPT_WEB_DIR"
	fi
	
	if [ ! -d "$SHARED_DIR" ]; then
		mkdir -p "$SHARED_DIR"
	fi
}

Create_Symlinks(){
	rm -f "$SCRIPT_WEB_DIR/"* 2>/dev/null
	
	ln -s "$SCRIPT_DIR/config"  "$SCRIPT_WEB_DIR/config.htm" 2>/dev/null
	ln -s "$SCRIPT_DIR/.connectedclients" "$SCRIPT_WEB_DIR/connectedclients.htm" 2>/dev/null
	
	if [ ! -d "$SHARED_WEB_DIR" ]; then
		ln -s "$SHARED_DIR" "$SHARED_WEB_DIR" 2>/dev/null
	fi
}

Download_File(){
	/usr/sbin/curl -fsL --retry 3 "$1" -o "$2"
}

### function based on @dave14305's FlexQoS webconfigpage function ###
Get_WebUI_URL(){
	urlpage=""
	urlproto=""
	urldomain=""
	urlport=""

	urlpage="$(sed -nE "/$SCRIPT_NAME/ s/.*url\: \"(user[0-9]+\.asp)\".*/\1/p" /tmp/menuTree.js)"
	if [ "$(nvram get http_enable)" -eq 1 ]; then
		urlproto="https"
	else
		urlproto="http"
	fi
	if [ -n "$(nvram get lan_domain)" ]; then
		urldomain="$(nvram get lan_hostname).$(nvram get lan_domain)"
	else
		urldomain="$(nvram get lan_ipaddr)"
	fi
	if [ "$(nvram get ${urlproto}_lanport)" -eq 80 ] || [ "$(nvram get ${urlproto}_lanport)" -eq 443 ]; then
		urlport=""
	else
		urlport=":$(nvram get ${urlproto}_lanport)"
	fi

	if echo "$urlpage" | grep -qE "user[0-9]+\.asp"; then
		echo "${urlproto}://${urldomain}${urlport}/${urlpage}" | tr "A-Z" "a-z"
	else
		echo "WebUI page not found"
	fi
}
### ###

Get_WebUI_Page(){
	MyPage="none"
	for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
		page="/www/user/user$i.asp"
		if [ -f "$page" ] && [ "$(md5sum < "$1")" = "$(md5sum < "$page")" ]; then
			MyPage="user$i.asp"
			return
		elif [ "$MyPage" = "none" ] && [ ! -f "$page" ]; then
			MyPage="user$i.asp"
		fi
	done
}

### locking mechanism code credit to Martineau (@MartineauUK) ###
Mount_WebUI(){
	Print_Output true "Mounting WebUI tab for $SCRIPT_NAME" "$PASS"
	LOCKFILE=/tmp/addonwebui.lock
	FD=386
	eval exec "$FD>$LOCKFILE"
	flock -x "$FD"
	Get_WebUI_Page "$SCRIPT_DIR/YazFi_www.asp"
	if [ "$MyPage" = "none" ]; then
		Print_Output true "Unable to mount $SCRIPT_NAME WebUI page, exiting" "$CRIT"
		flock -u "$FD"
		return 1
	fi
	cp -f "$SCRIPT_DIR/YazFi_www.asp" "$SCRIPT_WEBPAGE_DIR/$MyPage"
	echo "$SCRIPT_NAME" > "$SCRIPT_WEBPAGE_DIR/$(echo $MyPage | cut -f1 -d'.').title"
	
	if [ "$(uname -o)" = "ASUSWRT-Merlin" ]; then
		if [ ! -f "/tmp/menuTree.js" ]; then
			cp -f "/www/require/modules/menuTree.js" "/tmp/"
		fi
		
		sed -i "\\~$MyPage~d" /tmp/menuTree.js
		
		sed -i "/url: \"Guest_network.asp\", tabName:/a {url: \"$MyPage\", tabName: \"$SCRIPT_NAME\"}," /tmp/menuTree.js
		
		umount /www/require/modules/menuTree.js 2>/dev/null
		mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js
	fi
	
	flock -u "$FD"
	Print_Output true "Mounted $SCRIPT_NAME WebUI page as $MyPage" "$PASS"
}

Conf_Download(){
	mkdir -p "/jffs/addons/$SCRIPT_NAME.d"
	/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME.config.example" -o "$1"
	chmod 0644 "$1"
	dos2unix "$1"
	sleep 1
	Clear_Lock
}

Conf_Exists(){
	if [ -d "/jffs/configs/$SCRIPT_NAME" ]; then
		mv "/jffs/configs/$SCRIPT_NAME/$SCRIPT_NAME.config" "/jffs/configs/$SCRIPT_NAME/config"
		mv "/jffs/configs/$SCRIPT_NAME/$SCRIPT_NAME.config.blank" "/jffs/configs/$SCRIPT_NAME/config.blank"
		mv "/jffs/configs/$SCRIPT_NAME/$SCRIPT_NAME.config.example" "/jffs/configs/$SCRIPT_NAME/config.example"
		mkdir -p "/jffs/addons/$SCRIPT_NAME.d"
		cp -a "/jffs/configs/$SCRIPT_NAME/"* "/jffs/addons/$SCRIPT_NAME.d/."
		rm -rf "/jffs/configs/$SCRIPT_NAME"
	fi
	
	if [ -f "$SCRIPT_CONF" ]; then
		dos2unix "$SCRIPT_CONF"
		chmod 0644 "$SCRIPT_CONF"
		if [ ! -f "$SCRIPT_CONF.bak" ]; then
			cp -a "$SCRIPT_CONF" "$SCRIPT_CONF.bak"
		fi
		sed -i -e 's/_LANACCESS/_TWOWAYTOGUEST/g' "$SCRIPT_CONF"
		if ! grep -q "_ONEWAYTOGUEST" "$SCRIPT_CONF" ; then
			for CONFIFACE in $IFACELIST_FULL ; do
				CONFIFACETMP="$(Get_Iface_Var "$CONFIFACE")"
				sed -i "/^${CONFIFACETMP}_TWOWAYTOGUEST=/a ${CONFIFACETMP}_ONEWAYTOGUEST=" "$SCRIPT_CONF"
			done
		fi
		sed -i -e 's/"//g' "$SCRIPT_CONF"
		. "$SCRIPT_CONF"
		return 0
	else
		return 1
	fi
}

Firewall_Chains(){
	FWRDSTART="$(iptables -nvL FORWARD --line | grep -E "all.*state RELATED,ESTABLISHED" | tail -1 | awk '{print $1}')"
	
	case $1 in
		create)
			for CHAIN in $CHAINS; do
				if ! iptables -n -L "$CHAIN" >/dev/null 2>&1; then
					iptables -N "$CHAIN"
					case $CHAIN in
						"$INPT")
							iptables -I INPUT -j "$CHAIN"
						;;
						"$FWRD")
							iptables -I FORWARD "$FWRDSTART" -j "$CHAIN"
						;;
						"$LGRJT")
							iptables -I "$LGRJT" -j REJECT
							
							if [ -f "$SCRIPT_DIR/.rejectlogging" ]; then
								iptables -I $LGRJT -j LOG --log-prefix "REJECT " --log-tcp-sequence --log-tcp-options --log-ip-options
							fi
						;;
						"$DNSFLTR_DOT")
							iptables -I FORWARD "$FWRDSTART" -p tcp -m tcp --dport 853 -j "$CHAIN"
						;;
					esac
				fi
			done
			for CHAIN in $NATCHAINS; do
				if ! iptables -t nat -n -L "$CHAIN" >/dev/null 2>&1; then
					iptables -t nat -N "$CHAIN"
					case $CHAIN in
						"$DNSFLTR")
							### DNSFilter rules - credit to @RMerlin for the original implementation in Asuswrt ###
							iptables -t nat -I PREROUTING -p udp -m udp --dport 53 -j "$CHAIN"
							iptables -t nat -I PREROUTING -p tcp -m tcp --dport 53 -j "$CHAIN"
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
						"$INPT")
							iptables -D INPUT -j "$CHAIN"
						;;
						"$FWRD")
							iptables -D FORWARD -j "$CHAIN"
						;;
						"$LGRJT")
							iptables -D "$LGRJT" -j REJECT
						;;
						"$DNSFLTR_DOT")
							iptables -D FORWARD -p tcp -m tcp --dport 853 -j "$CHAIN"
						;;
					esac
					
					iptables -F "$CHAIN"
					iptables -X "$CHAIN"
				fi
			done
			for CHAIN in $NATCHAINS; do
				if ! iptables -t nat -n -L "$CHAIN" >/dev/null 2>&1; then
					case $CHAIN in
						"$DNSFLTR")
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
		
		ebtables -t broute "$ACTION" BROUTING -p ipv4 -i "$IFACE" -j DROP
		ebtables -t broute "$ACTION" BROUTING -p ipv6 -i "$IFACE" -j DROP
		ebtables -t broute "$ACTION" BROUTING -p arp -i "$IFACE" -j DROP
		
		ebtables -t broute -D BROUTING -p IPv4 -i "$IFACE" --ip-dst "$LAN"/24 --ip-proto tcp -j DROP
		ebtables -t broute -D BROUTING -p IPv4 -i "$IFACE" --ip-dst "$LAN" --ip-proto icmp -j ACCEPT
		ebtables -t broute -D BROUTING -p IPv4 -i "$IFACE" --ip-dst "$LAN"/24 --ip-proto icmp -j DROP
		
		iptables "$ACTION" "$FWRD" -i "$IFACE" -j ACCEPT
		
		if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_TWOWAYTOGUEST")" = "false" ]; then
			iptables "$ACTION" "$FWRD" ! -i "$IFACE_WAN" -o "$IFACE" -j "$LGRJT"
			iptables "$ACTION" "$FWRD" -i "$IFACE" ! -o "$IFACE_WAN" -j "$LGRJT"
		else
			iptables -D "$FWRD" ! -i "$IFACE_WAN" -o "$IFACE" -j "$LGRJT"
			iptables -D "$FWRD" -i "$IFACE" ! -o "$IFACE_WAN" -j "$LGRJT"
		fi
		
		if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_ONEWAYTOGUEST")" = "true" ]; then
			iptables "$ACTION" "$FWRD" ! -i "$IFACE_WAN" -o "$IFACE" -j ACCEPT
			iptables "$ACTION" "$FWRD" -i "$IFACE" ! -o "$IFACE_WAN" -m state --state RELATED,ESTABLISHED -j ACCEPT
		else
			iptables -D "$FWRD" ! -i "$IFACE_WAN" -o "$IFACE" -j ACCEPT
			iptables -D "$FWRD" -i "$IFACE" ! -o "$IFACE_WAN" -m state --state RELATED,ESTABLISHED -j ACCEPT
		fi
		
		if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_TWOWAYTOGUEST")" = "false" ] && [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_ONEWAYTOGUEST")" = "true" ]; then
			iptables -D "$FWRD" ! -i "$IFACE_WAN" -o "$IFACE" -j "$LGRJT"
		fi
		
		iptables "$ACTION" "$INPT" -i "$IFACE" -j "$LGRJT"
		iptables "$ACTION" "$INPT" -i "$IFACE" -p icmp -j ACCEPT
		iptables "$ACTION" "$INPT" -i "$IFACE" -p udp -m multiport --dports 67,123 -j ACCEPT
		
		ENABLED_WINS="$(nvram get smbd_wins)"
		ENABLED_SAMBA="$(nvram get enable_samba)"
		if ! Validate_Number "" "$ENABLED_SAMBA" silent; then ENABLED_SAMBA=0; fi
		if ! Validate_Number "" "$ENABLED_WINS" silent; then ENABLED_WINS=0; fi
		
		if [ "$ENABLED_WINS" -eq 1 ] && [ "$ENABLED_SAMBA" -eq 1 ]; then
			iptables "$ACTION" "$INPT" -i "$IFACE" -p udp -m multiport --dports 137,138 -j ACCEPT
		else
			iptables -D "$INPT" -i "$IFACE" -p udp -m multiport --dports 137,138 -j ACCEPT
		fi
		
		if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_TWOWAYTOGUEST")" = "true" ] || [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_ONEWAYTOGUEST")" = "true" ]; then
			iptables "$ACTION" "$INPT" -i "$IFACE" -d 224.0.0.0/4 -j ACCEPT
		fi
		
		modprobe xt_comment
		iptables -t nat -D POSTROUTING -s "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_IPADDR" | cut -f1-3 -d".")".0/24 -d "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_IPADDR" | cut -f1-3 -d".")".0/24 -o "$IFACE" -m comment --comment "$(Get_Guest_Name_Old "$IFACE")" -j MASQUERADE
		iptables -t nat "$ACTION" POSTROUTING -s "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_IPADDR" | cut -f1-3 -d".")".0/24 -d "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_IPADDR" | cut -f1-3 -d".")".0/24 -o "$IFACE" -m comment --comment "$(Get_Guest_Name "$IFACE")" -j MASQUERADE
		
		ENABLED_NTPD=0
		if [ -f /jffs/scripts/nat-start ]; then
			if [ "$(grep -c '# ntpMerlin' /jffs/scripts/nat-start)" -gt 0 ]; then ENABLED_NTPD=1; fi
		fi
		
		if [ "$ENABLED_NTPD" -eq 1 ]; then
			iptables -t nat "$ACTION" PREROUTING -i "$IFACE" -p udp --dport 123 -j DNAT --to "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_IPADDR" | cut -f1-3 -d".")"."$(echo "$LAN" | cut -f4 -d'.')"
			iptables -t nat "$ACTION" PREROUTING -i "$IFACE" -p tcp --dport 123 -j DNAT --to "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_IPADDR" | cut -f1-3 -d".")"."$(echo "$LAN" | cut -f4 -d'.')"
			
			iptables "$ACTION" "$FWRD" -i "$IFACE" -p tcp --dport 123 -j REJECT
			iptables "$ACTION" "$FWRD" -i "$IFACE" -p udp --dport 123 -j REJECT
			ip6tables "$ACTION" FORWARD -i "$IFACE" -p tcp --dport 123 -j REJECT
			ip6tables "$ACTION" FORWARD -i "$IFACE" -p udp --dport 123 -j REJECT
			##
		else
			iptables -t nat -D PREROUTING -i "$IFACE" -p udp --dport 123 -j DNAT --to "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_IPADDR" | cut -f1-3 -d".")"."$(echo "$LAN" | cut -f4 -d'.')"
			iptables -t nat -D PREROUTING -i "$IFACE" -p tcp --dport 123 -j DNAT --to "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_IPADDR" | cut -f1-3 -d".")"."$(echo "$LAN" | cut -f4 -d'.')"
			iptables -D "$FWRD" -i "$IFACE" -p tcp --dport 123 -j REJECT
			iptables -D "$FWRD" -i "$IFACE" -p udp --dport 123 -j REJECT
			ip6tables -D FORWARD -i "$IFACE" -p tcp --dport 123 -j REJECT
			ip6tables -D FORWARD -i "$IFACE" -p udp --dport 123 -j REJECT
		fi
	done
}

Firewall_DNS(){
	ACTIONS=""
	IFACE="$2"
	
	case $1 in
		create)
			ACTIONS="-D -I"
		;;
		delete)
			ACTIONS="-D"
		;;
	esac
	
	for ACTION in $ACTIONS; do
		if IP_Local "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_DNS1")" || IP_Local "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_DNS2")"; then
			RULES=$(iptables -nvL "$INPT" --line-number | grep "$IFACE" | grep "pt:53" | awk '{print $1}' | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
			for RULENO in $RULES; do
				iptables -D "$INPT" "$RULENO"
			done
			
			RULES=$(iptables -nvL "$FWRD" --line-number | grep "$IFACE" | grep "pt:53" | awk '{print $1}' | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
			for RULENO in $RULES; do
				iptables -D "$FWRD" "$RULENO"
			done
			
			if IP_Router "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_DNS1")" "$IFACE" || IP_Router "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_DNS2")" "$IFACE"; then
				if ifconfig "br0:pixelserv-tls" | grep -q "inet addr:" >/dev/null 2>&1; then
					IP_PXLSRV=$(ifconfig br0:pixelserv-tls | grep "inet addr:" | cut -d: -f2 | awk '{print $1}')
					iptables "$ACTION" "$INPT" -i "$IFACE" -d "$IP_PXLSRV" -p tcp -m multiport --dports 80,443 -j ACCEPT
				else
					RULES=$(iptables -nvL "$INPT" --line-number | grep "$IFACE" | grep "multiport dports 80,443" | awk '{print $1}' | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
					for RULENO in $RULES; do
						iptables -D "$INPT" "$RULENO"
					done
				fi
				
				for PROTO in tcp udp; do
					iptables "$ACTION" "$INPT" -i "$IFACE" -p "$PROTO" --dport 53 -j ACCEPT
				done
			fi
			if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_DNS1")" != "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_DNS2")" ]; then
				if IP_Local "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_DNS1")" && ! IP_Router "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_DNS1")" "$IFACE"; then
					for PROTO in tcp udp; do
						iptables "$ACTION" "$FWRD" -i "$IFACE" -d "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_DNS1")" -p "$PROTO" --dport 53 -j ACCEPT
						iptables "$ACTION" "$FWRD" -o "$IFACE" -s "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_DNS1")" -p "$PROTO" --sport 53 -j ACCEPT
					done
				fi
				if IP_Local "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_DNS2")" && ! IP_Router "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_DNS2")" "$IFACE"; then
					for PROTO in tcp udp; do
						iptables "$ACTION" "$FWRD" -i "$IFACE" -d "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_DNS2")" -p "$PROTO" --dport 53 -j ACCEPT
						iptables "$ACTION" "$FWRD" -o "$IFACE" -s "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_DNS2")" -p "$PROTO" --sport 53 -j ACCEPT
					done
				fi
			else
				if ! IP_Router "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_DNS1")" "$IFACE"; then
					for PROTO in tcp udp; do
						iptables "$ACTION" "$FWRD" -i "$IFACE" -d "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_DNS1")" -p "$PROTO" --dport 53 -j ACCEPT
						iptables "$ACTION" "$FWRD" -o "$IFACE" -s "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_DNS1")" -p "$PROTO" --sport 53 -j ACCEPT
					done
				fi
			fi
		else
			RULES=$(iptables -nvL "$INPT" --line-number | grep "$IFACE" | grep "pt:53" | awk '{print $1}' | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
			for RULENO in $RULES; do
				iptables -D "$INPT" "$RULENO"
			done
			
			RULES=$(iptables -nvL "$FWRD" --line-number | grep "$IFACE" | grep "pt:53" | awk '{print $1}' | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
			for RULENO in $RULES; do
				iptables -D "$FWRD" "$RULENO"
			done
		fi
		
		### DNSFilter rules - credit to @RMerlin for the original implementation in Asuswrt ###
		if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_FORCEDNS")" = "true" ]; then
			RULES=$(iptables -t nat -nvL "$DNSFLTR" --line-number | grep "$IFACE" | awk '{print $1}' | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
			for RULENO in $RULES; do
				iptables -t nat -D "$DNSFLTR" "$RULENO"
			done
			
			RULES=$(iptables -nvL $DNSFLTR_DOT --line-number | grep "$IFACE" | awk '{print $1}' | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
			for RULENO in $RULES; do
				iptables -t nat -D "$DNSFLTR_DOT" "$RULENO"
			done
			
			iptables -t nat "$ACTION" "$DNSFLTR" -i "$IFACE" -j DNAT --to-destination "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_DNS1")"
			iptables "$ACTION" "$DNSFLTR_DOT" -i "$IFACE" ! -d "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_DNS1")" -j "$LGRJT"
		else
			RULES=$(iptables -t nat -nvL "$DNSFLTR" --line-number | grep "$IFACE" | awk '{print $1}' | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
			for RULENO in $RULES; do
				iptables -t nat -D "$DNSFLTR" "$RULENO"
			done
			
			RULES=$(iptables -nvL $DNSFLTR_DOT --line-number | grep "$IFACE" | awk '{print $1}' | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
			for RULENO in $RULES; do
				iptables -t nat -D "$DNSFLTR_DOT" "$RULENO"
			done
		fi
		###
	done
}

Firewall_NVRAM(){
	case $1 in
		create)
			nvram set "${2}_ap_isolate"="1"
		;;
		delete)
			nvram set "${2}_ap_isolate"="0"
		;;
		deleteall)
			for IFACE in $IFACELIST; do
				Firewall_NVRAM delete "$IFACE" 2>/dev/null
			done
		;;
	esac
}

Firewall_NAT(){
	IFACE_WAN=""
	
	if [ "$(nvram get wan0_proto)" = "pppoe" ] || [ "$(nvram get wan0_proto)" = "pptp" ] || [ "$(nvram get wan0_proto)" = "l2tp" ]; then
		IFACE_WAN="ppp0"
	else
		IFACE_WAN="$(nvram get wan0_ifname)"
	fi
	
	case $1 in
		create)
			for ACTION in -D -I; do
				modprobe xt_comment
				iptables -t nat -D POSTROUTING -s "$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".")".0/24 -o tun1"$3" -m comment --comment "$(Get_Guest_Name_Old "$2") VPN" -j MASQUERADE
				iptables -t nat "$ACTION" POSTROUTING -s "$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".")".0/24 -o tun1"$3" -m comment --comment "$(Get_Guest_Name "$2") VPN" -j MASQUERADE
				iptables "$ACTION" "$FWRD" -i "$2" -o "$IFACE_WAN" -j "$LGRJT"
				iptables "$ACTION" "$FWRD" -i "$IFACE_WAN" -o "$2" -j "$LGRJT"
				iptables "$ACTION" "$FWRD" -i "$2" -o tun1"$3" -j ACCEPT
				iptables "$ACTION" "$FWRD" -i tun1"$3" -o "$2" -j ACCEPT
			done
		;;
		delete)
			RULES=$(iptables -t nat -nvL POSTROUTING --line-number | grep "$(Get_Guest_Name_Old "$2") VPN" | awk '{print $1}' | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
			for RULENO in $RULES; do
				iptables -t nat -D POSTROUTING "$RULENO"
			done
			
			RULES=$(iptables -t nat -nvL POSTROUTING --line-number | grep "$(Get_Guest_Name "$2") VPN" | awk '{print $1}' | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
			for RULENO in $RULES; do
				iptables -t nat -D POSTROUTING "$RULENO"
			done
			
			RULES=$(iptables -nvL "$FWRD" --line-number | grep "$2" | grep "tun1" | awk '{print $1}' | awk '{for(i=NF;i>0;--i)printf "%s%s",$i,(i>1?OFS:ORS)}')
			for RULENO in $RULES; do
				iptables -D "$FWRD" "$RULENO"
			done
			
			iptables -D "$FWRD" -i "$2" -o "$IFACE_WAN" -j "$LGRJT"
			iptables -D "$FWRD" -i "$IFACE_WAN" -o "$2" -j "$LGRJT"
		;;
		deleteall)
			for IFACE in $IFACELIST; do
				Firewall_NAT delete "$IFACE" 2>/dev/null
			done
		;;
	esac
}

Routing_RPDB(){
	case $1 in
		create)
			if ! ip route show | grep -q "$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR")"; then
				ip route del "$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".")".0/24 dev "$2" proto kernel src "$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".").$(nvram get lan_ipaddr | cut -f4 -d".")"
				ip route add "$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".")".0/24 dev "$2" proto kernel src "$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".").$(nvram get lan_ipaddr | cut -f4 -d".")"
			fi
			COUNTER=1
			until [ $COUNTER -gt 5 ]; do
				if ifconfig "tun1$COUNTER" >/dev/null 2>&1; then
					if ! ip route show table ovpnc"$COUNTER" | grep -q "$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR")"; then
						ip route del "$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".")".0/24 dev "$2" proto kernel table ovpnc"$COUNTER" src "$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".").$(nvram get lan_ipaddr | cut -f4 -d".")"
						ip route add "$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".")".0/24 dev "$2" proto kernel table ovpnc"$COUNTER" src "$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".").$(nvram get lan_ipaddr | cut -f4 -d".")"
					fi
				fi
				COUNTER=$((COUNTER+1))
			done
		;;
		delete)
			COUNTER=1
			until [ $COUNTER -gt 5 ]; do
				if ifconfig "tun1$COUNTER" >/dev/null 2>&1; then
					ip route del "$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".")".0/24 dev "$2" proto kernel table ovpnc"$COUNTER" src "$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".").$(nvram get lan_ipaddr | cut -f4 -d".")"
				fi
				COUNTER=$((COUNTER+1))
			done
		;;
	esac
	
	ip route flush cache
}

Routing_VPNDirector(){
	case $1 in
		initialise)
			VPN_IP_LIST_ORIG=$(cat /jffs/openvpn/vpndirector_rulelist)
			VPN_IP_LIST_NEW="$VPN_IP_LIST_ORIG"
		;;
		create)
			VPN_IFACE_NVRAM=""
			VPN_IFACE_NVRAM="<1>$(Get_Guest_Name "$2")>$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".").0/24>>OVPN$3"
			
			if ! echo "$VPN_IP_LIST_ORIG" | grep -q "$VPN_IFACE_NVRAM"; then
				Routing_VPNDirector delete "$2"
				VPN_IP_LIST_NEW="${VPN_IP_LIST_NEW}${VPN_IFACE_NVRAM}"
			fi
			
			VPN_IFACE_NVRAM_SAFE="$(echo "<0>$(Get_Guest_Name "$2")>$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".").0/24>>OVPN$3" | sed -e 's/\//\\\//g;s/\./\\./g;s/ /\\ /g')"
			VPN_IP_LIST_NEW=$(echo "$VPN_IP_LIST_NEW" | sed -e "s/$VPN_IFACE_NVRAM_SAFE//g")
			
			COUNTER=1
			until [ $COUNTER -gt 5 ]; do
				if [ $COUNTER -eq "$3" ]; then
					COUNTER=$((COUNTER + 1))
					continue
				fi
				VPN_IFACE_NVRAM_SAFE="$(echo "<0>$(Get_Guest_Name "$2")>$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".").0/24>>OVPN$COUNTER" | sed -e 's/\//\\\//g;s/\./\\./g;s/ /\\ /g')"
				VPN_IP_LIST_NEW=$(echo "$VPN_IP_LIST_NEW" | sed -e "s/$VPN_IFACE_NVRAM_SAFE//g")
				VPN_IFACE_NVRAM_SAFE="$(echo "<1>$(Get_Guest_Name "$2")>$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".").0/24>>OVPN$COUNTER" | sed -e 's/\//\\\//g;s/\./\\./g;s/ /\\ /g')"
				VPN_IP_LIST_NEW=$(echo "$VPN_IP_LIST_NEW" | sed -e "s/$VPN_IFACE_NVRAM_SAFE//g")
				COUNTER=$((COUNTER + 1))
			done
		;;
		delete)
			COUNTER=1
			until [ $COUNTER -gt 5 ]; do
				VPN_IP_LIST_NEW=$(echo "$VPN_IP_LIST_NEW" | sed -e "s/$(echo '<0>'"$(Get_Guest_Name "$2")" | sed -e 's/\//\\\//g;s/ /\\ /g').*>OVPN$COUNTER//g")
				VPN_IP_LIST_NEW=$(echo "$VPN_IP_LIST_NEW" | sed -e "s/$(echo '<1>'"$(Get_Guest_Name "$2")" | sed -e 's/\//\\\//g;s/ /\\ /g').*>OVPN$COUNTER//g")
				COUNTER=$((COUNTER + 1))
			done
		;;
		deleteall)
			Routing_VPNDirector initialise 2>/dev/null
			
			for IFACE in $IFACELIST; do
				Routing_VPNDirector delete "$IFACE" 2>/dev/null
			done
			
			Routing_VPNDirector save 2>/dev/null
		;;
		save)
			if [ "$VPN_IP_LIST_ORIG" != "$VPN_IP_LIST_NEW" ]; then
				printf "%s" "$VPN_IP_LIST_NEW" > /jffs/openvpn/vpndirector_rulelist
				
				COUNTER=1
				until [ $COUNTER -gt 5 ]; do
					if ifconfig "tun1$COUNTER" >/dev/null 2>&1; then
						if [ "$(nvram get vpn_client"$COUNTER"_rgw)" -ne 2 ]; then
							nvram set vpn_client"$COUNTER"_rgw=2
							nvram commit
						fi
					fi
					COUNTER=$((COUNTER + 1))
				done
				
				service restart_vpnrouting0 >/dev/null 2>&1
			fi
		;;
	esac
}

Routing_NVRAM(){
	case $1 in
		initialise)
			COUNTER=1
			until [ $COUNTER -gt 5 ]; do
				eval "VPN_IP_LIST_ORIG_$COUNTER=$(echo "$(nvram get "vpn_client${COUNTER}_clientlist")$(nvram get "vpn_client${COUNTER}_clientlist1")$(nvram get "vpn_client${COUNTER}_clientlist2")$(nvram get "vpn_client${COUNTER}_clientlist3")$(nvram get "vpn_client${COUNTER}_clientlist4")$(nvram get "vpn_client${COUNTER}_clientlist5")" | Escape_Sed)"
				eval "VPN_IP_LIST_NEW_$COUNTER=$(eval echo '$'"VPN_IP_LIST_ORIG_"$COUNTER | Escape_Sed)"
				COUNTER=$((COUNTER + 1))
			done
		;;
		create)
			VPN_NVRAM="$(Get_Guest_Name "$2")"
			VPN_IFACE_NVRAM=""
			if [ "$(Firmware_Version_Check "$(nvram get buildno)")" -lt "$(Firmware_Version_Check 384.18)" ]; then
				VPN_IFACE_NVRAM="<$VPN_NVRAM>$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".").0/24>0.0.0.0>VPN"
			else
				VPN_IFACE_NVRAM="<$VPN_NVRAM>$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".").0/24>>VPN"
			fi
			VPN_IFACE_NVRAM_SAFE="$(echo "$VPN_IFACE_NVRAM" | sed -e 's/\//\\\//g;s/\./\\./g;s/ /\\ /g')"
			
			if ! eval echo '$'"VPN_IP_LIST_ORIG_$3" | grep -q "$VPN_IFACE_NVRAM"; then
				Routing_NVRAM delete "$2"
				eval "VPN_IP_LIST_NEW_$3=$(echo "$(eval echo '$'"VPN_IP_LIST_NEW_$3")$VPN_IFACE_NVRAM" | Escape_Sed)"
			fi
			
			COUNTER=1
			until [ $COUNTER -gt 5 ]; do
				if [ $COUNTER -eq "$3" ]; then
					COUNTER=$((COUNTER + 1))
					continue
				fi
				eval "VPN_IP_LIST_NEW_$COUNTER=$(eval echo '$'"VPN_IP_LIST_NEW_$COUNTER" | sed -e "s/$VPN_IFACE_NVRAM_SAFE//g" | Escape_Sed)"
				COUNTER=$((COUNTER + 1))
			done
			
			VPN_NVRAM="$(Get_Guest_Name_Old "$2")"
			VPN_IFACE_NVRAM=""
			if [ "$(Firmware_Version_Check "$(nvram get buildno)")" -lt "$(Firmware_Version_Check 384.18)" ]; then
				VPN_IFACE_NVRAM="<$VPN_NVRAM>$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".").0/24>0.0.0.0>VPN"
			else
				VPN_IFACE_NVRAM="<$VPN_NVRAM>$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".").0/24>>VPN"
			fi
			VPN_IFACE_NVRAM_SAFE="$(echo "$VPN_IFACE_NVRAM" | sed -e 's/\//\\\//g;s/\./\\./g;s/ /\\ /g')"
			
			COUNTER=1
			until [ $COUNTER -gt 5 ]; do
				eval "VPN_IP_LIST_NEW_$COUNTER=$(eval echo '$'"VPN_IP_LIST_NEW_$COUNTER" | sed -e "s/$VPN_IFACE_NVRAM_SAFE//g" | Escape_Sed)"
				COUNTER=$((COUNTER + 1))
			done
		;;
		delete)
			COUNTER=1
			until [ $COUNTER -gt 5 ]; do
				VPN_NVRAM="$(Get_Guest_Name_Old "$2")"
				eval "VPN_IP_LIST_NEW_$COUNTER=$(echo "$(eval echo '$'"VPN_IP_LIST_NEW_$COUNTER")" | sed -e "s/$(echo '<'$VPN_NVRAM | sed -e 's/\//\\\//g' | sed -e 's/ /\\ /g').*>VPN//g" | Escape_Sed)"
				VPN_NVRAM="$(Get_Guest_Name "$2")"
				eval "VPN_IP_LIST_NEW_$COUNTER=$(echo "$(eval echo '$'"VPN_IP_LIST_NEW_$COUNTER")" | sed -e "s/$(echo '<'$VPN_NVRAM | sed -e 's/\//\\\//g' | sed -e 's/ /\\ /g').*>VPN//g" | Escape_Sed)"
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
				if [ "$(eval echo '$'"VPN_IP_LIST_ORIG_$COUNTER")" != "$(eval echo '$'"VPN_IP_LIST_NEW_$COUNTER")" ]; then
					Print_Output true "VPN Client $COUNTER client list has changed, restarting VPN Client $COUNTER"
					
					if [ "$(/bin/uname -m)" = "aarch64" ]; then
						fullstring="$(eval echo '$'"VPN_IP_LIST_NEW_"$COUNTER)"
						nvram set vpn_client"$COUNTER"_clientlist="$(echo "$fullstring" | cut -c0-255)"
						nvram set vpn_client"$COUNTER"_clientlist1="$(echo "$fullstring" | cut -c256-510)"
						nvram set vpn_client"$COUNTER"_clientlist2="$(echo "$fullstring" | cut -c511-765)"
						nvram set vpn_client"$COUNTER"_clientlist3="$(echo "$fullstring" | cut -c766-1020)"
						nvram set vpn_client"$COUNTER"_clientlist4="$(echo "$fullstring" | cut -c1021-1275)"
						nvram set vpn_client"$COUNTER"_clientlist5="$(echo "$fullstring" | cut -c1276-1530)"
					else
						nvram set vpn_client"$COUNTER"_clientlist="$(eval echo '$'"VPN_IP_LIST_NEW_$COUNTER")"
					fi
					
					if [ "$(nvram get vpn_client"$COUNTER"_rgw)" -ne 2 ]; then
						nvram set vpn_client"$COUNTER"_rgw=2
					fi
					nvram commit
					service restart_vpnclient$COUNTER >/dev/null 2>&1
				fi
				COUNTER=$((COUNTER + 1))
			done
		;;
	esac
}

DHCP_Conf(){
	case $1 in
		initialise)
			if [ -f /jffs/configs/dnsmasq.conf.add ]; then
				for IFACE in $IFACELIST; do
					BEGIN="### Start of script-generated configuration for interface $IFACE ###"
					END="### End of script-generated configuration for interface $IFACE ###"
					if grep -q "### Start of script-generated configuration for interface $IFACE ###" /jffs/configs/dnsmasq.conf.add; then
						sed -i -e '/'"$BEGIN"'/,/'"$END"'/c\' /jffs/configs/dnsmasq.conf.add
					fi
				done
			fi
			if [ -f "$DNSCONF" ]; then
				cp "$DNSCONF" "$TMPCONF"
			else
				touch "$TMPCONF"
			fi
		;;
		create)
			CONFSTRING=""
			CONFADDSTRING=""
			
			ENABLED_WINS="$(nvram get smbd_wins)"
			ENABLED_SAMBA="$(nvram get enable_samba)"
			if ! Validate_Number "" "$ENABLED_SAMBA" silent; then ENABLED_SAMBA=0; fi
			if ! Validate_Number "" "$ENABLED_WINS" silent; then ENABLED_WINS=0; fi
			
			ENABLED_NTPD=0
			if [ -f /jffs/scripts/nat-start ]; then
				if [ "$(grep -c '# ntpMerlin' /jffs/scripts/nat-start)" -gt 0 ]; then ENABLED_NTPD=1; fi
			fi
			
			if [ "$ENABLED_WINS" -eq 1 ] && [ "$ENABLED_SAMBA" -eq 1 ]; then
				CONFADDSTRING="$CONFADDSTRING||||dhcp-option=$2,44,$(nvram get lan_ipaddr)"
			fi
			
			if [ "$ENABLED_NTPD" -eq 1 ]; then
				CONFADDSTRING="$CONFADDSTRING||||dhcp-option=$2,42,$(nvram get lan_ipaddr)"
			fi
			
			CONFSTRING="interface=$2||||dhcp-range=$2,$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".").$(eval echo '$'"$(Get_Iface_Var "$2")_DHCPSTART"),$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".").$(eval echo '$'"$(Get_Iface_Var "$2")_DHCPEND"),255.255.255.0,86400s||||dhcp-option=$2,3,$(eval echo '$'"$(Get_Iface_Var "$2")_IPADDR" | cut -f1-3 -d".").$(nvram get lan_ipaddr | cut -f4 -d".")||||dhcp-option=$2,6,$(eval echo '$'"$(Get_Iface_Var "$2")_DNS1"),$(eval echo '$'"$(Get_Iface_Var "$2")_DNS2")$CONFADDSTRING"
			
			BEGIN="### Start of script-generated configuration for interface $2 ###"
			END="### End of script-generated configuration for interface $2 ###"
			if grep -q "### Start of script-generated configuration for interface $2 ###" "$TMPCONF"; then
				sed -i -e '/'"$BEGIN"'/,/'"$END"'/c\'"$BEGIN"'||||'"$CONFSTRING"'||||'"$END" "$TMPCONF"
			else
				printf "\\n%s\\n%s\\n%s\\n" "$BEGIN" "$CONFSTRING" "$END" >> "$TMPCONF"
			fi
		;;
		delete)
			BEGIN="### Start of script-generated configuration for interface $2 ###"
			END="### End of script-generated configuration for interface $2 ###"
			if grep -q "### Start of script-generated configuration for interface $2 ###" "$TMPCONF"; then
				sed -i -e '/'"$BEGIN"'/,/'"$END"'/c\' "$TMPCONF"
			fi
		;;
		deleteall)
			DHCP_Conf initialise 2>/dev/null
			for IFACE in $IFACELIST; do
				BEGIN="### Start of script-generated configuration for interface $IFACE ###"
				END="### End of script-generated configuration for interface $IFACE ###"
				if grep -q "### Start of script-generated configuration for interface $IFACE ###" "$TMPCONF"; then
					sed -i -e '/'"$BEGIN"'/,/'"$END"'/c\' "$TMPCONF"
				fi
			done
			
			DHCP_Conf save 2>/dev/null
		;;
		save)
			sed -i -e 's/||||/\n/g' "$TMPCONF"
			
			if ! diff -q "$DNSCONF" "$TMPCONF" >/dev/null 2>&1; then
				cp "$TMPCONF" "$DNSCONF"
				service restart_dnsmasq >/dev/null 2>&1
				Print_Output true "DHCP configuration updated"
				sleep 2
			fi
			
			rm -f "$TMPCONF"
		;;
	esac
}

Config_Networks(){
	Print_Output true "$SCRIPT_NAME $SCRIPT_VERSION starting up"
	WIRELESSRESTART="false"
	GUESTLANENABLED="false"
	
	Create_Dirs
	Create_Symlinks
	
	Auto_Startup create 2>/dev/null
	Auto_Cron create 2>/dev/null
	Auto_DNSMASQ create 2>/dev/null
	Auto_ServiceEvent create 2>/dev/null
	Auto_ServiceStart create 2>/dev/null
	Auto_OpenVPNEvent create 2>/dev/null
	
	if ! Conf_Exists; then
		Conf_Download "$SCRIPT_CONF"
		Clear_Lock
		return 1
	fi
	
	if ! Conf_Validate; then
		Clear_Lock
		return 1
	fi
	
	. $SCRIPT_CONF
	
	DHCP_Conf initialise 2>/dev/null
	
	if [ "$(Firmware_Version_Check "$(nvram get buildno)")" -lt "$(Firmware_Version_Check 386.3)" ]; then
		Routing_NVRAM initialise 2>/dev/null
	else
		Routing_VPNDirector initialise 2>/dev/null
	fi
	
	Firewall_Chains create 2>/dev/null
	
	for IFACE in $IFACELIST; do
		VPNCLIENTNO=$(eval echo '$'"$(Get_Iface_Var "$IFACE")_VPNCLIENTNUMBER")
		
		if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_ENABLED")" = "true" ]; then
			Iface_Manage create "$IFACE" 2>/dev/null
			
			Firewall_Rules create "$IFACE" 2>/dev/null
			
			if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_REDIRECTALLTOVPN")" = "true" ]; then
				Print_Output true "$IFACE (SSID: $(nvram get "${IFACE}_ssid")) - VPN redirection enabled, sending all interface internet traffic over VPN Client $VPNCLIENTNO"
				
				if [ "$(Firmware_Version_Check "$(nvram get buildno)")" -lt "$(Firmware_Version_Check 386.3)" ]; then
					Routing_NVRAM create "$IFACE" "$VPNCLIENTNO" 2>/dev/null
				else
					Routing_VPNDirector create "$IFACE" "$VPNCLIENTNO" 2>/dev/null
				fi
				
				Firewall_NAT create "$IFACE" "$VPNCLIENTNO" 2>/dev/null
			else
				Print_Output true "$IFACE (SSID: $(nvram get "${IFACE}_ssid")) - sending all interface internet traffic over WAN interface"
				
				Firewall_NAT delete "$IFACE" 2>/dev/null
				
				if [ "$(Firmware_Version_Check "$(nvram get buildno)")" -lt "$(Firmware_Version_Check 386.3)" ]; then
					Routing_NVRAM delete "$IFACE" 2>/dev/null
				else
					Routing_VPNDirector delete "$IFACE" 2>/dev/null
				fi
			fi
			
			Firewall_DNS create "$IFACE" 2>/dev/null
			
			if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_CLIENTISOLATION")" = "true" ]; then
				ISOBEFORE="$(nvram get "${IFACE}_ap_isolate")"
				if ! Validate_Number "" "$ISOBEFORE" silent; then ISOBEFORE=0; fi
				Firewall_NVRAM create "$IFACE" 2>/dev/null
				ISOAFTER="$(nvram get "${IFACE}_ap_isolate")"
				if ! Validate_Number "" "$ISOAFTER" silent; then ISOAFTER=0; fi
				if [ "$ISOBEFORE" -ne "$ISOAFTER" ]; then
					WIRELESSRESTART="true"
				fi
			else
				ISOBEFORE="$(nvram get "${IFACE}_ap_isolate")"
				if ! Validate_Number "" "$ISOBEFORE" silent; then ISOBEFORE=0; fi
				Firewall_NVRAM delete "$IFACE" 2>/dev/null
				ISOAFTER="$(nvram get "${IFACE}_ap_isolate")"
				if ! Validate_Number "" "$ISOAFTER" silent; then ISOAFTER=0; fi
				if [ "$ISOBEFORE" -ne "$ISOAFTER" ]; then
					WIRELESSRESTART="true"
				fi
			fi
			
			if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_ONEWAYTOGUEST")" = "true" ] || [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_TWOWAYTOGUEST")" = "true" ]; then
				GUESTLANENABLED="true"
			fi
			
			#Set guest interface LAN access to allowed in f/w, prevent creating VLAN
			if [ "$(nvram get "${IFACE}_lanaccess")" != "on" ]; then
				nvram set "$IFACE"_lanaccess=on
				WIRELESSRESTART="true"
			fi
			
			Routing_RPDB create "$IFACE" 2>/dev/null
			
			DHCP_Conf create "$IFACE" 2>/dev/null
			
			sleep 1
		else
			#Remove firewall rules for guest interface
			Firewall_Rules delete "$IFACE" 2>/dev/null
			
			Firewall_DNS delete "$IFACE" 2>/dev/null
			
			#Reset guest interface ISOLATION
			ISOBEFORE="$(nvram get "${IFACE}_ap_isolate")"
			if ! Validate_Number "" "$ISOBEFORE" silent; then ISOBEFORE=0; fi
			Firewall_NVRAM delete "$IFACE" 2>/dev/null
			ISOAFTER="$(nvram get "${IFACE}_ap_isolate")"
			if ! Validate_Number "" "$ISOAFTER" silent; then ISOAFTER=0; fi
			if [ "$ISOBEFORE" -ne "$ISOAFTER" ]; then
				WIRELESSRESTART="true"
			fi
			
			Iface_Manage delete "$IFACE" 2>/dev/null
			
			DHCP_Conf delete "$IFACE" 2>/dev/null
			
			if [ "$(Firmware_Version_Check "$(nvram get buildno)")" -lt "$(Firmware_Version_Check 386.3)" ]; then
				Routing_NVRAM delete "$IFACE" 2>/dev/null
			else
				Routing_VPNDirector delete "$IFACE" 2>/dev/null
			fi
			
			Routing_RPDB delete "$IFACE" 2>/dev/null
			
			Firewall_NAT delete "$IFACE" 2>/dev/null
		fi
	done
	
	if [ "$(Firmware_Version_Check "$(nvram get buildno)")" -lt "$(Firmware_Version_Check 386.3)" ]; then
		Routing_NVRAM save 2>/dev/null
	else
		Routing_VPNDirector save 2>/dev/null
	fi
	
	DHCP_Conf save 2>/dev/null
		
	if [ "$GUESTLANENABLED" = "true" ]; then
		Avahi_Conf create
	else
		Avahi_Conf delete
	fi
	
	if [ "$WIRELESSRESTART" = "true" ]; then
		nvram commit
		Clear_Lock
		service restart_wireless >/dev/null 2>&1
	elif [ "$WIRELESSRESTART" = "false" ]; then
		Execute_UserScripts
		Iface_BounceClients
	fi
	
	Print_Output true "$SCRIPT_NAME $SCRIPT_VERSION completed successfully" "$PASS"
	Clear_Lock
}

Execute_UserScripts(){
	FILES="$USER_SCRIPT_DIR/*.sh"
	for f in $FILES; do
		if [ -f "$f" ]; then
			Print_Output true "Executing user script: $f"
			sh "$f"
		fi
	done
}

### Code adapted from firmware WebUI function, credit to @RMerlin ###
Generate_QRCode(){
	QRGUEST_WL="$1"
	QRSSID="S:$(nvram get "$QRGUEST_WL"_ssid | sed 's/[\\":;,]/\\$&/g');"
	QRAUTHMODE=$(nvram get "$QRGUEST_WL"_auth_mode_x)
	
	if [ "$QRAUTHMODE" = 'psk' ] || [ "$QRAUTHMODE" = 'psk2' ] || [ "$QRAUTHMODE" = 'sae' ] || [ "$QRAUTHMODE" = 'pskpsk2' ] || [ "$QRAUTHMODE" = 'psk2sae' ]; then
		QRTYPE="T:WPA;"
		QRPASS="P:$(nvram get "$QRGUEST_WL"_wpa_psk | sed 's/[\\":;,]/\\$&/g');"
	elif [ "$QRAUTHMODE" = "open" ] && [ "$(nvram get "$QRGUEST_WL"_wep_x)" -eq 0 ]; then
		QRTYPE="T:;"
		QRPASS="P:;"
	elif [ "$QRAUTHMODE" = "shared" ] || [ "$QRAUTHMODE" = "open" ]; then
		QRTYPE="T:WEP;"
		QRKEYINDEX=$(nvram get "$QRGUEST_WL"_key)
		QRPASS="$(nvram get "$QRGUEST_WL"_key"$QRKEYINDEX");"
	else
		QRSSID="" # Unsupported
	fi
	
	if [ "$(nvram get "$QRGUEST_WL"_closed)" -eq 1 ]; then
		QRHIDE="H:true;"
	fi
	
	if [ "$QRSSID" != "" ]; then
		qrencode -t ANSI -o - "WIFI:${QRTYPE}${QRSSID}${QRPASS}${QRHIDE};"
	else
		printf "\\nQR Code generation not supported for this guest network. Please check configuration.\\n"
	fi
	QRTYPE=""
	QRSSID=""
	QRPASS=""
	QRHIDE=""
}
### ###

Shortcut_Script(){
	case $1 in
		create)
			if [ -d /opt/bin ] && [ ! -f "/opt/bin/$SCRIPT_NAME" ] && [ -f "/jffs/scripts/$SCRIPT_NAME" ]; then
				ln -s "/jffs/scripts/$SCRIPT_NAME" /opt/bin
				chmod 0755 "/opt/bin/$SCRIPT_NAME"
			fi
		;;
		delete)
			if [ -f "/opt/bin/$SCRIPT_NAME" ]; then
				rm -f "/opt/bin/$SCRIPT_NAME"
			fi
		;;
	esac
}

PressEnter(){
	while true; do
		printf "Press enter to continue..."
		read -r key
		case "$key" in
			*)
				break
			;;
		esac
	done
	return 0
}

ScriptHeader(){
	clear
	printf "\\n"
	printf "${BOLD}#############################################${CLEARFORMAT}\\n"
	printf "${BOLD}##                                         ##${CLEARFORMAT}\\n"
	printf "${BOLD}##     __     __          ______  _        ##${CLEARFORMAT}\\n"
	printf "${BOLD}##     \ \   / /         |  ____|(_)       ##${CLEARFORMAT}\\n"
	printf "${BOLD}##      \ \_/ /__ _  ____| |__    _        ##${CLEARFORMAT}\\n"
	printf "${BOLD}##       \   // _  ||_  /|  __|  | |       ##${CLEARFORMAT}\\n"
	printf "${BOLD}##        | || (_| | / / | |     | |       ##${CLEARFORMAT}\\n"
	printf "${BOLD}##        |_| \__,_|/___||_|     |_|       ##${CLEARFORMAT}\\n"
	printf "${BOLD}##                                         ##${CLEARFORMAT}\\n"
	printf "${BOLD}##           %s on %-11s         ##${CLEARFORMAT}\\n" "$SCRIPT_VERSION" "$ROUTER_MODEL"
	printf "${BOLD}##                                         ##${CLEARFORMAT}\\n"
	printf "${BOLD}##    https://github.com/jackyaz/YazFi/    ##${CLEARFORMAT}\\n"
	printf "${BOLD}##                                         ##${CLEARFORMAT}\\n"
	printf "${BOLD}#############################################${CLEARFORMAT}\\n"
	printf "\\n"
}

MainMenu(){
	printf "WebUI for %s is available at:\\n${SETTING}%s${CLEARFORMAT}\\n\\n" "$SCRIPT_NAME" "$(Get_WebUI_URL)"
	printf "1.    Apply %s settings\\n\\n" "$SCRIPT_NAME"
	printf "2.    Show connected clients using %s\\n\\n" "$SCRIPT_NAME"
	printf "3.    Edit %s config\\n" "$SCRIPT_NAME"
	printf "4.    Edit Guest Network config (SSID + passphrase)\\n\\n"
	if [ -f /opt/bin/qrencode ]; then
		printf "5.    Show QR Code for Guest Network\\n\\n"
	else
		printf "\\nQR Code generation not supported.\\n\\n"
	fi
	printf "u.    Check for updates\\n"
	printf "uf.   Update %s with latest version (force update)\\n\\n" "$SCRIPT_NAME"
	printf "d.    Generate %s diagnostics\\n\\n" "$SCRIPT_NAME"
	printf "e.    Exit %s\\n\\n" "$SCRIPT_NAME"
	printf "z.    Uninstall %s\\n" "$SCRIPT_NAME"
	printf "\\n"
	printf "${BOLD}#############################################${CLEARFORMAT}\\n"
	printf "\\n"
	
	while true; do
		printf "Choose an option:  "
		read -r menu
		case "$menu" in
			1)
				printf "\\n"
				if Check_Lock menu; then
					Config_Networks
					Clear_Lock
				fi
				PressEnter
				break
			;;
			2)
				printf "\\n"
				Menu_Status
				PressEnter
				break
			;;
			3)
				printf "\\n"
				if Check_Lock menu; then
					Menu_Edit
				else
					PressEnter
				fi
				break
			;;
			4)
				printf "\\n"
				if Check_Lock menu; then
					Menu_GuestConfig
				else
					PressEnter
				fi
				break
			;;
			5)
				if [ -f /opt/bin/qrencode ]; then
					Menu_QRCode
					printf "\\n"
					PressEnter
				else
					printf "\\nQR Code generation not supported.\\n\\n"
					PressEnter
				fi
				break
			;;
			u)
				printf "\\n"
				if Check_Lock menu; then
					Update_Version
					Clear_Lock
				fi
				PressEnter
				break
			;;
			uf)
				printf "\\n"
				if Check_Lock menu; then
					Update_Version force
					Clear_Lock
				fi
				PressEnter
				break
			;;
			d)
				ScriptHeader
				Menu_Diagnostics
				PressEnter
				break
			;;
			e)
				ScriptHeader
				printf "\\n${BOLD}Thanks for using %s!${CLEARFORMAT}\\n\\n\\n" "$SCRIPT_NAME"
				exit 0
			;;
			z)
				while true; do
					printf "\\n${BOLD}Are you sure you want to uninstall %s? (y/n)${CLEARFORMAT}  " "$SCRIPT_NAME"
					read -r confirm
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
		Print_Output false "Device is not running in router mode - non-router modes are not supported" "$ERR"
		CHECKSFAILED="true"
	fi
	
	if [ "$(nvram get jffs2_scripts)" -ne 1 ]; then
		nvram set jffs2_scripts=1
		nvram commit
		Print_Output true "Custom JFFS Scripts enabled" "$WARN"
	fi
	
	if [ "$(nvram get wl0_radio)" -eq 0 ] && [ "$(nvram get wl1_radio)" -eq 0 ] && [ "$(nvram get wl_radio)" -eq 0 ]; then
		Print_Output false "No wireless radios are enabled!" "$ERR"
		CHECKSFAILED="true"
	fi
	
	if [ "$(Firmware_Version_Check "$(nvram get buildno)")" -lt "$(Firmware_Version_Check 384.5)" ] && [ "$(Firmware_Version_Check "$(nvram get buildno)")" -ne "$(Firmware_Version_Check 374.43)" ]; then
		Print_Output true "Older Merlin firmware detected - service-event requires 384.5 or later" "$WARN"
		Print_Output true "Please update to benefit from $SCRIPT_NAME detecting wireless restarts" "$WARN"
	elif [ "$(Firmware_Version_Check "$(nvram get buildno)")" -eq "$(Firmware_Version_Check 374.43)" ]; then
		Print_Output true "John's fork detected - service-event requires 374.43_32D6j9527 or later" "$WARN"
		Print_Output true "Please update to benefit from $SCRIPT_NAME detecting wireless restarts" "$WARN"
	fi
	
	if [ "$CHECKSFAILED" = "false" ]; then
		return 0
	else
		return 1
	fi
}

Menu_Install(){
	ScriptHeader
	Print_Output true "Welcome to $SCRIPT_NAME $SCRIPT_VERSION, a script by JackYaz"
	sleep 1
	
	Print_Output true "Checking your router meets the requirements for $SCRIPT_NAME"
	
	if ! Check_Requirements; then
		Print_Output true "Requirements for $SCRIPT_NAME not met, please see above for the reason(s)" "$CRIT"
		PressEnter
		Clear_Lock
		rm -f "/jffs/scripts/$SCRIPT_NAME" 2>/dev/null
		exit 1
	fi
	
	Create_Dirs
	Create_Symlinks
	
	if Firmware_Version_WebUI ; then
		Update_File shared-jy.tar.gz
		Update_File YazFi_www.asp
	else
		Print_Output false "WebUI is only support on firmware versions with addon support" "$WARN"
	fi
	
	if ! Conf_Exists; then
		Conf_Download "$SCRIPT_CONF"
	else
		Print_Output false "Existing $SCRIPT_CONF found. This will be kept by $SCRIPT_NAME"
		Conf_Download "$SCRIPT_CONF.example"
	fi
	
	Shortcut_Script create
	Set_Version_Custom_Settings local "$SCRIPT_VERSION"
	Set_Version_Custom_Settings server "$SCRIPT_VERSION"
	Auto_Startup create 2>/dev/null
	Auto_Cron create 2>/dev/null
	Auto_DNSMASQ create 2>/dev/null
	Auto_ServiceEvent create 2>/dev/null
	Auto_ServiceStart create 2>/dev/null
	Auto_OpenVPNEvent create 2>/dev/null
	
	Print_Output false "You can access $SCRIPT_NAME's configuration via the Guest Networks section of the WebUI" "$PASS"
	Print_Output false "Alternatively, use $SCRIPT_NAME's menu via amtm (if installed), with /jffs/scripts/$SCRIPT_NAME or simply $SCRIPT_NAME"
	Clear_Lock
	PressEnter
	ScriptHeader
	MainMenu
}

Menu_Edit(){
	texteditor=""
	exitmenu="false"
	if ! Conf_Exists; then
		Conf_Download "$SCRIPT_CONF"
	fi
	printf "\\n${BOLD}A choice of text editors is available:${CLEARFORMAT}\\n"
	printf "1.    nano (recommended for beginners)\\n"
	printf "2.    vi\\n"
	printf "\\ne.    Exit to main menu\\n"
	
	while true; do
		printf "\\n${BOLD}Choose an option:${CLEARFORMAT}  "
		read -r editor
		case "$editor" in
			1)
				texteditor="nano -K"
				break
			;;
			2)
				texteditor="vi"
				break
			;;
			e)
				exitmenu="true"
				break
			;;
			*)
				printf "\\nPlease choose a valid option\\n\\n"
			;;
		esac
	done
	
	if [ "$exitmenu" != "true" ]; then
		$texteditor "$SCRIPT_CONF"
	fi
	Clear_Lock
}

Menu_GuestConfig(){
	exitmenu="false"
	selectediface=""
	changesmade="false"
	
	ScriptHeader
	
	printf "\\n${BOLD}Please select a Guest Network:${CLEARFORMAT}\\n\\n"
	COUNTER=1
	for IFACE_MENU in $IFACELIST; do
		if [ $((COUNTER % 4)) -eq 0 ]; then printf "\\n"; fi
		IFACE_MENU_TEST="$(nvram get "${IFACE_MENU}_bss_enabled")"
		if ! Validate_Number "" "$IFACE_MENU_TEST" silent; then IFACE_MENU_TEST=0; fi
		if [ "$IFACE_MENU_TEST" -eq 1 ]; then
			printf "%s.    %s (SSID: %s)\\n" "$COUNTER" "$(Get_Guest_Name "$IFACE_MENU")" "$(nvram get "${IFACE_MENU}_ssid")"
		fi
		COUNTER=$((COUNTER + 1))
	done
	
	printf "\\ne.    Go back\\n"
	
	while true; do
		selectediface=""
		printf "\\n${BOLD}Choose an option:${CLEARFORMAT}  "
		read -r selectedguest
		
		case "$selectedguest" in
			1|2|3|4|5|6|7|8|9)
				selectediface="$(echo "$IFACELIST" | awk '{print $'"$selectedguest"'}')"
			;;
			e)
				exitmenu="true"
				break
			;;
			*)
				printf "\\nPlease choose a valid option\\n\\n"
			;;
		esac
			
		if [ -n "$selectediface" ]; then
			if ! Validate_Exists_IFACE "$selectediface" silent; then
				printf "\\nSelected guest (%s) not supported on your router, please choose a different option\\n" "$selectediface"
			else
				selectediface_TEST="$(nvram get "${selectediface}_bss_enabled")"
				if ! Validate_Number "" "$selectediface_TEST" silent; then selectediface_TEST=0; fi
				if [ "$selectediface_TEST" -eq 1 ]; then
					break
				else
					printf "\\nSelected guest (%s) not enabled on your router, please choose a different option\\n" "$selectediface"
				fi
			fi
		fi
	done
		
	if [ "$exitmenu" != "true" ]; then
		while true; do
			ScriptHeader
			printf "\\n${BOLD}%s (%s)${CLEARFORMAT}\\n\\n" "$(Get_Guest_Name "$selectediface")" "$selectediface"
			printf "${BOLD}Available options:${CLEARFORMAT}\\n\\n"
			printf "1.    Set SSID (current: %s)\\n" "$(nvram get "${selectediface}_ssid")"
			printf "2.    Set passphrase (current: %s)\\n" "$(nvram get "${selectediface}_wpa_psk")"
			printf "\\ne.    Go back\\n"
			printf "\\n${BOLD}Choose an option:${CLEARFORMAT}  "
			read -r guestoption
			case "$guestoption" in
				1)
					printf "\\n${BOLD}Please enter your new SSID:${CLEARFORMAT}  "
					read -r newssid
					newssidclean="$newssid"
					if ! Validate_String "$newssid"; then
						newssidclean="$(echo "$newssid" | sed 's/[^a-zA-Z0-9]//g')"
					fi
					nvram set "${selectediface}_ssid"="$newssidclean"
					nvram commit
					changesmade="true"
				;;
				2)
					while true; do
						printf "\\n${BOLD}Available options:${CLEARFORMAT}\\n\\n"
						printf "1.    Generate random passphrase\\n"
						printf "2.    Manually set passphrase\\n"
						printf "\\ne.    Go back\\n"
						printf "\\n${BOLD}Choose an option:${CLEARFORMAT}  "
						read -r passoption
						case "$passoption" in
							1)
								validpasslength=""
								while true; do
									printf "\\n${BOLD}How many characters? (8-32)${CLEARFORMAT}  "
									read -r passlength
									if Validate_Number "" "$passlength" silent; then
										if [ "$passlength" -le 32 ] && [ "$passlength" -ge 8 ]; then
											validpasslength="$passlength"
											break
										else
											printf "\\nPlease choose a number between 8 and 32\\n\\n"
										fi
									elif [ "$passlength" = "e" ]; then
										break
									else
										printf "\\nPlease choose a valid number\\n\\n"
									fi
								done
								
								if [ -n "$validpasslength" ]; then
									newpassphrase="$(Generate_Random_String "$validpasslength")"
									newpassphraseclean="$(echo "$newpassphrase" | sed 's/[^a-zA-Z0-9]//g')"
									Set_WiFi_Passphrase "$selectediface" "$newpassphraseclean"
									changesmade="true"
									break
								fi
							;;
							2)
								printf "\\n${BOLD}Please enter your new passphrase:${CLEARFORMAT}  "
								read -r newpassphrase
								newpassphraseclean="$newpassphrase"
								if ! Validate_String "$newpassphrase"; then
									newpassphraseclean="$(echo "$newpassphrase" | sed 's/[^a-zA-Z0-9]//g')"
								fi
								
								Set_WiFi_Passphrase "$selectediface" "$newpassphraseclean"
								changesmade="true"
								break
							;;
							e)
								break
							;;
							*)
								printf "\\nPlease choose a valid option\\n\\n"
							;;
						esac
					done
				;;
				e)
					if [ "$changesmade" = "true" ]; then
						while true; do
							printf "\\n${BOLD}Do you want to restart wireless services now? (y/n)${CLEARFORMAT}  "
							read -r confirmrestart
							case "$confirmrestart" in
								y|Y)
									Clear_Lock
									service restart_wireless >/dev/null 2>&1
									break
								;;
								*)
									break
								;;
							esac
						done
					fi
					ScriptHeader
					break
				;;
				*)
					printf "\\nPlease choose a valid option\\n\\n"
				;;
			esac
		done
		
		Menu_GuestConfig
	fi
	Clear_Lock
}

Menu_QRCode(){
	exitmenu="false"
	selectediface=""
	
	ScriptHeader
	
	printf "\\n${BOLD}Please select a Guest Network:${CLEARFORMAT}\\n\\n"
	COUNTER=1
	for IFACE_MENU in $IFACELIST; do
		if [ $((COUNTER % 4)) -eq 0 ]; then printf "\\n"; fi
		IFACE_MENU_TEST="$(nvram get "${IFACE_MENU}_bss_enabled")"
		if ! Validate_Number "" "$IFACE_MENU_TEST" silent; then IFACE_MENU_TEST=0; fi
		if [ "$IFACE_MENU_TEST" -eq 1 ]; then
			printf "%s.    %s (SSID: %s)\\n" "$COUNTER" "$(Get_Guest_Name "$IFACE_MENU")" "$(nvram get "${IFACE_MENU}_ssid")"
		fi
		COUNTER=$((COUNTER + 1))
	done
	
	printf "\\ne.    Go back\\n"
	
	while true; do
		selectediface=""
		printf "\\n${BOLD}Choose an option:${CLEARFORMAT}  "
		read -r selectedguest
		
		case "$selectedguest" in
			1|2|3|4|5|6|7|8|9)
				selectediface="$(echo "$IFACELIST" | awk '{print $'"$selectedguest"'}')"
			;;
			e)
				exitmenu="true"
				break
			;;
			*)
				printf "\\nPlease choose a valid option\\n\\n"
			;;
		esac
			
		if [ -n "$selectediface" ]; then
			if ! Validate_Exists_IFACE "$selectediface" silent; then
				printf "\\nSelected guest (%s) not supported on your router, please choose a different option\\n" "$selectediface"
			else
				selectediface_TEST="$(nvram get "${selectediface}_bss_enabled")"
				if ! Validate_Number "" "$selectediface_TEST" silent; then selectediface_TEST=0; fi
				if [ "$selectediface_TEST" -eq 1 ]; then
					break
				else
					printf "\\nSelected guest (%s) not enabled on your router, please choose a different option\\n" "$selectediface"
				fi
			fi
		fi
	done
		
	if [ "$exitmenu" != "true" ]; then
		if [ -f /opt/bin/qrencode ]; then
			printf "\\n"
			Generate_QRCode "${selectediface}"
		else
			printf "\\nQR Code generation not supported.\\n"
		fi
	fi
}

Menu_Status(){
	renice 15 $$
	### This function suggested by @HuskyHerder, code inspired by @ColinTaylor's wireless monitor script ###
	STATUSOUTPUTFILE="$SCRIPT_DIR/.connectedclients"
	rm -f "$STATUSOUTPUTFILE"
	TMPSTATUSOUTPUTFILE="/tmp/.connectedclients"
	. "$SCRIPT_CONF"
	
	if [ ! -f /opt/bin/dig ] && [ -f /opt/bin/opkg ]; then
		opkg update
		opkg install bind-dig
	fi
	
	[ -z "$1" ] && ScriptHeader
	[ -z "$1" ] && printf "${BOLD}$PASS%sQuerying router for connected WiFi clients...${CLEARFORMAT}\\n\\n" ""
	printf "INTERFACE,HOSTNAME,IP,MAC,CONNECTED,RX,TX,RSSI,PHY\\n" >> "$TMPSTATUSOUTPUTFILE"
	
	ARPDUMP="$(arp -an)"
	
	for IFACE in $IFACELIST; do
		if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_ENABLED")" = "true" ] && Validate_Exists_IFACE "$IFACE" silent && Validate_Enabled_IFACE "$IFACE" silent; then
			[ -z "$1" ] && printf "%75s\\n\\n" "" | tr " " "-"
			[ -z "$1" ] && printf "${BOLD}INTERFACE: %-5s${CLEARFORMAT}\\n" "$IFACE"
			[ -z "$1" ] && printf "${BOLD}SSID: %-20s${CLEARFORMAT}\\n\\n" "$(nvram get "${IFACE}_ssid")"
			
			IFACE_MACS="$(wl -i "$IFACE" assoclist)"
			if [ "$IFACE_MACS" != "" ]; then
				[ -z "$1" ] && printf "${BOLD}%-30s%-20s%-20s%-15s%-15s%-10s%-5s${CLEARFORMAT}\\n" "HOSTNAME" "IP" "MAC" "CONNECTED" "RX/TX" "RSSI" "PHY"
				IFS=$'\n'
				for GUEST_MAC in $IFACE_MACS; do
					GUEST_MACADDR="$(echo "$GUEST_MAC" | awk '{print $2}')"
					GUEST_ARPINFO="$(echo "$ARPDUMP" | grep "$IFACE" | grep -i "$GUEST_MACADDR" | grep -v "$(nvram get lan_ipaddr | cut -d'.' -f1-3)")"
					GUEST_IPADDR="$(echo "$GUEST_ARPINFO" | awk '{print $2}' | sed 's/(//g;s/)//g')"
					GUEST_HOST=""
					
					if [ -z "$GUEST_IPADDR" ]; then
						GUEST_IPADDR=$(grep -i "$GUEST_MACADDR" /var/lib/misc/dnsmasq.leases | awk '{print $3}')
					fi
					
					if [ -n "$GUEST_IPADDR" ]; then
						GUEST_HOST="$(arp "$GUEST_IPADDR" | grep "$IFACE" | awk '{print $1}' | cut -f1 -d ".")"
						if [ "$GUEST_HOST" = "?" ]; then
							GUEST_HOST=$(grep -i "$GUEST_MACADDR" /var/lib/misc/dnsmasq.leases | awk '{print $4}')
						fi
						
						if [ "$GUEST_HOST" = "?" ] || [ "$(printf "%s" "$GUEST_HOST" | wc -m)" -le 1 ]; then
							GUEST_HOST="$(nvram get custom_clientlist | grep -ioE "<.*>$GUEST_MACADDR" | awk -F ">" '{print $(NF-1)}' | tr -d '<')" #thanks Adamm00
						fi
						
						if [ -f /opt/bin/dig ]; then
							if [ -z "$GUEST_HOST" ]; then
								GUEST_HOST="$(/opt/bin/dig +short +answer -x "$GUEST_IPADDR" '@'"$(nvram get lan_ipaddr)" | cut -f1 -d'.')"
							fi
						fi
					else
						GUEST_IPADDR="Unknown"
					fi
					
					if [ -z "$GUEST_HOST" ]; then
						GUEST_HOST="Unknown"
					fi
					
					GUEST_HOST=$(echo "$GUEST_HOST" | tr -d '\n')
					GUEST_IPADDR=$(echo "$GUEST_IPADDR" | tr -d '\n')
					GUEST_MACADDR=$(echo "$GUEST_MACADDR" | tr -d '\n')
					GUEST_RSSI=$(wl -i "$IFACE" rssi "$GUEST_MACADDR" | tr -d '\n')
					
					GUEST_STAINFO=$(wl -i "$IFACE" sta_info "$GUEST_MACADDR")
					GUEST_TIMECONNECTED=$(echo "$GUEST_STAINFO" | grep "in network" | awk '{print $3}' | tr -d '\n')
					GUEST_TIMECONNECTED_PRINT=$(printf '%dh:%dm:%ds\n' $((GUEST_TIMECONNECTED/3600)) $((GUEST_TIMECONNECTED%3600/60)) $((GUEST_TIMECONNECTED%60)))
					
					GUEST_TX=$(echo "$GUEST_STAINFO" | grep "rate of last tx pkt" | awk '{print $6}' | tr -d '\n' | awk '{printf("%.0f", $1/1000);}')
					GUEST_RX=$(echo "$GUEST_STAINFO" | grep "rate of last rx pkt" | awk '{print $6}' | tr -d '\n' | awk '{printf("%.0f", $1/1000);}')
					
					GUEST_PHY=""
					if echo "$GUEST_STAINFO" | grep -q "HT caps"; then
						GUEST_PHY="n"
					elif echo "$GUEST_STAINFO" | grep -q "VHT caps"; then
						GUEST_PHY="ac"
					else
						GUEST_PHY="Unknown"
					fi
					
					[ -z "$1" ] && printf "%-30s%-20s%-20s%-15s%-15s%-10s%-5s${CLEARFORMAT}\\n" "$GUEST_HOST" "$GUEST_IPADDR" "$GUEST_MACADDR" "$GUEST_TIMECONNECTED_PRINT" "$GUEST_RX/$GUEST_TX Mbps" "$GUEST_RSSI dBm" "$GUEST_PHY"
					printf "%s,%s,%s,%s,%s,%s,%s,%s,%s\\n" "$IFACE" "$GUEST_HOST" "$GUEST_IPADDR" "$GUEST_MACADDR" "$GUEST_TIMECONNECTED" "$GUEST_RX" "$GUEST_TX" "$GUEST_RSSI" "$GUEST_PHY" >> "$TMPSTATUSOUTPUTFILE"
				done
				unset IFS
			else
				[ -z "$1" ] && printf "${BOLD}${WARN}No clients connected${CLEARFORMAT}\\n\\n"
				printf "%s,,NOCLIENTS,,,,,,\\n" "$IFACE" >> "$TMPSTATUSOUTPUTFILE"
			fi
		fi
	done
	
	mv "$TMPSTATUSOUTPUTFILE" "$STATUSOUTPUTFILE" 2>/dev/null
	[ -z "$1" ] && printf "%75s\\n\\n" "" | tr " " "-"
	[ -z "$1" ] && printf "${BOLD}$PASS%sQuery complete, please see above for results${CLEARFORMAT}\\n\\n" ""
	#######################################################################################################
	renice 0 $$
}

Menu_Diagnostics(){
	printf "\\n${BOLD}This will collect the following. Files are encrypted with a unique random passphrase.${CLEARFORMAT}\\n"
	printf "\\n${BOLD} - iptables rules${CLEARFORMAT}"
	printf "\\n${BOLD} - ebtables rules${CLEARFORMAT}"
	printf "\\n${BOLD} - %s${CLEARFORMAT}" "$SCRIPT_CONF"
	printf "\\n${BOLD} - %s${CLEARFORMAT}" "$DNSCONF"
	printf "\\n${BOLD} - /jffs/scripts/firewall-start${CLEARFORMAT}"
	printf "\\n${BOLD} - /jffs/scripts/service-event${CLEARFORMAT}\\n\\n"
	while true; do
		printf "\\n${BOLD}Do you want to continue? (y/n)${CLEARFORMAT}  "
		read -r confirm
		case "$confirm" in
			y|Y)
				break
			;;
			n|N)
				printf "\\n${BOLD}User declined, returning to menu${CLEARFORMAT}\\n\\n"
				return 1
			;;
			*)
				printf "\\nPlease choose a valid option (y/n)\\n\\n"
			;;
		esac
	done
	
	printf "\\n\\n${BOLD}Generating %s diagnostics...${CLEARFORMAT}\\n\\n" "$SCRIPT_NAME"
	
	DIAGPATH="/tmp/${SCRIPT_NAME}Diag"
	mkdir -p "$DIAGPATH"
	
	iptables-save > "$DIAGPATH/iptables.txt"
		
	ebtables -L > "$DIAGPATH/ebtables.txt"
	echo "" >> "$DIAGPATH/ebtables.txt"
	ebtables -t broute -L >> "$DIAGPATH/ebtables.txt"
	
	ip rule show > "$DIAGPATH/iprule.txt"
	ip route show > "$DIAGPATH/iproute.txt"
	ip route show table all | grep "table" | sed 's/.*\(table.*\)/\1/g' | awk '{print $2}' | sort | uniq | grep ovpn > "$DIAGPATH/routetablelist.txt"
	
	while IFS='' read -r line || [ -n "$line" ]; do
		ip route show table "$line" > "$DIAGPATH/iproute_$line.txt"
	done < "$DIAGPATH/routetablelist.txt"
	
	ifconfig -a > "$DIAGPATH/ifconfig.txt"
	
	cp "$SCRIPT_CONF" "$DIAGPATH/$SCRIPT_NAME.conf"
	cp "$DNSCONF" "$DIAGPATH/$SCRIPT_NAME.dnsmasq"
	cp /jffs/scripts/dnsmasq.postconf "$DIAGPATH/dnsmasq.postconf"
	cp /jffs/scripts/firewall-start "$DIAGPATH/firewall-start"
	cp /jffs/scripts/service-event "$DIAGPATH/service-event"
	
	SEC="$(Generate_Random_String 32)"
	tar -czf "/tmp/$SCRIPT_NAME.tar.gz" -C "$DIAGPATH" .
	/usr/sbin/openssl enc -aes-256-cbc -k "$SEC" -e -in "/tmp/$SCRIPT_NAME.tar.gz" -out "/tmp/$SCRIPT_NAME.tar.gz.enc"
	
	Print_Output true "Diagnostics saved to /tmp/$SCRIPT_NAME.tar.gz.enc with passphrase $SEC" "$PASS"
	
	rm -f "/tmp/$SCRIPT_NAME.tar.gz" 2>/dev/null
	rm -rf "$DIAGPATH" 2>/dev/null
	SEC=""
}

Menu_Uninstall(){
	Print_Output true "Removing $SCRIPT_NAME..." "$PASS"
	Auto_Startup delete 2>/dev/null
	Auto_Cron delete 2>/dev/null
	Auto_DNSMASQ delete 2>/dev/null
	Auto_ServiceEvent delete 2>/dev/null
	Auto_ServiceStart delete 2>/dev/null
	Auto_OpenVPNEvent delete 2>/dev/null
	Avahi_Conf delete 2>/dev/null
	if [ "$(Firmware_Version_Check "$(nvram get buildno)")" -lt "$(Firmware_Version_Check 386.3)" ]; then
		Routing_NVRAM deleteall 2>/dev/null
	else
		Routing_VPNDirector deleteall 2>/dev/null
	fi
	Firewall_NAT deleteall 2>/dev/null
	Routing_RPDB delete 2>/dev/null
	Firewall_Chains deleteall 2>/dev/null
	Firewall_NVRAM deleteall "$IFACE" 2>/dev/null
	Iface_Manage deleteall 2>/dev/null
	DHCP_Conf deleteall 2>/dev/null
	LOCKFILE=/tmp/addonwebui.lock
	FD=386
	eval exec "$FD>$LOCKFILE"
	flock -x "$FD"
	Get_WebUI_Page "$SCRIPT_DIR/YazFi_www.asp"
	if [ -n "$MyPage" ] && [ "$MyPage" != "none" ] && [ -f "/tmp/menuTree.js" ]; then
		sed -i "\\~$MyPage~d" /tmp/menuTree.js
		umount /www/require/modules/menuTree.js
		mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js
		rm -f "$SCRIPT_WEBPAGE_DIR/$MyPage"
		rm -f "$SCRIPT_WEBPAGE_DIR/$(echo $MyPage | cut -f1 -d'.').title"
	fi
	flock -u "$FD"
	rm -f "$SCRIPT_DIR/YazFi_www.asp" 2>/dev/null
	while true; do
		printf "\\n${BOLD}Do you want to delete %s configuration file(s)? (y/n)${CLEARFORMAT}  " "$SCRIPT_NAME"
		read -r confirm
		case "$confirm" in
			y|Y)
				rm -rf "/jffs/addons/$SCRIPT_NAME.d" 2>/dev/null
				break
			;;
			*)
				break
			;;
		esac
	done
	SETTINGSFILE="/jffs/addons/custom_settings.txt"
	sed -i '/yazfi_version_local/d' "$SETTINGSFILE"
	sed -i '/yazfi_version_server/d' "$SETTINGSFILE"
	Shortcut_Script delete
	rm -f "/jffs/scripts/$SCRIPT_NAME" 2>/dev/null
	Clear_Lock
	Print_Output true "Restarting firewall to complete uninstall" "$PASS"
	service restart_dnsmasq >/dev/null 2>&1
	service restart_firewall >/dev/null 2>&1
}

Show_About(){
	cat <<EOF
About
  $SCRIPT_NAME is a Feature expansion of guest WiFi networks on
AsusWRT-Merlin, including SSID -> VPN, separate subnets per guest
network, pinhole access to LAN resources (e.g. DNS) and more!
License
  $SCRIPT_NAME is free to use under the GNU General Public License
  version 3 (GPL-3.0) https://opensource.org/licenses/GPL-3.0
Help & Support
  https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=13
Source code
  https://github.com/jackyaz/$SCRIPT_NAME
EOF
	printf "\\n"
}
### ###

### function based on @dave14305's FlexQoS show_help function ###
Show_Help(){
	cat <<EOF
Available commands:
  $SCRIPT_NAME about              explains functionality
  $SCRIPT_NAME update             checks for updates
  $SCRIPT_NAME forceupdate        updates to latest version (force update)
  $SCRIPT_NAME startup            runs startup actions such as mount WebUI tab
  $SCRIPT_NAME install            installs script
  $SCRIPT_NAME uninstall          uninstalls script
  $SCRIPT_NAME runnow             apply $SCRIPT_NAME configuration
  $SCRIPT_NAME check              check if $SCRIPT_NAME configuration is still in effect and re-apply if not
  $SCRIPT_NAME bounceclients      restart guest network radios
  $SCRIPT_NAME status             print information about clients connected to $SCRIPT_NAME guest networks
  $SCRIPT_NAME check              check if $SCRIPT_NAME configuration is still in effect and re-apply if not
  $SCRIPT_NAME userscripts        run userscripts (if any have been created)
  $SCRIPT_NAME rejectlogging      toggle whether rejected packets are logged to syslog
  $SCRIPT_NAME develop            switch to development branch
  $SCRIPT_NAME stable             switch to stable branch
EOF
	printf "\\n"
}
### ###

if [ -f "$SCRIPT_DIR/S98YazFiMonitor" ]; then
	rm -f "$SCRIPT_DIR/YazFiMonitor"
	rm -f "$SCRIPT_DIR/YazFiMonitord"
	rm -f "$SCRIPT_DIR/sc.func"
	rm -f "$SCRIPT_DIR/S98YazFiMonitor"
fi

if [ ! -f /opt/bin/qrencode ] && [ -f /opt/bin/opkg ]; then
	opkg update
	opkg install qrencode
fi

if [ -z "$1" ]; then
	Create_Dirs
	Create_Symlinks
	Auto_Startup create 2>/dev/null
	Auto_Cron create 2>/dev/null
	Auto_DNSMASQ create 2>/dev/null
	Auto_ServiceEvent create 2>/dev/null
	Auto_ServiceStart create 2>/dev/null
	Auto_OpenVPNEvent create 2>/dev/null
	Shortcut_Script create
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
		Check_Lock
		Print_Output true "Firewall restarted - sleeping 30s before running $SCRIPT_NAME" "$PASS"
		sleep 30
		Config_Networks
		Clear_Lock
		exit 0
	;;
	check)
		if [ "$(grep -c "NextDNS" /jffs/scripts/dnsmasq.postconf)" -gt 0 ]; then
			if [ "$(grep -c "exit 0" /jffs/scripts/dnsmasq.postconf)" -gt 0 ]; then
				sed -i '/exit 0/d' /jffs/scripts/dnsmasq.postconf
				service restart_dnsmasq
			fi
		fi
		if ! iptables -nL | grep -q "YazFi"; then
			Check_Lock
			Print_Output true "$SCRIPT_NAME firewall rules not detected during persistence check, re-applying rules" "$WARN"
			Config_Networks
			Clear_Lock
			exit 0
		fi
		
		if ! Conf_Exists; then
			exit 1
		fi
		
		if ! Conf_Validate; then
			exit 1
		fi
		
		. $SCRIPT_CONF
		WIRELESSRESTART="false"
		for IFACE in $IFACELIST; do
			if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_ENABLED")" = "true" ]; then
				if [ "$(nvram get "${IFACE}_lanaccess")" != "on" ]; then
					nvram set "$IFACE"_lanaccess=on
					WIRELESSRESTART="true"
				fi
			fi
		done
		
		if [ "$WIRELESSRESTART" = "true" ]; then
			nvram commit
			service restart_wireless >/dev/null 2>&1
		fi
		
		exit 0
	;;
	startup)
		sleep 12
		Create_Dirs
		Create_Symlinks
		Mount_WebUI
		exit 0
	;;
	bounceclients)
		. "$SCRIPT_CONF"
		Iface_BounceClients
		exit 0;
	;;
	service_event)
		if [ "$2" = "restart" ] && [ "$3" = "wireless" ]; then
			Check_Lock
			Print_Output true "Wireless restarted - sleeping 30s before running $SCRIPT_NAME" "$PASS"
			sleep 30
			Config_Networks
			Clear_Lock
		elif [ "$2" = "start" ] && [ "$3" = "$SCRIPT_NAME" ]; then
			Conf_FromSettings
			Print_Output true "WebUI config updated - running $SCRIPT_NAME" "$PASS"
			Check_Lock
			Config_Networks
			Clear_Lock
		elif [ "$2" = "start" ] && [ "$3" = "${SCRIPT_NAME}checkupdate" ]; then
			Update_Check
			exit 0
		elif [ "$2" = "start" ] && [ "$3" = "${SCRIPT_NAME}doupdate" ]; then
			Update_Version force unattended
			exit 0
		elif [ "$2" = "start" ] && [ "$3" = "${SCRIPT_NAME}connectedclients" ]; then
			STATUSOUTPUTFILE="$SCRIPT_DIR/.connectedclients"
			rm -f "$STATUSOUTPUTFILE"
			sleep 2
			Menu_Status outputtofile
			exit 0
		fi
		exit 0
	;;
	openvpn)
		if echo "$2" | grep -q tun1 && [ "$3" = "route-up" ]; then
			Print_Output true "VPN tunnel route just came up, running YazFi to fix RPDB routing" "$PASS"
			sleep 5
			
			if ! Conf_Exists; then
				return 1
			fi
			
			if ! Conf_Validate; then
				return 1
			fi
			
			. $SCRIPT_CONF
			
			for IFACE in $IFACELIST; do
				if [ "$(eval echo '$'"$(Get_Iface_Var "$IFACE")_ENABLED")" = "true" ]; then
					Routing_RPDB create "$IFACE" 2>/dev/null
				fi
			done
		fi
	;;
	status)
		Menu_Status
		exit 0
	;;
	statustofile)
		Menu_Status outputtofile
		exit 0
	;;
	userscripts)
		Execute_UserScripts
		exit 0
	;;
	rejectlogging)
		if [ -f "$SCRIPT_DIR/.rejectlogging" ]; then
			rm -f "$SCRIPT_DIR/.rejectlogging"
		else
			touch "$SCRIPT_DIR/.rejectlogging"
		fi
		service restart_firewall >/dev/null 2>&1
		exit 0
	;;
	update)
		Update_Version unattended
		exit 0
	;;
	forceupdate)
		Update_Version force unattended
		exit 0
	;;
	setversion)
		Set_Version_Custom_Settings local "$SCRIPT_VERSION"
		Set_Version_Custom_Settings server "$SCRIPT_VERSION"
		Create_Dirs
		Create_Symlinks
		Auto_Startup create 2>/dev/null
		Auto_Cron create 2>/dev/null
		Auto_DNSMASQ create 2>/dev/null
		Auto_ServiceEvent create 2>/dev/null
		Auto_ServiceStart create 2>/dev/null
		Auto_OpenVPNEvent create 2>/dev/null
		Shortcut_Script create
		exit 0
	;;
	postupdate)
		Create_Dirs
		Create_Symlinks
		Auto_Startup create 2>/dev/null
		Auto_Cron create 2>/dev/null
		Auto_DNSMASQ create 2>/dev/null
		Auto_ServiceEvent create 2>/dev/null
		Auto_ServiceStart create 2>/dev/null
		Auto_OpenVPNEvent create 2>/dev/null
		Shortcut_Script create
		exit 0
	;;
	uninstall)
		Menu_Uninstall
		exit 0
	;;
	develop)
		SCRIPT_BRANCH="develop"
		SCRIPT_REPO="https://raw.githubusercontent.com/jackyaz/$SCRIPT_NAME/$SCRIPT_BRANCH"
		Update_Version force
		exit 0
	;;
	stable)
		SCRIPT_BRANCH="master"
		SCRIPT_REPO="https://raw.githubusercontent.com/jackyaz/$SCRIPT_NAME/$SCRIPT_BRANCH"
		Update_Version force
		exit 0
	;;
	about)
		ScriptHeader
		Show_About
		exit 0
	;;
	help)
		ScriptHeader
		Show_Help
		exit 0
	;;
	*)
		ScriptHeader
		Print_Output false "Command not recognised." "$ERR"
		Print_Output false "For a list of available commands run: $SCRIPT_NAME help"
		exit 1
	;;
esac
