# Scaling

Scaling in Kubernetes is done using the **Replication Controller.**

- ensures specified number of replicas ran at all times 
- pods are automatically replaced if they fail, get deleted, or are terminated
- recommended to use even if you're only running 1 pod to ensure pod is always running