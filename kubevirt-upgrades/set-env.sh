# Disable showing commands as being typed
stty -echo

export PSBACKUP="$PS1"
export PS1=""
clear

echo -e "\nPreparking Kubernetes environment... hold on"
launch.sh > /dev/null 2>&1

# Get lateste KubeVirt virtctl
export KUBEVIRT_LATEST_VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | jq -r .tag_name) > /dev/null 2>&1

echo -e  "\nDownloading latest virtctl command... hold on"
# Download virctl
wget -O virtctl https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_LATEST_VERSION}/virtctl-${KUBEVIRT_LATEST_VERSION}-linux-amd64 > /dev/null 2>&1
chmod +x virtctl
clear

echo -e  "\nEnvironment is ready and virtctl is installed, go ahead"

SESSION=$USER

# Restore prompt
export PS1="$PSBACKUP"

tmux -2 new-session -d -s $SESSION

# Setup a window for tailing log files
tmux new-window -t $SESSION:1 -n 'Pods'
tmux split-window -v
tmux select-pane -t 0
tmux send-keys "watch -n 0.5 'kubectl -n kubevirt get pods'" C-m
tmux select-pane -t 1
tmux send-keys "clear" C-m

# Set default window
tmux select-window -t $SESSION:1

# Enable back showing commands when typed
stty echo

# Attach to session
tmux -2 attach-session -t $SESSION
