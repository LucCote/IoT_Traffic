#!/usr/bin/env bash

# Check that arguments supplied
if [ $# -ne 6 ] ; then
    echo "Usage: ./start.sh local_directory pcap_filename ssh_username ssh_server remote_directory ssh_password"
    exit 1
fi

# Check that script is running under root
if [ "$EUID" -ne 0 ] ; then
    echo "This start script must be run with sudo."
    exit 1
fi

python directory_monitor "$1" "$3" "$4" "$5" "$6" &
dumpcap -P -i wlan0 -w "$1/$2.pcap" -b filesize:100000 &
