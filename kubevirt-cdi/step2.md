# Use CDI to upload a VM image

As an example, we will import a CirrOS Cloud Image as a DV and launch a Virtual Machine making use of it.

```
kubectl create -f - <<EOF
apiVersion: cdi.kubevirt.io/v1beta1
kind: DataVolume
metadata:
  name: "cirros"
  annotations:
    cdi.kubevirt.io/storage.bind.immediate.requested: "true"
spec:
  source:
    http:
      url: "https://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img" # S3 or GCS
  pvc:
    accessModes:
    - ReadWriteOnce
    resources:
      requests:
        storage: "64Mi"
EOF
```{{execute}}

This will create the DV with a source that reads from a URL, and a destination PVC that is 64 MiB in size.

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
          - disk:
              bus: virtio
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
          userDataBase64: SGkuXG4=
        name: cloudinitdisk
EOF
kubectl create -f vm1.yml
```{{execute}}

This will create and start a Virtual Machine named vm1. We can use the following command to check our Virtual Machine is running and to gather its IP address. You are looking for the IP address beside the `virt-launcher` pod.

`kubectl get pod -o wide`{{execute}}

Wait for the Virtual Machine to boot and to be available for login.
Note that the speed at which the VM boots depends on the virtualization hardware and underlying storage speed.
Due to the nested virtualization employed in this scenario, it may take some time for the VM to fully boot.

Finally, we will connect to the `vm1` VM as a regular user would do, i.e. via ssh.

`virtctl ssh -l cirros vm1`{{execute}}

Use the default password of `gocubsgo`{{execute}} to log in.

Log out again, (type `exit`) and we will set up passwordless login to the VM. To work with ssh-copy-id, we will set up an ssh connection through the local client instead of through virtctl this time.

Check the IP address:

`kubectl get vmi`{{execute}}

```
NAME   AGE   PHASE     IP           NODENAME   READY
vm1    57s   Running   10.42.0.21   ubuntu     True
```

To make the following commands clickable, we save the IP into a variable:

```
IP=$(kubectl get vmi vm1 -o jsonpath='{.status.interfaces[0].ipAddress}')
```{{execute}}

The following command will require the default cirros password again.

```
ssh-copy-id -i ~/.ssh/id_rsa.pub cirros@${IP}
```{{execute}}

Log in once more to verify the password is no longer required.
This time, we will include the hostname command so we do not have to bother with exiting the shell once logged in.

```
ssh cirros@${IP} hostname
```{{execute}}

Now, to prove that configuration written to this VM is not ephemeral, we will shut down the VM and restart it.

```
virtctl stop vm1
```{{execute}}

Wait a moment, and verify the VM is stopped:

```
kubectl get vmi
```{{execute}}

```
No resources found in default namespace.
```{{}}

Start the VM back up

```
virtctl start vm1
```{{execute}}

Note the new IP address of the VM:

```
IP=$(kubectl get vmi vm1 -o jsonpath='{.status.interfaces[0].ipAddress}')
```{{execute}}

```
NAME   AGE   PHASE     IP           NODENAME   READY
vm1    13s   Running   10.42.0.22   ubuntu     True
```

```
ssh cirros@${IP} hostname
```{{execute}}

```
Warning: Permanently added '10.42.0.22' (ECDSA) to the list of known hosts.
vm1
```

You should now be logged into the VM without a password as before, demonstrating that the ssh key persisted through a stop/start.

This concludes this section of the lab.
