set -ux
tmux new-session -d -s cn5g
tmux split-window -v
tmux select-layout even-vertical
sudo journalctl -u open5gs-amfd -u open5gs-smfd -f --output cat
