launch.sh

# Get lateste KubeVirt virtctl
export KUBEVIRT_LATEST_VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | jq -r .tag_name)

# Download virctl
wget -O virtctl https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_LATEST_VERSION}/virtctl-${KUBEVIRT_LATEST_VERSION}-linux-amd64
chmod +x virtctl
clear

echo "Environment is ready and virtctl is installed, go ahead"

SESSION=$USER

tmux -2 new-session -d -s $SESSION

# Setup a window for tailing log files
tmux new-window -t $SESSION:1 -n 'Pods'
tmux split-window -v
tmux select-pane -t 0
tmux send-keys "watch -n 0,5 'kubectl -n kubevirt get pods'" C-m
tmux select-pane -t 1

# Set default window
tmux select-window -t $SESSION:1

# Attach to session
tmux -2 attach-session -t $SESSION
