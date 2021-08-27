#### Define the next version to upgrade to

KubeVirt starting from `v0.17.0` onwards, allows upgrading one version at a time, by using two approaches as defined in the [user-guide](https://kubevirt.io/user-guide/operations/updating_and_deletion/):

- Patching the imageTag value in the KubeVirt CR spec
- Updating the operator if no imageTag is defined (defaulting to upgrade to match the operator version)

**WARNING:** In both cases, the supported scenario is updating from N-1 to N

**NOTE:** Zero downtime rolling updates are supported starting with release `v0.17.0` onwards. Updating from any release prior to the KubeVirt `v0.17.0` release is not supported.

#### Performing the upgrade

##### Method 1: changing the imageTag value in the KubeVirt CR’s spec

In this example we are going to update from the version `v0.17.0` to `v0.18.0`, that is as simple as patching the KubeVirt CR with the `imageTag: v0.18.0` value. From there the KubeVirt operator will begin the process of rolling out the new version of KubeVirt. Existing VM/VMIs will remain uninterrupted both during and after the update succeeds.

First, let's ensure we've `v0.17.0` installed by executing:

`kubectl get deployment.apps virt-operator -n kubevirt -o template --template='{{range .spec.template.spec.containers}}{{.image}}{{end}} '| awk -F: '{print $NF}'`{{execute}}

Now let's proceed with the update:

`kubectl patch kv kubevirt -n kubevirt --type=json -p '[{ "op": "add", "path": "/spec/imageTag", "value": "v0.18.0" }]'`{{execute}}

To follow the updating process you can keep watching the output on terminal 1 to see how the containers are stopped and started as the deployment happens.

To proceed with the next update in the Method 2 you have to revert the changes done and indicate no specific version with the following command:

`kubectl patch kv kubevirt -n kubevirt --type=json -p '[{ "op": "add", "path": "/spec/imageTag", "value": "" }]'`{{execute}}

##### Method 2: updating the KubeVirt operator if no imageTag value is set

When no `imageTag` value is set in the KubeVirt CR, the system assumes that the version of KubeVirt is locked to the version of the operator. This means that updating the operator will result in the underlying KubeVirt installation being updated as well.

Let's upgrade to the newer version after the upgrade done in the Method 1:

`export KUBEVIRT_VERSION=v0.19.0
kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-operator.yaml`{{execute}}

**NOTE:** Compared to the first step of the scenario now we are using **apply** instead of **create** to deploy the newer version because the operator already exists.

##### Differences between the two methods

The first way provides a fine granular approach where you have full control over what version of KubeVirt, because it is installed independently of what version of the KubeVirt operator you might be running.

The second approach allows you to lock both the operator and the operand to the same version.

Newer KubeVirt may require additional or extended RBAC rules. In this case, the 1st update method may fail, because the `virt-operator` present in the cluster doesn’t have these RBAC rules itself.

In this case, you need to update the virt-operator first, and then proceed to update kubevirt.

Anyways, we can check that the VM is still running

`kubectl get vmis`{{execute}}

~~~
controlplane $ kubectl get vmis
NAME      AGE       PHASE     IP           NODENAME
testvm    1m        Running   10.32.0.11   controlplane
~~~

#### Final upgrades

You can keep testing in this scenario updating 'one version at a time' until reaching the value of `KUBEVIRT_LATEST_VERSION`:

`export KUBEVIRT_LATEST_VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | jq -r .tag_name)
echo -e "CURRENT: $KUBEVIRT_VERSION \n LATEST: $KUBEVIRT_LATEST_VERSION"`{{execute}}

Compare the values between and continue upgrading 'one release at a time' by:

Choosing the target version:

`export KUBEVIRT_VERSION=vX.XX.X`{{execute}}

Updating the operator to that release:

`kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/kubevirt-operator.yaml`{{execute}}

**NOTE:** Since version `0.20.1`, the operator version should be checked with the following command:

`echo $(
kubectl get deployment.apps virt-operator -n kubevirt -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="KUBEVIRT_VERSION")].value}')`{{execute}}

####  Wrap-up

Shutting down a VM works by either using `virtctl` or editing the VM.

`./virtctl stop testvm`{{execute}}

Finally, the VM can be deleted using:

`kubectl delete vms testvm`{{execute}}

**NOTE:** We've seen two methods for upgrading, based on the future requirements it's better if we follow the `Operator` approach as it will take into consideration the new requirements.

When updating using the operator, we can see that the 'AGE' of containers is similar between them, but when updating only the kubevirt version, the operator 'AGE' keeps increasing because it is not 'recreated'.
