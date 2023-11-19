
#!/bin/bash

# Setup the EKS cluster and EFS Filesystem using terraform 
terraform -chdir="../terraform_templates" init
terraform -chdir="../terraform_templates" fmt
terraform -chdir="../terraform_templates" apply -auto-approve

# Update the kubeconfig file
xxxx
xxxx
kubectl config use-context <cluster-name>

# Make the script executable
chmod +x ./setup-kube-dashboard.sh
./setup-kube-dashboard.sh

# Create namespace


# Install EFS Driver using Terraform 


# Create EFS Filesystem using Terraform 

