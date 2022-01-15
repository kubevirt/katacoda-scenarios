### Use ArgoCD to deploy KubeVirt

First, create the kubevirt application within ArgoCD by pointing to the repository, path, namespace, and local server URI:

`argocd app create kubevirt --repo https://github.com/cwilkers/kubevirt-gitops.git --path kubevirt --dest-namespace kubevirt --dest-server https://kubernetes.default.svc`{{execute create-kubevirt}}

`argocd app sync kubevirt`{{execute sync-kubevirt}}

`argocd app list`{{execute app-list}}

### Use ArgoCD to deploy kubevirt hostpath provisioner and CDI

Create a hostpath-provisioner using the following commands:

`argocd app create hostpath --repo https://github.com/cwilkers/kubevirt-gitops.git --path hpp --dest-namespace kubevirt-hostpath-provisioner --dest-server https://kubernetes.default.svc`{{execute create-hostpath}}

`argocd app sync hostpath`{{execute sync-hostpath}}

Create and sync the CDI application:

`argocd app create cdi --repo https://github.com/cwilkers/kubevirt-gitops.git --path cdi --dest-namespace cdi --dest-server https://kubernetes.default.svc`{{execute}}

`argocd app sync cdi`{{execute sync-cdi}}
