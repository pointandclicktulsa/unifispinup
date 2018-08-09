# Running on port <1024 no longer works, controller runs as non-root since 5.6.22! Unifi MUST use a port above 1024
# Set your static IP information in the variables below
# See https://community.ubnt.com/t5/UniFi-Wireless/UniFi-Installation-Scripts-Works-on-Ubuntu-18-04-and-16-04/td-p/2375150
# For the install script
ip="192.168.1.22"
netmask="255.255.255.0"
gateway="192.168.1.1"
dns="192.168.1.2"
# Start the script proper
# Update Ubuntu before starting unifi install, and install cron-apt/htop for maintenance purposes
apt-get update
apt-get dist-upgrade -y
apt-get install htop linux-virtual-lts-xenial linux-tools-virtual-lts-xenial linux-cloud-tools-virtual-lts-xenial -y
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
# Run the mongodb stuff after installing the controller
# echo 'ENABLE_MONGODB=no' | sudo tee -a /etc/mongodb.conf > /dev/null
# Iptables hardening to only allow the 7 ports you need
iptables -F
iptables -P INPUT DROP
iptables -A INPUT -i lo -p all -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 3478 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 6789 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8443 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8843 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8880 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 10001 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -j DROP
# Iptables persistance through reboot
su -c "iptables-save > /etc/iptables.conf"
sed -i "13i iptables-restore < /etc/iptables.conf" /etc/rc.local
reboot
