
# Taints and Tolerations 


  - [Taints vs Tolerations](#taints-vs-tolerations)
  - [Tainting the Node](#tainting-the-node)
  - [Test the Taint](#test-the-taint)
  - [Removing the Taint](#removing-the-taint)


## Taints vs Tolerations 

Taints are similar to node-labels, that taints also influence the scheduling of Pods. Taints are applied to pods and its purpose to repel Pods from nodes. Any Pod that is scheduled on a tainted node must have the toleration for the taint.

```bash
Taints are set on nodes.
Tolerations are set on pods. 
```

On the other hand, tolerations apply to Pods and counteract the taints.  Taints and tolerations are used together to ensure that Pods are onlys cheduled on appropriate nodes in a cluster.

As an example, I've used the manifest file below to create a Kubernetes cluster in Amazon EKS.

```yaml
# eksops.yml 

apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
    version: "1.23"
    name: eksops
    region: ap-southeast-1 
nodeGroups:
    -   name: ng-dover
        instanceType: t3.large
        minSize: 0
        maxSize: 5
        desiredCapacity: 3
        ssh: 
            publicKeyName: "k8s-kp" 
```

To create the cluster:

```bash
kubectl apply -f eksops.yml 
```

This will create three nodes. To view them:

```bash
$ kubectl get nodes

NAME                                                STATUS   ROLES    AGE     VERSION
ip-192-168-11-247.ap-southeast-1.compute.internal   Ready    <none>   6h30m   v1.23.13-eks-fb459a0
ip-192-168-56-187.ap-southeast-1.compute.internal   Ready    <none>   6h30m   v1.23.13-eks-fb459a0
ip-192-168-81-3.ap-southeast-1.compute.internal     Ready    <none>   6h30m   v1.23.13-eks-fb459a0 
```

Eventhough we haven't deployed anything yet, there will be system Pods running on the cluster. We can check the pods by running the command below. One of the set of Pods created by the DaemonSet is the **kube-proxy**. 

Recall that a [DaemonSet](./010-DaemonSets.md) ensures that each node will have a copy of the Pod. Since we have three nodes, we can see that there's also three kube-proxy pods.

```bash
$ kubectl get pods -A

NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
kube-system   aws-node-fbd7z             1/1     Running   0          6h40m
kube-system   aws-node-kg7tn             1/1     Running   0          6h40m
kube-system   aws-node-kqxqn             1/1     Running   0          6h40m
kube-system   coredns-6d8cc4bb5d-2xkxp   1/1     Running   0          6h51m
kube-system   coredns-6d8cc4bb5d-6wpbx   1/1     Running   0          6h51m
kube-system   kube-proxy-cb687           1/1     Running   0          6h40m
kube-system   kube-proxy-dt5xd           1/1     Running   0          6h40m
kube-system   kube-proxy-h9s8l           1/1     Running   0          6h40m 
```

To see that toleration on one of the kube-proxy pod, run the command below.

```bash
kubectl get pods -n kube-system kube-system  kube-proxy-cb687 -o yaml
```

Scroll down to the **tolerations** section. This ensures that the Pod will be eligible to be scheduled on all nodes, including when there are limited resources available.

DaemonSets are automatically created with these tolerations.

```yaml
    tolerations:
    - operator: Exists
    - effect: NoExecute
      key: node.kubernetes.io/not-ready
      operator: Exists
    - effect: NoExecute
      key: node.kubernetes.io/unreachable
      operator: Exists
    - effect: NoSchedule
      key: node.kubernetes.io/disk-pressure
      operator: Exists
    - effect: NoSchedule
      key: node.kubernetes.io/memory-pressure
      operator: Exists
    - effect: NoSchedule
      key: node.kubernetes.io/pid-pressure
      operator: Exists
    - effect: NoSchedule
      key: node.kubernetes.io/unschedulable
      operator: Exists
    - effect: NoSchedule
      key: node.kubernetes.io/network-unavailable
      operator: Exists 
```

To learn more, check out [Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/).

## Tainting the Node 

Let's try to taint the first node by setting the **high-priority** taint. This will now only allow Pods that can tolerate the taint are scheduled onto the node. This taint can be used to reserve resources for high-priority workloads.

```bash
$ kubectl get nodes
NAME                                                STATUS   ROLES    AGE     VERSION
ip-192-168-11-247.ap-southeast-1.compute.internal   Ready    <none>   6h45m   v1.23.13-eks-fb459a0
ip-192-168-56-187.ap-southeast-1.compute.internal   Ready    <none>   6h45m   v1.23.13-eks-fb459a0
ip-192-168-81-3.ap-southeast-1.compute.internal     Ready    <none>   6h45m   v1.23.13-eks-fb459a0 
```

```bash
kubectl taint node \
ip-192-168-11-247.ap-southeast-1.compute.internal \
priority=high:NoSchedule 
```

There are three taint effects:


Taint effect | Description |
---------|----------|
 NoSchedule | System avoids the specific node and places the Pod on the next available node.   
 PreferNoSchedule | System will try to avoid placing Pods on the node but there is no guarantee. 
 NoExecute | New pods will not be scheduled on the node and existing pods will be evicted if they do not tolerate the taint. 


Verify this by checking the **taint** for all three nodes.

```bash
$ kubectl describe node ip-192-168-11-247.ap-southeast-1.compute.internal | grep Taint
Taints:             priority=high:NoSchedule
```

```bash
$ kubectl describe node ip-192-168-56-187.ap-southeast-1.compute.internal | grep Taint
Taints:             <none>
```

```bash
$ kubectl describe node ip-192-168-81-3.ap-southeast-1.compute.internal | grep Taint
Taints:             <none>  
```

## Test the Taint 

Let's now create a namespace called **testing** and run a simple NGINX deployment with 4 replicas and see where the 4 Pods will be scheduled.

```bash
kubectl create namespace testing 
```
```bash
kubectl create deployment my-deployment -n testing \
--image=nginx \
--replicas=4
```

We can see that four pods are created under the **testing** namespace.

```bash
$ kubectl get pods -n testing
NAME                            READY   STATUS    RESTARTS   AGE
my-deployment-cfd9bd55b-2hqkj   1/1     Running   0          18s
my-deployment-cfd9bd55b-bx77s   1/1     Running   0          18s
my-deployment-cfd9bd55b-tx5mv   1/1     Running   0          18s
my-deployment-cfd9bd55b-xk9hm   1/1     Running   0          18s 
```

We can add the "-o wide" parameter to see on what nodes are the Pods scheduled. Here we can see that the Pods are scheduled on the two nodes without any taints.

```bash
$ kubectl get pods -n testing -o wide
NAME                            READY   STATUS    RESTARTS   AGE   IP               NODE
                NOMINATED NODE   READINESS GATES
my-deployment-cfd9bd55b-2hqkj   1/1     Running   0          61s   192.168.54.78    ip-192-168-56-187.ap-southeast-1.compute.internal   <none>           <none>
my-deployment-cfd9bd55b-bx77s   1/1     Running   0          61s   192.168.43.49    ip-192-168-56-187.ap-southeast-1.compute.internal   <none>           <none>
my-deployment-cfd9bd55b-tx5mv   1/1     Running   0          61s   192.168.88.99    ip-192-168-81-3.ap-southeast-1.compute.internal     <none>           <none>
my-deployment-cfd9bd55b-xk9hm   1/1     Running   0          61s   192.168.69.116   ip-192-168-81-3.ap-southeast-1.compute.internal     <none>           <none> 
```

## Removing the Taint 

Before we remove the taint, let's delete the deployment first.

```bash
kubectl delete deployment -n testing my-deployment 
```

Remove the taint on the first node by running the same taint command but with "-" at the end.

```bash
kubectl taint node ip-192-168-11-247.ap-southeast-1.compute.internal \
priority=high:NoSchedule 
```

Check the taint:

```bash
$ kubectl describe node ip-192-168-81-3.ap-southeast-1.compute.internal | grep Taint
Taints:             <none> 
```


<br>

[Back to first page](../../README.md#kubernetes)
