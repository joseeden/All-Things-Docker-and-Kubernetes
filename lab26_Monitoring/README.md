# Lab 26: Monitoring


Before we begin, make sure you've setup the following pre-requisites

- [Basic Understanding of Kubernetes](../README.md#kubernetes)
- [AWS account](../pages/01-Pre-requisites/labs-optional-tools/README.md#create-an-aws-account)
- [AWS IAM Requirements](../pages/01-Pre-requisites/labs-optional-tools/01-AWS-IAM-requirements.md)
- [AWS CLI, kubectl, and eksctl](../pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md#install-cli-tools) 

Here's a breakdown of the sections for this lab.

- [Introduction](#introduction)
- [Launch a Simple EKS Cluster](#launch-a-simple-eks-cluster)
- [Readiness Probes](#readiness-probes)
- [Liveness Probes](#liveness-probes)
- [Delete the Probes](#delete-the-probes)
- [Monitoring](#monitoring)
- [Cleanup](#cleanup)
- [Resources](#resources)


## Introduction

We've covered the first pillar of observability in th [previous lab](../lab25_Logging/README.md), Logging. In this lab, we'll go through the second pillar, Monitoring, and learn how Kubernetes handles the monitoring of Pods through built-in mechanisms such as Probes, as well as available external monitoring systems.

As an overview, there are three types of Probes:
- **Readiness Probes** - checks if a Pod is ready to server traffic and handle requests.
- **Liveness Probes** - detects if a Pod enters a broken state where it can no longer serve traffic.
- **Startup Probes** - Used when an application starts slowly and may otherwise be killed due to failed liveness probes

A container can define up to one of each type of probe. All probes are also configured the same way.

The main difference between the three is that Readiness and Liveness probes run for the entire lifetime of the container they are declared in, while Startng probes only run until they first succeed.

To learn more about Probes, check out the [Probes page](../pages/04-Kubernetes/020-Probes.md).


## Launch a Simple EKS Cluster

Before we start, let's first verify if we're using the correct IAM user's access keys. This should be the user we created from the **pre-requisites** section above.

```bash
$ aws sts get-caller-identity 
```
```bash
{
    "UserId": "AIDxxxxxxxxxxxxxx",
    "Account": "1234567890",
    "Arn": "arn:aws:iam::1234567890:user/k8s-admin"
} 
```

For the cluster, we can reuse the **eksops.yml** file from the other labs.

<details><summary> eksops.yml </summary>
 
```bash
apiVersion: eksctl.io/v1alpha5
# apiVersion: client.authentication.k8s.io/v1beta1
kind: ClusterConfig

metadata:
    version: "1.23"
    name: eksops
    region: ap-southeast-1 
nodeGroups:
    -   name: ng-dover
        instanceType: t3.large
        minSize: 1
        maxSize: 5
        desiredCapacity: 3
        ssh: 
            publicKeyName: "k8s-kp"
```
 
</details>

Launch the cluster.

```bash
time eksctl create cluster -f eksops.yml 
```

Check the nodes.

```bash
kubectl get nodes 
```

Save the cluster, region, and AWS account ID in a variable. We'll be using these in a lot of the commands later.

```bash
MYREGION=ap-southeast-1
MYCLUSTER=eksops 
MYAWSID=$(aws sts get-caller-identity | python3 -c "import sys,json; print (json.load(sys.stdin)['Account'])")
```


## Readiness Probes

We can read about readinessProbes by using the **explain** command on the path:

```bash
$ kubectl explain pod.spec.containers.readinessProbe
KIND:     Pod
VERSION:  v1

RESOURCE: readinessProbe <Object>

DESCRIPTION:
     Periodic probe of container service readiness. Container will be removed
     from service endpoints if the probe fails. Cannot be updated. More info:
     https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes

     Probe describes a health check to be performed against a container to
     determine whether it is alive or ready to receive traffic.

FIELDS:
   exec <Object>
     Exec specifies the action to take.

   failureThreshold     <integer>
     Minimum consecutive failures for the probe to be considered failed after
     having succeeded. Defaults to 3. Minimum value is 1.

   grpc <Object>
     GRPC specifies an action involving a GRPC port. This is a beta field and
     requires enabling GRPCContainerProbe feature gate.

   httpGet      <Object>
     HTTPGet specifies the http request to perform.

   initialDelaySeconds  <integer>
     Number of seconds after the container has started before liveness probes
     are initiated. More info:
     https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes

   periodSeconds        <integer>
     How often (in seconds) to perform the probe. Default to 10 seconds. Minimum
     value is 1.

   successThreshold     <integer>
     Minimum consecutive successes for the probe to be considered successful
     after having failed. Defaults to 1. Must be 1 for liveness and startup.
     Minimum value is 1.

   tcpSocket    <Object>
     TCPSocket specifies an action involving a TCP port.

   terminationGracePeriodSeconds        <integer>
     Optional duration in seconds the pod needs to terminate gracefully upon
     probe failure. The grace period is the duration in seconds after the
     processes running in the pod are sent a termination signal and the time
     when the processes are forcibly halted with a kill signal. Set this value
     longer than the expected cleanup time for your process. If this value is
     nil, the pod's terminationGracePeriodSeconds will be used. Otherwise, this
     value overrides the value provided by the pod spec. Value must be
     non-negative integer. The value zero indicates stop immediately via the
     kill signal (no opportunity to shut down). This is a beta field and
     requires enabling ProbeTerminationGracePeriod feature gate. Minimum value
     is 1. spec.terminationGracePeriodSeconds is used if unset.

   timeoutSeconds       <integer>
     Number of seconds after which the probe times out. Defaults to 1 second.
     Minimum value is 1. More info:
     https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes 
```

We'll use [probe-readiness.yml](./probe-readiness.yml) to deploy a Pod that uses a **readinessProbe** which will check for a successfull HTTP response from the Pod's IP on port 80. On the other hand, the container command will simulate a startup routine by delaying the bootup of the server by sleeping for 30 seconds.

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: readiness-http
  labels:
    test: readiness
spec:
  replicas: 1
  selector:
    matchLabels:
      test: readiness  
  template:
    metadata:
      labels:
        test: readiness      
    spec:    
      containers:
      - name: readiness
        image: httpd:2.4.38-alpine
        ports:
        - containerPort: 80
        # Sleep for 30 seconds before starting the server
        command: ["/bin/sh","-c"]
        args: ["sleep 30 && httpd-foreground"]
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 3 
```

Run the manifest.

```bash
kubectl apply -f probe-readiness.yml 
```

We can see that the Pod is running when we check the status. However, the pod is not actually ready to receive requests because the readiness Probe actually failed. We can see this as a condition when we **describe** the pod.

```bash
~$ kubectl get pod
NAME                              READY   STATUS    RESTARTS   AGE
readiness-http-75fb994f94-t645n   1/1     Running   0          5m40s
```

```bash
~$ kubectl describe pod readiness-http-75fb994f94-t645n | grep Conditions -A 5
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   False 
  PodScheduled      True  
```

We can also the **Events** section of the output.

```bash
~$ kubectl describe pod readiness-http-75fb994f94-t645n | grep Events -A 10
Events:
  Type     Reason     Age                    From               Message
  ----     ------     ----                   ----               -------
  Normal   Scheduled  6m22s                  default-scheduler  Successfully assigned default/readiness-http-75fb994f94-t645n to ip-10-0-0-11.us-west-2.compute.internal
  Normal   Pulling    6m20s                  kubelet            Pulling image "httpd:2.4.38-alpine"
  Normal   Pulled     6m14s                  kubelet            Successfully pulled image "httpd:2.4.38-alpine" in 6.455970435s
  Normal   Created    6m12s                  kubelet            Created container readiness
  Normal   Started    6m12s                  kubelet            Started container readiness
  Warning  Unhealthy  5m42s (x10 over 6m9s)  kubelet            Readiness probe failed: Get "http://192.168.23.130:80/": dial tcp 192.168.23.130:80: connect: connection 
```

After some more attempts, the probe will succeed and the **Conditions** should all change to **True.**

```bash
~$ kubectl describe pod readiness-http-75fb994f94-t645n | grep Conditions -A 5
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True  
```

We can try to kill all the running httpd processes inside the Pod's container to confirm that the readiness probes are always running. 
```bash
kubectl exec readiness-http-75fb994f94-t645n -- pkill httpd 
```

After we kill the HTTP processes, the **Conditions** will show False on thw two conditions again while httpd server tries to recover.

```bash
~$ kubectl describe pod readiness-http-75fb994f94-t645n | grep Conditions -A 5
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   False 
  PodScheduled      True
```

The status of the Pod will also change to **CrashLoopBackOff** as it tries to restart the Pod. It will return back to Running once the probe succeeds.

```bash
~$ kubectl get pod
NAME                              READY   STATUS    RESTARTS      AGE
readiness-http-75fb994f94-t645n   0/1     CrashLoopBackOff   1 (18s ago)   7m24s
```

## Liveness Probes 

Let's use [probe-liveness.yml](./probe-liveness.yml) to detect if a Pod enters a broken state.

The nc (netcat) command listens (the -l option) for connections on port (-p) 8888 and responds with the message hi for the first 30 seconds, after which timeout kills the nc server. The liveness probe attempts to establish a connection with the server every 5 seconds.


```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: liveness-tcp
  labels:
    test: liveness
spec:
  replicas: 1
  selector:
    matchLabels:
      test: liveness  
  template:
    metadata:
      labels:
        test: liveness      
    spec:    
      containers:
      - name: liveness
        image: busybox:1.30.1
        ports:
        - containerPort: 8888
        livenessProbe:
          tcpSocket:
            port: 8888
          initialDelaySeconds: 3
          periodSeconds: 5
        # Listen on port 8888 for 30 seconds, then sleep
        command: ["/bin/sh", "-c"]
        args: ["timeout 30 nc -p 8888 -lke echo hi && sleep 600"]
```

Run the manifest.

```bash
kubectl apply -f probe-liveness.yml 
```

We can see that the liveness Pod has tried to restart thrice. Recall that the probe needs to fail three times after having success to consider the probe as failed.

```bash
$ kubectl get pod
NAME                              READY   STATUS             RESTARTS        AGE
liveness-tcp-66464b9b7d-964dx     0/1     CrashLoopBackOff   3 (25s ago)     3m11s
readiness-http-75fb994f94-t645n   1/1     Running            2 (9m29s ago)   16m 
``` 

We can also see the summary under the **Containers** section in the **describe** output.

```bash
~$ kubectl describe pod liveness-tcp-66464b9b7d-964dx | grep Restart -A 1

    Restart Count:  3
    Liveness:       tcp-socket :8888 delay=3s timeout=1s period=5s #success=1 #failure=3 
```

## Delete the Probes 

We've intentionally caused the readinessProbes and livenessProbes to fail and we've seen how each are configured almost the same way and how each tries to restart the probes. The livenessProbe will keep on attempting to recover the Pod and it will be stuck in that loop because we have a command inside the container that intentionally kills the server, which causes the connection to drop.

Delete the probes.

```bash
kubectl delete -f probe-readiness.yml 
kubectl delete -f probe-liveness.yml
```

## Monitoring

Besides using purpose-built monitoring mechanisms that run in pods, we can also use a basic monitoring solution called **Metrics Server.** It can be used to monitor the resource usage in out cluster. The Metrics API offers a basic set of metrics to support automatic scaling and similar use cases. 

This API makes information available about resource usage for node and pod, including metrics for CPU and memory. To learn more, check out [Resource metrics pipeline.](https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/)

To install the Metric Server, checkout the [official Metrics Server Github page.](https://github.com/kubernetes-sigs/metrics-server).

We can list all the events in sequence that occured in our Pods in the default namespace by running:

```bash
kubectl get events -n default
```

We can also use the **top** command to see the resource consumption for the nodes and Pods.

```bash
~$ kubectl top node
NAME                                       CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
ip-10-0-0-10.us-west-2.compute.internal    109m         5%     855Mi           22%       
ip-10-0-0-100.us-west-2.compute.internal   145m         7%     1232Mi          32%       
ip-10-0-0-11.us-west-2.compute.internal    80m          4%     732Mi           19% 
```

Explanation:

- The CPU(cores) column would have a maximum value of 2000m (2000 milliCPU cores = 2 CPU cores).
- The CPU metrics indicate that the cluster is not under CPU pressure. 
- The MEMORY columns indicate that there is greater than 50% memory available on the nodes.
- That indicates the cluster if oversized for the current workload. 

As new Pods are added we should monitor the memory pressure. It is also recommended to set the following to avoid an unexpected degradation in performance:
- CPU limits 
- memory limits
- requests 

We can also view the resource utilization at a granular level by adding the **--containers** option when we have multi-container Pods.

```bash
 ~$ kubectl top pod -n kube-system --containers
POD                                                                NAME                      CPU(cores)   MEMORY(bytes)   
calico-kube-controllers-f88756749-tw9kt                            calico-kube-controllers   2m           12Mi            
calico-node-62z9q                                                  calico-node               30m          96Mi            
calico-node-6b2h2                                                  calico-node               20m          95Mi            
calico-node-m445l                                                  calico-node               23m          95Mi  
```

We can use label selectors to filter Pods. In the example below, we can see the utilization of Pods that has the **k8s-app=kube-dns** label:

```bash
~$ kubectl top pod -n kube-system --containers -l k8s-app=kube-dns
POD                        NAME      CPU(cores)   MEMORY(bytes)   
coredns-6d4b75cb6d-dn29p   coredns   1m           11Mi            
coredns-6d4b75cb6d-xrdqh   coredns   1m           11Mi   
```

Since this lab didn't dive deep into the Metric Server, you can check out another lab where we [installed the Metric Server and Kubernetes Dashboard.](../lab55_EKS_Kubernetes_Dashboard/README.md)


## Cleanup 

Before we officially close this lab, make sure to destroy all resources to prevent incurring additional costs.

```bash
$ time eksctl delete cluster -f eksops.yml
```

Note that when you delete your cluster, make sure to double-check the AWS Console and ensure that the Cloudformation stacks (which we created by eksctl) are dropped cleanly.

## Resources

- [Kubernetes Observability: Logging](https://cloudacademy.com/lab/kubernetes-observability-logging/connecting-kubernetes-cluster/?context_id=888&context_resource=lp)