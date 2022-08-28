# Port Mapping

Recall that the underlying host (your machine) where docker is installed is called **DOCKER HOST** or **DOCKER ENGINE**.

If you want to access your app in the container through a web browser, we can use the container's IP, but note that this is an internal IP and is only accessible from the host itselF. This means that users outside the host cannot access this IP.

To get the IP address;

```bash
$ docker ps
$ docker inspect <container-id>
```

To access the ip from within the host, we can open the ip address in a browser in the host. we can also do a curl in the host's terminal. Note that 8080 is the default port of the container

```bash
$ curl <ip-of-vm>:8080
```

We can also use the IP of the docker host, but we need to map the port inside the container to the free port inside the docker host. We can use the "-p" flag to map the ports

As an example, we can use to map container port 5000 to host port 80.

```bash
$ docker run -d -p 80:8080 kodekloud/simple-webapp
```

To see the port mappings in your linux machine:

```bash 
$ netstat -tulpn
```