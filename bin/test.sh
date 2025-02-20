sudo ip route add 10.45.2.10 via 10.45.0.1
sudo traceroute -U -f 2 -m 2 -p 33435 10.45.2.10

sudo ip route add 10.45.1.10 via 10.45.0.1
sudo traceroute -U -f 2 -m 2 -p 33435 10.45.1.10

#Install tshark in UE1 and UE2
sudo apt update
sudo apt install -y tshark

#Continue with packet capture
sudo tshark -i ogstun -T fields -e frame.time_epoch -e ip.src -e ip.dst -e ip.id -e udp.srcport -e udp.dstport -E header=y -E separator=, -E quote=d > cn_results.csv
sudo tcpdump -i ogstun -w ogstun_capture.pcap

sudo tshark -i enx5e4cb4adde52 -T fields -e frame.time_epoch -e ip.src -e ip.dst -e ip.id -e udp.srcport -e udp.dstport -E header=y -E separator=, -E quote=d > ue1_results.csv
sudo tcpdump -i enx5e4cb4adde52 -w ue1_capture.pcap

sudo tshark -i enx7a6202a42b3f -T fields -e frame.time_epoch -e ip.src -e ip.dst -e ip.id -e udp.srcport -e udp.dstport -E header=y -E separator=, -E quote=d > ue2_results.csv
sudo tcpdump -i enx7a6202a42b3f -w ue2_capture.pcap

sudo tshark -i enxa686a3fc16a2 -T fields -e frame.time_epoch -e ip.src -e ip.dst -e ip.id -e udp.srcport -e udp.dstport -E header=y -E separator=, -E quote=d > ueTraff_results.csv
sudo tcpdump -i enxa686a3fc16a2 -w ueTraff_capture.pcap


#Save results from CN
scp root@pc11-fort.emulab.net:cn_results.csv /home/ubuntu/
scp root@pc11-fort.emulab.net:ogstun_capture.pcap /home/ubuntu/

#Save results from UE1
scp root@ota-nuc1.emulab.net:ue1_results.csv /home/ubuntu/
scp root@ota-nuc1.emulab.net:ue1_capture.pcap /home/ubuntu/
scp root@ota-nuc1.emulab.net:/local/repository/etc/srsran/traceroute_results.csv /home/ubuntu/

#Save results from UE2 - Background data
scp root@ota-nuc2.emulab.net:ueTraff_results.csv /home/ubuntu/
scp root@ota-nuc2.emulab.net:ueTraff_capture.pcap /home/ubuntu/


#Save results from gnb1
scp root@pc04-meb.emulab.net:/tmp/gnb1_mac.pcap /home/ubuntu/
scp root@pc04-meb.emulab.net:/tmp/gnb1_ngap.pcap /home/ubuntu/
scp root@pc04-meb.emulab.net:/tmp/gnb1-trace.log /home/ubuntu/
scp root@pc04-meb.emulab.net:/tmp/gnb1.log /home/ubuntu/

#Save results from UE2
scp root@nuc1.web.powderwireless.net:ue2_results.csv /home/ubuntu/
scp root@nuc1.web.powderwireless.net:ue2_capture.pcap /home/ubuntu/

#Save results from gnb2
scp root@pc01-meb.emulab.net:/tmp/gnb2_mac.pcap /home/ubuntu/
scp root@pc01-meb.emulab.net:/tmp/gnb2_ngap.pcap /home/ubuntu/
