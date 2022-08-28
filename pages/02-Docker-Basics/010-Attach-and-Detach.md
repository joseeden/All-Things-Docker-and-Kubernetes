
# Attach and Detach Mode

You can run a container in an **ATTACH** mode - this means process will run in the foreground. You cannot do anything else while process is attached to the console until container exits.

The console won't response to any input, except if you stop it by running Ctrl-C

As an example, we can run a simple web-server that listens on port 8080.

```bash
$ sudo docker run kodekloud/simple-webapp
```

Check the running containers.

```bash 
$ sudo docker ps

CONTAINER ID   IMAGE                     COMMAND           CREATED          STATUS          PORTS      NAMES
734e84936864   kodekloud/simple-webapp   "python app.py"   30 seconds ago   Up 29 seconds   8080/tcp   relaxed_grothendieck
```

On the other hand, running containers in **DETACH** mode means the container is running in the background. This can be done by using the "-d" flag. 

```bash
$ sudo docker run -d ubuntu sleep 60 
```

To attach to the running container in the background, you can run the **attach** command, followed by either the container ID or the container name.

```bash
$ sudo docker ps
$ sudo docker attach <container-id>
$ sudo docker attach <container-name>
```

You can also run and automatically log in to the container by using the "-it" flag.

```bash
sudo docker run -it -d --name nyancat2 06kellyjac/nyancat
```