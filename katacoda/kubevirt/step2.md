#### Deploy a VM

Start of by creating a virtual machine:

`kubectl apply -f https://raw.githubusercontent.com/kubevirt/demo/master/manifests/vm.yaml`{{execute}}

After it has been created you can manage VMs using the usual verbs:

```
$ kubectl get vms
$ kubectl get vms -o yaml testvm
```

Check VM's defined (using above commands)
`kubectl get vms`{{execute}}

To start a VM, virtctl can be used:

`./virtctl start testvm`{{execute}}

Alternatively you can use `kubectl edit vm testvm` to set `.spec.running: true`.

Once the VM is running you can inspect it's instance:

```
$ kubectl get vmis
$ kubectl get vmis -o yaml testvm
```

`kubectl get vmis`{{execute}}

Once it's ready, above comand will print something like:

~~~
master $ kubectl get vmis
NAME      AGE       PHASE     IP           NODENAME
testvm    1m        Running   10.32.0.11   master
~~~

#### Accessing VMs (serial console & vnc)

Now that a VM is running you can access it's console:
```
# Connect to the serial console
# NOTE: YOU WILL NOT BE ABLE TO ESCAPE THE CONSOLE ON KATACODA
$ ./virtctl console testvm
```

See above **NOTE** before executing:

`./virtctl console testvm`{{execute}}

```
# Connect to the graphical display
# It Requires remote-viewer from the virt-viewer package.
# This obviously does not work on katacoda
$ ./virtctl vnc testvm
```

If you've opened the console, you can click on the "+" close to 'Terminal' to start a new shell there and be able to continue with the following steps.

#### Shutdown and cleanup

Shutting down a VM works by either using `virtctl` or editing the VM.

`./virtctl stop testvm`{{execute}}

Finally, the VM can be deleted using:

`kubectl delete vms testvm`{{execute}}
