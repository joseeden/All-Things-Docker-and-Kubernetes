
# Services 

A Service defines the networking rules for accessing Pods in a Kubernetes cluster. When a network request is made to the service, it checks the labels and then select the Pods tagged with those labels.

- declare a service to access a group of Pods based on *labels*
- clients can access the service through a fixed IP address
- the service distributed the incoming requests across the pods

To get the services in all the namespaces:

```bash
$ kubectl get svc -A  
```

In the example above, we see two services which are always deployed when we create EKS clusters:

- **kubernetes** - allows the users to communicate to the cluster nodes
- **kube-dns** - talks to the different Pods

To learn more, check out this [hands-on lab.](../../lab40-Kubernetes_Basics/README.md)


