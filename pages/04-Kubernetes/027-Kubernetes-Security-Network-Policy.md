
# Network Policy 


- [Network Policies netpol](#network-policies-netpol)
- [Components](#components)
- [Sample Scenario](#sample-scenario)
- [Network Policy Support](#network-policy-support)


## Network Policies (netpol)

In Kubernetes, Network Policies are a way to control the communication between pods within a cluster. They allow you to define rules that specify how groups of pods are allowed or denied communication with each other. 

Network Policies help enforce security and isolation within a Kubernetes cluster by controlling the flow of traffic between pods.

## Components 

**Selector Labels**

- Network Policies use label selectors to identify groups of pods. Rules are then applied to these selected pods.

**Ingress and Egress Rules**

- Network Policies define both ingress (incoming) and egress (outgoing) rules for traffic.
- Ingress rules control incoming traffic to the selected pods.
- Egress rules control outgoing traffic from the selected pods.

**Default Deny**

- By default, Network Policies follow a "deny-all" approach, meaning that all communication between pods is denied unless explicitly allowed by policies.

**Namespaces**

- Network Policies are applied at the namespace level. Policies are scoped to a specific namespace, and they only affect pods within that namespace.

## Sample Scenario 

Consider a scenario where you have a frontend application and a backend database in the same Kubernetes cluster. You want to restrict communication so that only the frontend pods can access the backend database, and other pods are not allowed to communicate with the database.

Here's an example Network Policy for achieving this:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: my-namespace
spec:
  podSelector:
    matchLabels:
      app: frontend
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
```

To apply the Network Policy to the cluster:

```bash
kubectl apply -f network-policy.yaml
```

## Network Policy Support

Network Policies are enforced by the network solution implemented on the Kubernetes cluster. Some network solutions that support network policies:

- Kube-router 
- Calico 
- Romana
- Weave-net 

The following does not support Network Policies:

- Flannel 



<br>

[Back to first page](../../README.md#kubernetes-security)
