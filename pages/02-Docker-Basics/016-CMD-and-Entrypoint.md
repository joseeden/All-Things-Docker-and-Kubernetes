# CMD and ENTRYPOINT

Containers are not meant to host operating systems. Thus when you launch a container of a Linux Image like Ubuntu, it's default command or CMD is bash. This can be seen from the dockerfile itself. 

However if it doesn't detect any terminal, it just stops the process which also stops the container.

### CMD

If you want to define a default command or instruction to run besides the bash when the container is ran, you can specify it in the dockerfile using the CMD keyword.

As an example, we can set the container to sleep for 60 seconds when it is ran by:

```bash 
docker run ubuntu sleep 60
```

An easier way to do this is by including the command itself when creating the **Dockerfile.**

```bash
$ cat > dockerfile 

FROM ubuntu
CMD sleep 60
```

There are ways to specify a command in the dockerfile

```bash 
CMD <command> <parameter1>
CMD ["<command>", "<parameter1>"]                   <<< JSON format
```

### ENTRYPOINT

We can also use a parameter from the commandline itself. This can be done by using ENTRYPOINT in the **dockerfile**.

```bash 
FROM ubuntu
ENTRYPOINT ["sleep"]
```

Now when you run the container, you'll just have to define the parameter.

```bash
$ docker run ubuntu-sleeper 60
```

Note that you'll get an error when you don't append a parameter in the _docker run_ command because the ENTRYPOINT is expecting a parameter.

To include a default value in case user doesn't provide a parameter along with the _docker run_ command, you can use CMD and ENTRYPOINT together

```bash
FROM ubuntu
ENTRYPOINT ["sleep"]
CMD ["60"]
```

**Overriding ENTRYPOINT**

You can also override the entrypoint during runtime by using the "--entrypoint" flag

```bash
docker run --entrypoint sleep2.0 ubuntu-sleeper 60
```
