#!/usr/bin/env bash

run_it () {
apt-get install --assume-yes hostapd dnsmasq

cp ./config/dhcpcd.conf /etc/dhcpcd.conf
cp ./config/interfaces /etc/network/interfaces
service dhcpcd restart

cp ./config/hostapd.conf /etc/hostapd/hostapd.conf
cp ./config/hostapd /etc/default/hostapd

cp ./config/dnsmasq.conf /etc/dnsmasq.conf

# Setup iptables for NAT
echo hit2
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

sh -c "iptables-save > /etc/iptables.ipv4.nat"

ifdown wlan0
ifup wlan0
echo hit3
service hostapd restart
service dnsmasq restart
echo hit4
# Ensure that services restart on reboot
update-rc.d hostapd enable
update-rc.d dnsmasq enable
update-rc.d dhcpcd enable
echo hit5
cp ./config/nat-startup.sh /etc/init.d/nat-startup.sh
chmod +x /etc/init.d/nat-startup.sh
update-rc.d nat-startup.sh defaults 100
}
run_it