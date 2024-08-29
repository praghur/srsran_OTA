set -ux
tmux new-session -d -s ue1
tmux split-window -v
tmux select-layout even-vertical
tmux attach-session -d -t ue1
sudo quectel-CM -s internet -4
/local/repository/bin/module-off.sh
/local/repository/bin/module-on.sh
