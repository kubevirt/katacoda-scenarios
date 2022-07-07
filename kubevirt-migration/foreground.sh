# Need schedulable for migration

kubectl taint node controlplane node-role.kubernetes.io/master:NoSchedule-

kubectl -n kubevirt wait --for=jsonpath='{.status.phase}'=Deployed kubevirt/kubevirt

echo "KubeVirt is deployed"