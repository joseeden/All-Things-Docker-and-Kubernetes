
# Services 

A Service enables network access to Pods in a Kubernetes cluster. When a network request is made to the service, it checks the labels and then select the Pods tagged with those labels.



TODO:
- study services in kubernetes 


To get the services in all the namespaces:

```bash
$ kubectl get svc -A  
```

In the example above, we see two services which are always deployed when we create EKS clusters:

- **kubernetes** - allows the users to communicate to the cluster nodes
- **kube-dns** - talks to the different Pods


