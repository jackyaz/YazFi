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

thead.collapsible-jquery {
  color: white;
  padding: 0px;
  width: 100%;
  border: none;
  text-align: left;
  outline: none;
  cursor: pointer;
}

.SettingsTable {
  table-layout: fixed !important;
  width: 745px !important;
  text-align: center;
}

.SettingsTable input {
  text-align: center;
}

.SettingsTable th {
  background-color: #1F2D35 !important;
  background: #2F3A3E !important;
  border-bottom: none !important;
  border-top: none !important;
  font-size: 12px !important;
  color: white !important;
  padding: 4px !important;
  font-weight: bolder !important;
  padding: 0px !important;
}

.SettingsTable th.bss {
  color: red !important;
}

.SettingsTable td {
  padding: 4px !important;
  word-wrap: break-word !important;
  overflow-wrap: break-word !important;
  border-right: none;
  border-left: none;
}

.SettingsTable td.settingname {
  border-right: solid 1px black;
  background-color: #1F2D35 !important;
  background: #2F3A3E !important;
  font-weight: bolder !important;
}

.SettingsTable td.settingvalue {
  border-right: solid 1px black;
}

.SettingsTable th:first-child{
  border-left: none !important;
}

.SettingsTable th:last-child {
  border-right: none !important;
}

.SettingsTable .invalid {
  background-color: darkred !important;
}

.SettingsTable .disabled {
  background-color: #CCCCCC !important;
  color: #888888 !important;
}

label.settingvalue {
  margin-right: 10px !important;
  vertical-align: top !important;
}
</style>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/detect.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmhist.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmmenu.js"></script>
<script language="JavaScript" type="text/javascript" src="/client_function.js"></script>
<script language="JavaScript" type="text/javascript" src="/validator.js"></script>
<script language="JavaScript" type="text/javascript" src="/base64.js"></script>
<script>
var custom_settings;

function LoadCustomSettings(){
	custom_settings = <% get_custom_settings(); %>;
	for(var prop in custom_settings){
		if (Object.prototype.hasOwnProperty.call(custom_settings, prop)){
			if(prop.indexOf("yazfi") != -1 && prop.indexOf("yazfi_version") == -1){
				eval("delete custom_settings."+prop);
			}
		}
	}
}
var $j=jQuery.noConflict(),bands=0;function YazHint(a){for(var b=document.getElementsByTagName("a"),c=0;c<b.length;c++)b[c].onmouseout=nd;return hinttext="My text goes here",1==a&&(hinttext="Enable YazFi for this Guest Network"),2==a&&(hinttext="IP address/subnet to use for Guest Network"),3==a&&(hinttext="Start of DHCP pool (2-253)"),4==a&&(hinttext="End of DHCP pool (3-254)"),5==a&&(hinttext="IP address for primary DNS resolver"),6==a&&(hinttext="IP address for secondary DNS resolver"),7==a&&(hinttext="Should Guest Network DNS requests be forced/redirected to DNS1? N.B. This setting is ignored if sending to VPN, and VPN Client's DNS configuration is Exclusive"),8==a&&(hinttext="Should Guest Network traffic be sent via VPN?"),9==a&&(hinttext="The number of the VPN Client to send traffic through (1-5)"),10==a&&(hinttext="Should LAN/Guest Network traffic have unrestricted access to each other? Cannot be enabled if _ONEWAYTOGUEST is enabled"),11==a&&(hinttext="Should LAN be able to initiate connections to Guest Network clients (but not the opposite)? Cannot be enabled if _TWOWAYTOGUEST is enabled"),12==a&&(hinttext="Should Guest Network radio prevent clients from talking to each other?"),overlib(hinttext,HAUTO,VAUTO)}function OptionsEnableDisable(forminput){var inputname=forminput.name,inputvalue=forminput.value,prefix=inputname.substring(0,inputname.lastIndexOf("_"));"false"==inputvalue?($j("input[name="+prefix+"_ipaddr]").addClass("disabled"),$j("input[name="+prefix+"_ipaddr]").prop("disabled",!0),$j("input[name="+prefix+"_dhcpstart]").addClass("disabled"),$j("input[name="+prefix+"_dhcpstart]").prop("disabled",!0),$j("input[name="+prefix+"_dhcpend]").addClass("disabled"),$j("input[name="+prefix+"_dhcpend]").prop("disabled",!0),$j("input[name="+prefix+"_dns1]").addClass("disabled"),$j("input[name="+prefix+"_dns1]").prop("disabled",!0),$j("input[name="+prefix+"_dns2]").addClass("disabled"),$j("input[name="+prefix+"_dns2]").prop("disabled",!0),$j("input[name="+prefix+"_forcedns]").prop("disabled",!0),$j("input[name="+prefix+"_redirectalltovpn]").prop("disabled",!0),$j("input[name="+prefix+"_vpnclientnumber]").addClass("disabled"),$j("input[name="+prefix+"_vpnclientnumber]").prop("disabled",!0),$j("input[name="+prefix+"_onewaytoguest]").prop("disabled",!0),$j("input[name="+prefix+"_twowaytoguest]").prop("disabled",!0),$j("input[name="+prefix+"_clientisolation]").prop("disabled",!0)):"true"==inputvalue&&($j("input[name="+prefix+"_ipaddr]").removeClass("disabled"),$j("input[name="+prefix+"_ipaddr]").prop("disabled",!1),$j("input[name="+prefix+"_dhcpstart]").removeClass("disabled"),$j("input[name="+prefix+"_dhcpstart]").prop("disabled",!1),$j("input[name="+prefix+"_dhcpend]").removeClass("disabled"),$j("input[name="+prefix+"_dhcpend]").prop("disabled",!1),$j("input[name="+prefix+"_dns1]").removeClass("disabled"),$j("input[name="+prefix+"_dns1]").prop("disabled",!1),$j("input[name="+prefix+"_dns2]").removeClass("disabled"),$j("input[name="+prefix+"_dns2]").prop("disabled",!1),$j("input[name="+prefix+"_forcedns]").prop("disabled",!1),$j("input[name="+prefix+"_redirectalltovpn]").prop("disabled",!1),$j("input[name="+prefix+"_onewaytoguest]").prop("disabled",!1),$j("input[name="+prefix+"_twowaytoguest]").prop("disabled",!1),$j("input[name="+prefix+"_clientisolation]").prop("disabled",!1),"true"==eval("document.form."+prefix+"_redirectalltovpn").value&&($j("input[name="+prefix+"_vpnclientnumber]").removeClass("disabled"),$j("input[name="+prefix+"_vpnclientnumber]").prop("disabled",!1)))}function VPNOptionsEnableDisable(forminput){var inputname=forminput.name,inputvalue=forminput.value,prefix=inputname.substring(0,inputname.lastIndexOf("_"));"true"==eval("document.form."+prefix+"_enabled").value&&("false"==inputvalue?($j("input[name="+prefix+"_vpnclientnumber]").addClass("disabled"),$j("input[name="+prefix+"_vpnclientnumber]").prop("disabled",!0)):"true"==inputvalue&&($j("input[name="+prefix+"_vpnclientnumber]").removeClass("disabled"),$j("input[name="+prefix+"_vpnclientnumber]").prop("disabled",!1)))}function Validate_IP(forminput,iptype){var inputvalue=forminput.value,inputname=forminput.name;if("DNS"==iptype&&".0"==inputvalue.substring(inputvalue.lastIndexOf("."))&&(forminput.value=inputvalue.substring(0,inputvalue.lastIndexOf("."))+".1"),/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(inputvalue)){if("DNS"!=iptype){var fixedip=inputvalue.substring(0,inputvalue.lastIndexOf("."))+".0";if($j(forminput).val(fixedip),/(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)/.test(fixedip)){if(!checkIPConflict("LAN",fixedip,"255.255.255.0",document.form.lan_ipaddr.value,document.form.lan_netmask.value).state){matchfound=!1;for(var i=0;i<bands;i++)for(var i2=1;4>i2;i2++)"yazfi_wl"+i.toString()+i2.toString()+"_ipaddr"!=inputname&&eval("document.form.yazfi_wl"+i.toString()+i2.toString()+"_ipaddr.value")==fixedip&&(matchfound=!0);return matchfound?($j(forminput).addClass("invalid"),!1):($j(forminput).removeClass("invalid"),!0)}return $j(forminput).addClass("invalid"),!1}return $j(forminput).addClass("invalid"),!1}return $j(forminput).removeClass("invalid"),!0}return $j(forminput).addClass("invalid"),!1}function Validate_DHCP(forminput){var startend="",inputname=forminput.name,inputvalue=1*forminput.value;return startend=-1==inputname.indexOf("start")?"end":"start","start"==startend?inputvalue>=1*eval("document.form."+inputname.substring(0,inputname.indexOf("start"))+"end.value")?($j(forminput).addClass("invalid"),!1):254<inputvalue||2>inputvalue?($j(forminput).addClass("invalid"),!1):($j(forminput).removeClass("invalid"),!0):inputvalue<=1*eval("document.form."+inputname.substring(0,inputname.indexOf("end"))+"start.value")?($j(forminput).addClass("invalid"),!1):254<inputvalue||2>inputvalue?($j(forminput).addClass("invalid"),!1):($j(forminput).removeClass("invalid"),!0)}function Validate_VPNClientNo(a){var b=a.name,c=1*a.value;return 5<c||1>c?($j(a).addClass("invalid"),!1):($j(a).removeClass("invalid"),!0)}function Validate_OneTwoWay(forminput){var onetwo="",inputname=forminput.name,inputvalue=forminput.value;onetwo=-1==inputname.indexOf("oneway")?"two":"one","one"==onetwo?"true"==inputvalue&&eval("document.form."+inputname.substring(0,inputname.indexOf("one"))+"twowaytoguest.value=false"):"true"==inputvalue&&eval("document.form."+inputname.substring(0,inputname.indexOf("two"))+"onewaytoguest.value=false")}function Validate_All(){for(var validationfailed=!1,i=0;i<bands;i++)for(var i2=1;4>i2;i2++)Validate_IP(eval("document.form.yazfi_wl"+i+i2+"_ipaddr"),"IP")||(validationfailed=!0),Validate_DHCP(eval("document.form.yazfi_wl"+i+i2+"_dhcpstart"))||(validationfailed=!0),Validate_DHCP(eval("document.form.yazfi_wl"+i+i2+"_dhcpend"))||(validationfailed=!0),Validate_IP(eval("document.form.yazfi_wl"+i+i2+"_dns1"),"DNS")||(validationfailed=!0),Validate_IP(eval("document.form.yazfi_wl"+i+i2+"_dns2"),"DNS")||(validationfailed=!0),Validate_VPNClientNo(eval("document.form.yazfi_wl"+i+i2+"_vpnclientnumber"))||(validationfailed=!0);return!validationfailed||(alert("Validation for some fields failed. Please correct invalid values and try again."),!1)}function get_conf_file(){$j.ajax({url:"/ext/YazFi/config.htm",dataType:"text",error:function(){setTimeout(get_conf_file,1e3)},success:function(data){var settings=data.split("\n");settings.reverse(),settings=settings.filter(Boolean);var settingcount=settings.length;window.yazfi_settings=[];for(var commentstart,i=0;i<settingcount;i++)if(commentstart=settings[i].indexOf("#"),-1==commentstart){var setting=settings[i].split("=");window.yazfi_settings.unshift(setting)}wl_info.band2g_support&&($j("#table_buttons").before(BuildConfigTable("wl0","2.4GHz Guest Networks")),++bands),wl_info.band5g_support&&($j("#table_buttons").before(BuildConfigTable("wl1","5GHz-1 Guest Networks")),++bands),wl_info.band5g_2_support&&($j("#table_buttons").before(BuildConfigTable("wl2","5GHz-2 Guest Networks")),++bands);for(var settingcount=3*(12*bands),i=0;i<settingcount;i++){var settingname=window.yazfi_settings[i][0].toLowerCase(),settingvalue=window.yazfi_settings[i][1];eval("document.form.yazfi_"+settingname).value=settingvalue,-1!=settingname.indexOf("redirectalltovpn")&&VPNOptionsEnableDisable($j("#yazfi_"+settingname.replace("_redirectalltovpn","")+"_redir_"+settingvalue)[0]),-1!=settingname.indexOf("enabled")&&OptionsEnableDisable($j("#yazfi_"+settingname.replace("_enabled","")+"_en_"+settingvalue)[0])}386.1>1*$j("#firmver").text()&&("RT-AX88U"==productid||"RT-AX3000"==productid)&&($j("input[name*=clientisolation][value=false]").prop("checked",!0),$j("input[name*=clientisolation]").attr("disabled",!0));for(var i=0;i<bands;i++)for(var i2=1;4>i2;i2++)0==eval("document.form.wl"+i+i2+"_bss_enabled").value&&(OptionsEnableDisable($j("#yazfi_wl"+i+i2+"_en_false")[0]),$j("input[name=yazfi_wl"+i+i2+"_enabled]").prop("disabled",!0));AddEventHandlers()}})}function SetCurrentPage(){document.form.next_page.value=window.location.pathname.substring(1),document.form.current_page.value=window.location.pathname.substring(1)}function ScriptUpdateLayout(){var a=GetVersionNumber("local"),b=GetVersionNumber("server");$j("#yazfi_version_local").text(a),a!=b&&"N/A"!=b&&($j("#yazfi_version_server").text("Updated version available: "+b),showhide("btnChkUpdate",!1),showhide("yazfi_version_server",!0),showhide("btnDoUpdate",!0))}function update_status(){$j.ajax({url:"/ext/YazFi/detect_update.js",dataType:"script",timeout:3e3,error:function(){setTimeout(update_status,1e3)},success:function(){"InProgress"==updatestatus?setTimeout(update_status,1e3):(document.getElementById("imgChkUpdate").style.display="none",showhide("yazfi_version_server",!0),"None"==updatestatus?($j("#yazfi_version_server").text("No update available"),showhide("btnChkUpdate",!0),showhide("btnDoUpdate",!1)):($j("#yazfi_version_server").text("Updated version available: "+updatestatus),showhide("btnChkUpdate",!1),showhide("btnDoUpdate",!0)))}})}function CheckUpdate(){showhide("btnChkUpdate",!1),document.formScriptActions.action_script.value="start_YazFicheckupdate",document.formScriptActions.submit(),document.getElementById("imgChkUpdate").style.display="",setTimeout(update_status,2e3)}function DoUpdate(){document.form.action_script.value="start_YazFidoupdate";document.form.action_wait.value=45,showLoading(),document.form.submit()}function GetVersionNumber(a){var b;return"local"==a?b=custom_settings.yazfi_version_local:"server"==a&&(b=custom_settings.yazfi_version_server),"undefined"==typeof b||null==b?"N/A":b}function GetCookie(a,b){var c;if(null!=(c=cookie.get("yazfi_"+a)))return cookie.get("yazfi_"+a);return"string"==b?"":"number"==b?0:void 0}function SetCookie(a,b){cookie.set("yazfi_"+a,b,31)}function SaveConfig(){if(Validate_All()){$j("[name*=yazfi_]").prop("disabled",!1),document.getElementById("amng_custom").value=JSON.stringify($j("form").serializeObject());document.form.action_script.value="start_YazFi";document.form.action_wait.value=45,showLoading(),document.form.submit()}else return!1}function initial(){SetCurrentPage(),LoadCustomSettings(),show_menu(),get_conf_file(),ScriptUpdateLayout()}function BuildConfigTable(prefix,title){var charthtml="<div style=\"line-height:10px;\">&nbsp;</div>";charthtml+="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable\" id=\"table_config_"+prefix+"\">",charthtml+="<thead class=\"collapsible-jquery\" id=\""+prefix+"\">",charthtml+="<tr>",charthtml+="<td colspan=\"2\">"+title+" Configuration (click to expand/collapse)</td>",charthtml+="</tr>",charthtml+="</thead>",charthtml+="<tr>",charthtml+="<td colspan=\"2\" align=\"center\" style=\"padding: 0px;\">",charthtml+="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable SettingsTable\">",charthtml+="<col style=\"width:130px;\">",charthtml+="<col style=\"width:205px;\">",charthtml+="<col style=\"width:205px;\">",charthtml+="<col style=\"width:205px;\">",charthtml+="<thead>",charthtml+="<tr>",charthtml+="<th>&nbsp;</th>",charthtml+="<th>Guest Network 1</th>",charthtml+="<th>Guest Network 2</th>",charthtml+="<th>Guest Network 3</th>",charthtml+="</tr>",charthtml+="<tr>",charthtml+="<th>&nbsp;</th>",charthtml+="<th>"+eval("document.form."+prefix+"1_ssid.value")+"</th>",charthtml+="<th>"+eval("document.form."+prefix+"2_ssid.value")+"</th>",charthtml+="<th>"+eval("document.form."+prefix+"3_ssid.value")+"</th>",charthtml+="</tr>";var enabled1=eval("document.form."+prefix+"1_bss_enabled.value"),enabled2=eval("document.form."+prefix+"2_bss_enabled.value"),enabled3=eval("document.form."+prefix+"3_bss_enabled.value");return(0==enabled1||0==enabled2||0==enabled3)&&(charthtml+="<tr>",charthtml+="<th>&nbsp;</th>",charthtml+=0==enabled1?"<th class=\"bss\">Disabled on Guest Network Tab</th>":"<th>&nbsp;</th>",charthtml+=0==enabled2?"<th class=\"bss\">Disabled on Guest Network Tab</th>":"<th>&nbsp;</th>",charthtml+=0==enabled3?"<th class=\"bss\">Disabled on Guest Network Tab</th>":"<th>&nbsp;</th>",charthtml+="</tr>"),charthtml+="</thead>",charthtml+="<tr>",charthtml+="<td class=\"settingname\"><a class=\"hintstyle\" href=\"javascript:void(0);\" onclick=\"YazHint(1);\">Enabled</a></td><td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"1_enabled\" id=\"yazfi_"+prefix+"1_en_true\" onChange=\"OptionsEnableDisable(this)\" class=\"input\" value=\"true\">Yes<input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"1_enabled\" id=\"yazfi_"+prefix+"1_en_false\" onChange=\"OptionsEnableDisable(this)\" class=\"input\" value=\"false\" checked>No</td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"2_enabled\" id=\"yazfi_"+prefix+"2_en_true\" onChange=\"OptionsEnableDisable(this)\" class=\"input\" value=\"true\">Yes<input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"2_enabled\" id=\"yazfi_"+prefix+"2_en_false\" onChange=\"OptionsEnableDisable(this)\" class=\"input\" value=\"false\" checked>No</td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"3_enabled\" id=\"yazfi_"+prefix+"3_en_true\" onChange=\"OptionsEnableDisable(this)\" class=\"input\" value=\"true\">Yes<input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"3_enabled\" id=\"yazfi_"+prefix+"3_en_false\" onChange=\"OptionsEnableDisable(this)\" class=\"input\" value=\"false\" checked>No</td>",charthtml+="</tr>",charthtml+="<tr>",charthtml+="<td class=\"settingname\"><a class=\"hintstyle\" href=\"javascript:void(0);\" onclick=\"YazHint(2);\">IP Address</a></td><td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"text\" maxlength=\"15\" class=\"input_20_table\" name=\"yazfi_"+prefix+"1_ipaddr\" value=\"0.0.0.0\" onkeypress=\"return validator.isIPAddr(this, event)\" onblur=\"Validate_IP(this,'IP')\" data-lpignore=\"true\" /></td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"text\" maxlength=\"15\" class=\"input_20_table\" name=\"yazfi_"+prefix+"2_ipaddr\" value=\"0.0.0.0\" onkeypress=\"return validator.isIPAddr(this, event)\" onblur=\"Validate_IP(this,'IP')\" data-lpignore=\"true\" /></td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"text\" maxlength=\"15\" class=\"input_20_table\" name=\"yazfi_"+prefix+"3_ipaddr\" value=\"0.0.0.0\" onkeypress=\"return validator.isIPAddr(this, event)\" onblur=\"Validate_IP(this,'IP')\" data-lpignore=\"true\" /></td>",charthtml+="</tr>",charthtml+="<tr>",charthtml+="<td class=\"settingname\"><a class=\"hintstyle\" href=\"javascript:void(0);\" onclick=\"YazHint(3);\">DHCP Start</a></td><td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"text\" maxlength=\"3\" class=\"input_6_table\" name=\"yazfi_"+prefix+"1_dhcpstart\" value=\"2\" onkeypress=\"return validator.isNumber(this, event)\" onblur=\"Validate_DHCP(this)\" /></td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"text\" maxlength=\"3\" class=\"input_6_table\" name=\"yazfi_"+prefix+"2_dhcpstart\" value=\"2\" onkeypress=\"return validator.isNumber(this, event)\" onblur=\"Validate_DHCP(this)\" /></td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"text\" maxlength=\"3\" class=\"input_6_table\" name=\"yazfi_"+prefix+"3_dhcpstart\" value=\"2\" onkeypress=\"return validator.isNumber(this, event)\" onblur=\"Validate_DHCP(this)\" /></td>",charthtml+="</tr>",charthtml+="<tr>",charthtml+="<td class=\"settingname\"><a class=\"hintstyle\" href=\"javascript:void(0);\" onclick=\"YazHint(4);\">DHCP End</a></td><td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"text\" maxlength=\"3\" class=\"input_6_table\" name=\"yazfi_"+prefix+"1_dhcpend\" value=\"254\" onkeypress=\"return validator.isNumber(this, event)\" onblur=\"Validate_DHCP(this)\" /></td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"text\" maxlength=\"3\" class=\"input_6_table\" name=\"yazfi_"+prefix+"2_dhcpend\" value=\"254\" onkeypress=\"return validator.isNumber(this, event)\" onblur=\"Validate_DHCP(this)\" /></td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"text\" maxlength=\"3\" class=\"input_6_table\" name=\"yazfi_"+prefix+"3_dhcpend\" value=\"254\" onkeypress=\"return validator.isNumber(this, event)\" onblur=\"Validate_DHCP(this)\" /></td>",charthtml+="</tr>",charthtml+="<tr>",charthtml+="<td class=\"settingname\"><a class=\"hintstyle\" href=\"javascript:void(0);\" onclick=\"YazHint(5);\">DNS Server 1</a></td><td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"text\" maxlength=\"15\" class=\"input_20_table\" name=\"yazfi_"+prefix+"1_dns1\" value=\"0.0.0.0\" onkeypress=\"return validator.isIPAddr(this, event)\" onblur=\"Validate_IP(this,'DNS')\" data-lpignore=\"true\" /></td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"text\" maxlength=\"15\" class=\"input_20_table\" name=\"yazfi_"+prefix+"2_dns1\" value=\"0.0.0.0\" onkeypress=\"return validator.isIPAddr(this, event)\" onblur=\"Validate_IP(this,'DNS')\" data-lpignore=\"true\" /></td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"text\" maxlength=\"15\" class=\"input_20_table\" name=\"yazfi_"+prefix+"3_dns1\" value=\"0.0.0.0\" onkeypress=\"return validator.isIPAddr(this, event)\" onblur=\"Validate_IP(this,'DNS')\" data-lpignore=\"true\" /></td>",charthtml+="</tr>",charthtml+="<tr>",charthtml+="<td class=\"settingname\"><a class=\"hintstyle\" href=\"javascript:void(0);\" onclick=\"YazHint(6);\">DNS Server 2</a></td><td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"text\" maxlength=\"15\" class=\"input_20_table\" name=\"yazfi_"+prefix+"1_dns2\" value=\"0.0.0.0\" onkeypress=\"return validator.isIPAddr(this, event)\" onblur=\"Validate_IP(this,'DNS')\" data-lpignore=\"true\" /></td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"text\" maxlength=\"15\" class=\"input_20_table\" name=\"yazfi_"+prefix+"2_dns2\" value=\"0.0.0.0\" onkeypress=\"return validator.isIPAddr(this, event)\" onblur=\"Validate_IP(this,'DNS')\" data-lpignore=\"true\" /></td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"text\" maxlength=\"15\" class=\"input_20_table\" name=\"yazfi_"+prefix+"3_dns2\" value=\"0.0.0.0\" onkeypress=\"return validator.isIPAddr(this, event)\" onblur=\"Validate_IP(this,'DNS')\" data-lpignore=\"true\" /></td>",charthtml+="</tr>",charthtml+="<tr>",charthtml+="<td class=\"settingname\"><a class=\"hintstyle\" href=\"javascript:void(0);\" onclick=\"YazHint(7);\">Force DNS</a></td><td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"1_forcedns\" class=\"input\" value=\"true\">Yes<input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"1_forcedns\" class=\"input\" value=\"false\" checked>No</td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"2_forcedns\" class=\"input\" value=\"true\">Yes<input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"2_forcedns\" class=\"input\" value=\"false\" checked>No</td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"3_forcedns\" class=\"input\" value=\"true\">Yes<input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"3_forcedns\" class=\"input\" value=\"false\" checked>No</td>",charthtml+="</tr>",charthtml+="<tr>",charthtml+="<td class=\"settingname\"><a class=\"hintstyle\" href=\"javascript:void(0);\" onclick=\"YazHint(8);\">Redirect all to VPN</a></td><td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"1_redirectalltovpn\" id=\"yazfi_"+prefix+"1_redir_true\" onChange=\"VPNOptionsEnableDisable(this)\" class=\"input\" value=\"true\">Yes<input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"1_redirectalltovpn\" id=\"yazfi_"+prefix+"1_redir_false\" onChange=\"VPNOptionsEnableDisable(this)\" class=\"input\" value=\"false\" checked>No</td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"2_redirectalltovpn\" id=\"yazfi_"+prefix+"2_redir_true\" onChange=\"VPNOptionsEnableDisable(this)\" class=\"input\" value=\"true\">Yes<input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"2_redirectalltovpn\" id=\"yazfi_"+prefix+"2_redir_false\" onChange=\"VPNOptionsEnableDisable(this)\" class=\"input\" value=\"false\" checked>No</td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"3_redirectalltovpn\" id=\"yazfi_"+prefix+"3_redir_true\" onChange=\"VPNOptionsEnableDisable(this)\" class=\"input\" value=\"true\">Yes<input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"3_redirectalltovpn\" id=\"yazfi_"+prefix+"3_redir_false\" onChange=\"VPNOptionsEnableDisable(this)\" class=\"input\" value=\"false\" checked>No</td>",charthtml+="</tr>",charthtml+="<tr>",charthtml+="<td class=\"settingname\"><a class=\"hintstyle\" href=\"javascript:void(0);\" onclick=\"YazHint(9);\">VPN Client No.</a></td><td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"text\" maxlength=\"1\" class=\"input_6_table\" name=\"yazfi_"+prefix+"1_vpnclientnumber\" value=\"2\" onkeypress=\"return validator.isNumber(this, event)\" onblur=\"Validate_VPNClientNo(this)\" /></td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"text\" maxlength=\"1\" class=\"input_6_table\" name=\"yazfi_"+prefix+"2_vpnclientnumber\" value=\"2\" onkeypress=\"return validator.isNumber(this, event)\" onblur=\"Validate_VPNClientNo(this)\" /></td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"text\" maxlength=\"1\" class=\"input_6_table\" name=\"yazfi_"+prefix+"3_vpnclientnumber\" value=\"2\" onkeypress=\"return validator.isNumber(this, event)\" onblur=\"Validate_VPNClientNo(this)\" /></td>",charthtml+="</tr>",charthtml+="<tr>",charthtml+="<td class=\"settingname\"><a class=\"hintstyle\" href=\"javascript:void(0);\" onclick=\"YazHint(10);\">Two way to guest</a></td><td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"1_twowaytoguest\" class=\"input\" value=\"true\" onchange=\"Validate_OneTwoWay(this)\">Yes<input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"1_twowaytoguest\" class=\"input\" value=\"false\" onchange=\"Validate_OneTwoWay(this)\" checked>No</td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"2_twowaytoguest\" class=\"input\" value=\"true\" onchange=\"Validate_OneTwoWay(this)\" >Yes<input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"2_twowaytoguest\" class=\"input\" value=\"false\" onchange=\"Validate_OneTwoWay(this)\" checked>No</td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"3_twowaytoguest\" class=\"input\" value=\"true\" onchange=\"Validate_OneTwoWay(this)\" >Yes<input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"3_twowaytoguest\" class=\"input\" value=\"false\" onchange=\"Validate_OneTwoWay(this)\" checked>No</td>",charthtml+="</tr>",charthtml+="<tr>",charthtml+="<td class=\"settingname\"><a class=\"hintstyle\" href=\"javascript:void(0);\" onclick=\"YazHint(11);\">One way to guest</a></td><td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"1_onewaytoguest\" class=\"input\" value=\"true\" onchange=\"Validate_OneTwoWay(this)\" >Yes<input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"1_onewaytoguest\" class=\"input\" value=\"false\" onchange=\"Validate_OneTwoWay(this)\" checked>No</td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"2_onewaytoguest\" class=\"input\" value=\"true\" onchange=\"Validate_OneTwoWay(this)\" >Yes<input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"2_onewaytoguest\" class=\"input\" value=\"false\" onchange=\"Validate_OneTwoWay(this)\" checked>No</td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"3_onewaytoguest\" class=\"input\" value=\"true\" onchange=\"Validate_OneTwoWay(this)\" >Yes<input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"3_onewaytoguest\" class=\"input\" value=\"false\" onchange=\"Validate_OneTwoWay(this)\" checked>No</td>",charthtml+="</tr>",charthtml+="<tr>",charthtml+="<td class=\"settingname\"><a class=\"hintstyle\" href=\"javascript:void(0);\" onclick=\"YazHint(12);\">Client isolation</a></td><td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"1_clientisolation\" class=\"input\" value=\"true\">Yes<input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"1_clientisolation\" class=\"input\" value=\"false\" checked>No</td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"2_clientisolation\" class=\"input\" value=\"true\">Yes<input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"2_clientisolation\" class=\"input\" value=\"false\" checked>No</td>",charthtml+="<td class=\"settingvalue\"><input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"3_clientisolation\" class=\"input\" value=\"true\" >Yes<input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"yazfi_"+prefix+"3_clientisolation\" class=\"input\" value=\"false\" checked>No</td>",charthtml+="</tr>",charthtml+="</table>",charthtml+="</td>",charthtml+="</tr>",charthtml+="</table>",charthtml+="<div style=\"line-height:10px;\">&nbsp;</div>",charthtml}function AddEventHandlers(){$j(".collapsible-jquery").click(function(){$j(this).siblings().toggle("fast",function(){"none"==$j(this).css("display")?SetCookie($j(this).siblings()[0].id,"collapsed"):SetCookie($j(this).siblings()[0].id,"expanded")})}),$j(".collapsible-jquery").each(function(){"collapsed"==GetCookie($j(this)[0].id,"string")?$j(this).siblings().toggle(!1):$j(this).siblings().toggle(!0)})}$j.fn.serializeObject=function(){var b=custom_settings,c=this.serializeArray();return $j.each(c,function(){void 0!==b[this.name]&&-1!=this.name.indexOf("yazfi")&&-1==this.name.indexOf("version")?(!b[this.name].push&&(b[this.name]=[b[this.name]]),b[this.name].push(this.value||"")):-1!=this.name.indexOf("yazfi")&&-1==this.name.indexOf("version")&&(b[this.name]=this.value||"")}),b};
</script>
</head>
<body onload="initial();" onunload="return unload_body();">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<iframe name="hidden_frame" id="hidden_frame" src="about:blank" width="0" height="0" frameborder="0"></iframe>
<form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="current_page" value="">
<input type="hidden" name="next_page" value="">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_wait" value="30">
<input type="hidden" name="first_time" value="">
<input type="hidden" name="SystemCmd" value="">
<input type="hidden" name="action_script" value="start_YazFi">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="lan_ipaddr" value="<% nvram_get("lan_ipaddr"); %>">
<input type="hidden" name="lan_netmask" value="<% nvram_get("lan_netmask"); %>">
<input type="hidden" name="wl01_ssid" value="<% nvram_get("wl0.1_ssid"); %>">
<input type="hidden" name="wl02_ssid" value="<% nvram_get("wl0.2_ssid"); %>">
<input type="hidden" name="wl03_ssid" value="<% nvram_get("wl0.3_ssid"); %>">
<input type="hidden" name="wl11_ssid" value="<% nvram_get("wl1.1_ssid"); %>">
<input type="hidden" name="wl12_ssid" value="<% nvram_get("wl1.2_ssid"); %>">
<input type="hidden" name="wl13_ssid" value="<% nvram_get("wl1.3_ssid"); %>">
<input type="hidden" name="wl21_ssid" value="<% nvram_get("wl2.1_ssid"); %>">
<input type="hidden" name="wl22_ssid" value="<% nvram_get("wl2.2_ssid"); %>">
<input type="hidden" name="wl23_ssid" value="<% nvram_get("wl2.3_ssid"); %>">
<input type="hidden" name="wl01_bss_enabled" value="<% nvram_get("wl0.1_bss_enabled"); %>">
<input type="hidden" name="wl02_bss_enabled" value="<% nvram_get("wl0.2_bss_enabled"); %>">
<input type="hidden" name="wl03_bss_enabled" value="<% nvram_get("wl0.3_bss_enabled"); %>">
<input type="hidden" name="wl11_bss_enabled" value="<% nvram_get("wl1.1_bss_enabled"); %>">
<input type="hidden" name="wl12_bss_enabled" value="<% nvram_get("wl1.2_bss_enabled"); %>">
<input type="hidden" name="wl13_bss_enabled" value="<% nvram_get("wl1.3_bss_enabled"); %>">
<input type="hidden" name="wl21_bss_enabled" value="<% nvram_get("wl2.1_bss_enabled"); %>">
<input type="hidden" name="wl22_bss_enabled" value="<% nvram_get("wl2.2_bss_enabled"); %>">
<input type="hidden" name="wl23_bss_enabled" value="<% nvram_get("wl2.3_bss_enabled"); %>">
<input type="hidden" name="amng_custom" id="amng_custom" value="">
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
<div class="formfonttitle" id="scripttitle" style="text-align:center;">YazFi</div>
<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
<div class="formfontdesc">Feature expansion of guest WiFi networks on AsusWRT-Merlin, including SSID -> VPN, separate subnets per guest network, pinhole access to LAN resources (e.g. DNS) and more!</div>
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_utilities">
<thead class="collapsible-jquery" id="scripttools">
<tr><td colspan="2">Utilities (click to expand/collapse)</td></tr>
</thead>
<tr>
<th width="20%">Version information</th>
<td>
<span id="yazfi_version_local" style="color:#FFFFFF;"></span>
&nbsp;&nbsp;&nbsp;
<span id="yazfi_version_server" style="display:none;">Update version</span>
&nbsp;&nbsp;&nbsp;
<input type="button" class="button_gen" onclick="CheckUpdate();" value="Check" id="btnChkUpdate">
<img id="imgChkUpdate" style="display:none;vertical-align:middle;" src="images/InternetScan.gif"/>
<input type="button" class="button_gen" onclick="DoUpdate();" value="Update" id="btnDoUpdate" style="display:none;">
&nbsp;&nbsp;&nbsp;
</td>
</tr>
</table>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_buttons">
<tr class="apply_gen" valign="top" height="35px">
<td style="background-color:rgb(77, 89, 93);border:0px;">
<input name="button" type="button" class="button_gen" onclick="SaveConfig();" value="Apply"/>
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
<form method="post" name="formScriptActions" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="productid" value="<% nvram_get("productid"); %>">
<input type="hidden" name="current_page" value="">
<input type="hidden" name="next_page" value="">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="">
<input type="hidden" name="action_wait" value="">
</form>
<div id="footer"></div>
</body>
</html>
