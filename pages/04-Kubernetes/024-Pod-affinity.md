
# Pod Affinity 

Like Node Affinity, **Pod Affinity** is used to constrain the nodes that can receive Pods by matching labels of the existing Pods that are already running on the nodes.

The main difference between the two affinities are:

- Node Affinity ensures that pods are hosted on particular nodes
- Pod Affinity ensures two pods to be co-located in a single node

Pod affinities also support the same operators as Node affinity:

- In 
- NotIn 
- Exists 
- DoesNotExist 
- Gt 
- Lt

However, the conditions are specific for the Pod labels, not the node labels. This means the conditions are evaluated based on the labels of the Pods running on each node. 

- computationally more expensive
- not recommended for large clusters with hundreds of nodes or more
- since pods are namespaced, their labels are also namespaced

After the conditions are evaluated, the **topology key** is used in deciding the node in which the pod will be scheduled on. This key usually corresponds to a physical domain such as datacenter, region, server rack, etc.



<br>

[Back to first page](../../README.md#kubernetes)
