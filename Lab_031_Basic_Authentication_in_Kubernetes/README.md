# Lab 31: Basic Authentication in Kubernetes_OBSOLETE

> *This approach is deprecated in Kubernetes version 1.19*
> *The current version as of 2023 is Kubernetes version 1.25*

Pre-requisites

- [Basic Understanding of Kubernetes](../README.md#kubernetes)
- [AWS account](../pages/01-Pre-requisites/labs-optional-tools/README.md#create-an-aws-account)
- [AWS IAM Requirements](../pages/01-Pre-requisites/labs-optional-tools/01-AWS-IAM-requirements.md)
- [AWS CLI, kubectl, and eksctl](../pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md#install-cli-tools) 

Sections:

- [Introduction](#introduction)
- [Setup Kubernetes cluster using kubeadm](#setup-kubernetes-cluster-using-kubeadm)
- [Setup Basic Authentication](#setup-basic-authentication)
- [Cleanup](#cleanup)


## Introduction

The goals for this lab are:

- Create a password file and pass it to the kube-apiserver
- Configure kube-apiserver to include the basic-auth file during startup
- Create the role and rolebindings for the users in the password file
- Authenticate to the cluster using the user credentials

Note that this is intended for lab purposes only.
**THIS IS NOT RECOMMENDED FOR PRODUCTION**

## Setup Kubernetes cluster using kubeadm 

In this lab, we'll be using three EC2 instances bootstrapped with the kubeadm tool which will allow us to easily manage the Kubernetes cluster. Check out [Creating and Managing Kubernetes Clusters using kubeadm](../Lab_020_Create_and_Manage_Cluster_using_kubeadm/README.md).

![](../Images/lab20ec2instances.png)  

The **instance-a** serves as the master node while the other two instances are worker nodes. We can also see this when we run the **kubectl** in the master node.

```bash
$ kubectl get nodes
NAME            STATUS     ROLES           AGE   VERSION
ip-10-0-0-10    Ready      <none>          23m   v1.26.3
ip-10-0-0-11    Ready      <none>          14s   v1.26.3  
ip-10-0-0-100   Ready      control-plane   25m   v1.26.3
```

## Setup Basic Authentication 

Create the **user-details.csv** at /tmp/users.

```csv
password123,user1,u0001
password123,user2,u0002
password123,user3,u0003
password123,user4,u0004
password123,user5,u0005  
```

Create the **pod-reader.yml** roles and rolebindings.

```yaml
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]

---
# This role binding allows "jane" to read pods in the "default" namespace.
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: user1 # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role #this must be Role or ClusterRole
  name: pod-reader # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io  
```

```bash
kubectl apply -f  pod-reader.yml
```

Modify the **/etc/kubernetes/manifests/kube-apiserver.yaml** to pass the user details to the kube-apiserver and include the basic-auth-file during startup.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: kube-apiserver
  namespace: kube-system
spec:
  volumes:
  - hostPath:
      path: /tmp/users
      type: DirectoryOrCreate
    name: user-details  
    <...............content-hidden...............>

  containers:
  - name: kube-apiserver
    image: k8s.gcr.io/kube-apiserver-amd64:v1.11.3
    <...............content-hidden...............>

    volumeMounts:
    - mountPath: /tmp/users
      name: user-details
      readOnly: true
    <...............content-hidden...............>

    command:
    - kube-apiserver
    - --authorization-mode=Node,RBAC
    - --basic-auth-file=/tmp/users/user-details.csv
    <...............content-hidden...............>
```

To verify, try authenticating into the kube-apiserver using the user's credentials.

```bash
curl -v -k https://localhost:6443/api/v1/pods -u "user1:password123"
```

**NOTE**

You may encounter an error trying to enforce basic auth. Please see [Clusters built with kubeadm don't support basic auth](https://github.com/kubernetes/kubeadm/issues/23)


## Cleanup 

Since we're using a Kubernetes cluster set on top of three EC2 instances, the resources can be deleted by simply deleting the instances through the AWS Management Console.

## Resources 

- [Clusters built with kubeadm don't support basic auth](https://github.com/kubernetes/kubeadm/issues/23)

- [Setting up Basic Authentication for Kubernetes Cluster on Minikube](https://techexpertise.medium.com/setting-up-basic-authentication-for-kubernetes-cluster-on-minikube-1-e84e1b56c64)

- [Passing extra config to apiserver to enable basic auth](https://github.com/kubernetes-sigs/kind/issues/1507)

- [Kubernetes simple authentication](https://stackoverflow.com/questions/35942193/kubernetes-simple-authentication)
