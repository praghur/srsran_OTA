###Rev1
#!/bin/bash

# Define the list of nodes
nodes=("pc741" "pc06-fort" "ota-x310-1" "pc09-fort" "ota-x310-2" "pc05-fort" "ota-x310-3" "ota-nuc1" "ota-nuc2" "ota-nuc3" "ota-nuc4")

# SSH username and hostname
username="praghur"
host_suffix=".emulab.net"

# Loop through the nodes and open terminal windows with SSH commands
for node in "${nodes[@]}"; do
    gnome-terminal -- bash -c "ssh -o StrictHostKeyChecking=no ${username}@${node}${host_suffix}; exec bash" &
done


#--------------------------------
#Rev2

#!/bin/bash

# Define the list of nodes
nodes=("pc741" "pc06-fort" "pc09-fort" "pc05-fort" "ota-nuc1" "ota-nuc2" "ota-nuc3" "ota-nuc4")

# Define the list of scripts to run on each node
scripts=("start_cn.sh" "start_gnb1.sh" "start_gnb2.sh" "start_gnb3.sh" "start_ue1.sh" "start_ue2.sh" "start_ue3.sh" "start_ue4.sh")

# SSH username and hostname
username="praghur"
host_suffix=".emulab.net"

# Loop through the nodes and open terminal windows with SSH commands
for i in "${!nodes[@]}"; do
    node=${nodes[$i]}
    script=${scripts[$i]}
    gnome-terminal -- bash -c "ssh -o StrictHostKeyChecking=no ${username}@${node}${host_suffix} 'chmod +x /local/repository/bin/${script} && /local/repository/bin/${script}'; exec bash" &
done
