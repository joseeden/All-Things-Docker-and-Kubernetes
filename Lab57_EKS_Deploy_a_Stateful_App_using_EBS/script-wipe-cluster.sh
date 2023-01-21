#!/bin/bash

kubectl delete -f pvc-claim.yml -n ns-lab57 
kubectl delete -f sc-lab57.yml -n ns-lab57 
kubectl delete deployments -n kube-system  ebs-csi-controller 
# time eksctl delete cluster -f eksops.yml

MYREGION=ap-southeast-1
MYCLUSTER=eksops
MYAWSID=$(aws sts get-caller-identity | python3 -c "import sys,json; print (json.load(sys.stdin)['Account'])")

# Deletes IAM resources

# Detach role policy.
aws iam detach-role-policy  \
--role-name AmazonEKS_EBS_CSI_DriverRole \
--policy-arn arn:aws:iam::$MYAWSID:policy/AmazonEKS_EBS_CSI_Driver_Policy

# Delete the IAM policy.
aws iam delete-policy \
--policy-arn arn:aws:iam::$MYAWSID:policy/AmazonEKS_EBS_CSI_Driver_Policy

# Delete the role.
aws iam delete-role --role-name AmazonEKS_EBS_CSI_DriverRole

# Delete the OIDC associated to the cluster.
ACCOUNT_ID=$(aws sts get-caller-identity | python3 -c "import sys,json; print (json.load(sys.stdin)['Account'])")
OIDCURL=$(aws eks describe-cluster --name $MYCLUSTER --region $MYREGION --query "cluster.identity.oidc.issuer" --output text  | python3 -c "import sys; print (sys.stdin.readline().replace('https://',''))")
aws iam delete-open-id-connect-provider --open-id-connect-provider-arn arn:aws:iam::$MYAWSID:oidc-provider/$OIDCURL  2>/dev/null
