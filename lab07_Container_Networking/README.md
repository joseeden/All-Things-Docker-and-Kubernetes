## Lab 07: Container Networking

<details><summary> Read more... </summary>

> *This lab is based on [Cloud Academy's Learning Path on Building, Deploying, and Running Containers in Production.](https://cloudacademy.com/learning-paths/building-deploying-and-running-containers-in-production-1-888/)*

Before we begin, make sure you've setup the following pre-requisites

  - [Install Docker](../README.md#pre-requisites)
  - [Install Go](../README.md#pre-requisites)

### Introduction

In this lab, we'll run containers in the same host and test the connectivity between them. We'll also get to explore the threee type of networks in containers:
- Bridge network
- Host network

Let's start with creating the project directory where we'll create our files.

```bash
$ mkdir lab07_Container_Networking
$ cd lab07_Container_Networking
```

### Create the Files

Create the dockerfile. Besides using Ubuntu as base image, we're also installing some networking tools.

```bash
FROM ubuntu:16.04

RUN apt update && apt install -y \
    arp-scan \
    iputils-ping \
    iproute2

COPY webapp /

CMD ["/bin/bash"]
```

Notice in the dockerfile that we're also copying the **webapp** binary which we also used from the previous lab.

Here's the code for our website.

<details><summary> webapp.go </summary>

```go
package main

import (
	"fmt"
	"net/http"
	"os"
)

func hostHandler(w http.ResponseWriter, r *http.Request) {
	name, err := os.Hostname()

	if err != nil {
		panic(err)
	}

	fmt.Fprintf(w, "<h1> HOSTNAME: %s</h1><br>", name)
	fmt.Fprintf(w, "<h1> ENVIRONMENT VARS: </h1><nr>")
	fmt.Fprintf(w, "<ul>")

	for _, evar := range os.Environ() {
		fmt.Fprintf(w, "<li>%s</li>", evar)
	}
	fmt.Fprintf(w, "</ul>")
}

func rootHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "<h1> Let's do this! </h1><br>")
	fmt.Fprintf(w, "<a href='/host/'> Host info </a><br>")
}

func main() {
	http.HandleFunc("/", rootHandler)
	http.HandleFunc("/host/", hostHandler)
	http.ListenAndServe(":8080",nil)
}

```

</details>


Let's compile the code first and build the packages.

```bash
$ env GOARCH=386 GOOS=linux go build webapp.go 
```

```bash
$ ll
total 6008
drwxrwxr-x 2 ubuntu ubuntu    4096 Jun 23 10:46 ./
drwxr-x--- 9 ubuntu ubuntu    4096 Jun 23 10:34 ../
-rwxrwxr-x 1 ubuntu ubuntu 6137719 Jun 23 10:46 webapp*
-rw-rw-r-- 1 ubuntu ubuntu     700 Jun 23 10:44 webapp.go 
```

### Build the Image

```bash
$ docker build -t ubuntu_networking . 
```

```bash
$ docker images
REPOSITORY          TAG       IMAGE ID       CREATED          SIZE
ubuntu_networking   latest    b65babeff71b   11 seconds ago   229MB
ubuntu              16.04     b6f507652425   9 months ago     135MB 
```

### Bridge Network

Here we'll explore a new command - **docker network.**

To see the existing networks,

```bash
$ sudo docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
c42784ebf07e   bridge    bridge    local
11aa2835ceb1   host      host      local
cbc02a1260fb   none      null      local 
```

The **bridge** network is the default network that's used when you don't specify a network during the container startup.

#### Run the Container

Add the "-it" flag so that we can run shell commands on the container. We'll call this container 1.

```bash
$ docker run -it ubuntu_networking
root@2c5606eb344c:/#
root@2c5606eb344c:/#
```

Check if ping is installed on the container.

```bash
root@2c5606eb344c:/# ping google.com -c 3
PING google.com (142.251.12.101) 56(84) bytes of data.
64 bytes from se-in-f101.1e100.net (142.251.12.101): icmp_seq=1 ttl=99 time=1.58 ms
64 bytes from se-in-f101.1e100.net (142.251.12.101): icmp_seq=2 ttl=99 time=1.64 ms
64 bytes from se-in-f101.1e100.net (142.251.12.101): icmp_seq=3 ttl=99 time=1.66 ms

--- google.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 1.580/1.627/1.661/0.047 ms 
```

Check its IP address.

```bash
root@2c5606eb344c:/# ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
6: eth0@if7: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever 
```

IP address of container 1.

```bash
172.17.0.2
```

To detach from the container without stopping/killing the container, hit **Ctrl-P and Ctrl-Q.**.

We can see here that the container is still running.

```bash
$ docker ps
CONTAINER ID   IMAGE               COMMAND       CREATED         STATUS         PORTS     NAMES
2c5606eb344c   ubuntu_networking   "/bin/bash"   2 minutes ago   Up 2 minutes             jolly_wing 
```

#### Run three containers from the same image

We've spin up the first container. Let's run a second one and see its IP address. We'll call this container 2. Click Ctrl-P,Q to detach.

```bash
$ docker run -it ubuntu_networking
root@416c4cab13ff:/#
root@416c4cab13ff:/# ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
8: eth0@if9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:11:00:03 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.3/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever 
```

IP address of container 2.

```bash
172.17.0.3
```

Run a third one and detach. We'll call this container 3.

```bash
$ docker run -it ubuntu_networking
root@2cbde76af881:/#
root@2cbde76af881:/# ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
10: eth0@if11: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:11:00:04 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.4/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever 
```

IP address of container 3.

```bash
172.17.0.4
```

We now have three running containers.

```bash
$ docker ps
CONTAINER ID   IMAGE               COMMAND       CREATED              STATUS              PORTS     NAMES
2cbde76af881   ubuntu_networking   "/bin/bash"   23 seconds ago       Up 22 seconds                 charming_hypatia
416c4cab13ff   ubuntu_networking   "/bin/bash"   About a minute ago   Up About a minute             laughing_ritchie
2c5606eb344c   ubuntu_networking   "/bin/bash"   6 minutes ago        Up 6 minutes                  jolly_wing 
```

#### Test the networking between the three containers

Attach to container 1 which we spin up *6 minutes ago*.

```bash
$ docker ps
CONTAINER ID   IMAGE               COMMAND       CREATED              STATUS              PORTS     NAMES
2cbde76af881   ubuntu_networking   "/bin/bash"   23 seconds ago       Up 22 seconds                 charming_hypatia
416c4cab13ff   ubuntu_networking   "/bin/bash"   About a minute ago   Up About a minute             laughing_ritchie
2c5606eb344c   ubuntu_networking   "/bin/bash"   6 minutes ago        Up 6 minutes                  jolly_wing 
```

```bash
$ docker attach 2c5
root@2c5606eb344c:/#
root@2c5606eb344c:/#
```

From container 1, try to ping container 2 and container 3.

```bash
root@2c5606eb344c:/# ping 172.17.0.3 -c 3
PING 172.17.0.3 (172.17.0.3) 56(84) bytes of data.
64 bytes from 172.17.0.3: icmp_seq=1 ttl=64 time=0.065 ms
64 bytes from 172.17.0.3: icmp_seq=2 ttl=64 time=0.080 ms
64 bytes from 172.17.0.3: icmp_seq=3 ttl=64 time=0.119 ms

--- 172.17.0.3 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2024ms
rtt min/avg/max/mdev = 0.065/0.088/0.119/0.022 ms
```
```bash
root@2c5606eb344c:/# ping 172.17.0.4 -c 3
PING 172.17.0.4 (172.17.0.4) 56(84) bytes of data.
64 bytes from 172.17.0.4: icmp_seq=1 ttl=64 time=0.116 ms
64 bytes from 172.17.0.4: icmp_seq=2 ttl=64 time=0.072 ms
64 bytes from 172.17.0.4: icmp_seq=3 ttl=64 time=0.076 ms

--- 172.17.0.4 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2035ms
rtt min/avg/max/mdev = 0.072/0.088/0.116/0.019 ms 
```

From container 1, scan all the containers that are residing in the same host. The first entry (172.17.0.1) is the default gateway while the next two are the other two containers.

```bash
# arp-scan --interface=eth0 --localnet
Interface: eth0, datalink type: EN10MB (Ethernet)
Starting arp-scan 1.8.1 with 65536 hosts (http://www.nta-monitor.com/tools/arp-scan/)
172.17.0.1      02:42:bb:1d:06:40       (Unknown)
172.17.0.3      02:42:ac:11:00:03       (Unknown)
172.17.0.4      02:42:ac:11:00:04       (Unknown) 
```

### Host Network

Host networks add the container to the host network. This means that if the application inside your container is running on the container's port 8080, it will also be binded to the host's port 8080.

Let's spin up a fourth container which will use the host network. It'll also run the webapp binary. 

We'll call this container 4.

```bash
$ docker run -d --name container_4 --network=host ubuntu_networking /webapp 
```

```bash
$ docker ps
CONTAINER ID   IMAGE               COMMAND       CREATED          STATUS          PORTS     NAMES
e9266543a998   ubuntu_networking   "/webapp"     40 seconds ago   Up 39 seconds             container_4
2cbde76af881   ubuntu_networking   "/bin/bash"   19 minutes ago   Up 19 minutes             charming_hypatia
416c4cab13ff   ubuntu_networking   "/bin/bash"   20 minutes ago   Up 20 minutes             laughing_ritchie
2c5606eb344c   ubuntu_networking   "/bin/bash"   25 minutes ago   Up 25 minutes             jolly_wing 
```

To test this, run a cURL to the application inside the container. Recall that we didn't expose any port on the container through the dockerfile and we also didn't map any container ports to the host's ports, but since we're using the host network for container 4, the container port 8080 is binded to the host's port 8080 automatically.

```bash
$ curl -i localhost:8080
HTTP/1.1 200 OK
Date: Fri, 24 Jun 2022 09:24:35 GMT
Content-Length: 65
Content-Type: text/html; charset=utf-8

<h1> Let's do this! </h1><br><a href='/host/'> Host info </a><br>
```

### None Network

The third type is **None** - whihc actually means the container doesn't belong in any network.

```bash
$ docker run -it --network=none --name=container_5 ubuntu_networking /bin/bash
root@60e87613ae29:/#
```

```bash
$ docker ps
CONTAINER ID   IMAGE               COMMAND              CREATED          STATUS          PORTS     NAMES
60e87613ae29   ubuntu_networking   "/bin/bash"          6 minutes ago    Up 6 minutes              container_5
4b69751c876f   ubuntu_networking   "/webapp /bin/bas"   18 minutes ago   Up 18 minutes             container_4
2cbde76af881   ubuntu_networking   "/bin/bash"          42 minutes ago   Up 42 minutes             charming_hypatia
416c4cab13ff   ubuntu_networking   "/bin/bash"          43 minutes ago   Up 43 minutes             laughing_ritchie
2c5606eb344c   ubuntu_networking   "/bin/bash"          48 minutes ago   Up 48 minutes             jolly_wing 
```

Test the networking.

```bash
root@60e87613ae29:/# ip addr sh
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever 
```

```bash
root@60e87613ae29:/# ping 8.8.8.8
connect: Network is unreachable
root@60e87613ae29:/#
root@60e87613ae29:/# ping google.com
ping: unknown host google.com 
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

</details>