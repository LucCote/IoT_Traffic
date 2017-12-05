#!/usr/bin/env bash

# Check that script is running under root
if [ "$EUID" -ne 0 ] ; then
    echo "This start script must be run with sudo."
    exit 1
fi

dumpcap -P -i wlan0 -w "$1/$2.pcap" -b filesize:100000 &
