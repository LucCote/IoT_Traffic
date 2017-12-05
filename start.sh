#!/usr/bin/env bash

# Check that arguments supplied
if [ $# -lt 2 ]
  then
    echo "Usage: ./start.sh output_directory pcap_filename"
    exit 1
fi

# Check that script is running under root
if [ "$EUID" -ne 0 ] ; then
    echo "This start script must be run with sudo."
    exit 1
fi

dumpcap -P -i wlan0 -w "$1/$2.pcap" -b filesize:100000 &
