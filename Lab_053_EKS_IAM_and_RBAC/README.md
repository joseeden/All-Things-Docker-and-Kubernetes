# Lab 53: IAM and RBAC on EKS

Pre-requisites:

- [Basic Understanding of Kubernetes](../README.md#kubernetes)
- [AWS account](../pages/01-Pre-requisites/labs-optional-tools/README.md#create-an-aws-account)


Here's a breakdown of sections for this lab.

- [Introduction](#introduction)
- [Before we start](#before-we-start)
    - [IAM Requirements](#iam)
    - [CLI Tools](#cli-tools)
    - [Launch a Simple Cluster](#launch-a-simple-cluster)
- [Part 1: Create the Users](#part-1-create-the-users)
    - [Create the three IAM accounts with no permission](#create-the-three-iam-accounts-with-no-permission)
    - [Verify that they still don't have cluster access via CLI](#verify-that-they-still-dont-have-cluster-access-via-cli)
- [Part 2: Provide Cluster Admin Access](#part-2-provide-cluster-admin-access)
    - [Add the Cluster-admin user to Configmap](#add-the-cluster-admin-user-to-configmap)
    - [Test the Cluster-admin access](#test-the-cluster-admin-access)
- [Part 3: Provide Admin Access for dedicated namespace](#part-3-provide-admin-access-for-dedicated-namespace)
    - [Create the Namespace](#create-the-namespace)
    - [Create a role and rolebinding for Prod-admin User](#create-a-role-and-rolebinding-for-prod-admin-user)
    - [Map the Prod-admin User](#map-the-prod-admin-user)
    - [Test Prod-admin Access](#test-prod-admin-access)
- [Part 4: Provide Read-only Access for dedicated namespace](#part-4-provide-read-only-access-for-dedicated-namespace)
    - [Create a role and rolebinding for Read-only User](#create-a-role-and-rolebinding-for-read-only-user)
    - [Map the Read-only User](#map-the-read-only-user)
    - [Test Read-only Access](#test-read-only-access)
- [Cleanup](#cleanup)


## Introduction 

**New Developers joining**

Three new developers have been added to our team. They won't need IAM permissions and access to the AWS Console but since they will be collaborators, they will need programmatic access and they should have admin rights to our EKS cluster.

- developerMax will be given the admin access 
- developerTed will be given the prod-operator access
- developerYung will be given the prod-read-only access 

In this lab, we'll create additional users and provide them RBAC permissions to access our Kubernetes clusters. This lab has three parts:

**Part 1: Create the Users**

- Create an IAM user for "k8s-user-2" (admin)
- Create an IAM user for "k8s-user-prodadmin" (admin on prod)
- Create an IAM user for "k8s-user-prodviewer" (read-only on prod)
- Verify that they still don't have cluster access via CLI 

**Part 2: Provide Cluster Admin Access**

- Map user to Kubernetes role
- Test the setup 

**Part 3: Provide Admin Access for dedicated namespace**

- Create a role and rolebinding 
- Map user to Kubernetes role
- Test the setup 

**Part 4: Provide Read-only Access for dedicated namespace**

- Create a role and rolebinding 
- Map user to Kubernetes role
- Test the setup 

We'll also be using **ap-southeast-1** region (Singapore).


## Before we start

### IAM 

We need to do the following before we can perform EKS operations.

- [Create the IAM Policy](../pages/01-Pre-requisites/labs-optional-tools/01-AWS-IAM-requirements.md)
- [Create the IAM User, Access Key, and Keypair](../pages/01-Pre-requisites/labs-optional-tools/01-AWS-IAM-requirements.md)
- [Create the IAM Group](../pages/01-Pre-requisites/labs-optional-tools/01-AWS-IAM-requirements.md)

For the IAM User and Group, you can use the values below. Make sure to add the user to the group.

- IAM User: k8s-admin
- IAM Group: k8s-lab

**NOTE:** I would give k8s-admin as *AdminstratorAccess* since you might run into some issues later on.

Once you've created the <code>k8s-user</code>, log-in to the AWS Management Console using this IAM user.

To avoid confusion, we'll label the user accounts as:

- **k8s-admin** - main admin user that we'll use 

- **k8s-user-2** - a second admin user that we'll create 

- **k8s-user-prodadmin** - admin on prod 

- **k8s-user-prodviewer** - a read-only user on prod

### CLI Tools

We also need to install the following CLI tools:

- [aws cli](../pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md#install-cli-tools) 
) - used by eksctl to grab authentication token
- [eksctl](../pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md#install-cli-tools) 
) - setup and operation of EKS cluster 
- [kubectl](../pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md#install-cli-tools) 
) - interaction with K8S API server

Once you've installed AWS CLI, [add the access key to your credentials file](../pages/01-Pre-requisites/labs-optional-tools/01-AWS-IAM-requirements.mds). It should look like this:

```bash
# /home/user/.aws/credentials

[k8s-admin]
aws_access_key_id = AKIAxxxxxxxxxxxxxxxxxxx
aws_secret_access_key = ABCDXXXXXXXXXXXXXXXXXXXXXXX
region = ap-southeast-1
output = json
```

You can use a different profile name. To use the profile, export it as a variable.

```bash
$ export AWS_PROFILE=k8s-admin
```

To verify, we can run the commands below:

```bash
$ aws configure list 
```
```bash
$ aws sts get-caller-identity 
```

Although the region is already set in the profile, we'll also be using the region in many of the commands. We can save it as a variable.

```bash
$ export AWSREGION=ap-southeast-1 
```

### Launch a Simple Cluster

To use as an example later on, we can launch a simple cluster. But before we do that, let's first verify if we're using the main admin's access keys 

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

For the cluster, we can reuse the [eksops.yml](manifests/eksops.yml) file from the previous labs.
Launch the cluster.

```bash
$ time eksctl create cluster -f eksops.yml 
```

Check the nodes and pods.

```bash
$ kubectl get nodes 
$ kubectl get pods -A
```

## Part 1: Create the Users

### Create the three IAM accounts with no permission 

Let's start with creating the new users in the IAM console. Note that we'll be using our own "k8s-admin"  that has an *AdministratorAccess*.

Create the *k8s-user-2* with no IAM permissions.

1. Login to the AWS Management Console.
2. Go to IAM > Users > Add users 
3. In the next page, set the following:

    - User name: k8s-user-2
    - Select AWS credential type: Access key - Programmatic access

4. Click **Next: permissions** > **Next: tags**

    - Key: Name 
    - Value: k8s-user-2

5. Click **Next: Review** > **Create user**
6. You should see the **Success** message in the last page, along with the access key ID and secret access key.
7. Click **Download .csv** > **Close**
8. Back at the Users page, click the user that you just created. 9. Copy and save **User ARN**. We'll be using it later on.

Create the *k8s-user-prodadmin* with no IAM permissions. 
Repeat the same steps, but change the values. Make sure to download the CSV files and save the ARN.

For the username:

- User name: k8s-user-prodadmin
- Select AWS credential type: Access key - Programmatic access

For the tags:

- Key: Name 
- Value: k8s-user-prodadmin

Do the same for *k8s-user-prodviewer*. Make sure to download the CSV files and save the ARN.

For the username:

- User name: k8s-user-prodviewer
- Select AWS credential type: Access key - Programmatic access

For the tags:

- Key: Name 
- Value: k8s-user-prodviewer


### Verify that they still don't have cluster access via CLI 

Before we give the new IAM user cluster rights, let's test first the cluster access. Set a profile in the AWS credentias file then add the access key ID and secret acces key from the CSV file that's downloaded as a CSV file in the first step.

```bash
$ vim ~/.aws/credentials 
```
```bash
[k8s-user-2]
aws_access_key_id = AKIAxxxxxxxxxxxxxxxxxxx
aws_secret_access_key = ABCDXXXXXXXXXXXXXXXXXXXXXXX
region = ap-southeast-1
output = json

[k8s-user-prodadmin]
aws_access_key_id = AKIAxxxxxxxxxxxxxxxxxxx
aws_secret_access_key = ABCDXXXXXXXXXXXXXXXXXXXXXXX
region = ap-southeast-1
output = json

[k8s-user-prodviewer]
aws_access_key_id = AKIAxxxxxxxxxxxxxxxxxxx
aws_secret_access_key = ABCDXXXXXXXXXXXXXXXXXXXXXXX
region = ap-southeast-1
output = json
```

To use the new profile, export it as a variable then check the identity again.

```bash
$ export AWS_PROFILE=k8s-user-2 
```
```bash
$ aws sts get-caller-identity 
```
```bash
{
    "UserId": "AIDxxxxxxxxxxxxxx",
    "Account": "1234567890",
    "Arn": "arn:aws:iam::1234567890:user/k8s-user-2"
} 
```

Test that the new user account still doesn't have cluster access.

```bash
$ kubectl get nodes
error: You must be logged in to the server (Unauthorized)
```
```bash
$ kubectl get svc
error: You must be logged in to the server (Unauthorized) 
```

Repeat the same for *k8s-user-prodviewer*.

```bash
$ export AWS_PROFILE=k8s-user-prodviewer 
```
```bash
$ aws sts get-caller-identity 
```
```bash
{
    "UserId": "AIDxxxxxxxxxxxxxx",
    "Account": "1234567890",
    "Arn": "arn:aws:iam::1234567890:user/k8s-user-prodviewer"
} 
```

```bash
$ kubectl get nodes
error: You must be logged in to the server (Unauthorized)
```
```bash
$ kubectl get svc
error: You must be logged in to the server (Unauthorized) 
```
```bash
$ eksctl get nodegroup --cluster eksops
Error: unable to describe cluster control plane: operation error EKS: DescribeCluster, https response error StatusCode: 403, RequestID: 7778c7b0-e3ef-41e5-9b92-14c5b558ba22, api error AccessDeniedException: User: arn:aws:iam::848587260896:user/k8s-user-2 is not authorized to perform: eks:DescribeCluster on resource: arn:aws:eks:ap-southeast-1:848587260896:cluster/eksops 
```

We now have two IAM users with no permissions to the AWS Console and no admin rights to the EKS cluster.

## Part 2: Provide Cluster Admin Access

### Add the Cluster-admin user to Configmap 

Switch back to our main *k8s-admin* admin account.

```bash
$ export AWS_PROFILE=k8s-admin 
```
```bash
$ aws sts get-caller-identity 
```

Verify that the Configmap is created in our cluster. This should return the **aws-auth**.

```bash
$ kubectl -n kube-system get cm 
```

Next is to edit the the Configmap. We can edit the file using the command below:

```bash
$ kubectl edit configmap aws-auth -n kube-system 
```

Another approach it to print the Configmap in YAML format and then store it in a file which we can edit later. We'll proceed with this approach.

```bash
$ kubectl -n kube-system get configmap aws-auth -o yaml > aws-auth-configmap.yml
```

Edit the file. Populate the **mapUsers** block. Replace userarn with the ARN of *k8s-user-2*

```bash
$ vim aws-auth-configmap.yml
```
```bash
mapUsers: |
 -  username: k8s-user-2
    userarn: arn:aws:iam::1234567890:user/k8s-user-2
    groups:
        - system:masters
```

Apply the changes.

```bash
$ kubectl -n kube-system apply -f aws-auth-configmap.yml 
```

Check if the user was saved in the Configmap.

```bash
$ kubectl -n kube-system describe cm aws-auth 
```

### Test the Cluster-admin access

In the CLI, switch over to the profile of *k8s-user-2*.
Check if the new user can now access the cluster.

```bash
$ kubectl get nodes
NAME                                                STATUS   ROLES    AGE   VERSION
ip-192-168-12-34.ap-southeast-1.compute.internal   Ready    <none>   80m   v1.22.12-eks-ba74326
```

```bash
$ kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.100.1.2   <none>        443/TCP   91m 
```

Let's now create a manifest that will deploy NGINX in the default namespace.

<details><summary> main-nginx.yml </summary>
 
```bash
apiVersion: v1
kind: Pod
metadata:
  name: nginx-demo
  namespace: default
spec:
  containers:
  - name: nginx-ctr
    image: nginx:latest
    ports:
      - containerPort: 80
```
 
</details>

Apply the NGINX file.

```bash
$ kubectl apply -f main-nginx.yml 
```

Verify that the pod was created.

```bash
$ kubectl get pods
NAME         READY   STATUS    RESTARTS   AGE
nginx-demo   1/1     Running   0          16s 
```

## Part 3: Provide Admin Access for dedicated namespace

### Create the Namespace

Switch back to our main *k8s-admin* admin account.

```bash
$ export AWS_PROFILE=k8s-admin 
```
```bash
$ aws sts get-caller-identity 
```

Create the new namespace.

```bash
$ kubectl create ns prod 
```

Verify.

```bash
$ kubectl get ns 
```

### Create a role and rolebinding for Prod-admin User

Create the **role-prodadmin.yml**. Make sure to add *prod* in the namespace field.

<details><summary> role-prodadmin.yml </summary>
 
```bash
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
    namespace: prod
    name: role-prodadmin
rules:
- apiGroups: [  # "" indicates the core API group
    "",
    "extensions",
    "apps"
    ] 
  resources: [  # can be further limited, e.g. pods, deployments
    "*"
    ]
  verbs: [
    "*"
  ]
```

</details>

Create the **rolebind-prodadmin**. Add the user name *k8s-user-prodadmin* in the name field in the Subjects block.

Under the Roleref, add the name of the role.

<details><summary> rolebind-prodadmin.yml </summary>
 
```bash
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: rolebind-prodadmin
  namespace: prod
# You can specify more than one "subject"
subjects:
- kind: User
  name: k8s-user-prodadmin # "name" is case sensitive
  apiGroup: ""
roleRef:
  # "roleRef" specifies the binding to a Role / ClusterRole
  kind: Role #this must be Role or ClusterRole
  name: role-prodadmin # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: ""
```
 
</details>

Apply the role and rolebindings.

```bash
$ kubectl apply -f role-prodadmin.yml 
$ kubectl apply -f rolebind-prodadmin.yml 
```

### Map the Prod-admin User

Add the *k8s-user-prodadmin* to the Configmap. 

```bash
$ kubectl edit configmap aws-auth -n kube-system 
```

```bash
  mapUsers: |

    - userarn: arn:aws:iam::848587260896:user/k8s-user-2
      username: k8s-user-2
      groups:
       - system:masters

    - userarn: arn:aws:iam::848587260896:user/k8s-user-prodadmin
      username: k8s-user-prodadmin
      groups:
      - role-prodadmin
```

Check if the user was saved in the Configmap.

```bash
$ kubectl -n kube-system describe cm aws-auth 
```

### Test Prod-admin Access

Switch over to the new profile.

```bash
$ export AWS_PROFILE=k8s-user-prodadmin 
```
```bash
$ aws sts get-caller-identity 
```

Let's test if the user is able to retrieve the nodes for all namespaces. This should return an error.

```bash
$ kubectl get nodes
error: You must be logged in to the server (Unauthorized) 
```

Let's now create a manifest that will deploy nginx in the Prod namespace.

<details><summary> prod-nginx.yml </summary>
 
```bash
apiVersion: v1
kind: Pod
metadata:
  name: nginx-demo
  namespace: prod
spec:
  containers:
  - name: nginx-ctr
    image: nginx:latest
    ports:
      - containerPort: 80
```

</details>

Apply the manifest in the prod namespace.

```bash
$ kubectl apply -f prod-nginx.yml -n prod
pod/nginx-demo created 
```

We now have NGINX running in two namespaces: in the default and in prod. *k8s-user-prodadmin* should only be able to access pods in the *prod* namespace.

```bash
$ kubectl get pods
Error from server (Forbidden): pods is forbidden: User "k8s-user-prodadmin" cannot list resource "pods" in API group "" in the namespace "default" 
```
```bash
$ kubectl get pods -n prod
NAME         READY   STATUS    RESTARTS   AGE
nginx-demo   1/1     Running   0          40s 
```
 

## Part 4: Provide Read-only Access for dedicated namespace

### Create a role and rolebinding for Read-only User 

Switch back to our main *k8s-admin* admin account.

```bash
$ export AWS_PROFILE=k8s-admin 
```
```bash
$ aws sts get-caller-identity 
```

Create the **role-prodviewer.yml**. Make sure to add *prod* in the namespace field.

<details><summary> role-prodviewer.yml </summary>
 
```bash
 kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
    namespace: prod
    name: role-prodviewer
rules:
- apiGroups: [  # "" indicates the core API group
    "",
    "extensions",
    "apps"
    ] 
  resources: [  # can be further limited, e.g. pods, deployments
    "*"
    ]
  verbs: [
    "get", 
    "watch", 
    "list"
    ]
```
 
</details>

Create the **rolebind-prodviewer.yml**. Add the user name *k8s-user-prodviewer* in the name field in the Subjects block.

Under the Roleref, add the name of the role.

<details><summary> rolebind-prodviewer.yml </summary>
 
```bash
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: rolebind-prodviewer
  namespace: prod
subjects:
# You can specify more than one "subject"
- kind: User
  name: k8s-user-prodviewer # "name" is case sensitive
  apiGroup: ""
#   apiGroup: rbac.authorization.k8s.io
roleRef:
  # "roleRef" specifies the binding to a Role / ClusterRole
  kind: Role #this must be Role or ClusterRole
  name: role-prodviewer # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: ""
#   apiGroup: rbac.authorization.k8s.io

```
 
</details>

Apply the role and rolebindings.

```bash
$ kubectl apply -f role-prodviewer.yml 
$ kubectl apply -f rolebind-prodviewer.yml 
```

### Map the Read-only User

Next, edit the the Configmap. 

```bash
$ kubectl edit configmap aws-auth -n kube-system 
```

Add *k8s-user-prodviewer*.

```bash
  mapUsers: |

    - userarn: arn:aws:iam::848587260896:user/k8s-user-2
      username: k8s-user-2
      groups:
       - system:masters

    - userarn: arn:aws:iam::848587260896:user/k8s-user-prodadmin
      username: k8s-user-prodadmin
      groups:
      - role-prodadmin

    - userarn: arn:aws:iam::848587260896:user/k8s-user-prodviewer
      username: k8s-user-prodviewer
      groups:
      - role-prodviewer      
```

Check if the user was saved in the Configmap.

```bash
$ kubectl -n kube-system describe cm aws-auth 
```

### Test Read-only Access

We now have another user that has read-acess to the *prod* namespace only. Switch over to the new profile.

```bash
$ export AWS_PROFILE=k8s-user-prodviewer 
```
```bash
$ aws sts get-caller-identity 
```

Let's test if he's able to retrieve the nodes for all namespaces.

```bash
$ kubectl get nodes
Error from server (Forbidden): nodes is forbidden: User "k8s-user-prodviewer" cannot list resource "nodes" in API group "" at the cluster scope 
```

Checking the nodes for the defailt namespace also returns an error.

```bash
$ kubectl get pods
Error from server (Forbidden): pods is forbidden: User "k8s-user-prodviewer" cannot list resource "pods" in API group "" in the namespace "default" 
```

The user should be able to access pods in the *prod* namespace.

```bash
$ kubectl get pods -n prod
NAME         READY   STATUS    RESTARTS   AGE
nginx-demo   1/1     Running   0          10m52s 
```

Recall that this user has Read-only access. Let's try to the pod.

```bash
$ kubectl delete pod nginx-demo
Error from server (Forbidden): pods "nginx-demo" is forbidden: User "k8s-user-prodviewer" cannot delete resource "pods" in API group "" in the namespace "default" 
```

Right, we need to specify the namespace.

```bash
$ kubectl delete pod nginx-demo -n prod
Error from server (Forbidden): pods "nginx-demo" is forbidden: User "k8s-user-prodviewer" cannot delete resource "pods" in API group "" in the namespace "prod" 
```

How about if we try to delete it by running the command below? This should delete **all** the NGINX pods (if there's more than one pod) in the *prod* namespace.

```bash
$ kubectl delete -f prod-nginx.yml
Error from server (Forbidden): error when deleting "prod-nginx.yml": pods "nginx-demo" is forbidden: User "k8s-user-prodviewer" cannot delete resource "pods" in API group "" in the namespace "prod"
```

As we can see, *k8s-user-prodviewer* cannot do any update or delete action to the running pods because it only has read access to the namespace.


## Cleanup

Whew, that was a lot! Switch over to the main admin account.

```bash
$ export AWS_PROFILE=k8s-admin 
```
```bash
$ aws sts get-caller-identity 
```

Before we officially close this lab, make sure to destroy all resources to prevent incurring additional costs.

```bash
$ time eksctl delete cluster -f eksops.yml 
```

Note that when you delete your cluster, make sure to double check the AWS Console and check the Cloudformation stacks (which we created by eksctl) are dropped cleanly.




