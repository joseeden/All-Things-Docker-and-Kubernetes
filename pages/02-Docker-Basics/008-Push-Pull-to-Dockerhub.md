# Pushing/Pulling an Image to/from a Container Registry
 
Let's use Dockerhub as our example. 

Once you've [set up a Dockerhub account.](https://hub.docker.com/signup), you can now login through the terminal.

```bash
$ docker login
```

Assuming the image is tagged, the final step is to push the image to a registry. 

```bash
$ docker push NAME[:TAG]
```

For example, to push the sample Python hello-world application tagged with v1 to 'my-repo' repository in DockerHub
```bash
$ docker push my-repo/python-helloworld:v1.0.0
```

To pull an image from DockerHub,
```bash
$ docker pull NAME[:TAG]
```


<br>

[Back to first page](../../README.md#docker--containers)