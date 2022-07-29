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
            user: cirros
            password: gocubsgo
            hostname: vm1
            ssh_pwauth: True
            disable_root: false
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

Check the IP address:

`kubectl get vmi`{{execute}}

```
NAME   AGE   PHASE     IP           NODENAME   READY
vm1    57s   Running   10.42.0.21   ubuntu     True
```

To make the following commands clickable, we save the IP into a variable:

`IP=$(kubectl get vmi testvm -o jsonpath='{.status.interfaces[0].ipAddress}')`{{execute}}

Now, connect via SSH

`ssh cirros@${IP}`{{execute}}

Use the default password of `gocubsgo` to log in.

Log out again, (type `exit`) and we will set up passwordless login to the VM. The following command will require the default cirros password again.

`ssh-copy-id -i ~/.ssh/id_rsa.pub cirros@${IP}`{{execute}}

Log in once more to verify the password is no longer required.

`ssh cirros@${IP}`{{execute}}

Now, to prove that configuration written to this VM is not ephemeral, we will shut down the VM and restart it.

`virtctl stop vm1`{{execute}}

Wait a moment, and verify the VM is stopped:

`kubectl get vmi`{{execute}}

`No resources found in default namespace.`{{}}

Start the VM back up

`virtctl start vm1`{{execute}}

Note the new IP address of the VM:

`IP=$(kubectl get vmi testvm -o jsonpath='{.status.interfaces[0].ipAddress}')`{{execute}}


```
NAME   AGE   PHASE     IP           NODENAME   READY
vm1    13s   Running   10.42.0.22   ubuntu     True
```

`ssh cirros@${IP}`{{execute}}

```
Warning: Permanently added '10.42.0.22' (ECDSA) to the list of known hosts.
$ 
```{{}}

You should now be logged into the VM without a password as before, demonstrating that the ssh key persisted through a stop/start.

This concludes this section of the lab.
