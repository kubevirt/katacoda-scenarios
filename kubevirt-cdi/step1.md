# Introduction to Containerized Data Importer

[CDI](https://github.com/kubevirt/containerized-data-importer) is a utility designed to import Virtual Machine images for use with Kubevirt.

At a high level, a PersistentVolumeClaim (PVC) is created. A custom controller watches for importer specific claims, and when discovered, starts an import process to create a raw image named _disk.img_ with the desired content into the associated PVC.

In this exercise we start by deploying the CDI operator. Then, we import a [CirrOS](https://github.com/cirros-dev/cirros) disk image and use it to start a VM.

# Wait for KubeVirt to deploy

The setup for this scenario includes installation of KubeVirt and the `virtctl` utility.

Before we can start, we need to wait for the KubeVirt initialization script to run. (a command prompt will appear once everything is ready).

# Check Default Storage Class

Before we can install CDI, we have some prerequisites, namely a supported storage class and provisioner. For this example, we make use of the `local-path` _StorageClass_ provided by _k3s_ which provisions PVCs using node local storage. This is an option for proof of concept exercises like this one, but should not be used in production because it does not support accessing a volume across nodes.

`kubectl get storageclass`{{execute}}

# Install the Containerized Data Importer

Next we determine the latest version of CDI and apply both the Operator and the CR that starts the deployment:

```
export VERSION=$(curl -Ls https://github.com/kubevirt/containerized-data-importer/releases/latest | grep -m 1 -o "v[0-9]\.[0-9]*\.[0-9]*")
echo $VERSION
```{{execute}}

Deploy the operator (and scale its replicas down to one due to the resource limitations of the environment):

```
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-operator.yaml
kubectl -n cdi scale deployment/cdi-operator --replicas=1
```{{execute}}

Create CRD to trigger operator deployment of CDI:

`kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-cr.yaml`{{execute}}

Check status of CDI deployment. It may take some time before the cdi "PHASE" reads "Deployed"

`kubectl get cdi -n cdi`{{execute}}

To have _kubectl_ do the checking for you and let you know when the operator finishes its deployment, use the _wait_ command:

`kubectl wait -n cdi --for=jsonpath='{.status.phase}'=Deployed cdi/cdi`{{execute}}

At times, the environment this scenario runs in may be under heavy load; if the above command errors out, wait a moment and re-run.

Review the "cdi" pods that were added.

`kubectl -n cdi get pods`{{execute}}