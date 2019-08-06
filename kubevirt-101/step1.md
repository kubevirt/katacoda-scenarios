### Wait for the Kubernetes cluster to be ready

Before we can start, we need to wait for the Kubernetes cluster to be ready (command prompt will appear to accept commands).

#### Deploy KubeVirt

Deploy KubeVirt operator[^1] using latest KubeVirt version (we query GH api to get latest release available).

[^1] An Operator is a method of packaging, deploying and managing a Kubernetes application. A Kubernetes application is an application that is both deployed on Kubernetes and managed using the Kubernetes APIs and kubectl tooling. To be able to make the most of Kubernetes, you need a set of cohesive APIs to extend in order to service and manage your applications that run on Kubernetes. You can think of Operators as the runtime that manages this type of application on Kubernetes. If you want to learn more about Operators you can check the CoreOS Operators website: <https://coreos.com/operators/>

`export KUBEVIRT_VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | jq -r .tag_name)
echo $KUBEVIRT_VERSION`{{execute}}

`kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-operator.yaml`{{execute}}

We need to enable 'nested' virtualization in our demo environment. To do so, we need to run the following command to run the VM's using 'emulated' virtualization. (It is a requriment of the environment in Katacoda, we're running kubernetes inside Virtual Machines, so in order to execute a '2nd' layer of VM inside the VM we need to emulate it. In production, when using over baremetal this will not be required.)

`kubectl create configmap kubevirt-config -n kubevirt --from-literal debug.useEmulation=true`{{execute}}

Now let's deploy KubeVirt by creating a Custom Resource that will trigger the 'operator' reaction and perform the deployment:

`kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-cr.yaml`{{execute}}

Let's check the deployment:
`kubectl get pods -n kubevirt`{{execute}}

Once it's ready, it will show something similar to:

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

#### Install Virtctl

`virtctl` is a client utility to provide some more convenient ways to interact with the VM (start/stop/console, etc):

`wget -O virtctl https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/virtctl-${KUBEVIRT_VERSION}-linux-amd64`{{execute}}

`chmod +x virtctl`{{execute}}

Now everything is ready to continue and launch a VM.