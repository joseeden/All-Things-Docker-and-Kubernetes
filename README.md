
# All Things Docker and Kubernetes #

This repository will contain my notes, drafts, and projects on containerization and orchestration.

It's still at an early stage, but building (and breaking) and deploying containerized workloads are one of the targets I have on my list for ~~2021~~ the present.

Ayt, going full steam ahead!

<p align=center>
    <img src="Images/docker-6.jpg" width=500>
</p>


## Pre-requisites



## Docker Basics



## Cloud-Native

Another technology that comes to mind when you talk about containers is the concept of cloud-native applications. 

<details><summary> What the heck is Cloud Native? </summary>
 
### So what the heck is Cloud Native?

As defined by [Cloud Native Computing Foundation (CNCF)](https://www.cncf.io/about/charter/) 

> *Cloud native technologies empower organizations to build and run scalable applications in modern, dynamic environments such as public, private, and hybrid clouds. Containers, service meshes, microservices, immutable infrastructure, and declarative APIs exemplify this approach.*
>
> *These techniques enable loosely coupled systems that are resilient, manageable, and observable. Combined with robust automation, they allow engineers to make high-impact changes frequently and predictably with minimal toil.*

In its simplest terms, Cloud native refers to building and managing applications at scale using either private, public, or hybrid cloud platforms.

</details>

<details><summary> Containers and being Cloud Native </summary>

### Containers and being Cloud Native

There are three key things to know here. The first two are **speed** and **agility** - how quickly anorganization can response and adapt to change. 

The third key thing: **containers**.

![](Images/udacity-suse-1-container.png)

To recall, containers are simply **processes** but are treated as the smallest unit of an application. They are closely associated with cloud native applications as containers are a great way to deploy applications quickly and resiliently given their lightweight feature.

Now, when you hear containers, it is also often followed by another buzzword: **microservices**.

![](Images/udacity-suse-1-microservices.png)

This will have its own section but for now, just know that microservices are simply a collection of small, independent, and containerized applications.

</details>

<details><summary> Cloud-Native Landscape </summary>

### Cloud-Native Landscape

With the advent of containers, the need for tools to manage and maintain them also arise. Some of the container orchestrator tools that are being used is the market are:

- Kubernetes,
- Apache Mesos, and 
- Docker Swarm 

Of the three, **Kubernetes** is currently the leading tool in deploying containerized workloads.
 
![](Images/udacity-suse-1-kubernetes.png)

It was a project inside Google and was released in 2014 and is currently being maintained by **CNCF** or **Cloud Native Computing Foundation**, a vendor-agnostic organization that manages open-source projects. The main features of Kubernetes are the automation of:

- Configuration 
- Management
- Scalability

Over time, Kubernetes was developed to include more than just automation but also other functionalities:

- Runtime
- Networking
- Storage
- Service Mesh
- Logs and metrics
- Tracing

</details>

<details><summary> Business and Technical Considerations </summary>

### Business and Technical Considerations

Adoption cloud-native practices means consideration alot of factors, specifically business and technical keypoints, which would need to be assessed by all the stakeholders.

From a business perspective, the adoption of cloud-native tooling represents:

- **Agility** - perform strategic transformations
- **Growth** - quickly iterate on customer feedback
- **Service availability** - ensures the product is available to - customers 24/7

From a technical perspective, the adoption of cloud-native tooling represents:

- **Automation** - release a service without human intervention
- **Orchestration** - introduce a container orchestrator to manage  thousands of services with minimal effort
- **Observability** - ability to independently troubleshoot and debug each component

</details>

## Kubernetes

Adding this section soon!

<p align=center>
    <img src="Images/comingsoon.png" width=500>
</p>

## Resources

Useful courses on Docker:

- [Docker in Production Using Amazon Web Services](https://www.pluralsight.com/courses/docker-production-using-amazon-web-services)
- [Building, Deploying, and Running Containers in Production](https://cloudacademy.com/learning-paths/building-deploying-and-running-containers-in-production-1-888/#)
- [Docker and Kubernetes: The Complete Guide](https://www.udemy.com/course/docker-and-kubernetes-the-complete-guide/)

Learn more about Dockerfile best practices:

- [Dockerfile reference](https://docs.docker.com/engine/reference/builder/#from)
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

Read about the available options when building the image and running containers:

- [Docker Build command](https://docs.docker.com/engine/reference/commandline/build/)
- [Docker Run command](https://docs.docker.com/engine/reference/commandline/run/)

Check out Docker registries, alternatives to package an application, and OCI standards:

- [Introduction to Docker registry](https://docs.docker.com/registry/introduction/)
- [Docker Tag command](https://docs.docker.com/engine/reference/commandline/tag/)
- [Docker Push command](https://docs.docker.com/engine/reference/commandline/push/)
- [Open Container Initiative (OCI) Specifications](https://www.docker.com/blog/demystifying-open-container-initiative-oci-specifications/)
- [Buildpacks: An App’s Brief Journey from Source to Image](https://buildpacks.io/docs/app-journey/)