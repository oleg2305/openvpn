#!/bin/bash

pause(){
   read -p "$*"
}

usage(){
cat << EOF
  usage: $0 options

  This script will create user client config openvpn. Please, run this script on slave an make sure:
  OPTIONS:
  -help      Show this message
  -u         user login name

  Example: $0 -u v.piskin


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
clear

if [ -f /etc/openvpn/admin/ovpn.bd ]; then
	coproc sqlite3 /etc/openvpn/admin/ovpn.bd
	echo "SELECT a, b FROM net where user is null limit 1;" >&${COPROC[1]}
	read res <&${COPROC[0]}
	ADDRES1=$(echo $res | awk -v FS=\| '{print $1}')
	ADDRES2=$(echo $res | awk -v FS=\| '{print $2}')
	echo "UPDATE net set user = '$USER' where a like '$ADDRES1';" >&${COPROC[1]}
else
	python /etc/openvpn/admin/createbd.py
	coproc sqlite3 /etc/openvpn/admin/ovpn.bd
	echo "SELECT a, b FROM net where user is null limit 1;" >&${COPROC[1]}
	read res <&${COPROC[0]}
	ADDRES1=$(echo $res | awk -v FS=\| '{print $1}')
	ADDRES2=$(echo $res | awk -v FS=\| '{print $2}')
	echo "UPDATE net set user = '$USER' where a like '$ADDRES1';" >&${COPROC[1]}
fi

cd /etc/openvpn/easy-rsa/
echo
echo
echo "Generate sertificate for $USER  ......."
echo
echo

source ./vars
./build-key $USER
 if [ -z `find ./keys/$USER.crt -size 0` ]; then

	touch /etc/openvpn/ccd/$USER
	echo "ifconfig-push $ADDRES1 $ADDRES2" > /etc/openvpn/ccd/$USER
	echo "$USER $ADDRES1 $ADDRES2" >> /etc/openvpn/admin/conf/ip.txt
	touch /etc/openvpn/admin/conf/$USER.ovpn
	echo "client
dev tun
remote 46.173.213.75 21999 udp
resolv-retry infinite
nobind
comp-lzo
persist-key
persist-tun
tls-client
tls-timeout 12
#auth SHA1
cipher AES-128-CBC
mute 20
remote-cert-tls server
key-direction 1

<ca>
" > /etc/openvpn/admin/conf/$USER.ovpn
	/bin/cat /etc/openvpn/easy-rsa/keys/ca.crt >> /etc/openvpn/admin/conf/$USER.ovpn
	echo "</ca>

<cert>" >> /etc/openvpn/admin/conf/$USER.ovpn
	/bin/cat /etc/openvpn/easy-rsa/keys/$USER.crt >> /etc/openvpn/admin/conf/$USER.ovpn
	echo "</cert>

<key>" >> /etc/openvpn/admin/conf/$USER.ovpn
	/bin/cat /etc/openvpn/easy-rsa/keys/$USER.key >> /etc/openvpn/admin/conf/$USER.ovpn
	echo "</key>

<tls-auth>" >> /etc/openvpn/admin/conf/$USER.ovpn
	/bin/cat /etc/openvpn/easy-rsa/keys/ta.key >> /etc/openvpn/admin/conf/$USER.ovpn
	echo "</tls-auth>" >> /etc/openvpn/admin/conf/$USER.ovpn
	echo "IP - $ADDRES1"	
	echo "Congratulations, you created openvpn config file - /etc/openvpn/admin/conf/$USER.ovpn" 
	exit 0
else 
	echo "Sertificate not found  !!!"
fi
