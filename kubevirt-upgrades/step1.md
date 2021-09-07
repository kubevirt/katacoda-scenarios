### Wait for the Kubernetes cluster to be ready

Before we can start, we need to wait for the Kubernetes cluster to be ready (a command prompt will appear once it's ready).

Please ensure you're familiar with KubeVirt basics in [First steps with KubeVirt](https://katacoda.com/kubevirt/scenarios/kubevirt-101) scenario before proceeding.

Wait until you see the command prompt to continue.

#### Deploy KubeVirt

For upgrading to the latest KubeVirt version, first we will install a specific older version of the operator.

Let's stick to use the release `v0.17.0`:

`export KUBEVIRT_VERSION=v0.17.0`{{execute}}

Similar to <https://katacoda.com/kubevirt/scenarios/kubevirt-101> we're going to follow the same steps:

To deploy the KubeVirt Operator run the following command:

`kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-operator.yaml`{{execute}}

Let's wait for the operator to become ready:
`kubectl wait --for condition=ready pod -l kubevirt.io=virt-operator -n kubevirt --timeout=100s`{{execute}}

Now let's deploy KubeVirt by creating a Custom Resource that will trigger the 'operator' and perform the deployment:

`kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-cr.yaml`{{execute}}

Next, we need to configure KubeVirt to use software emulation for virtualization. This is necessary for the Katacoda environment, but results in poor performance, so avoid this step in production environments.

`kubectl -n kubevirt patch kubevirt kubevirt --type=merge --patch '{"spec":{"configuration":{"developerConfiguration":{"useEmulation":true}}}}'`{{execute}}

Let's check the deployment:
`kubectl get pods -n kubevirt`{{execute}}

Once it's ready, it will show something similar to the information below (this will keep showing in the upper half of the terminal in the right side of the webpage):

~~~
controlplane $ kubectl get pods -n kubevirt
NAME                               READY     STATUS    RESTARTS   AGE
virt-api-7fc57db6dd-g4s4w          1/1       Running   0          3m
virt-api-7fc57db6dd-zd95q          1/1       Running   0          3m
virt-controller-6849d45bcc-88zd4   1/1       Running   0          3m
virt-controller-6849d45bcc-cmfzk   1/1       Running   0          3m
virt-handler-fvsqw                 1/1       Running   0          3m
virt-operator-5649f67475-gmphg     1/1       Running   0          4m
virt-operator-5649f67475-sw78k     1/1       Running   0          4m
~~~

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
