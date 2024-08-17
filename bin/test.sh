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
