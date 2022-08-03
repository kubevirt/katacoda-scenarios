until [ -e "/usr/local/bin/kubectl" ]
do
  echo waiting for k3s to install
  sleep 5
done

alias k=kubectl

export PS1="\[\e[1;33m\]\h $ \[\e[1;36m\]"
trap 'echo -ne "\e[0m"' DEBUG
echo