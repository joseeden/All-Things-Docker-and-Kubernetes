
# Error: Failing to Delete CloudFormation Stack 

- [Problem](#problem)
- [Cause](#cause)
- [Solution](#solution)


## Problem

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

## Cause

Your IAM user account doesn't have the needed permissions.

## Solution

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



<br>

[Back to first page](../../README.md#troubleshooting-guides)