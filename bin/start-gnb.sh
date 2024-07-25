set -ux
tmux new-session -d -s gnb1
tmux send-keys 'sudo /var/tmp/srsRAN_Project/build/apps/gnb/gnb  -c /local/repository/etc/srsran/gnb_x310.yml -c /var/tmp/srsRAN_Project/configs/qam256.yml' C-m
tmux split-window -v
tmux select-layout even-vertical
tmux attach-session -d -t gnb1
