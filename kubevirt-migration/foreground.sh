# Need schedulable for migration

kubectl taint node controlplane node-role.kubernetes.io/control-plane:NoSchedule-
kubectl taint node controlplane node-role.kubernetes.io/master:NoSchedule-
sleep 20
kubectl -n kubevirt wait --for=jsonpath='{.status.phase}'=Deployed kubevirt/kubevirt --timeout 9m && echo "KubeVirt is deployed"