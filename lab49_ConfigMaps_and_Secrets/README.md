
# Lab 49: ConfigMaps and Secrets

Pre-requisites:

- [Basic Understanding of Kubernetes](../README.md#kubernetes)
- [AWS account](../pages/01-Pre-requisites/labs-optional-tools/README.md#create-an-aws-account)
- [AWS IAM Requirements](../pages/01-Pre-requisites/labs-optional-tools/01-AWS-IAM-requirements.md)
- [AWS CLI, kubectl, and eksctl](../pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md#install-cli-tools) 

Here's a breakdown of sections for this lab.




## Introduction

We'll be using the same architecture from the previous labs but we'll incorporate ConfigMaps and Secrets:

- ConfigMap for Redis configuration
- Secret for injecting sensitive environment variables into the app tier

Our architecture looks like this:

<p align=center>
<img width=500 src="../Images/lab48-volumes-diagram.png">
</p>

To learn more, check out the [Volumes and StorageClass page.](../pages/04-Kubernetes/017-StorageClass.md)


Mounting config file using a volume 