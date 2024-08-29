set -ux
tmux new-session -d -s ue4
tmux split-window -v
tmux select-layout even-vertical
tmux attach-session -d -t ue4
sudo quectel-CM -s internet -4
/local/repository/bin/module-off.sh
