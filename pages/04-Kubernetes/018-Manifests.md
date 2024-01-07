
# Manifests 

A **Manifest** contains all the properties that we can define different Kubernetes resources.  We can describe all the resource-specific attribute using **spec** or specification in the manifest file.

**How Manifests Works**

1. We can run <code>kubectl create</code> to create the Kubernetes resources using the manifest.
2. kubectl sends the manifest to Kubernetes API server.
3. API server does the following actions:

    - Select the node with sufficient resources
    - Schedule Pod onto that node 
    - The node pull down the Pod's container image
    - The node starts the Pod's containers

Here's a sample manifest file that creates a basic NGINX Pod.

```bash
apiVersion: v1 
kind: Pod
metadata:
    name: pod-nginx
spec:
    containers:
    - name: container-nginx-1
      image: nginx:latest
```

Every manifest has the same set of top-level properties:

- **apiVersion** - usually v1, which is core API version
- **kind** - indicates the resource to be created
- **metadata** - details about the resource
- **spec** - specifications of the declared resource



<br>

[Back to first page](../../README.md#kubernetes)
