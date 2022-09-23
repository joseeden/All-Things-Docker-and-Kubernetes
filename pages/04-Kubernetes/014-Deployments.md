
# Deployments 

Deployments represents multiple replicas of a pod. Manifests for deployments resembles Pod manifests since it uses the same fields.

- application scales by creating more replicas
- describe the desired state for the deployment
- Kubernetes manages the state
- when any changes are done on the resources, the deployment controller converges the actual state with the desired state

To see deployments in action, check out this [lab](../../lab43_Deployments/README.md).

To learn more about Deployments and StatefulSets using Persistent Volumes in AWS, check out [Amazon EKS - Persistent Volumes](pages/04-Kubernetes/056-EKS-Persistent-Volumes.md) page.

