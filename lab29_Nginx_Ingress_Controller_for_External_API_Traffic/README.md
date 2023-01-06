# Lab 29: Create Kubernetes Nginx Ingress Controller for External API Traffic

Before we begin, make sure you've setup the following pre-requisites

- [Basic Understanding of Kubernetes](../README.md#kubernetes)
- [AWS account](../pages/01-Pre-requisites/labs-optional-tools/README.md#create-an-aws-account)
- [AWS IAM Requirements](../pages/01-Pre-requisites/labs-optional-tools/01-AWS-IAM-requirements.md)
- [AWS CLI, kubectl, and eksctl](../pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md#install-cli-tools) 

Additional CLI utilities:

- [yq](https://github.com/mikefarah/yq) 
- [jq](https://stedolan.github.io/jq/download/)

Here's a breakdown of the sections for this lab.


  - [Introduction](#introduction)
  - [Lab Environment](#lab-environment)
  - [Install Cilium CNI](#install-cilium-cni)
  - [Install NGINX Ingress Controller](#install-nginx-ingress-controller)
  - [Allow internet inbound traffic](#allow-internet-inbound-traffic)
  - [Deploy the API Deployment and Service](#deploy-the-api-deployment-and-service)
  - [Deploy the API Ingress Resource](#deploy-the-api-ingress-resource)
  - [Perform end-to-end API Test](#perform-end-to-end-api-test)
  - [Cleanup](#cleanup)
  - [Resources](#resources)



## Introduction

Kubernetes provides superior container-orchestration, deployment, scaling, and management, making it the most suited platform for cloud-native applications.

In addition to deploying the applications, it is also important to be able to consume these Kubernetes-hosted servies from the outside. TO achieve this, we can use a Kubernetes resource called **Nginx Ingress Controller.** We can then secure the API traffic using Network policies.

We'll implement the network policies through **Cilium**. It is a Kubernetes CNI plugin for securing network connectivity to the API using Layer-7 (HTTP) rules.

Steps:
- Install Cilium CNI 
- Install NGINX Ingress Controller
- Deploy the API Deployment and Service resources
- Perform end-to-end API Test

## Lab Environment

The environment used here is an empty Kubernetes cluster managed through kubeadm. The cluster is using a single node EC2 instance in AWS. To setup the environment, check out [Using Minikube to Create a Cluster.](https://kubernetes.io/docs/tutorials/kubernetes-basics/create-cluster/cluster-intro/)

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

## Install NGINX Ingress Controller

To deploy the pre-requisite resources, we'll use [install-nginx-resources.0.32.0.yml](manifests/install-nginx-resources.0.32.0.yml). This will first create

```bash
$ kubectl apply -f install-nginx-resources.0.32.0.yml

namespace/ingress-nginx created
serviceaccount/ingress-nginx created
configmap/ingress-nginx-controller created
clusterrole.rbac.authorization.k8s.io/ingress-nginx created
clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx created
role.rbac.authorization.k8s.io/ingress-nginx created
rolebinding.rbac.authorization.k8s.io/ingress-nginx created
service/ingress-nginx-controller-admission created
service/ingress-nginx-controller created
deployment.apps/ingress-nginx-controller created
clusterrole.rbac.authorization.k8s.io/ingress-nginx-admission created
clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
job.batch/ingress-nginx-admission-create created
job.batch/ingress-nginx-admission-patch created
role.rbac.authorization.k8s.io/ingress-nginx-admission created
rolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
serviceaccount/ingress-nginx-admission created 
```

Check the status of the deployment.

```bash
$ kubectl get deploy ingress-nginx-controller -n ingress-nginx

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
ingress-nginx-controller   1/1     1            1           8m7s 
```

## Allow internet inbound traffic 

Since the YAML file we previously used contains all the NGINX Ingress Controller resources, we can generate a separate YAML file called [nginx-ingress-controller.yml](manifests/nginx-ingress-controller-v1.yml) which contains just the Deployment.

```bash
kubectl get deploy ingress-nginx-controller -n ingress-nginx -o yaml >> nginx-ingress-controller.yml 
```

Currently, inbound traffic to the Nginx Ingress controller is not allowed. To change this, we can perform a networking updated by adding the **spec.template.spec.hostNetwork true** property in the file.

There's two ways we can edit the file. We can directly edit the [nginx-ingress-controller.yml](manifests/nginx-ingress-controller-v1.yml), or we can also utilize a YAML processor called yq.

To install yq, check out the official [yq Github page](https://github.com/mikefarah/yq).

We've installed yq on our home directory. We need to make it executable.

```bash
chmod +x ~/yq 
```

Use the yq utility to inject the **hostNetwork: true** setting into the **nginx-ingress-controller.yml** file and then forward the new version to [nginx-ingress-controller-v2.yml](manifests/nginx-ingress-controller-v2.yml)

```bash
~/yq w nginx-ingress-controller.yaml spec.template.spec.hostNetwork true > nginx-ingress-controller-v2.yaml 
```

Replace the old deployment with the new deployment.

```bash
kubectl delete deploy ingress-nginx-controller -n ingress-nginx
kubectl apply -f nginx-ingress-controller-v2.yml 
```

ss

## Deploy the API Deployment and Service

We'll use [deploy-api.yaml](manifests/deploy-api.yaml) to deploy the custom API as a set of load balanced Pods.

```bash
kubectl apply -f deploy-api.yaml 
```

Note that these resources are deployed in the **default** namespace.

```bash
$ kubectl get all

NAME                      READY   STATUS    RESTARTS   AGE
pod/api-c49b694cc-jrhvr   1/1     Running   0          28s
pod/api-c49b694cc-ldwpr   1/1     Running   0          28s


NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
service/api          ClusterIP   10.98.31.43   <none>        8080/TCP   28s
service/kubernetes   ClusterIP   10.96.0.1     <none>        443/TCP    5m55s


NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/api   2/2     2            2           28s

NAME                            DESIRED   CURRENT   READY   AGE
replicaset.apps/api-c49b694cc   2         2         2       28s 
```

## Deploy the API Ingress Resource

Next, deploy the API Ingress using the [deploy-api-ingress.yaml](manifests/deploy-api-ingress.yaml) file. Before we apply any changes, we need to replace the "X.X.X.X" placeholder in the YAML file with the public IP address of the EC2 instance that the Kuberentes cluster is running on. Afterwarrds, run the file.

```bash
sed -i -e "s/X.X.X.X.nip.io/35.161.101.10.nip.io/g" deploy-api-ingress.yaml
```
```bash
kubectl apply -f deploy-api-ingress.yaml
```

Verify.

```bash
$ kubectl get ingress
NAME   HOSTS                      ADDRESS   PORTS   AGE
api    api.35.161.101.10.nip.io             80      53s
```

## Perform end-to-end API Test

To ensure that we can connect to the API from an external network, we can perform an end-to-end API test.

```bash
EXTIP=35.161.101.10
curl -s api.$EXTIP.nip.io/languages
```

It should return:

```bash
{"go":{"usecase":"system, web, server-side","rank":16,"compiled":true,"homepage":"https://golang.org","download":"https://golang.org/dl/","votes":0},"java":{"usecase":"system, web, server-side","rank":2,"compiled":true,"homepage":"https://www.java.com/en/","download":"https://www.java.com/en/download/","votes":0},"javascript":{"usecase":"web, frontend development","rank":1,"compiled":false,"homepage":"https://en.wikipedia.org/wiki/JavaScript","votes":0},"nodejs":{"usecase":"system, web, server-side","rank":30,"compiled":false,"homepage":"https://nodejs.org/en/","download":"https://nodejs.org/en/download/","votes":0}}
```

This request will resolve to API via the public IP address currently assigned to the Kubernetes cluster. We are connecting eternally to port 80, which our request will then be forwarded by the Ingress resource to the API service listerning on port 8080.

The response isn't very readable. We can format it using the [jq utility](https://stedolan.github.io/jq/download/) which we have also installed no our terminal.

```bash
$ curl -s api.$EXTIP.nip.io/languages | jq .

{
  "go": {
    "usecase": "system, web, server-side",
    "rank": 16,
    "compiled": true,
    "homepage": "https://golang.org",
    "download": "https://golang.org/dl/",
    "votes": 0
  },
  "java": {
    "usecase": "system, web, server-side",
    "rank": 2,
    "compiled": true,
    "homepage": "https://www.java.com/en/",
    "download": "https://www.java.com/en/download/",
    "votes": 0
  },
  "javascript": {
    "usecase": "web, frontend development",
    "rank": 1,
    "compiled": false,
    "homepage": "https://en.wikipedia.org/wiki/JavaScript",
    "votes": 0
  },
  "nodejs": {
    "usecase": "system, web, server-side",
    "rank": 30,
    "compiled": false,
    "homepage": "https://nodejs.org/en/",
    "download": "https://nodejs.org/en/download/",
    "votes": 0
  }
} 
```

## Cleanup 

The resources can be deleted by simply running a **delete** command on the *manifest* directory where the YAML files are located.

```bash
kubectl delete -f manifest 
```

We can also simply [delete the EC2 instance in the AWS Management Console](https://aws.amazon.com/premiumsupport/knowledge-center/delete-terminate-ec2/).

## Resources

- [Create Kubernetes Nginx Ingress Controller for External API Traffic](https://cloudacademy.com/lab/create-kubernetes-nginx-ingress-controller-external-api-traffic/?context_id=888&context_resource=lp)