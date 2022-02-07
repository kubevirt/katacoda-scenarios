launch.sh

# May need both nodes
kubectl taint node controlplane node-role.kubernetes.io/master:NoSchedule-

# Install Argo-CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install command line tools
## ArgoCD argocd
export ARGOCD_VERSION=$(curl -s https://api.github.com/repos/argoproj/argo-cd/releases/latest | jq -r .tag_name)
wget -O argocd https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64
sudo install -m 0755 argocd /usr/local/bin/argocd
rm -f argocd

## Kubevirt virtctl
export KUBEVIRT_VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | jq -r .tag_name)
wget -O virtctl https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/virtctl-${KUBEVIRT_VERSION}-linux-amd64

sudo install -m 0755  virtctl /usr/local/bin/virtctl
rm -f virtctl

# Wait for argo to come up
ARGO_POD=$(kubectl -n argocd get po -l 'app.kubernetes.io/name=argocd-server' -o name)
kubectl wait --for=condition=Ready ${ARGO_POD} --timeout=300s

# Patch argo server to present nodeport to API
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

ARGO_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)
ARGO_PORT=$(kubectl -n argocd get svc argocd-server -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')

argocd login localhost:${ARGO_PORT} --username admin --password ${ARGO_PASS} --insecure
