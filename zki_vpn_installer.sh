#!/bin/bash
#==============================================================================
# Description   : WHZ VPN client installer and CIFS-mount config script.
# Homepage      : https://www.fh-zwickau.de 
# Author        : Manuel Del Basso (manuel.delbasso@gmail.com)
# Date          : 2017-04-20
# Usage         : --help
# Notes         : Tested on "Linux Mint 18.1 Serena"
# bash version  : GNU bash, Version 4.3.48(1)-release (x86_64-pc-linux-gnu)
# Version       : 1.4    
#==============================================================================

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~ Clean script body and declare a function to add shares/mountpoints ~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
unset SH2MP ACT_CIFS

ADD_SH2MP() {
    : "${1?First argument takes a single CIFS share name!}"
    : "${2?Second argument takes a single mount point name!}"
    SH2MP+=( "$1:$2" )
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~ Add the desired whz shares and a corresponding mount point ~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ADD_SH2MP  "//whz-ffak-00.zw.fh-zwickau.de/Information"                 "/mnt/whzInfo"
ADD_SH2MP  "//whz-ffak-00.zw.fh-zwickau.de/Information/Lehre/ETechnik"  "/mnt/whzELT"
ADD_SH2MP  "//whz-file-10.zw.fh-zwickau.de/<ZKI_USER>"                  "/mnt/whzHome"
ADD_SH2MP  "//whz-cms-10.zw.fh-zwickau.de/Web_Space/<ZKI_USER>"         "/mnt/whzWeb"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~ VPN script and samba/CIFS credentials file paths ~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VPNSCR="/usr/bin/vpnWhz.sh"             
SMB_CRDENTIALS="/.smbcredentialsWhz"   

#==============================================================================
#=== DO NOT CHANGE ANYTHING BELOW THIS LINE !!! ===============================
#==============================================================================
alias grep='$(which grep) --color=never'
alias find='$(which find) -L'

_MNTPTS() { echo "${SH2MP[@]}" | grep --color=never -oE '\:.[^ ]*' | tr -d ':'; }
_SHARES() { echo "${SH2MP[@]}" | sed 's/ /\n/g' | grep -oE '.*\:' | tr -d ':'; }

#==============================================================================
#=== Remove a share/mountpoint entry from SH2MP ===============================
#==============================================================================
DEL_SH2MP() {
    : "${1?First argument takes a single CIFS share name to delete!}"
    for ((k = 0; k < ${#SH2MP[@]}; k++)); do
        [[ $(echo "${SH2MP[k]}" | cut -f1 -d:) == "$1" ]] && unset 'SH2MP[k]'
    done
}

#==============================================================================
#=== Declare ZKI Web-Space info page ==========================================
#==============================================================================
URI_WEB_SPACE="https://www.fh-zwickau.de/zki/nutzerservice/webspace-freischalten/"

#==============================================================================
#=== Define some fancy fonts ==================================================
#==============================================================================
ansi()  { echo -en "\e[${1}m${*:2}\e[0m"; }
bold()  { ansi 1 "$@"; }

GY()    { ansi '38;5;245' "$@"; }
GN()    { ansi  '38;5;76' "$@"; }
RD()    { ansi   '38;5;9' "$@"; }
BU()    { ansi  '38;5;38' "$@"; }
OR()    { ansi '38;5;202' "$@"; }

GB()    { GN "$(bold "$@")"; }
RB()    { RD "$(bold "$@")"; }
OB()    { OR "$(bold "$@")"; }
BD()    { bold "$@"; }

#==============================================================================
#=== Print horizontal line ====================================================
#==============================================================================
hline() { [[ -z ${1+x} ]] && HC="=" || HC="${1:0:1}"; printf "%0.s$HC" $(seq 1 `tput cols`); }

#==============================================================================
#=== Print a "How to use" message and exit ====================================
#==============================================================================
printUsageAndExit() {
    GY $(hline =); echo -e "If you have ZKI Web-Space service enabled, append --use-web-space when invoking $(basename $0)"; GY $(hline =)
    echo -e "Install: Invoke $(basename $0) script as follows:\n"
    echo -e " sudo ZKI_USER=\"$(RB ZKI-user)\" ZKI_PASSWD=\"$(RB ZKI-passwd)\" UNID=\"$(RB your linux user)\" ./$(basename $0) --install"
    echo -e " sudo ZKI_USER=\"$(BD mad16h09)\" ZKI_PASSWD=\"$(BD qwertz1234)\" UNID=\"$(BD Tom)\" ./$(basename $0) --install\n"
    GY $(hline =); echo -e "Note the whitespace character before $(BD \" sudo ZKI\_USER\=\.\.\.\") to prevent bash from storing your zki cleartext credentials in ~/.bash_history."
    GY $(hline =); 
    exit -1;
}

#==============================================================================
#=== Escape path-arg bash function ============================================
#==============================================================================
pathesc() { echo "$1" | sed 's/\//\\\//g'; }

#==============================================================================
#=== Track modified files =====================================================
#==============================================================================
DTRACK="$(date +%F_%H%M%S)"

#==============================================================================
#=== Parse input arguments ====================================================
#==============================================================================
[[ $# -eq 0 ]] \
    || [[ "$1" = *"help"* ]] \
    || [[ "$1" = *"-h"* ]] \
    || [[ "$1" = *"?"* ]] \
    && printUsageAndExit;

# Check for --install and --use-web-space flags
for arg in "$@"; do
    [[ "$arg" == *"install" ]]       && INST_FLAG=1
    [[ "$arg" == *"use-web-space" ]] && WEBS_FLAG=1
done

# Check for --install and --use-web-space flags
[[ -n ${INST_FLAG+x} ]] || { echo -e "Not called with $(BD --install)?!! Exit!"; exit -1; }
[[ -n ${WEBS_FLAG+x} ]] || { DEL_SH2MP "//whz-cms-10.zw.fh-zwickau.de/Web_Space/<ZKI_USER>"; }

# Installer script called by root?
[[ $EUID -ne 0 ]] && { echo -e "Please run as root!\n"; EXIT=1; }

# Check if $UNID is a regular user
[[ `awk -F':' '{print$1 $2}' /etc/shadow | grep -v '[\*|\!]'` != *"${UNID}"* ]] \
    && { echo -e "User $UNID is not a default login user name!"; EXIT=1; }

# Check required environment variables and call error handler if unset
[[ -z "${ZKI_USER+x}" ]]    && { echo "ZKI_USER not set";    EXIT=1; }
[[ -z "${ZKI_PASSWD+x}" ]]  && { echo "ZKI_PASSWD not set";  EXIT=1; }
[[ -z "${UNID+x}" ]]        && { echo "USER not set";        EXIT=1; }
[[ ${EXIT} ]]               && { printUsageAndExit; }

# Replace zki username place holders in predefined share names
for ((k = 0; k < ${#SH2MP[@]}; k++)); do
    SH2MP[k]=`echo "${SH2MP[k]}" | sed 's/<ZKI\_USER>/'"${ZKI_USER}"'/'`
done

MNTPTS=( `_MNTPTS` )
SHARES=( `_SHARES` )

#==============================================================================
# Check for already mounted whz cifs drives and try to unmount each ===========
#==============================================================================
# Grep only for samba users who match the given zki user.
grep "fh-zwickau.de" /etc/mtab | grep "username=$ZKI_USER" > /tmp/mtab && readarray ACT_CIFS < /tmp/mtab

for REC in "${ACT_CIFS[@]}"; do 
    MPS+=( `echo "$REC" | cut -f2 -d' '` )
done 

if [[ ${#MPS[@]} -gt 0 ]]; then
    GY $(hline);
    echo ${MPS[@]} | tr ' ' '\n'
    printf "One or more samba shares for USER $ZKI_USER are already mounted, trying to \"force\" unmount...\n";
    GY $(hline);

    for MP in ${MPS[@]}; do
        umount -f $MP 2>/dev/null
        if [[ $? -ne 0 ]]; then
            printf "Force umount $MP  $(RB Failed) Trying to \"lazy\" umount... ";
            umount -l $MP 2>/dev/null
            [[ $? -ne 0 ]] && { printf "Lazy umount $(RB failed), Exit\!\n"; exit -1; }
            [[ $? -eq 1 ]] && { printf "Lazy umount $(GB successful)\!\n"; }
        else
            printf "Force umount of $MP\t$(GB successful\!)\n"
        fi
    done
fi

#==============================================================================
# Install open client for Cisco AnyConnect VPN and samba client packages,
# optional network management framework (OpenConnect  plugin * GUI)
#==============================================================================
apt-get install openconnect libopenconnect. smbclient smbnetfs samba \
        samba-common samba-libs python-samba network-manager-openconnect* -y
GY $(hline);

[[ $? -ne 0 ]] && { printf "$(RB Error while installing deb\-packages\, exit\!)\n"; exit -1; }

# Create or overwrite samba credentials file
echo -e "username=$ZKI_USER\npassword=$ZKI_PASSWD" > "${SMB_CRDENTIALS}"
chmod 600 "${SMB_CRDENTIALS}"

# Purge fstab entrys that holds a mount point or share names MNTPTS and SHARES
sed -i.bak.$(basename "$sh") '/zw.fh-zwickau.de/d' /etc/fstab

# Create mount points
mkdir -p ${MNTPTS[@]}
chown -Rv "${UNID}:${UNID}" ${MNTPTS[@]}

# Create (formated) smbfs/cifs fstab entrys
echo > /tmp/fstab.tmp
for k in $(seq 1 ${#MNTPTS[@]}); do
    printf "${SHARES[k-1]}\t${MNTPTS[k-1]}\tcifs\tusers,noauto,nolock,credentials=${SMB_CRDENTIALS},uid=1000,gid=1000,noserverino 0 0\n" >> /tmp/fstab.tmp
done
cat /tmp/fstab.tmp | column -t >> /etc/fstab

MODTRACK+=( "${SMB_CRDENTIALS}" )
MODTRACK+=( "${MNTPTS[@]}" )
MODTRACK+=( "/etc/fstab" )

#==============================================================================
# Make sudoers entry to allow invocation of connect/disconnect script as 
# non-privileged user
#==============================================================================
#==============================================================================
# NEVEREVER TAKE DIRECTLY WRITE ACCESS TO /ETC/SUDOERS FILE!!!
#==============================================================================
cp /etc/sudoers /tmp/sudoers.tmp;
[[ $? -ne 0 ]] && echo "Sodoers copy fail"

# Remove old FSTAB_ENTRYs if they exists, use temporary /etc/sudoers
sed -i '/.*'$(basename $VPNSCR)'.*/d' /tmp/sudoers.tmp

# Append a new sudoers FSTAB_ENTRY to tmp file
bash -c "echo -e \"$UNID ALL= NOPASSWD: $VPNSCR\" | (EDITOR=\"tee -a\" visudo -f /tmp/sudoers.tmp)"

# Check tmp sudoers file for syntax errors, owner and mode.
visudo -cf /tmp/sudoers.tmp

# Check return value and replace sudoers file if exit==0
[[ $? -eq 0 ]] \
    && { mv /tmp/sudoers.tmp /etc/sudoers; } \
    || { echo "Malformed /etc/sudoers.tmp, this is a $(RB BUG). Exit!"; exit -1; }

MODTRACK+=( /etc/sudoers )

#==============================================================================
#=== Redefine VPN script ======================================================
#==============================================================================
rm -f ${VPNSCR}

for m in ${MNTPTS[@]}; do
    _MNTPTS+=( "\"$m\"" )
done

printf '#!/bin/bash
ZKI_USER="'"${ZKI_USER}"'"
ZKI_PASSWD="'"${ZKI_PASSWD}"'"
UNID="'"${UNID}"'"
MNTPTS=( '"$(echo "${_MNTPTS[@]}")"' )
IFACE="vpnZw"
VPN_HOST="vpn1.fh-zwickau.de"

function errorHandler() {
   echo -e "usage:   $(basename $0) -c|d|m|u
      -c        # Connect VPN tunnel
      -d        # Umount and disconnect VPN
      -m        # Mount sambs shares 
      -u        # Umount sambe shares"
   exit -1
}

# Connect/Disconnect VPN tunnel
function _tunnel() {
    # Connect
    if [[ "$1" = *"c"* ]]; then
        killall -q openconnect
        eval `echo "$ZKI_PASSWD" | sudo -u "${UNID}" openconnect --authgroup=1SplitTunnel --user="${ZKI_USER}" --passwd-on-stdin -i${IFACE} --authenticate  ${VPN_HOST}`

        [[ -n "${COOKIE}" ]] \
            && { echo "${COOKIE}" | openconnect --cookie-on-stdin "${HOST}" --servercert "${FINGERPRINT}" -i"${IFACE}" --background; } \
            || { echo "Login COOKIE not set, exiting"; exit -1; }
        return 0;
    fi

    # Disconnect
    if [[ "$1" = *"d"* ]]; then
        _shares "u"
        killall -q openconnect     

        [[ $? -eq 0 ]] \
            && { echo "openconnect daemon killed successfully!"; } \
            || { echo "Killing openconnect daemon failed!"; exit -1; }
    fi

}

# Mount/Umount shares
function _shares() {
    # Mount shares
    if [[ "$1" = *"m"* ]]; then
        [[ $(ifconfig | grep -c "$IFACE") -eq 0 ]] \
            && { echo "No running vpn iface found, can not mount Windows share, exiting!"; exit -1; }

        for s in "${MNTPTS[@]}"; do
            mount $s
            [[ $? -eq 0 ]] \
                && { echo "Successfully mounted samba share on $s!"; } \
                || { echo "Mount error, exiting"; exit -1; }
        done
    fi

    # Umount shares
    if [[ "$1" = *"u"* ]]; then
        umount "${MNTPTS[@]}"
    fi
}

##################################################################################################
# There are several ways to etablish vpn connection:
# preferRD: (4),(3)
##################################################################################################
# (1) Invoke openconnect as privileged user (INSECURE)
# sudo openconnect --authgroup=1SplitTunnel --user="<ZKI-user>" vpn1.fh-zwickau.de --interface="${IFACE}" --background
# (2) Invoke openconnect as privileged user (INSECURE) and pass ZKI password via command line
# printf "<ZKI-password>" | sudo openconnect --authgroup=1SplitTunnel --user="<ZKI-user>" vpn1.fh-zwickau.de --interface="${IFACE}" --background --passwd-on-stdin
# (3) Invoke openconnect as non-privileged user
# eval `openconnect --authgroup=1SplitTunnel --user="<ZKI-user>" --authenticate  vpn1.fh-zwickau.de`; [ -n $COOKIE ] && echo $COOKIE | sudo openconnect --cookie-on-stdin $HOST --servercert $FINGERPRINT --background
# (4) Invoke openconnect as non-privileged user and pass ZKI password via command line
# eval `printf "<ZKI-password>" | openconnect --authgroup=1SplitTunnel --user="<ZKI-user>" --authenticate  vpn1.fh-zwickau.de`; [ -n $COOKIE ] && echo $COOKIE | sudo openconnect --cookie-on-stdin $HOST --servercert $FINGERPRINT --background

ARGIN="$@"

[[ $# -eq 0 ]] | [[ "${ARGIN[0]::1}" != *"-"* ]] && errorHandler;
[[ "$1" == *"c"* ]] || [[ "$1" == *"d"* ]] && { _tunnel $1; sleep 1; } 
[[ "$1" == *"m"* ]] || [[ "$1" == *"u"* ]] && { _shares $1; exit 0; } 
' > "$VPNSCR"
MODTRACK+=( "$VPNSCR" )

echo -e "VPN connect/disconnect script $(basename $VPNSCR) copied to $VPNSCR."

#==============================================================================
#== Prevent read access to vpn script file for non-privileged users ===========
#== because it holds your cleartext ZKI credentials ===========================
#==============================================================================
chmod 711 "$VPNSCR"
ALIASBASE="$(basename $VPNSCR | sed 's/\.sh//g')"
sudo -u $UNID sed -i.bak_${DTRACK} '/.*'"$ALIASBASE"'.*/d' $HOME/.bash_aliases

# Add *Connect and *Disconnect aliases to ~/.bash_aliases
sudo -u $UNID sed -i '2 a alias '"$ALIASBASE"'Connect='\""sudo $VPNSCR"' -cm\"' $HOME/.bash_aliases
sudo -u $UNID sed -i '2 a alias '"$ALIASBASE"'Disconnect='\""sudo $VPNSCR"' -d\"' $HOME/.bash_aliases

MODTRACK+=( $(sudo -u $UNID echo "$HOME/.bash_aliases") )
MODTRACK+=( ${MODTRACK[-1]}.bak_${DTRACK} )
sudo -k

echo -e "Aliases for ${ALIASBASE}Connect and ${ALIASBASE}Disconnect created.\n"; 
GY $(hline); echo -e "$(GB Installed\!)"; GY $(hline);
echo -e "Run $(BD source ~/\.bash\_aliases) or open new bash terminal and test command $(BD ${ALIASBASE}Connect).\n"
GY $(hline)
echo -e "$(OB List of modified files/dirs:)"; GY $(hline)
echo "${MODTRACK[@]}" | tr ' ' '\n' | tee modified_files.log

