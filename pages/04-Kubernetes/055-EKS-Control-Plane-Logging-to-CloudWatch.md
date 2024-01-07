
# Amazon EKS - Control Plane Logging to CloudWatch

Since the Control Plane is managed by AWS, we don't have access to the hosts that are serve the Control Plane and manages the logs. We can access these logs thru CloudWatch by enabling which log type to send.

**Log Types**

- API
- Audit 
- Authenticator 
- Control Manager 
- Scheduler 

We can access the logs by going to the CloudWatch dashboard in the AWS Management Console.

- each log type creates its own CloudWatch log stream 
- prefixed with <code>/aws/eks/cluster-name</code>
- this adds [additional costs](https://aws.amazon.com/cloudwatch/pricing/) for storage and collection



<br>

[Back to first page](../../README.md#amazon-elastic-kubernetes-service)