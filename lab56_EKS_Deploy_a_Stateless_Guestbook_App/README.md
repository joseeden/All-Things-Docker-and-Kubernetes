# Lab 56: Deploy a Stateless Guestbook Application

Pre-requisites:

- [Basic Understanding of Kubernetes](../README.md#kubernetes)
- [AWS account](../pages/01-Pre-requisites/labs-optional-tools/README.md#create-an-aws-account)
- [AWS IAM Requirements](../pages/01-Pre-requisites/labs-optional-tools/01-AWS-IAM-requirements.md)
- [AWS CLI, kubectl, and eksctl](../pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md#install-cli-tools) 

Here's a breakdown of sections for this lab.

- insert-TOC-here


We'll be using **ap-southeast-1** region (Singapore).


## Introduction

In this lab, we'll deploy an EKS cluster and then deploy a simple guestbook application that uses a Redis database. We'll also scale up and down our Pods and see the results. Lastly, we will also get to use an AWS LoadBalancer with our cluster.

TODO:

- Deploy backend resources
- Deploy frontend resources
- Scale up/down the Pods 
- Perform chaos testing on the cluster
- test app access through the LoadBalancer

## xxxx


## xxxx


## xxxx


## xxxx


## xxxx


## xxxx



## Cleanup

Before we officially close this lab, make sure to destroy all resources to prevent incurring additional costs.

```bash
$ time eksctl delete cluster -f  
```

Note that when you delete your cluster, make sure to double-check the AWS Console and check the Cloudformation stacks (which we created by eksctl) are dropped cleanly.



## xxxx




