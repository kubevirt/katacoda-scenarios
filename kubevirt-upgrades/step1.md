### Wait for the Kubernetes cluster to be ready
#### Deploy a VM

Once all the containers are with the status "Running" you can execute the command below for applying a YAML definition of a virtual machine into our current Kubernetes environment:

First, let's wait for all the pods to be ready like previously provided example:

`kubectl wait --for condition=ready pod -l kubevirt.io=virt-api -n kubevirt --timeout=100s
kubectl wait --for condition=ready pod -l kubevirt.io=virt-controller -n kubevirt --timeout=100s
kubectl wait --for condition=ready pod -l kubevirt.io=virt-handler -n kubevirt --timeout=100s`{{execute}}

And proceed with the VM creation:

`kubectl apply -f https://kubevirt.io/labs/manifests/vm.yaml`{{execute}}

Using the command below for checking that the VM is defined:

`kubectl get vms`{{execute}}

Notice from the output that the VM is not running yet.

To start a VM, `virtctl` should be used:
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
