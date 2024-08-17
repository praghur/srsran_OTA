#First ensure iperf3 is installed in source and destination
sudo apt-get update
sudo apt-get install iperf3

#At the server (destination)
iperf3 -s  #This will cause a message called "Server listening on 5201"
