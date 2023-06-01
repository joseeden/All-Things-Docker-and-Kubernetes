#!/bin/bash

MYREGION=ap-southeast-1
MYCLUSTER=eksops 
MYAWSID=$(aws sts get-caller-identity | python3 -c "import sys,json; print (json.load(sys.stdin)['Account'])")

#--------------------------------------------------------------------------------------------------------------

## Deploy Kubernetes Dashboard

# Download the metrics server.
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.1/components.yaml

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

echo "-------------------------------------------------"
# Print deployment
kubectl get deployment metrics-server -n kube-system