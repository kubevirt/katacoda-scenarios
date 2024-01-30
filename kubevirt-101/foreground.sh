until [ -f "$HOME/.kube/config" ]
do
  echo waiting for k3s to install
  sleep 5
done

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

alias k=kubectl

export PS1="\[\e[1;33m\]\h $ \[\e[1;36m\]"
trap 'echo -ne "\e[0m"' DEBUG
echo
