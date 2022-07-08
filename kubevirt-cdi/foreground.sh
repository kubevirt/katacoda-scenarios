# Need schedulable for migration

sleep 20
kubectl -n kubevirt wait --for=jsonpath='{.status.phase}'=Deployed kubevirt/kubevirt --timeout 9m && echo "KubeVirt is deployed"