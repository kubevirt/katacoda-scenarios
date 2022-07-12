# Deploy a Virtual Machine

The command below applies a YAML definition of a virtual machine into the current Kubernetes environment, defining the VM name, the resources required (disk, CPU, memory), etc. You can take a look at the [vm.yaml](https://kubevirt.io/labs/manifests/vm.yaml) file if you have interest in knowing more about a virtual machine definition:

`kubectl apply -f https://kubevirt.io/labs/manifests/vm.yaml`{{execute}}

We are creating a Virtual Machine in the same way as we would create any other Kubernetes resource thanks to the KubeVirt operator in our environment. Now we have a Virtual Machine as a Kubernetes resource.

After the vm resource has been created, you can manage the VMs with standard 'kubectl' commands:

`kubectl get vms`{{execute}}

`kubectl get vms -o yaml testvm | grep -E 'running:.*|$'`{{execute}}

Notice from the output that the VM is not running yet.

To start a VM, use _virtctl_ with the _start_ verb:

`./virtctl start testvm`{{execute}}

Again, check the VM status:

`kubectl get vms`{{execute}}

A _VirtualMachine_ resource contains a VM's definition and status. An [instance](https://kubevirt.io/user-guide/virtual_machines/virtual_machine_instances/) of a running VM has an additional associated resource, a _VirtualMachineInstance_.

Once the VM is running you can inspect its status:

`kubectl get vmis`{{execute}}

Once it is ready, the command above will print something like:

```
NAME      AGE       PHASE     IP           NODENAME
testvm    1m        Running   10.32.0.11   controlplane
```

# Access a VM (serial console & vnc)

Now that the VM is running you can access its serial console:

**WARNING:** in some OS and browser environments you may not be able to escape the serial console in this course.

**NOTE:** _^]_ means: press the "CTRL" and "]" keys to escape the console.

`./virtctl console testvm`{{execute}}

If you opened the serial console within the Killercoda course environment and you can't escape from it by pressing _^]_, you can click on the _+_ at the top of the terminal window to start a new shell. You should be able to continue with the following steps in the shutdown and cleanup section.

In environments where VNC client access is available, the graphical console of a VM can be accessed with the [virtctl vnc](https://kubevirt.io/user-guide/virtual_machines/graphical_and_console_access/#accessing-the-graphical-console-vnc) command.

# Shutdown and cleanup

As with starting, stopping a VM also may be accomplished with the _virtctl_ command:

`./virtctl stop testvm`{{execute}}

Finally, the VM can be deleted as any other Kubernetes resource using _kubectl_:

`kubectl delete vms testvm`{{execute}}
