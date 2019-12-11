#### Introduction on Containerized Data Importer

[CDI](https://github.com/kubevirt/containerized-data-importer) is a utility designed to import Virtual Machine images for use with Kubevirt.

At a high level, a PersistentVolumeClaim (PVC) is created. A custom controller watches for importer specific claims, and when discovered, starts an import process to create a raw image named *disk.img* with the desired content into the associated PVC.

#### Install the CDI

We will first explore each component and later we will install them. In this exercise we create a hostpath provisioner and storage class. Also, we will deploy the CDI component using the Operator.

Download the storage definition and examine it:
`wget https://raw.githubusercontent.com/kubevirt/kubevirt.github.io/master/labs/manifests/storage-setup.yml
kubectl create -f storage-setup.yml`{{execute}}

Grab latest version of CDI and apply both the Operator and the Custom Resource Definition (CR) that starts the deployment:

`export VERSION=$(curl -s https://github.com/kubevirt/containerized-data-importer/releases/latest | grep -o "v[0-9]\.[0-9]*\.[0-9]*")`{{execute}}

Deploy operator:

`kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-operator.yaml`{{execute}}

Create CRD to trigger operator deployment of CDI:
`kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-cr.yaml`{{execute}}

Review the "cdi" pods that were added.

`kubectl get pods -n cdi`{{execute}}

Some of the pods will report as being in 'Error' mode, do not worry about them and continue with the lab.

#### Use the CDI

As an example, we will import a Fedora30 Cloud Image as a PVC and launch a Virtual Machine making use of it.

`kubectl create -f https://raw.githubusercontent.com/kubevirt/kubevirt.github.io/master/labs/manifests/pvc_fedora.yml`{{execute}}

This will create the PVC with a proper annotation so that CDI controller detects it and launches an importer pod to gather the image specified in the *cdi.kubevirt.io/storage.import.endpoint* annotation.

Grab the pod name to check later the logs. If the pod is not yet listed, wait a bit more because the Operator is still doing required actions.

`kubectl get pod # Make note of the pod name assigned to the import process`{{execute}}

Then check the import process (it will be a long process and can take some time):

`kubectl logs -f $(kubectl get pods -o name)`{{execute}}

Notice that the importer downloaded the publicly available Fedora Cloud qcow image. Once the importer pod completes, this PVC is ready for use in KubeVirt.

If the importer pod completes in error, you may need to retry it or specify a different URL to the fedora cloud image. To retry, first delete the importer pod and the PVC, and then recreate the PVC.

Let's create a Virtual Machine making use of it. Review the file *vm1_pvc.yml*.

`wget https://raw.githubusercontent.com/kubevirt/kubevirt.github.io/master/labs/manifests/vm1_pvc.yml`{{execute}}

We change the YAML definition of this Virtual Machine to inject the default public key of user in the cloud instance.

First we'll create an SSH key pair that we'll use to configure the machine and patch the VM definition to use it:

`# Prepare SSH passwordless login
rm -fv ~/.ssh/id_rsa
ssh-keygen -N '' -f ~/.ssh/id_rsa
PUBKEY=$(cat ~/.ssh/id_rsa.pub)
sed -i "s%ssh-rsa.*%$PUBKEY%" vm1_pvc.yml`{{execute}}

Now, we'll create the VM with the patched YAML:

`kubectl create -f vm1_pvc.yml`{{execute}}

This will create and start a Virtual Machine named vm1. We can use the following command to check our Virtual Machine is running and to `gather its IP`. You are looking for the IP address beside the `virt-launcher` pod.

`kubectl get pod -o wide`{{execute}}

Wait for the Virtual Machine to boot and to be available for login. You may monitor its progress through the console. The speed at which the VM boots depends on whether baremetal hardware is used. It is much slower when nested virtualization is used, which is likely the case if you are completing this lab on an instance on a cloud provider.

From here, there's some playing around with the VM, wait until it has started (you can check the console to see the boot progress)

Finally, we will connect to vm1 Virtual Machine (VM) as a regular user would do, i.e. via ssh. This can be achieved by just ssh to the gathered IP.

Check the IP address:

```master $ kubectl get vmis
NAME      AGE       PHASE     IP           NODENAME
testvm    1m        Running   10.32.0.11   master```

Now, connect via SSH

```sh
ssh fedora@10.32.0.11
```

This concludes this section of the lab.
