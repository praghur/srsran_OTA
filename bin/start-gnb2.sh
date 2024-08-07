set -ux
tmux new-session -d -s gnb2
tmux split-window -v
tmux select-layout even-vertical
tmux attach-session -d -t gnb2
sudo /var/tmp/srsRAN_Project/build/apps/gnb/gnb  -c /local/repository/etc/srsran/gnb_x310_2.yml
