# openvpn
openvpn за 20 мин
debian 9

apt-get install git openvpn sqlite3 easy-rsa cryptsetup python-pip

pip install ipcalc

git clone https://github.com/oleg2305/openvpn && cd openvpn

gzip -d ./vpn.img.gz

Default password Qwerty

cryptsetup -y luksAddKey ./vpn.img

cryptsetup luksRemoveKey ./vpn.img

cryptsetup luksOpen vpn.img volume1

mount /dev/mapper/volume1 /etc/openvpn

