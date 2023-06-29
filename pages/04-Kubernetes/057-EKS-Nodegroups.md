# Amazon EKS - Self-managed vs. Managed Nodegroups

- [Self-managed Nodegroups](#self-managed-nodegroups)
- [Managed Nodegroups](#managed-nodegroups)
- [Resources](#resources)



## Self-managed Nodegroups 

The Kubernertes administrator is responsible for configuring a lot of stuff with self-managed node, which includes:

- installing the kubelet,
- container runtime,
- connecting to the cluster,
- autoscaling,
- networking, and more. 

Most EKS clusters do not need the level of customization that self-managed nodes provide.

Below is an example YAML file for creating an EKS cluster with self-managed nodegroup using eksctl.

```yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
    version: "1.24"
    name: eksops
    region: ap-southeast-1 
nodeGroups:
    -   name: ng-dover
        instanceType: t3.large
        minSize: 0
        maxSize: 5
        desiredCapacity: 3
        ssh: 
            publicKeyName: "k8s-kp" 
```

To create the cluster:

```bash
time eksctl create cluster -f eksops.yml  
```

From **kubectl**:

```bash
  
```

From the **AWS Management Console > Amazon EKS**:




## Managed Nodegroups 

Managed node groups handle the lifecycle of each worker node for you. A managed node group will:

- come with all the prerequisite software and permissions, 
- connect itself to the cluster, and 
- makes it easier for lifecycle actions like autoscaling and updates. 

AWS manages the servers for you - You just specify the instance type, but not the AMI. Patching can be managed for you.

In most cases managed node groups will reduce the operational overhead of self managing nodes and provide a much easier experience.


Below is an example YAML file for creating an EKS cluster with a managed nodegroup using eksctl.

```yaml
# eksops-managed.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eksops-managed
  region: ap-southeast-1

managedNodeGroups:
  - name: eksops-dev
    instanceType: t2.micro
    minSize: 1
    maxSize: 5
    desiredCapacity: 3
    volumeSize: 10
    ssh:
      allow: true
      publicKeyPath: ~/.ssh/ec2_id_rsa.pub
    labels: {role: worker}
    tags:
      nodegroup-role: worker
    iam:
      withAddonPolicies:
        externalDNS: true
        certManager: true
```

To create the cluster:

```bash
time eksctl create cluster -f eksops-managed.yml  
```

From **kubectl**:

```bash
  
```

From the **AWS Management Console > Amazon EKS**:


## Combining both 

We can also create an EKS Cluster that has a managed node group and an unmanaged nodegroup.




## Resources 

- https://eksctl.io/usage/eks-managed-nodes/

- https://repost.aws/questions/QU3b7kgBtFSCGtWW88a3fiMQ/difference-between-eks-managed-node-group-and-self-managed-node-group