#!/usr/bin/env bash

run_it () {

PREFIX="/usr/local"

set -e
set -u

# Let's display everything on stderr.
exec 1>&2

UNAME=$(uname)
# Check to see if OS is Raspbian
if [ "$UNAME" != "Linux" ] ; then
    echo "This installer script is only designed to be executed on Raspbian."
    echo "Please run this script on a v3 Rasbperry Pi with Raspbian installed."
    exit 1
fi

# Check that script is running under root
if [ "$EUID" -ne 0 ] ; then
    echo "This installer script must be run with sudo."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# All relative paths are relative to SCRIPT location
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
cd "$parent_path"

# Update the package manager and install base packages
apt-get update --assume-yes
apt-get upgrade --assume-yes
apt-get install --assume-yes openssh-server
apt-get install --assume-yes emacs
apt-get install --assume-yes vim
apt-get install --assume-yes tmux

## STEP 1: Dumpcap Setup ###

# Install packages
apt-get install --assume-yes wireshark tshark python-pip libpcap-dev python-dev # tshark includes dumpcap
pip install -r requirements.txt

# Give dumpcap privileges to run in non-root mode (helpful for wireshark analysis)
setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/bin/dumpcap

## STEP 2: Wi-Fi Setup ###

apt-get install --assume-yes hostapd dnsmasq

cp ./config/dhcpcd.conf /etc/dhcpcd.conf
cp ./config/interfaces /etc/network/interfaces
service dhcpcd restart

cp ./config/hostapd.conf /etc/hostapd/hostapd.conf
cp ./config/hostapd /etc/default/hostapd

cp ./config/dnsmasq.conf /etc/dnsmasq.conf

# Setup iptables for NAT

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

sh -c "iptables-save > /etc/iptables.ipv4.nat"

ifdown wlan0
ifup wlan0

service hostapd restart
service dnsmasq restart

# Ensure that services restart on reboot
update-rc.d hostapd enable
update-rc.d sshd enable
update-rc.d dnsmasq enable
update-rc.d dhcpcd enable

cp ./config/nat-startup.sh /etc/init.d/nat-startup.sh
chmod +x /etc/init.d/nat-startup.sh
update-rc.d nat-startup.sh defaults 100

}

run_it
