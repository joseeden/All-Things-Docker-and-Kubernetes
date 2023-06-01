# Lab 29: Create Layer-7 Network Policies using Cilium CNI

Before we begin, make sure you've setup the following pre-requisites

- [Basic Understanding of Kubernetes](../README.md#kubernetes)
- [AWS account](../pages/01-Pre-requisites/labs-optional-tools/README.md#create-an-aws-account)
- [AWS IAM Requirements](../pages/01-Pre-requisites/labs-optional-tools/01-AWS-IAM-requirements.md)
- [AWS CLI, kubectl, and eksctl](../pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md#install-cli-tools) 

Here's a breakdown of the sections for this lab.

- [Introduction](#introduction)
- [Setup kubeadm and kubectl](#setup-kubeadm-and-kubectl)
- [Install Cilium CNI](#install-cilium-cni)
- [Star Wars API Pods](#star-wars-api-pods)
- [Secure the API with Layer-7 Network Policy](#secure-the-api-with-layer-7-network-policy)
- [Verify](#verify)
- [Cleanup](#cleanup)
- [Resources](#resources)


## Introduction

In this lab, we'll install Cilium CNI into our Kubernetes cluster. Cilium is an open source software for providing, securing and observing network connectivity between container workloads - cloud native, and fueled by the revolutionary Kernel technology eBPF.

Similar to Calico, Cilium can be installed as a Kubernetes CNI Plugin that provides an implementation of Container Networking Interface (CNI). We will use Cilium CNI to secure the network connectivity to the API using Layer-7 (HTTP) rules.

**How does a k8s cluster behave if you have no cni installed?**

With no CNI enabled, pods will actually get an IP address allocated. The cool thing is that we'll also be able to schedule pods with no CNI. There's  a special Kubernetes internal routing setup to allow for very simple bootstrapping of CNI installation. Without that we wouldn't be able to install a CNI via manifest. However, pod to pod communication would not work.

To learn more, check out the [Cilium official documentation.](https://docs.cilium.io/en/v1.9/gettingstarted/)

## Setup kubeadm and kubectl 

Start with creating one EC2 instance (running Ubuntu 18.04) in the AWS Management Console. Refer to the [AWS Documentation](https://docs.aws.amazon.com/efs/latest/ug/gs-step-one-create-ec2-resources.html) on how to launch the instances. 

Once you have the EC2 instance up and running, connect to the first EC2 instance and run the following command to update the package manager and packages required for **containerd**.

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
sudo sed -i 's/          \[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options\]/          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]\n            SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd 
```

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


Check the nodes.

```bash
kubectl get nodes 
```

## Install Cilium CNI 

Let's use [install-cilium.1.6.1.yml](manifests/install-cilium.1.6.1.yml) to create the resources.

```bash
$ kubectl apply -f install-cilium.1.6.1.yml

configmap/cilium-config created
serviceaccount/cilium created
serviceaccount/cilium-operator created
clusterrole.rbac.authorization.k8s.io/cilium created
clusterrole.rbac.authorization.k8s.io/cilium-operator created
clusterrolebinding.rbac.authorization.k8s.io/cilium created
clusterrolebinding.rbac.authorization.k8s.io/cilium-operator created
daemonset.apps/cilium created
deployment.apps/cilium-operator created
```

Retrieve the Cilium Pods:

```bash
$ watch kubectl get pods -n kube-system 

NAME                               READY   STATUS    RESTARTS   AGE
cilium-operator-5dd48645c4-s9ffr   1/1     Running   0          7m3s
cilium-qlml9                       1/1     Running   0          7m3s
coredns-5c98db65d4-qrr5c           1/1     Running   0          69m
coredns-5c98db65d4-t6p87           1/1     Running   0          69m
etcd-minikube                      1/1     Running   0          68m
kube-addon-manager-minikube        1/1     Running   0          68m
kube-apiserver-minikube            1/1     Running   0          68m
kube-controller-manager-minikube   1/1     Running   0          68m
kube-proxy-9cbz9                   1/1     Running   0          69m
kube-scheduler-minikube            1/1     Running   0          68m
storage-provisioner                1/1     Running   0          69m
```

## Star Wars API Pods 

We'll use [api-star-wars.yml](manifests/api-star-wars.ymlapi-star-wars.yml) to deploy a Star Wars themed API into our Kubernetes cluster. Run the manifest. It should return all the created resources.

```bash
$ kubectl apply -f api-star-wars.yml

service/deathstar created
deployment.apps/deathstar created
pod tiefighter created
pod/xwing created
```

Retrieve the Pods and Services to verify that they are running.

```bash
$ kubectl get pods

NAME                       READY   STATUS    RESTARTS   AGE
deathstar-d7d9cc8b-5nkpn   1/1     Running   0          26s
deathstar-d7d9cc8b-n9th4   1/1     Running   0          26s 
tiefighter                 1/1     Running   0          26s
xwing                      1/1     Running   0          26s
```
```bash
$ kubectl get services

NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
deathstar    ClusterIP   10.102.68.194   <none>        80/TCP    52s
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP   32m
```

#### How the Star Wars API works

The mechanics of this Star Wars API is that there are two factions involved, each with their own alliances:

**Galactic Empire**
- DeathStar
- TIEFighter

**Rebel Alliance**
- XWing

Below are the API traffic Rules:

- TIEFighters are allowed to request landing on the DeathStar
- XWings are not allowed to request landing on the DeathStar


---

Start with retrieving the DeathStar Service VIP assigned to the API. This is actually the IP of the Kubernetes Service that will distribute requests to the "deathstar" Pods.

```bash
$ kubectl get service/deathstar -o jsonpath='{.spec.clusterIP}'; echo

10.102.68.194
```

"Enter" the  "TIEFighter" Pod by running a shell onto the Pod. Then send a curl request from TIEFighter to the /v1 API service endpoint. This should display all of the available API endpoints.

```bash
$ kubectl exec -it tiefighter bash
bash-4.3#
bash-4.3# curl -is -XGET http://10.102.68.194/v1
HTTP/1.1 200 OK
Content-Type: text/plain
Date: Fri, 30 Dec 2022 10:54:55 GMT
Content-Length: 548

{
        "name": "Death Star",
        "model": "DS-1 Orbital Battle Station",
        "manufacturer": "Imperial Department of Military Research, Sienar Fleet Systems",
        "cost_in_credits": "1000000000000",
        "length": "120000",
        "crew": "342953",
        "passengers": "843342",
        "cargo_capacity": "1000000000000",
        "hyperdrive_rating": "4.0",
        "starship_class": "Deep Space Mobile Battlestation",
        "api": [
                "GET   /v1",
                "GET   /v1/healthz",
                "POST  /v1/request-landing",
                "PUT   /v1/cargobay",
                "GET   /v1/hyper-matter-reactor/status",
                "PUT   /v1/exhaust-port"
        ]
} 
```

From the TIEFighter Pod, send a curl request to the /v1/request-landing API service endpoint.

```bash
bash-4.3# curl -is -XPOST http://10.102.68.194/v1/request-landing
HTTP/1.1 200 OK
Content-Type: text/plain
Date: Fri, 30 Dec 2022 10:56:40 GMT
Content-Length: 12

Ship landed
```

As we can see, the curl request succeeded and the TIEFighter Pod was able to perform "landing" onto the Deathstar. From the Kubernetes's perspective, this means that the TIEFighter Pod is able to connect to the Deathstar Pod.

---

Let's now try to "board" the XWing and send the same curl request to the Deathstar. As we can see, the landing has also succeeded. We need to stop this!

```bash
$ kubectl exec -it xwing bash
bash-4.3#
bash-4.3# curl -is -XPOST http://10.102.68.194/v1/request-landing
HTTP/1.1 200 OK
Content-Type: text/plain
Date: Fri, 30 Dec 2022 11:05:02 GMT
Content-Length: 12

Ship landed 
```

## Secure the API with Layer-7 Network Policy

We'll use [api-network-policy.yml](manifests/api-network-policy.yml) to stop any unauthorized access to the DeathStar Pod.

```bash
kubectl apply -f api-network-policy.yml
```

Since we don't know the actual Kubernetes resource name for the network policies, we can do a quick search on the **api-resources**:

```bash
$ kubectl api-resources | grep cilium

ciliumendpoints                   cep,ciliumep   cilium.io                      true         CiliumEndpoint
ciliumidentities                  ciliumid       cilium.io                      false        CiliumIdentity
ciliumnetworkpolicies             cnp,ciliumnp   cilium.io                      true         CiliumNetworkPolicy
ciliumnodes                       cn             cilium.io                      false        CiliumNode
```

The deep dive on the network policies will be done on another lab, but for now, we can just see the details when we **describe** the resource. Here we can see the **Ingress** rules which specify the allowed endpoints that can connect and to which port and HTTP path.

```bash
$ kubectl describe cnp

Name:         rule1
Namespace:    default
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"cilium.io/v2","description":"L7 policy to restrict access to specific HTTP call","kind":"CiliumNetworkPolicy","metadata":{"...
API Version:  cilium.io/v2
Description:  L7 policy to restrict access to specific HTTP call
Kind:         CiliumNetworkPolicy
Metadata:
  Creation Timestamp:  2022-12-30T11:08:42Z
  Generation:          1
  Resource Version:    4652
  Self Link:           /apis/cilium.io/v2/namespaces/default/ciliumnetworkpolicies/rule1
  UID:                 8131a386-4446-4352-bced-9b3b9a8cc4c8
Spec:
  Endpoint Selector:
    Match Labels:
      Class:  deathstar
      Org:    empire
  Ingress:
    From Endpoints:
      Match Labels:
        Org:  empire
    To Ports:
      Ports:
        Port:      80
        Protocol:  TCP
      Rules:
        Http:
          Method:  POST
          Path:    /v1/request-landing
Status:
  Nodes:
    Minikube:
      Enforcing:              true
      Last Updated:           2022-12-30T11:08:42.981868248Z
      Local Policy Revision:  2
      Ok:                     true
Events:                       <none> 
```

## Verify 

Get the Service IP for the DeathStar Pod once again and "board" the XWing Pod. Next, try to send another request from the XWing to the DeathStar.

```bash
$ kubectl get services | grep deathstar

deathstar    ClusterIP   10.102.68.194   <none>        80/TCP    52s
```
```bash
$ kubectl get pods | grep xwing

xwing                      1/1     Running   0          26s
```
```bash
$ kubectl exec -it xwing bash
bash-4.3#
bash-4.3#
bash-4.3# curl -is -XPOST http://10.102.68.194/v1/request-landing


```

We can see that the connection from the XWing Pod to the DeathStar Pod has now been blocked, as it should be.

## Cleanup 

The resources can be deleted by simply running a **delete** command on the *manifest* directory where the YAML files are located.

```bash
kubectl delete -f manifest 
```

We can also simply [delete the EC2 instance in the AWS Management Console](https://aws.amazon.com/premiumsupport/knowledge-center/delete-terminate-ec2/).

## Resources

- [Create Kubernetes Layer-7 Network Policies using Cilium CNI](https://cloudacademy.com/lab/create-kubernetes-layer7-network-policies-using-cilium-cni/?context_id=888&context_resource=lp)

- [Kubernetes Network Plugins](https://kubedex.com/kubernetes-network-plugins/)