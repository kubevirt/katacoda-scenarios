until [ -e /usr/local/bin/virtctl ]
do
    sleep 5
done
until kubectl -n kubevirt wait --for=jsonpath='{.status.phase}'=Deployed kubevirt/kubevirt --timeout 9m
do
    sleep 30
done

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
export PS1="\[\e[1;33m\]\h $ \[\e[1;36m\]"
trap 'echo -ne "\e[0m"' DEBUG

echo "KubeVirt is deployed"
