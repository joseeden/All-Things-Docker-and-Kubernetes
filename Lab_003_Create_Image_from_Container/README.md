## Lab 03: Create an Image from an Existing Container

Before we begin, make sure you've setup the following pre-requisites

  - [Install Docker](../pages/01-Pre-requisites/labs-docker-pre-requisites/README.md)

### Introduction

In the previous lab, we've create a dockerfile, build the image, and then run a container from that image. This time, we'll create an image from an existing container. 

Let's start with creating the project directory where we'll create our files.

```bash
$ mkdir Lab_003_Create_Image_from_Container
$ cd Lab_003_Create_Image_from_Container 
```

### Run the Container and Install Python

Recall the Ubuntu container that we run awhile back. We we're able to interact with it by using the "-it" flag.

```bash
$ docker run -it ubuntu /bin/bash 

Unable to find image 'ubuntu:latest' locally
latest: Pulling from library/ubuntu
405f018f9d1d: Pull complete
Status: Downloaded newer image for ubuntu:latest
root@80452f6f437e:/#
root@80452f6f437e:/#
```

Check if python is installed in the Ubuntu container.

```bash
root@80452f6f437e:/# which python
root@80452f6f437e:/# 
```

Let's install the python binary.
```bash
root@80452f6f437e:/# apt update
root@80452f6f437e:/# apt install -y python
root@80452f6f437e:/# 
```

Verify.
```bash
root@80452f6f437e:/# which python
/usr/bin/python
```

### Create the New Image from the Running Container 

We can now create a new Ubuntu image with Python installed.

Get the container ID of the Ubuntu container where we installed Python.

```bash
$ docker ps -a
CONTAINER ID   IMAGE            COMMAND          CREATED          STATUS                      PORTS     NAMES
80452f6f437e   ubuntu           "/bin/bash"      11 minutes ago   Exited (1) 4 minutes ago              nervous_brown
05d5dad77d2c   my-hello-world   "/hello-world"   26 minutes ago   Exited (0) 26 minutes ago             wonderful_rhodes 
```

```bash
$ docker images
REPOSITORY       TAG       IMAGE ID       CREATED          SIZE
my-hello-world   latest    5635489bb18b   23 minutes ago   1.77MB
ubuntu           latest    27941809078c   2 weeks ago      77.8MB 
```

Create the image from the existing container. Notice that we would also need to change the **CMD** from "/bin/bash" to "python". Make sure to the add the container ID and a tag at the end. We'll call out new image "ubuntu_python".

```bash
$ docker commit --change='CMD ["python", "-C", "This is a new image"]' 8045 ubuntu_python 
```

```bash
$ docker images
REPOSITORY       TAG       IMAGE ID       CREATED          SIZE
ubuntu_python    latest    42fb2bf45f34   2 minutes ago    142MB
my-hello-world   latest    5635489bb18b   31 minutes ago   1.77MB
ubuntu           latest    27941809078c   2 weeks ago      77.8MB 
```

### Cleanup 

When you're done with the lab, you can stop all running containers by running the command below.

```bash
$ docker stop $(docker ps) 
```

Once all containers have "Exited" status, remove them.

```bash
$ docker ps  -a 
```
```bash
$ docker container prune -f 
```

Finally, remove all images.

```bash
$ docker image prune -af 
```
