### Wait for the Kubernetes cluster to be ready

Before we can start, we need to wait for the Kubernetes cluster to be ready (a command prompt will appear once it's ready).

#### Deploy KubeVirt

Deploy the KubeVirt operator[^1] using the latest KubeVirt version.

[^1] An Operator is a method of packaging, deploying and managing a Kubernetes application. A Kubernetes application is an application that is both deployed on Kubernetes and managed using the Kubernetes APIs and kubectl tooling. You can think of Operators as the runtime that manages this type of application on Kubernetes. If you want to learn more about Operators you can check the CoreOS Operators website: <https://coreos.com/operators/>

We query GitHub's API to get the latest available release (click on the text to autoexecute the commands on the console):

`export KUBEVIRT_VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | jq -r .tag_name)
echo $KUBEVIRT_VERSION`{{execute}}

Run the following command to deploy the KubeVirt Operator:

`kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-operator.yaml`{{execute}}

This demo environment already runs within a virtualized environment, and in order to be able to run VMs here we need to pre-configure KubeVirt so it uses software-emulated virtualization instead of trying to use real hardware virtualization.

`kubectl create configmap kubevirt-config -n kubevirt --from-literal debug.useEmulation=true`{{execute}}

Now let's deploy KubeVirt by creating a Custom Resource that will trigger the 'operator' reaction and perform the deployment:

`kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-cr.yaml`{{execute}}

Let's check the deployment:
`kubectl get pods -n kubevirt`{{execute}}

Once it's ready, it will show something similar to:

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

#### Install Virtctl

`virtctl` is a client utility that helps interact with VM's (start/stop/console, etc):

`wget -O virtctl https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/virtctl-${KUBEVIRT_VERSION}-linux-amd64`{{execute}}

`chmod +x virtctl`{{execute}}

Now everything is ready to continue and launch a VM.
