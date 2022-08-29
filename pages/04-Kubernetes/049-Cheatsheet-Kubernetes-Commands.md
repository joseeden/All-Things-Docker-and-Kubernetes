
# Cheatsheet: Kubernetes Commands

Command | Description
---------|----------
| <code> kubectl get pod </code> | Get information about all running pods
| <code> kubectl describe pod <pod> </code> | Describe one pod
| <code> kubectl expose pod <pod> --port=444 --name=frontend </code> | Expose the port of a pod (creates a new service)
| <code> kubectl port-forward <pod> 8080 </code> | Port forward the exposed pod port to your local machine
| <code> kubectl attach <podname> -i </code> | Attach to the pod
| <code> kubectl exec <pod> -- command </code> | Execute a command on the pod
| <code> kubectl label pods <pod> mylabel=awesome </code> | Add a new label to a pod
| <code> kubectl run -i --tty busybox --image=busybox --restart=Never -- sh </code> | Run a shell in a pod - very useful for debugging
| <code> kubectl get deployments </code> | Get information on current deployments
| <code> kubectl get rs </code> | Get information about the replica sets
| <code> kubectl get pods --show-labels </code> | get pods, and also show labels attached to those pods
| <code> kubectl rollout status deployment/helloworld-deployment </code> | Get deployment status
| <code> kubectl set image deployment/helloworld-deployment k8s-demo=k8s-demo </code> |2 </code> | Run k8s-demo with the image label version 2
| <code> kubectl edit deployment/helloworld-deployment </code> | Edit the deployment object
| <code> kubectl rollout status deployment/helloworld-deployment </code> | Get the status of the rollout
| <code> kubectl rollout history deployment/helloworld-deployment </code> | Get the rollout history
| <code> kubectl rollout undo deployment/helloworld-deployment </code> | Rollback to previous version
| <code> kubectl rollout undo deployment/helloworld-deployment --to-revision=n </code> | Rollback to any version version
