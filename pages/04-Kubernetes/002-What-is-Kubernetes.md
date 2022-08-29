# What is Kubernetes

As we've previously seen, the advent of containers called for much better tools to manage and maintain them. Some of the container orchestrator tools that are being used is the market are Kubernetes, Apache Mesos, and Docker Swarm, with Kubernetes being the leading tool in deploying containerized workloads.

<p align=center>
<img src="../../Images/udacity-suse-1-kubernetes.png">
</p>

**What does Kubernetes do?**

- starts and stops container-based application
- handles workload placement
- automation of configuration, management, and scalability
- zero downtime with automated rollouts/rollbacks
- abstracts infrastructure by handling it under the hood
- follows *desired state* - which means we can define in code what we want our end state to look like

<p align=center>
<img src="../../Images/pluralsightwhatiskubernetesfordevs.png">
</p>

**Besides automation, what are its other functionalities?**

* Runtime
* Networking
* Storage orchestration
* self-healing
* Service Mesh
* Logs and metrics
* secrets management
* Tracing

**What are its benefits from an administrator's standpoint?**

- Speed of deployment
- Ability to absorb change quickly
- Ability to recover quickly (self-healing)
- scale containers
- orchestrate containers
- Hide complexity in the cluster    
- ensure secrets/config are working properly

**What are its benefits from a developer's standpoint?**

- zero-downtime deployments
- ability to emulate production locally 
- ability to create an end-to-end testing environment
- performance testing scenarios, determining what are the limits of our application
- workload scenarios, for multiple builds in your CICD pipeline
- leverage different deployment options (AB, canary, etc.)

