

# All Things Docker and Kubernetes 

This repository contains projects on containerization and orchestration that I'm currently working on in ~~2021~~ the present. 


- [How to Use this Repo](#how-to-use-this-repo)
- [Projects](#projects)
    - [Pre-requisites](#pre-requisites)
    - [Project List](#project-list)
- [Notes](#notes)    
    - [Docker + Containers](#docker--containers)
    - [Cloud-Native](#cloud-native)
    - [Kubernetes](#kubernetes)
    - [Kubernetes Security](#kubernetes-security)
    - [Helm](#helm)
    - [Amazon Elastic Kubernetes Service (EKS)](#amazon-elastic-kubernetes-service)
    - [Azure Kubernetes Service (AKS)](#azure-kubernetes-service)
    - [Google Kubernetes Engine (GKE)](#google-kubernetes-engine)
    - [Troubleshooting Guides](#troubleshooting-guides)
- [Certification Exams](#certification-exams)
    - [Practice Tests](#practice-tests) 
    - [Links](#links) 
- [Resources](#resources)


## How to Use this Repo

- Each project in this repo is equipped with easy-to-follow, detailed instructions. 

- You can also go through the **Docker** and **Kubernetes** notes below for a quick walkthrough.

## Projects

### Pre-requisites

Here are some pre-requisites before we can perform the projects and labs. 

- [For Docker Labs](pages/01-Pre-requisites/labs-docker-pre-requisites/README.md)

- [For Kubernetes Labs](pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md)
 
- [Optional Tools](pages/01-Pre-requisites/labs-optional-tools/README.md)

### Project List 

The complete list of projects can be found [here](projects/README.md).

## Notes 

### Docker + Containers
<!-- 
Containers are where it all starts. -->

<!-- <details><summary> Read more.. 
<br> -->

- [From VMs to Containers](pages/02-Docker-Basics/001-From-VMs-to-Containers.md) 

- [What is Docker?](pages/02-Docker-Basics/002-What-is-Docker.md)

- [The Docker Architecture](pages/02-Docker-Basics/003-The-Docker-Architecture.md)

- [Linux Kernel Features](pages/02-Docker-Basics/004-Linux-Kernel-Features.md) 

- [How Docker runs on Windows](pages/02-Docker-Basics/005-How-Docker-runs-on-Windows.md) 

- [Installing Docker](pages/01-Pre-requisites/labs-docker-pre-requisites/README.md)

- [Using Docker without Root Permission](pages/01-Pre-requisites/labs-docker-pre-requisites/05-Using-Docker-without-Root-permissions.md)

- [Docker Objects](pages/02-Docker-Basics/006-Docker-Object.md) 

- [Tagging the Image](pages/02-Docker-Basics/007-Tagging-the-Image.md)

- [Pushing/Pulling an Image to/from a Container Registry](pages/02-Docker-Basics/008-Push-Pull-to-Dockerhub.md)

- [Docker Commands](pages/02-Docker-Basics/009-Docker-Commands.md) 

- [Attach and Detach Mode](pages/02-Docker-Basics/010-Attach-and-Detach.md) 

- [Inputs](pages/02-Docker-Basics/011-Inputs.md) 

- [Port Mapping](pages/02-Docker-Basics/012-Port-Mapping.md) 

- [Persisting Data](pages/02-Docker-Basics/013-Persisting-Data.md)

- [Logs](pages/02-Docker-Basics/014-Logs.md)

- [Environment Variables](pages/02-Docker-Basics/015-Environment-Variables.md) 

- [CMD and ENTRYPOINT](pages/02-Docker-Basics/016-CMD-and-Entrypoint.md) 

- [Docker Networking](pages/02-Docker-Basics/017-Docker-Networking.md) 

- [Docker Compose](pages/02-Docker-Basics/018-Docker-Compose.md) 

- [Docker Compose Commands](pages/02-Docker-Basics/019-Docker-Compose-Commands.md) 

- [Status Codes and Restart Policies](pages/02-Docker-Basics/020-Status-Codes-and-Restart-Policies.md) 

- [Docker Swarms](pages/02-Docker-Basics/021-Docker-Swarms.md) 

- [Container Security](pages/02-Docker-Basics/022-Docker-Security.md) 

- [Container Best Practices](pages/02-Docker-Basics/023-Container-Best-Practices.md) 


<!-- </details> -->


### Cloud Native
<!-- 
When you have containers, you have cloud-native applications.  -->

- [What is Cloud Native?](pages/03-Cloud-Native/001-What-is-Cloud-Native.md) 
 
- [Containers and being Cloud Native](pages/03-Cloud-Native/002-Containers-and-being-Cloud-Native.md) 

- [Cloud-Native Landscape](pages/03-Cloud-Native/003-Cloud-Native-Landscape.md) 

- [Business and Technical Considerations](pages/03-Cloud-Native/004-Business-and-Technical-Considerations.md) 

- [Design Considerations](pages/03-Cloud-Native/005-Design-Considerations.md) 

- [Monoliths and Microservices](pages/03-Cloud-Native/006-Monoliths-and-Microservices.md) 

- [Tradeoffs](pages/03-Cloud-Native/007-Tradeoffs.md) 

- [Best Practices for Application Deployments](pages/03-Cloud-Native/008-Best-Practice-for-App-Deployments.md) 

- [Product is Released, What's Next?](pages/03-Cloud-Native/009-Product-is-Released-Whats-Next.md) 


### Kubernetes
<!-- 
Kubernetes is indeed an entire universe in itself.  -->

- [Container Management Challenges](pages/04-Kubernetes/001-Container-Management-Challenges.md) 

- [What is Kubernetes](pages/04-Kubernetes/002-What-is-Kubernetes.md) 

- [Kubernetes API Objects](pages/04-Kubernetes/004-Kubernetes-API-Objects.md) 

- [Kubernetes Cluster](pages/04-Kubernetes/005-Kubernetes-Cluster.md) 

- [Pod Operations](pages/04-Kubernetes/006-Pod-Operations.md) 

- [Kubernetes Networking](pages/04-Kubernetes/007-Kubernetes-Networking.md) 

- [Setting up Kubernetes](pages/04-Kubernetes/008-Setting-up-Kubernetes.md)

- [Kubeconfig file](pages/04-Kubernetes/009-kubeconfig-files.md)

- [Kubernetes API](pages/04-Kubernetes/040-kubernetes-api.md)

- [Enabling API versions for API Groups](pages/04-Kubernetes/041-enabling-api-versions.md)

- [Changing deprecated API versions using kubectl convert](pages/04-Kubernetes/042-changing-deprecated-apo-versions.md)

- [Custom Resources](pages/04-Kubernetes/043-custom-resource.md)

- [Manifests](pages/04-Kubernetes/018-Manifests.md)

- [Pods](pages/04-Kubernetes/009-Pods.md) 

- [Static Pods](pages/04-Kubernetes/009-Static-Pods.md)

- [Scheduling](pages/04-Kubernetes/022-Scheduling-pods.md)

- [DaemonSets](pages/04-Kubernetes/010-DaemonSets.md) 

- [Labels, Selectors, and Annotations](pages/04-Kubernetes/034-Labels-seclector-annotations.md)

- [Jobs and CronJobs](pages/04-Kubernetes/035-jobs-cronjobs.md)

- [Taints and Tolerations](pages/04-Kubernetes/022-Taints-and-tolerations.md)

- [Node Selectors and Node Affinity](pages/04-Kubernetes/023-NODESLSECTOR.MD)

- [Pod Affinity](pages/04-Kubernetes/024-Pod-affinity.md)

- [Resource Requirements](pages/04-Kubernetes/025-Container-resource-requirements.md)

- [ReplicaSets](pages/04-Kubernetes/011-ReplicaSets.md) 

- [Scaling](pages/04-Kubernetes/012-Scaling.md) 

- [Services](pages/04-Kubernetes/013-Services.md)

- [ClusterIP](pages/04-Kubernetes/013-Services.md)

- [Nodeport](pages/04-Kubernetes/013-Services.md)

- [External Name](pages/04-Kubernetes/013-Services.md)

- [Kubernetes Ingress](pages/04-Kubernetes/013-Services.md)

- [Deployments](pages/04-Kubernetes/014-Deployments.md) 

- [Rollouts and Rollbacks](pages/04-Kubernetes/019-Rollouts-and-Rollbacks.md)

- [Probes, Sidecar Containers, and Init Containers](pages/04-Kubernetes/020-Probes.md)

- [Volumes and StorageClasses](pages/04-Kubernetes/017-StorageClass.md)

- [ConfigMaps and Secrets](pages/04-Kubernetes/021-Configmaps.md)

- [Certificate Authority](pages/04-Kubernetes/015-Certificate-Authority.md) 

- [Stateless vs. Stateful](pages/04-Kubernetes/016-Stateful-vs-Stateless.md)

- [Application Lifecycle Management](pages/04-Kubernetes/036-App-Lifecycle-Management.md)

- [Kubernetes Dashboard](pages/04-Kubernetes/027-Kubernetes-Dashboard.md)

- [Kubernetes Commands](pages/04-Kubernetes/049-Cheatsheet-Kubernetes-Commands.md) 

- [Cluster Maintenance](pages/04-Kubernetes/037-Cluster-maintenance.md)

- [Back Up, Restore and Upgrade Clusters](projects/Lab_021_Backup_Restore_and_Upgrade_a_Kubernetes_Cluster/README.md)

- [Kubernetes Ecosystem](pages/04-Kubernetes/026-kubernetes-ecosystem.md)

- [CNCF Projects](pages/04-Kubernetes/029-CNCF-Projects.md)

- [Kubernetes in the Cloud](pages/04-Kubernetes/039-Kubernetes-in-the-Cloud.md) 

- [Kubernetes Patterns for Application Developers](pages/04-Kubernetes/033-Kubernetes-patterns.md) 


### Kubernetes Security 

- [The 4Cs of Cloud Native Security](pages/04-Kubernetes/028-Kubernetes-Security-4cs.md)

- [Cluster Hardening](#kubernetes-security)

    - [CIS Security Benchmarks](pages/04-Kubernetes/028-Kubernetes-Security-Security-Benchmarks.md)

    - [CIS-CAT Pro Assessor](pages/04-Kubernetes/028-Kubernetes-Security-Security-Benchmarks.md)

    - [Kube-bench](pages/04-Kubernetes/028-Kubernetes-Security-Security-Benchmarks.md)

    - [Security Primitives](pages/04-Kubernetes/028-Kubernetes-Security-primitives.md)

    - [Authentication and Authorization](pages/04-Kubernetes/028-Kubernetes-Security-authentication-authorization.md) 

    - [Authentication Mechanisms](pages/04-Kubernetes/028-Kubernetes-Security-authentication-mechanisms.md) 

    - [Authorization Mechanisms](pages/04-Kubernetes/028-Kubernetes-Security-authorization-mechanisms.md) 

    - [Role-Based Access Control](pages/04-Kubernetes/028-Kubernetes-Security-roles-and-rolebindings.md) 

    - [Service Accounts](pages/04-Kubernetes/028-Kubernetes-Security-Service-Accounts.md)

    - [TLS Certificates](pages/04-Kubernetes/028-Kubernetes-Security-tls-certificates.md)

    - [Security Contexts](pages/04-Kubernetes/028-Kubernetes-Security.md) 

    - [Kubelet Security](pages/04-Kubernetes/028-Kubernetes-Security-Kubelet.md) 

    - [Kubectl Proxy and Port Forwarding](pages/04-Kubernetes/028-Kubernetes-Security-Kubectl-Port-Forwarding.md) 

    - [Kubernetes Dashboard](pages/04-Kubernetes/027-Kubernetes-Dashboard.md)

    - [Network Policy](pages/04-Kubernetes/027-Kubernetes-Security-Network-Policy.md)

    - [Ingress](pages/04-Kubernetes/027-Kubernetes-Security-Ingress.md)

    - [Securing the Docker Daemon](pages/04-Kubernetes/027-Kubernetes-Security-Docker-Service-Configurations.md)

    - [Securing Control Plane Communications with Ciphers](pages/04-Kubernetes/027-Kubernetes-Security-securing-controlplane-comms.md)

- [System Hardening](#kubernetes-security)

    - [Least Privilege Principle](pages/04-Kubernetes/028-Least-Privilege-Principle.md)

    - [Limit Node Access](pages/04-Kubernetes/028-Limit-node-access.md)
    
    - [SSH Hardening](pages/04-Kubernetes/028-SSH-Hardening.md)

    - [Linux Privilege Escalation](pages/04-Kubernetes/028-Linux-Privilege-Escalation.md)

    - [Remove Obsolete Packages and Services](pages/04-Kubernetes/028-Remove-Obsolete-Packages.md)

    - [Restrict Kernel Modules](pages/04-Kubernetes/028-Restrict-Kernel-Modules.md)

    - [Identify and Disable Open Ports](pages/04-Kubernetes/028-Identify-and-disable-open-ports.md)

    - [Minimize IAM Roles](pages/04-Kubernetes/028-Minimize-IAM-Roles.md)

    - [Restrict Network Access](pages/04-Kubernetes/028-Restrict-Network-Access.md)

    - [Tracing Linux Syscalls](pages/04-Kubernetes/028-Linux-syscalls.md)

    - [Restricting Linux Syscalls through Seccomp](pages/04-Kubernetes/028-Seccomp.md)

    - [AppArmor](pages/04-Kubernetes/028-AppArmor.md)

    - [Linux Capabilities](pages/04-Kubernetes/028-Linux-Capabilities.md)

- [Minimize Microservice Vulnerabilities](#kubernetes-security)

    - [Admission Controllers](pages/04-Kubernetes/028-Admission-Controllers.md)

    - [Pod Security](pages/04-Kubernetes/028-Pod-Security.md)

    - [Managing Kubernetes Secrets](pages/04-Kubernetes/021-Configmaps.md)

    - [Open Policy Agent](pages/04-Kubernetes/028-Open-Policy-Agent.md)

    - [Container Sandboxing](pages/04-Kubernetes/028-Container-sandboxing.md)

    - [One-way SSL and Mutual SSL](pages/04-Kubernetes/028-Mutual-SSL.md)

- [Supply Chain Security](#kubernetes-security)

    - [Image Security and Best Practices](pages/04-Kubernetes/028-Minimize-base-image-footprint.md)

    - [Whitelist Allowed Registries](pages/04-Kubernetes/028-Whitelist-allowed-registries.md)

    - [Static Analysis of User Workloads](pages/04-Kubernetes/028-Static-Analysis-of-User-Workloads.md)

    - [Scan images for known vulnerabilities](pages/04-Kubernetes/028-Scan-images-for-known-vulerabilities.md)


- [Monitoring, Logging, and Runtime Security](#kubernetes-security)

    <!-- - [Perform behavioral analytics of syscall process](pages/04-Kubernetes/028-Perform-behavioral-analytics-of-syscall-process.md)
    -->
    - [Falco](pages/04-Kubernetes/028-Falco.md)

    - [Mutable and Immutable Infrastructure](pages/04-Kubernetes/028-Mutable-and-Immutable-Infrastructure.md)
   
    - [Use Audit Logs to monitor access](pages/04-Kubernetes/028-Use-audit-logs-to-monitor-access.md)






### Helm 

- [Helm Package Manager](pages/04-Kubernetes/030-Helm-Package-Manager.md) 

- [Helm Chart and Templates](pages/04-Kubernetes/032-Helm-Chart-and-Templates.md)

- [Helm Commands](pages/04-Kubernetes/031-Helm-commands.md)



### Amazon Elastic Kubernetes Service 

- [Amazon EKS - Managed Kubernetes](pages/04-Kubernetes/050-EKS-Managed-Kubernetes.md) 

- [Amazon EKS - Pricing](pages/04-Kubernetes/051-EKS-Pricing.md) 

- [Amazon EKS - IAM and RBAC](pages/04-Kubernetes/052-EKS-IAM-and-RBAC.md)  

- [Amazon EKS - Networking](pages/04-Kubernetes/056-EKS-Networking.md)

- [Amazon EKS - Loadbalancers](pages/04-Kubernetes/053-EKS-Loadbalancers.md) 

- [Amazon EKS - Cluster AutoScaler](pages/04-Kubernetes/054-EKS-Cluster-Autoscaler.md) 

- [Amazon EKS - Logging to CloudWatch ](pages/04-Kubernetes/055-EKS-Control-Plane-Logging-to-CloudWatch.md) 

- [Amazon EKS - Persistent Volumes](pages/04-Kubernetes/056-EKS-Persistent-Volumes.md)    

- [Amazon EKS - Self-managed vs. Managed Nodegroups](pages/04-Kubernetes/057-EKS-Nodegroups.md)      



<!-- ### Azure Kubernetes Service 



### Google Kubernetes Engine -->




### Troubleshooting Guides 

- [Log Locations](pages/04-Kubernetes/097-Tshooting-basics.md) 

- [Error: Cannot View Kubernetes Nodes](pages/04-Kubernetes/099-Error-Guide.md)

- [Error: Failing to Delete CloudFormation Stack](pages/04-Kubernetes/098-Error-Failing-to-delete-cloudformation-stack.md)

- [Default etcd port](pages/04-Kubernetes/097-etcd-default-server-port.md)


## Certification Exams 

### Practice Tests

- [Certified Kubernetes Administrator (CKA)](pages/05-Exams/002-Practice-Test-CKA.md)
- [Certified Kubernetes Application Developer (CKAD)](pages/05-Exams/015-Practice-Test-CKAD.md)

### Links  

- [Exam Tips](pages/05-Exams/001-Exam-tips.md)    

- [Open Source Curriculum for CNCF Certification Courses](https://github.com/cncf/curriculum)

- [Certified Kubernetes Administrator (CKA)](https://www.cncf.io/certification/cka/)

- [Certified Kubernetes Application Developer (CKAD)](https://www.cncf.io/training/certification/ckad/)

- [Certified Kubernetes Security Specialist (CKS)](https://www.cncf.io/training/certification/cks/)

- [Important Instructions: CKA and CKAD](https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad)

- [Linux Foundation Certification Exam: Candidate Handbook](https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2)

## Resources

Useful courses on Docker:

- [Docker in Production Using Amazon Web Services](https://www.pluralsight.com/courses/docker-production-using-amazon-web-services)

- [Building, Deploying, and Running Containers in Production](https://cloudacademy.com/learning-paths/building-deploying-and-running-containers-in-production-1-888/#)

- [Docker and Kubernetes: The Complete Guide](https://www.udemy.com/course/docker-and-kubernetes-the-complete-guide/)

- [Docker in Production Using Amazon Web Services](https://www.pluralsight.com/courses/docker-production-using-amazon-web-services)

- [The Complete Practical Docker Guide](https://www.oreilly.com/library/view/the-complete-practical/9781803247892/)

- [Complete AWS ECS Bootcamp (Beginner friendly)](https://www.udemy.com/course/aws-ecs-devops-masterclass/)

 
Useful courses on Kubernetes:

- [Getting Started with Kubernetes LiveLessons, 2nd Edition](https://www.oreilly.com/library/view/getting-started-with/9780136787709/)

- [Hands-on Kubernetes](https://www.oreilly.com/library/view/hands-on-kubernetes/9780136702887/)

- [Learning Path - Kubernetes Administration](https://www.pluralsight.com/paths/kubernetes-administration)

- [Learning Path - Using Kubernetes as a Developer](https://www.pluralsight.com/paths/using-kubernetes-as-a-developer)

- [Learn DevOps: The Complete Kubernetes Course](https://www.udemy.com/course/learn-devops-the-complete-kubernetes-course/)

- [Cloud Native Fundamentals by SUSE](https://www.udacity.com/course/cloud-native-fundamentals--ud064)

- [Running Kubernetes on AWS (EKS)](https://www.linkedin.com/learning/running-kubernetes-on-aws-eks)

- [Hands-On Amazon Elastic Kubernetes Service (EKS) LiveLessons: Running Microservices](https://www.oreilly.com/library/view/hands-on-amazon-elastic/9780137446667/)

- [Packaging Applications with Helm for Kubernetes](https://www.pluralsight.com/courses/kubernetes-packaging-applications-helm)


Other resources on Docker:

- [Dockerfile reference](https://docs.docker.com/engine/reference/builder/#from)

- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

- [Docker Build command](https://docs.docker.com/engine/reference/commandline/build/)

- [Docker Run command](https://docs.docker.com/engine/reference/commandline/run/)

- [Introduction to Docker registry](https://docs.docker.com/registry/introduction/)

- [Docker Tag command](https://docs.docker.com/engine/reference/commandline/tag/)

- [Docker Push command](https://docs.docker.com/engine/reference/commandline/push/)

- [Open Container Initiative (OCI) Specifications](https://www.docker.com/blog/demystifying-open-container-initiative-oci-specifications/)

- [Buildpacks: An App’s Brief Journey from Source to Image](https://buildpacks.io/docs/app-journey/)


Other resources on Kubernetes:

- [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)

- [Custom Resources or CRDs](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)

- [Autoscaling in Kubernetes](https://kubernetes.io/blog/2016/07/autoscaling-in-kubernetes/)

- [Kubernetes Components](https://kubernetes.io/docs/concepts/overview/components/)

- [eksctl - Config file schema](https://eksctl.io/usage/schema/#config-file-schema)


Github repositories:

- [Kubernetes Autoscaler](https://github.com/kubernetes/autoscaler)

- [kubernetes/kops](https://github.com/kubernetes/kops)

- [wardviaene/kubernetes-course](https://github.com/wardviaene/kubernetes-course)

- [wardviaene/devops-box (devops box with pre-built tools)](https://github.com/wardviaene/devops-box)

- [kelseyhightower/kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way)

- [mmumshad/kubernetes-the-hard-way](https://github.com/mmumshad/kubernetes-the-hard-way)

- [yankils/Simple-DevOps-Project](https://github.com/yankils/Simple-DevOps-Project)

- [phcollignon/helm](https://github.com/phcollignon/helm)

- [phcollignon/helm3](https://github.com/phcollignon/helm3)



Metrics, Logging, Health Checks, and Tracing:

- [Pattern: Health Check API](https://microservices.io/patterns/observability/health-check-api.html)

- [Best Practice on Metric Naming](https://prometheus.io/docs/instrumenting/writing_exporters/#metrics)

- [How to Log a Log: Application Logging Best Practices](https://logz.io/blog/logging-best-practices/)

- [log4j - Logging Levels](https://www.tutorialspoint.com/log4j/log4j_logging_levels.htm)

- [Enabling Distributed Tracing for Microservices With Jaeger in Kubernetes](https://containerjournal.com/topics/container-ecosystems/enabling-distributed-tracing-for-microservices-with-jaeger-in-kubernetes/)



Free DNS Service using [freedns](https://freedns.afraid.org/)

- Sign up at http://freedns.afraid.org/
- Choose for subdomain hosting
- Enter the AWS nameservers given to you in route53 as nameservers for the subdomain

Free DNS Service using [dot.tk](http://www.dot.tk)

- provides a free .tk domain name you can use
- you can point it to the amazon AWS nameservers

Free DNS Service using [Namecheap](https://www.namecheap.com/)
- often has promotions for tld’s like .co for just a couple of bucks