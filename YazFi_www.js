/**----------------------------------------**/
/** Modified by Martinski W. [2023-Jan-23] **/
/**----------------------------------------**/
var clientswl01 = []; var sortnamewl01 = 'Hostname'; var sortdirwl01 = 'asc';
var clientswl02 = []; var sortnamewl02 = 'Hostname'; var sortdirwl02 = 'asc';
var clientdwl03 = []; var sortnamewl03 = 'Hostname'; var sortdirwl03 = 'asc';
var clientswl11 = []; var sortnamewl11 = 'Hostname'; var sortdirwl11 = 'asc';
var clientswl12 = []; var sortnamewl12 = 'Hostname'; var sortdirwl12 = 'asc';
var clientswl13 = []; var sortnamewl13 = 'Hostname'; var sortdirwl13 = 'asc';
var clientswl21 = []; var sortnamewl21 = 'Hostname'; var sortdirwl21 = 'asc';
var clientswl22 = []; var sortnamewl22 = 'Hostname'; var sortdirwl22 = 'asc';
var clientswl23 = []; var sortnamewl23 = 'Hostname'; var sortdirwl23 = 'asc';
var clientswl31 = []; var sortnamewl31 = 'Hostname'; var sortdirwl31 = 'asc';
var clientswl32 = []; var sortnamewl32 = 'Hostname'; var sortdirwl32 = 'asc';
var clientswl33 = []; var sortnamewl33 = 'Hostname'; var sortdirwl33 = 'asc';

var tout;
var numOfBands = 0;
var failedfields = [];

/**----------------------------------------------**/
/** Added/modified by Martinski W. [2023-Jan-23] **/
/**----------------------------------------------**/
/** The DHCP Lease Time values can be given in:  **/
/** seconds, minutes, hours, days, or weeks.     **/
/**----------------------------------------------**/
const theDHCPLeaseTime=
{
   uiLabel: 'DHCP Lease',
   varType: 'dhcpLEASE',
   varName: 'dhcplease',
   minVal: 120,     minStr: '2 minutes',
   maxVal: 7776000, maxStr: '90 days',
   ValidateLeaseValue: function(theValue)
   {
      let timeUnits, timeFactor, timeNumber, timeValue;

      const valueFormat1 = /^[0-9]{1,7}$/;
      const valueFormat2 = /^[0-9]{1,7}[smhdw]{1}$/;

      if (valueFormat1.test(theValue))
      {
         timeUnits = 's';
         timeNumber = theValue;
      }
      else if (valueFormat2.test(theValue))
      {
         let valLen = theValue.length;
         timeUnits = theValue.substring ((valLen - 1), valLen);
         timeNumber = theValue.substring (0, (valLen - 1));
      }
      else { return false; }

      switch (timeUnits)
      {
         case 's': timeFactor=1; break;
         case 'm': timeFactor=60; break;
         case 'h': timeFactor=3600; break;
         case 'd': timeFactor=86400; break;
         case 'w': timeFactor=604800; break;
      }

      if (!valueFormat1.test(timeNumber)) { return false; }
      timeValue=(timeNumber * timeFactor);

      if (timeValue < this.minVal || timeValue > this.maxVal)
      { return false; }
      else
      { return true; }
   },
   ValidateLeaseInput: function(obj, event)
   {
      const valueFormat = /^[0-9]{1,7}$/;
      const keyPressed = (event.keyCode ? event.keyCode : event.which);
      if (validator.isFunctionButton(event)) { return true; }

      if (keyPressed > 47 && keyPressed < 58 && 
          (obj.value.length == 0 || obj.value.charAt(0) != '0' || keyPressed != 48))
      { return true; }
      else if (obj.value.length > 0 && obj.value.charAt(0) != '0' && valueFormat.test(obj.value) &&
               (keyPressed == 115 || keyPressed == 109 || keyPressed == 104 || keyPressed == 100 || keyPressed == 119))
      { return true; }
      else if (event.metaKey &&
               (keyPressed == 65 || keyPressed == 67 || keyPressed == 86 || keyPressed == 88 ||
                keyPressed == 97 || keyPressed == 99 || keyPressed == 118 || keyPressed == 120))
      { return true; }
      else
      { return false; }
   },
   errorMsg: function()
   { return (`Value is not between ${this.minVal} and ${this.maxVal} seconds (${this.minStr} to ${this.maxStr}).`); },
   hintMsg: function()
   { return (`DHCP Lease Time in seconds: ${this.minVal} (${this.minStr}) to ${this.maxVal} (${this.maxStr}).`); }
};

const theDHCPStart=
{
   uiLabel: 'DHCP Start',
   varType: 'dhcpSTART',
   varName: 'dhcpstart',
   minVal: 2, maxVal: 253,
   errorMsg1: 'DHCP Start is greater than or equal to DHCP End',
   errorMsg2: function()
   { return (`Value is not between ${this.minVal} and ${this.maxVal}`); },
   hintMsg: function()
   { return (`Start of DHCP pool (${this.minVal}-${this.maxVal})`); }
};

const theDHCPEnd=
{
   uiLabel: 'DHCP End',
   varType: 'dhcpEND',
   varName: 'dhcpend',
   minVal: 3, maxVal: 254,
   errorMsg1: 'DHCP End is less than or equal to DHCP Start',
   errorMsg2: function()
   { return (`Value is not between ${this.minVal} and ${this.maxVal}`); },
   hintMsg: function()
   { return (`End of DHCP pool (${this.minVal}-${this.maxVal})`); }
};

/**-------------------------------------**/
/** Added by Martinski W. [2022-Dec-23] **/
/**-------------------------------------**/
const listOfGUIFieldNames=
[ 'enabled', 'ipaddr', theDHCPStart.varName, theDHCPEnd.varName, theDHCPLeaseTime.varName, 'dns1', 'dns2', 'vpnclientnumber', 'allowinternet', 'forcedns', 'redirectalltovpn', 'onewaytoguest', 'twowaytoguest', 'clientisolation' ];

const band_24GHz='24G';
const band_5GHz_1='5G_1';
const band_5GHz_2='5G_2';
const band_6GHz_1='6G_1';

const theGuestNet=
{
   numOfGNsPerBand: 3,
   listOfBandIFtags:
   [
     ['wl01', 'wl02', 'wl03'],
     ['wl11', 'wl12', 'wl13'],
     ['wl21', 'wl22', 'wl23'],
     ['wl31', 'wl32', 'wl33']
   ],
   wifiBands:
   [
      {
         uiLabel: '2.4GHz',
         bandType: band_24GHz,
         ifPrefix: function()
         {
            if (productid == 'GT-AXE16000')
            return ('wl3');
            else
            return ('wl0');
         },
         supported: function()
         {
            if (typeof wl_info == 'undefined' || wl_info == null)
            return (true);
            else
            return (wl_info.band2g_support);
         }
      },
      {
         uiLabel: '5GHz',
         bandType: band_5GHz_1,
         ifPrefix: function()
         {
            if (productid == 'GT-AXE16000')
            return ('wl0');
            else
            return ('wl1');
         },
         supported: function()
         {
            if (typeof wl_info == 'undefined' || wl_info == null)
            return (true);
            else
            return (wl_info.band5g_support);
         }
      },
      {
         uiLabel: '5GHz-2',
         bandType: band_5GHz_2,
         ifPrefix: function()
         {
            if (productid == 'GT-AXE16000')
            return ('wl1');
            else if (wl_info.band5g_2_support)
            return ('wl2');
            else
            return (null);
         },
         supported: function()
         { return (wl_info.band5g_2_support); }
      },
      {
         uiLabel: '6GHz',
         bandType: band_6GHz_1,
         ifPrefix: function()
         {
            if (productid == 'GT-AXE16000' || wl_info.band6g_support)
            return ('wl2');
            else
            return (null);
         },
         supported: function()
         { return (wl_info.band6g_support); }
      }
   ],

   IFacePrefix: function(theBandType)
   {
      let theIFprefix='';
      for (var cnt=0; cnt < this.wifiBands.length; cnt++)
      {
         if (this.wifiBands[cnt].supported() &&
             theBandType == this.wifiBands[cnt].bandType)
         { theIFprefix=this.wifiBands[cnt].ifPrefix(); break; }
      }
      return (theIFprefix);
   },

   IFaceUILabel: function(theBandType)
   {
      let theUILabel='';
      for (var cnt=0; cnt < this.wifiBands.length; cnt++)
      {
         if (this.wifiBands[cnt].supported() &&
             theBandType == this.wifiBands[cnt].bandType)
         { theUILabel=this.wifiBands[cnt].uiLabel; break; }
      }
      return (theUILabel);
   },

   UILabelFromPrefix: function(theIFnamePrefix)
   {
      let theUILabel='';
      for (var cnt=0; cnt < this.wifiBands.length; cnt++)
      {
         if (this.wifiBands[cnt].supported() &&
             theIFnamePrefix == this.wifiBands[cnt].ifPrefix())
         { theUILabel=this.wifiBands[cnt].uiLabel; break; }
      }
      return (theUILabel);
   }
};

var $j = jQuery.noConflict();

function initial(){
	SetCurrentPage();
	LoadCustomSettings();
	show_menu();
	get_conf_file();
	ScriptUpdateLayout();
	
	document.formScriptActions.action_script.value='start_YazFiconnectedclients';
	document.formScriptActions.submit();
	tout = setTimeout(get_connected_clients_file,5000);
}

/**----------------------------------------**/
/** Modified by Martinski W. [2022-Dec-05] **/
/**----------------------------------------**/
function YazHint(hintid){
	var tag_name= document.getElementsByTagName('a');
	for(var i=0;i<tag_name.length;i++){
		tag_name[i].onmouseout=nd;
	}
	hinttext='My text goes here';
	if(hintid == 1) hinttext='Enable YazFi for this Guest Network';
	if(hintid == 2) hinttext='IP address/subnet to use for Guest Network';
	if(hintid == 3) hinttext=theDHCPStart.hintMsg();
	if(hintid == 4) hinttext=theDHCPEnd.hintMsg();
	if(hintid == 5) hinttext=theDHCPLeaseTime.hintMsg();
	if(hintid == 6) hinttext='IP address for primary DNS resolver';
	if(hintid == 7) hinttext='IP address for secondary DNS resolver';
	if(hintid == 8) hinttext='Should Guest Network DNS requests be forced/redirected to DNS1? N.B. This setting is ignored if sending to VPN, and VPN Client\'s DNS configuration is Exclusive';
	if(hintid == 9) hinttext='Should Guest Network be allowed to access the internet?';
	if(hintid == 10) hinttext='Should Guest Network traffic be sent via VPN?';
	if(hintid == 11) hinttext='The number of the VPN Client to send traffic through (1-5)';
	if(hintid == 12) hinttext='Should LAN/Guest Network traffic have unrestricted access to each other? Cannot be enabled if _ONEWAYTOGUEST is enabled';
	if(hintid == 13) hinttext='Should LAN be able to initiate connections to Guest Network clients (but not the opposite)? Cannot be enabled if _TWOWAYTOGUEST is enabled';
	if(hintid == 14) hinttext='Should Guest Network radio prevent clients from talking to each other?';
	return overlib(hinttext,0,0);
}

/**----------------------------------------**/
/** Modified by Martinski W. [2022-Dec-05] **/
/**----------------------------------------**/
function OptionsEnableDisable(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	var prefix = inputname.substring(0,inputname.lastIndexOf('_'));

	var fieldnames = ['ipaddr',theDHCPStart.varName,theDHCPEnd.varName,theDHCPLeaseTime.varName,'dns1','dns2','vpnclientnumber'];
	var fieldnames2 = ['allowinternet','forcedns','redirectalltovpn','onewaytoguest','twowaytoguest','clientisolation'];
	
	if(inputvalue == 'false'){
		for(var index = 0; index < fieldnames.length; index++){
			$j('input[name='+prefix+'_'+fieldnames[index]+']').addClass('disabled');
			$j('input[name='+prefix+'_'+fieldnames[index]+']').prop('disabled',true);
		}
		for(var index = 0; index < fieldnames2.length; index++){
			$j('input[name='+prefix+'_'+fieldnames2[index]+']').prop('disabled',true);
		}
	}
	else if(inputvalue == 'true'){
		for(var index = 0; index < fieldnames.length; index++){
			if(fieldnames2[index] == 'dns2' || fieldnames2[index] == 'vpnclientnumber'){continue;}
			$j('input[name='+prefix+'_'+fieldnames[index]+']').removeClass('disabled');
			$j('input[name='+prefix+'_'+fieldnames[index]+']').prop('disabled',false);
		}
		for(var index = 0; index < fieldnames2.length; index++){
			$j('input[name='+prefix+'_'+fieldnames2[index]+']').prop('disabled',false);
		}
		
		if(eval('document.form.'+prefix+'_redirectalltovpn').value == 'true'){
			$j('input[name='+prefix+'_vpnclientnumber]').removeClass('disabled');
			$j('input[name='+prefix+'_vpnclientnumber]').prop('disabled',false);
		}
		
		if(eval('document.form.'+prefix+'_forcedns').value == 'false'){
			$j('input[name='+prefix+'_dns2]').removeClass('disabled');
			$j('input[name='+prefix+'_dns2]').prop('disabled',false);
		}
		
		if(eval('document.form.'+prefix+'_allowinternet').value == 'false'){
			$j('input[name='+prefix+'_redirectalltovpn]').addClass('disabled');
			$j('input[name='+prefix+'_redirectalltovpn]').prop('disabled',true);
			$j('input[name='+prefix+'_vpnclientnumber]').addClass('disabled');
			$j('input[name='+prefix+'_vpnclientnumber]').prop('disabled',true);
			Validate_IP(eval('document.form.'+prefix+'_dns1'),'DNS');
			Validate_IP(eval('document.form.'+prefix+'_dns2'),'DNS');
		}
	}
}

function SubOptionsEnableDisable(forminput,optiontype){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	var prefix = inputname.substring(0,inputname.lastIndexOf('_'));
	
	if(eval('document.form.'+prefix+'_enabled').value == 'true'){
		if(inputvalue == 'false'){
			if(optiontype == 'vpn'){
				$j('input[name='+prefix+'_vpnclientnumber]').addClass('disabled');
				$j('input[name='+prefix+'_vpnclientnumber]').prop('disabled',true);
			}
			else if(optiontype == 'dns'){
				$j('input[name='+prefix+'_dns2]').removeClass('disabled');
				$j('input[name='+prefix+'_dns2]').prop('disabled',false);
			}
			else if(optiontype == 'allowinternet'){
				$j('input[name='+prefix+'_redirectalltovpn]').addClass('disabled');
				$j('input[name='+prefix+'_redirectalltovpn]').prop('disabled',true);
				$j('input[name='+prefix+'_vpnclientnumber]').addClass('disabled');
				$j('input[name='+prefix+'_vpnclientnumber]').prop('disabled',true);
				Validate_IP(eval('document.form.'+prefix+'_dns1'),'DNS');
				Validate_IP(eval('document.form.'+prefix+'_dns2'),'DNS');
			}
		}
		else if(inputvalue == 'true'){
			if(optiontype == 'vpn'){
				$j('input[name='+prefix+'_vpnclientnumber]').removeClass('disabled');
				$j('input[name='+prefix+'_vpnclientnumber]').prop('disabled',false);
			}
			else if(optiontype == 'dns'){
				$j('input[name='+prefix+'_dns2]').val($j('input[name='+prefix+'_dns1]').val());
				$j('input[name='+prefix+'_dns2]').addClass('disabled');
				$j('input[name='+prefix+'_dns2]').prop('disabled',true);
			}
			else if(optiontype == 'allowinternet'){
				$j('input[name='+prefix+'_redirectalltovpn]').removeClass('disabled');
				$j('input[name='+prefix+'_redirectalltovpn]').prop('disabled',false);
				$j('input[name='+prefix+'_vpnclientnumber]').removeClass('disabled');
				$j('input[name='+prefix+'_vpnclientnumber]').prop('disabled',false);
				Validate_IP(eval('document.form.'+prefix+'_dns1'),'DNS');
				Validate_IP(eval('document.form.'+prefix+'_dns2'),'DNS');
			}
		}
	}
}

/**----------------------------------------**/
/** Modified by Martinski W. [2022-Dec-23] **/
/**----------------------------------------**/
function Validate_IP(forminput,iptype){
	var inputvalue = forminput.value;
	var inputname = forminput.name;
	var prefix = inputname.substring(0,inputname.lastIndexOf('_'));
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
					for(var i = 0; i < numOfBands; i++){
						for(var i2 = 1; i2 <= theGuestNet.numOfGNsPerBand; i2++){
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
		else if (iptype == 'DNS' && ! /(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)/.test(inputvalue) && eval('document.form.'+prefix+'_allowinternet.value') == 'false'){
			$j(forminput).addClass('invalid');
			failedfields.push([$j(forminput),'Allow internet disabled and non-private IP address used']);
			$j(forminput).on('mouseover',function(){return overlib('Allow internet disabled and non-private IP address used',0,0);});
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
		failedfields.push([$j(forminput),'Invalid IP Address']);
		$j(forminput).on('mouseover',function(){return overlib('Invalid IP Address',0,0);});
		$j(forminput)[0].onmouseout = nd;
		return false;
	}
}

/**----------------------------------------------**/
/** Added/modified by Martinski W. [2023-Jan-22] **/
/**----------------------------------------------**/
function Validate_DHCP(forminput,dhcpType){
	var inputname = forminput.name;
	var inputvalue = forminput.value*1;

	if(dhcpType == theDHCPStart.varType){
		if(inputvalue >= eval('document.form.'+inputname.substring(0,inputname.indexOf('start'))+'end.value')*1){
			$j(forminput).addClass('invalid');
			failedfields.push([$j(forminput),theDHCPStart.errorMsg1]);
			$j(forminput).on('mouseover',function(){return overlib(theDHCPStart.errorMsg1,0,0);});
			$j(forminput)[0].onmouseout = nd;
			return false;
		}
		else{
			if(inputvalue > theDHCPStart.maxVal || inputvalue < theDHCPStart.minVal){
				$j(forminput).addClass('invalid');
				failedfields.push([$j(forminput),theDHCPStart.errorMsg2()]);
				$j(forminput).on('mouseover',function(){return overlib(theDHCPStart.errorMsg2(),0,0);});
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
	else if(dhcpType == theDHCPEnd.varType){
		if(inputvalue <= eval('document.form.'+inputname.substring(0,inputname.indexOf('end'))+'start.value')*1){
			$j(forminput).addClass('invalid');
			failedfields.push([$j(forminput),theDHCPEnd.errorMsg1]);
			$j(forminput).on('mouseover',function(){return overlib(theDHCPEnd.errorMsg1,0,0);});
			$j(forminput)[0].onmouseout = nd;
			return false;
		}
		else{
			if(inputvalue > theDHCPEnd.maxVal || inputvalue < theDHCPEnd.minVal){
				$j(forminput).addClass('invalid');
				failedfields.push([$j(forminput),theDHCPEnd.errorMsg2()]);
				$j(forminput).on('mouseover',function(){return overlib(theDHCPEnd.errorMsg2(),0,0);});
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
	else if(dhcpType == theDHCPLeaseTime.varType){
		if (!theDHCPLeaseTime.ValidateLeaseValue (forminput.value)){
			$j(forminput).addClass('invalid');
			failedfields.push([$j(forminput),theDHCPLeaseTime.errorMsg()]);
			$j(forminput).on('mouseover',function(){return overlib(theDHCPLeaseTime.errorMsg(),0,0);});
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

/**----------------------------------------**/
/** Modified by Martinski W. [2022-Dec-23] **/
/**----------------------------------------**/
function Validate_All(){
	var validationfailed = false;
	failedfields = [];
	for(var i=0; i < numOfBands; i++){
		for(var i2=1; i2 <= theGuestNet.numOfGNsPerBand; i2++){
			if(! Validate_IP(eval('document.form.yazfi_wl'+i+i2+'_ipaddr'),'IP')){validationfailed=true;}
			if(! Validate_DHCP(eval('document.form.yazfi_wl'+i+i2+'_'+theDHCPStart.varName),theDHCPStart.varType)){validationfailed=true;}
			if(! Validate_DHCP(eval('document.form.yazfi_wl'+i+i2+'_'+theDHCPEnd.varName),theDHCPEnd.varType)){validationfailed=true;}
			if(! Validate_DHCP(eval('document.form.yazfi_wl'+i+i2+'_'+theDHCPLeaseTime.varName),theDHCPLeaseTime.varType)){validationfailed=true;}
			if(! Validate_IP(eval('document.form.yazfi_wl'+i+i2+'_dns1'),'DNS')){validationfailed=true;}
			if(! Validate_IP(eval('document.form.yazfi_wl'+i+i2+'_dns2'),'DNS')){validationfailed=true;}
			if(! Validate_VPNClientNo(eval('document.form.yazfi_wl'+i+i2+'_vpnclientnumber'))){validationfailed=true;}
		}
	}
	
	var failedfieldsstring = '';
	for(var i=0; i < failedfields.length; i++)
	{
		var guestnework = '';
		var prefix = failedfields[i][0].attr('name').split('_')[1];
		let theIFprefix=prefix.substring(0,3);
		let theIFnumber=prefix.substring(3,4);
		guestnetwork = theGuestNet.UILabelFromPrefix(theIFprefix)+' Guest Network '+theIFnumber;

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

/**----------------------------------------**/
/** Modified by Martinski W. [2022-Dec-23] **/
/**----------------------------------------**/
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
			let linesCount=settings.length;
			let settingsCount=0;
			let ifaceVarPrefix, ifacePrefix;
			let showIFprefix, theIFprefixTag;
			let ifaceUILabel, guestNetUILabel;
			window['yazfi_settings'] = [];

			for(var i = 0; i < linesCount; i++)
			{
				ifaceVarPrefix=settings[i].match(/^wl[0-3][1-3]_/);
				var commentstart = settings[i].indexOf('#');
				if (commentstart != -1 || ifaceVarPrefix == null) {continue;}
				settingsCount+=1;
				var setting=settings[i].split('=');
				window['yazfi_settings'].unshift(setting);
			}

			if(typeof wl_info == 'undefined' || wl_info == null)
			{
				numOfBands = 2;

				ifacePrefix=theGuestNet.IFacePrefix (band_24GHz);
				ifaceUILabel=theGuestNet.IFaceUILabel (band_24GHz);
				guestNetUILabel=`${ifaceUILabel} Guest Networks`;

				$j('#table_config').append(BuildConfigTable(ifacePrefix, guestNetUILabel));
				$j('#table_config').append('<tr><td style="padding:0px;height:10px;"></td></tr>');

				ifacePrefix=theGuestNet.IFacePrefix (band_5GHz_1);
				ifaceUILabel=theGuestNet.IFaceUILabel (band_5GHz_1);
				guestNetUILabel=`${ifaceUILabel} Guest Networks`;

				$j('#table_config').append(BuildConfigTable(ifacePrefix, guestNetUILabel));
			}
			else
			{
				showIFprefix=wl_info.band6g_support;
				if(wl_info.band2g_support)
				{
					theIFprefixTag='';
					ifacePrefix=theGuestNet.IFacePrefix (band_24GHz);
					ifaceUILabel=theGuestNet.IFaceUILabel (band_24GHz);
					if (showIFprefix) theIFprefixTag=` [${ifacePrefix}]`;
					guestNetUILabel=`${ifaceUILabel}${theIFprefixTag} Guest Networks`;

					$j('#table_config').append(BuildConfigTable(ifacePrefix, guestNetUILabel));
					numOfBands = numOfBands+1;
				}
				if(wl_info.band5g_support)
				{
					theIFprefixTag='';
					ifacePrefix=theGuestNet.IFacePrefix (band_5GHz_1);
					ifaceUILabel=theGuestNet.IFaceUILabel (band_5GHz_1);
					if (showIFprefix) theIFprefixTag=` [${ifacePrefix}]`;
					guestNetUILabel=`${ifaceUILabel}${theIFprefixTag} Guest Networks`;

					$j('#table_config').append('<tr><td style="padding:0px;height:10px;"></td></tr>');
					$j('#table_config').append(BuildConfigTable(ifacePrefix, guestNetUILabel));
					numOfBands = numOfBands+1;
				}
				if(wl_info.band5g_2_support)
				{
					theIFprefixTag='';
					ifacePrefix=theGuestNet.IFacePrefix (band_5GHz_2);
					ifaceUILabel=theGuestNet.IFaceUILabel (band_5GHz_2);
					if (showIFprefix) theIFprefixTag=` [${ifacePrefix}]`;
					guestNetUILabel=`${ifaceUILabel}${theIFprefixTag} Guest Networks`;

					$j('#table_config').append('<tr><td style="padding:0px;height:10px;"></td></tr>');
					$j('#table_config').append(BuildConfigTable(ifacePrefix, guestNetUILabel));
					numOfBands = numOfBands+1;
				}
				if(wl_info.band6g_support)
				{
					theIFprefixTag='';
					ifacePrefix=theGuestNet.IFacePrefix (band_6GHz_1);
					ifaceUILabel=theGuestNet.IFaceUILabel (band_6GHz_1);
					if (showIFprefix) theIFprefixTag=` [${ifacePrefix}]`;
					guestNetUILabel=`${ifaceUILabel}${theIFprefixTag} Guest Networks`;

					$j('#table_config').append('<tr><td style="padding:0px;height:10px;"></td></tr>');
					$j('#table_config').append(BuildConfigTable(ifacePrefix, guestNetUILabel));
					numOfBands = numOfBands+1;
				}
			}

			$j('#table_config').append('<tr class="apply_gen" valign="top"><td style="background-color:rgb(77,89,93);border-top:0px;border-bottom:0px;height:5px;"></td></tr>');
			var buttonshtml = '<tr class="apply_gen" valign="top" height="35px"><td style="background-color:rgb(77,89,93);border-top:0px;">';
			buttonshtml += '<input name="button" type="button" class="button_gen" onclick="SaveConfig();" value="Apply"/></td></tr>';
			$j('#table_config').append(buttonshtml);

			for(var i = 0; i < settingsCount; i++)
			{
				var settingname = window['yazfi_settings'][i][0].toLowerCase();
				var settingvalue = window['yazfi_settings'][i][1];
				let varNameTags=settingname.split('_');
				let supportedBand=false;
				let supportedField=listOfGUIFieldNames.includes(varNameTags[1]);

				for(var cnt = 0; cnt < numOfBands; cnt++)
				{
				   if (theGuestNet.listOfBandIFtags[cnt].includes(varNameTags[0]))
				   { supportedBand=true; break; }
				}
				if (!supportedBand || !supportedField) {continue;}

				eval('document.form.yazfi_'+settingname).value = settingvalue;
				if(settingname.indexOf('forcedns') != -1) SubOptionsEnableDisable($j('#yazfi_'+settingname.replace('_forcedns','')+'_fdns_'+settingvalue)[0],'dns');
				if(settingname.indexOf('redirectalltovpn') != -1) SubOptionsEnableDisable($j('#yazfi_'+settingname.replace('_redirectalltovpn','')+'_redir_'+settingvalue)[0],'vpn');
				if(settingname.indexOf('allowinternet') != -1) SubOptionsEnableDisable($j('#yazfi_'+settingname.replace('_allowinternet','')+'_allowinet_'+settingvalue)[0],'allowinternet');
				if(settingname.indexOf('enabled') != -1) OptionsEnableDisable($j('#yazfi_'+settingname.replace('_enabled','')+'_en_'+settingvalue)[0]);
			}
			
			if($j('#firmver').text()*1 < 386.1){
				if(productid == 'RT-AX88U' || productid == 'RT-AX3000'){
					$j('input[name*=clientisolation][value=false]').prop('checked',true);
					$j('input[name*=clientisolation]').attr('disabled',true);
				}
			}
			
			for(var i = 0; i < numOfBands; i++){
				for(var i2 = 1; i2 <= theGuestNet.numOfGNsPerBand; i2++){
					if(eval('document.form.wl'+i+i2+'_bss_enabled').value == 0){
						OptionsEnableDisable($j('#yazfi_wl'+i+i2+'_en_false')[0]);
						$j('input[name=yazfi_wl'+i+i2+'_enabled]').prop('disabled',true);
					}
				}
			}
		}
	});
}

/**----------------------------------------**/
/** Modified by Martinski W. [2022-Dec-23] **/
/**----------------------------------------**/
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
			
			for(var i = 0; i < numOfBands; i++){
				for(var i2 = 1; i2 <= theGuestNet.numOfGNsPerBand; i2++){
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
	}).catch(function(){tout = setTimeout(get_connected_clients_file,1000);});
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

/**----------------------------------------**/
/** Modified by Martinski W. [2022-Dec-05] **/
/**----------------------------------------**/
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

	/**----------------------------------------**/
	/** Modified by Martinski W. [2022-Dec-05] **/
	/**----------------------------------------**/
	/* DHCP START */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(3);">'+theDHCPStart.uiLabel+'</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_6_table" name="yazfi_'+prefix+'1_'+theDHCPStart.varName+'" value="2" onkeypress="return validator.isNumber(this,event)" onblur="Validate_DHCP(this,theDHCPStart.varType)" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_6_table" name="yazfi_'+prefix+'2_'+theDHCPStart.varName+'" value="2" onkeypress="return validator.isNumber(this,event)" onblur="Validate_DHCP(this,theDHCPStart.varType)" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_6_table" name="yazfi_'+prefix+'3_'+theDHCPStart.varName+'" value="2" onkeypress="return validator.isNumber(this,event)" onblur="Validate_DHCP(this,theDHCPStart.varType)" /></td>';
	tablehtml+='</tr>';

	/**----------------------------------------**/
	/** Modified by Martinski W. [2022-Dec-05] **/
	/**----------------------------------------**/
	/* DHCP END */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(4);">'+theDHCPEnd.uiLabel+'</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_6_table" name="yazfi_'+prefix+'1_'+theDHCPEnd.varName+'" value="254" onkeypress="return validator.isNumber(this,event)" onblur="Validate_DHCP(this,theDHCPEnd.varType)" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_6_table" name="yazfi_'+prefix+'2_'+theDHCPEnd.varName+'" value="254" onkeypress="return validator.isNumber(this,event)" onblur="Validate_DHCP(this,theDHCPEnd.varType)" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="3" class="input_6_table" name="yazfi_'+prefix+'3_'+theDHCPEnd.varName+'" value="254" onkeypress="return validator.isNumber(this,event)" onblur="Validate_DHCP(this,theDHCPEnd.varType)" /></td>';
	tablehtml+='</tr>';

	/**----------------------------------------------**/
	/** Added/modified by Martinski W. [2023-Jan-22] **/
	/**----------------------------------------------**/
	/* DHCP LEASE */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(5);">'+theDHCPLeaseTime.uiLabel+'</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="8" class="input_12_table" name="yazfi_'+prefix+'1_'+theDHCPLeaseTime.varName+'" value="86400" onkeypress="return theDHCPLeaseTime.ValidateLeaseInput(this,event)" onblur="Validate_DHCP(this,theDHCPLeaseTime.varType)" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="8" class="input_12_table" name="yazfi_'+prefix+'2_'+theDHCPLeaseTime.varName+'" value="86400" onkeypress="return theDHCPLeaseTime.ValidateLeaseInput(this,event)" onblur="Validate_DHCP(this,theDHCPLeaseTime.varType)" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="8" class="input_12_table" name="yazfi_'+prefix+'3_'+theDHCPLeaseTime.varName+'" value="86400" onkeypress="return theDHCPLeaseTime.ValidateLeaseInput(this,event)" onblur="Validate_DHCP(this,theDHCPLeaseTime.varType)" /></td>';
	tablehtml+='</tr>';

	/* DNS1 */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(6);">DNS Server 1</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'1_dns1" value="0.0.0.0" onkeypress="return validator.isIPAddr(this,event)" onblur="Validate_IP(this,\'DNS\')" data-lpignore="true" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'2_dns1" value="0.0.0.0" onkeypress="return validator.isIPAddr(this,event)" onblur="Validate_IP(this,\'DNS\')" data-lpignore="true" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'3_dns1" value="0.0.0.0" onkeypress="return validator.isIPAddr(this,event)" onblur="Validate_IP(this,\'DNS\')" data-lpignore="true" /></td>';
	tablehtml+='</tr>';
	
	/* DNS2 */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(7);">DNS Server 2</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'1_dns2" value="0.0.0.0" onkeypress="return validator.isIPAddr(this,event)" onblur="Validate_IP(this,\'DNS\')" data-lpignore="true" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'2_dns2" value="0.0.0.0" onkeypress="return validator.isIPAddr(this,event)" onblur="Validate_IP(this,\'DNS\')" data-lpignore="true" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="15" class="input_20_table" name="yazfi_'+prefix+'3_dns2" value="0.0.0.0" onkeypress="return validator.isIPAddr(this,event)" onblur="Validate_IP(this,\'DNS\')" data-lpignore="true" /></td>';
	tablehtml+='</tr>';
	
	/* FORCEDNS */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(8);">Force DNS</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_forcedns" id="yazfi_'+prefix+'1_fdns_true" onChange="SubOptionsEnableDisable(this,\'dns\')" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_forcedns" id="yazfi_'+prefix+'1_fdns_false" onChange="SubOptionsEnableDisable(this,\'dns\')" class="input" value="false" checked>No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_forcedns" id="yazfi_'+prefix+'2_fdns_true" onChange="SubOptionsEnableDisable(this,\'dns\')" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_forcedns" id="yazfi_'+prefix+'2_fdns_false" onChange="SubOptionsEnableDisable(this,\'dns\')" class="input" value="false" checked>No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_forcedns" id="yazfi_'+prefix+'3_fdns_true" onChange="SubOptionsEnableDisable(this,\'dns\')" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_forcedns" id="yazfi_'+prefix+'3_fdns_false" onChange="SubOptionsEnableDisable(this,\'dns\')" class="input" value="false" checked>No</td>';
	tablehtml+='</tr>';
	
	/* ALLOWINTERNET */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(9);">Allow Internet access</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_allowinternet" id="yazfi_'+prefix+'1_allowinet_true" onChange="SubOptionsEnableDisable(this,\'allowinternet\')" class="input" value="true" checked>Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_allowinternet" id="yazfi_'+prefix+'1_allowinet_false" onChange="SubOptionsEnableDisable(this,\'allowinternet\')" class="input" value="false">No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_allowinternet" id="yazfi_'+prefix+'2_allowinet_true" onChange="SubOptionsEnableDisable(this,\'allowinternet\')" class="input" value="true" checked>Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_allowinternet" id="yazfi_'+prefix+'2_allowinet_false" onChange="SubOptionsEnableDisable(this,\'allowinternet\')" class="input" value="false">No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_allowinternet" id="yazfi_'+prefix+'3_allowinet_true" onChange="SubOptionsEnableDisable(this,\'allowinternet\')" class="input" value="true" checked>Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_allowinternet" id="yazfi_'+prefix+'3_allowinet_false" onChange="SubOptionsEnableDisable(this,\'allowinternet\')" class="input" value="false">No</td>';
	tablehtml+='</tr>';
	
	/* REDIRECTALLTOVPN */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(10);">Redirect all to VPN</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_redirectalltovpn" id="yazfi_'+prefix+'1_redir_true" onChange="SubOptionsEnableDisable(this,\'vpn\')" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_redirectalltovpn" id="yazfi_'+prefix+'1_redir_false" onChange="SubOptionsEnableDisable(this,\'vpn\')" class="input" value="false" checked>No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_redirectalltovpn" id="yazfi_'+prefix+'2_redir_true" onChange="SubOptionsEnableDisable(this,\'vpn\')" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_redirectalltovpn" id="yazfi_'+prefix+'2_redir_false" onChange="SubOptionsEnableDisable(this,\'vpn\')" class="input" value="false" checked>No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_redirectalltovpn" id="yazfi_'+prefix+'3_redir_true" onChange="SubOptionsEnableDisable(this,\'vpn\')" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_redirectalltovpn" id="yazfi_'+prefix+'3_redir_false" onChange="SubOptionsEnableDisable(this,\'vpn\')" class="input" value="false" checked>No</td>';
	tablehtml+='</tr>';
	
	/* VPNCLIENTNUMBER */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(11);">VPN Client No.</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="1" class="input_6_table" name="yazfi_'+prefix+'1_vpnclientnumber" value="2" onkeypress="return validator.isNumber(this,event)" onblur="Validate_VPNClientNo(this)" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="1" class="input_6_table" name="yazfi_'+prefix+'2_vpnclientnumber" value="2" onkeypress="return validator.isNumber(this,event)" onblur="Validate_VPNClientNo(this)" /></td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="text" maxlength="1" class="input_6_table" name="yazfi_'+prefix+'3_vpnclientnumber" value="2" onkeypress="return validator.isNumber(this,event)" onblur="Validate_VPNClientNo(this)" /></td>';
	tablehtml+='</tr>';
	
	/* TWOWAYTOGUEST */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(12);">Two way to guest</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_twowaytoguest" class="input" value="true" onchange="Validate_OneTwoWay(this)">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_twowaytoguest" class="input" value="false" onchange="Validate_OneTwoWay(this)" checked>No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_twowaytoguest" class="input" value="true" onchange="Validate_OneTwoWay(this)" >Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_twowaytoguest" class="input" value="false" onchange="Validate_OneTwoWay(this)" checked>No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_twowaytoguest" class="input" value="true" onchange="Validate_OneTwoWay(this)" >Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_twowaytoguest" class="input" value="false" onchange="Validate_OneTwoWay(this)" checked>No</td>';
	tablehtml+='</tr>';
	
	/* ONEWAYTOGUEST */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(13);">One way to guest</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_onewaytoguest" class="input" value="true" onchange="Validate_OneTwoWay(this)" >Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_onewaytoguest" class="input" value="false" onchange="Validate_OneTwoWay(this)" checked>No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_onewaytoguest" class="input" value="true" onchange="Validate_OneTwoWay(this)" >Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'2_onewaytoguest" class="input" value="false" onchange="Validate_OneTwoWay(this)" checked>No</td>';
	tablehtml+='<td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_onewaytoguest" class="input" value="true" onchange="Validate_OneTwoWay(this)" >Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'3_onewaytoguest" class="input" value="false" onchange="Validate_OneTwoWay(this)" checked>No</td>';
	tablehtml+='</tr>';
	
	/* CLIENT ISOLATION */
	tablehtml+='<tr>';
	tablehtml+='<td class="settingname"><a class="hintstyle" href="javascript:void(0);" onclick="YazHint(14);">Client isolation</a></td><td class="settingvalue"><input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_clientisolation" class="input" value="true">Yes<input autocomplete="off" autocapitalize="off" type="radio" name="yazfi_'+prefix+'1_clientisolation" class="input" value="false" checked>No</td>';
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
	$j('#auto_refresh').prop('checked',false);
	clearTimeout(tout);
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
		$j('#auto_refresh').prop('checked',false);
		clearTimeout(tout);
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
	if($j('#auto_refresh').prop('checked') == true){
		document.formScriptActions.action_script.value='start_YazFiconnectedclients';
		document.formScriptActions.submit();
		tout = setTimeout(get_connected_clients_file,5000);
	}
	else{
		clearTimeout(tout);
	}
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
