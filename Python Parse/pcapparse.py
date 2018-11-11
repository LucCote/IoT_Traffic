from scapy.all import rdpcap
from scapy.layers.inet import TCP

data = "../../documents/IoT_Traffic/pcaps/tester.pcap"
a = rdpcap(data)
sessions = a.sessions()
for session in sessions:
    for packet in sessions[session]:
        try:
            if packet[TCP].dport == 80 or packet[TCP].sport == 80:
                print(str(packet[TCP].payload))
        except:
            pass