# Use CDI to upload a VM image

As an example, we will import a CirrOS Cloud Image as a PVC and launch a Virtual Machine making use of it.

```
cat <<EOF > pvc_cirros.yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: "cirros"
  labels:
    app: containerized-data-importer
  annotations:
    cdi.kubevirt.io/storage.import.endpoint: "http://download.cirros-cloud.net/0.5.2/cirros-0.5.2-x86_64-disk.img"
    kubevirt.io/provisionOnNode: node01
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 120Mi
EOF
kubectl create -f pvc_cirros.yml
```{{execute}}

This will create the PVC with a proper annotation so that the CDI controller detects it and launches an importer pod to gather the image specified in the *cdi.kubevirt.io/storage.import.endpoint* annotation.

Grab the pod name to check later the logs. If the pod is not yet listed, wait a bit more because the operator is still doing required actions.

`kubectl get pod`{{execute}}

Then check the import process:

`kubectl logs importer-cirros -f`{{execute}}

Notice that the importer downloads the publicly available CirrOS qcow image. Once the importer pod completes, this PVC is ready for use in KubeVirt.

Let's create a virtual machine that makes use of our new PVC.

```
cat <<EOF > vm1.yml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  creationTimestamp: 2018-07-04T15:03:08Z
  generation: 1
  labels:
    kubevirt.io/os: linux
  name: vm1
spec:
  running: true
  template:
    metadata:
      creationTimestamp: null
      labels:
        kubevirt.io/domain: vm1
    spec:
      domain:
        cpu:
          cores: 1
        devices:
          disks:
          - disk:
              bus: virtio
            name: disk0
          - cdrom:
              bus: sata
              readonly: true
            name: cloudinitdisk
        resources:
          requests:
            memory: 128M
      volumes:
      - name: disk0
        persistentVolumeClaim:
          claimName: cirros
      - cloudInitNoCloud:
          userData: |
            #cloud-config
            hostname: vm1
            ssh_pwauth: True
            disable_root: false
            ssh_authorized_keys:
            - ssh-rsa YOUR_SSH_PUB_KEY_HERE
        name: cloudinitdisk
```{{execute}}

We change the YAML definition of this Virtual Machine to inject the default public key of user in the cloud instance. This scenario provides an environment with an ssh key already set up, so we will use the public key we find in the authorized_keys file.

```
PUBKEY=$(cat ~/.ssh/id_rsa.pub)
sed -i "s%ssh-rsa YOUR_SSH_PUB_KEY_HERE%${PUBKEY}%" vm1.yml
```{{execute}}

Now, we'll create the VM with the patched YAML:

`kubectl create -f vm1.yml`{{execute}}

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
ssh cirros@10.32.0.11
```

This concludes this section of the lab.
