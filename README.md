# whz_vpn_installer #
This repository contains a BASH-driven installer script for the automatic installation and configuration of various network drives for students of the [WHZ](https://www.fh-zwickau.de/).

## OpenConnect ##
The VPN-SSL connection is established via an open-source implementation of "Cisco's AnyConnect SSL VPN" protocol (ZKI user account necessary). Based on this, various CIFS shares could be mounted to your file system and managed from within your Unix Box.

## Tested on Linux Mint 18.1 ##
```
mainster@x58a:~/scripts$ uname -a && lsb_release -a
  Linux x58a 4.4.0-53-generic #74-Ubuntu SMP Fri Dec 2 15:59:10 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
  Distributor ID:	LinuxMint
  Description:		Linux Mint 18.1 Serena
  Release:		18.1
  Codename:		serena
```

```
sudo ZKI_USER="mad16h09" ZKI_PASSWD="qwertz123" UNID="mainster" ./zki_vpn_installer.sh --install --use-web-space
sudo ZKI_USER="mad16h09" ZKI_PASSWD="qwertz123" UNID="mainster" ./zki_vpn_installer.sh --install
```
