# After running this prep script see the below link!!
# https://community.ubnt.com/t5/UniFi-Wireless/UniFi-Installation-Scripts-UniFi-Easy-Update-Scripts-Works-on/td-p/2375150
# Running on port <1024 no longer works, controller runs as non-root since 5.6.22! Unifi MUST use a port above 1024
# Set your static IP information in the variables below
ip="192.168.1.22"
netmask="255.255.255.0"
gateway="192.168.1.1"
dns="192.168.1.2"
# Start the script proper
# Update Ubuntu before starting unifi install, and install cron-apt/htop for maintenance purposes
apt-get update
apt-get dist-upgrade -y
apt-get install cron-apt htop linux-virtual-lts-xenial linux-tools-virtual-lts-xenial linux-cloud-tools-virtual-lts-xenial -y
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
# Firewall config
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh/tcp
ufw allow 8080/tcp
ufw allow 8443/tcp
ufw allow 8880/tcp
ufw allow 8843/tcp
ufw allow 6789/tcp
ufw allow 3478/udp
ufw allow 5656:5699/udp
ufw allow 10001/udp
ufw allow 1900/udp
reboot
