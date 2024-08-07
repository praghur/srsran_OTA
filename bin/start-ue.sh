set -ux
tmux new-session -d -s ue1
tmux split-window -v
tmux select-layout even-vertical
tmux attach-session -d -t ue1
