# If you want the unifi controller to run the web interface on 443,
# after the reboot, run "sudo sed -i "40i unifi.https.port=443" /usr/lib/unifi/data/system.properties"
# If you want it on 8443, do nothing, other than change this script's iptables rules to alow 8443.
# Set your static IP information in the variables below
ip="192.168.1.22"
netmask="255.255.255.0"
gateway="192.168.1.1"
dns="192.168.1.2"
# Start the script proper
# Update Ubuntu before starting unifi install, and install cron-apt/htop for maintenance purposes
apt-get update
apt-get dist-upgrade -y
apt-get install cron-apt htop -y
apt-get install linux-virtual-lts-xenial
apt-get install linux-tools-virtual-lts-xenial
apt-get install linux-cloud-tools-virtual-lts-xenial
# Disable ipv6 on all interfaces, remove if your network is actually using ipv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p
# Set static IP, this may need changed if using ipv6
sed -i -e 's/iface eth0 inet dhcp/#iface eth0 inet dhcp/g' /etc/network/interfaces
echo "iface eth0 inet static" >> /etc/network/interfaces
echo "address $ip" >> /etc/network/interfaces
echo "netmask $netmask" >> /etc/network/interfaces
echo "gateway $gateway" >> /etc/network/interfaces
echo "dns-nameservers $dns" >> /etc/network/interfaces
# Add Unifi sources, if you want to install from a different channel than unifi5 modify this portion
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
# Start Unifi package install and config
apt-get install unifi -y
# not sure if smallfiles makes a big difference, testing needed
# echo "unifi.db.extraargs=--smallfiles" >> /usr/lib/unifi/data/system.properties
echo 'ENABLE_MONGODB=no' | sudo tee -a /etc/mongodb.conf > /dev/null
# Iptables hardening to only allow the 5 ports you need
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
# Iptables persistance through reboot
su -c "iptables-save > /etc/iptables.conf"
sed -i "13i iptables-restore < /etc/iptables.conf" /etc/rc.local
reboot
