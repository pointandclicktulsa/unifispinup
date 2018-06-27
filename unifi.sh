# Running on port <1024 no longer works, controller runs as non-root since 5.6.22! Unifi MUST use a port above 1024
# Set your static IP information in the variables below
ip="192.168.1.22/24"
gateway="192.168.1.1"
dns="192.168.1.2"
# Start the script proper
# Update Ubuntu before starting unifi install, and install cron-apt for maintenance purposes
apt-get update
apt-get dist-upgrade -y
apt-get install cron-apt -y
# Disable ipv6 on all interfaces, remove if your network is actually using ipv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p
# Set static IP, this may need changed if using ipv6
sed -i -e 's/dhcp4: yes/dhcp4: no/g' /etc/netplan/01-netcfg.yaml
echo "      addresses: [$ip]" >> /etc/netplan/01-netcfg.yaml
echo "      gateway4: $gateway" >> /etc/netplan/01-netcfg.yaml
echo "      nameservers:" >> /etc/netplan/01-netcfg.yaml
echo "       addresses: [$dns]" >> /etc/netplan/01-netcfg.yaml
netplan apply
# Add Unifi sources, if you want to install from a different channel than unifi5 modify this portion
echo "## Debian/Ubuntu" >> /etc/apt/sources.list
echo "# stable => unifi4" >> /etc/apt/sources.list
echo "# deb http://www.ubnt.com/downloads/unifi/debian unifi4 ubiquiti" >> /etc/apt/sources.list
echo "# deb http://www.ubnt.com/downloads/unifi/debian unifi5 ubiquiti" >> /etc/apt/sources.list
echo "deb http://www.ubnt.com/downloads/unifi/debian stable ubiquiti" >> /etc/apt/sources.list
echo "# oldstable => unifi3" >> /etc/apt/sources.list
echo "# deb http://www.ubnt.com/downloads/unifi/debian unifi3 ubiquiti" >> /etc/apt/sources.list
echo "# deb http://www.ubnt.com/downloads/unifi/debian oldstable ubiquiti" >> /etc/apt/sources.list
wget -O /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ubnt.com/unifi/unifi-repo.gpg
apt-get update
# Start Unifi package install and config
apt-get install unifi -y
# not sure if smallfiles makes a big difference, testing needed
# echo "unifi.db.extraargs=--smallfiles" >> /usr/lib/unifi/data/system.properties
echo 'ENABLE_MONGODB=no' | sudo tee -a /etc/mongodb.conf > /dev/null
# Firewall config
ufw allow ssh
ufw allow 3478
ufw allow 6789
ufw allow 58443
ufw allow 8843
ufw allow 8880
ufw allow 8080
ufw allow 10001
ufw --force enable
reboot
