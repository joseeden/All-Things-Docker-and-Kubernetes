
# All Things Docker and Kubernetes #

This repository will contain my notes, drafts, and projects on containerization and orchestration.

It's still at an early stage, but building (and breaking) and deploying containerized workloads are one of the targets I have on my list for ~~2021~~ the present.

Ayt, going full steam ahead!

<p align=center>
    <img src="Images/docker-6.jpg" width=500>
</p>


## Pre-requisites

It's important to note that you can't run Linux containers without a Linux kernel. This means you still need a runtime interpreter to emulate the Linux kernel system calls.

<details><summary> Install Docker </summary>
 
### Install Docker

With the introduction of Hyper-V, this gave way for **Docker Desktop for Windows** which under the hood, uses WSL2's to launch a VM as the host Linux operating system.

**NOTE:** Running containers on Windows machines is suited for local development purposes only and is NOT RECOMMENDED FOR PRODUCTION USE.

<details><summary> Install Docker on WSL2 without Docker Desktop </summary>

#### Install Docker on WSL2 without Docker Desktop 

Note on [Docker Desktop's changing to paid subscription](https://www.docker.com/legal/docker-subscription-service-agreement/):

> After January 31, 2022, Docker Desktop will require a paid subscription.
> Commercial use of Docker Desktop in larger enterprises requires a Docker Pro, Team or Business subscription for as little as 5 USD per user per month.
> The existing Docker Free subscription has been renamed Docker Personal. Docker Desktop remains free for personal use, education, non-commercial open source projects, and small businesses (fewer than 250 employees AND less than 10M USD in annual revenue).

 
A quick Google search shows how to [install Docker in WSL2 without Docker desktop:](https://dev.solita.fi/2021/12/21/docker-on-wsl2-without-docker-desktop.html)

Remove old Docker installations.

```bash
$ sudo apt remove docker \
docker-engine \
docker.io \
containerd runc 
```

Install some pre-requisites.

```bash
$ sudo apt update 
$ sudo apt install -y --no-install-recommends \
apt-transport-https ca-certificates curl gnupg2
```

Configure package repository

```bash
$ source /etc/os-release 
$ curl -fsSL https://download.docker.com/linux/${ID}/gpg | sudo apt-key add -
$ echo "deb [arch=amd64] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list
$ sudo apt update
```

Install Docker.

```bash
$ sudo apt install -y docker-ce docker-ce-cli containerd.io
```

Add user to group

```bash
$ sudo usermod -aG docker $USER 
```

Configure dockerd

```bash
$ DOCKER_DIR=/mnt/wsl/shared-docker
$ mkdir -pm o=,ug=rwx "$DOCKER_DIR"
$ sudo chgrp docker "$DOCKER_DIR"
$ sudo mkdir /etc/docker
$ sudo vi /etc/docker/daemon.json 

    {
    "hosts": ["unix:///mnt/wsl/shared-docker/docker.sock"]
    }
```

Test if it works. Run the command below. It should return "API listen on.." message.

```bash
$ sudo dockerd 

API listen on /mnt/wsl/shared-docker/docker.sock
```

Do another test. Open another terminal and run the command below.

```bash
$ docker -H unix:///mnt/wsl/shared-docker/docker.sock run --rm hello-world
```

It should return this output.

<details><summary> run hello-world </summary>
 
```bash
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```
 
</details>
</br>

The next step is to create a launch script for dockerd. You can do this in two ways:

<details><summary> Manual </summary>

Add the following to .bashrc or .profile 

```bash
$ cat >> ~/.bashrc

DOCKER_SOCK="/mnt/wsl/shared-docker/docker.sock"
test -S "$DOCKER_SOCK" && export DOCKER_HOST="unix://$DOCKER_SOCK"
```
 
</details>

<details><summary> Automatic </summary>

Add the following to .bashrc or .profile 
```bash
$ cat >> ~/.bashrc

DOCKER_DISTRO=$(cat /etc/os-release | grep PRETTY_NAME | cut -c14- | cut -d ' ' -f1,2)
DOCKER_DIR=/mnt/wsl/shared-docker
DOCKER_SOCK="$DOCKER_DIR/docker.sock"
export DOCKER_HOST="unix://$DOCKER_SOCK"

if [ ! -S "$DOCKER_SOCK" ]; then
   mkdir -pm o=,ug=rwx "$DOCKER_DIR"
   sudo chgrp docker "$DOCKER_DIR"
   /mnt/c/Windows/System32/wsl.exe -d $DOCKER_DISTRO sh -c "nohup sudo -b dockerd < /dev/null > $DOCKER_DIR/dockerd.log 2>&1"
fi
```
 
</details>


</details>


<details><summary> Install on RHEL/CentOS </summary>
 
#### Install on RHEL/CentOS

These steps are the ones I followed to install docker on RHEL 8/CentOS in an Amazon EC2 instance. Detailed steps can be found on [Docker's official documentation](https://docs.docker.com/engine/install/centos/).

Check version.

```bash
ll /etc/*release
cat /etc/*release
```

Update base image

```bash
sudo yum -y update
```

Uninstall older versions of docker - if one exists

```bash
sudo yum remove -y docker \
docker-client \
docker-client-latest \
docker-common \
docker-latest \
docker-latest-logrotate \
docker-logrotate \
docker-engine
```

To install Docker, you can do it in two ways:

<details><summary> Install from a package </summary>

Install from a package - Setup repository and install from there.

Choose your OS version in https://download.docker.com/linux/centos/, head to **x86_64/stable/Packages/**, and download the **.rpm** file.

Go to the directory where the rpm file is downloaded and do the installation.

```bash
$ cd <path-to>/package.rpm
$ sudo yum install -y package.rpm
```

Start docker and verify version.

```bash
$ sudo systemctl start docker 
$ docker version 
```

Run a simple "hello-world" container.

```bash
$ sudo docker run hello-world 
```
 
</details>

<details><summary> Install from a script </summary>

Install from a script - Use the convenience scripts
This method is NOT RECOMMENDED for production environments

Do a preview first of the changes before actually applying them.

```bash
$ curl -fsSL https://get.docker.com -o get-docker.sh
$ DRY_RUN=1 sh ./get-docker.sh 
```

Download the script and install the latest release.

```bash
$ curl -fsSL https://get.docker.com -o get-docker.sh
$ sudo sh get-docker.sh 
```

Start docker and verify version.

```bash
$ sudo systemctl start docker 
$ docker version 
```

Run a simple "hello-world" container.

```bash
$ sudo docker run hello-world 
```

</details>
</details>

<details><summary> Install on Ubuntu </summary>

#### Install on Ubuntu

This is a summary of the command that you can run to install docker on Ubuntu.

```bash
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
$ sudo apt-get update -y 
$ sudo sudo apt-get install docker-ce docker-ce-cli containerd.io -y 
$ sudo usermod -aG docker ubuntu 
```
  
</details>

<details><summary> Install on Ubuntu using Terraform </summary>

#### Install on Ubuntu using Terraform

Whether you've dabbled around in Terraform or not, this is the fastest way to provision a resource in AWS with Docker installed. This will provision the following:

- a VPC
- an EC2 instance with Docker installed

For more details, check this [repository](https://github.com/joseeden/101-Terraform-Projects/tree/master/lab12_Docker_Kubernetes_Env).

</details>

</details>

<details><summary> Error: Cannot connect to the Docker daemon </summary>

### Error: Cannot connect to the Docker daemon

In case you encounter this message when you test Docker for the first time:

```bash
docker: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
```

To resolve this, start the docker service and docker daemon.
```bash
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker
```
```bash
sudo dockerd
```

You can checkout this [Stackoverflow discussion](https://stackoverflow.com/questions/44678725/cannot-connect-to-the-docker-daemon-at-unix-var-run-docker-sock-is-the-docker) to know more.

</details>


<details><summary> Install Go (optional) </summary>

### Install Go (optional)

This is not required for running containers but we will be using custom binary written in Go in some of the labs.
Doing a quick Google search, we find a link on [how to install Go (golang) on Ubunt](https://www.cyberciti.biz/faq/how-to-install-gol-ang-on-ubuntu-linux/)u:

#### Method 1: Using Snap 

```bash
$ sudo snap install go --classic 
```
You should see the following output returned.
```bash
go 1.18.3 from Michael Hudson-Doyle (mwhudson) installed 
```

#### Method 2: Using apt-get/apt

```bash
$ sudo apt update
$ sudo apt upgrade 
```
```bash
$ sudo apt search golang-go
$ sudo apt search gccgo-go 
```
```bash
$ sudo apt install golang-go 
```

Verify.
```bash
$ go version
go version go1.18.3 linux/amd64 
```

#### Test

Create a simple **hello-world.go** program.

```go
// Hello Word in Go by Vivek Gite
package main
 
// Import OS and fmt packages
import ( 
	"fmt" 
	"os" 
)
 
// Let us start
func main() {
    fmt.Println("Hello, world!")  // Print simple text on screen
    fmt.Println(os.Getenv("USER"), ", Let's be friends!") // Read Linux $USER environment variable 
} 
```

Compile and run.
```bash
$ go run hello-world.go 

Hello, world!
ubuntu , Let's be friends!
```

Build/compile packages and dependencies:
```bash
$ go build hello-world.go
```
```bash
$ ls -l hello*

-rwxrwxr-x 1 ubuntu ubuntu 1766381 Jun 23 08:05 hello-world
-rw-rw-r-- 1 ubuntu ubuntu     305 Jun 23 08:04 hello-world.go
```
```bash
$ ./hello-world

Hello, world!
ubuntu , Let's be friends!
```

</details>

## Docker Basics


</details>

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