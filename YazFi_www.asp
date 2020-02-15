<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title>YazFi</title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<style>
p {
font-weight: bolder;
}

thead.collapsible {
  color: white;
  padding: 0px;
  width: 100%;
  border: none;
  text-align: left;
  outline: none;
  cursor: pointer;
}

thead.collapsibleparent {
  color: white;
  padding: 0px;
  width: 100%;
  border: none;
  text-align: left;
  outline: none;
  cursor: pointer;
}

.collapsiblecontent {
  padding: 0px;
  max-height: 0;
  overflow: hidden;
  border: none;
  transition: max-height 0.2s ease-out;
}

.SettingsTable {
  table-layout: fixed !important;
  width: 750px !important;
  text-align: left;
}

.SettingsTable input {
  text-align: center;
}

.SettingsTable th {
  background-color:#1F2D35 !important;
  background:#2F3A3E !important;
  border-bottom:none !important;
  border-top:none !important;
  font-size: 12px !important;
  color: white !important;
  padding: 4px !important;
  font-weight: bolder !important;
}

.SettingsTable td {
  padding: 4px !important;
  word-wrap: break-word !important;
  overflow-wrap: break-word !important;
  border-right: none;
  border-left: none;
}

.SettingsTable a {
  font-weight: bolder !important;
  text-decoration: underline !important;
}

.SettingsTable th:first-child{
  border-left: none !important;
}

.SettingsTable th:last-child {
  border-right: none !important;
}
</style>
<script language="JavaScript" type="text/javascript" src="/js/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmhist.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmmenu.js"></script>
<script language="JavaScript" type="text/javascript" src="/client_function.js"></script>
<script language="JavaScript" type="text/javascript" src="/validator.js"></script>
<script language="JavaScript" type="text/javascript" src="/base64.js"></script>
<script>
function get_conf_file(){
	$.ajax({
		url: '/ext/YazFi/config.htm',
		dataType: 'text',
		error: function(xhr){
			setTimeout("get_conf_file();", 1000);
		},
		success: function(data){
			var settings=data.split("\n");
			settings.reverse();
			var settingcount=settings.length;
			window["yazfi_settings"] = new Array();
			for (var i = 0; i < settingcount; i++) {
				var commentstart=settings[i].indexOf("#");
				if (commentstart != -1){
					continue
				}
				var setting=settings[i].split("=");
				window["yazfi_settings"].unshift(setting);
				}
				$("#table_buttons").before(BuildConfigTable("wl0","2.4GHz Guest Networks"));
				$("#table_buttons").before(BuildConfigTable("wl1","5GHz-1 Guest Networks"));
				$("#table_buttons").before(BuildConfigTable("wl2","5GHz-2 Guest Networks"));
				for (var i = 0; i < window["yazfi_settings"].length; i++) {
					window["yazfi_" + window["yazfi_settings"][i][0]] = window["yazfi_settings"][i][1];
				}
				AddEventHandlers();
			}
	});
}

function GetCookie(cookiename) {
	var s;
	if ((s = cookie.get("yazfi_"+cookiename)) != null) {
		return cookie.get("yazfi_"+cookiename);
	}
	else {
		return "";
	}
}

function SetCookie(cookiename,cookievalue) {
	cookie.set("yazfi_"+cookiename, cookievalue, 31);
}

function SetCurrentPage(){
	document.form.next_page.value = window.location.pathname.substring(1);
	document.form.current_page.value = window.location.pathname.substring(1);
}

function reload() {
	location.reload(true);
}

function applyRule() {
	var action_script_tmp = "restart_wireless";
	document.form.action_script.value = action_script_tmp;
	var restart_time = document.form.action_wait.value*1;
	parent.showLoading(restart_time, "waiting");
	document.form.submit();
}

function initial(){
	SetCurrentPage();
	show_menu();
	get_conf_file();

/*if (custom_settings.unbound_enable == undefined){document.form.unbound_enable.value = "0";}
else{document.form.unbound_enable.value = custom_settings.unbound_enable;}

if (custom_settings.unbound_control == undefined)
document.form.unbound_control.value = "1";
else
document.form.unbound_control.value = custom_settings.unbound_control;

if (custom_settings.unbound_validator == undefined)
document.form.unbound_validator.value = "1";
else
document.form.unbound_validator.value = custom_settings.unbound_validator;

if (custom_settings.unbound_logdest == undefined)
document.form.unbound_logdest.value = "syslog";
else
document.form.unbound_logdest.value = custom_settings.unbound_logdest;

if (custom_settings.unbound_logextra == undefined)
document.form.unbound_logextra.value = "0";
else
document.form.unbound_logextra.value = custom_settings.unbound_logextra;

if (custom_settings.unbound_verbosity == undefined)
document.form.unbound_verbosity.value = "1";
else
document.form.unbound_verbosity.value = custom_settings.unbound_verbosity;

if (custom_settings.unbound_extended_stats == undefined)
document.form.unbound_extended_stats.value = "0";
else
document.form.unbound_extended_stats.value = custom_settings.unbound_extended_stats;

if (custom_settings.unbound_protocol == undefined)
document.form.unbound_protocol.value = "ip4_only";
else
document.form.unbound_protocol.value = custom_settings.unbound_protocol;

if (custom_settings.unbound_edns_size == undefined)
document.getElementById('unbound_edns_size').value = "1280";
else
document.getElementById('unbound_edns_size').value = custom_settings.unbound_edns_size;

if (custom_settings.unbound_listen_port == undefined)
document.getElementById('unbound_listen_port').value = "53535";
else
document.getElementById('unbound_listen_port').value = custom_settings.unbound_listen_port;

if (custom_settings.unbound_resource == undefined)
document.form.unbound_resource.value = "default";
else
document.form.unbound_resource.value = custom_settings.unbound_resource;

if (custom_settings.unbound_dns64 == undefined)
document.form.unbound_dns64.value = "0";
else
document.form.unbound_dns64.value = custom_settings.unbound_dns64;

hide_dns64(getRadioValue(document.form.unbound_dns64));

if (custom_settings.unbound_dns64_prefix == undefined)
document.getElementById('unbound_dns64_prefix').value = "64:ff9b::/96";
else
document.getElementById('unbound_dns64_prefix').value = custom_settings.unbound_dns64_prefix;

if (custom_settings.unbound_recursion == undefined)
document.form.unbound_recursion.value = "default";
else
document.form.unbound_recursion.value = custom_settings.unbound_recursion;

if (custom_settings.unbound_query_minimize == undefined)
document.form.unbound_query_minimize.value = "1";
else
document.form.unbound_query_minimize.value = custom_settings.unbound_query_minimize;

if (custom_settings.unbound_query_min_strict == undefined)
document.form.unbound_query_min_strict.value = "0";
else
document.form.unbound_query_min_strict.value = custom_settings.unbound_query_min_strict;

if (custom_settings.unbound_ttl_min == undefined)
document.getElementById('unbound_ttl_min').value = "120";
else
document.getElementById('unbound_ttl_min').value = custom_settings.unbound_ttl_min;

if (custom_settings.unbound_rebind_protection == undefined)
document.form.unbound_rebind_protection.value = "1";
else
document.form.unbound_rebind_protection.value = custom_settings.unbound_rebind_protection;

if (custom_settings.unbound_rebind_localhost == undefined)
document.form.unbound_rebind_localhost.value = "1";
else
document.form.unbound_rebind_localhost.value = custom_settings.unbound_rebind_localhost;

if (custom_settings.unbound_domain_insecure == undefined)
document.getElementById('unbound_domain_insecure').value ="<% nvram_get("ntp_server0"); %> <% nvram_get("ntp_server1"); %>";  // TODO Get NTP server 1 and 2 from nvram
else
document.getElementById('unbound_domain_insecure').value = Base64.decode(custom_settings.unbound_domain_insecure);

if (custom_settings.unbound_domain_rebindok == undefined)
document.getElementById('unbound_domain_rebindok').value = "";  // TODO Get NTP server 1 and 2 from nvram
else
document.getElementById('unbound_domain_rebindok').value = Base64.decode(custom_settings.unbound_domain_rebindok);

if (custom_settings.unbound_validator_ntp == undefined)
document.form.unbound_validator_ntp.value = "0";
else
document.form.unbound_validator_ntp.value = custom_settings.unbound_validator_ntp;

if (custom_settings.unbound_statslog == undefined)
document.form.unbound_statslog.value = "0";
else
document.form.unbound_statslog.value = custom_settings.unbound_statslog;*/

}

function applySettings(){
/*if (!validator.numberRange(document.form.unbound_edns_size, 512, 4096) ||
!validator.numberRange(document.form.unbound_listen_port, 1, 65535) ||
!validator.numberRange(document.form.unbound_ttl_min, 0, 1800))
return false;*/

/* Retrieve value from input fields, and store in object */
custom_settings.unbound_enable = document.form.unbound_enable.value;
custom_settings.unbound_control = document.form.unbound_control.value;
custom_settings.unbound_validator = document.form.unbound_validator.value;
custom_settings.unbound_logdest = document.form.unbound_logdest.value;
custom_settings.unbound_logextra = document.form.unbound_logextra.value;
custom_settings.unbound_verbosity = document.form.unbound_verbosity.value;
custom_settings.unbound_extended_stats = document.form.unbound_extended_stats.value;
custom_settings.unbound_protocol = document.form.unbound_protocol.value;
custom_settings.unbound_edns_size = document.getElementById('unbound_edns_size').value;
custom_settings.unbound_listen_port = document.getElementById('unbound_listen_port').value;
custom_settings.unbound_resource = document.form.unbound_resource.value;
custom_settings.unbound_dns64 = document.form.unbound_dns64.value;
custom_settings.unbound_dns64_prefix = document.getElementById('unbound_dns64_prefix').value;
custom_settings.unbound_recursion = document.form.unbound_recursion.value;
custom_settings.unbound_query_minimize = document.form.unbound_query_minimize.value;
custom_settings.unbound_query_min_strict = document.form.unbound_query_min_strict.value;
custom_settings.unbound_ttl_min = document.getElementById('unbound_ttl_min').value;
custom_settings.unbound_rebind_protection = document.form.unbound_rebind_protection.value;
custom_settings.unbound_rebind_localhost = document.form.unbound_rebind_localhost.value;
custom_settings.unbound_domain_rebindok = Base64.encode(document.getElementById('unbound_domain_rebindok').value);
custom_settings.unbound_domain_insecure = Base64.encode(document.getElementById('unbound_domain_insecure').value);
custom_settings.unbound_validator_ntp = document.form.unbound_validator_ntp.value;
custom_settings.unbound_statslog = document.form.unbound_statslog.value;

/* Store object as a string in the amng_custom hidden input field */
document.getElementById('amng_custom').value = JSON.stringify(custom_settings);
}

function BuildConfigTable(prefix,title){
	var charthtml = '<div style="line-height:10px;">&nbsp;</div>';
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="table_config_'+prefix+'">';
	charthtml+='<thead class="collapsible expanded" id="'+prefix+'">';
	charthtml+='<tr>';
	charthtml+='<td colspan="2">'+title+' Configuration (click to expand/collapse)</td>';
	charthtml+='</tr>';
	charthtml+='</thead>';
	charthtml+='<tr>';
	charthtml+='<td colspan="2" align="center" style="padding: 0px;">';
	charthtml+='<div class="collapsiblecontent">';
	
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable SettingsTable">';
	charthtml+='<col style="width:115px;">';
	charthtml+='<col style="width:135px;">';
	charthtml+='<col style="width:115px;">';
	charthtml+='<col style="width:135px;">';
	charthtml+='<col style="width:115px;">';
	charthtml+='<col style="width:135px;">';
	charthtml+='<thead>';
	charthtml+='<tr>';
	charthtml+='<th colspan="2">Guest Network 1</th>';
	charthtml+='<th colspan="2">Guest Network 2</th>';
	charthtml+='<th colspan="2">Guest Network 3</th>';
	charthtml+='</tr>';
	charthtml+='</thead>';
	
	/* ENABLED */
	charthtml+='<tr>';
	charthtml+='<td>Enabled</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_enabled" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_enabled" class="input" value="false" checked>No</td>';
	charthtml+='<td>Enabled</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_enabled" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_enabled" class="input" value="false" checked>No</td>';
	charthtml+='<td>Enabled</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_enabled" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_enabled" class="input" value="false" checked>No</td>';
	charthtml+='</tr>';
	
	/* IPADDR */
	charthtml+='<tr>';
	charthtml+='<td>IP Address</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_15_table" name="yazfi_'+prefix+'1_ipaddr" value="0.0.0.0" onkeypress="return validator.isIPAddr(this, event)" /></td>';
	charthtml+='<td>IP Address</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_15_table" name="yazfi_'+prefix+'2_ipaddr" value="0.0.0.0" onkeypress="return validator.isIPAddr(this, event)" /></td>';
	charthtml+='<td>IP Address</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_15_table" name="yazfi_'+prefix+'3_ipaddr" value="0.0.0.0" onkeypress="return validator.isIPAddr(this, event)" /></td>';
	charthtml+='</tr>';
	
	/* DHCP START */
	charthtml+='<tr>';
	charthtml+='<td>DHCP Start</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_3_table" name="yazfi_'+prefix+'1_dhcpstart" value="2" onkeypress="return validator.isNumber(this, event)" /></td>';
	charthtml+='<td>DHCP Start</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_3_table" name="yazfi_'+prefix+'2_dhcpstart" value="2" onkeypress="return validator.isNumber(this, event)" /></td>';
	charthtml+='<td>DHCP Start</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_3_table" name="yazfi_'+prefix+'3_dhcpstart" value="2" onkeypress="return validator.isNumber(this, event)" /></td>';
	charthtml+='</tr>';
	
	/* DHCP END */
	charthtml+='<tr>';
	charthtml+='<td>DHCP End</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_3_table" name="yazfi_'+prefix+'1_dhcpend" value="254" onkeypress="return validator.isNumber(this, event)" /></td>';
	charthtml+='<td>DHCP End</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_3_table" name="yazfi_'+prefix+'2_dhcpend" value="254" onkeypress="return validator.isNumber(this, event)" /></td>';
	charthtml+='<td>DHCP End</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_3_table" name="yazfi_'+prefix+'3_dhcpend" value="254" onkeypress="return validator.isNumber(this, event)" /></td>';
	charthtml+='</tr>';
	
	/* DNS1 */
	charthtml+='<tr>';
	charthtml+='<td>DNS Server 1</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_15_table" name="yazfi_'+prefix+'1_dns1" value="0.0.0.0" onkeypress="return validator.isIPAddr(this, event)" /></td>';
	charthtml+='<td>DNS Server 1</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_15_table" name="yazfi_'+prefix+'2_dns1" value="0.0.0.0" onkeypress="return validator.isIPAddr(this, event)" /></td>';
	charthtml+='<td>DNS Server 1</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_15_table" name="yazfi_'+prefix+'3_dns1" value="0.0.0.0" onkeypress="return validator.isIPAddr(this, event)" /></td>';
	charthtml+='</tr>';
	
	/* DNS2 */
	charthtml+='<tr>';
	charthtml+='<td>DNS Server 2</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_15_table" name="yazfi_'+prefix+'1_dns2" value="0.0.0.0" onkeypress="return validator.isIPAddr(this, event)" /></td>';
	charthtml+='<td>DNS Server 2</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_15_table" name="yazfi_'+prefix+'2_dns2" value="0.0.0.0" onkeypress="return validator.isIPAddr(this, event)" /></td>';
	charthtml+='<td>DNS Server 2</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_15_table" name="yazfi_'+prefix+'3_dns2" value="0.0.0.0" onkeypress="return validator.isIPAddr(this, event)" /></td>';
	charthtml+='</tr>';
	
	/* FORCEDNS */
	charthtml+='<tr>';
	charthtml+='<td>Force DNS</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_forcedns" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_forcedns" class="input" value="false" checked>No</td>';
	charthtml+='<td>Force DNS</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_forcedns" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_forcedns" class="input" value="false" checked>No</td>';
	charthtml+='<td>Force DNS</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_forcedns" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_forcedns" class="input" value="false" checked>No</td>';
	charthtml+='</tr>';
	
	/* REDIRECTALLTOVPN */
	charthtml+='<tr>';
	charthtml+='<td>Redirect all to VPN</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_redirectalltovpn" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_redirectalltovpn" class="input" value="false" checked>No</td>';
	charthtml+='<td>Redirect all to VPN</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_redirectalltovpn" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_redirectalltovpn" class="input" value="false" checked>No</td>';
	charthtml+='<td>Redirect all to VPN</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_redirectalltovpn" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_redirectalltovpn" class="input" value="false" checked>No</td>';
	charthtml+='</tr>';
	
	/* VPNCLIENTNUMBER */
	charthtml+='<tr>';
	charthtml+='<td>VPN Client No.</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="text" maxlength="1" class="input_3_table" name="yazfi_'+prefix+'1_vpnclientnumber" value="2" onkeypress="return validator.isNumber(this, event)" /></td>';
	charthtml+='<td>VPN Client No.</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="text" maxlength="1" class="input_3_table" name="yazfi_'+prefix+'2_vpnclientnumber" value="2" onkeypress="return validator.isNumber(this, event)" /></td>';
	charthtml+='<td>VPN Client No.</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="text" maxlength="1" class="input_3_table" name="yazfi_'+prefix+'3_vpnclientnumber" value="2" onkeypress="return validator.isNumber(this, event)" /></td>';
	charthtml+='</tr>';
	
	/* TWOWAYTOGUEST */
	charthtml+='<tr>';
	charthtml+='<td>Two way to guest</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_twowaytoguest" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_twowaytoguest" class="input" value="false" checked>No</td>';
	charthtml+='<td>Two way to guest</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_twowaytoguest" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_twowaytoguest" class="input" value="false" checked>No</td>';
	charthtml+='<td>Two way to guest</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_twowaytoguest" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_twowaytoguest" class="input" value="false" checked>No</td>';
	charthtml+='</tr>';
	
	/* ONEWAYTOGUEST */
	charthtml+='<tr>';
	charthtml+='<td>One way to guest</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_onewaytoguest" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_onewaytoguest" class="input" value="false" checked>No</td>';
	charthtml+='<td>One way to guest</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_onewaytoguest" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_onewaytoguest" class="input" value="false" checked>No</td>';
	charthtml+='<td>One way to guest</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_onewaytoguest" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_onewaytoguest" class="input" value="false" checked>No</td>';
	charthtml+='</tr>';
	
	/* CLIENT ISOLATION */
	charthtml+='<tr>';
	charthtml+='<td>Client isolation</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_clientisolation" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_clientisolation" class="input" value="false" checked>No</td>';
	charthtml+='<td>Client isolation</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_clientisolation" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_clientisolation" class="input" value="false" checked>No</td>';
	charthtml+='<td>Client isolation</td><td style="border-right: solid 1px black;"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_clientisolation" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_clientisolation" class="input" value="false" checked>No</td>';
	charthtml+='</tr>';
	
	charthtml+='</table>';
	charthtml+='</div>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='</table>';
	charthtml+='<div style="line-height:10px;">&nbsp;</div>';
	return charthtml;
}

function AddEventHandlers(){
	var coll = document.getElementsByClassName("collapsible");
	var i;
	var height = 0;

	for (i = 0; i < coll.length; i++) {
		coll[i].addEventListener("click", function() {
			this.classList.toggle("active");
			var content = this.nextElementSibling.firstElementChild.firstElementChild.firstElementChild;
			if (content.style.maxHeight){
					content.style.maxHeight = null;
					SetCookie(this.id,"collapsed")
			} else {
					content.style.maxHeight = content.scrollHeight + "px";
					this.parentElement.parentElement.style.maxHeight = (this.parentElement.parentElement.style.maxHeight.substring(0,this.parentElement.parentElement.style.maxHeight.length-2)*1) + content.scrollHeight + "px";
					SetCookie(this.id,"expanded");
				}
		});
		
		if(GetCookie(coll[i].id) == "expanded" || GetCookie(coll[i].id) == ""){
			coll[i].click();
		}
		height=(coll[i].nextElementSibling.firstElementChild.firstElementChild.firstElementChild.style.maxHeight.substring(0,coll[i].nextElementSibling.firstElementChild.firstElementChild.firstElementChild.style.maxHeight.length-2)*1) + height + 21 + 10 + 10 + 10 + 10 + 10;
	}
	
	var coll = document.getElementsByClassName("collapsibleparent");
	var i;
	
	for (i = 0; i < coll.length; i++) {
		coll[i].addEventListener("click", function() {
			this.classList.toggle("active");
			var content = this.nextElementSibling.firstElementChild.firstElementChild.firstElementChild;
			if (content.style.maxHeight){
				content.style.maxHeight = null;
				SetCookie(this.id,"collapsed");
			} else {
				content.style.maxHeight = content.scrollHeight + "px";
				SetCookie(this.id,"expanded");
			}
		});
		if(GetCookie(coll[i].id) == "expanded" || GetCookie(coll[i].id) == ""){
			coll[i].nextElementSibling.firstElementChild.firstElementChild.firstElementChild.style.maxHeight = height + "px";
		} else {
			coll[i].nextElementSibling.firstElementChild.firstElementChild.firstElementChild.style.maxHeight = null;
		}
	}
}
</script>
</head>

<body onload="initial();" onunload="return unload_body();">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<iframe name="hidden_frame" id="hidden_frame" src="about:blank" width="0" height="0" frameborder="0"></iframe>
<form method="post" name="form" action="start_apply.htm" target="hidden_frame">
<input autocomplete="off" autocapitalize="off" type="hidden" name="current_page" value="">
<input autocomplete="off" autocapitalize="off" type="hidden" name="next_page" value="">
<input autocomplete="off" autocapitalize="off" type="hidden" name="group_id" value="">
<input autocomplete="off" autocapitalize="off" type="hidden" name="modified" value="0">
<input autocomplete="off" autocapitalize="off" type="hidden" name="action_mode" value="apply">
<input autocomplete="off" autocapitalize="off" type="hidden" name="action_wait" value="75">
<input autocomplete="off" autocapitalize="off" type="hidden" name="first_time" value="">
<input autocomplete="off" autocapitalize="off" type="hidden" name="action_script" value="">
<input autocomplete="off" autocapitalize="off" type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input autocomplete="off" autocapitalize="off" type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input autocomplete="off" autocapitalize="off" type="hidden" name="amng_custom" id="amng_custom" value="">
<input autocomplete="off" autocapitalize="off" type="hidden" name="action_script" value="">
<table class="content" align="center" cellpadding="0" cellspacing="0">
<tr>
<td width="17">&nbsp;</td>
<td valign="top" width="202">
<div id="mainMenu"></div>
<div id="subMenu"></div></td>
<td valign="top">
<div id="tabMenu" class="submenuBlock"></div>
<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
<tr>
<td align="left" valign="top">
<table width="760px" border="0" cellpadding="5" cellspacing="0" bordercolor="#6b8fa3" class="FormTitle" id="FormTitle">
<tr>
<td bgcolor="#4D595D" colspan="3" valign="top">
<div>&nbsp;</div>
<div class="formfonttitle">YazFi Configuration</div>
<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
<div class="formfontdesc">YazFi extends the features of Guest Networks in Asuswrt-Merlin</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_buttons">
<tr class="apply_gen" valign="top" height="35px">
<td style="background-color:rgb(77, 89, 93);border:0px;">
<input autocomplete="off" autocapitalize="off" name="button" type="button" class="button_gen" onclick="applyRule();" value="Apply"/>
</td>
</tr>
</table>
</td>
</tr>
</table>
</td>
</tr>
</table>
</td>
</tr>
</table>
</form>
<div id="footer"></div>
</body>
</html>
