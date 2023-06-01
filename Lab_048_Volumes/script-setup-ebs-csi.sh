#!/bin/bash

# This script creates every resource needed for this lab:

# - Create an IAM OIDC provider for your cluster
# - Create the required IAM policy and role
# - Deploy EBS CSI driver

MYREGION=ap-southeast-1
MYCLUSTER=eksops 
MYAWSID=$(aws sts get-caller-identity | python3 -c "import sys,json; print (json.load(sys.stdin)['Account'])")

#--------------------------------------------------------------------------------------------------------------

## Creating an IAM OIDC provider for your cluster

# Create an IAM OIDC provider for your cluster
eksctl utils associate-iam-oidc-provider \
--cluster $MYCLUSTER \
--region $MYREGION \
--approve

oidc_id=$(aws eks describe-cluster --name $MYCLUSTER --region $MYREGION --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)

MYOID=$(aws iam list-open-id-connect-providers | grep $oidc_id | awk -v FS='/id/' '{print $2}' | cut -d '"' -f1)

#--------------------------------------------------------------------------------------------------------------

## Create the required IAM policy and role

# Create an IAM policy named Amazon_EBS_CSI_Driver:
curl -o example-iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/v0.9.0/docs/example-iam-policy.json

aws iam create-policy \
--policy-name AmazonEKS_EBS_CSI_Driver_Policy \
--policy-document file://example-iam-policy.json

# Create an IAM trust policy file. 
cat <<EOF > trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$MYAWSID:oidc-provider/oidc.eks.$MYREGION.amazonaws.com/id/$MYOID"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.$MYREGION.amazonaws.com/id/$MYOID:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
}
EOF

# Create an IAM role and attach the new policy.
aws iam create-role \
  --role-name AmazonEKS_EBS_CSI_DriverRole \
  --assume-role-policy-document file://"trust-policy.json"

aws iam attach-role-policy \
--policy-arn arn:aws:iam::$MYAWSID:policy/AmazonEKS_EBS_CSI_Driver_Policy \
--role-name AmazonEKS_EBS_CSI_DriverRole

#--------------------------------------------------------------------------------------------------------------

## Deploy EBS CSI driver

# Deploy the EBS driver
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

# Annotate the ebs-csi-controller-sa Kubernetes service account with the Amazon Resource Name (ARN) of the IAM role.
kubectl annotate serviceaccount ebs-csi-controller-sa \
-n kube-system \
eks.amazonaws.com/role-arn=arn:aws:iam::$MYAWSID:role/AmazonEKS_EBS_CSI_DriverRole

# Delete the driver pods so that EKS can re-deploy the Pods with the new permissions.
kubectl delete pods \
  -n kube-system \
  -l=app=ebs-csi-controller

