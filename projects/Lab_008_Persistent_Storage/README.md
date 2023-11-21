# Lab 008: Persistent Storage


## Pre-requisites

  - [Install Docker](../../pages/01-Pre-requisites/labs-docker-pre-requisites/README.md)
  - [Install Go](../../pages/01-Pre-requisites/labs-optional-tools/README.md#install-go)

## Introduction
  
In this lab, we'll explore the storage options available for Docker containers.

## Create the Files and Storage Directory

We have a **writedata.go** that will loop 50 times and write the hostname and loop counter to a file which we'll specify in the command line. Multiple containers can write data to the volume

<details><summary> writedata.go </summary>
 
```go
package main

import (
	"fmt"
	"os"
	"time"
)

func main() {
	
	if len(os.Args) <= 1 {
		fmt.Println("Usage: writedata /path/to/file")
		panic("You're missing a file name")
	}
	
	filename := os.Args[1]
	hostname, err := os.Hostname()
	
	if err != nil {
		panic("Cannot determine the hostname")

	}

	f, err := os.OpenFile(filename, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0644)
	defer f.Close()

	for i := 0; i < 50; i++ {
		
		data := fmt.Sprintf("Host: %s - Loop Number: %d\n", hostname, i)

		_, err := f.WriteString(data)

		if err != nil {
			panic("Cannot write to file")
		}

		time.Sleep(time.Second)
	}
}
```
 
</details>
</br>

Let's compile the code first and build the packages.

```bash
$ env GOARCH=386 GOOS=linux go build writedata.go 
```

```bash
$ ll
total 1684
drwxrwxr-x  2 ubuntu ubuntu    4096 Jun 25 11:01 ./
drwxr-x--- 10 ubuntu ubuntu    4096 Jun 25 10:59 ../
-rwxrwxr-x  1 ubuntu ubuntu 1709821 Jun 25 11:01 writedata*
-rw-rw-r--  1 ubuntu ubuntu     610 Jun 25 11:00 writedata.go
```

Next, create the local directory which will serve as the external persistent volume for our container.

```bash
$ sudo mkdir /var/lab08/logs  
```

Finally, create the dockerfile. The **writedata** binary will be copied to the root directory. When the container is ran, it will execute the **writedata** code and the data will be written to "/logs/myapp".

```bash
FROM scratch
COPY writedata /
CMD ["/writedata", "/logs/myapp"] 
```

## Build the Image

Build the image from the dockerfile and give it a name, "lab08-storage".

```bash
$ docker build . -t lab08-storage -f dockerfile
```
```bash
$ docker images
REPOSITORY      TAG       IMAGE ID       CREATED          SIZE
lab08-storage   latest    2c5686b5d2e8   18 seconds ago   1.71MB
```

Before we run the containers, let's confirm that there are no files inside the local directory that will serve as the persistent volume.

```bash
$ ll /var/lab08/logs/
total 8
drwxr-xr-x 2 root root 4096 Jun 25 11:24 ./
drwxr-xr-x 3 root root 4096 Jun 25 11:08 ../
```

## Run the Containers and Specify the Storage

### Storage: Bindmounts 

We'll run four containers from the image and specify the mount type as "bind mounts". We also need to specify the source directory (src), which is the directory residing in our local machine that we want to mount and the destination directory (dst) is the path inside the container where the volume will be mounted to.

Run the first container.

```bash
$ docker run -d --mount type=bind,src="/var/lab08/logs",dst="/logs" lab08-storage
```

Run the command three more times to spin up three more containers.

```bash
$ docker run -d --mount type=bind,src="/var/lab08/logs",dst="/logs" lab08-storage
$ docker run -d --mount type=bind,src="/var/lab08/logs",dst="/logs" lab08-storage
$ docker run -d --mount type=bind,src="/var/lab08/logs",dst="/logs" lab08-storage
```

We could check the running containers by issuing the **docker ps** command but note that once the container is done executing the binary, it will exit out. 

```bash
$ docker ps
CONTAINER ID   IMAGE           COMMAND                  CREATED         STATUS         PORTS     NAMES
ef6d100a98b9   lab08-storage   "/writedata /logs/my…"   3 seconds ago   Up 2 seconds             gifted_goldberg
9c87a3c0b601   lab08-storage   "/writedata /logs/my…"   4 seconds ago   Up 3 seconds             stoic_hertz
a9a8e50e478d   lab08-storage   "/writedata /logs/my…"   5 seconds ago   Up 4 seconds             hardcore_vaughan
2c3c811d93f2   lab08-storage   "/writedata /logs/my…"   8 seconds ago   Up 6 seconds             elegant_euler
```

A **myapp** file should be created inside the local directory (/var/lab08/logs) and the four containers should have written some data onto this file. We could simply *tail* the last 10 lines of the file.

```bash
$ ll /var/lab08/logs/
total 16
drwxr-xr-x 2 root root 4096 Jun 25 11:28 ./
drwxr-xr-x 3 root root 4096 Jun 25 11:08 ../
-rw-r--r-- 1 root root 7360 Jun 25 11:28 myapp 
```
```bash
$ tail -10 /var/lab08/logs/myapp
Host: 168ffaa1de28 - Loop Number: 49
Host: 2c5dd2d8cab0 - Loop Number: 48
Host: fe6700eee87a - Loop Number: 47
Host: a56c6f731eef - Loop Number: 46
Host: 2c5dd2d8cab0 - Loop Number: 49
Host: fe6700eee87a - Loop Number: 48
Host: a56c6f731eef - Loop Number: 47
Host: fe6700eee87a - Loop Number: 49
Host: a56c6f731eef - Loop Number: 48
Host: a56c6f731eef - Loop Number: 49 
```

Sorting out the entire content of the myapp file and filtering for just the container IDs, we'll see that the four containers wrote on the same shared file.

```bash
$ cat /var/lab08/logs/myapp | cut -d " " -f 2 | sort | uniq
168ffaa1de28
2c5dd2d8cab0
a56c6f731eef
fe6700eee87a 
```

Remove the containers and verify that the myapp file still exists in the path.

```bash
$ docker container prune -f 
```
```bash
$ tail -10 /var/lab08/logs/myapp
Host: ef6d100a98b9 - Loop Number: 45
Host: a9a8e50e478d - Loop Number: 48
Host: 9c87a3c0b601 - Loop Number: 47
Host: ef6d100a98b9 - Loop Number: 46
Host: a9a8e50e478d - Loop Number: 49
Host: 9c87a3c0b601 - Loop Number: 48
Host: ef6d100a98b9 - Loop Number: 47
Host: 9c87a3c0b601 - Loop Number: 49
Host: ef6d100a98b9 - Loop Number: 48
Host: ef6d100a98b9 - Loop Number: 49
```

It's important to remember that with bindmounts, the user manages the volume, not Docker. This means you can specify the "source" directory which will serve as the persistent volume. 

### Storage: Volumes

Before we proceed with volumes, remove any existing container so that we have a fresh plate.



We'll use the same **docker run** command but this time we'll set the mount type as volume. Notice that we don't have to specify any path for the source directory, only for the destination path. Thi is because Docker manages the volume and not the user.

```bash
$ docker run -d --mount type=volume,src="lab08-logs",dst="/logs" lab08-storage 
```
```bash
$ docker volume ls
DRIVER    VOLUME NAME
local     lab08-logs 
```

Run three more containers.

```bash
$ docker run -d --mount type=volume,src="lab08-logs",dst="/logs" stor-volume 
$ docker run -d --mount type=volume,src="lab08-logs",dst="/logs" stor-volume 
$ docker run -d --mount type=volume,src="lab08-logs",dst="/logs" stor-volume 
```

Use **inspect** to determine the lcoation of the volume.

```bash
$ docker inspect lab08-logs
[
    {
        "CreatedAt": "2022-06-25T11:43:12Z",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/lab08-logs/_data",
        "Name": "lab08-logs",
        "Options": null,
        "Scope": "local"
    }
]
```

We should see a **myapp** file created in the volume path.

```bash
$ sudo ls -la /var/lib/docker/volumes/lab08-logs/_data
total 12
drwxr-xr-x 2 root root 4096 Jun 25 11:43 .
drwx-----x 3 root root 4096 Jun 25 11:43 ..
-rw-r--r-- 1 root root 1840 Jun 25 11:44 myapp 
```

Let's display the unique container IDs in the myapp file to verify that all four containers were able to write on this file.

```bash
$ sudo cat /var/lib/docker/volumes/lab08-logs/_data/myapp | cut -d " " -f 2 | sort | uniq
0e0bd1af70b4
974b119df850
c0cf0d7aa335
e3b218904f2c
```
```bash
$ docker ps -aq | sort
0e0bd1af70b4
974b119df850
c0cf0d7aa335
e3b218904f2c
```

Remove the containers and verify that the myapp file still exists in the path.

```bash
$ docker container prune -f 
```
```bash
$ sudo tail -10 /var/lib/docker/volumes/lab08-logs/_data/myapp
Host: 974b119df850 - Loop Number: 49
Host: e3b218904f2c - Loop Number: 48
Host: c0cf0d7aa335 - Loop Number: 47
Host: 0e0bd1af70b4 - Loop Number: 46
Host: e3b218904f2c - Loop Number: 49
Host: c0cf0d7aa335 - Loop Number: 48
Host: 0e0bd1af70b4 - Loop Number: 47
Host: c0cf0d7aa335 - Loop Number: 49
Host: 0e0bd1af70b4 - Loop Number: 48
Host: 0e0bd1af70b4 - Loop Number: 49
```

### Storage: tmpfs

With temporary file system (tmpfs), you can also create the volume when you run the container using the "--mount" flag. The difference is that it is an in-memory storage the data will be accesible as long as the container is running.

We'll use an Ubuntu image for this example. Notice that in our**docker run** command, we don't need to specify the source directory on the host since all the data will be persisted inside the container itself.

```bash
$ docker run -it --mount type=tmpfs,dst="/logs" ubuntu bash
root@ab371cf7e00c:/#
root@ab371cf7e00c:/#
```

Write a message to /logs/mymessages file. Note that this file will be created when you run the command. To detach from container 1, click **Ctrl-P,Q**.

```bash
root@ab371cf7e00c:/# cat > /logs/mymessages

This message will
only exists in the
tmpfs in container 1
```

Another important thing to remember is that if you have multiple containers, they won't share the storage and each will have its own in-memory tmpfs. Run a secnod container and write a message to a file with the same filename. Click **Ctrl-P,Q** to detach from this container.

```bash
$ docker run -it --mount type=tmpfs,dst="/logs" ubuntu bash
root@ddc0d6734996:/#
root@ddc0d6734996:/# cat > /logs/mymessages

Containers are awesome!
```

We now have two running containers.

```bash
$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED              STATUS              PORTS     NAMES
ddc0d6734996   ubuntu    "bash"    About a minute ago   Up About a minute             pensive_kilby
ab371cf7e00c   ubuntu    "bash"    12 minutes ago       Up 12 minutes                 hungry_mendel 
```

Now execute a command on each containers by using the **exec** instruction.

```bash
$ docker exec -it ddc0 cat /logs/mymessages

Containers are awesome! 
```

```bash
$ docker exec -it ab37 cat /logs/mymessages

This message will
only exists in the
tmpfs in container 1 
```

## Cleanup 

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
