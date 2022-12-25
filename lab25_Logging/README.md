# Lab 24: Service Accounts


Before we begin, make sure you've setup the following pre-requisites

- [Basic Understanding of Kubernetes](../README.md#kubernetes)
- [AWS account](../pages/01-Pre-requisites/labs-optional-tools/README.md#create-an-aws-account)
- [AWS IAM Requirements](../pages/01-Pre-requisites/labs-optional-tools/01-AWS-IAM-requirements.md)
- [AWS CLI, kubectl, and eksctl](../pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md#install-cli-tools) 

Here's a breakdown of the sections for this lab.

- [Introduction](#introduction)
- [Launch a Simple EKS Cluster](#launch-a-simple-eks-cluster)
- [default ServiceAccount](#default-serviceaccount)
- [Using the default ServiceAccount](#using-the-default-serviceaccount)
- [Using a Custom ServiceAccount](#using-a-custom-serviceaccount)
- [Cleanup](#cleanup)
- [Resources](#resources)


## Introduction

In this lab, we'll create service accounts to define identities for our Pods. Kubernetes uses role-based access control (RBAC) to create roles that grant access to APIs and then bind those roles to **ServiceAccounts**.

## Launch a Simple EKS Cluster

Before we start, let's first verify if we're using the correct IAM user's access keys. This should be the user we created from the **pre-requisites** section above.

```bash
$ aws sts get-caller-identity 
```
```bash
{
    "UserId": "AIDxxxxxxxxxxxxxx",
    "Account": "1234567890",
    "Arn": "arn:aws:iam::1234567890:user/k8s-admin"
} 
```

For the cluster, we can reuse the **eksops.yml** file from the other labs.

<details><summary> eksops.yml </summary>
 
```bash
apiVersion: eksctl.io/v1alpha5
# apiVersion: client.authentication.k8s.io/v1beta1
kind: ClusterConfig

metadata:
    version: "1.23"
    name: eksops
    region: ap-southeast-1 
nodeGroups:
    -   name: ng-dover
        instanceType: t3.large
        minSize: 1
        maxSize: 5
        desiredCapacity: 3
        ssh: 
            publicKeyName: "k8s-kp"
```
 
</details>

Launch the cluster.

```bash
time eksctl create cluster -f eksops.yml 
```

Check the nodes.

```bash
kubectl get nodes 
```

Save the cluster, region, and AWS account ID in a variable. We'll be using these in a lot of the commands later.

```bash
MYREGION=ap-southeast-1
MYCLUSTER=eksops 
MYAWSID=$(aws sts get-caller-identity | python3 -c "import sys,json; print (json.load(sys.stdin)['Account'])")
```



## default ServiceAccount 

Run the get command to see the existing service accounts.

```bash
$ kubectl get serviceaccount -A | grep default
default                default                              0         137d
kube-node-lease        default                              0         137d
kube-public            default                              0         137d
kube-system            default                              0         137d
kubernetes-dashboard   default                              0         137d
```

Each Namespace has a **default** ServiceAccount. The default ServiceAccount grants minimal access to APIs and cannot be used to get any cluster state information. Therefore, you should use custom ServiceAccounts when your application requires access to cluster state.


## Using the default ServiceAccount 

Use the [pod-default-sa.yml](./pod-default-sa.yml) to create a Pod that uses the default service account. We'll also create a new namespace called "serviceaccounts". Notice that we don't need to specify a service account here.

```bash
apiVersion: v1
kind: Namespace
metadata:
  name: serviceaccounts
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-default-sa 
  namespace: serviceaccounts
spec:
  containers:
  - image: mongo:4.0.6
    name: mongodb
```


We could also see that the **spec.serviceAccount** is automatically set to the **default** ServiceAccount.

```bash
$ kubectl get pod pod-default-sa -n serviceaccounts -o yaml | grep 

serviceAccount
  serviceAccount: default
  serviceAccountName: default
      - serviceAccountToken:
```

## Using a Custom ServiceAccount 

It is a best practice to create a ServiceAccount for each applications to use the least amount of access necessary (principle of least privilege) to improve security. The created ServiceAccount will not have any specific role bound to it so there are no additional permissions associated with it. 

In practice, the  Kubernetes administrator creates a role and bind it to the ServiceAccount.

Let's create a custom ServiceAccount. 

```bash
kubectl create serviceaccount app-sa  
```

Use [pod-custom-sa.yml](./pod-custom-sa.yml) to create a new pod that uses the new service account. 

```bash
apiVersion: v1
kind: Pod
metadata:
  name: custom-sa-pod 
  namespace: serviceaccounts
spec:
  serviceAccount: app-sa
  containers:
  - image: mongo:4.0.6
    name: mongodb
```

We should now see two Pods running in our namespace.

```bash
$ kubectl get pods -n serviceaccounts 
NAME             READY   STATUS    RESTARTS   AGE
pod-default-sa   1/1     Running   0          11m 
pod-custom-sa    1/1     Running   0          3s 
```

## Cleanup 

Before we officially close this lab, make sure to destroy all resources to prevent incurring additional costs.

```bash
$ time eksctl delete cluster -f eksops.yml
```

Note that when you delete your cluster, make sure to double-check the AWS Console and ensure that the Cloudformation stacks (which we created by eksctl) are dropped cleanly.

## Resources

- Mastering Kubernetes Pod Configuration: Service Accounts