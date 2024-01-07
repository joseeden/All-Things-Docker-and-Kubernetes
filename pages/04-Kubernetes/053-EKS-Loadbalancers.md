
# Amazon EKS - Loadbalancers 

## LoadBalancers 

Amazon EKS supports the three types of Loadbalancers:

Loadbalancer | Service type B | 
---------|----------|---------
 Classic Loadbalancer | None | 
 Network Loadbalancer | LoadBalancer | 
 Application Loadbalancer | Ingress Controller |

To learn more about loadbalancers, check out [Type LoadBalancer](https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer)

## Annotations 

The configuration of the load balancer is controlled by **annotations** that are added to the manifest files.

We can use either labels or annotations to attach metadata to Kubernetes objects. 

**Labels** can be used to select objects and to find collections of objects that satisfy certain conditions. 

**Annotations**, on the other hand, are not used to identify and select objects. The metadata in an annotation can be small or large, structured or unstructured, and can include characters not permitted by labels.

To learn more, check out [Annotations in Kubernetes.](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)

## AWS Load Balancer Controller 

The **AWS Load Balancer Controller** manages AWS Elastic Load Balancers for a Kubernetes cluster. The controller provisions the following resources:

- An **AWS Application Load Balancer (ALB)** when you create a Kubernetes Ingress.

- An **AWS Network Load Balancer (NLB)** when you create a Kubernetes service of type LoadBalancer

Note that it doesn't create AWS Classic Load Balancers. 
It is recommended to use version *2.4.3* or above if your cluster is version *1.19* and above.

**Service annotations** are different when using the AWS Load Balancer Controller than they are when using the AWS cloud provider load balancer controller. 

To add tags to the load balancer when or after it's created, add the following annotation in your service specification:

```bash
service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags 
```

To learn more AWS Load Balancer Controller, check out the links below:

- [AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)

- [AWS Load Balancer Controller Github page](https://github.com/kubernetes-sigs/aws-load-balancer-controller)

## Classic LoadBalancer

By default, EKS will create a classic loadbalancers when you create a Kubernetes **Service** of type **LoadBalancer**. We can change it by adding the **annotations** in the manifest file.

## Network LoadBalancer

An AWS Network Load Balancer can load balance network traffic to pods deployed to Amazon EC2 IP with either targets.

- To loadbalance traffic across Pods deployed in EC2 nodes, use **instance targets**.

- To loadbalance traffic across Pods deployed in Fargate, use **IP targets**.

### Instance Targets 

It is recommended to use the AWS Load Balancer Controller to creates the Network Load Balancers with instance targets.

To deploy a Network Load Balancer to a private subnet, add the following annotation to your manifest and deploy the services:

```bash
service.beta.kubernetes.io/aws-load-balancer-type: "external"
service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "instance" 
```

The **external** value tells the the AWS Load Balancer Controller (rather than the AWS cloud provider load balancer controller) to create the Network Load Balancer.

If you want to create an Network Load Balancer in a public subnet to load balance to Amazon EC2 nodes, add this annotation:

```bash
service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing" 
```

### IP Targets  

To create an NLB that uses IP targets for the Pods, ad the following annotation to your manifest and deploy the service:

```bash
service.beta.kubernetes.io/aws-load-balancer-type: "external"
service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip" 
```

The **external** value tells the the AWS Load Balancer Controller (rather than the AWS cloud provider load balancer controller) to create the Network Load Balancer. 

If you want to create a Network Load Balancer in a public subnet to load balance to Amazon EC2 nodes (Fargate can only be private), add these annotation:

```bash
service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing" 
```

To assign Elastic IP addresses to NLB, add this to the annotations:

```bash
service.beta.kubernetes.io/aws-load-balancer-eip-allocations: eipalloc-xxxxxxxxxxxxxxxxx,eipalloc-yyyyyyyyyyyyyyyyy 
```

To learn more about NLBs, check out [Network load balancing on Amazon EKS.](https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html)

## Application LoadBalancer

To load balance application traffic at L7, we deploy a **Kubernetes ingress**, which provisions an AWS Application Load Balancer.

- can be used with pods deployed to nodes or to AWS Fargate
- can deploy an ALB to public or private subnets.

To tell the AWS LoadBalancer Controller to create an ALB and its supporting resources when a Kubernetes Ingress is created, we need to add this annotation to our manifest:

```bash
annotations:
    kubernetes.io/ingress.class: alb 
```

To loadbalance on IPv6 pods deployed on IP targets (instance targets not allowed):

```bash
alb.ingress.kubernetes.io/ip-address-type: dualstack 
```

The AWS Load Balancer Controller supports the following traffic modes:

- **Instance mode (default)** 
    - Registers nodes within the cluster as targets
    - Traffic reaching the ALB is routed to NodePort for the service and then proxied to pods. 

- **IP mode**
    - Registers pods as targets for the ALB
    - ALB directly communicates with the Pod

To learn more, [check out Application load balancing on Amazon EKS.](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html)

Details about the open source Ingress can be found in the [Kubernetes documentation.](https://kubernetes.io/docs/concepts/services-networking/ingress/)



<br>

[Back to first page](../../README.md#amazon-elastic-kubernetes-service)