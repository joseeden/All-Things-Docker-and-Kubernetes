
# Lab 58: Deploy a Stateful Application using EFS

Pre-requisites:

- [Basic Understanding of Kubernetes](../README.md#kubernetes)
- [AWS account](../pages/01-Pre-requisites/labs-optional-tools/README.md#create-an-aws-account)
- [AWS IAM Requirements](../pages/01-Pre-requisites/labs-optional-tools/01-AWS-IAM-requirements.md)
- [AWS CLI, kubectl, and eksct installed](../pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md#install-cli-tools) 

Here's a breakdown of sections for this lab.








## Introduction

This lab discusses how to deploy a stateful application using EFS. 
The steps are similar with the previous [lab](../Lab_057_EKS_Deploy_a_Stateful_App_using_EBS/README.md) but instead of a EBS CS driver, we will use an EFS driver.

We'll be using **ap-southeast-1** region (Singapore).

## The Application Architecture 

<p align=center>
<img width=600 src="../Images/lab58.png">
</p>

Our sample application will be composed of two layers:

- **Web layer**: Wordpress application 
- **Data layer**: MySQL database 

Both tiers will have their own storage to store the media content:

- **Frontend resources:**

  - an internet-facing Amazon Elastic LoadBalancer (ELB) to expose our application to the web
  - the Wordpress application running on Pods

- **Backend resources:**

  - a MySQL database running on Pods 
  - a MySQL service that connects the frontend to the database

## Launch a Simple EKS Cluster

Verify the correct IAM user's access keys. 
This should be the user created from the **pre-requisites** section above.

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

For the cluster, we can reuse the [eksops.yml](./eksops.yml) file from the previous labs. Launch the cluster. Note that you must have generated an SSH key pair which can be used to SSH onto the nodes. The keypair I've used here is named "k8s-kp" and is specified in the manifest file.

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

Verify in the AWS Management Console. We should be able to see the cluster and the nodegroup.

<!-- insert screenshot here -->

## Setup the Kubernetes Dashboard   

The [previous lab](../Lab_055_EKS_Kubernetes_Dashboard/README.md) explained the concept of Kubernetes Dashboard and the steps to set it up. We can use a script that sets up the dashboard in one go. Make the script executable.

```bash
chmod +x scripts/script-setup-kube-dashboard.sh
```

Run the script.

```bash
./scripts/script-setup-kube-dashboard.sh
```

It should return the following output:

```bash
serviceaccount/metrics-server created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrole.rbac.authorization.k8s.io/system:metrics-server created
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created
service/metrics-server created
deployment.apps/metrics-server created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
namespace/kubernetes-dashboard created
serviceaccount/kubernetes-dashboard created
service/kubernetes-dashboard created
secret/kubernetes-dashboard-certs created
secret/kubernetes-dashboard-csrf created
secret/kubernetes-dashboard-key-holder created
configmap/kubernetes-dashboard-settings created
role.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrole.rbac.authorization.k8s.io/kubernetes-dashboard created
rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
deployment.apps/kubernetes-dashboard created
service/dashboard-metrics-scraper created
deployment.apps/dashboard-metrics-scraper created
serviceaccount/kb-admin-svc created
clusterrolebinding.rbac.authorization.k8s.io/kb-admin-svc created
-------------------------------------------------
Starting to serve on 127.0.0.1:8001
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
metrics-server   1/1     1            1           7m37s 
```

The script should also create a file that contains the token of the service account we just created. Copy the token inside.

```bash
grep "token:" kube-dashboard-token.txt
```

Open a web browser and paste this URL. Enter the token that we just copied. We'll use thie dashboard later in the lab.

```bash
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

Note that the token will expire after some time. Simply generate a new one in the terminal.

```bash
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep kb-admin-svc | awk '{print $1}') 
```

## Create Namespace 

Create a namespace to separate workloads and isolate environments.
To get the namespaces that we currently have in our cluster:

```bash
kubectl create ns lab-efs
```

Verify.

```bash
$ kubectl get ns -A

NAME                   STATUS   AGE
default                Active   5h25m
kube-node-lease        Active   5h25m
kube-public            Active   5h25m
kube-system            Active   5h25m
kubernetes-dashboard   Active   7m
lab-efs                Active   12s
```


## Install the Amazon EFS driver
 


## Create the EFS Filesystem 

> *If you have Terraform installed, you can also create the EFS Filesystem using it. Scroll down below.*

Start with creating the EFS Filesystem in the AWS Management Console. 
Since the console UI is changing from time to time, better to follow the [official AWS Documentation](https://docs.aws.amazon.com/efs/latest/ug/creating-using-create-fs.html) on how to create the EFS Filesystem. 

<p align=center>
<img src= "../Images/lab58efsreated.png">
</p>

We should see the "Success" message along with the filesystem created in the EFS main page. 

![](../Images/lab58created%20efsfilesystem.png)  

Click on the new filesystem and go to **Network** tab to see more details.

![](../Images/lab58detailsonthenewefs.png)  

Save the EFS Filesystem ID to a variable.

```bash
EFSID="fs-0be2ae829d8f1aec2" 
```




## Create StorageClass and PersistenVolumeClaims

Create the StorageClass and PersistenVolumeClaims for both Wordpress and MySQL. Make sure to replace the **fileSystemId** with your EFS Filesystem ID.

```bash
kubectl apply -f manifests/create-storage.yml 
```

To verify, run the command below. Note that both PVCs are in **Bound** state.

```bash
$ kubectl get pvc
NAME            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc-mysql       Bound    pvc-fbf5035d-81cf-4c45-b90f-e2b2213eed9d   10Gi       RWX            efs-sc         62s
pvc-wordpress   Bound    pvc-515d6e26-1b9b-4722-ac41-66763166f428   10Gi       RWX            efs-sc         62s 
```
## Deploy MySQL


## Deploy Wordpress


## Cleanup

Before we officially close this lab, make sure to destroy all resources to prevent incurring additional costs.

```bash
$ time eksctl delete cluster -f  
```

Note that when you delete your cluster, make sure to double-check the AWS Console and ensure that the Cloudformation stacks (which we created by eksctl) are dropped cleanly.

Make sure to delete the EFS Filesystem. If you created it through Terraform, run the command below.

```bash
cd manifests
terraform destroy -auto-approve 
```

## Resources 

- https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html
- https://aws.amazon.com/blogs/containers/introducing-efs-csi-dynamic-provisioning/