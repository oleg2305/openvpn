# openvpn
openvpn за 20 мин
debian 9

apt-get install git openvpn sqlite3 easy-rsa cryptsetup python-pip

pip install ipcalc

git clone https://github.com/oleg2305/openvpn && cd openvpn

gzip -d ./vpn.img.gz

Ключ по умолчаню Qwerty

Смена ключа:

cryptsetup -y luksAddKey ./vpn.img

cryptsetup luksRemoveKey ./vpn.img

cryptsetup luksOpen vpn.img volume1

mount /dev/mapper/volume1 /etc/openvpn

cd /etc/openvpn/admin && ./firstrun.sh

Замените подсеть по умолчанию на свою:

python ./createbd.py 192.168.4.0/24

Для генерации конфига для пользователя запустите:

./create_vpnuser_new.sh -u user1

где user1 - учетная запись пользователя
