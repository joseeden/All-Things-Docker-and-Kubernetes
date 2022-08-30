
# Lab 55: Kubernetes Dashboard on EKS


Pre-requisites:

- [Basic Understanding of Kubernetes](../README.md#kubernetes)
- [AWS account](../pages/01-Pre-requisites/labs-optional-tools/README.md#create-an-aws-account)
- [AWS IAM Requirements](../pages/01-Pre-requisites/labs-optional-tools/01-AWS-IAM-requirements.md)
- [AWS CLI, kubectl, and eksctl](../pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md#install-cli-tools) 

Here's a breakdown of sections for this lab.

<insert-TOC-here>


For this lab, we'll be using **ap-southeast-1** region (Singapore).


## Introduction


## xxxx



## Cleanup

Before we officially close this lab, make sure to destroy all resources to prevent incurring additional costs.

```bash
$ time eksctl delete cluster -f l 
```

Note that when you delete your cluster, make sure to double-check the AWS Console and check the Cloudformation stacks (which we created by eksctl) are dropped cleanly.



## xxxx





TODO:

- Create service account and RBAC rules
- Deploy dashboard 
- Deploy metrics add-ons
- Create cluster admin account
- Explore the dashboard