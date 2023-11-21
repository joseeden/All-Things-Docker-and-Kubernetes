

# All Things Docker and Kubernetes 

This repository contains projects on containerization and orchestration that I'm currently working on in ~~2021~~ the present. 

- [How to Use this Repo](#how-to-use-this-repo)
- [Pre-requisites](#pre-requisites)
- [Docker + Containers](#docker--containers)
- [Cloud-Native](#cloud-native)
- [Kubernetes](#kubernetes)
- [Certification Exams](#certification-exams)
- [Resources](#resources)


----------------------------------------------


## How to Use this Repo

- Each project in this repo is equipped with easy-to-follow, detailed instructions. 

- You can also go through the **Docker** and **Kubernetes** topics below for a quick walkthrough.

## Projects

The complete list of projects can be found [here](projects/README.md).


## Pre-requisites

Here are some pre-requisites before we can perform the labs. 

- [For Docker Labs](pages/01-Pre-requisites/labs-docker-pre-requisites/README.md)

- [For Kubernetes Labs](pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md)
 
- [Optional Tools](pages/01-Pre-requisites/labs-optional-tools/README.md)


## Docker + Containers

Containers are where it all starts.

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


## Cloud-Native

When you have containers, you have cloud-native applications. 

- [What is Cloud Native?](pages/03-Cloud-Native/001-What-is-Cloud-Native.md) 
 
- [Containers and being Cloud Native](pages/03-Cloud-Native/002-Containers-and-being-Cloud-Native.md) 

- [Cloud-Native Landscape](pages/03-Cloud-Native/003-Cloud-Native-Landscape.md) 

- [Business and Technical Considerations](pages/03-Cloud-Native/004-Business-and-Technical-Considerations.md) 

- [Design Considerations](pages/03-Cloud-Native/005-Design-Considerations.md) 

- [Monoliths and Microservices](pages/03-Cloud-Native/006-Monoliths-and-Microservices.md) 

- [Tradeoffs](pages/03-Cloud-Native/007-Tradeoffs.md) 

- [Best Practices for Application Deployments](pages/03-Cloud-Native/008-Best-Practice-for-App-Deployments.md) 

- [Product is Released, What's Next?](pages/03-Cloud-Native/009-Product-is-Released-Whats-Next.md) 


## Kubernetes

Kubernetes is indeed an entire universe in itself. 

- [Container Management Challenges](pages/04-Kubernetes/001-Container-Management-Challenges.md) 

- [What is Kubernetes](pages/04-Kubernetes/002-What-is-Kubernetes.md) 

- [Kubernetes API Objects](pages/04-Kubernetes/004-Kubernetes-API-Objects.md) 

- [Kubernetes Cluster](pages/04-Kubernetes/005-Kubernetes-Cluster.md) 

- [Pod Operations](pages/04-Kubernetes/006-Pod-Operations.md) 

- [Kubernetes Networking](pages/04-Kubernetes/007-Kubernetes-Networking.md) 

- [Setting up Kubernetes](pages/04-Kubernetes/008-Setting-up-Kubernetes.md)

- [Kubeconfig file](pages/04-Kubernetes/009-kubeconfig-files.md)

- [Kubernetes API](pages/04-Kubernetes/040-kubernetes-api.md)

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

- [Probes and Init Containers](pages/04-Kubernetes/020-Probes.md)

- [Volumes and StorageClasses](pages/04-Kubernetes/017-StorageClass.md)

- [ConfigMaps and Secrets](pages/04-Kubernetes/021-Configmaps.md)

- [Certificate Authority](pages/04-Kubernetes/015-Certificate-Authority.md) 

- [Stateless vs. Stateful](pages/04-Kubernetes/016-Stateful-vs-Stateless.md)

- [Application Lifecycle Management](pages/04-Kubernetes/036-App-Lifecycle-Management.md)

- [Kubernetes Dashboard](pages/04-Kubernetes/027-Kubernetes-Dashboard.md)

- [Kubernetes Commands](pages/04-Kubernetes/049-Cheatsheet-Kubernetes-Commands.md) 

- [Cluster Maintenance](pages/04-Kubernetes/037-Cluster-maintenance.md)

- [Back Up, Restore and Upgrade Clusters](./Lab21_Backup_Restore_and_Upgrade_a_Kubernetes_Cluster/README.md)

- [Kubernetes Ecosystem](pages/04-Kubernetes/026-kubernetes-ecosystem.md)

- [Kubernetes Security - Security Primitives](pages/04-Kubernetes/028-Kubernetes-Security-primitives.md)

- [Kubernetes Security - Authentication and Authorization](pages/04-Kubernetes/028-Kubernetes-Security-authentication-authorization.md) 

- [Kubernetes Security - TLS Certificates](pages/04-Kubernetes/028-Kubernetes-Security-tls-certificates.md)

- [Kubernetes Security - Security Contexts](pages/04-Kubernetes/028-Kubernetes-Security.md) 

- [Kubernetes in the Cloud](pages/04-Kubernetes/039-Kubernetes-in-the-Cloud.md) 

- [CNCF Projects](pages/04-Kubernetes/029-CNCF-Projects.md)

- [Helm Package Manager](pages/04-Kubernetes/030-Helm-Package-Manager.md) 

- [Helm Chart and Templates](pages/04-Kubernetes/032-Helm-Chart-and-Templates.md)

- [Helm Commands](pages/04-Kubernetes/031-Helm-commands.md)

- [Kubernetes Patterns for Application Developers](pages/04-Kubernetes/033-Kubernetes-patterns.md) 

- [Amazon EKS - Managed Kubernetes](pages/04-Kubernetes/050-EKS-Managed-Kubernetes.md) 

- [Amazon EKS - Pricing](pages/04-Kubernetes/051-EKS-Pricing.md) 

- [Amazon EKS - IAM and RBAC](pages/04-Kubernetes/052-EKS-IAM-and-RBAC.md)  

- [Amazon EKS - Networking](pages/04-Kubernetes/056-EKS-Networking.md)

- [Amazon EKS - Loadbalancers](pages/04-Kubernetes/053-EKS-Loadbalancers.md) 

- [Amazon EKS - Cluster AutoScaler](pages/04-Kubernetes/054-EKS-Cluster-Autoscaler.md) 

- [Amazon EKS - Logging to CloudWatch ](pages/04-Kubernetes/055-EKS-Control-Plane-Logging-to-CloudWatch.md) 

- [Amazon EKS - Persistent Volumes](pages/04-Kubernetes/056-EKS-Persistent-Volumes.md)    

- [Amazon EKS - Self-managed vs. Managed Nodegroups](pages/04-Kubernetes/057-EKS-Nodegroups.md)      

- [Error Guides](pages/04-Kubernetes/099-Error-Guide.md)   


## Certification Exams 

Notes: 

- [Exam Tips](pages/05-Exams/001-Exam-tips.md)    

Resources: 

- [Open Source Curriculum for CNCF Certification Courses](https://github.com/cncf/curriculum)

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