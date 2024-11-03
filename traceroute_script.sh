sudo tcpdump -i any host 8.8.8.8 -w /home/ubuntu/traceroute_ue1.pcap &
#sudo tcpdump -i any host 10.45.2.10 -w /tmp/traceroute_ue1.pcap &

# Run traceroute 30 times
    for i in {1..3}; do
        #traceroute -U -f 2 -m 2 10.45.2.10
        traceroute -U -f 2 -m 2 8.8.8.8
    done
    
 sudo pkill tcpdump
 sudo chmod 777 -v /home/ubuntu/traceroute_ue1.pcap
 #sudo chmod 777 -v /tmp/traceroute_ue1.pcap
