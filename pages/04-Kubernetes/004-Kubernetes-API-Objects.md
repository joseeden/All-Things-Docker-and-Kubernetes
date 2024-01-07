# Kubernetes API Objects

<p align=center>
<img src="../../Images/k8s-object.png">
</p>

## Pods 

A single or a collection of containers deployed as a single unit. From the standpoint of Kubernetes, this is the mmost basic unit of work.

- atomic unit of scheduling
- These are basically our container-based application
- When we define a pod, we also define the resources it needs
- **Ephemeral**, which means no pod is ever re-deployed, a new pod is always used
- **Atomicity**, which means pod is no longer available if a container inside it dies

Kubernetes handles the pod by managing the:

- **state** - is the pod running?
- **health** - is the application inside the pod running?
- **liveness probes** - are we getting the appropriate response back?

A Pod has 1 IP address:

- this means containers inside the Pod share the same IP address
- containers within the same Pod talk via localhost
- Pods coordinate ports


## Controllers

These keep the system in our desired state. 

- creates and manages Pods
- ensures the desired state is maintained
- responds to a Pod state and health

Controllers include the following:

- **ReplicaSet** - allows us to define the number of replicas for a Pod that we want to be running at all times

- **Deployment** - manages the transition between two ReplicaSets

There are a lot more controllers that Kubernetes offers and the two mentioned above are just some that are based on Pods.

## Services 

Services provide a persistent axis point to the applications provided by the pods. This basically add persistency based on the state of the system.

- networking abstraction for Pod access
- allocates IP and DNS name for the service
- redeployed Pods are automatically updated
- updates routing information to the Pods
- scales application by adding or removing Pods
- enables loadbalancing to distribute load across the Pods

Essentially, a virtual IP address,

- this virtual IP address is mapped to various Pods
- ensures that external services accessing the Pods only needs to know a single IP

## Storage

Storage objects serves as persistent storage to keep the data.

- **Volumes**, a storage backed by physical media which is tightly coupled to the Pods

- **Persistent Volume**, a Pod-independent storage defined at the cluster level using a *Persistent Volume Claim*

</details>



<br>

[Back to first page](../../README.md#kubernetes)
