ip="192.168.1.22"
netmask="255.255.255.0"
gateway="192.168.1.1"
dns="192.168.1.2"
apt-get update
apt-get dist-upgrade -y
apt-get install cron-apt htop -y
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p
sed -i -e 's/iface eth0 inet dhcp/#iface eth0 inet dhcp/g' /etc/network/interfaces
echo "iface eth0 inet static" >> /etc/network/interfaces
echo "address $ip" >> /etc/network/interfaces
echo "netmask $netmask" >> /etc/network/interfaces
echo "gateway $gateway" >> /etc/network/interfaces
echo "dns-nameservers $dns" >> /etc/network/interfaces
echo "## Debian/Ubuntu" >> /etc/apt/sources.list
echo "# stable => unifi4" >> /etc/apt/sources.list
echo "# deb http://www.ubnt.com/downloads/unifi/debian unifi4 ubiquiti" >> /etc/apt/sources.list
echo "deb http://www.ubnt.com/downloads/unifi/debian unifi5 ubiquiti" >> /etc/apt/sources.list
echo "# deb http://www.ubnt.com/downloads/unifi/debian stable ubiquiti" >> /etc/apt/sources.list
echo "# oldstable => unifi3" >> /etc/apt/sources.list
echo "# deb http://www.ubnt.com/downloads/unifi/debian unifi3 ubiquiti" >> /etc/apt/sources.list
echo "# deb http://www.ubnt.com/downloads/unifi/debian oldstable ubiquiti" >> /etc/apt/sources.list
apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50
apt-get update
apt-get install unifi -y
sed -i "41i unifi.https.port=443" /usr/lib/unifi/data/system.properties
# not sure if smallfiles makes a big difference, testing needed
# echo "unifi.db.extraargs=--smallfiles" >> /usr/lib/unifi/data/system.properties
echo 'ENABLE_MONGODB=no' | sudo tee -a /etc/mongodb.conf > /dev/null
iptables -F
iptables -P INPUT DROP
iptables -A INPUT -i lo -p all -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8843 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8880 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -j DROP
su -c "iptables-save > /etc/iptables.conf"
sed -i "13i iptables-restore < /etc/iptables.conf" /etc/rc.local
reboot
