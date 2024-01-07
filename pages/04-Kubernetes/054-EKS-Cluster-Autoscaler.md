
# Amazon EKS - Cluster AutoScaler

The Cluster AutoScaler is responsible for dynamically scaling (in and out) the nodes within a nodegroup.

- not specific to AWS, this is a general Kubernetes concept
- can be based on availability/requests,
- can scale if node is under-utilized
- also possible to have a mixture of on-demand and spot instances
- avaialble RAM and number of CPUs should be similar throughout the noes

For stateful workloads:

- use a nodegroup with single availability zone (AZ)
- underlying EBS volume cannot be shared across AZ

For stateless workloads:

- use a nodegroup with multiple availability zones (AZs)

To learn more, check out this [Github repository](https://github.com/kubernetes/autoscaler).

</details>



<br>

[Back to first page](../../README.md#amazon-elastic-kubernetes-service)