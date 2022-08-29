
# Kubernetes in the Cloud

## EKS - Elastic Kubernetes Service

**Amazon EKS** is the Kubernetes offering from AWS which allows users to deploy a management plane. 

AWS basically provides the control plane and all it components, and it's up to the users to provision where their workload will run. The workloads can run on Fargate or EC2.

Benefits of EKS:

- no control plane to manage
- built-in loadbalancing, networking, volume storage 
- easy to turn on and off
- integrations with other AWS components to build applications (S3, Redshift, RDS, Lambda, COgnito, etc.)

## ECS and Fargate

**Amazon ECS** is a proprietary Docker management service developed first to compete with Kubernetes.

- uses JSON task definition
- similar with EKS in many ways but the main difference is that it's proprietary 

**Amazon Fargate**, on the other hand, is a container service that is done in a serverless fashion.

- no node to manage
- No scaling management
- Fargate can be used with EKS and ECS
- JSON task definition
- only pay for active pods, not active node

Now, if you decide to go for Fargate, here are some important reminders:

- container service needs to map tp Fargate CPU or memory tier
- mapping is based on largest sum of resources
- mapping also consumes 250M cores, and 512Mi memory

</details>