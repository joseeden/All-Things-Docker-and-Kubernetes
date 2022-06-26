
## Lab 02: Creating the Dockerfile and the Image 

> *This lab is based on [Cloud Academy's Learning Path on Building, Deploying, and Running Containers in Production.](https://cloudacademy.com/learning-paths/building-deploying-and-running-containers-in-production-1-888/)*

Before we begin, make sure you've setup the following pre-requisites

  - [Install Docker](../README.md#pre-requisites)
  - [Install Go](../README.md#pre-requisites)

### Introduction

In this lab, we'll run a lightweight container that runs a custom binary that we'll create. Let's start with creating the project directory where will create our files.

```bash
$ mkdir lab02_Creating_Dockerfile_and_Image 
$ cd lab02_Creating_Dockerfile_and_Image 
```

### Create the Files

Here's a custom **hello-world.go** binary. This is the same code that was used in the pre-requisite section.

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

If you haven't build and compiled yet, please do so.

```bash
$ go run hello-world.go 
$ go build hello-world.go
$ ls -l hello*
$ ./hello-world
```

Let's now create the **dockerfile**. 

```bash
FROM scratch
COPY hello-world /
CMD ["/hello-world"]
```

**A Few Notes on the dockerfile**

- The **FROM**line specifies the base image tha we'll use. Here we're using a very minal image called "scratch".
- **COPY** copies the hello-world files from our host onto a layer of the image.
- Finally, the **CMD** tells the container the default command to run when the container is launched.

### Build the Image

Use the **build** command, followed by the directory where the dockerfile is.

```bash
$ docker build .
```
```bash
Sending build context to Docker daemon   1.77MB
Step 1/3 : FROM scratch
 --->
Step 2/3 : COPY hello-world /
 ---> ace21a3aa6c1
Step 3/3 : CMD ["/hello-world"]
 ---> Running in f9d66d34a3ee
Removing intermediate container f9d66d34a3ee
 ---> 937c8df2598b
Successfully built 937c8df2598b 
```

Checking the docker images, we see that the image was created without a repo name and tag.

```bash
$ docker images

REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
<none>       <none>    937c8df2598b   46 seconds ago   1.77MB 
```

To remove the image, run the command below. Make sure to add the image ID at the end. We don't need to specify the entire image ID.

```bash
$ docker rmi 937 
```

Let's create the image again, but this time let's add a tag.

```bash
$ docker build . -t my-hello-world
```
```bash
Sending build context to Docker daemon   1.77MB
Step 1/3 : FROM scratch
 --->
Step 2/3 : COPY hello-world /
 ---> b540b27e4866
Step 3/3 : CMD ["/hello-world"]
 ---> Running in 31c09c3a4794
Removing intermediate container 31c09c3a4794
 ---> 5635489bb18b
Successfully built 5635489bb18b
Successfully tagged my-hello-world:latest 
```

Verify.

```bash
$ docker images

REPOSITORY       TAG       IMAGE ID       CREATED              SIZE
my-hello-world   latest    5635489bb18b   About a minute ago   1.77MB 
```

### Run the container

```bash
$ docker run my-hello-world

Hello, world!
Let's be friends! 
```

The container will run the binary and then exit out. If we check the list of running containers,

```bash
$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES 
```
```bash
$ docker ps -a
CONTAINER ID   IMAGE            COMMAND          CREATED              STATUS                          PORTS     NAMES
05d5dad77d2c   my-hello-world   "/hello-world"   About a minute ago   Exited (0) About a minute ago             wonderful_rhodes 
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

