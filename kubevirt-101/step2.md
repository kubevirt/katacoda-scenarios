#### Deploy a VM

Start off by creating a virtual machine:

`kubectl apply -f https://raw.githubusercontent.com/kubevirt/demo/master/manifests/vm.yaml`{{execute}}

The command above applies a yaml definition of a virtual machine into our current Kubernetes environment, defining the vm name, the resources required (disk, cpu, memory), etc. You can take a look to the vm.yaml file if you have interest in knowing more about a virtual machine definition.

We are creating a Virtual Machine in the same way as we would create any other Kubernetes resource thanks to what KubeVirt has enabled in our environment. Now we have got a Virtual Machine as a Kubernetes resource.

After the vm resource has been created, you can manage the VMs with standard 'kubectl' commands:

```
$ kubectl get vms
$ kubectl get vms -o yaml testvm
```

Check VM's defined (using commands above)
`kubectl get vms`{{execute}}

To start a VM, virtctl should be used:

`./virtctl start testvm`{{execute}}

Alternatively you can use `kubectl edit vm testvm` to set `.spec.running: true`.

Once the VM is running you can inspect its status as [instance](https://kubevirt.io/user-guide/docs/latest/creating-virtual-machines/intro.html) :

```
$ kubectl get vmis
$ kubectl get vmis -o yaml testvm
```

`kubectl get vmis`{{execute}}

Once it's ready, the command above will print something like:

~~~
master $ kubectl get vmis
NAME      AGE       PHASE     IP           NODENAME
testvm    1m        Running   10.32.0.11   master
~~~

#### Accessing VMs (serial console & vnc)

Now that a VM is running you can access its console:

**NOTE** : YOU WILL NOT BE ABLE TO ESCAPE THE CONSOLE ON KATACODA.

`^]` means: press CTRL + "]" keys to escape the console

~~~sh
# Connect to the serial console
$ ./virtctl console testvm
~~~

If you've opened the console **within** Katacoda, you can click on the `+` close to 'Terminal' to start a new shell there and be able to continue with the following steps in the shutdown and cleanup section.

**NOTE** This doesn't work on Katacoda because of the environment setup and browser access

`./virtctl console testvm`

~~~sh
# Connect to the graphical display
# It Requires remote-viewer from the virt-viewer package.
$ ./virtctl vnc testvm
~~~

#### Shutdown and cleanup

Shutting down a VM works by either using `virtctl` or editing the VM.

`./virtctl stop testvm`{{execute}}

Finally, the VM can be deleted using:

`kubectl delete vms testvm`{{execute}}