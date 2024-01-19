# Lab 61: Deploy WordPress on EKS


- [Pre-requisites](#pre-requisites)
- [Introduction](#introduction)
- [Create the EBS Volumes](#create-the-ebs-volumes)
- [Launch a Simple EKS Cluster](#launch-a-simple-eks-cluster)
- [Download kubectl and awscli](#download-kubectl-and-awscli)
- [Update kubeconfig](#update-kubeconfig)
- [Prepare the Manifests](#prepare-the-manifests)
    - [Update the Backend Deployment manifest](#update-the-backend-deployment-manifest)
    - [Update the Frontend Deployment manifest](#update-the-frontend-deployment-manifest)
- [Create the MySQL Database Password](#create-the-mysql-database-password)
- [Deploy the MySQL Database](#deploy-the-mysql-database)
- [Deploy the Frontend](#deploy-the-frontend)
- [End-to-end Testing of Wordpress Application](#end-to-end-testing-of-wordpress-application)
- [Cleanup](#cleanup)
- [Resources](#resources)

## Pre-requisites

- [Basic Understanding of Kubernetes](../README.md#kubernetes)
- [AWS account](../pages/01-Pre-requisites/labs-optional-tools/README.md#create-an-aws-account)
- [AWS IAM Requirements](../pages/01-Pre-requisites/labs-optional-tools/01-AWS-IAM-requirements.md)
- [AWS CLI, kubectl, and eksctl](../pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md#install-cli-tools) 


## Introduction

In this lab, we'll launch a single-node EKS Cluster and deploy a containerize Wordpress application which consists of the following containers:

- Frontend web server running Apache
- Backend database running MySQL

Storage:

- EBS GP2 volumes for persistent storage

Architecture:

![](../../Images/lab30-arch-diagram.png)  


## Create the EBS Volumes

Before we create the EKS cluster, we first need a total of six EBS volumes that are equally spread across three availability zones. Please check out the AWS Documentation to know how to [create an EBS Volume.](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-creating-volume.html)

- us-west-2a
  - wordpress.mysql.volume
  - wordpress.web.volume
- us-west-2b
  - wordpress.mysql.volume
  - wordpress.web.volume
- us-west-2c
  - wordpress.mysql.volume
  - wordpress.web.volume

![](../Images/lab30-ebsvolumes-new.png)  


## Launch a Simple EKS Cluster

Let's first verify if we're using the correct IAM user's access keys. This should be the user we created from the **pre-requisites** section above.

```bash
aws sts get-caller-identity 
```
```bash
{
    "UserId": "AIDxxxxxxxxxxxxxx",
    "Account": "1234567890",
    "Arn": "arn:aws:iam::1234567890:user/k8s-admin"
} 
```

For the cluster, we can reuse the [eksops.yml](eksops.yml) file from the other labs. Launch the cluster. We can add the **time** command how long the the creation of the EKS cluster took.

```bash
time eksctl create cluster -f eksops.yml 
```

From the AWS Management Console, we should see the the **Cluster-1** created and in **Active** state.

![](../Images/lab30-ekscluster-created.png)  

We should also see the nodes and node group.

![](../Images/lab30-nodes-nodegorup.png)  


## Download kubectl and awscli 

We'll be connecting to our EKS cluster from our local development computer. If you haven't yet, install the kubectl and awscli utility tools.

```bash
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo cp ./kubectl /usr/local/bin
export PATH=/usr/local/bin:$PATH 
```
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

To verify:

```bash
$  kubectl version --short --client=true

Client Version: v1.21.2-13+d2965f0db10712
 
```
```bash
$ aws --version

aws-cli/2.9.15 Python/3.9.11 Linux/4.14.246-187.474.amzn2.x86_64 exe/x86_64.amzn.2 prompt/off
```


## Update kubeconfig 

After setting up eksctl, retrieve the EKS cluster name that you just created.

```bash
EKS_CLUSTER_NAME=$(aws eks list-clusters --region us-west-2 --query clusters[0] --output text)
echo $EKS_CLUSTER_NAME
```

Next, update the kubeconfig file. This ensures that we'll be authenticated to the EKS cluster so we'll be able to talk to our cluster and perform operations.

```bash
$ aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region us-west-2 

Added new context arn:aws:eks:us-west-2:598251627037:cluster/Cluster-1 to /home/ec2-user/.kube/config 
```

Check the nodes.

```bash
$ kubectl get nodes 

NAME                                          STATUS   ROLES    AGE   VERSION
ip-192-168-9-108.us-west-2.compute.internal   Ready    <none>   18m   v1.21.14-eks-fb459a0
```

## Prepare the Manifests 

We'll use the following YAML files to deploy a containerized WordPress application.

- [backend-mysql.yml](manifests/backend-mysql.yml) 
- [frontend-web.yml](manifests/frontend-web.yml)

We still need to update the volume that each deployment will use. Recall that we created EBS volumes on all availability zones. For now, we need th specific EBS volume that are in the same availability zone as our worker node. 

Retrieve the availability zone where the EKS worker node is deployed into.

```bash
EKS_WORKER_NODE_AZ=$(kubectl get nodes -o jsonpath="{.items[*].metadata.labels.topology\.kubernetes\.io/zone}" | cut -d" " -f1)
```
```bash 
$ echo $EKS_WORKER_NODE_AZ

us-west-2c
```

Next, find the EBS volume that's created in the same availability zone.

```bash
VOLUMEID_DB=$(aws ec2 describe-volumes --region us-west-2 \
  --filters "Name=tag:Name,Values=wordpress.mysql.volume" "Name=tag:Zone,Values=$EKS_WORKER_NODE_AZ" \
  --query Volumes[0].VolumeId \
  --output text)
echo $VOLUMEID_DB 
```

### Update the Backend Deployment manifest

Replace the **EBS_VOLUME_ID** variable in the backend-mysql.yml manifest with the volume ID.

```bash
sed -i.bak s/EBS_VOLUME_ID/$VOLUMEID_DB/g backend-mysql.yml
sed -i.bak s/EKS_WORKER_NODE_AZ/$EKS_WORKER_NODE_AZ/g backend-mysql.yml
```

Verify.

```bash
$ cat backend-mysql.yml | grep 'volumeID\|zone'

        topology.kubernetes.io/zone: us-west-2c
            volumeID: vol-0488a12b51f2e38b2 
```

### Update the Frontend Deployment manifest

Do the same step for the frontend deployment. Find the EBS volume created in the same availability zone as the worker node and modify the YAML file.

```bash
VOLUMEID_WEB=$(aws ec2 describe-volumes --region us-west-2 \
  --filters "Name=tag:Name,Values=wordpress.web.volume" "Name=tag:Zone,Values=$EKS_WORKER_NODE_AZ" \
  --query Volumes[0].VolumeId \
  --output text)
echo $VOLUMEID_WEB
```
```bash
sed -i.bak s/EBS_VOLUME_ID/$VOLUMEID_WEB/g frontend-web.yml
sed -i.bak s/EKS_WORKER_NODE_AZ/$EKS_WORKER_NODE_AZ/g frontend-web.yml
```
```bash
$ cat frontend-web.yml | grep 'volumeID\|zone'

       topology.kubernetes.io/zone: us-west-2c
            volumeID: vol-0e148dcf67a09cf36
```

## Create the MySQL Database Password 

Create a password for the MySQL database and store it as a secret:

```bash
kubectl create secret generic mysql-pass \
--from-literal=password=WEARETHEYOUNGKENNEDYS
```
```bash
$ kubectl get secrets

NAME                  TYPE                                  DATA   AGE
default-token-rcrsk   kubernetes.io/service-account-token   3      60m
mysql-pass            Opaque                                1      67s 
```

```bash
$ kubectl describe secrets mysql-pass

Name:         mysql-pass
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
==== 
```

## Deploy the MySQL Database 

Deploy the backend MySQL database.

```bash
kubectl apply -f backend-mysql.yml
```

```bash
$ kubectl get pods

NAME                               READY   STATUS    RESTARTS   AGE
wordpress-mysql-868d8f6df8-krrld   1/1     Running   0          63s 
```

Save the pod aname to a variable.

```bash
POD_NAME_MYSQL=$(kubectl get --no-headers=true pods -l app=wordpress,tier=mysql -o custom-columns=:metadata.name)
echo $POD_NAME_MYSQL 
```

In addition to checking the Pod's status, we could also check the logs of the Pod.

```bash
$ kubectl logs $POD_NAME_MYSQL

2023-01-22 15:16:52+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 5.6.51-1debian9 started.
2023-01-22 15:16:52+00:00 [Note] [Entrypoint]: Switching to dedicated user 'mysql'
2023-01-22 15:16:52+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 5.6.51-1debian9 started.
2023-01-22 15:16:52+00:00 [Note] [Entrypoint]: Initializing database files
2023-01-22 15:16:52 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
2023-01-22 15:16:52 0 [Note] Ignoring --secure-file-priv value as server is running with --bootstrap.
2023-01-22 15:16:52 0 [Note] /usr/sbin/mysqld (mysqld 5.6.51) starting as process 46 ...
```

Back at the AWS Management Console, we could also see that one of the EBS volumes is now in a **In-use** state.

![](../Images/lab30-ebsvolumeinusestate1.png)  



## Deploy the Frontend 

Deploy the frontend web server running Apache. Save the pod name to a variable.

```bash
kubectl apply -f frontend-web.yml
```

```bash
$ kubectl get pods

NAME                               READY   STATUS    RESTARTS   AGE
wordpress-74dcd765cf-cf8qx         1/1     Running   0          82s
wordpress-mysql-868d8f6df8-krrld   1/1     Running   0          7m40s 
```

```bash
POD_NAME_WEB=$(kubectl get --no-headers=true pods -l app=wordpress,tier=frontend -o custom-columns=:metadata.name)
echo $POD_NAME_WEB  
```

Check the logs.

```bash
$ kubectl logs $POD_NAME_WEB

WordPress not found in /var/www/html - copying now...
WARNING: /var/www/html is not empty - press Ctrl+C now if this is an error!
+ ls -A
+ sleep 10
lost+found
Complete! WordPress has been successfully copied to /var/www/html
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 192.168.77.162. Set the 'ServerName' directive globally to suppress this message
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 192.168.77.162. Set the 'ServerName' directive globally to suppress this message
[Sun Jan 22 15:23:26.629137 2023] [mpm_prefork:notice] [pid 1] AH00163: Apache/2.4.10 (Debian) PHP/5.6.32 configured -- resuming normal operations
[Sun Jan 22 15:23:26.629417 2023] [core:notice] [pid 1] AH00094: Command line: 'apache2 -D FOREGROUND' 
```

As expected, another EBS volume has transitioned to **In-use** state.

![](../Images/lab30-ebsvolumeinuseweb.png)  

Now to expose the application, the manifest also created a Kubernetes Service of Type **Loadbalancer**. This service will provide a persistent virtual IP for the frontend pods.

This will also create an ELB, which we should also see in the AWS Management Console.

![](../Images/lab30-elbcreated.png)  


## End-to-end Testing of Wordpress Application 

To test the application, we first need to get the HTTP URL provided by the Kubernetes Service that was just created.

```bash
$ kubectl get services -o wide

NAME              TYPE           CLUSTER-IP       EXTERNAL-IP                                                             PORT(S)        AGE     SELECTOR
kubernetes        ClusterIP      10.100.0.1       <none>                                                                  443/TCP        78m     <none>
wordpress         LoadBalancer   10.100.108.241   a11e785248d39457b88dc1c80a5a8433-13015745.us-west-2.elb.amazonaws.com   80:30812/TCP   8m10s   app=wordpress,tier=frontend
wordpress-mysql   ClusterIP      None             <none>                                                                  3306/TCP       14m     app=wordpress,tier=mysql 
```

We could also get the URL through another way. Save the URL to a variable.

```bash
$ ELB_DNS_NAME=$(kubectl get services -l app=wordpress -o json \
>   | jq -r '.items[] | select(.spec.type=="LoadBalancer") | .status.loadBalancer.ingress[].hostname') 
```

```bash
$ echo $ELB_DNS_NAME
a11e785248d39457b88dc1c80a5a8433-13015745.us-west-2.elb.amazonaws.com 
```


Run the dig command to ensure that the DNS name for the ELB has propagated and can be resolved correctly

```bash
$ dig $ELB_DNS_NAME

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.amzn2.5.2 <<>> a11e785248d39457b88dc1c80a5a8433-13015745.us-west-2.elb.amazonaws.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 20698
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;a11e785248d39457b88dc1c80a5a8433-13015745.us-west-2.elb.amazonaws.com. IN A

;; ANSWER SECTION:
a11e785248d39457b88dc1c80a5a8433-13015745.us-west-2.elb.amazonaws.com. 60 IN A 54.187.203.23
a11e785248d39457b88dc1c80a5a8433-13015745.us-west-2.elb.amazonaws.com. 60 IN A 35.161.239.189

;; Query time: 2 msec
;; SERVER: 192.168.0.2#53(192.168.0.2)
;; WHEN: Sun Jan 22 15:33:33 UTC 2023
;; MSG SIZE  rcvd: 130 
```

Use curl to view the HTTP headers returned from the Wordpress application hosted within the Kubernetes cluster:

```bash
$ curl -I $ELB_DNS_NAME

HTTP/1.1 302 Found
Date: Sun, 22 Jan 2023 15:34:15 GMT
Server: Apache/2.4.10 (Debian)
X-Powered-By: PHP/5.6.32
Expires: Wed, 11 Jan 1984 05:00:00 GMT
Cache-Control: no-cache, must-revalidate, max-age=0
Location: http://a11e785248d39457b88dc1c80a5a8433-13015745.us-west-2.elb.amazonaws.com/wp-admin/install.php
Content-Type: text/html; charset=UTF-8
```

Open a web browser and navigate to the HTTP URL. We should be directed tot he installation setup for the Wordpress application.

![](../Images/lab30-wordpressapp.png)  


## Cleanup 

Delete the deployments.

```bash
kubectl delete -f frontend-web.yml
kubectl delete -f backend-mysql.yml
```

Next, delete the EBS volumes. The volumes need to be in the **Available** state to delete them.

![](../Images/lab30-deleteebsvolumes.png)  

Finally, delete the EKS cluster.

```bash
time eksctl delete cluster -f eksops.yml 
```


## Resources

- [Amazon EKS - Launch Kubernetes Cluster and Deploy WordPress](https://cloudacademy.com/lab/amazon-eks-launch-cluster-and-deploy-microservices-application/?context_id=888&context_resource=lp)