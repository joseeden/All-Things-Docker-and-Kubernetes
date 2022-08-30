# DaemonSets

A **DaemonSet** ensures that all (or some) Nodes run a copy of a Pod. As nodes are added to the cluster, Pods are added to them. As nodes are removed from the cluster, those Pods are garbage collected. Deleting a DaemonSet will clean up the Pods it created.

Some typical uses of a DaemonSet are:

- running a cluster storage daemon on every node
- running a logs collection daemon on every node
- running a node monitoring daemon on every node

To see the daemonsets running:

```bash
$ kubectl get ds
```

To get more information about the daemonset in a specific namespace, e.g. kube-system: 

```bash
$ kubectl describe <daemonset> -n kube-system
```

To see the daemonset in a specific namespace, e.g. kube-system: 

```bash
$ kubectl get ds -n kube-system 
```
```bash
NAME        DESIRED     CURRENT     READY   UP-TO-DATE  AVAILABLE
aws-node    2           2           2       2           2
ube-proxy   2           2           2       2           2
```

In the example above, we see that there's two DaemonSets running:

- **kube-proxy** - handles iptables configs of the nodes
- **aws-node** - handles network overlay underneath


To learn more, check out [DaemonSets in Kubernetes](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/).