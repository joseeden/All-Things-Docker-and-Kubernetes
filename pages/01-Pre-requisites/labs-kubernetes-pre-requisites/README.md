# Pre-requisites for Kubernetes Labs


- [Install Kubernetes on Ubuntu](#install-kubernetes-on-ubuntu)
- [Install CLI Tools](#install-cli-tools)
- [Install Helm](#install-helm)
- [Setup EKS Access on AWS](#setup-eks-access-on-aws)

----------------------------------------------

## Install Kubernetes on Ubuntu

This section discuss how to install Kubernetes on virtual machines and/or bare metal servers.

System Requirements:
- Linux OS
- 2 CPUs 
- 2 GB RAM 
- Disable Swap 

Container Runtime Requirements:

- Compatible with CRI (Container Runtime Interface)
- We can also use Docker 

Networking Requirements:
- Connectivity between all nodes 

Note that we have to install these packages on **ALL** the nodes that will be part of the Kubernetes cluster.

- kubelet
- kubeadm 
- kubectl 
- container runtime (docker)

Begin by installing the packages, which includes adding the signing key and the repository.

```bash
$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add 
$ sudo bash -c 'cat <<EOF >/etc/apt/sources.list.d/kubernetes.list 
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF'
```

We can inspect the versions available in the repository using apt-cache.

```bash
$ sudo apt-get update
```
```bash
$ apt-cache policy kubelet | head -20
$ apt-cache policy docker.io | head -20
```

Install the Kubernetes tools.
```bash
$ sudo apt-get install -y kubeadm kubelet kubectl docker.io 
$ sudo apt-mark hold kubeadm kubelet kubectl docker.io
```

Disable the swap.

```bash
$ swapoff -a  
```

Check the status of the kubelet and docker. Notice that kubelet will show an "activating" status. This will stay in this status until a work is assigned to the kubelet.

```bash
$ sudo systemctl status kubelet 
$ sudo systemctl status docker 
```


## Install CLI Tools

When you click the links, it should bring you to the official installation pages. Note that only the kubectl is necessary for running Kubernetes locally but I recommend installing the other CLI tools too. 

- [aws cli v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) - used by eksctl to grab authentication token
- [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html) - setup and operation of EKS cluster 
- [kubectl](https://kubernetes.io/docs/tasks/tools/) - interaction with K8S API server

If you're using **WSL running Ubuntu in a Windows laptop**, you may simply use these commands:

```bash
# aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```
```bash
# eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
```
```bash
# kubectl
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo apt-get install -y apt-transport-https
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```

To verify the AWS CLI version:

```bash
$ aws --version 
```

To verify the eksctl version:

```bash
$ eksctl version 
```

To verify the kubectl version:

```bash
$ kubectl version --output=json  
```

We can also enable eksctl bash completion:

```bash
eksctl completion bash >> ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion 
```

## Install Helm

Helm is the Kubernetes package manager which helps us manage Kubernetes applications. To learn more, visit the official [Helm website.](https://helm.sh/)

Helm can be installed in two ways:

- install it from a source, or 
- install it from pre-built binary releases

Detailed setup instructions for different OS can be found in the [Installing Helm](https://helm.sh/docs/intro/install/) page.

If you're using **WSL running Ubuntu in a Windows laptop**, you may simply use these commands:

```bash
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh 
```

## Setup EKS Access on AWS

This is needed if you're going to run Kubernetes using the Amazon EKS (Elastic Kubernetes Service).

Having said, I've added this under the **[Optional Tools](../labs-optional-tools/README.md)** page. 
