set -ux
tmux new-session -d -s ue1
tmux split-window -v
tmux select-layout even-vertical
tmux attach-session -d -t ue1
sudo quectel-CM -s internet -4
/local/repository/bin/module-off.sh
/local/repository/bin/module-on.sh


set -ux
tmux new-session -d -s ue2
tmux split-window -v
tmux select-layout even-vertical
tmux attach-session -d -t ue2
sudo quectel-CM -s internet -4
/local/repository/bin/module-off.sh
/local/repository/bin/module-on.sh

set -ux
tmux new-session -d -s ue3
tmux split-window -v
tmux select-layout even-vertical
tmux attach-session -d -t ue3
sudo quectel-CM -s internet -4
/local/repository/bin/module-off.sh
/local/repository/bin/module-on.sh

set -ux
tmux new-session -d -s ue4
tmux split-window -v
tmux select-layout even-vertical
tmux attach-session -d -t ue4
sudo quectel-CM -s internet -4
/local/repository/bin/module-off.sh
