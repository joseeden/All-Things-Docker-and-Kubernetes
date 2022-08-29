# Installation Options

- [Ways to Setup Kubernetes](#ways-to-setup-kubernetes)
- [Which is the Right Solution?](#which-is-the-right-solution)
- [Create a Cluster using kubeadm](#create-a-cluster-using-kubeadm)


> *The rest of succeeding sections is focused on on-premise implementation of Kubernetes.*
>
> *If you prefer to use cloud platforms such as AWS to run Kubernetes, you may jump to the **Kubernetes in the Cloud** section.*

## Ways to Setup Kubernetes

There are multiple ways to setup a kubernetes cluster. 

- A local cluster (on your machine)
- A production cluster on the cloud
- A on-prem, cloud-agnostic cluster
- A managed production cluster on AWS using EKS

There are available tools to automate bootstrapping clusters on on-premise and public cloud platforms.

For **production-grade cluster**:
- kubeadm
- Kubespray
- Kops
- K3s

For **development-grade cluster** (testing):
- minikube
- k3d

**k3s** is a lightweight version of kubernetes that can be installed using one binary.

- operational 1-node cluster
- instals **kubectl** - CLI tool

Here are some ways to run Kubernetes on your local machine.

- Minikube
- Docker Desktop
- kind
- kubeadm


## Which is the Right Solution?

Before we start running Kubernetes, we must review some considerations. 

**Where to install?**

- **Cloud**
    Kubernetes is a cloud-native tool and we could leverage the available services from cloud platforms.

    - Using virtual machines (IaaS)
    - Using managed service (PaaS)

- **On-prem**
    - Bare metal
    - VirtuaL machines 

**Which one should we choose?**

- it all depends on the strategy of the organization
- depends on the skillset and expertise of people in the organization

**We've decided where to run Kubernetes, what's next?**

- Cluster Networking 
- Scalability
- High Availability 
- Disaster Recovery

Checkout these resources to learn more about installation considerations:

- [Picking the Right Solution](https://jamesdefabia.github.io/docs/getting-started-guides/)

- [Getting started](https://kubernetes.io/docs/setup/)


After installing the Kubernetes packages, the next steps are:

1. Create the cluster (specifically the master node)
2. Disable the swap space on the nodes.
3. Configure Pod networking
4. Join additional nodes to our cluster


## Create a Cluster using kubeadm

Before we can provision a cluster, we must ensure that the control plane and data plane is up and running, which is known as **bootstraping the cluster**. 

This can be done manually but there's a risk for misconfiguration since we would need to run independent components separately.

We'll use kubeadm to create our cluster. The phases include:

1. We'll run <code>kubeadm init</code>.
2. kubeadm does **pre-flight checks** which ensure the appropraite permissions and system resources are in place.
3. kubeadm creates a **certificate authority** for authentication and encryption.
4. kubeadm generates **kubeconfig files** for authenticating the components against the API server.
5. kubeadm generates **Static Pod Manifests** which are monitored by the kubelet.
6. kubeadm starts up the control plane.
7. kubeadm taints the master, ensuring pods are only scheduled on worker nodes.
8. kubeadm generates a **Bootstrap Token** for joining nodes to the cluster.
9. kubeadm starts **Add-on Pods: DNS and kube-proxy**

Note that the process defined above can be customized by specifying parameters.
