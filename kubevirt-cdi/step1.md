# Wait for KubeVirt to deploy

The setup for this scenario includes installation of KubeVirt and the `virtctl` utility.

Before we can start, we need to wait for the KubeVirt initialization script to run. (a command prompt will appear once everything is ready).

# Introduction to Containerized Data Importer

[CDI](https://github.com/kubevirt/containerized-data-importer) is a utility designed to import Virtual Machine images for use with Kubevirt.

At a high level, a PersistentVolumeClaim (PVC) is created. A custom controller watches for importer specific claims, and when discovered, starts an import process to create a raw image named *disk.img* with the desired content into the associated PVC.

We will first explore each component and later we will install them. In this exercise we create a hostpath provisioner and storage class. Also, we will deploy the CDI component using the Operator.

# Install Hostpath Provisioner

Download the hostpath-provisioner deployment YAML and apply it.

`wget https://raw.githubusercontent.com/kubevirt/hostpath-provisioner/main/deploy/kubevirt-hostpath-provisioner.yaml
kubectl create -f kubevirt-hostpath-provisioner.yaml
kubectl annotate storageclass kubevirt-hostpath-provisioner storageclass.kubernetes.io/is-default-class=true`{{execute}}

Verify you now have a default storage class. You should see "kubevirt-hostpath-provisioner (default)"

`kubectl get storageclass`{{execute}}

# Install the CDI

Grab latest version of CDI and apply both the Operator and the Custom Resource Definition (CR) that starts the deployment:

`export VERSION=$(curl -s https://github.com/kubevirt/containerized-data-importer/releases/latest | grep -o "v[0-9]\.[0-9]*\.[0-9]*")`{{execute}}

Deploy operator:

`kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-operator.yaml`{{execute}}

Create CRD to trigger operator deployment of CDI:

`kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-cr.yaml`{{execute}}

Check status of CDI deployment. You may repeat this command as needed until the cdi "PHASE" reads "Deployed"

`kubectl get cdi -n cdi`{{execute}}

Review the "cdi" pods that were added.

`kubectl get pods -n cdi`{{execute}}