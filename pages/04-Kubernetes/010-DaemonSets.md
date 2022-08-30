# DaemonSets

A **DaemonSet** ensures that all (or some) nodes run a copy of a Pod. As nodes are added to the cluster, Pods are added to them. As nodes are removed from the cluster, those Pods are garbage collected. Deleting a DaemonSet will clean up the Pods it created.

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
kube-proxy   2           2           2       2           2
```

In the example above, we see that there's two DaemonSets running:

- **kube-proxy** 
    - handles iptables configs of the nodes
    - allows network connectivity to happen with the pods on the node.

    ```bash
    kubectl logs -n kube-system kube-proxy-XXXXX
    ```

- **aws-node** 
    - handles network overlay underneath
    - contains the CNI plugins necessary for EC2 nodes to be able to communicate with the Amazon VPC CNI.

    ```bash
    kubectl describe ds aws-node -n kube-system 
    ```

To learn more, check out [DaemonSets in Kubernetes](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/).