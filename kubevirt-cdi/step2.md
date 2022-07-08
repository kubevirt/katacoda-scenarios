# Use CDI to upload a VM image

As an example, we will import a Fedora34 Cloud Image as a PVC and launch a Virtual Machine making use of it.

```
cat <<EOF > pvc_fedora.yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: "fedora"
  labels:
    app: containerized-data-importer
  annotations:
    cdi.kubevirt.io/storage.import.endpoint: "https://mirror.23media.com/fedora/linux/releases/34/Cloud/x86_64/images/Fedora-Cloud-Base-34-1.2.x86_64.raw.xz"
    kubevirt.io/provisionOnNode: node01
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5500Mi
EOF
kubectl create -f pvc_fedora.yml
```{{execute}}

This will create the PVC with a proper annotation so that CDI controller detects it and launches an importer pod to gather the image specified in the *cdi.kubevirt.io/storage.import.endpoint* annotation.

Grab the pod name to check later the logs. If the pod is not yet listed, wait a bit more because the Operator is still doing required actions.

`kubectl get pod`{{execute}}

Then check the import process (it will be a long process and can take some time):

`kubectl logs -f $(kubectl get pods -o name)`{{execute}}

Notice that the importer downloaded the publicly available Fedora Cloud qcow image. Once the importer pod completes, this PVC is ready for use in KubeVirt.

If the importer pod completes in error, you may need to retry it or specify a different URL to the fedora cloud image. To retry, first delete the importer pod and the PVC, and then recreate the PVC.

Let's create a virtual machine that makes use of our new PVC. Review the file *vm1_pvc.yml*.

`wget https://kubevirt.io/labs/manifests/vm1_pvc.yml`{{execute}}

We change the YAML definition of this Virtual Machine to inject the default public key of user in the cloud instance. This scenario provides an environment with an ssh key already set up, so we will use the public key we find in the authorized_keys file.

`
PUBKEY=$(cat ~/.ssh/authorized_keys)
sed -i "s%ssh-rsa YOUR_SSH_PUB_KEY_HERE%$PUBKEY%" vm1_pvc.yml`{{execute}}

Now, we'll create the VM with the patched YAML:

`kubectl create -f vm1_pvc.yml`{{execute}}

This will create and start a Virtual Machine named vm1. We can use the following command to check our Virtual Machine is running and to `gather its IP`. You are looking for the IP address beside the `virt-launcher` pod.

`kubectl get pod -o wide`{{execute}}

Wait for the Virtual Machine to boot and to be available for login. You may monitor its progress through the console. The speed at which the VM boots depends on whether baremetal hardware is used. It is much slower when nested virtualization is used, which is likely the case if you are completing this lab on an instance on a cloud provider.

From here, there's some playing around with the VM, wait until it has started (you can check the console to see the boot progress)

Finally, we will connect to vm1 Virtual Machine (VM) as a regular user would do, i.e. via ssh. This can be achieved by just ssh to the gathered IP.

Check the IP address:

```controlplane $ kubectl get vmis
NAME      AGE       PHASE     IP           NODENAME
testvm    1m        Running   10.32.0.11   controlplane```

Now, connect via SSH

```sh
ssh fedora@10.32.0.11
```

This concludes this section of the lab.
