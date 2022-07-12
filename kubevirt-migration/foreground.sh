#!/bin/bash

export PS1="\[\e[1;33m\]\h $ \[\e[1;36m\]"
trap 'echo -ne "\e[0m"' DEBUG

# Need schedulable for migration

kubectl taint node controlplane node-role.kubernetes.io/control-plane:NoSchedule-
kubectl taint node controlplane node-role.kubernetes.io/master:NoSchedule-
sleep 20
kubectl -n kubevirt wait --for=jsonpath='{.status.phase}'=Deployed kubevirt/kubevirt --timeout 9m && echo "KubeVirt is deployed"