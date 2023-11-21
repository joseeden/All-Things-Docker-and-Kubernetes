# Lab 030: Building Highly-Available Kubernetes Cluster

> TODO


## Pre-requisites

- [Basic Understanding of Kubernetes](../README.md#kubernetes)
- [AWS account](../pages/01-Pre-requisites/labs-optional-tools/README.md#create-an-aws-account)
- [AWS IAM Requirements](../pages/01-Pre-requisites/labs-optional-tools/01-AWS-IAM-requirements.md)
- [AWS CLI, kubectl, and eksctl](../pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md#install-cli-tools) 

Additional CLI utilities:

- [yq](https://github.com/mikefarah/yq) 
- [jq](https://stedolan.github.io/jq/download/)

Here's a breakdown of the sections for this lab.




## Introduction


The main goals for this lab are:

- Build a highly available etc cluster 
- Bootstrap the HA Kubernetes cluster with kubeadm 
- Front the cluster with HAProxy loadbalancer 
- Set up the worker node 
- Learn to manage the Kubernetes cluster 

System Requirements;

Ensure that the networking is set up and that all the virtual machines can talk to each other.

- 7 virtual machines (etcd, LB, worker nodes)  
- 3 virtual machines (master nodes)
- 1 client VM


## Lab Environment

The environment used here is an empty Kubernetes cluster managed through minikube. The cluster is using a single node EC2 instance in AWS. To setup the environment, check out [Using Minikube to Create a Cluster.](https://kubernetes.io/docs/tutorials/kubernetes-basics/create-cluster/cluster-intro/)






## Cleanup 

The resources can be deleted by simply running a **delete** command on the *manifest* directory where the YAML files are located.

```bash
kubectl delete -f manifest 
```

We can also simply [delete the EC2 instance in the AWS Management Console](https://aws.amazon.com/premiumsupport/knowledge-center/delete-terminate-ec2/).

## Resources

- [Create Kubernetes Nginx Ingress Controller for External API Traffic](https://cloudacademy.com/lab/create-kubernetes-nginx-ingress-controller-external-api-traffic/?context_id=888&context_resource=lp)