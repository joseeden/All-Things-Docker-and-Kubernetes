# ReplicaSets 

A **ReplicaSet** is a declarative statement of how many different pods of the same type that we want to run in the system at any given time. Since it maintains a stable set of replica Pods, it is often used to guarantee the availability of a specified number of identical Pods.

Note that we don't usually create the ReplicaSet but instead we create the Deployments and specify the number of containers that we want to run. You can verify this by checking a deployment:

```bash
$ kubectl edit deployment -n kube-system
```

To see the ReplicaSets running:

```bash
$ kubectl get rs -n kube-system 
```

To see the ReplicaSetsin a specific namespace, e.g. kube-system: 

```bash
$ kubectl get rs -n kube-system 
```

To learn more, check out [ReplicaSets in Kubernetes](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/).
