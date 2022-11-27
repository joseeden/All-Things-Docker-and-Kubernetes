
# Special Topics in Scheduling Pods 

- [Static Pods](#static-pods)
- [Container Resource Requirements](#container-resource-requirements)

## Static Pods 

Static pods are pods that are managed directly by the nodes kubelet and not through the Kubernetes' API server. This means that static pods are not scheduled by the Kubernetes scheduler and instead are always scheduled onto the node by the kubelet. 

To learn more, check out [Static Pods.](./009-Static-Pod-Manifests.md)

## Container Resource Requirements

We can set resource requirements for the container by defining them in the Pod spec. The compute resources that Kubernetes includes built-in support for are:

- CPU, measured in cores, and 
- memory, measured in bytes

Although the compute resource requests and limits are optional, the Kubernetes scheduler can make better decisions about which node to schedule a Pod on if it knows the Pod's resource requirement. 

The scheduler will only schedule a Pod on a node if the node has enough resources available to satisfy the Pod's total request, which is the sum of the Pod's containers' **requests**. 

**Limits** also reduce resource contention on a node and can make performance more predictable.

To understand better, we can see the official description for the requirements by using the **explain** command.

```bash
$ kubectl explain pod.spec.containers.resources
KIND:     Pod
VERSION:  v1

RESOURCE: resources <Object>

DESCRIPTION:
     Compute Resources required by this container. Cannot be updated. More info:
     https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

     ResourceRequirements describes the compute resource requirements.

FIELDS:
   limits       <map[string]string>
     Limits describes the maximum amount of compute resources allowed. More
     info:
     https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

   requests     <map[string]string>
     Requests describes the minimum amount of compute resources required. If
     Requests is omitted for a container, it defaults to Limits if that is
     explicitly specified, otherwise to an implementation-defined value. More
     info:
     https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
 
```

To see resource requirements in action, check out this [lab](../../lab21-Resource_Requirements/README.md).
