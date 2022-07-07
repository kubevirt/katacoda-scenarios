# Need schedulable for migration

kubectl taint node controlplane node-role.kubernetes.io/master:NoSchedule-
sleep 30
kubectl -n kubevirt wait --for=jsonpath='{.status.phase}'=Deployed kubevirt/kubevirt --timeout 9m && echo "KubeVirt is deployed"