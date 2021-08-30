launch.sh

# Need schedulable for migration
kubectl taint node controlplane node-role.kubernetes.io/master:NoSchedule-

export KUBEVIRT_VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | jq -r .tag_name)
echo Installing Kubevirt $KUBEVIRT_VERSION

kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-operator.yaml

kubectl create configmap kubevirt-config -n kubevirt \
    --from-literal debug.useEmulation=true \
    --from-literal feature-gates=LiveMigration

kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-cr.yaml

wget -O virtctl https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/virtctl-${KUBEVIRT_VERSION}-linux-amd64

sudo install -m 0755  virtctl /usr/local/bin/virtctl
rm -f virtctl

tries=10
output=$(kubectl -n kubevirt get kubevirt kubevirt -o jsonpath='{.status.phase}')
while [ $tries -gt 0 ] && [ "$output" != "Deployed" ]
do
    echo KubeVirt in ${output:-Uninitialized} phase.
    sleep $(( tries * 3 ))
    let tries--
    output=$(kubectl -n kubevirt get kubevirt kubevirt -o jsonpath='{.status.phase}')
done

kubectl -n kubevirt get kubevirt kubevirt
