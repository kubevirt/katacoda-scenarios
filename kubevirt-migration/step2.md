#### Deploy a service on the VM

Create two NodePort services to access ports on the VM:

`
virtctl expose vmi testvm --name=testvm-ssh --port=22 --type=NodePort
virtctl expose vmi testvm --name=testvm-http --port=8080 --type=NodePort
`{{execute}}

Save the SSH NodePort to a variable:

`SSHPORT=$(kubectl get service testvm-ssh -o jsonpath='{.spec.ports[0].nodePort}')`{{execute}}

The Cirros VM uses a default username and password of `cirros:gocubsgo`. Using
sshpass, we can automatically run commands on the testvm without a password
prompt. First, hide the password in an environment variable:

`export SSHPASS=gocubsgo`{{execute}}

Next, ssh into testvm and run the hostname command:

`sshpass -e ssh node01 -l cirros -p $SSHPORT hostname`{{execute}}

If all went well, this should print the VM's hostname, "testvm".

Next, we will try something more complicated. Due to cirros' lack of a
webserver, we will create one using a while loop and the netcat utility (which
cirros does include).

The bash loop looks like:

~~~sh
while true
do
    ( echo "HTTP/1.0 200 Ok"; echo; echo "Migration test" ) | nc -l -p 8080
done
~~~

The full command looks like the following, with `-f` added to background the
ssh session and return control to the controlplane node.

`sshpass -e ssh node01 -l cirros -p $SSHPORT -f 'while true; do ( echo "HTTP/1.0 200 Ok"; echo; echo "Migration test" ) | nc -l -p 8080; done'`{{execute}}

As with the ssh NodePort, it will be necessary to capture the http NodePort to a variable.

`HTTPPORT=$(kubectl get service testvm-http -o jsonpath='{.spec.ports[0].nodePort}')`{{execute}}

Test the http connection:

`curl node01:$HTTPPORT`{{execute}}

This should return something like the following:

~~~sh
GET / HTTP/1.1
Host: node01:30115
User-Agent: curl/7.58.0
Accept: */*

Migration test
~~~

Note that the first part is actually netcat echoing curl instructions over your
backgrounded ssh connection. The important part is "Migration test" at the
bottom.

#### Migrate the VM

Migration is a straightforward procedure with virtctl. To start a migration, run:

`virtctl migrate testvm`{{execute}}

This should return:

~~~
VM testvm was scheduled to migrate
~~~

Run the following multiple times to follow the migration:

`kubectl get vmis,pods -o wide`{{execute}}

KubeVirt will schedule and start a virt-launcher pod instance on the target node, "controlplane" in our case:

~~~
NAME                                        AGE   PHASE     IP           NODENAME   LIVE-MIGRATABLE   PAUSED
virtualmachineinstance.kubevirt.io/testvm   26m   Running   10.244.1.7   node01     True

NAME                             READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
pod/virt-launcher-testvm-676tr   2/2     Running   0          26m   10.244.1.7   node01         <none>           <none>
pod/virt-launcher-testvm-fd2lj   2/2     Running   0          21s   10.244.0.9   controlplane   <none>           <none>
~~~

Once the two virt-launcher pods are synchronized, control will swap over to the new one, and the other will be scheduled for shutdown.

~~~
NAME                                        AGE   PHASE     IP           NODENAME       LIVE-MIGRATABLE   PAUSED
virtualmachineinstance.kubevirt.io/testvm   27m   Running   10.244.0.9   controlplane   True              

NAME                             READY   STATUS     RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
pod/virt-launcher-testvm-676tr   1/2     NotReady   0          27m   10.244.1.7   node01         <none>           <none>
pod/virt-launcher-testvm-fd2lj   2/2     Running    0          54s   10.244.0.9   controlplane   <none>           <none>
~~~

Eventually, the old virt-launcher will enter a Completed state:

~~~
NAME                                        AGE   PHASE     IP           NODENAME       LIVE-MIGRATABLE   PAUSED
virtualmachineinstance.kubevirt.io/testvm   27m   Running   10.244.0.9   controlplane   True

NAME                             READY   STATUS      RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
pod/virt-launcher-testvm-676tr   0/2     Completed   0          27m   10.244.1.7   node01         <none>           <none>
pod/virt-launcher-testvm-fd2lj   2/2     Running     0          70s   10.244.0.9   controlplane   <none>           <none>
~~~

#### Test running services on the migrated VM

Run the curl command again. Because NodePorts are forwarded regardless of which node the actual Pod is running on, it is okay to use the same hostname as before even though the VM is now running on controlplane.

`curl node01:$HTTPPORT`{{execute}}

Note that the netcat output of the HTTP headers sent by curl will no longer display, only the output:

~~~
Migration test
~~~

This is because the ssh connection that was running the while loop got
disconnected during the migration. A look at the VM IP will show why this
happens. In our example, it has changed from 10.244.1.7 to 10.244.0.9.

#### Shutdown and cleanup

Shutting down a VM works by either using `virtctl` or editing the VM.

`virtctl stop testvm`{{execute}}

Finally, the VM can be deleted using:

`kubectl delete vm testvm`{{execute}}
