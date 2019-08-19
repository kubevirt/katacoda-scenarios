### Wait for the Kubernetes cluster to be ready

Before we can start, we need to wait for the Kubernetes cluster to be ready (a command prompt will appear once it's ready).

Please ensure you're familiar with KubeVirt basics in [First steps with KubeVirt](https://katacoda.com/kubevirt/scenarios/kubevirt-101) scenario before proceeding.

#### Deploy KubeVirt

Deploy the KubeVirt operator using a specific KubeVirt version, so that we can later proceed to upgrade to latest.

Let's force ourselves to use release `v0.17.0`:

`export KUBEVIRT_VERSION=v0.17.0`{{execute}}

Run the following command to deploy the KubeVirt Operator:

`kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-operator.yaml`{{execute}}

This demo environment already runs within a virtualized environment, and in order to be able to run VMs here we need to pre-configure KubeVirt so it uses software-emulated virtualization instead of trying to use real hardware virtualization.

`kubectl create configmap kubevirt-config -n kubevirt --from-literal debug.useEmulation=true`{{execute}}

Now let's deploy KubeVirt by creating a Custom Resource that will trigger the 'operator' reaction and perform the deployment:

`kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-cr.yaml`{{execute}}

Let's check the deployment:
`kubectl get pods -n kubevirt`{{execute}}

Once it's ready, it will show something similar to (this will keep showing in upper half of your terminal at katacoda):

~~~
master $ kubectl get pods -n kubevirt
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

The command below applies a YAML definition of a virtual machine into our current Kubernetes environment:

`kubectl apply -f https://raw.githubusercontent.com/kubevirt/demo/master/manifests/vm.yaml`{{execute}}

Check that the VM is defined (using commands above):

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
master $ kubectl get vmis
NAME      AGE       PHASE     IP           NODENAME
testvm    1m        Running   10.32.0.11   master
~~~

Now, we're ready for upgrading KubeVirt