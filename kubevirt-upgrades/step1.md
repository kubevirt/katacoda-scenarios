### Wait for the Kubernetes cluster to be ready

Notice from the output that the VM is not running yet.

To start a VM, `virtctl` should be used:

`./virtctl start testvm`{{execute}}

Now you can check again the VM status:

`kubectl get vms`{{execute}}

Once the VM is running you can inspect its status:

`kubectl get vmis`{{execute}}

Once it's ready, the command above will print something like:

~~~
controlplane $ kubectl get vmis
NAME      AGE       PHASE     IP           NODENAME
testvm    1m        Running   10.32.0.11   controlplane
~~~

While the PHASE is still `Scheduling` you can run the same commnad for checking again:

`kubectl get vmis`{{execute}}

Once the PHASE will change to `Running`,we're ready for upgrading KubeVirt.
