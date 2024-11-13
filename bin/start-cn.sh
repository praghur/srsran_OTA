set -ux
tmux new-session -d -s cn5g
tmux split-window -v
tmux select-layout even-vertical
tmux attach-session -d -t cn5g
sudo tc qdisc add dev ogstun root netem delay 1ms
sudo journalctl -u open5gs-amfd -u open5gs-smfd -f --output cat

