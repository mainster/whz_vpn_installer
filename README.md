# whz_vpn_installer #
This repository contains a BASH-driven installer script for the automatic installation and configuration of various network drives for students of the [WHZ](https://www.fh-zwickau.de/).

## OpenConnect ##
The VPN-SSL connection is established via an open-source implementation of "Cisco's AnyConnect SSL VPN" protocol (ZKI user account necessary). Based on this, various CIFS shares could be mounted to your file system and managed from within your Unix Box.

## Tested on Linux Mint 18.1 ##
```
me@x58a:~/scripts$ uname -a && lsb_release -a
Linux x58a 4.4.0-53-generic #74-Ubuntu SMP Fri Dec 2 15:59:10 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
Distributor ID: LinuxMint
Description:    Linux Mint 18.1 Serena
Release:        18.1
Codename:       serena
```

## Install/Update ##
The ZKI credentials (ZKI_USER:ZKI_PASSWD) must be passed via environment variables as shown: 
```
 sudo ZKI_USER="mad16h09" ZKI_PASSWD="qwertz123" UNID="mainster" ./zki_vpn_installer.sh --install
```
The trailing space before ``` sudo ``` prevents BASH from appending the script-invocation call in cleartext to your ~/.bash_history.

## use-web-space ##
If you are a [web-space registered ZKI user](https://www.fh-zwickau.de/zki/nutzerservice/webspace-freischalten/), simply append the ```--use-web-space``` flag after the ```--install``` flag when invoking the whz_vpn_installer.sh for the next install/update. 
```
 sudo ZKI_USER="mad16h09" ZKI_PASSWD="qwertz123" UNID="mainster" ./zki_vpn_installer.sh --install --use-web-space
```

## Configuration ##
Complete and/or extend the list of CIFS shares before your next call to the installer script. 
If you want to be able to mount the share ```y:(Info)/Lehre/ETechnik``` to, lets say, ```/mnt/whzElt```, simply do a copy/paste/modify like

```bash
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~ Add the desired whz shares and a corresponding mount point ~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ADD_SH2MP  "//whz-ffak-00.zw.fh-zwickau.de/Information"           "/mnt/whzInfo"
ADD_SH2MP  "//whz-file-10.zw.fh-zwickau.de/<ZKI_USER>"            "/mnt/whzHome"
ADD_SH2MP  "//whz-cms-10.zw.fh-zwickau.de/Web_Space/<ZKI_USER>"   "/mnt/whzWeb"

ADD_SH2MP  "//whz-ffak-00.zw.fh-zwickau.de/Information/Lehre/ETechnik"  "/mnt/whzElt"
(...)
```
followed by 
install/update. 

```
 sudo ZKI_USER="mad16h09" ZKI_PASSWD="qwertz123" UNID="mainster" ./zki_vpn_installer.sh --install
```
or  
```
 sudo ZKI_USER="mad16h09" ZKI_PASSWD="qwertz123" UNID="mainster" ./zki_vpn_installer.sh --install --use-web-space
```

## Example output ##
![BASH out](https://github.com/mainster/whz_vpn_installer/blob/master/bash.png)
