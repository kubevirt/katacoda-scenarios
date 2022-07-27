# Deploy KubeVirt

Deploy the KubeVirt operator [^1] using the latest KubeVirt version.

[^1]: An Operator is a method of packaging, deploying, and managing a Kubernetes application. A Kubernetes application is one that is deployed on Kubernetes and managed using the Kubernetes APIs and kubectl tooling. You can think of Operators as the runtime that manages this type of application on Kubernetes. If you want to learn more about Operators you can check the [Kubernetes documentation](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)

Here, we query GitHub's API to get the latest available release:
(click on the text to automatically execute the commands on the console):

```
export KUBEVIRT_VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | jq -r .tag_name)
echo $KUBEVIRT_VERSION
```{{execute}}

Run the following command to deploy the KubeVirt Operator:

`kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-operator.yaml`{{execute}}

Now deploy KubeVirt by creating a Custom Resource that will trigger the 'operator' reaction and perform the deployment:

`kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-cr.yaml`{{execute}}

Next, we need to configure KubeVirt to use software emulation for virtualization. This is necessary for the course environment but results in poor performance so avoid this step in production environments.

`kubectl -n kubevirt patch kubevirt kubevirt --type=merge --patch '{"spec":{"configuration":{"developerConfiguration":{"useEmulation":true}}}}'`{{execute}}

# Install Virtctl

While we are waiting for the KubeVirt operator to start up all its Pods, we can take some time to download the client we will need to use in the next step.

_virtctl_ is a client utility that helps interact with VM's (start/stop/console, etc):

`wget -O virtctl https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/virtctl-${KUBEVIRT_VERSION}-linux-amd64`{{execute}}

`chmod +x virtctl`{{execute}}

# Wait for KubeVirt deployment to finalize

Let's check the deployment:
`kubectl get pods -n kubevirt`{{execute}}

Once it's ready, it will show something similar to:

```
controlplane $ kubectl get pods -n kubevirt
NAME                               READY     STATUS    RESTARTS   AGE
virt-api-7fc57db6dd-g4s4w          1/1       Running   0          3m
virt-api-7fc57db6dd-zd95q          1/1       Running   0          3m
virt-controller-6849d45bcc-88zd4   1/1       Running   0          3m
virt-controller-6849d45bcc-cmfzk   1/1       Running   0          3m
virt-handler-fvsqw                 1/1       Running   0          3m
virt-operator-5649f67475-gmphg     1/1       Running   0          4m
virt-operator-5649f67475-sw78k     1/1       Running   0          4m
```

As there are multiple deployments involved, the best way to determine whether the operator is fully installed is to check the operator's Custom Resource itself:

`kubectl -n kubevirt get kubevirt`{{execute}}

Once fully deployed, this will look like:

```
NAME      AGE   PHASE
kubevirt  3m    Deployed
```




Now everything is ready to continue and launch a VM.
