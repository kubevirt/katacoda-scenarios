# Introduction to Containerized Data Importer

[CDI](https://github.com/kubevirt/containerized-data-importer) is a utility designed to import Virtual Machine images for use with Kubevirt.

At a high level, a PersistentVolumeClaim (PVC) is created. A custom controller watches for importer specific claims, and when discovered, starts an import process to create a raw image named _disk.img_ with the desired content into the associated PVC.

In this exercise we create a Hostpath provisioner and storage class. Then we deploy the CDI component using its operator. Finally, we import a Fedora cloud image and use it to start a Fedora VM.

# Wait for KubeVirt to deploy

The setup for this scenario includes installation of KubeVirt and the `virtctl` utility.

Before we can start, we need to wait for the KubeVirt initialization script to run. (a command prompt will appear once everything is ready).

# Install Hostpath Provisioner

Before we can install CDI, we have some prerequisites, namely a supported storage class and provisioner. For this example, we use the Hostpath provisioner which provisions PVCs using node local storage. This is an option for proof of concept exercises like this one, but should not be used in production because it does not support RWX nor accessing a volume across nodes.

The Hostpath provisioner operator requires [cert-manager](https://github.com/cert-manager/cert-manager) in order to create TLS certificates. Apply the certr- manager manifests:

```
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.8.2/cert-manager.yaml
```{{execute}}

Wait for the cert-manager pods to come up to the _running_ state:

```
kubectl -n cert-manager wait --for=condition=Available deployment/cert-manager
kubectl -n cert-manager wait --for=condition=Available deployment/cert-manager-webhook
```{{execute}}

Apply the Hostpath provisioner manifests:

```
kubectl apply -f https://raw.githubusercontent.com/kubevirt/hostpath-provisioner-operator/main/deploy/namespace.yaml

kubectl apply -f https://raw.githubusercontent.com/kubevirt/hostpath-provisioner-operator/main/deploy/webhook.yaml

kubectl -n hostpath-provisioner apply -f https://raw.githubusercontent.com/kubevirt/hostpath-provisioner-operator/main/deploy/operator.yaml
```{{execute}}

Once these manifests have had a moment to deploy their Custom Resource Definitions (CRDs), apply the Custom Resource (CR) that instantiates the Hostpath provisioner operator along with its "wait for first consumer" storage class:

```
kubectl -n hostpath-provisioner apply -f https://github.com/kubevirt/hostpath-provisioner-operator/raw/main/deploy/hostpathprovisioner_cr.yaml
kubectl apply -f https://github.com/kubevirt/hostpath-provisioner-operator/raw/main/deploy/storageclass-wffc-csi.yaml
```{{execute}}

Now annotate the resulting storage class to set it as the default for provisioning PVCs in the cluster:

`kubectl annotate sc hostpath-csi storageclass.kubernetes.io/is-default-class=true`{{execute}}

`kubectl get storageclass`{{execute}}

Before we continue, we need to make sure the Hostpath Provisioner has completely deployed:

```
 kubectl -n hostpath-provisioner wait hostpathprovisioner/hostpath-provisioner --for=condition=Available
 ```{{execute}}

# Install the CDI

Next we determine the latest version of CDI and apply both the Operator and the CR that starts the deployment:



```
export VERSION=$(curl -Ls https://github.com/kubevirt/containerized-data-importer/releases/latest | grep -m 1 -o "v[0-9]\.[0-9]*\.[0-9]*")
echo $VERSION
```{{execute}}

Deploy operator:

`kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-operator.yaml`{{execute}}

Create CRD to trigger operator deployment of CDI:

`kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-cr.yaml`{{execute}}

Check status of CDI deployment. It may take some time before the cdi "PHASE" reads "Deployed"

`kubectl get cdi -n cdi`{{execute}}

To have _kubectl_ do the checking for you and let you know when the operator finishes its deployment, use the _wait_ command:

`kubectl wait -n cdi --for=jsonpath='{.status.phase}'=Deployed cdi/cdi`{{execute}}

Review the "cdi" pods that were added.

`kubectl -n cdi get pods`{{execute}}