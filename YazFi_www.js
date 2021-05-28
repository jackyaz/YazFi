var $j=jQuery.noConflict();
var bands = 0;

function YazHint(hintid){
	var tag_name= document.getElementsByTagName('a');
	for(var i=0;i<tag_name.length;i++){
		tag_name[i].onmouseout=nd;
	}
	hinttext="My text goes here";
	if(hintid == 1) hinttext="Enable YazFi for this Guest Network";
	if(hintid == 2) hinttext="IP address/subnet to use for Guest Network";
	if(hintid == 3) hinttext="Start of DHCP pool (2-253)";
	if(hintid == 4) hinttext="End of DHCP pool (3-254)";
	if(hintid == 5) hinttext="IP address for primary DNS resolver";
	if(hintid == 6) hinttext="IP address for secondary DNS resolver";
	if(hintid == 7) hinttext="Should Guest Network DNS requests be forced/redirected to DNS1? N.B. This setting is ignored if sending to VPN, and VPN Client's DNS configuration is Exclusive";
	if(hintid == 8) hinttext="Should Guest Network traffic be sent via VPN?";
	if(hintid == 9) hinttext="The number of the VPN Client to send traffic through (1-5)";
	if(hintid == 10) hinttext="Should LAN/Guest Network traffic have unrestricted access to each other? Cannot be enabled if _ONEWAYTOGUEST is enabled";
	if(hintid == 11) hinttext="Should LAN be able to initiate connections to Guest Network clients (but not the opposite)? Cannot be enabled if _TWOWAYTOGUEST is enabled";
	if(hintid == 12) hinttext="Should Guest Network radio prevent clients from talking to each other?";
	return overlib(hinttext, HAUTO, VAUTO);
}

function OptionsEnableDisable(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	var prefix = inputname.substring(0,inputname.lastIndexOf('_'));
	
	if(inputvalue == "false"){
		$j('input[name='+prefix+'_ipaddr]').addClass("disabled");
		$j('input[name='+prefix+'_ipaddr]').prop("disabled",true);
		$j('input[name='+prefix+'_dhcpstart]').addClass("disabled");
		$j('input[name='+prefix+'_dhcpstart]').prop("disabled",true);
		$j('input[name='+prefix+'_dhcpend]').addClass("disabled");
		$j('input[name='+prefix+'_dhcpend]').prop("disabled",true);
		$j('input[name='+prefix+'_dns1]').addClass("disabled");
		$j('input[name='+prefix+'_dns1]').prop("disabled",true);
		$j('input[name='+prefix+'_dns2]').addClass("disabled");
		$j('input[name='+prefix+'_dns2]').prop("disabled",true);
		$j('input[name='+prefix+'_forcedns]').prop("disabled",true);
		$j('input[name='+prefix+'_redirectalltovpn]').prop("disabled",true);
		$j('input[name='+prefix+'_vpnclientnumber]').addClass("disabled");
		$j('input[name='+prefix+'_vpnclientnumber]').prop("disabled",true);
		$j('input[name='+prefix+'_onewaytoguest]').prop("disabled",true);
		$j('input[name='+prefix+'_twowaytoguest]').prop("disabled",true);
		$j('input[name='+prefix+'_clientisolation]').prop("disabled",true);
	}
	else if(inputvalue == "true"){
		$j('input[name='+prefix+'_ipaddr]').removeClass("disabled");
		$j('input[name='+prefix+'_ipaddr]').prop("disabled",false);
		$j('input[name='+prefix+'_dhcpstart]').removeClass("disabled");
		$j('input[name='+prefix+'_dhcpstart]').prop("disabled",false);
		$j('input[name='+prefix+'_dhcpend]').removeClass("disabled");
		$j('input[name='+prefix+'_dhcpend]').prop("disabled",false);
		$j('input[name='+prefix+'_dns1]').removeClass("disabled");
		$j('input[name='+prefix+'_dns1]').prop("disabled",false);
		$j('input[name='+prefix+'_dns2]').removeClass("disabled");
		$j('input[name='+prefix+'_dns2]').prop("disabled",false);
		$j('input[name='+prefix+'_forcedns]').prop("disabled",false);
		$j('input[name='+prefix+'_redirectalltovpn]').prop("disabled",false);
		$j('input[name='+prefix+'_onewaytoguest]').prop("disabled",false);
		$j('input[name='+prefix+'_twowaytoguest]').prop("disabled",false);
		$j('input[name='+prefix+'_clientisolation]').prop("disabled",false);
		
		if(eval('document.form.'+prefix+'_redirectalltovpn').value == "true"){
			$j('input[name='+prefix+'_vpnclientnumber]').removeClass("disabled");
			$j('input[name='+prefix+'_vpnclientnumber]').prop("disabled",false);
		}
	}
}

function VPNOptionsEnableDisable(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	var prefix = inputname.substring(0,inputname.lastIndexOf('_'));
	
	if(eval("document.form."+prefix+"_enabled").value == "true"){
		if(inputvalue == "false"){
			$j('input[name='+prefix+'_vpnclientnumber]').addClass("disabled");
			$j('input[name='+prefix+'_vpnclientnumber]').prop("disabled",true);
		}
		else if(inputvalue == "true"){
			$j('input[name='+prefix+'_vpnclientnumber]').removeClass("disabled");
			$j('input[name='+prefix+'_vpnclientnumber]').prop("disabled",false);
		}
	}
}

function Validate_IP(forminput,iptype){
	var inputvalue = forminput.value;
	var inputname = forminput.name;
	if(iptype == "DNS"){
		if(inputvalue.substring(inputvalue.lastIndexOf(".")) == ".0"){
			forminput.value = inputvalue.substring(0,inputvalue.lastIndexOf("."))+".1";
		}
	}
	if(/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(inputvalue)){
		if(iptype != "DNS"){
			var fixedip = inputvalue.substring(0,inputvalue.lastIndexOf("."))+".0";
			$j(forminput).val(fixedip);
			if (/(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)/.test(fixedip)){
				if(! checkIPConflict("LAN",fixedip,"255.255.255.0",document.form.lan_ipaddr.value,document.form.lan_netmask.value).state){
					matchfound=false;
					for(var i = 0; i < bands; i++){
						for(var i2 = 1; i2 < 4; i2++){
							if("yazfi_wl"+i.toString()+i2.toString()+"_ipaddr" != inputname){
								if(eval("document.form.yazfi_wl"+i.toString()+i2.toString()+"_ipaddr.value") == fixedip){
									matchfound=true;
								}
							}
						}
					}
					if(matchfound){
						$j(forminput).addClass("invalid");
						return false;
					}
					else{
						$j(forminput).removeClass("invalid");
						return true;
					}
				}
				else{
					$j(forminput).addClass("invalid");
					return false;
				}
			}
			else{
				$j(forminput).addClass("invalid");
				return false;
			}
		}
		else{
			$j(forminput).removeClass("invalid");
			return true;
		}
	}
	else{
		$j(forminput).addClass("invalid");
		return false;
	}
}

function Validate_DHCP(forminput){
	var startend = "";
	var inputname = forminput.name;
	var inputvalue = forminput.value*1;
	
	(inputname.indexOf("start") != -1) ? startend = "start" : startend = "end";
	if(startend == "start"){
		if(inputvalue >= eval("document.form."+inputname.substring(0,inputname.indexOf("start"))+"end.value")*1){
			$j(forminput).addClass("invalid");
			return false;
		}
		else{
			if(inputvalue > 254 || inputvalue < 2){
				$j(forminput).addClass("invalid");
				return false;
			}
			else{
				$j(forminput).removeClass("invalid");
				return true;
			}
		}
	}
	else{
		if(inputvalue <= eval("document.form."+inputname.substring(0,inputname.indexOf("end"))+"start.value")*1){
			$j(forminput).addClass("invalid");
			return false;
		}
		else{
			if(inputvalue > 254 || inputvalue < 2){
				$j(forminput).addClass("invalid");
				return false;
			}
			else{
				$j(forminput).removeClass("invalid");
				return true;
			}
		}
	}
}

function Validate_VPNClientNo(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value*1;
	
	if(inputvalue > 5 || inputvalue < 1){
		$j(forminput).addClass("invalid");
		return false;
	}
	else{
		$j(forminput).removeClass("invalid");
		return true;
	}
}

function Validate_OneTwoWay(forminput){
	var onetwo = "";
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	
	(inputname.indexOf("oneway") != -1) ? onetwo = "one" : onetwo = "two";
	if(onetwo == "one"){
		if(inputvalue == "true"){
			eval("document.form."+inputname.substring(0,inputname.indexOf("one"))+"twowaytoguest.value=false");
		}
	}
	else{
		if(inputvalue == "true"){
			eval("document.form."+inputname.substring(0,inputname.indexOf("two"))+"onewaytoguest.value=false");
		}
	}
}

function Validate_All(){
	var validationfailed = false;
	for(var i=0; i < bands; i++){
		for(var i2=1; i2 < 4; i2++){
			if(! Validate_IP(eval("document.form.yazfi_wl"+i+i2+"_ipaddr"),"IP")){validationfailed=true;}
			if(! Validate_DHCP(eval("document.form.yazfi_wl"+i+i2+"_dhcpstart"))){validationfailed=true;}
			if(! Validate_DHCP(eval("document.form.yazfi_wl"+i+i2+"_dhcpend"))){validationfailed=true;}
			if(! Validate_IP(eval("document.form.yazfi_wl"+i+i2+"_dns1"),"DNS")){validationfailed=true;}
			if(! Validate_IP(eval("document.form.yazfi_wl"+i+i2+"_dns2"),"DNS")){validationfailed=true;}
			if(! Validate_VPNClientNo(eval("document.form.yazfi_wl"+i+i2+"_vpnclientnumber"))){validationfailed=true;}
		}
	}
	if(validationfailed){
		alert("Validation for some fields failed. Please correct invalid values and try again.");
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
			setTimeout(get_conf_file, 1000);
		},
		success: function(data){
			var settings=data.split("\n");
			settings.reverse();
			settings = settings.filter(Boolean);
			var settingcount=settings.length;
			window["yazfi_settings"] = [];
			for(var i = 0; i < settingcount; i++){
				var commentstart=settings[i].indexOf("#");
				if (commentstart != -1){
					continue;
				}
				var setting=settings[i].split("=");
				window["yazfi_settings"].unshift(setting);
			}
			if(wl_info.band2g_support){$j("#table_buttons").before(BuildConfigTable("wl0","2.4GHz Guest Networks"));bands = bands + 1;}
			if(wl_info.band5g_support){$j("#table_buttons").before(BuildConfigTable("wl1","5GHz-1 Guest Networks"));bands = bands + 1;}
			if(wl_info.band5g_2_support){$j("#table_buttons").before(BuildConfigTable("wl2","5GHz-2 Guest Networks"));bands = bands + 1;}
			var settingcount = bands*12*3;
			for(var i = 0; i < settingcount; i++){
				var settingname = window["yazfi_settings"][i][0].toLowerCase();
				var settingvalue = window["yazfi_settings"][i][1];
				eval("document.form.yazfi_"+settingname).value = settingvalue;
				if(settingname.indexOf("redirectalltovpn") != -1) VPNOptionsEnableDisable($j("#yazfi_"+settingname.replace("_redirectalltovpn","")+"_redir_"+settingvalue)[0]);
				if(settingname.indexOf("enabled") != -1) OptionsEnableDisable($j("#yazfi_"+settingname.replace("_enabled","")+"_en_"+settingvalue)[0]);
			}
			
			if($("#firmver").text()*1 < 386.1){
				if(productid == "RT-AX88U" || productid == "RT-AX3000"){
					$j("input[name*=clientisolation][value=false]").prop("checked",true);
					$j("input[name*=clientisolation]").attr('disabled',true);
				}
			}
			
			for(var i = 0; i < bands; i++){
				for(var i2 = 1; i2 < 4; i2++){
					if(eval('document.form.wl'+i+i2+'_bss_enabled').value == 0){
						OptionsEnableDisable($j("#yazfi_wl"+i+i2+"_en_false")[0]);
						$j('input[name=yazfi_wl'+i+i2+'_enabled]').prop("disabled",true);
					}
				}
			}
			AddEventHandlers();
		}
	});
}

function SetCurrentPage(){
	document.form.next_page.value = window.location.pathname.substring(1);
	document.form.current_page.value = window.location.pathname.substring(1);
}

function ScriptUpdateLayout(){
	var localver = GetVersionNumber("local");
	var serverver = GetVersionNumber("server");
	$j("#yazfi_version_local").text(localver);
	
	if(localver != serverver && serverver != "N/A"){
		$j("#yazfi_version_server").text("Updated version available: "+serverver);
		showhide("btnChkUpdate", false);
		showhide("yazfi_version_server", true);
		showhide("btnDoUpdate", true);
	}
}

function update_status(){
	$j.ajax({
		url: '/ext/YazFi/detect_update.js',
		dataType: 'script',
		timeout: 3000,
		error: function(xhr){
			setTimeout(update_status, 1000);
		},
		success: function(){
			if (updatestatus == "InProgress"){
				setTimeout(update_status, 1000);
			}
			else{
				document.getElementById("imgChkUpdate").style.display = "none";
				showhide("yazfi_version_server", true);
				if(updatestatus != "None"){
					$j("#yazfi_version_server").text("Updated version available: "+updatestatus);
					showhide("btnChkUpdate", false);
					showhide("btnDoUpdate", true);
				}
				else{
					$j("#yazfi_version_server").text("No update available");
					showhide("btnChkUpdate", true);
					showhide("btnDoUpdate", false);
				}
			}
		}
	});
}

function CheckUpdate(){
	showhide("btnChkUpdate", false);
	document.formScriptActions.action_script.value="start_YazFicheckupdate"
	document.formScriptActions.submit();
	document.getElementById("imgChkUpdate").style.display = "";
	setTimeout(update_status, 2000);
}

function DoUpdate(){
	var action_script_tmp = "start_YazFidoupdate";
	document.form.action_script.value = action_script_tmp;
	var restart_time = 45;
	document.form.action_wait.value = restart_time;
	showLoading();
	document.form.submit();
}

function GetVersionNumber(versiontype){
	var versionprop;
	if(versiontype == "local"){
		versionprop = custom_settings.yazfi_version_local;
	}
	else if(versiontype == "server"){
		versionprop = custom_settings.yazfi_version_server;
	}
	
	if(typeof versionprop == 'undefined' || versionprop == null){
		return "N/A";
	}
	else{
		return versionprop;
	}
}

function GetCookie(cookiename,returntype){
	var s;
	if ((s = cookie.get("yazfi_"+cookiename)) != null){
		return cookie.get("yazfi_"+cookiename);
	}
	else{
		if(returntype == "string"){
			return "";
		}
		else if(returntype == "number"){
			return 0;
		}
	}
}

function SetCookie(cookiename,cookievalue){
	cookie.set("yazfi_"+cookiename, cookievalue, 31);
}

function SaveConfig(){
	if(Validate_All()){
		$j('[name*=yazfi_]').prop("disabled",false);
		document.getElementById('amng_custom').value = JSON.stringify($j('form').serializeObject());
		var action_script_tmp = "start_YazFi";
		document.form.action_script.value = action_script_tmp;
		var restart_time = 45;
		document.form.action_wait.value = restart_time;
		showLoading();
		document.form.submit();
	}
	else{
		return false;
	}
}

function initial(){
	SetCurrentPage();
	LoadCustomSettings();
	show_menu();
	get_conf_file();
	ScriptUpdateLayout();
}

function BuildConfigTable(prefix,title){
	var charthtml = '<div style="line-height:10px;">&nbsp;</div>';
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="table_config_'+prefix+'">';
	charthtml+='<thead class="collapsible-jquery" id="'+prefix+'">';
	charthtml+='<tr>';
	charthtml+='<td colspan="2">'+title+' Configuration (click to expand/collapse)</td>';
	charthtml+='</tr>';
	charthtml+='</thead>';
	charthtml+='<tr>';
	charthtml+='<td colspan="2" align="center" style="padding: 0px;">';
	
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable SettingsTable">';
	charthtml+='<col style="width:130px;">';
	charthtml+='<col style="width:205px;">';
	charthtml+='<col style="width:205px;">';
	charthtml+='<col style="width:205px;">';
	charthtml+='<thead>';
	charthtml+='<tr>';
	charthtml+='<th>&nbsp;</th>';
	charthtml+='<th>Guest Network 1</th>';
	charthtml+='<th>Guest Network 2</th>';
	charthtml+='<th>Guest Network 3</th>';
	charthtml+='</tr>';
	charthtml+='<tr>';
	charthtml+='<th>&nbsp;</th>';
	charthtml+='<th>'+eval('document.form.'+prefix+'1_ssid.value')+'</th>';
	charthtml+='<th>'+eval('document.form.'+prefix+'2_ssid.value')+'</th>';
	charthtml+='<th>'+eval('document.form.'+prefix+'3_ssid.value')+'</th>';
	charthtml+='</tr>'
	
	var enabled1 = eval('document.form.'+prefix+'1_bss_enabled.value');
	var enabled2 = eval('document.form.'+prefix+'2_bss_enabled.value');
	var enabled3 = eval('document.form.'+prefix+'3_bss_enabled.value');
	
	if( enabled1 == 0 || enabled2 == 0 || enabled3 == 0){
		charthtml+='<tr>';
		charthtml+='<th>&nbsp;</th>';
		if(enabled1 == 0){
			charthtml+='<th class="bss">Disabled on Guest Network Tab</th>';
		}
		else{
			charthtml+='<th>&nbsp;</th>';
		}
		if(enabled2 == 0){
			charthtml+='<th class="bss">Disabled on Guest Network Tab</th>';
		}
		else{
			charthtml+='<th>&nbsp;</th>';
		}
		if(enabled3 == 0){
			charthtml+='<th class="bss">Disabled on Guest Network Tab</th>';
		}
		else{
			charthtml+='<th>&nbsp;</th>';
		}
		charthtml+='</tr>'
	}
	
	charthtml+='</thead>';
	
	/* ENABLED */
	charthtml+='<tr>';
	charthtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(1);">Enabled</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_enabled" id="yazfi_'+prefix+'1_en_true" onChange="OptionsEnableDisable(this)" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_enabled" id="yazfi_'+prefix+'1_en_false" onChange="OptionsEnableDisable(this)" class="input" value="false" checked>No</td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_enabled" id="yazfi_'+prefix+'2_en_true" onChange="OptionsEnableDisable(this)" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_enabled" id="yazfi_'+prefix+'2_en_false" onChange="OptionsEnableDisable(this)" class="input" value="false" checked>No</td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_enabled" id="yazfi_'+prefix+'3_en_true" onChange="OptionsEnableDisable(this)" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_enabled" id="yazfi_'+prefix+'3_en_false" onChange="OptionsEnableDisable(this)" class="input" value="false" checked>No</td>';
	charthtml+='</tr>';
	
	/* IPADDR */
	charthtml+='<tr>';
	charthtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(2);">IP Address</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'1_ipaddr" value="0.0.0.0" onkeypress="return validator.isIPAddr(this, event)" onblur="Validate_IP(this,\'IP\')" data-lpignore="true" /></td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'2_ipaddr" value="0.0.0.0" onkeypress="return validator.isIPAddr(this, event)" onblur="Validate_IP(this,\'IP\')" data-lpignore="true" /></td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'3_ipaddr" value="0.0.0.0" onkeypress="return validator.isIPAddr(this, event)" onblur="Validate_IP(this,\'IP\')" data-lpignore="true" /></td>';
	charthtml+='</tr>';
	
	/* DHCP START */
	charthtml+='<tr>';
	charthtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(3);">DHCP Start</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_6_table" name="yazfi_'+prefix+'1_dhcpstart" value="2" onkeypress="return validator.isNumber(this, event)" onblur="Validate_DHCP(this)" /></td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_6_table" name="yazfi_'+prefix+'2_dhcpstart" value="2" onkeypress="return validator.isNumber(this, event)" onblur="Validate_DHCP(this)" /></td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_6_table" name="yazfi_'+prefix+'3_dhcpstart" value="2" onkeypress="return validator.isNumber(this, event)" onblur="Validate_DHCP(this)" /></td>';
	charthtml+='</tr>';
	
	/* DHCP END */
	charthtml+='<tr>';
	charthtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(4);">DHCP End</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_6_table" name="yazfi_'+prefix+'1_dhcpend" value="254" onkeypress="return validator.isNumber(this, event)" onblur="Validate_DHCP(this)" /></td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_6_table" name="yazfi_'+prefix+'2_dhcpend" value="254" onkeypress="return validator.isNumber(this, event)" onblur="Validate_DHCP(this)" /></td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_6_table" name="yazfi_'+prefix+'3_dhcpend" value="254" onkeypress="return validator.isNumber(this, event)" onblur="Validate_DHCP(this)" /></td>';
	charthtml+='</tr>';
	
	/* DNS1 */
	charthtml+='<tr>';
	charthtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(5);">DNS Server 1</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'1_dns1" value="0.0.0.0" onkeypress="return validator.isIPAddr(this, event)" onblur="Validate_IP(this,\'DNS\')" data-lpignore="true" /></td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'2_dns1" value="0.0.0.0" onkeypress="return validator.isIPAddr(this, event)" onblur="Validate_IP(this,\'DNS\')" data-lpignore="true" /></td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'3_dns1" value="0.0.0.0" onkeypress="return validator.isIPAddr(this, event)" onblur="Validate_IP(this,\'DNS\')" data-lpignore="true" /></td>';
	charthtml+='</tr>';
	
	/* DNS2 */
	charthtml+='<tr>';
	charthtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(6);">DNS Server 2</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'1_dns2" value="0.0.0.0" onkeypress="return validator.isIPAddr(this, event)" onblur="Validate_IP(this,\'DNS\')" data-lpignore="true" /></td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'2_dns2" value="0.0.0.0" onkeypress="return validator.isIPAddr(this, event)" onblur="Validate_IP(this,\'DNS\')" data-lpignore="true" /></td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'3_dns2" value="0.0.0.0" onkeypress="return validator.isIPAddr(this, event)" onblur="Validate_IP(this,\'DNS\')" data-lpignore="true" /></td>';
	charthtml+='</tr>';
	
	/* FORCEDNS */
	charthtml+='<tr>';
	charthtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(7);">Force DNS</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_forcedns" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_forcedns" class="input" value="false" checked>No</td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_forcedns" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_forcedns" class="input" value="false" checked>No</td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_forcedns" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_forcedns" class="input" value="false" checked>No</td>';
	charthtml+='</tr>';
	
	/* REDIRECTALLTOVPN */
	charthtml+='<tr>';
	charthtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(8);">Redirect all to VPN</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_redirectalltovpn" id="yazfi_'+prefix+'1_redir_true" onChange="VPNOptionsEnableDisable(this)" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_redirectalltovpn" id="yazfi_'+prefix+'1_redir_false" onChange="VPNOptionsEnableDisable(this)" class="input" value="false" checked>No</td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_redirectalltovpn" id="yazfi_'+prefix+'2_redir_true" onChange="VPNOptionsEnableDisable(this)" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_redirectalltovpn" id="yazfi_'+prefix+'2_redir_false" onChange="VPNOptionsEnableDisable(this)" class="input" value="false" checked>No</td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_redirectalltovpn" id="yazfi_'+prefix+'3_redir_true" onChange="VPNOptionsEnableDisable(this)" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_redirectalltovpn" id="yazfi_'+prefix+'3_redir_false" onChange="VPNOptionsEnableDisable(this)" class="input" value="false" checked>No</td>';
	charthtml+='</tr>';
	
	/* VPNCLIENTNUMBER */
	charthtml+='<tr>';
	charthtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(9);">VPN Client No.</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="1" class="input_6_table" name="yazfi_'+prefix+'1_vpnclientnumber" value="2" onkeypress="return validator.isNumber(this, event)" onblur="Validate_VPNClientNo(this)" /></td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="1" class="input_6_table" name="yazfi_'+prefix+'2_vpnclientnumber" value="2" onkeypress="return validator.isNumber(this, event)" onblur="Validate_VPNClientNo(this)" /></td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="1" class="input_6_table" name="yazfi_'+prefix+'3_vpnclientnumber" value="2" onkeypress="return validator.isNumber(this, event)" onblur="Validate_VPNClientNo(this)" /></td>';
	charthtml+='</tr>';
	
	/* TWOWAYTOGUEST */
	charthtml+='<tr>';
	charthtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(10);">Two way to guest</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_twowaytoguest" class="input" value="true" onchange="Validate_OneTwoWay(this)">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_twowaytoguest" class="input" value="false" onchange="Validate_OneTwoWay(this)" checked>No</td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_twowaytoguest" class="input" value="true" onchange="Validate_OneTwoWay(this)" >Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_twowaytoguest" class="input" value="false" onchange="Validate_OneTwoWay(this)" checked>No</td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_twowaytoguest" class="input" value="true" onchange="Validate_OneTwoWay(this)" >Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_twowaytoguest" class="input" value="false" onchange="Validate_OneTwoWay(this)" checked>No</td>';
	charthtml+='</tr>';
	
	/* ONEWAYTOGUEST */
	charthtml+='<tr>';
	charthtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(11);">One way to guest</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_onewaytoguest" class="input" value="true" onchange="Validate_OneTwoWay(this)" >Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_onewaytoguest" class="input" value="false" onchange="Validate_OneTwoWay(this)" checked>No</td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_onewaytoguest" class="input" value="true" onchange="Validate_OneTwoWay(this)" >Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_onewaytoguest" class="input" value="false" onchange="Validate_OneTwoWay(this)" checked>No</td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_onewaytoguest" class="input" value="true" onchange="Validate_OneTwoWay(this)" >Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_onewaytoguest" class="input" value="false" onchange="Validate_OneTwoWay(this)" checked>No</td>';
	charthtml+='</tr>';
	
	/* CLIENT ISOLATION */
	charthtml+='<tr>';
	charthtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(12);">Client isolation</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_clientisolation" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_clientisolation" class="input" value="false" checked>No</td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_clientisolation" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_clientisolation" class="input" value="false" checked>No</td>';
	charthtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_clientisolation" class="input" value="true" >Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_clientisolation" class="input" value="false" checked>No</td>';
	charthtml+='</tr>';
	
	charthtml+='</table>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='</table>';
	charthtml+='<div style="line-height:10px;">&nbsp;</div>';
	return charthtml;
}

function AddEventHandlers(){
	$j(".collapsible-jquery").click(function(){
		$j(this).siblings().toggle("fast",function(){
			if($j(this).css("display") == "none"){
				SetCookie($j(this).siblings()[0].id,"collapsed");
			}
			else{
				SetCookie($j(this).siblings()[0].id,"expanded");
			}
		})
	});
	
	$j(".collapsible-jquery").each(function(index,element){
		if(GetCookie($j(this)[0].id,"string") == "collapsed"){
			$j(this).siblings().toggle(false);
		}
		else{
			$j(this).siblings().toggle(true);
		}
	});
}

$j.fn.serializeObject = function(){
	var o = custom_settings;
	var a = this.serializeArray();
	$j.each(a, function(){
		if (o[this.name] !== undefined && this.name.indexOf("yazfi") != -1 && this.name.indexOf("version") == -1){
			if (!o[this.name].push){
				o[this.name] = [o[this.name]];
			}
			o[this.name].push(this.value || '');
		} else if (this.name.indexOf("yazfi") != -1 && this.name.indexOf("version") == -1){
			o[this.name] = this.value || '';
		}
	});
	return o;
};
