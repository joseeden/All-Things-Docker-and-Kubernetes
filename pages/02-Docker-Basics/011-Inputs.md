
# Inputs

By default, a docker container doesn't listen to standard input. It runs in a non-interactive shell. You can map the standard input of your host to the docker container using the "-i" flag.

You can also map your terminal to the container's terminal by using the "-t" flag

    "-i"  - interactive
    "-t"  - terminal

As an example, we can use a simple image of an app that prompts the user for its name.

```bash
$ docker pull kodekloud/simple-prompt-docker
$ docker run -it kodekloud/simple-prompt-docker
```


<br>

[Back to first page](../../README.md#docker--containers)