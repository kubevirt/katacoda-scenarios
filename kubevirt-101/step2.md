#### Deploy a VM

The command below applies a YAML definition of a virtual machine into our current Kubernetes environment, defining the VM name, the resources required (disk, CPU, memory), etc. You can take a look at the [vm.yaml](https://kubevirt.io/labs/manifests/vm.yaml) file if you have interest in knowing more about a virtual machine definition:

`kubectl apply -f https://kubevirt.io/labs/manifests/vm.yaml`{{execute}}

We are creating a Virtual Machine in the same way as we would create any other Kubernetes resource thanks to what KubeVirt has enabled in our environment. Now we have a Virtual Machine as a Kubernetes resource.

After the vm resource has been created, you can manage the VMs with standard 'kubectl' commands:

```
$ kubectl get vms
$ kubectl get vms -o yaml testvm
```

Check that the VM is defined (using commands above):

`kubectl get vms`{{execute}}

Notice from the output that the VM is not running yet.

To start a VM, `virtctl` should be used:

`./virtctl start testvm`{{execute}}

Alternatively you can use `kubectl edit vm testvm` to set `.spec.running: true`.

Now you can check again the VM status:

`kubectl get vms`{{execute}}

A `VirtualMachine` resource contains a VM's definition and status. An [instance](https://kubevirt.io/user-guide/virtual_machines/virtual_machine_instances/) of a running VM has an additional associated resource, a `VirtualMachineInstance`.

Once the VM is running you can inspect its status:

```
$ kubectl get vmis
$ kubectl get vmis -o yaml testvm
```

`kubectl get vmis`{{execute}}

Once it's ready, the command above will print something like:

~~~
controlplane $ kubectl get vmis
NAME      AGE       PHASE     IP           NODENAME
testvm    1m        Running   10.32.0.11   controlplane
~~~

#### Accessing VMs (serial console & vnc)

Now that a VM is running you can access its serial console:

**WARNING:** in some browser environments you will not be able to escape the serial console on Katacoda.

**NOTE:** `^]` means: press the "CTRL" and "]" keys to escape the console.

~~~sh
# Connect to the serial console
$ ./virtctl console testvm
~~~

If you opened the serial console within Katacoda and you can't escape from it by pressing `^]`, you can click on the `+` close to 'Terminal' to start a new shell there and be able to continue with the following steps in the shutdown and cleanup section.

In environments where VNC client access is available, the graphical console of a VM can be accessed with the [virtctl vnc](https://kubevirt.io/user-guide/virtual_machines/graphical_and_console_access/#accessing-the-graphical-console-vnc) command.

#### Shutdown and cleanup

Shutting down a VM works by either using `virtctl` or editing the VM.

`./virtctl stop testvm`{{execute}}

Finally, the VM can be deleted using:

`kubectl delete vms testvm`{{execute}}
