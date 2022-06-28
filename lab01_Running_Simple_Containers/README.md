## Lab 01: Running Simple Containers
 
> *This lab is based on [Cloud Academy's Learning Path on Building, Deploying, and Running Containers in Production.](https://cloudacademy.com/learning-paths/building-deploying-and-running-containers-in-production-1-888/)*

Before we begin, make sure you've setup the following pre-requisites

  - [Install Docker](../README.md#pre-requisites)

### Introduction

In this lab, we'll run the following simple containers. Let's start with creating the project directory where will create our files.

```bash
$ mkdir lab01_Running_Simple_Containers 
$ cd lab01_Running_Simple_Containers 
```

### whalesay

Run the command below. It will pull the image from Dockerhub and run it locally.

```bash
$ sudo docker run docker/whalesay cowsay Infinity and beyond!
```

You should see and output like this.

```bash
< Infinity and beyond! >
 ----------------------
    \
     \
      \
                    ##        .
              ## ## ##       ==
           ## ## ## ##      ===
       /""""""""""""""""___/ ===
  ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
       \______ o          __/
        \    \        __/
          \____\______/
```

Now make the whale say "Let's do this!"

```bash
$ sudo docker run docker/whalesay cowsay "Let's do this!"
```
```bash
 ________________
< Let's do this! >
 ----------------
    \
     \
      \
                    ##        .
              ## ## ##       ==
           ## ## ## ##      ===
       /""""""""""""""""___/ ===
  ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
       \______ o          __/
        \    \        __/
          \____\______/ 
```


### nyancat 

Run the command below. It will pull the image from Dockerhub and run it locally.
```bash
$ sudo docker run -it --rm --name nyancat 06kellyjac/nyancat
```

<p align=center>
<img src="../Images/0619nyancat.png">
</p>

To exit out of the animation, hit Ctrl-C.

### Running a Web server

This runs the nginx web server in a container using the official nginx image, specifically the version 1.12.

```bash
$ docker run --name web-server -d -p 8080:80 nginx:1.12 
```

Here we assigned a container name "web-server" to the container and we also mapped the host's port 8080 to the container port 80(http).

Notice the "-d" which means *detached*. The container runs in the background and you can simply "attach" to it using the **docker attach <container-id></container-id>** command.

Verify by running a cURL to out localhost through port 8080. It should return a "200 OK" status.

```bash
# curl localhost:8080 -I

HTTP/1.1 200 OK
Server: nginx/1.12.2
Date: Thu, 23 Jun 2022 09:46:05 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 11 Jul 2017 13:29:18 GMT
Connection: keep-alive
ETag: "5964d2ae-264"
Accept-Ranges: bytes 
```

To stop the container,

```bash
$ docker stop web-server 
```

To start the container again,

```bash
$ docker start web-server 
```

### Interactive Ubuntu container

We've launch one-off containers so far, which means once the process is done or when we exit out, the container is then killed. In this one, we'll be able to "interact" with the actual container by running commands inside it.

```bash
$ sudo docker run -it ubuntu /bin/bash

Unable to find image 'ubuntu:latest' locally
latest: Pulling from library/ubuntu
405f018f9d1d: Pull complete
Status: Downloaded newer image for ubuntu:latest
root@938c4f054e92:/#
root@938c4f054e92:/#
```

Note that each container is independent from each other. To see this, let's create a file in this Ubuntu container and then exit out. Remember that when you exit out of a container, the container is sort of "deactivated".

```bash
root@938c4f054e92:/# echo "This file exists in Ubuntu container 1" > container1.txt 
root@938c4f054e92:/# cat container1.txt
This file exists in Ubuntu container 1
root@938c4f054e92:/# exit
exit
```

Now let's run another Ubuntu container and check if the file exists here. We'll see that this container doesn't have the file.

```bash
$ sudo docker run -it ubuntu /bin/bash
root@40485b5df3ce:/# cat container.txt
cat: container.txt: No such file or directory 
```

Let's restart the first Ubuntu container. Get the list of containers first. 

```bash
$ docker ps -a
CONTAINER ID   IMAGE             COMMAND                  CREATED              STATUS                         PORTS     NAMES
40485b5df3ce   ubuntu            "/bin/bash"              About a minute ago   Exited (1) 4 seconds ago                 modest_galois
938c4f054e92   ubuntu            "/bin/bash"              4 minutes ago        Exited (0) 3 minutes ago                 nostalgic_dhawan
```

Restart the container and verify that it is running by issuing the **docker ps** commmand.

```bash
$ docker start 938c4f054e92
938c4f054e92 
```
```bash
$ docker ps
CONTAINER ID   IMAGE     COMMAND       CREATED         STATUS         PORTS     NAMES
938c4f054e92   ubuntu    "/bin/bash"   7 minutes ago   Up 5 seconds             nostalgic_dhawan 
```

To interact with this container, we need to "attach". Once attached, check the container1.txt file.

```bash
$ docker attach 938c4f054e92
root@938c4f054e92:/# 
root@938c4f054e92:/# 
root@938c4f054e92:/# cat container1.txt
This file exists in Ubuntu container 1
```

### Executing Commands inside a Running Container

For this example, let's run a simple Redis container.

```bash
$ docker run -d redis 
```
```bash
$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS      NAMES
dc9f84c643f9   redis     "docker-entrypoint.s…"   3 seconds ago   Up 2 seconds   6379/tcp   sweet_brown 
```

To run "enter" the container and run the Redis CLi, use the **exec it** command, followed by the container-id and the command "redis-cli". You should be able to run the Redis CLI now.

```bash
$ docker exec -it dc9 redis-cli 
```

Verify that the CLI works by setting a "testvalue" and retrieving it.

```bash
127.0.0.1:6379> set testvalue 100
OK
127.0.0.1:6379> get testvalue
"100" 
```

### Removing Containers

To delete specific containers, use the **rm** command.

```bash
$ docker rm <container-id>
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
