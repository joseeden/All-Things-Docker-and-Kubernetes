#!/bin/bash

# This script creates every resource needed for this lab:

# - Deploy kubernetes dashboard
# - Create a namespace "ns-lab57"
# - Create an IAM OIDC provider for your cluster
# - Deploy EBS CSI driver
# - Create Storageclass

MYREGION=ap-southeast-1
MYCLUSTER=eksops 
MYAWSID=$(aws sts get-caller-identity | python3 -c "import sys,json; print (json.load(sys.stdin)['Account'])")

#--------------------------------------------------------------------------------------------------------------

## Deploy Kubernetes Dashboard

# Download the metrics server.
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.1/components.yaml
print $(kubectl get deployment metrics-server -n kube-system)

# Deploy the Kubernetes dashboard.
export KB_VER=v2.5.1
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/$KB_VER/aio/deploy/recommended.yaml

# Create the service account that we'll use to authenticate to the Kubernetes dashboard.
cat <<EOF > kube-dashboard-admin-svc.yml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kb-admin-svc
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kb-admin-svc
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: kb-admin-svc
    namespace: kube-system
EOF

# Apply the YAML file.
kubectl apply -f kube-dashboard-admin-svc.yml

# Get the bearer token of the service account that we just created and save it to a file.
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep kb-admin-svc | awk '{print $1}') > kube-dashboard-token.txt

# Run this command to access Dashboard from your local workstation.
kubectl proxy &


#--------------------------------------------------------------------------------------------------------------

## Create a namespace

kubectl create ns ns-lab57

#--------------------------------------------------------------------------------------------------------------

## Creating an IAM OIDC provider for your cluster

# Create an IAM OIDC provider for your cluster
eksctl utils associate-iam-oidc-provider \
--cluster $MYCLUSTER \
--region $MYREGION \
--approve

oidc_id=$(aws eks describe-cluster --name $MYCLUSTER --region $MYREGION --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)

MYOID=$(aws iam list-open-id-connect-providers | grep $oidc_id | awk -v FS='/id/' '{print $2}' | cut -d '"' -f1)

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

# Deploys the EBS driver
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

# Annotate the ebs-csi-controller-sa Kubernetes service account with the Amazon Resource Name (ARN) of the IAM role.
kubectl annotate serviceaccount ebs-csi-controller-sa \
-n kube-system \
eks.amazonaws.com/role-arn=arn:aws:iam::$MYAWSID:role/AmazonEKS_EBS_CSI_DriverRole

# Delete the driver pods so that EKS can re-deploy the Pods with the new permissions.
kubectl delete pods \
  -n kube-system \
  -l=app=ebs-csi-controller

#--------------------------------------------------------------------------------------------------------------

## Create Storage Class

# Remove the *default* label on the old **gp2** default storageclass
kubectl patch storageclass gp2 -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

# Create another StorageClass but this time we'll use the external provisioner **ebs.csi.aws.com**. Also make sure to set it as the default storageclass by specifying *true* on the annotation.
cat <<EOF >sc-lab57.yml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: sc-lab57
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com # Amazon EBS CSI driver
volumeBindingMode: Immediate # EBS volumes are AZ specific
reclaimPolicy: Delete
mountOptions:
- debug
EOF

# Apply
kubectl apply -f sc-lab57.yml -n ns-lab57

#--------------------------------------------------------------------------------------------------------------

## Create PVC

kubectl apply -f pvc-claim.yml -n ns-lab57 

#--------------------------------------------------------------------------------------------------------------

## Deploy the Database (MySQL)

MYSQLPW=admin123 
kubectl create secret generic mysql-pass \
--from-literal=password=$MYSQLPW \
-n ns-lab57 
kubectl apply -n ns-lab57 -f deploy-mysql.yml 
