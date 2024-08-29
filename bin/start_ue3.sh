set -ux
tmux new-session -d -s ue3
tmux split-window -v
tmux select-layout even-vertical
tmux attach-session -d -t ue3
sudo quectel-CM -s internet -4
/local/repository/bin/module-off.sh
/local/repository/bin/module-on.sh
