#First ensure iperf3 is installed in source and destination
sudo apt-get update
sudo apt-get install iperf3

#At the server (destination)
iperf3 -s  #This will cause a message called "Server listening on 5201"

#At the client (source)
iperf3 -c 10.45.0.5 -u -b 1M -t 10
#where 10.45.0.5 is the server (destination) IP address
# -u is UDP test
# -b setting the bandwidth to 1Mbps
# -t setting the duration of test to 10 seconds. 


#Traceroute will provide us with latency for the data transmission
#First install traceroute in the source and destination
sudo apt-get update
sudo apt-get install traceroute

#At the source machine (client), run the traceroute command with -U to indicate UDP packets. 
#The size can be changed (I did not test this) using the command traceroute -U -s 1200 10.45.0.9 where 1200 bytes of UDP packets will be sent
traceroute -U -p 33435 10.45.2.10

#Import pcap files from server to VM
scp praghur@pc14-fort.emulab.net:/var/tmp/gnb_mac.pcap /home/ubuntu/
