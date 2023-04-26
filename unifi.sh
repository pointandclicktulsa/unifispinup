# After running this prep script see the below link!!
# https://community.ubnt.com/t5/UniFi-Wireless/UniFi-Installation-Scripts-UniFi-Easy-Update-Scripts-Works-on/td-p/2375150
# Running on port <1024 no longer works, controller runs as non-root since 5.6.22! Unifi MUST use a port above 1024
# Start the script proper
# Update Ubuntu before starting unifi install, and install cron-apt/htop for maintenance purposes
apt update
apt dist-upgrade -y
apt install cron-apt htop -y
cron-apt
# Disable ipv6 on all interfaces, remove if your network is actually using ipv6
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/&ipv6.disable=1/' /etc/default/grub
update-grub
# Firewall config
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh/tcp
ufw allow 53/tcp
ufw allow 53/udp
ufw allow 443/tcp
ufw allow 3478/udp
ufw allow 5514/udp
ufw allow 8080/tcp
ufw allow 8443/tcp
ufw allow 8880/tcp
ufw allow 8843/tcp
ufw allow 6789/tcp
ufw allow 5656:5699/udp
ufw allow 10001/udp
ufw allow 1900/udp
ufw allow 123/udp
reboot
