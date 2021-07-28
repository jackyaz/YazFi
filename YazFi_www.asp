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
p{font-weight:bolder}thead.collapsible-jquery{color:#fff;padding:0;width:100%;border:none;text-align:left;outline:none;cursor:pointer}td.nodata{height:30px!important;border:none!important;text-align:center!important;vertical-align:top!important;font:bolder 16px Arial!important}.SettingsTable{table-layout:fixed!important;width:745px!important;text-align:center}.SettingsTable input{text-align:center}.SettingsTable th{background-color:#1F2D35!important;background:#2F3A3E!important;border-bottom:none!important;border-top:none!important;font-size:12px!important;color:#fff!important;padding:4px!important;font-weight:bolder!important;padding:0!important}.SettingsTable th.bss{color:red!important}.SettingsTable td{padding:4px!important;word-wrap:break-word!important;overflow-wrap:break-word!important;border-right:none;border-left:none}.SettingsTable td.settingname{border-right:solid 1px #000;background-color:#1F2D35!important;background:#2F3A3E!important;font-weight:bolder!important}.SettingsTable td.settingvalue{border-right:solid 1px #000}.SettingsTable th:first-child{border-left:none!important}.SettingsTable th:last-child{border-right:none!important}.SettingsTable .invalid{background-color:#8b0000!important}.SettingsTable .disabled{background-color:#CCC!important;color:#888!important}.SettingsTable label{margin-right:10px!important;vertical-align:top!important}div.sortTableContainer{height:150px;overflow-y:scroll;width:745px}.sortTable{table-layout:fixed!important;border:none}thead.sortTableHeader th{background-image:linear-gradient(#92a0a5 0%,#66757c 100%);border-top:none!important;border-left:none!important;border-right:none!important;border-bottom:1px solid #000!important;font-weight:bolder;padding:2px;text-align:center;color:#fff;position:sticky;top:0;font-size:11px!important}thead.sortTableHeader th:first-child,thead.sortTableHeader th:last-child{border-right:none!important}thead.sortTableHeader th:first-child,thead.sortTableHeader td:first-child{border-left:none!important}tbody.sortTableContent td{border-bottom:1px solid #000!important;border-left:none!important;border-right:1px solid #000!important;border-top:none!important;padding:2px;text-align:center;overflow:hidden!important;white-space:nowrap!important;font-size:12px!important}tbody.sortTableContent tr.sortRow:nth-child(odd) td{background-color:#2F3A3E!important}tbody.sortTableContent tr.sortRow:nth-child(even) td{background-color:#475A5F!important}th.sortable{cursor:pointer}tbody.sortTableContent td a{text-decoration:underline!important}
</style>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/d3.js"></script>
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
		if (Object.prototype.hasOwnProperty.call(custom_settings,prop)){
			if(prop.indexOf('yazfi') != -1 && prop.indexOf('yazfi_version') == -1){
				eval('delete custom_settings.'+prop);
			}
		}
	}
}

function jy_checkIPConflict(CompareItem,sourceIP,sourceMask,compareIP,compareMask){
	var SetIPConflictAttr = function(){
		this.state = false;
		this.ipAddr = '';
		this.mask = '';
		this.netRangeStart = '';
		this.netRangeEnd = '';
		this.netLegalRangeStart = '';
		this.netLegalRangeEnd = '';
	};
	var ipConflict = new SetIPConflictAttr();
	var calculatorNetworkSegmentRange = function(compareIP,compareMask){
		var gatewayIPArray = compareIP.split('.');
		var netMaskArray = compareMask.split('.');
		var ipPoolStartArray = new Array();
		var ipPoolEndArray = new Array();
		var ipActualRange = '';
		var ipLegalRange = '';
		ipPoolStartArray[0] = (gatewayIPArray[0] & 0xFF) & (netMaskArray[0] & 0xFF);
		ipPoolStartArray[1] = (gatewayIPArray[1] & 0xFF) & (netMaskArray[1] & 0xFF);
		ipPoolStartArray[2] = (gatewayIPArray[2] & 0xFF) & (netMaskArray[2] & 0xFF);
		ipPoolStartArray[3] = (gatewayIPArray[3] & 0xFF) & (netMaskArray[3] & 0xFF);
		ipPoolEndArray[0] = (gatewayIPArray[0] & 0xFF) | (~netMaskArray[0] & 0xFF);
		ipPoolEndArray[1] = (gatewayIPArray[1] & 0xFF) | (~netMaskArray[1] & 0xFF);
		ipPoolEndArray[2] = (gatewayIPArray[2] & 0xFF) | (~netMaskArray[2] & 0xFF);
		ipPoolEndArray[3] = (gatewayIPArray[3] & 0xFF) | (~netMaskArray[3] & 0xFF);
		ipActualRange = ipPoolStartArray[0]+'.'+ipPoolStartArray[1]+'.'+ipPoolStartArray[2]+'.'+ipPoolStartArray[3]+'>' +
		ipPoolEndArray[0]+'.'+ipPoolEndArray[1]+'.'+ipPoolEndArray[2]+'.'+ipPoolEndArray[3];
		ipLegalRange = ipPoolStartArray[0]+'.'+ipPoolStartArray[1]+'.'+ipPoolStartArray[2]+'.'+(ipPoolStartArray[3]+1)+'>' +
		ipPoolEndArray[0]+'.'+ipPoolEndArray[1]+'.'+ipPoolEndArray[2]+'.'+(ipPoolEndArray[3] - 1);
		return ipActualRange+'>'+ipLegalRange;
	};
	var checkRangeConflict = function(sourceRangeStart,sourceRangeEnd,compareRangeStart,compareRangeEnd){
		var sourceNetStartNum = inet_network(sourceRangeStart);
		var sourceNetEndNum = inet_network(sourceRangeEnd);
		var compareNetStartNum = inet_network(compareRangeStart);
		var compareNetEndNum = inet_network(compareRangeEnd);
		if( (sourceNetStartNum >= compareNetStartNum && sourceNetStartNum <= compareNetEndNum) || //case 1
		(sourceNetEndNum >= compareNetStartNum && sourceNetEndNum <= compareNetEndNum) || //case 2
		(sourceNetStartNum <= compareNetStartNum && sourceNetStartNum <= compareNetEndNum && //case 3
		sourceNetEndNum >= compareNetStartNum && sourceNetEndNum >= compareNetEndNum) ){
			return true;
		}
		else{
			return false;
		}
	};
	var setIPConflictValue = function(compareIP,compareMask,sourceIP,sourceMask){
		var compareNetRangeArray = '';
		var sourceNetRangeArray = '';
		ipConflict.ipAddr = compareIP;
		ipConflict.mask = compareMask;
		compareNetRangeArray = calculatorNetworkSegmentRange(ipConflict.ipAddr,ipConflict.mask).split('>');
		ipConflict.netRangeStart = compareNetRangeArray[0];
		ipConflict.netRangeEnd = compareNetRangeArray[1];
		ipConflict.netLegalRangeStart = compareNetRangeArray[2];
		ipConflict.netLegalRangeEnd = compareNetRangeArray[3];
		sourceNetRangeArray = calculatorNetworkSegmentRange(sourceIP,sourceMask).split('>');
		ipConflict.state = checkRangeConflict(sourceNetRangeArray[0],sourceNetRangeArray[1],ipConflict.netRangeStart,ipConflict.netRangeEnd);
	};
	var iSourceIndex = 0;
	if(CompareItem.search('VLAN') !== -1){
		iSourceIndex = parseInt(CompareItem.substring(4,5));
		CompareItem = CompareItem.substring(0,4);
	}
	if(CompareItem.search('subnet') !== -1){
		iSourceIndex = parseInt(CompareItem.substring(6,7));
		CompareItem = CompareItem.substring(0,6).toUpperCase();
	}
	switch(CompareItem){
		case 'WAN':
			var wanIP = wanlink_ipaddr();
			var wanMask = wanlink_netmask();
			if(wanIP != '0.0.0.0' && wanIP != '' && wanMask != '0.0.0.0' && wanMask != ''){
				setIPConflictValue(wanIP,wanMask,sourceIP,sourceMask);
			}
		break;
		case 'LAN':
			setIPConflictValue('<% nvram_get("lan_ipaddr"); %>', '<% nvram_get("lan_netmask"); %>', sourceIP, sourceMask);
			break;
			case 'PPTP':
			var pptpIP = '<% nvram_get("pptpd_clients"); %>';
			pptpIP = pptpIP.split('-')[0];
			setIPConflictValue(pptpIP,'255.255.255.0',sourceIP,sourceMask);
		break;
		case 'OpenVPN':
			setIPConflictValue('<% nvram_get("vpn_server_sn"); %>', '<% nvram_get("vpn_server_nm"); %>', sourceIP, sourceMask);
		break;
		case 'VLAN':
			var subnet_rulelist_array = decodeURIComponent("<% nvram_char_to_ascii("","subnet_rulelist"); %>");
			var subnet_rulelist_row = subnet_rulelist_array.split('<');
			var subnet_rulelist_col = subnet_rulelist_row[iSourceIndex].split('>');
			var vlanIP = subnet_rulelist_col[1];
			var vlanMask = subnet_rulelist_col[2];
			setIPConflictValue(vlanIP,vlanMask,sourceIP,sourceMask);
		break;
		case 'SUBNET':
			var gatewayIP = '';
			var netMask = '';
			if(tagged_based_vlan){
				gatewayIP = compareIP;
				netMask = compareMask;
			}
			else{
				var subnet_rulelist_array = decodeURIComponent("<% nvram_char_to_ascii("","subnet_rulelist"); %>");
				var subnet_rulelist_row = subnet_rulelist_array.split('<');
				for(var i = 1; i < subnet_rulelist_row.length; i++){
					var subnet_rulelist_col = subnet_rulelist_row[i].split('>');
					if(subnet_rulelist_col[0].substring(6,7) == iSourceIndex){
						gatewayIP = subnet_rulelist_col[1];
						netMask = subnet_rulelist_col[2];
					}
				}
			}
			setIPConflictValue(gatewayIP,netMask,sourceIP,sourceMask);
		break;
		default:
			setIPConflictValue(compareIP,compareMask,sourceIP,sourceMask);
		break;
	}
	return ipConflict;
}
var clientswl01 = []; var sortnamewl01 = 'Hostname'; var sortdirwl01 = 'asc';
var clientswl02 = []; var sortnamewl02 = 'Hostname'; var sortdirwl02 = 'asc';
var clientdwl03 = []; var sortnamewl03 = 'Hostname'; var sortdirwl03 = 'asc';
var clientswl11 = []; var sortnamewl11 = 'Hostname'; var sortdirwl11 = 'asc';
var clientswl12 = []; var sortnamewl12 = 'Hostname'; var sortdirwl12 = 'asc';
var clientswl13 = []; var sortnamewl13 = 'Hostname'; var sortdirwl13 = 'asc';
var clientswl21 = []; var sortnamewl21 = 'Hostname'; var sortdirwl21 = 'asc';
var clientswl22 = []; var sortnamewl22 = 'Hostname'; var sortdirwl22 = 'asc';
var clientswl23 = []; var sortnamewl23 = 'Hostname'; var sortdirwl23 = 'asc';
var tout;
var bands = 0;
var failedfields = [];

var $j = jQuery.noConflict();

function initial(){
	SetCurrentPage();
	LoadCustomSettings();
	show_menu();
	get_conf_file();
	ScriptUpdateLayout();
	
	document.formScriptActions.action_script.value='start_YazFiconnectedclients';
	document.formScriptActions.submit();
	setTimeout(get_connected_clients_file,5000);
}

function YazHint(hintid){
	var tag_name= document.getElementsByTagName('a');
	for(var i=0;i<tag_name.length;i++){
		tag_name[i].onmouseout=nd;
	}
	hinttext='My text goes here';
	if(hintid == 1) hinttext='Enable YazFi for this Guest Network';
	if(hintid == 2) hinttext='IP address/subnet to use for Guest Network';
	if(hintid == 3) hinttext='Start of DHCP pool (2-253)';
	if(hintid == 4) hinttext='End of DHCP pool (3-254)';
	if(hintid == 5) hinttext='IP address for primary DNS resolver';
	if(hintid == 6) hinttext='IP address for secondary DNS resolver';
	if(hintid == 7) hinttext='Should Guest Network DNS requests be forced/redirected to DNS1? N.B. This setting is ignored if sending to VPN, and VPN Client\'s DNS configuration is Exclusive';
	if(hintid == 8) hinttext='Should Guest Network traffic be sent via VPN?';
	if(hintid == 9) hinttext='The number of the VPN Client to send traffic through (1-5)';
	if(hintid == 10) hinttext='Should LAN/Guest Network traffic have unrestricted access to each other? Cannot be enabled if _ONEWAYTOGUEST is enabled';
	if(hintid == 11) hinttext='Should LAN be able to initiate connections to Guest Network clients (but not the opposite)? Cannot be enabled if _TWOWAYTOGUEST is enabled';
	if(hintid == 12) hinttext='Should Guest Network radio prevent clients from talking to each other?';
	return overlib(hinttext,0,0);
}

function OptionsEnableDisable(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	var prefix = inputname.substring(0,inputname.lastIndexOf('_'));
	
	if(inputvalue == 'false'){
		$j('input[name='+prefix+'_ipaddr]').addClass('disabled');
		$j('input[name='+prefix+'_ipaddr]').prop('disabled',true);
		$j('input[name='+prefix+'_dhcpstart]').addClass('disabled');
		$j('input[name='+prefix+'_dhcpstart]').prop('disabled',true);
		$j('input[name='+prefix+'_dhcpend]').addClass('disabled');
		$j('input[name='+prefix+'_dhcpend]').prop('disabled',true);
		$j('input[name='+prefix+'_dns1]').addClass('disabled');
		$j('input[name='+prefix+'_dns1]').prop('disabled',true);
		$j('input[name='+prefix+'_dns2]').addClass('disabled');
		$j('input[name='+prefix+'_dns2]').prop('disabled',true);
		$j('input[name='+prefix+'_forcedns]').prop('disabled',true);
		$j('input[name='+prefix+'_redirectalltovpn]').prop('disabled',true);
		$j('input[name='+prefix+'_vpnclientnumber]').addClass('disabled');
		$j('input[name='+prefix+'_vpnclientnumber]').prop('disabled',true);
		$j('input[name='+prefix+'_onewaytoguest]').prop('disabled',true);
		$j('input[name='+prefix+'_twowaytoguest]').prop('disabled',true);
		$j('input[name='+prefix+'_clientisolation]').prop('disabled',true);
	}
	else if(inputvalue == 'true'){
		$j('input[name='+prefix+'_ipaddr]').removeClass('disabled');
		$j('input[name='+prefix+'_ipaddr]').prop('disabled',false);
		$j('input[name='+prefix+'_dhcpstart]').removeClass('disabled');
		$j('input[name='+prefix+'_dhcpstart]').prop('disabled',false);
		$j('input[name='+prefix+'_dhcpend]').removeClass('disabled');
		$j('input[name='+prefix+'_dhcpend]').prop('disabled',false);
		$j('input[name='+prefix+'_dns1]').removeClass('disabled');
		$j('input[name='+prefix+'_dns1]').prop('disabled',false);
		$j('input[name='+prefix+'_dns2]').removeClass('disabled');
		$j('input[name='+prefix+'_dns2]').prop('disabled',false);
		$j('input[name='+prefix+'_forcedns]').prop('disabled',false);
		$j('input[name='+prefix+'_redirectalltovpn]').prop('disabled',false);
		$j('input[name='+prefix+'_onewaytoguest]').prop('disabled',false);
		$j('input[name='+prefix+'_twowaytoguest]').prop('disabled',false);
		$j('input[name='+prefix+'_clientisolation]').prop('disabled',false);
		
		if(eval('document.form.'+prefix+'_redirectalltovpn').value == 'true'){
			$j('input[name='+prefix+'_vpnclientnumber]').removeClass('disabled');
			$j('input[name='+prefix+'_vpnclientnumber]').prop('disabled',false);
		}
	}
}

function VPNOptionsEnableDisable(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	var prefix = inputname.substring(0,inputname.lastIndexOf('_'));
	
	if(eval('document.form.'+prefix+'_enabled').value == 'true'){
		if(inputvalue == 'false'){
			$j('input[name='+prefix+'_vpnclientnumber]').addClass('disabled');
			$j('input[name='+prefix+'_vpnclientnumber]').prop('disabled',true);
		}
		else if(inputvalue == 'true'){
			$j('input[name='+prefix+'_vpnclientnumber]').removeClass('disabled');
			$j('input[name='+prefix+'_vpnclientnumber]').prop('disabled',false);
		}
	}
}

function ForceDNSEnableDisable(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	var prefix = inputname.substring(0,inputname.lastIndexOf('_'));
	
	if(eval('document.form.'+prefix+'_enabled').value == 'true'){
		if(inputvalue == 'true'){
			$j('input[name='+prefix+'_dns2]').addClass('disabled');
			$j('input[name='+prefix+'_dns2]').prop('disabled',true);
		}
		else if(inputvalue == 'false'){
			$j('input[name='+prefix+'_dns2]').removeClass('disabled');
			$j('input[name='+prefix+'_dns2]').prop('disabled',false);
		}
	}
}

function Validate_IP(forminput,iptype){
	var inputvalue = forminput.value;
	var inputname = forminput.name;
	if(iptype == 'DNS'){
		if(inputvalue.substring(inputvalue.lastIndexOf('.')) == '.0'){
			forminput.value = inputvalue.substring(0,inputvalue.lastIndexOf('.'))+'.1';
		}
	}
	if(/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(inputvalue)){
		if(iptype != 'DNS'){
			var fixedip = inputvalue.substring(0,inputvalue.lastIndexOf('.'))+'.0';
			$j(forminput).val(fixedip);
			if (/(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)/.test(fixedip)){
				if(! jy_checkIPConflict('LAN',fixedip,'255.255.255.0',document.form.lan_ipaddr.value,document.form.lan_netmask.value).state){
					matchfound=false;
					for(var i = 0; i < bands; i++){
						for(var i2 = 1; i2 <= 3; i2++){
							if('yazfi_wl'+i.toString()+i2.toString()+'_ipaddr' != inputname){
								if(eval('document.form.yazfi_wl'+i.toString()+i2.toString()+'_ipaddr.value') == fixedip){
									matchfound=true;
								}
							}
						}
					}
					if(matchfound){
						$j(forminput).addClass('invalid');
						failedfields.push([$j(forminput),'Conflict with another YazFi network']);
						$j(forminput).on('mouseover',function(){return overlib('Conflict with another YazFi network',0,0);});
						$j(forminput)[0].onmouseout = nd;
						return false;
					}
					else{
						$j(forminput).removeClass('invalid');
						$j(forminput).off('mouseover');
						return true;
					}
				}
				else{
					$j(forminput).addClass('invalid');
					failedfields.push([$j(forminput),'LAN IP conflict']);
					$j(forminput).on('mouseover',function(){return overlib('LAN IP conflict',0,0);});
					$j(forminput)[0].onmouseout = nd;
					
					return false;
				}
			}
			else{
				$j(forminput).addClass('invalid');
				failedfields.push([$j(forminput),'Not a private IP address']);
				$j(forminput).on('mouseover',function(){return overlib('Not a private IP address',0,0);});
				$j(forminput)[0].onmouseout = nd;
				return false;
			}
		}
		else{
			$j(forminput).removeClass('invalid');
			$j(forminput).off('mouseover');
			return true;
		}
	}
	else{
		$j(forminput).addClass('invalid');
		failedfields.push([$j(forminput),'Invalid IP Address']);
		$j(forminput).on('mouseover',function(){return overlib('Invalid IP Address',0,0);});
		$j(forminput)[0].onmouseout = nd;
		return false;
	}
}

function Validate_DHCP(forminput){
	var startend = '';
	var inputname = forminput.name;
	var inputvalue = forminput.value*1;
	
	(inputname.indexOf('start') != -1) ? startend = 'start' : startend = 'end';
	if(startend == 'start'){
		if(inputvalue >= eval('document.form.'+inputname.substring(0,inputname.indexOf('start'))+'end.value')*1){
			$j(forminput).addClass('invalid');
			failedfields.push([$j(forminput),'DHCP start is greater than DHCP end']);
			$j(forminput).on('mouseover',function(){return overlib('DHCP start is greater than DHCP end',0,0);});
			$j(forminput)[0].onmouseout = nd;
			return false;
		}
		else{
			if(inputvalue > 254 || inputvalue < 2){
				$j(forminput).addClass('invalid');
				failedfields.push([$j(forminput),'Value not between 2 and 254']);
				$j(forminput).on('mouseover',function(){return overlib('Value not between 2 and 254',0,0);});
				$j(forminput)[0].onmouseout = nd;
				return false;
			}
			else{
				$j(forminput).removeClass('invalid');
				$j(forminput).off('mouseover');
				return true;
			}
		}
	}
	else{
		if(inputvalue <= eval('document.form.'+inputname.substring(0,inputname.indexOf('end'))+'start.value')*1){
			$j(forminput).addClass('invalid');
			failedfields.push([$j(forminput),'DHCP end is less than DHCP start']);
			$j(forminput).on('mouseover',function(){return overlib('DHCP end is less than DHCP start',0,0);});
			$j(forminput)[0].onmouseout = nd;
			return false;
		}
		else{
			if(inputvalue > 254 || inputvalue < 2){
				$j(forminput).addClass('invalid');
				failedfields.push([$j(forminput),'Value not between 2 and 254']);
				$j(forminput).on('mouseover',function(){return overlib('Value not between 2 and 254',0,0);});
				$j(forminput)[0].onmouseout = nd;
				return false;
			}
			else{
				$j(forminput).removeClass('invalid');
				$j(forminput).off('mouseover');
				return true;
			}
		}
	}
}

function Validate_VPNClientNo(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value*1;
	
	if(inputvalue > 5 || inputvalue < 1){
		$j(forminput).addClass('invalid');
		failedfields.push([$j(forminput),'Value not between 1 and 5']);
		$j(forminput).on('mouseover',function(){return overlib('Value not between 1 and 5',0,0);});
		$j(forminput)[0].onmouseout = nd;
		return false;
	}
	else{
		$j(forminput).removeClass('invalid');
		$j(forminput).off('mouseover');
		return true;
	}
}

function Validate_OneTwoWay(forminput){
	var onetwo = '';
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	
	(inputname.indexOf('oneway') != -1) ? onetwo = 'one' : onetwo = 'two';
	if(onetwo == 'one'){
		if(inputvalue == 'true'){
			eval('document.form.'+inputname.substring(0,inputname.indexOf('one'))+'twowaytoguest.value=false');
		}
	}
	else{
		if(inputvalue == 'true'){
			eval('document.form.'+inputname.substring(0,inputname.indexOf('two'))+'onewaytoguest.value=false');
		}
	}
}

function Validate_All(){
	var validationfailed = false;
	failedfields = [];
	for(var i=0; i < bands; i++){
		for(var i2=1; i2 <= 3; i2++){
			if(! Validate_IP(eval('document.form.yazfi_wl'+i+i2+'_ipaddr'),'IP')){validationfailed=true;}
			if(! Validate_DHCP(eval('document.form.yazfi_wl'+i+i2+'_dhcpstart'))){validationfailed=true;}
			if(! Validate_DHCP(eval('document.form.yazfi_wl'+i+i2+'_dhcpend'))){validationfailed=true;}
			if(! Validate_IP(eval('document.form.yazfi_wl'+i+i2+'_dns1'),'DNS')){validationfailed=true;}
			if(! Validate_IP(eval('document.form.yazfi_wl'+i+i2+'_dns2'),'DNS')){validationfailed=true;}
			if(! Validate_VPNClientNo(eval('document.form.yazfi_wl'+i+i2+'_vpnclientnumber'))){validationfailed=true;}
		}
	}
	
	var failedfieldsstring = '';
	for(var i=0; i < failedfields.length; i++){
		var guestnework = '';
		var prefix = failedfields[i][0].attr('name').split('_')[1];
		if(prefix.startsWith('wl0')){
			guestnetwork = '2.4GHz Guest Network '+prefix.replace('wl0','');
		}
		else if(prefix.startsWith('wl1')){
			guestnetwork = '5GHz Guest Network '+prefix.replace('wl0','');
		}
		else if(prefix.startsWith('wl2')){
			guestnetwork = '5GHz-2 Guest Network '+prefix.replace('wl0','');
		}
		failedfieldsstring += guestnetwork+' - '+failedfields[i][0].parent().parent().children().children()[0].innerHTML+' - '+failedfields[i][1]+'\n';
	}
	
	if(validationfailed){
		alert('Validation for some fields failed, shown below. Please correct invalid values and try again.\n'+failedfieldsstring);
		return false;
	}
	else{
		return true;
	}
}

function get_conf_file(){
	$j.ajax({
		url: '/ext/YazFi/config.htm',
		dataType: 'text',
		error: function(xhr){
			setTimeout(get_conf_file,1000);
		},
		success: function(data){
			var settings = data.split('\n');
			settings.reverse();
			settings = settings.filter(Boolean);
			var settingcount=settings.length;
			window['yazfi_settings'] = [];
			for(var i = 0; i < settingcount; i++){
				var commentstart = settings[i].indexOf('#');
				if (commentstart != -1){
					continue;
				}
				var setting=settings[i].split('=');
				window['yazfi_settings'].unshift(setting);
			}
			if(typeof wl_info == 'undefined' || wl_info == null){
				bands = 2;
				$j('#table_config').append(BuildConfigTable('wl0','2.4GHz Guest Networks'));
				$j('#table_config').append('<tr><td style="padding:0px;height:10px;"></td></tr>');
				$j('#table_config').append(BuildConfigTable('wl1','5GHz Guest Networks'));
			}
			else{
				if(wl_info.band2g_support){
					$j('#table_config').append(BuildConfigTable('wl0','2.4GHz Guest Networks'));
					bands = bands+1;
				}
				if(wl_info.band5g_support){
					$j('#table_config').append('<tr><td style="padding:0px;height:10px;"></td></tr>');
					$j('#table_config').append(BuildConfigTable('wl1','5GHz Guest Networks'));
					bands = bands+1;
				}
				if(wl_info.band5g_2_support){
					$j('#table_config').append('<tr><td style="padding:0px;height:10px;"></td></tr>');
					$j('#table_config').append(BuildConfigTable('wl2','5GHz-2 Guest Networks'));
					bands = bands+1;
				}
			}
			
			$j('#table_config').append('<tr class="apply_gen" valign="top"><td style="background-color:rgb(77,89,93);border-top:0px;border-bottom:0px;height:5px;"></td></tr>');
			var buttonshtml = '<tr class="apply_gen" valign="top" height="35px"><td style="background-color:rgb(77,89,93);border-top:0px;">';
			buttonshtml += '<input name="button" type="button" class="button_gen" onclick="SaveConfig();" value="Apply"/></td></tr>';
			$j('#table_config').append(buttonshtml);
			
			var settingcount = bands*12*3;
			for(var i = 0; i < settingcount; i++){
				var settingname = window['yazfi_settings'][i][0].toLowerCase();
				var settingvalue = window['yazfi_settings'][i][1];
				eval('document.form.yazfi_'+settingname).value = settingvalue;
				if(settingname.indexOf('forcedns') != -1) ForceDNSEnableDisable($j('#yazfi_'+settingname.replace('_forcedns','')+'_fdns_'+settingvalue)[0]);
				if(settingname.indexOf('redirectalltovpn') != -1) VPNOptionsEnableDisable($j('#yazfi_'+settingname.replace('_redirectalltovpn','')+'_redir_'+settingvalue)[0]);
				if(settingname.indexOf('enabled') != -1) OptionsEnableDisable($j('#yazfi_'+settingname.replace('_enabled','')+'_en_'+settingvalue)[0]);
			}
			
			if($j('#firmver').text()*1 < 386.1){
				if(productid == 'RT-AX88U' || productid == 'RT-AX3000'){
					$j('input[name*=clientisolation][value=false]').prop('checked',true);
					$j('input[name*=clientisolation]').attr('disabled',true);
				}
			}
			
			for(var i = 0; i < bands; i++){
				for(var i2 = 1; i2 <= 3; i2++){
					if(eval('document.form.wl'+i+i2+'_bss_enabled').value == 0){
						OptionsEnableDisable($j('#yazfi_wl'+i+i2+'_en_false')[0]);
						$j('input[name=yazfi_wl'+i+i2+'_enabled]').prop('disabled',true);
					}
				}
			}
		}
	});
}

function get_connected_clients_file(){
	d3.csv('/ext/YazFi/connectedclients.htm').then(function(data){
		if(data.length > 0){
			var unique = [];
			var YazFiInterfaces = [];
			for(var i = 0; i < data.length; i++){
				if(!unique[data[i].INTERFACE]){
					YazFiInterfaces.push(data[i].INTERFACE.replace('.',''));
					unique[data[i].INTERFACE] = 1;
				}
			}
			
			$j('#table_connectedclients').empty();
			
			for(var i = 0; i < bands; i++){
				for(var i2 = 1; i2 <= 3; i2++){
					YazFiInterface = 'wl'+i.toString()+i2.toString();
					window['clients'+YazFiInterface] = data.filter(function(item){
						return item.INTERFACE.replace('.','') == YazFiInterface;
					}).map(function(obj){
						return {
							Hostname: obj.HOSTNAME,
							IPAddress: obj.IP,
							MACAddress: obj.MAC,
							Connected: obj.CONNECTED,
							Rx: obj.RX,
							Tx: obj.TX,
							RSSI: obj.RSSI,
							PHY: obj.PHY
						}
					});
					
					if(eval('document.form.yazfi_'+YazFiInterface+'_enabled.value') == "true" && eval('document.form.'+YazFiInterface+'_bss_enabled.value') == 1){
						$j('#table_connectedclients').append(BuildConnectedClientPlaceholderTable(YazFiInterface,eval('document.form.'+YazFiInterface+'_ssid.value')));
						
						if(window['clients'+YazFiInterface].length > 0 && window['clients'+YazFiInterface][0].IPAddress != 'NOCLIENTS'){
							SortTable('sortTable'+YazFiInterface,'clients'+YazFiInterface,eval('sortname'+YazFiInterface)+' '+eval('sortdir'+YazFiInterface).replace('desc','↑').replace('asc','↓').trim(),'sortname'+YazFiInterface,'sortdir'+YazFiInterface);
						}
						else{
							$j('#sortTable'+YazFiInterface).css('height','30px');
							$j('#sortTable'+YazFiInterface).css('overflow-y','hidden');
							$j('#sortTable'+YazFiInterface).append(BuildConnectedClientsTableNoData('sortTable'+YazFiInterface));
						}
					}
				}
			}
		}
		if(document.getElementById('auto_refresh').checked){
			document.formScriptActions.action_script.value='start_YazFiconnectedclients';
			document.formScriptActions.submit();
			tout = setTimeout(get_connected_clients_file,5000);
		}
		AddEventHandlers();
	}).catch(function(){setTimeout(get_connected_clients_file,1000);});
}

function SortTable(tableid,arrayid,sorttext,sortname,sortdir){
	window[sortname] = sorttext.replace('↑','').replace('↓','').trim();
	var sorttype = 'string';
	var sortfield = window[sortname];
	switch(window[sortname]){
		case 'Connected':
			sorttype = 'time';
		break
		case 'Rx':
		case 'Tx':
		case 'RSSI':
			sorttype = 'number';
		break
	}
	
	if(sorttype == 'string'){
		if(sorttext.indexOf('↓') == -1 && sorttext.indexOf('↑') == -1){
			eval(arrayid+' = '+arrayid+'.sort((a,b) => (a.'+sortfield+'.toLowerCase() > b.'+sortfield+'.toLowerCase()) ? 1 : ((b.'+sortfield+'.toLowerCase() > a.'+sortfield+'.toLowerCase()) ? -1 : 0));');
			window[sortdir] = 'asc';
		}
		else if(sorttext.indexOf('↓') != -1){
			eval(arrayid+' = '+arrayid+'.sort((a,b) => (a.'+sortfield+'.toLowerCase() > b.'+sortfield+'.toLowerCase()) ? 1 : ((b.'+sortfield+'.toLowerCase() > a.'+sortfield+'.toLowerCase()) ? -1 : 0));');
			window[sortdir] = 'asc';
		}
		else{
			eval(arrayid+' = '+arrayid+'.sort((a,b) => (a.'+sortfield+'.toLowerCase() < b.'+sortfield+'.toLowerCase()) ? 1 : ((b.'+sortfield+'.toLowerCase() < a.'+sortfield+'.toLowerCase()) ? -1 : 0));');
			window[sortdir] = 'desc';
		}
	}
	else if(sorttype == 'number'){
		if(sorttext.indexOf('↓') == -1 && sorttext.indexOf('↑') == -1){
			eval(arrayid+' = '+arrayid+'.sort((a,b) => parseFloat(a.'+sortfield+'.replace("m","000")) - parseFloat(b.'+sortfield+'.replace("m","000")));');
			window[sortdir] = 'asc';
		}
		else if(sorttext.indexOf('↓') != -1){
			eval(arrayid+' = '+arrayid+'.sort((a,b) => parseFloat(a.'+sortfield+'.replace("m","000")) - parseFloat(b.'+sortfield+'.replace("m","000")));');
			window[sortdir] = 'asc';
		}
		else{
			eval(arrayid+' = '+arrayid+'.sort((a,b) => parseFloat(b.'+sortfield+'.replace("m","000")) - parseFloat(a.'+sortfield+'.replace("m","000")));');
			window[sortdir] = 'desc';
		}
	}
	else if(sorttype == 'time'){
		if(sorttext.indexOf('↓') == -1 && sorttext.indexOf('↑') == -1){
			eval(arrayid+' = '+arrayid+'.sort((a,b) => parseFloat(HHMMSStoS(a.'+sortfield+'.replace("m","000"))) - parseFloat(HHMMSStoS(b.'+sortfield+'.replace("m","000"))));');
			window[sortdir] = 'asc';
		}
		else if(sorttext.indexOf('↓') != -1){
			eval(arrayid+' = '+arrayid+'.sort((a,b) => parseFloat(HHMMSStoS(a.'+sortfield+'.replace("m","000"))) - parseFloat(HHMMSStoS(b.'+sortfield+'.replace("m","000"))));');
			window[sortdir] = 'asc';
		}
		else{
			eval(arrayid+' = '+arrayid+'.sort((a,b) => parseFloat(HHMMSStoS(b.'+sortfield+'.replace("m","000"))) - parseFloat(HHMMSStoS(a.'+sortfield+'.replace("m","000"))));');
			window[sortdir] = 'desc';
		}
	}
	
	$j('#'+tableid).empty();
	$j('#'+tableid).append(BuildConnectedClientsTable(tableid.replace('sortTable','')));
	
	$j('#'+tableid).find('.sortable').each(function(index,element){
		if(element.innerHTML.replace(/ \(.*\)/,'').replace(' ','') == window[sortname]){
			if(window[sortdir] == 'asc'){
				element.innerHTML = element.innerHTML+' ↑';
			}
			else{
				element.innerHTML = element.innerHTML+' ↓';
			}
		}
	});
}

function BuildConnectedClientPlaceholderTable(iface,title){
	var tablehtml = '<div style="line-height:10px;">&nbsp;</div>';
	tablehtml+='<tr><td style="padding:0px;">';
	tablehtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="table_clients_'+iface+'">';
	tablehtml+='<thead class="collapsible-jquery" id="thead_clients_'+iface+'">';
	tablehtml+='<tr>';
	tablehtml+='<td>'+title+' (click to expand/collapse)</td>';
	tablehtml+='</tr>';
	tablehtml+='</thead>';
	tablehtml+='<tr>';
	tablehtml+='<td style="padding:0px;">';
	tablehtml+='<div id="sortTable'+iface+'" class="sortTableContainer" style="height:150px;"></div>';
	tablehtml+='</td>';
	tablehtml+='</tr>';
	tablehtml+='</table>';
	tablehtml+='</td>';
	tablehtml+='</tr>';
	return tablehtml;
}

function BuildConnectedClientsTableNoData(){
	var tablehtml = '<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="sortTable">';
	tablehtml += '<tr>';
	tablehtml += '<td class="nodata">';
	tablehtml += 'No connected clients';
	tablehtml += '</td>';
	tablehtml += '</tr>';
	tablehtml += '</table>';
	return tablehtml;
}

function BuildConnectedClientsTable(name){
	var tablehtml = '<table border="0" cellpadding="0" cellspacing="0" width="100%" class="sortTable">';
	tablehtml += '<col style="width:150px;">';
	tablehtml += '<col style="width:100px;">';
	tablehtml += '<col style="width:100px;">';
	tablehtml += '<col style="width:60px;">';
	tablehtml += '<col style="width:60px;">';
	tablehtml += '<col style="width:65px;">';
	tablehtml += '<col style="width:60px;">';
	tablehtml += '<col style="width:40px;">';
	
	tablehtml += '<thead class="sortTableHeader">';
	tablehtml += '<tr>';
	tablehtml += '<th class="sortable" onclick="SortTable(\'sortTable'+name+'\',\'clients'+name+'\',this.innerHTML.replace(/ \\(.*\\)/,\'\'),\'sortname'+name+'\',\'sortdir'+name+'\')">Hostname</th>';
	tablehtml += '<th class="sortable" onclick="SortTable(\'sortTable'+name+'\',\'clients'+name+'\',this.innerHTML.replace(/ \\(.*\\)/,\'\').replace(\' \',\'\'),\'sortname'+name+'\',\'sortdir'+name+'\')">IP Address</th>';
	tablehtml += '<th class="sortable" onclick="SortTable(\'sortTable'+name+'\',\'clients'+name+'\',this.innerHTML.replace(/ \\(.*\\)/,\'\').replace(\' \',\'\'),\'sortname'+name+'\',\'sortdir'+name+'\')">MAC Address</th>';
	tablehtml += '<th class="sortable" onclick="SortTable(\'sortTable'+name+'\',\'clients'+name+'\',this.innerHTML.replace(/ \\(.*\\)/,\'\'),\'sortname'+name+'\',\'sortdir'+name+'\')">Connected</th>';
	tablehtml += '<th class="sortable" onclick="SortTable(\'sortTable'+name+'\',\'clients'+name+'\',this.innerHTML.replace(/ \\(.*\\)/,\'\'),\'sortname'+name+'\',\'sortdir'+name+'\')">Rx (Mbps)</th>';
	tablehtml += '<th class="sortable" onclick="SortTable(\'sortTable'+name+'\',\'clients'+name+'\',this.innerHTML.replace(/ \\(.*\\)/,\'\'),\'sortname'+name+'\',\'sortdir'+name+'\')">Tx (Mbps)</th>';
	tablehtml += '<th class="sortable" onclick="SortTable(\'sortTable'+name+'\',\'clients'+name+'\',this.innerHTML.replace(/ \\(.*\\)/,\'\'),\'sortname'+name+'\',\'sortdir'+name+'\')">RSSI (dBm)</th>';
	tablehtml += '<th class="sortable" onclick="SortTable(\'sortTable'+name+'\',\'clients'+name+'\',this.innerHTML.replace(/ \\(.*\\)/,\'\'),\'sortname'+name+'\',\'sortdir'+name+'\')">PHY</th>';
	tablehtml += '</tr>';
	tablehtml += '</thead>';
	tablehtml += '<tbody class="sortTableContent">';
	
	for(var i = 0; i < window['clients'+name].length; i++){
		tablehtml += '<tr class="sortRow">';
		tablehtml += '<td>'+window['clients'+name][i].Hostname+'</td>';
		tablehtml += '<td>'+window['clients'+name][i].IPAddress+'</td>';
		tablehtml += '<td>'+window['clients'+name][i].MACAddress+'</td>';
		tablehtml += '<td>'+StoHHMMSS(window['clients'+name][i].Connected)+'</td>';
		tablehtml += '<td>'+window['clients'+name][i].Rx+'</td>';
		tablehtml += '<td>'+window['clients'+name][i].Tx+'</td>';
		tablehtml += '<td>'+window['clients'+name][i].RSSI+'</td>';
		tablehtml += '<td>'+window['clients'+name][i].PHY+'</td>';
		tablehtml += '</tr>';
	}
	tablehtml += '</tbody>';
	tablehtml += '</table>';
	return tablehtml;
}

function BuildConfigTable(prefix,title){
	var tablehtml = '<tr><td style="padding:0px;">';
	tablehtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="table_config_'+prefix+'">';
	tablehtml+='<thead class="collapsible-jquery" id="'+prefix+'">';
	tablehtml+='<tr>';
	tablehtml+='<td>'+title+' (click to expand/collapse)</td>';
	tablehtml+='</tr>';
	tablehtml+='</thead>';
	tablehtml+='<tr>';
	tablehtml+='<td colspan="2" align="center" style="padding:0px;">';
	tablehtml+='<table width="100%" border="0" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable SettingsTable" style="border:0px;">';
	
	tablehtml+='<col style="width:130px;">';
	tablehtml+='<col style="width:205px;">';
	tablehtml+='<col style="width:205px;">';
	tablehtml+='<col style="width:205px;">';
	tablehtml+='<thead>';
	tablehtml+='<tr>';
	tablehtml+='<th>&nbsp;</th>';
	tablehtml+='<th>Guest Network 1</th>';
	tablehtml+='<th>Guest Network 2</th>';
	tablehtml+='<th>Guest Network 3</th>';
	tablehtml+='</tr>';
	tablehtml+='<tr>';
	tablehtml+='<th>&nbsp;</th>';
	tablehtml+='<th>'+eval('document.form.'+prefix+'1_ssid.value')+'</th>';
	tablehtml+='<th>'+eval('document.form.'+prefix+'2_ssid.value')+'</th>';
	tablehtml+='<th>'+eval('document.form.'+prefix+'3_ssid.value')+'</th>';
	tablehtml+='</tr>'
	
	var enabled1 = eval('document.form.'+prefix+'1_bss_enabled.value');
	var enabled2 = eval('document.form.'+prefix+'2_bss_enabled.value');
	var enabled3 = eval('document.form.'+prefix+'3_bss_enabled.value');
	
	if( enabled1 == 0 || enabled2 == 0 || enabled3 == 0){
		tablehtml+='<tr>';
		tablehtml+='<th>&nbsp;</th>';
		if(enabled1 == 0){
			tablehtml+='<th class="bss">Disabled on Guest Network Tab</th>';
		}
		else{
			tablehtml+='<th>&nbsp;</th>';
		}
		if(enabled2 == 0){
			tablehtml+='<th class="bss">Disabled on Guest Network Tab</th>';
		}
		else{
			tablehtml+='<th>&nbsp;</th>';
		}
		if(enabled3 == 0){
			tablehtml+='<th class="bss">Disabled on Guest Network Tab</th>';
		}
		else{
			tablehtml+='<th>&nbsp;</th>';
		}
		tablehtml+='</tr>'
	}
	
	tablehtml+='</thead>';
	
	/* ENABLED */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(1);">Enabled</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_enabled" id="yazfi_'+prefix+'1_en_true" onChange="OptionsEnableDisable(this)" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_enabled" id="yazfi_'+prefix+'1_en_false" onChange="OptionsEnableDisable(this)" class="input" value="false" checked>No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_enabled" id="yazfi_'+prefix+'2_en_true" onChange="OptionsEnableDisable(this)" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_enabled" id="yazfi_'+prefix+'2_en_false" onChange="OptionsEnableDisable(this)" class="input" value="false" checked>No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_enabled" id="yazfi_'+prefix+'3_en_true" onChange="OptionsEnableDisable(this)" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_enabled" id="yazfi_'+prefix+'3_en_false" onChange="OptionsEnableDisable(this)" class="input" value="false" checked>No</td>';
	tablehtml+='</tr>';
	
	/* IPADDR */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(2);">IP Address</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'1_ipaddr" value="0.0.0.0" onkeypress="return validator.isIPAddr(this,event)" onblur="Validate_IP(this,\'IP\')" data-lpignore="true" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'2_ipaddr" value="0.0.0.0" onkeypress="return validator.isIPAddr(this,event)" onblur="Validate_IP(this,\'IP\')" data-lpignore="true" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'3_ipaddr" value="0.0.0.0" onkeypress="return validator.isIPAddr(this,event)" onblur="Validate_IP(this,\'IP\')" data-lpignore="true" /></td>';
	tablehtml+='</tr>';
	
	/* DHCP START */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(3);">DHCP Start</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_6_table" name="yazfi_'+prefix+'1_dhcpstart" value="2" onkeypress="return validator.isNumber(this,event)" onblur="Validate_DHCP(this)" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_6_table" name="yazfi_'+prefix+'2_dhcpstart" value="2" onkeypress="return validator.isNumber(this,event)" onblur="Validate_DHCP(this)" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_6_table" name="yazfi_'+prefix+'3_dhcpstart" value="2" onkeypress="return validator.isNumber(this,event)" onblur="Validate_DHCP(this)" /></td>';
	tablehtml+='</tr>';
	
	/* DHCP END */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(4);">DHCP End</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_6_table" name="yazfi_'+prefix+'1_dhcpend" value="254" onkeypress="return validator.isNumber(this,event)" onblur="Validate_DHCP(this)" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_6_table" name="yazfi_'+prefix+'2_dhcpend" value="254" onkeypress="return validator.isNumber(this,event)" onblur="Validate_DHCP(this)" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_6_table" name="yazfi_'+prefix+'3_dhcpend" value="254" onkeypress="return validator.isNumber(this,event)" onblur="Validate_DHCP(this)" /></td>';
	tablehtml+='</tr>';
	
	/* DNS1 */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(5);">DNS Server 1</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'1_dns1" value="0.0.0.0" onkeypress="return validator.isIPAddr(this,event)" onblur="Validate_IP(this,\'DNS\')" data-lpignore="true" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'2_dns1" value="0.0.0.0" onkeypress="return validator.isIPAddr(this,event)" onblur="Validate_IP(this,\'DNS\')" data-lpignore="true" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'3_dns1" value="0.0.0.0" onkeypress="return validator.isIPAddr(this,event)" onblur="Validate_IP(this,\'DNS\')" data-lpignore="true" /></td>';
	tablehtml+='</tr>';
	
	/* DNS2 */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(6);">DNS Server 2</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'1_dns2" value="0.0.0.0" onkeypress="return validator.isIPAddr(this,event)" onblur="Validate_IP(this,\'DNS\')" data-lpignore="true" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'2_dns2" value="0.0.0.0" onkeypress="return validator.isIPAddr(this,event)" onblur="Validate_IP(this,\'DNS\')" data-lpignore="true" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'3_dns2" value="0.0.0.0" onkeypress="return validator.isIPAddr(this,event)" onblur="Validate_IP(this,\'DNS\')" data-lpignore="true" /></td>';
	tablehtml+='</tr>';
	
	/* FORCEDNS */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(7);">Force DNS</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_forcedns" id="yazfi_'+prefix+'1_fdns_true" onChange="ForceDNSEnableDisable(this)" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_forcedns" id="yazfi_'+prefix+'1_fdns_false" onChange="ForceDNSEnableDisable(this)" class="input" value="false" checked>No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_forcedns" id="yazfi_'+prefix+'2_fdns_true" onChange="ForceDNSEnableDisable(this)" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_forcedns" id="yazfi_'+prefix+'2_fdns_false" onChange="ForceDNSEnableDisable(this)" class="input" value="false" checked>No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_forcedns" id="yazfi_'+prefix+'3_fdns_true" onChange="ForceDNSEnableDisable(this)" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_forcedns" id="yazfi_'+prefix+'3_fdns_false" onChange="ForceDNSEnableDisable(this)" class="input" value="false" checked>No</td>';
	tablehtml+='</tr>';
	
	/* REDIRECTALLTOVPN */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(8);">Redirect all to VPN</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_redirectalltovpn" id="yazfi_'+prefix+'1_redir_true" onChange="VPNOptionsEnableDisable(this)" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_redirectalltovpn" id="yazfi_'+prefix+'1_redir_false" onChange="VPNOptionsEnableDisable(this)" class="input" value="false" checked>No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_redirectalltovpn" id="yazfi_'+prefix+'2_redir_true" onChange="VPNOptionsEnableDisable(this)" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_redirectalltovpn" id="yazfi_'+prefix+'2_redir_false" onChange="VPNOptionsEnableDisable(this)" class="input" value="false" checked>No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_redirectalltovpn" id="yazfi_'+prefix+'3_redir_true" onChange="VPNOptionsEnableDisable(this)" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_redirectalltovpn" id="yazfi_'+prefix+'3_redir_false" onChange="VPNOptionsEnableDisable(this)" class="input" value="false" checked>No</td>';
	tablehtml+='</tr>';
	
	/* VPNCLIENTNUMBER */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(9);">VPN Client No.</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="1" class="input_6_table" name="yazfi_'+prefix+'1_vpnclientnumber" value="2" onkeypress="return validator.isNumber(this,event)" onblur="Validate_VPNClientNo(this)" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="1" class="input_6_table" name="yazfi_'+prefix+'2_vpnclientnumber" value="2" onkeypress="return validator.isNumber(this,event)" onblur="Validate_VPNClientNo(this)" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="1" class="input_6_table" name="yazfi_'+prefix+'3_vpnclientnumber" value="2" onkeypress="return validator.isNumber(this,event)" onblur="Validate_VPNClientNo(this)" /></td>';
	tablehtml+='</tr>';
	
	/* TWOWAYTOGUEST */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(10);">Two way to guest</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_twowaytoguest" class="input" value="true" onchange="Validate_OneTwoWay(this)">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_twowaytoguest" class="input" value="false" onchange="Validate_OneTwoWay(this)" checked>No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_twowaytoguest" class="input" value="true" onchange="Validate_OneTwoWay(this)" >Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_twowaytoguest" class="input" value="false" onchange="Validate_OneTwoWay(this)" checked>No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_twowaytoguest" class="input" value="true" onchange="Validate_OneTwoWay(this)" >Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_twowaytoguest" class="input" value="false" onchange="Validate_OneTwoWay(this)" checked>No</td>';
	tablehtml+='</tr>';
	
	/* ONEWAYTOGUEST */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(11);">One way to guest</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_onewaytoguest" class="input" value="true" onchange="Validate_OneTwoWay(this)" >Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_onewaytoguest" class="input" value="false" onchange="Validate_OneTwoWay(this)" checked>No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_onewaytoguest" class="input" value="true" onchange="Validate_OneTwoWay(this)" >Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_onewaytoguest" class="input" value="false" onchange="Validate_OneTwoWay(this)" checked>No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_onewaytoguest" class="input" value="true" onchange="Validate_OneTwoWay(this)" >Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_onewaytoguest" class="input" value="false" onchange="Validate_OneTwoWay(this)" checked>No</td>';
	tablehtml+='</tr>';
	
	/* CLIENT ISOLATION */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(12);">Client isolation</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_clientisolation" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_clientisolation" class="input" value="false" checked>No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_clientisolation" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_clientisolation" class="input" value="false" checked>No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_clientisolation" class="input" value="true" >Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_clientisolation" class="input" value="false" checked>No</td>';
	tablehtml+='</tr>';
	
	tablehtml+='</table>';
	tablehtml+='</td>';
	tablehtml+='</tr>';
	tablehtml+='</table>';

	tablehtml+='</td></tr>';

	return tablehtml;
}

function SetCurrentPage(){
	document.form.next_page.value = window.location.pathname.substring(1);
	document.form.current_page.value = window.location.pathname.substring(1);
}

function ScriptUpdateLayout(){
	var localver = GetVersionNumber('local');
	var serverver = GetVersionNumber('server');
	$j('#yazfi_version_local').text(localver);
	
	if(localver != serverver && serverver != 'N/A'){
		$j('#yazfi_version_server').text('Updated version available: '+serverver);
		showhide('btnChkUpdate',false);
		showhide('yazfi_version_server',true);
		showhide('btnDoUpdate',true);
	}
}

function update_status(){
	$j.ajax({
		url: '/ext/YazFi/detect_update.js',
		dataType: 'script',
		error: function(xhr){
			setTimeout(update_status,1000);
		},
		success: function(){
			if (updatestatus == 'InProgress'){
				setTimeout(update_status,1000);
			}
			else{
				document.getElementById('imgChkUpdate').style.display = 'none';
				showhide('yazfi_version_server',true);
				if(updatestatus != 'None'){
					$j('#yazfi_version_server').text('Updated version available: '+updatestatus);
					showhide('btnChkUpdate',false);
					showhide('btnDoUpdate',true);
				}
				else{
					$j('#yazfi_version_server').text('No update available');
					showhide('btnChkUpdate',true);
					showhide('btnDoUpdate',false);
				}
			}
		}
	});
}

function CheckUpdate(){
	showhide('btnChkUpdate',false);
	document.formScriptActions.action_script.value='start_YazFicheckupdate'
	document.formScriptActions.submit();
	document.getElementById('imgChkUpdate').style.display = '';
	setTimeout(update_status,2000);
}

function DoUpdate(){
	document.form.action_script.value = 'start_YazFidoupdate';
	document.form.action_wait.value = 45;
	showLoading();
	document.form.submit();
}

function GetVersionNumber(versiontype){
	var versionprop;
	if(versiontype == 'local'){
		versionprop = custom_settings.yazfi_version_local;
	}
	else if(versiontype == 'server'){
		versionprop = custom_settings.yazfi_version_server;
	}
	
	if(typeof versionprop == 'undefined' || versionprop == null){
		return 'N/A';
	}
	else{
		return versionprop;
	}
}

function GetCookie(cookiename,returntype){
	if (cookie.get('yazfi_'+cookiename) != null){
		return cookie.get('yazfi_'+cookiename);
	}
	else{
		if(returntype == 'string'){
			return '';
		}
		else if(returntype == 'number'){
			return 0;
		}
	}
}

function SetCookie(cookiename,cookievalue){
	cookie.set('yazfi_'+cookiename,cookievalue,10*365);
}

function SaveConfig(){
	if(Validate_All()){
		$j('[name*=yazfi_]').prop('disabled',false);
		document.getElementById('amng_custom').value = JSON.stringify($j('form').serializeObject());
		document.form.action_script.value = 'start_YazFi';
		document.form.action_wait.value = 45;
		showLoading();
		document.form.submit();
	}
	else{
		return false;
	}
}

function AddEventHandlers(){
	$j('.collapsible-jquery').off('click').on('click',function(){
		$j(this).siblings().toggle('fast',function(){
			if($j(this).css('display') == 'none'){
				SetCookie($j(this).siblings()[0].id,'collapsed');
			}
			else{
				SetCookie($j(this).siblings()[0].id,'expanded');
			}
		})
	});
	
	$j('.collapsible-jquery').each(function(index,element){
		if(GetCookie($j(this)[0].id,'string') == 'collapsed'){
			$j(this).siblings().toggle(false);
		}
		else{
			$j(this).siblings().toggle(true);
		}
	});
	
	$j('#auto_refresh').off('click').on('click',function(){ToggleRefresh();});
}

function ToggleRefresh(){
	$j('#auto_refresh').prop('checked',function(i,v){ if(v){get_connected_clients_file();} else{clearTimeout(tout);} });
}

$j.fn.serializeObject = function(){
	var o = custom_settings;
	var a = this.serializeArray();
	$j.each(a,function(){
		if (o[this.name] !== undefined && this.name.indexOf('yazfi') != -1 && this.name.indexOf('version') == -1){
			if (!o[this.name].push){
				o[this.name] = [o[this.name]];
			}
			o[this.name].push(this.value || '');
		} else if (this.name.indexOf('yazfi') != -1 && this.name.indexOf('version') == -1){
			o[this.name] = this.value || '';
		}
	});
	return o;
};

function StoHHMMSS(secs){
	var sec_num = parseInt(secs, 10)
	var hours   = Math.floor(sec_num / 3600)
	var minutes = Math.floor(sec_num / 60) % 60
	var seconds = sec_num % 60
	
	return [hours,minutes,seconds].map(v => v < 10 ? '0'+v : v).filter((v,i) => v !== '00' || i > 0).join(':');
}

function HHMMSStoS(HHMMSS){
	var p = HHMMSS.split(':')
	var s = 0
	var m = 1;
	while (p.length > 0){
		s += m * parseInt(p.pop(), 10);
		m *= 60;
	}
	return s;
}

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
<thead class="collapsible-jquery" id="thead_utilities">
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
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:1px;">
<thead class="collapsible-jquery" id="thead_connectedclients">
<tr><td colspan="2">Connected Guests (click to expand/collapse)</td></tr>
</thead>
<tr class="even">
<th style="width:35%;">Update automatically?</th>
<td>
<label style="color:#FFCC00;display:block;">
<input type="checkbox" checked="" id="auto_refresh" style="padding:0;margin:0;vertical-align:middle;position:relative;top:-1px;" />&nbsp;&nbsp;Table will refresh every 5s</label>
</td>
</tr>
<tr><td colspan="2" style="padding:0px;">
<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:1px;" id="table_connectedclients">
</table>
</td></tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:1px;" id="table_config">
<thead class="collapsible-jquery" id="thead_config">
<tr><td colspan="2">Guest Network Configuration (click to expand/collapse)</td></tr>
</thead>
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
