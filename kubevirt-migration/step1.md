### Wait for KubeVirt to deploy

The setup for this scenario includes installation of KubeVirt and the `virtctl` utility.

Before we can start, we need to wait for the Kubernetes cluster and KubeVirt
initialization script to run. (a command prompt will appear once everything is
ready).

#### Check the kubevirt-config

When KubeVirt finishes deploying, list out the KubeVirt Custom Resource "kubevirt" in
the "kubevirt" namespace.

In addition to emulated virtualization (a requirement in this environment), a
feature gate has also been added to make live migration possible.

`kubectl -n kubevirt get kubevirt kubevirt -o yaml`{{execute}}

### Launch the test VM

This scenario will use the same VirtualMachine YAML definition from the first
lab. Run the following code to create the VM.

`kubectl apply -f https://kubevirt.io/labs/manifests/vm.yaml`{{execute}}

Run the following to start the VM.

`virtctl start testvm`{{execute}}

The testvm virtual machine should start running on node01. Check which node the VM is on with:

`kubectl get vmi`{{execute}}

Once the VM reaches the Running phase, you should see something like:

~~~sh
NAME     AGE   PHASE     IP           NODENAME
testvm   17s   Running   10.244.1.7   node01
~~~

For more detailed information, you can use directly view the virt-launcher Pod(s) with:

`kubectl get pods -o wide`{{execute}}

~~~sh
NAME                         READY   STATUS    RESTARTS   AGE   IP           NODE     NOMINATED NODE   READINESS GATES
virt-launcher-testvm-676tr   2/2     Running   0          80s   10.244.1.7   node01   <none>           <none>
~~~

Make note of the VM's node, and move ahead to the next step.
