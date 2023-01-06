# Lab 20: Create and Manage a Kubernetes Cluster using kubeadm


Before we begin, make sure you've setup the following pre-requisites

- [Basic Understanding of Kubernetes](../README.md#kubernetes)
- [AWS account](../pages/01-Pre-requisites/labs-optional-tools/README.md#create-an-aws-account)
- [AWS IAM Requirements](../pages/01-Pre-requisites/labs-optional-tools/01-AWS-IAM-requirements.md)
- [AWS CLI, kubectl, and eksctl](../pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md#install-cli-tools) 


Here's a breakdown of the sections for this lab.

- [Introduction](#introduction)
- [Install the Container Runtime](#install-the-container-runtime)
- [Intsall kubeadm and its dependencies](#intsall-kubeadm-and-its-dependencies)
- [Repeat the same steps for the other instances](#repeat-the-same-steps-for-the-other-instances)
- [No default network plugin](#no-default-network-plugin)
- [Initialize the Master Node](#initialize-the-master-node)
- [Create the Calico Plugin](#create-the-calico-plugin)
- [Join the Worker Nodes](#join-the-worker-nodes)
- [Create a simple deployment](#create-a-simple-deployment)
- [Resources](#resources)


## Introduction

In this lab, we'll be using three EC2 instances to create a Kubernetes cluster. We'll also be installing the **kubeadm** tool which will allow us to easily manage the Kubernetes cluster.

Start with creating the EC2 instances (running Ubuntu 18.04) in the same VPC, region, and availability zone. Refer to the [AWS Documentation](https://docs.aws.amazon.com/efs/latest/ug/gs-step-one-create-ec2-resources.html) on how to launch the instances.

![](../Images/lab20ec2instances.png)  

## Install the Container Runtime

The basic requirement for a Kubernetes cluster is a container runtime. Here are the available container runtimes:

- containerd
- CRI-O
- dockerd 


For our setup, we'll use containerd.

Connect to the first EC2 instance and run the following command to update the package manager and packages required for **containerd**.

```bash
# Update the package index
sudo apt-get update
# Update packages required for HTTPS package repository access
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release
```

Next, allow forwarding IPv4 by loading the br_netfilter module.

```bash
# Load br_netfilter module
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
```

We'll also need to allow the Linux node's iptables to correctly view bridged traffic.

```bash
# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
# Apply sysctl params without reboot
sudo sysctl --system
```

Install containerd using the DEB package distributed by Docker. Note that there are [other ways of installing containerd](https://github.com/containerd/containerd/blob/main/docs/getting-started.md).

```bash
# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# Set up the repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# Install containerd
sudo apt-get update
sudo apt-get install -y containerd.io=1.4.4-1
```

Next, we need to mitigate the [instability of having two cgroup managers](https://kubernetes.io/docs/setup/production-environment/container-runtimes/) by configuring the systemd cgroup driver.

```bash
# Configure the systemd cgroup driver
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/ \[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options\]/          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]\n            SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd 
```

## Install kubeadm and its dependencies

Install kubeadm, kubectl, and kubelet from the official Kubernetes package repository.

```bash
# Add the Google Cloud packages GPG key
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
# Add the Kubernetes release repository
sudo add-apt-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
# Update the package index to include the Kubernetes repository
sudo apt-get update
# Install the packages
sudo apt-get install -y kubeadm=1.24.3-00 kubelet=1.24.3-00 kubectl=1.24.3-00
```

Optionally, we can prevent the automatic updates to the packages to ensure we'll use the same version throughout the succeeding labs. 

```bash
sudo apt-mark hold kubelet kubeadm kubectl
```

To verify if everything is successfully installed, run **kubeadm**. This should display the help page for kubeadm.

```bash
$ kubeadm


    ┌──────────────────────────────────────────────────────────┐
    │ KUBEADM                                                  │
    │ Easily bootstrap a secure Kubernetes cluster             │
    │                                                          │
    │ Please give us feedback at:                              │
    │ https://github.com/kubernetes/kubeadm/issues             │
    └──────────────────────────────────────────────────────────┘

Example usage:

    Create a two-machine cluster with one control-plane node
    (which controls the cluster), and one worker node
    (where your workloads, like Pods and Deployments run).

    ┌──────────────────────────────────────────────────────────┐
    │ On the first machine:                                    │
    ├──────────────────────────────────────────────────────────┤
    │ control-plane# kubeadm init                              │
    └──────────────────────────────────────────────────────────┘

    ┌──────────────────────────────────────────────────────────┐
    │ On the second machine:                                   │
    ├──────────────────────────────────────────────────────────┤
    �� worker# kubeadm join <arguments-returned-from-init>      │
    └──────────────────────────────────────────────────────────┘

    You can then repeat the second step on as many other machines as you like.

Usage:
  kubeadm [command] 
```

## Repeat the same steps for the other instances 

We've only installed the container runtime and kubeadm on one instance. We need to perform the same series of steps on the other two instances that will join the Kubernetes cluster later.

## No default network plugin 

Note that kubeadm does not install a default network plugin. In this lab, we'll use **Calico** as our pod network plugin later. Calico supports Kubernetes network policies. 

For network policies to function properly, we can use the option below to specify a range of IP addresses for the pod network when initializing the control-plane node with kubeadm. 

```bash
--pod-network-cidr option 
```

Calico is used primarily because it is production-ready. However, you may also consider [Amazon VPC network plugin](https://github.com/aws/amazon-vpc-cni-k8s) for environments that reside in AWS.

## Initialize the Master Node 

Now that we have installed all the necessary packages on all three nodes, the next step is to initialize the control plane node using kubeadm. During the initialization process, the following steps are performed:

- a certificate authority is created  for secure cluster communication and authentication
- all the node components, control plane componenents, and add-ons are started

This process can be customized to suit your requirements, such as providing your own CA, external etcd key-value store, or the network plugin.

Initialize the control-plane node using the init command. The CIDR block we specified is the default one used by Calico. This command will output the whole initialization process.

```bash
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --kubernetes-version=stable-1.24
```

At the end of the output, you should see the **kubeadm join** command. Copy this. The tokens expire after 24 hours by default.

```bash
kubeadm join 10.0.0.100:6443 --token 3h6x2f.m8r3elyvooi8tl1q \
        --discovery-token-ca-cert-hash sha256:6476277c4a9ed3a2b0ddbc67aa485082af9d5165727e40bdf2222be7fefa0468 
```

We need to initialize our user's kubeconfig file.

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Confirm that the kubeconfig file is setup correctly by listing the status of the Kubernetes components. If the Kubernetes API server is working, then all components should return a "Healthy" status. Otherwise, it will return an error saying its attempting to connect to an API server.

```bash
$ kubectl get componentstatuses
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE                         ERROR
controller-manager   Healthy   ok                              
scheduler            Healthy   ok                              
etcd-0               Healthy   {"health":"true","reason":""} 
```

Lastly, get the nodes. Notice the status says **NotReady**. We can see more details on the node by running the **describe** command.

```bash
$ kubectl get nodes
NAME            STATUS     ROLES           AGE    VERSION
ip-10-0-0-100   NotReady   control-plane   4m1s   v1.24.3
```

We can see the **KubeletNotReady** status and the reason for it. The error basically refers to the [container network interface](https://github.com/containernetworking/cni) which implements the network plugins is missing. This is where we'll use the Calico Network plugin.

```bash
$ kubectl describe nodes | grep Conditions -A 2
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----             ------  -----------------                 ------------------                ------                       -------
ubuntu@ip-10-0-0-100:~$ 
ubuntu@ip-10-0-0-100:~$ kubectl describe nodes | grep Conditions -A 10
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----             ------  -----------------                 ------------------                ------                       -------
  MemoryPressure   False   Sun, 27 Nov 2022 08:40:39 +0000   Sun, 27 Nov 2022 08:40:23 +0000   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   Sun, 27 Nov 2022 08:40:39 +0000   Sun, 27 Nov 2022 08:40:23 +0000   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   Sun, 27 Nov 2022 08:40:39 +0000   Sun, 27 Nov 2022 08:40:23 +0000   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            False   Sun, 27 Nov 2022 08:40:39 +0000   Sun, 27 Nov 2022 08:40:23 +0000   KubeletNotReady              container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:Network plugin returns error: cni plugin not initialized
Addresses:
  InternalIP:  10.0.0.100
  Hostname:    ip-10-0-0-100 
```

## Create the Calico Plugin

Run the command below to create the Calico network plugin. This will output the list of resources created to support the pod networking. The Calico node pod will run on each node in the cluster.

```bash
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yamlkubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

The node should now show as **Ready.**

```bash
$ kubectl get nodes
NAME            STATUS   ROLES           AGE   VERSION
ip-10-0-0-100   Ready    control-plane   11m   v1.24.3
```

## Join the Worker Nodes 

The next step is to add the worker nodes to the cluster using kubeadm. Connect to the second instance, **instance-b** and simply run the command we copied in the previous step.

```bash
sudo kubeadm join 10.0.0.100:6443 --token 3h6x2f.m8r3elyvooi8tl1q \
        --discovery-token-ca-cert-hash sha256:6476277c4a9ed3a2b0ddbc67aa485082af9d5165727e40bdf2222be7fefa0468 
```

Connect to **instance-c** and run the same command.
Once that's done, return to **instance-a** terminal and check the nodes. We should now see three nodes in the cluster. Note that it may take awhile for the pod statuses to change to **Ready**.

```bash
$ kubectl get nodes
NAME            STATUS   ROLES           AGE     VERSION
ip-10-0-0-10    Ready    <none>          4m14s   v1.24.3
ip-10-0-0-100   Ready    control-plane   24m     v1.24.3
ip-10-0-0-11    Ready    <none>          114s    v1.24.3
```

## Create a Simple Deployment

Back in the **instance-a** terminal, create a simple NGINX deployment with 2 replicas. We'll use this later to confirm that the deployment still exists after we restore the cluster.

```bash
kubectl create deployment nginx --image=nginx
kubectl scale deployment nginx --replicas=2
```

Expose the deployment using a ClusterIP service.

```bash
kubectl expose deployment nginx --type=ClusterIP --port=80 --target-port=80 --name=web
```

Confirm that the service is created.

```bash
$ kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP   28m
web          ClusterIP   10.107.142.62   <none>        80/TCP    17s
```

Next, check if the NGINX is running by sending an HTTP request to it.

```bash
# Get the Cluster IP of the service
service_ip=$(kubectl get service web -o jsonpath='{.spec.clusterIP}')
# Use curl to send an HTTP request to the service
curl -I $service_ip 
```

It sould return a **200 OK** response.

```bash
HTTP/1.1 200 OK
Server: nginx/1.23.2
Date: Sun, 27 Nov 2022 09:10:36 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Wed, 19 Oct 2022 07:56:21 GMT
Connection: keep-alive
ETag: "634fada5-267"
Accept-Ranges: bytes
```

## Next Step 

Now that we have a working Kubernetes cluster, proceed to the [next lab](../lab21_Backup_Restore_and_Upgrade_a_Kubernetes_Cluster/README.md) to simulate a cluster failure and restore the cluster to its original state using a backup.

## Resources

- [Create and Manage a Kubernetes Cluster from Scratch](https://cloudacademy.com/lab/create-manage-kubernetes-cluster-scratch/?context_resource=lp&context_id=888) 