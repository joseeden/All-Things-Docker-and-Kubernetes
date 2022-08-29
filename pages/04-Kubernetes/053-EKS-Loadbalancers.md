
# Amazon EKS - Loadbalancers 

- [AWS Load Balancer Controller](#aws-load-balancer-controller)
- [Classic LoadBalancer](#classic-loadbalancer)
- [Network LoadBalancer](#network-loadbalancer)


Amazon EKS supports the three types of Loadbalancers:

Loadbalancer | Service type B | 
---------|----------|---------
 Classic Loadbalancer | None | 
 Network Loadbalancer | LoadBalancer | 
 Application Loadbalancer | Ingress Controller |


## AWS Load Balancer Controller 

The AWS Load Balancer Controller manages AWS Elastic Load Balancers for a Kubernetes cluster. The controller provisions the following resources:

- An AWS Application Load Balancer (ALB) when you create a Kubernetes Ingress.

- An AWS Network Load Balancer (NLB) when you create a Kubernetes service of type LoadBalancer

Note that it doesn't create AWS Classic Load Balancers. 
It is recommended to use version *2.4.3* or above if your cluster is version *1.19* and above.

To learn more AWS Load Balancer Controller, check out the links below:

- [AWS User Guide on EKS](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)

- [AWS Load Balancer Controller Github page](https://github.com/kubernetes-sigs/aws-load-balancer-controller)

## Classic LoadBalancer

By default, EKS will create a classic loadbalancers when you create a Kubernetes *Service* of type *LoadBalancer*. We can change it by adding the **annotations** in the manifest file.

## Network LoadBalancer

An AWS Network Load Balancer can load balance network traffic to pods deployed to Amazon EC2 IP and instance targets or to AWS Fargate IP targets. 