
# nodeSelectors and nodeAffinity

## nodeSelector 

nodeSelectors are the works the opposite way as taints. Instead of repelling the Pods, nodeselectors attracts the Pods to specific nodes. A nodeSelector is a list of labels included in a Pod's spec.

As an example, let's say we set a label onto one node. Pods with the matching labels will then be assigned to the node that has the same label.

## nodeAffinity 

Another way of attracting Pods to specific ndoes is through the use of Node Affinity. Instead of allowing only the exact matches of labels, Node Affinity can use other set of criterias known as **Supported Operators**:

- In 
- NotIn 
- Exists 
- DoesNotExist 
- Gt 
- Lt

There are two types of node affinity:

- **requiredDuringSchedulingIgnoredDuringExecution**: The scheduler can't schedule the Pod unless the rule is met. This functions like nodeSelector, but with a more expressive syntax.

- **preferredDuringSchedulingIgnoredDuringExecution**: The scheduler tries to find a node that meets the rule. If a matching node is not available, the scheduler still schedules the Pod.
 
## Using required node affinity

We'll use the manifest below to create a Kubernetes cluster in Amazon EKS. You can also use this to create the clsuter in your preferred environment.

```bash
## eksops.yml

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

Create the cluster and check the nodes.

```bash
kubectl apply -f eksops.yml  
```
```bash
$ kubectl get nodes
NAME                                                STATUS   ROLES    AGE   VERSION
ip-192-168-11-247.ap-southeast-1.compute.internal   Ready    <none>   8h    v1.23.13-eks-fb459a0
ip-192-168-56-187.ap-southeast-1.compute.internal   Ready    <none>   8h    v1.23.13-eks-fb459a0
ip-192-168-81-3.ap-southeast-1.compute.internal     Ready    <none>   8h    v1.23.13-eks-fb459a0 
```

Add the "disktype=ssd" label to the first node and verify.

```bash
kubectl label nodes ip-192-168-11-247.ap-southeast-1.compute.internal disktype=ssd
```
```bash
$ kubectl get nodes --show-labels | grep ssd
ip-192-168-11-247.ap-southeast-1.compute.internal   Ready    <none>   8h    v1.23.13-eks-fb459a0   ....disktype=ssd...
```

Next, we'll use the manifest below to launch a Pod that has a **requiredDuringSchedulingIgnoredDuringExecution** node affinity,**disktype: ssd**. This means that the pod will get scheduled only on a node that has a disktype=ssd label.

```bash
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd            
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
```

Apply the manifest.

```bash
kubectl apply -f https://k8s.io/examples/pods/pod-nginx-required-affinity.yaml
```

The Pod should now be launched on the node with the matching label which in this case is the "192-168-11-247" node.

```bash
$ kubectl get pods -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP              NODE                                                NOMINATED NODE   READINESS GATES
nginx   1/1     Running   0          3s    192.168.8.176   ip-192-168-11-247.ap-southeast-1.compute.internal   <none>           <none> 
```

To delete the Pod:

```bash
kubectl delete -f https://k8s.io/examples/pods/pod-nginx-required-affinity.yaml
```

## Using preferred node affinity

In this second example, we'll use the manifest below to launch a Pod that has **preferredDuringSchedulingIgnoredDuringExecution** node affinity,**disktype: ssd**. This means that the pod will prefer a node that has a disktype=ssd label. 

This works almost the same way as required affinity, but the key difference is that we can specify a weight to each instance beforehand which is also considered by the scheduler when making scheduling decision for the Pod. 

```bash
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd          
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent 
```

Apply.

```bash
kubectl apply -f https://k8s.io/examples/pods/pod-nginx-preferred-affinity.yaml
```