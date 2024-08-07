set -ux
tmux new-session -d -s gnb1
tmux split-window -v
tmux select-layout even-vertical
tmux attach-session -d -t gnb1
sudo /var/tmp/srsRAN_Project/build/apps/gnb/gnb  -c /local/repository/etc/srsran/gnb_x310_1.yml
