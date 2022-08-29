
# Error Guide 


- [Error: Cannot View Kubernetes Nodes](#error-cannot-view-kubernetes-nodes)
- [Error: Failing to Delete CloudFormation Stack](#error-failing-to-delete-cloudformation-stack)


## Error: Cannot View Kubernetes Nodes 

**Problem:**

You might get the following error when checking the EKS cluster through the AWS Console.

```bash
Your current user or role does not have access to Kubernetes objects on this EKS cluster 
```

**Cause:**

You might be using two different IAM user accounts:

- IAM-user1 - you originally use this to log-in to the AWS Management Console 
- IAM-user2 - this is the new user you created and generated the access key 

In the terminal, you set up the CLI access to connect to your AWS resources by editing
the credentials file. 

```bash
$ vim ~/.aws/credentials 
```

Check the identity.

```bash
$ aws sts get-caller-identity  
```

If the user returned is the same as the user currently logged-in the AWS Management Console, then you shouldn't have any issue.

If they're different users, then that means the user in the CLI (this is the user you used to create the EKS cluster) has different permissions from the user logged in the console.

**Solution:**

You may try to log-in to the console using the same identity that you used in the CLI.
If error still appeared, you may need to attach the inline policy to the group.

![](../../Images/labxx-attachinlinepolicytogroupjson.png)  

In the next page, choose the JSON tab and enter the following policy. Make sure to replace 111122223333 with your account ID.

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:ListFargateProfiles",
                "eks:DescribeNodegroup",
                "eks:ListNodegroups",
                "eks:ListUpdates",
                "eks:AccessKubernetesApi",
                "eks:ListAddons",
                "eks:DescribeCluster",
                "eks:DescribeAddonVersions",
                "eks:ListClusters",
                "eks:ListIdentityProviderConfigs",
                "iam:ListRoles"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ssm:GetParameter",
            "Resource": "arn:aws:ssm:*:111122223333:parameter/*"
        }
    ]
}   
```

Click **Review Policy**, then in the next page, create a name for the policy. Click **Create Policy.** 

Next, create a rolebinding. If you need to change the Kubernetes group name, namespace, permissions, or any other configuration in the file, then download the file and edit it before applying it to your cluster

```bash
$ curl -o eks-console-full-access.yaml https://s3.us-west-2.amazonaws.com/amazon-eks/docs/eks-console-full-access.yaml
```
```bash
$ curl -o eks-console-restricted-access.yaml https://s3.us-west-2.amazonaws.com/amazon-eks/docs/eks-console-restricted-access.yaml 
```

You can apply any of the two YAML files.

```bash
$ kubectl apply -f eks-console-full-access.yaml
```
```bash
$ kubectl apply -f eks-console-restricted-access.yaml
```

Next, map the IAM user or role to the Kubernetes user or group in the aws-auth ConfigMap using eksctl.

```bash
export MYCLUSTER=<put-name-of-the-cluster-here> 
export MYREGION=<put-region-code-here> 
export MYACCOUNTID=<put-account-id-here>
export MYUSER=<put-user-id-here>
```

View the current mappings.

```bash
eksctl get iamidentitymapping --cluster $MYCLUSTER --region=$MYREGION 
```

Add a mapping for a role.

```bash
eksctl create iamidentitymapping \
    --cluster $MYCLUSTER \
    --region=$MYREGION \
    --arn arn:aws:iam::$MYACCOUNTID:role/my-console-viewer-role \
    --group eks-console-dashboard-full-access-group \
    --no-duplicate-arns 
```

Add a mapping for a user.

```bash
eksctl create iamidentitymapping \
    --cluster $MYCLUSTER \
    --region=$MYREGION \
    --arn arn:aws:iam::$MYACCOUNTID:user/$MYUSER \
    --group eks-console-dashboard-restricted-access-group \
    --no-duplicate-arns
```

To learn more, check out these links:

- [Can't see Nodes on the Compute tab/Resources tab](https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting_iam.html#security-iam-troubleshoot-cannot-view-nodes-or-workloads)

- [View Kubernetes resources](https://docs.aws.amazon.com/eks/latest/userguide/view-kubernetes-resources.html#view-kubernetes-resources-permissions)



## Error: Failing to Delete CloudFormation Stack 

**Problem:** 

When you try to delete the cluster using the command below, you get an error that says it failed to delete the cluster.

```bash
$ eksctl delete cluster -f manifest.yml 
```

When you go to > CloudFormation dashboard > Stacks > *eksctl-yourcluster*, and then check the Events, you might see this two errors:

When CloudFormation tries to create the node instance profile: 

```bash
Resource handler returned message: "User: arn:aws:iam::12345678910:user/k8s-admin is not authorized to perform: iam:RemoveRoleFromInstanceProfile on resource: instance profile eksctl-eksops-nodegroup-mynodegroup-NodeInstanceProfile-qNlJ2ojEWOdP because no identity-based policy allows the iam:RemoveRoleFromInstanceProfile action (Service: Iam, Status Code: 403, Request ID: b90e26ea-97ff-453b-8e4d-8353c39a3a9b, Extended Request ID: null)" (RequestToken: 139ad70a-2b04-9797-697d-85530cb2496b, HandlerErrorCode: GeneralServiceException) 
```

After the stack failed, CloudFormation tried to rollback but fails to delete the node instance profile:

```bash
Resource handler returned message: "User: arn:aws:iam::12345678910:user/k8s-admin is not authorized to perform: iam:CreateInstanceProfile on resource: arn:aws:iam::12345678910:instance-profile/eksctl-eksops-nodegroup-mynodegroup-NodeInstanceProfile-qNlJ2ojEWOdP because no identity-based policy allows the iam:CreateInstanceProfile action (Service: Iam, Status Code: 403, Request ID: 8f3b2448-5ff3-40b9-80c8-12aeb56eb692, Extended Request ID: null)" (RequestToken: 0b93aa73-eb81-1650-0f47-56a3a476f5b3, HandlerErrorCode: GeneralServiceException)
```

**Cause:**

Your IAM user account doesn't have the needed permissions.

**Solution:** 

As I have had many attempts in resolving the issue, the best option is to create the cluster with the IAM user that has an *AdministratorAccess*. This isn't recommended but this completely solves the issue.

You may also refer to the EKSFullAccess policy file that I have created. It contains the minimum AWS IAM permissions to do EKS operations using eksctl and kubectl.

You may also check out these links:

- [Controlling Access to the Kubernetes API](https://kubernetes.io/docs/concepts/security/controlling-access/)

- [Using Node Authorization](https://kubernetes.io/docs/reference/access-authn-authz/node/)

- [Manage IAM users and roles](https://eksctl.io/usage/iam-identity-mappings/)

- [Configure Kubernetes Role Access](https://www.eksworkshop.com/beginner/091_iam-groups/configure-aws-auth/)

- [How do I resolve an unauthorized server error when I connect to the Amazon EKS API server?](https://aws.amazon.com/premiumsupport/knowledge-center/eks-api-server-unauthorized-error/)

- [Fail to create new cluster with service role error #2182](https://github.com/weaveworks/eksctl/issues/2182)

- [Document minimum IAM requirements #204](https://github.com/weaveworks/eksctl/issues/204)

- [usage of EKS Service IAM Role #122](https://github.com/weaveworks/eksctl/issues/122)


