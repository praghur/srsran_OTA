#!/bin/bash

# Define the source and destination IP addresses
SOURCE_IP="10.45.1.10"
DEST_IP="10.45.2.10"

# Function to start tcpdump on a given node
start_tcpdump() {
  local node_ip=$1
  local output_file=$2
  ssh $node_ip "sudo tcpdump -i any udp -w $output_file &"
}

# Function to stop tcpdump on a given node
stop_tcpdump() {
  local node_ip=$1
  ssh $node_ip "sudo pkill tcpdump"
}

# Start tcpdump on both nodes
start_tcpdump $SOURCE_IP "source_capture.pcap"
start_tcpdump $DEST_IP "destination_capture.pcap"

# Run traceroute 30 times
for i in {1..30}
do
  echo "Running traceroute attempt $i"
  traceroute -U -s $SOURCE_IP $DEST_IP
  echo "Completed traceroute attempt $i"
  echo "--------------------------------"
done

# Stop tcpdump on both nodes
stop_tcpdump $SOURCE_IP
stop_tcpdump $DEST_IP

# Download the capture files from both nodes
scp $SOURCE_IP:source_capture.pcap .
scp $DEST_IP:destination_capture.pcap .
