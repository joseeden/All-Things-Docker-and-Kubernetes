# Lab 21: Resource Requirements


Before we begin, make sure you've setup the following pre-requisites

- [Basic Understanding of Kubernetes](../README.md#kubernetes)
- [AWS account](../pages/01-Pre-requisites/labs-optional-tools/README.md#create-an-aws-account)
- [AWS IAM Requirements](../pages/01-Pre-requisites/labs-optional-tools/01-AWS-IAM-requirements.md)
- [AWS CLI, kubectl, and eksctl](../pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md#install-cli-tools) 

Here's a breakdown of the sections for this lab.


- [Introduction](#introduction)
- [Launch a Simple EKS Cluster](#launch-a-simple-eks-cluster)
- [Install the Metrics Server](#install-the-metrics-server)
- [Unrestricted Pod](#unrestricted-pod)
- [Limited Pod](#limited-pod)
- [Cleanup](#cleanup)


## Introduction

In this lab, we'll get to explore how we can define resource requirements to set a requested amount and limits on the compute resources that our pods can user. These two are optional but setting them will help the Kubernetes Scheduler to make better decisions on assigning Pods to nodes. 

Defining the limits also ensures that there is no resource contention between the Pods that are launched on the same node.

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
        desiredCapacity: 1
        ssh: 
            publicKeyName: "k8s-kp"
```
 
</details>

Launch the cluster.

```bash
time eksctl create cluster -f eksops.yml 
```

Check the nodes and pods.

```bash
kubectl get nodes 
```

Save the cluster, region, and AWS account ID in a variable. We'll be using these in a lot of the commands later.

```bash
MYREGION=ap-southeast-1
MYCLUSTER=eksops 
MYAWSID=$(aws sts get-caller-identity | python3 -c "import sys,json; print (json.load(sys.stdin)['Account'])")
```

## Install the Metrics Server 

We'll install the metrics server in our cluster to view Pod and node compute resource usage. This will allow us to use the **kubectl top** command later to view the resource utilization of our Pods.

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.1/components.yaml 
```

Verify.

```bash
$ kubectl get pods -A | grep metrics
kube-system   metrics-server-847dcc659d-t5f4v   1/1     Running   0          18m 
```

## Unrestricted Pod 

We'll use the [load.yml](load.yml) file to create a Pod that will consume a lot of the CPU resources of our Node.

```bash
apiVersion: v1
kind: Pod
metadata:
  name: load
spec:
  containers:
  - name: cpu-load
    image: cloudacademydevops/stress
    args:
    - -cpus
    - "5"
```

Apply the manifest.

```bash
kubectl apply -f load.yaml 
```

Check which Node is the Pod deployed. The Pod is launched on the "ip-192-168-17-73" node.

```bash
$ kubectl get pods -o wide
NAME   READY   STATUS    RESTARTS   AGE   IP              NODE                                               NOMINATED NODE   READINESS GATES
load   1/1     Running   0          12s   192.168.7.224   ip-192-168-17-73.ap-southeast-1.compute.internal   <none>           <none> 
```

List the resource consumption of pods.

```bash
$ kubectl top pods
NAME   CPU(cores)   MEMORY(bytes)
load   1913m        1Mi 
```

Here we can see that the Pod is already using almost 2 full cores which can cause some significant impact if you have other workloads running on the same node. We can confirm this by checking the resource utilization in the nodes.

```bash
$ kubectl top nodes
NAME                                                CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
ip-192-168-17-73.ap-southeast-1.compute.internal    2000m        103%   559Mi           7%
ip-192-168-60-220.ap-southeast-1.compute.internal   33m          1%     546Mi           7%
ip-192-168-87-193.ap-southeast-1.compute.internal   40m          2%     605Mi           8%
```

## Limited Pod

Let's create another Pod but with defined resource limits and requests. We'll use the [load-limited.yml](./load-limited.yml) file for this.

```bash
apiVersion: v1
kind: Pod
metadata:
  name: load-limited
spec:
  containers:
  - name: cpu-load-limited
    image: cloudacademydevops/stress
    args:
    - -cpus
    - "2"
    resources:
      limits:
        cpu: "0.5" # half a core
        memory: "20Mi" # 20 mebibytes 
      requests:
        cpu: "0.35" # 35% of a core
        memory: "10Mi" # 20 mebibytes 
```

Apply.

```bash
kubectl apply -f load-limited.yml 
```
```bash
$ kubectl get pods -o wide
NAME           READY   STATUS    RESTARTS   AGE     IP              NODE                                                NOMINATED NODE   READINESS GATES
load           1/1     Running   0          6m32s   192.168.7.224   ip-192-168-17-73.ap-southeast-1.compute.internal    <none>           <none>
load-limited   1/1     Running   0          9s      192.168.63.48   ip-192-168-60-220.ap-southeast-1.compute.internal   <none>           <none> 
```

Verify that the **load-limited** pod is only using the amount of resources we set in its manifest.

```bash
$ kubectl top pods
NAME           CPU(cores)   MEMORY(bytes)
load           1961m        1Mi
load-limited   500m         1Mi 
```

We can also check the pods and their non-terminated Pods tables to see workloads influence scheduling decisions. The **load** pod is launched on the node which shows **CPU Requests** of zero. The reason for this is because we didn't set the any limits or requests on that pod's manifest. It also doesn't impact the **load-limited** pod which is launched on another node.

```bash
$ kubectl describe nodes | grep --after-context=5 "Non-terminated Pods"
Non-terminated Pods:          (3 in total)
  Namespace                   Name                CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                ------------  ----------  ---------------  -------------  ---
  default                     load                0 (0%)        0 (0%)      0 (0%)           0 (0%)         7m33s
  kube-system                 aws-node-xqhdx      25m (1%)      0 (0%)      0 (0%)           0 (0%)         93m
  kube-system                 kube-proxy-njfqn    100m (5%)     0 (0%)      0 (0%)           0 (0%)         93m
--
Non-terminated Pods:          (3 in total)
  Namespace                   Name                CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                ------------  ----------  ---------------  -------------  ---
  default                     load-limited        350m (18%)    500m (25%)  10Mi (0%)        20Mi (0%)      70s
  kube-system                 aws-node-bhsgt      25m (1%)      0 (0%)      0 (0%)           0 (0%)         93m
  kube-system                 kube-proxy-phxmq    100m (5%)     0 (0%)      0 (0%)           0 (0%)         93m
--
Non-terminated Pods:          (5 in total)
  Namespace                   Name                               CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                               ------------  ----------  ---------------  -------------  ---
  kube-system                 aws-node-zx2n4                     25m (1%)      0 (0%)      0 (0%)           0 (0%)         93m
  kube-system                 coredns-6d8cc4bb5d-6csmj           100m (5%)     0 (0%)      70Mi (0%)        170Mi (2%)     103m
  kube-system                 coredns-6d8cc4bb5d-cn9zd           100m (5%)     0 (0%)      70Mi (0%)        170Mi (2%)     103m 
```

## Cleanup 

Before we officially close this lab, make sure to destroy all resources to prevent incurring additional costs.

```bash
$ time eksctl delete cluster -f  
```

Note that when you delete your cluster, make sure to double-check the AWS Console and ensure that the Cloudformation stacks (which we created by eksctl) are dropped cleanly.