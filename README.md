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
```bash
mainster@x58a:~/scripts$ sudo ZKI_USER="mad16h09" ZKI_PASSWD="qwertz123" UNID="mainster" ./zki_vpn_installer.sh --install --use-web-space
=============================================================================================================================================================================================================================================================/mnt/whzInfo
/mnt/whzELT
/mnt/whzHome
/mnt/whzWeb
One or more samba shares for USER mad16h09 are already mounted, trying to "force" unmount...
=============================================================================================================================================================================================================================================================Force umount of /mnt/whzInfo	successful!
Force umount of /mnt/whzELT	successful!
Force umount of /mnt/whzHome	successful!
Force umount of /mnt/whzWeb	successful!
Paketlisten werden gelesen... Fertig
Abhängigkeitsbaum wird aufgebaut.       
Statusinformationen werden eingelesen.... Fertig
Hinweis: »libopenconnect-dev« wird für regulären Ausdruck »libopenconnect.« gewählt.
Hinweis: »libopenconnect5« wird für regulären Ausdruck »libopenconnect.« gewählt.
Hinweis: »libopenconnect5-dbg« wird für regulären Ausdruck »libopenconnect.« gewählt.
Note, selecting 'network-manager-openconnect-gnome' for glob 'network-manager-openconnect*'
Note, selecting 'network-manager-openconnect' for glob 'network-manager-openconnect*'
libopenconnect-dev is already the newest version (7.06-2build2).
libopenconnect5 is already the newest version (7.06-2build2).
libopenconnect5-dbg is already the newest version (7.06-2build2).
openconnect is already the newest version (7.06-2build2).
smbnetfs is already the newest version (0.6.0-1).
python-samba is already the newest version (2:4.3.11+dfsg-0ubuntu0.16.04.7).
samba is already the newest version (2:4.3.11+dfsg-0ubuntu0.16.04.7).
samba-common is already the newest version (2:4.3.11+dfsg-0ubuntu0.16.04.7).
samba-libs is already the newest version (2:4.3.11+dfsg-0ubuntu0.16.04.7).
smbclient is already the newest version (2:4.3.11+dfsg-0ubuntu0.16.04.7).
network-manager-openconnect is already the newest version (1.2.0-0ubuntu0.16.04.1).
network-manager-openconnect-gnome is already the newest version (1.2.0-0ubuntu0.16.04.1).
0 aktualisiert, 0 neu installiert, 0 zu entfernen und 10 nicht aktualisiert.
=============================================================================================================================================================================================================================================================ownership of '/mnt/whzInfo' retained as mainster:mainster
ownership of '/mnt/whzELT' retained as mainster:mainster
ownership of '/mnt/whzHome' retained as mainster:mainster
ownership of '/mnt/whzWeb' retained as mainster:mainster
mainster ALL= NOPASSWD: /usr/bin/vpnWhz.sh
/tmp/sudoers.tmp: parsed OK
/etc/sudoers.d/README: parsed OK
/etc/sudoers.d/mint_artwork_kde_dolphin_root: parsed OK
/etc/sudoers.d/mintupdate: parsed OK
VPN connect/disconnect script vpnWhz.sh copied to /usr/bin/vpnWhz.sh.
Aliases for vpnWhzConnect and vpnWhzDisconnect created.

=============================================================================================================================================================================================================================================================Installed!
=============================================================================================================================================================================================================================================================Run source /home/mainster/.bash_aliases or open new bash terminal and test command vpnWhzConnect.

=============================================================================================================================================================================================================================================================List of modified files/dirs:
=============================================================================================================================================================================================================================================================/.smbcredentialsWhz
/mnt/whzInfo
/mnt/whzELT
/mnt/whzHome
/mnt/whzWeb
/etc/fstab
/etc/sudoers
/usr/bin/vpnWhz.sh
/home/mainster/.bash_aliases
/home/mainster/.bash_aliases.bak_2017-06-20_082036
```
