
# Persisting Data

<br>
<p align=center>
<img src="../../Images/dp-docker-image-layers.png">
</p>
<br>

Recall that a docker image has different layers, with the *first layer as the base image* that the image will use and the layers on top as packages being installed. 

The *last layer is a writeable layer* which applications will use. If a container is started without defining a specific storage option, any data written to the default storage by an application running in a container will be removed as soon as it is stopped.  

For this scenario, Docker provides three storage options.

<p align=center>
<img src="../../Images/dp-storage-options.png">
</p>

## Bind mounts 

Bind mounts work by mounting a directory (that's on the host) to the container. This is a good storage option since the data lives on a directory outside of the container. When the container is stopped or terminated, the data is perfectly safe and intact in the directory residing on the host.

It is important to note that you will need the fully qualified path of the directory on the host to mount it inside the directory.

Use cases:

- **Sharing config files between host and containers** - allows DNS resolution to container by mounting */etc/resolv.conf* into each container 

- **Sharing source code/build artifacts between host and container** - Dockerfile copies artifacts directly into the image, instead of relying on the bind mounts

- **Consistent bindmounts** - when the file/directory structure of the host is consistent with the bind mounts the containers require

## Volumes 

Another option is to use volumes which is similar to bindmounts but docker manages the storage on the host. This means you don't need to know the directory path on the host since this is being managed by Docker itself.

Volumes also allow you to use external storage mechanisms using different drivers, which means you are not limited to the local volume.

In addition,

- if not explicitly created, volumes are created when you mount them for the first time

- volumes are only removed when you explicitly remove them

Use cases:

- **Sharing data between containers** - allows multiple containers to mount the same volum simultaenously, either read-write or read-only 

- **File/directory structure not guaranteed on the host** - decouples host configuration from the container runtime

- **Remote Storage** - storing the data on a remote host or cloud provider, instead of storing locally 

- **Backup, restore, or migrate** - ensuring data has copies on another host 

To add a local volume to a container:

```bash
$ docker run -d \
    -v <name>:</path/on/container> \ 
    --name <name> \
    <image>
```

To mount existing directory to a container:

```bash
$ docker run -d \
    -mount type=bind, source=</path/on/node>, target=<name> \
    --name <name> \
    <image>
```

## tmpfs (Temporary filesystem)

This is an in-memory filesystem, which is basically inside the container. This isn't persistent and data stored here are only accesible as long as the container is running.

<p align=center>
<img src="../../Images/dp-st3-tmpfs.png">
</p>




<br>

[Back to first page](../../README.md#docker--containers)