
# Lab 48: Volumes 

Pre-requisites:

- [Basic Understanding of Kubernetes](../README.md#kubernetes)
- [AWS account](../pages/01-Pre-requisites/labs-optional-tools/README.md#create-an-aws-account)
- [AWS IAM Requirements](../pages/01-Pre-requisites/labs-optional-tools/01-AWS-IAM-requirements.md)
- [AWS CLI, kubectl, and eksctl](../pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md#install-cli-tools) 

Here's a breakdown of sections for this lab.

- [Introduction](#introduction)
- [Launch a Simple EKS Cluster](#launch-a-simple-eks-cluster)
- [Create the Namespace](#create-the-namespace)
- [Without Persistent Volumes](#without-persistent-volumes)
- [Persistent Volumes Outdated](#persistent-volumes-outdated)
- [Using the EBS CSI Driver](#using-the-ebs-csi-driver)
- [Persistent Volumes using the EBS CSI Driver](#persistent-volumes-using-the-ebs-csi-driver)
- [Cleanup](#cleanup)


## Introduction

In this lab, we'll get to see how we can use PersistentVolume for the sample data tier to preserve the data even after the Pod is deleted. 

We'll also statically provision an Amazon Elastic Block Storage (EBS) for the underlying storage. We'll use the application architecture from a [previous lab](../Lab_041-Multi_Container_Pods/README.md):

<p align=center>
<img width=700 src="../Images/lab48-volumes-diagram.png">
</p>

To learn more, check out the [Volumes and StorageClass page.](../pages/04-Kubernetes/017-StorageClass.md)


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

For the cluster, we can reuse the **eksops.yml** file from the previous labs.

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
        desiredCapacity: 1
        ssh: 
            publicKeyName: "k8s-kp"
```
 
</details>

Launch the cluster.

```bash
time eksctl create cluster -f eksops.yml 
```

Check the nodes and pods.

```bash
kubectl get nodes 
```

Save the cluster, region, and AWS account ID in a variable. We'll be using these in a lot of the commands later.

```bash
MYREGION=ap-southeast-1
MYCLUSTER=eksops 
MYAWSID=$(aws sts get-caller-identity | python3 -c "import sys,json; print (json.load(sys.stdin)['Account'])")
```


## Create the Namespace

We'll use [namespace-volumes.yml](manifests/namespace-volumes.yml) to create **probes** namespace.

```bash
apiVersion: v1
kind: Namespace
metadata:
  name: volumes
  labels:
    app: counter
```

Apply.

```bash
kubectl apply -f namespace-volumes.yml 
```

Verify.

```bash
$ kubectl get ns
NAME                STATUS   AGE
default             Active   8h
volumes             Active   18s 
```

## Without Persistent Volumes

To demonstrate the application without persistent volumes, let's first try to deploy it with ephemeral storage. The YAML files are inside the <code>/manifests/ephemeral</code> subdirectory.

```bash
kubectl apply -f deployment-support.yml
kubectl apply -f deployment-app.yml
kubectl apply -f deployment-data.yml
```

Check the pods:

```bash
$ kubectl get pods -n volumes

NAME                            READY   STATUS    RESTARTS   AGE
app-tier-74d6d7465d-bzvbh       1/1     Running   0          3m32s
data-tier-6c8f55b94f-mq4h6      1/1     Running   0          3m32s
support-tier-66f4cc4f7c-njhjt   2/2     Running   0          3m32s
```

Recall that the support tier has a poller that continuously makes GET requests and a counter that continuously makes POST requests. Let's check the poller pod.

```bash
$ kubectl logs support-tier-66f4cc4f7c-njhjt poller --tail=1 -n volumes

Current counter: 36279 

$ kubectl logs support-tier-66f4cc4f7c-njhjt poller --tail=1 -n volumes

Current counter: 37331
```

Let's now try to restart the Redis pod by logging in to the Pod and killing the process. The process ID of the container since this is the first process that is run when the container is started.

Notice that when we log in to the pod, the prompt changes.

```bash
$ kubectl exec -it -n volumes data-tier-6c8f55b94f-mq4h6  bash

kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
root@data-tier-6c8f55b94f-mq4h6:/data# 
root@data-tier-6c8f55b94f-mq4h6:/data# 
root@data-tier-6c8f55b94f-mq4h6:/data# 
```

Kill the Redis process. You should automatically get logged out.

```bash
root@data-tier-6c8f55b94f-mq4h6:/data# kill 1
root@data-tier-6c8f55b94f-mq4h6:/data# command terminated with exit code 137
$ 
$ 
$ 
```

Now check the logs for the poller again. The counter should now be restarted and is at a lower number. This means that the previous data is wiped out.

```bash
$ kubectl logs support-tier-66f4cc4f7c-njhjt poller --tail=1 -n volumes

Current counter: 27
```

Let's now delete all the deployments before we proceed with the persistent volumes.

```bash
cd /manifests/ephemeral
kubectl delete -f .
```

## Persistent Volumes (Outdated)

> *The PersistentVolume used in this lab is "awsElasticBlockStore" which is already deprecated in Kubernetes v1.17. The current version is Kubernetes v1.22 and it is recommended to use the EBS CSI provisioner plugins*
>
> *You may skip this step and proceed to the next step, "Using the EBS CSI Driver"*

The YAML files that we'll use are in the *persistent* directory.

```bash
cd manifests/persistent 
```

This lab is based on the previous labs so if you've done the lab before this, then you'll know that were using the same structure here. 

The difference is that each YAML files now have sections for **PersistentVolume**, which declares the storage capacity, access modes, and the EBS volume ID, and the **PersistentVolumeClaim**, which outlines how much storage the Pod will be requesting.

As mentioned, an [EBS volume should be created](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-creating-volume.html) prior to this step. If you haven't done it yet, you can also run the command below to create an EBS volume through the [AWS CLI](../pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md#install-cli-tools).

```bash
aws ec2 create-volume \
--region ap-southeast-1 --availability-zone ap-southeast-1a  --size 100 \
--tag-specifications \
'ResourceType=volume,
Tags=[{Key=Name,Value=ebs-pv},{Key=Type,Value=PV}]' 
```

We can retrieve the EBS volume ID through the AWS Management Console or through the AWS CLI as well.

```bash
aws ec2 describe-volumes --region ap-southeast-1 --filters="Name=tag:Type, Values=PV" 
```

To get just the volume ID:

```bash
aws ec2 describe-volumes --region ap-southeast-1 --filters="Name=tag:Type, Values=PV" --query="Volumes[0].VolumeId" 
```

Now replace the volume ID in the YAML file for the data tier.

```bash
$ vim deployment-data.yml
..........

  awsElasticBlockStore: 
    volumeID: vol-0c8f51b897c8960b9
```

We'll be using the same manifests for the app and support tier from the previous labs. Let's now create the resources.

```bash
cd manifests/persistent 
kubectl apply -f .
```

```bash
$ kubectl get pods -n volumes
NAME                            READY   STATUS    RESTARTS     AGE
app-tier-76b8556cc-ksnlb        1/1     Running   0            9s
data-tier-5f5b8bc86-mxp47       1/1     Running   0            8s
support-tier-755fff44ff-4q92w   2/2     Running   0            8s 
```

Let's now test the the poller container.

```bash
$ kubectl logs -n volumes support-tier-755fff44ff-4q92w poller --tail=1 

476
```

Previously, we saw that the count was wiped out on the ephemeral storage when the deployment for the data tier is deleted. 

Let's delete the deployment once again.

```bash
kubectl delete -n  volumes deployments data tier 
```

Since we're using a persistent storage, the last count that should be returned by the poller should be higher than the count that we just got from above.


```bash
$ kubectl logs -n volumes support-tier-755fff44ff-4q92w poller --tail=1 

871
```

## Using the EBS CSI Driver

To dynamically provision the EBS volume which we will use as the persistent volume, we can use the EBS CSI driver plugin. Deploying the driver requires a couple of steps but we can simply use the [script](./script-setup-ebs-csi.sh) that's provided in this lab.

Make the script executable first.

```bash
chmod +x script-setup-ebs-csi.sh
```

> *****
> *The script will create the IAM role,**AmazonEKS_EBS_CSI_DriverRole** and the policy **AmazonEKS_EBS_CSI_Driver_Policy**. If you already have this two resources, then the script will fail.*
> 
> *You can opt to delete the two resources first before running the script, or you can also modify the trust relationship for the policy and replace the OID with the OID of your cluster.*
>
> *If you choose to simply edit your existing IAM policy, you may also need to edit the script and remove the part for creating the IAM role and policy.*
> ****

Run the script. It should return an output.

```bash
./script-setup-ebs-csi.sh 
```
```bash
2022-10-11 11:51:41 [ℹ]  will create IAM Open ID Connect provider for cluster "eksops" in "ap-southeast-1"
2022-10-11 11:51:41 [✔]  created IAM Open ID Connect provider for cluster "eksops" in "ap-southeast-1"
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   599  100   599    0     0   1212      0 --:--:-- --:--:-- --:--:--  1210
{
    "Policy": {
        "PolicyName": "AmazonEKS_EBS_CSI_Driver_Policy",
        "PolicyId": "ANPA4LE56APQMKHWFJMTS",
        "Arn": "arn:aws:iam::12345678901:policy/AmazonEKS_EBS_CSI_Driver_Policy",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2022-10-11T03:52:05+00:00",
        "UpdateDate": "2022-10-11T03:52:05+00:00"
    }
}
{
    "Role": {
        "Path": "/",
        "RoleName": "AmazonEKS_EBS_CSI_DriverRole",
        "RoleId": "AROA4LE56APQFM3Y5Q7FW",
        "Arn": "arn:aws:iam::12345678901:role/AmazonEKS_EBS_CSI_DriverRole",
        "CreateDate": "2022-10-11T03:52:07+00:00",
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Federated": "arn:aws:iam::12345678901:oidc-provider/oidc.eks.ap-southeast-1.amazonaws.com/id/6FD1DA6E5C418823802CF53BE7A9F5B6"
                    },
                    "Action": "sts:AssumeRoleWithWebIdentity",
                    "Condition": {
                        "StringEquals": {
                            "oidc.eks.ap-southeast-1.amazonaws.com/id/6FD1DA6E5C418823802CF53BE7A9F5B6:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
                        }
                    }
                }
            ]
        }
    }
}
serviceaccount/ebs-csi-controller-sa created
serviceaccount/ebs-csi-node-sa created
clusterrole.rbac.authorization.k8s.io/ebs-csi-node-role created
clusterrole.rbac.authorization.k8s.io/ebs-external-attacher-role created
clusterrole.rbac.authorization.k8s.io/ebs-external-provisioner-role created
clusterrole.rbac.authorization.k8s.io/ebs-external-resizer-role created
clusterrole.rbac.authorization.k8s.io/ebs-external-snapshotter-role created
clusterrolebinding.rbac.authorization.k8s.io/ebs-csi-attacher-binding created
clusterrolebinding.rbac.authorization.k8s.io/ebs-csi-node-getter-binding created
clusterrolebinding.rbac.authorization.k8s.io/ebs-csi-provisioner-binding created
clusterrolebinding.rbac.authorization.k8s.io/ebs-csi-resizer-binding created
clusterrolebinding.rbac.authorization.k8s.io/ebs-csi-snapshotter-binding created
deployment.apps/ebs-csi-controller created
poddisruptionbudget.policy/ebs-csi-controller created
daemonset.apps/ebs-csi-node created
csidriver.storage.k8s.io/ebs.csi.aws.com created
serviceaccount/ebs-csi-controller-sa annotated
pod "ebs-csi-controller-7969d567c-qh7gw" deleted
pod "ebs-csi-controller-7969d567c-qnqcn" deleted 
```

Check if the EBS CSI pods are running.

```bash
$ kubectl get pods -A | grep ebs

kube-system   ebs-csi-controller-7969d567c-4pz9c   6/6     Running   0          10m
kube-system   ebs-csi-controller-7969d567c-tcflx   6/6     Running   0          10m
kube-system   ebs-csi-node-bkzs5                   3/3     Running   0          10m  
```

## Persistent Volumes using the EBS CSI Driver

Let's now deploy the YAML files. 

```bash
cd manifests/persistent-ebs-csi 
kubectl apply -f . 
```

Check the pods. The app-tier pods will fail initially because its waiting for the data-tier to start first. Run the command below multiple times to see the app-tier change to "running" status.

```bash
$ kubectl get pods -n volumes

NAME                            READY   STATUS    RESTARTS      AGE
app-tier-74d6d7465d-wz59p       1/1     Running   3 (30s ago)   3m10s
data-tier-7cd987fdc5-wwmnq      1/1     Running   0             14s
support-tier-75b9d58579-6jbxn   2/2     Running   0             3m10s
```

Recall that the support-tier pod has a poller that continuously makes GET requests and a counter that continuously makes POST requests.

Let's check the latest count retrieved by the poller.

```bash
$ kubectl logs support-tier-75b9d58579-6jbxn poller --tail 1 -n volumes

Current counter: 1264 
```

Previously, we saw that the count was wiped out on the ephemeral storage when the deployment for the data tier is deleted. 

Let's delete the deployment once again.

```bash
$ kubectl get deployment -n volumes

NAME           READY   UP-TO-DATE   AVAILABLE   AGE
app-tier       1/1     1            1           119s
data-tier      1/1     1            1           119s
support-tier   1/1     1            1           119s 
```

```bash
kubectl delete -n  volumes deployments data-tier 
```

Apply the manifest for the data-tier again to re-create the deployment.

```bash
kubectl apply -f deployment-data.yml
```

Since we're using a persistent storage, the last count that should be returned by the poller should be higher than the count that we just got from above.

```bash
$ kubectl logs support-tier-75b9d58579-6jbxn poller --tail 1 -n volumes

Current counter: 2596 
```


## Cleanup 

Make sure to delete the cluster after the lab to save costs.

```bash
$ time eksctl delete cluster -f eksops.yml 
```

When you delete your cluster, make sure to also double check the AWS Console and ensure that the Cloudformation stacks (which we created by eksctl) are dropped cleanly.
