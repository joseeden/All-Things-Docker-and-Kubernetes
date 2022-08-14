
# Lab xx: EKS Operations using eksctl

Pre-requisites:

  - [Basic Understanding of Kubernetes](../README.md#kubernetes)
  - [Sign-up for an AWS account](../README.md#pre-requisites)

For this lab, we'll be using ap-southeast-1 region (Singapore).

## Creating the Access 

We will need to do the following before we can create clusters and perform EKS operations.

- [Create a "k8s-kp.pem" keypair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html)

- [Create a "k8s-user" user with admin access](https://www.techrepublic.com/article/how-to-create-an-administrator-iam-user-and-group-in-aws/)

- [Create an access key for "k8s-user"](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey)

- [Create a service-linked role](https://us-east-1.console.aws.amazon.com/iamv2/home#/roles)


Step | Choose this value | 
---------|----------|
Trusted entity type | AWS service | 
Use case | KS (Allow EKS to manage clusters in your behalf |
Permission policies | AmazonEKSServiceRolePolicy

For the keypair, store it inside <code>~/.ssh</code> directory.

## Setup CLI Tools

Install the following tools by clicking the links:

- [aws cli](../README.md#pre-requisites) - used by eksctl to grab authentication token
- [eksctl](../README.md#pre-requisites) - setup and operation of EKS cluster 
- [kubectl](../README.md#pre-requisites) - interaction with K8S API server

Once you've installed aws cli, a <code>.aws/credentials</code> file should be automatically created in your home directory. You can also create the file yourself. Configure it with the access key for the "k8s-user" that you just created.

```bash
# /home/user/.aws/credentials

[default]
aws_access_key_id = AKIAxxxxxxxxxxxxxxxxxxx
aws_secret_access_key = ABCDXXXXXXXXXXXXXXXXXXXXXXX
region = ap-southeast-1
output = json
```

## Create the EKS cluster via eksctl

We'll deploy an intial cluster:
- region is ap-southeast-1
- contains one nodegroup
- nodegroup consists of 3 worker nodes
- each node will be t2.small
- ssh access is allowed

Create the project directory.

```bash
$ mkdir eksops-dir
```

Create the **eksops.yaml** file which will contain the specifications of our cluster.

```bash
$ vi eksops-dir/eksops.yml

apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
    name: eksops
    region: ap-southeast-1 

nodeGroups:
    -   name: ng-1
        instanceType: t2.small
        desiredCapacity: 3
        ssh: 
            publicKeyName: "k8s-kp"
```

Note that eksctl will automatically create a VPC and 2 subnets in two different availability zones (AZ).

Run the command below to create the cluster. This will take around 10-15 minutes.

```bash
$ eksctl create cluster -f eksops-dir/eksops.yaml
```

We can also track how long it ran by adding <code>time</code> at the beginning.

```bash
$ time eksctl create cluster -f eksops-dir/eksops.yaml
```

In the output, you should see the location where the <code>kubeconfig</code> file is saved.

```bash
saved kubeconfig as "/home/joseeden/.kube/config 
```

At the AWS Console, go to the EKS page to verify if the cluster is created.

<!-- ![](../Images/labxx-eksctldone.png)   -->

Recall that Amazon EKS uses Cloudformation to provision the resources under the hood. You can see the stack created in the CloudFormation console.

<!-- ![](../Images/labxx-eksctl-cfdone.png)   -->


To check the running nodes,

```bash
$ kubectl get nodes 
```

To check the running cluster,

```bash
$ eksctl get cluster 
```

To inspect the nodegroup,

```bash
$ eksctl get nodegroup --cluster  
```

## Scaling Nodegroups

It's always good practice to check the running cluster and nodes.

```bash
$ eksctl get cluster 
$ eksctl get nodegroup --cluster eksops
```

Initially, we set the *desiredCapacity* to 3 in the YAML file. To scale the number of nodes to 5,

```bash
$  eksctl scale nodegroup --cluster=eksops --name=ng-1 --nodes=5
```

Back at the EC2 Console, you should see two additional ndoes being initiallized.



At the Cloudformation console, you'll see an update in progress.



We could also scale in to reduce the number of nodes. 

```bash
$  eksctl scale nodegroup --cluster=eksops --name=ng-1 --nodes=2
```


## Adding a Nodegroup



## Deleting a Nodegroup