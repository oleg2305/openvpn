#!/bin/bash

pause(){
   read -p "$*"
}

usage(){
cat << EOF
  usage: $0 options

  This script will bloc user sertificate from openvpn base. Please, run this script on slave an make sure:
  OPTIONS:
  -help      Show this message
  -u         user login name

  Example: $0  -u v.userov

EOF
}

USER=
        while getopts "help:u:?" OPTION
        do
                case $OPTION in
                help)
                        usage
                        exit 1
                        ;;
                u)
                        USER=$OPTARG
                        ;;
                ?)
                        usage
                        exit
                        ;;
                esac
        done
if  [[ -z $USER ]]
        then
                usage
                exit 1
        fi
cd /etc/openvpn/easy-rsa/
echo
echo
echo

source ./vars
./revoke-full $USER
mv /etc/openvpn/fixed-ip/$USER /etc/openvpn/removed
cp -a keys/crl.pem /etc/openvpn/
chmod 755 /etc/openvpn/crl.pem
sed -i "/^$USER/d" /opt/admin/conf/ip.txt

coproc sqlite3 /opt/admin/ovpn.bd
echo "UPDATE net set user = null where user like '$USER';" >&${COPROC[1]}

echo "User $USER deleted"
exit 0
