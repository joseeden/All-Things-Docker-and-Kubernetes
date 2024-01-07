# Container Management Challenges 

Since you've reached this Kubernetes section, I'm assuming that you've work around some of these topics:

- TCP/IP Networking 
- Linux 
- Containers

As a recap, **containers** are a way to isolate and ship applications with dependencies and runtimes tied to it. 

In addition to this, containers:

- are considered as "Linux processes" under the hood which exits when the application has done its purpose.
- allows mapping to external volumes to persist data.
- can publish ports which allows access to the application running inside the container.

<p align=center>
<img width=700 src="../../Images/udacity-suse-1-container.png">
</p>

While containers have indeed revolutionized ways on how software can be delivered, it still had some challenges:

- How do we keep track of which port goes to which container on which host?

- How should we efficiently allocate containers to hosts?

- Given that microservices scale horizontally, how do we map service dependencies?

- Given that applications are frequently updated and container ports are randomized, how do we account for frequent changes?

As an example, check the diagram below. Here we have three NGINX containers running on the same underlying server. To serve the website, we can map ports on the container to the host ports. This enables port-forwarding and will direct any traffic that access the arbitrary host port and forward it to the mapped port on the container.

<p align=center>
<img src="../../Images/Server.png">
</p>

This can be done by manually mapping ports. We could also simply utilize dynamic mapping by specifying the "-P" flag when running the containers. To create three containers, we can run the command below three times. Each container will have a dynamic port assigned to it.

```bash
docker run -d -P nginx 
```

We can also throw in some basic scripting so that we can run the containers in one swoop.

```bash
for i in $(seq 3) ; do docker run -d -P nginx; done
```

It is still manageable when you have a small number of applications running on single host. However, this becomes more problematic when you add more applications and more hosts. In addition to this, things becomes more complicated when you have dependencies between applications.

<p align=center>
<img src="../../Images/manydockers.png">
</p>

We can simply use the command below to run this setup but as you can see, we would need a much better solution of managing this kind of situation.

```bash
for i in $(seq 6); do
    for j in $(seq 3); do
        ssh node0$i docker run -d -P app${i}-${j};
    done;
done 
```

From a developer's perspective, it would be just nice if we can:

- just package up an app and let something else manage it for us 
- don't have to  worry about the management of containers 
- eliminate single points of failure 
- scale containers
- update containers without bringing down the application 
- have a robust networking and persistent storage options

**Enter Kubernetes.**



<br>

[Back to first page](../../README.md#kubernetes)
