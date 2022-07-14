kubectl taint node controlplane node-role.kubernetes.io/control-plane:NoSchedule-
kubectl taint node controlplane node-role.kubernetes.io/master:NoSchedule-

until kubectl -n kubevirt wait --for=jsonpath='{.status.phase}'=Deployed kubevirt/kubevirt --timeout 9m
do
    sleep 30
done

export PS1="\[\e[1;33m\]\h $ \[\e[1;36m\]"
trap 'echo -ne "\e[0m"' DEBUG

echo "KubeVirt is deployed"