
# Kubeconfig files 

## Kubeconfig 

A **kubeconfig** file is used to define how to connect to the Kubernetes cluster. It contains the following information:

- certificate information, for authentication 
- cluster location 

If you used **kubeadm** to setup Kubernetes, you'll see that it creates a collection of kubeconfig files which are stored in <code>/etc/kubernetes</code>.

Here are some files that kubeadm generates:

- **admin.conf** - configuration for the super admin account

- **kubelet.conf** - helps the kubelet locate the API server and present the correct client certificate

- **controller-manager.conf** - tells kubelet the API server location and the client certificate to use

- **scheduler.conf** - tells kubelet the API server location and the client certificate to use

