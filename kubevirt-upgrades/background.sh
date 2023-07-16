#!/bin/bash

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

export KUBEVIRT_VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | jq -r .tag_name)
echo Installing KubeVirt $KUBEVIRT_VERSION

kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-operator.yaml
kubectl -n kubevirt scale deployment/kubevirt-operator --replicas=1

kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-cr.yaml

kubectl -n kubevirt patch kubevirt kubevirt --type=merge --patch '{"spec":{"configuration":{"developerConfiguration":{"useEmulation":true,"featureGates":["LiveMigration"]}}}}'
kubectl -n kubevirt patch kubevirt/kubevirt --type=merge --patch='{"spec": {"infra": {"replicas": 1}}}'

curl -sLo virtctl https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/virtctl-${KUBEVIRT_VERSION}-linux-amd64

sudo install -m 0775  virtctl /usr/local/bin/virtctl
rm -f virtctl

echo "StrictHostKeyChecking=no" > ${HOME}/.ssh/config
