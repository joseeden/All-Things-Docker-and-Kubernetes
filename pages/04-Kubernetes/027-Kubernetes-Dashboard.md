
# Kubernetes Dashboard

A **Kubernetes Dashboard** is a general-purpose web UI for Kubernetes clusters which allows users to manage applications, troubleshoot issues, and manage the cluster itself. 

- displays information about workloads, Pods, Deployments, etc.
- displays resources in different namespaces
- shows details on Services, Nodes, and Storage
- shows usage metric (requires Heapster monitoring enabled)
- securely login using **HTTPs** or**Bearer token**
- authorization using **RBAC** for granular access rules

When we deploy the Kubernetes Dashboard, it will live in one of the Pods:

- Kubernetes dashboard with REST Endpoint, SSL, and authontication
- Metrics Add-on using **Heapster** to show usage metrics
= Metrics Add-on using **InfluxDB** to store metrics

To access the Kubernetes dashboard from our terminal,

```bash
$ kubectl proxy 
```

To see this in action, check out this [lab](../../lab55_EKS_K8s_Dashboard.md/README.md).

To learn more, check out the [official Kubernetes Dashboard Github](https://github.com/kubernetes/dashboard) page.
