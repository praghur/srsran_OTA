set -ux
tmux new-session -d -s ue1
tmux split-window -v
tmux select-layout even-vertical
tmux attach-session -d -t ue1
sudo quectel-CM -s internet -4
/local/repository/bin/module-off.sh
/local/repository/bin/module-on.sh
sudo ip route add 10.45.2.10 via 10.45.0.1



set -ux
tmux new-session -d -s ue2
tmux split-window -v
tmux select-layout even-vertical
tmux attach-session -d -t ue2
sudo quectel-CM -s internet -4
/local/repository/bin/module-off.sh
/local/repository/bin/module-on.sh
sudo ip route add 10.45.1.10 via 10.45.0.1


set -ux
tmux new-session -d -s ue3
tmux split-window -v
tmux select-layout even-vertical
tmux attach-session -d -t ue3
sudo quectel-CM -s internet -4
/local/repository/bin/module-off.sh
/local/repository/bin/module-on.sh
sudo ip route add 10.45.4.10 via 10.45.0.1

set -ux
tmux new-session -d -s ue4
tmux split-window -v
tmux select-layout even-vertical
tmux attach-session -d -t ue4
sudo quectel-CM -s internet -4
/local/repository/bin/module-off.sh
/local/repository/bin/module-on.sh
sudo ip route add 10.45.3.10 via 10.45.0.1
##OR
sudo sh -c "chat -t 1 -sv '' AT OK 'AT+CFUN=4' OK < /dev/ttyUSB2 > /dev/ttyUSB2"
