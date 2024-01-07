
# Kubernetes Commands

<!-- | <code> </code> |  -->

## Pods and Parameters

Pods | Description
---------|----------
| <code> kubectl completion --help </code> | To search for "enabling completion"
| <code> source <(kubectl completion bash) </code> | To enable completion for kubectl
| <code> kubectl api-resources </code> | To list out shortname for resources
| <code> kubectl get pods </code> | Get information about running pods in current namespace
| <code> kubectl describe pod <pod> </code> | Describe one pod
| <code> kubectl expose pod <pod> --port=444 --name=frontend </code> | Expose the port of a pod (creates a new service)
| <code> kubectl port-forward <pod> 8080 </code> | Port forward the exposed pod port to your local machine
| <code> kubectl attach <podname> -i </code> | Attach to the pod
| <code> kubectl exec <pod> -- command </code> | Execute a command on the pod
| <code> kubectl exec -it pod-name bash </code> | SSH onto the pod
| <code> kubectl label pods <pod> mylabel=awesome </code> | Add a new label to a pod
| <code> kubectl run -i --tty busybox --image=busybox --restart=Never -- sh </code> | Run a shell in a pod - very useful for debugging


Parameters | Description
---------|----------
| <code> --all-namespaces </code> | To display resource in all namespaces
| <code> -l  LABEL-NAME </code> | To filter for a specific LABEL-NAME
| <code> -l  LABEL-NAME1,LABEL-NAME2 </code> | For filtering pods that has specific label names
| <code> --sort-by=metadata.creationTimestamp </code> | To sort the Pods by age
| <code> --output=yaml </code> | To dusplay output in YAML format
| <code> --o yaml </code> | To dusplay output in YAML format, can also use JSON  
| <code> --wide </code> | To dusplay more information in the output
| <code> --show-labels </code> | show labels attached to those pods

## kubectl create vs. kubectl apply

kubectl create is what we call **Imperative Management**. On this approach you tell the Kubernetes API what you want to create, replace or delete, not how you want your K8s cluster world to look like.

Example: 

```bash
kubectl create deployment my-deployment --image=nginx
```

kubectl apply is part of the **Declarative Management** approach, where changes that you may have applied to a live object (i.e. through scale) are "maintained" even if you apply other changes to the object.

Example: 

```bash
kubectl apply -f my-manifest.yaml 
```

The main difference is that if the resource exists, kubectl create will error out and kubectl apply will not error out.

## Deployments 

Deployments | Description
---------|----------
| <code> kubectl get deployments </code> | Get information on current deployments
| <code> kubectl get rs </code> | Get information about the replica sets
| <code> kubectl rollout status deployment/helloworld-deployment </code> | Get deployment status
| <code> kubectl set image deployment/helloworld-deployment k8s-demo=k8s-demo </code> | Run k8s-demo with the image label version 2
| <code> kubectl edit deployment/helloworld-deployment </code> | Edit the deployment object
| <code> kubectl rollout status deployment/helloworld-deployment </code> | Get the status of the rollout
| <code> kubectl rollout history deployment/helloworld-deployment </code> | Get the rollout history
| <code> kubectl rollout undo deployment/helloworld-deployment </code> | Rollback to previous version
| <code> kubectl rollout undo deployment/helloworld-deployment --to-revision=n </code> | Rollback to any version version



<br>

[Back to first page](../../README.md#kubernetes)
