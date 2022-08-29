# Pods

A **Pod** can be a single container or multiple containers that always run together. If you usually run single containers, you can think of a pod as a running container. This is the same concept whether you're running containers on-premise or on the cloud.

Kubernetes control plane software decides:

- when and where to run your pods
- how to manage traffic routing
- how to scales pods based on utilization or other metrics defined. 

In addition to this, Kubernetes also:
- automatically starts pods based on resource requirements
- automatically restarts pods if they or the instances they are running on fail
- gives an IP address and a single DNS name to each pod

To see the pods in the default namespace:

```bash
$ kubectl get pods  
```

To see the pods in all namespaces:

```bash
$ kubectl get pods -A  
```

To see the pods in a specific names, e.g. kube-system: 

```bash
$ kubectl get pods -n kube-system 
```

To get more information about the pod:

```bash
$ kubectl describe <pod-name> 
```

To see the logs of a particular pos: 

```bash
$ kubectl logs <pod-name> 
```

To learn more, check out [Pods in Kubernetes.](https://kubernetes.io/docs/concepts/workloads/pods/)
