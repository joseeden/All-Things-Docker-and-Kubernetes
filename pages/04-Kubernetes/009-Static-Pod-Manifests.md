# Static Pod Manifests 

A **Static Pod Manifest** describes the configuration of a Pod. These are **generated by the kubeadm init** for the cluster components that it needs to bootsrap:

- etcd 
- API server
- Controller anager
- Scheduler

The **kubelet** then monitors the manifests directory and starts up Pods that are described in those manifests.

This enables the core cluster components to start without the cluster

These statis pod manifests are stored in <code>/etc/kubrnetes/manifests</code>