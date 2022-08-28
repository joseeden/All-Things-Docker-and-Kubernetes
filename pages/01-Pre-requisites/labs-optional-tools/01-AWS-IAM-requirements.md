
# IAM Requirements


- [Create the IAM Policy](#create-the-iam-policy)
- [Create the Service-linked Role](#create-the-service-linked-role)
- [Create the IAM User, Access Key, and Keypair](#create-the-iam-user-access-key-and-keypair)
- [Create the IAM Group](#create-the-iam-group)
- [Configure the Credentials File](#configure-the-credentials-file)


----------------------------------------------

## Create the IAM Policy

Create the **EKSFullAccess** policy that allows us access to EKS and ECR.

1. Go to IAM console.
2. In the left panel, click Policies.
3. Click Create Policy.
4. Choose the JSON tab and paste the [EKSFullAccess](EKSFullAccess.json) policy.
5. Click Review Policy.
6. Give the policy the name and description.

    Name: EKSFullAccess
    Description: Allows full admin access for EKS and ECR resources.

7. Finally, click Create Policy.

## Create the Service-linked Role

To [create a service-linked role](https://us-east-1.console.aws.amazon.com/iamv2/home#/roles):

1. Log-in to your AWS Management Console and go to IAM dashboard.
2. in the left menu, click *Roles* > *Create Role*
3. In the *Select trusted entity page*, choose *AWS Service.*
4. In the *Use cases for other AWS services*, type EKS.
5. Select the *EKS (Allow EKS to manage clusters in your behalf)* then click Next > Next
6. In the *Name, review, and create* step, git it a name: EKSServiceRole click *Create role*.

Back at the Roles page, click the role you just created to show the details. Copy the ARN. We'll be using it in the IAM Policy next.

```bash
arn:aws:iam::1234567890:role/aws-service-role/eks.amazonaws.com/AWSServiceRoleForAmazonEKS 
```

## Create the IAM User, Access Key, and Keypair

Refer to the links below.

- [Create a "k8s-kp.pem" keypair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html)

- [Create a "k8s-admin"](https://www.techrepublic.com/article/how-to-create-an-administrator-iam-user-and-group-in-aws/)

- [Create an access key for "k8s-admin"](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey)

For the keypair, store it inside <code>~/.ssh</code> directory.


## Create the IAM Group

Create the **k8s-lab** group.

1. Go to IAM console.
2. In the left panel, click User Groups.
3. Click Create group
4. Give it a user group name: *k8s-lab*
5. Scroll below to the Attach User section. Choose "k8s-admin" and the current user you're signed in to.
6. Scroll below to the Attach permission policies.
7. Filter and add the following policy.

    - AmazonEC2FullAccess
    - AmazonEKSClusterPolicy
    - AmazonEKSWorkerNodePolicy
    - AmazonS3FullAccess
    - AmazonSNSReadOnlyAccess (for CloudFormation)
    - AmazonEKSServicePolicy
    - AWSCloudFormationFullAccess
    <!-- - IAMReadOnlyAccess -->

8. Finally, click Create group.
9. You may add the new user to this group.

**Note**: You may encounter some issue when using this user with limited IAM permissions. As a workaround, you can attach the *AdministratorAccess* to the user.

## Configure the Credentials File

In your terminal, configure the <code>.aws/credentials</code> file that's automatically created in your home directory. 

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
