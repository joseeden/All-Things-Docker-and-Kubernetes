# Docker Compose 

## Using docker-compose

Instead of running multiple RUN commands of different images, we could use **docker compose**. In this example, we'll use a sample voting app with result app architecture.

We can see below the comparison between the two approaches.

**First method - multiple RUNs**

```bash 
docker run voting=app
docker run redis
docker run worker
docker run db
docker run result-app
```

**Second method - using DOCKER COMPOSE**

```bash 
# docker-compose.yml
services:
    web:
        image: "voting-app"
    cache:
        image: "db"
    messaging:
        image: "worker"
    db:
        image: "db"
    result:
        image: "result-app"
```

As we can see, the second method is much cleaner and is a more precise way to run containers. To run the entire stack defined in the docker-compose.yml, run the command below.

**NOTE**: This is only applicable if you're running multiple containers in a SINGLE DOCKER HOST.

```bash
$ docker-compose up 
```

We can add more details in the **docker-compose.yml** file.
 
```bash
services:
  redis:
      image: "redis"
  db:
      image: postgres:9.4
  vote:
      # here we're telling it to build the image from the ./vote directory
      build: ./vote
      ports:
          - 5000:80
      # we're linkedin the voting-app container to the redis container
      # note that links may be deprecated now.
      links:
          - redis
  result:
      build: ./result
      ports:
          - 5001:80
      links:
          - db
  worker:
      image: worker
      links:
          - db
          - redis
```

Check out the labs in this repository to learn more about docker compose.


## Docker Compose versions

There are three versions of a docker-compose file. For v2 and v3, you must specify the VERSION.

### Version 1
All containers are attached to the default bridge network and then use LINKS to enable communication between the containers.

```bash
redis:
    image: redis
db:
    image: postgres:9.4
vote:
    image: voting-app
    ports:
        - 5000:80
    links:
        - redis
```

### Version 2

A dedicated network is automatically created for the application and then attaches all containers to that new network. We can also introduce a "DEPENDENCY" feature where a container can only be started based on a condition

```bash 
version: 2
services:
    redis:
        image: redis
    db:
        image: postgres:9.4
    vote:
        image: voting-app
        ports:
            - 5000:80
        # voting-app is created only when the redis container is started
        depends_on:
            - redis
```

### Version 3

Almost similar with v2, but this one supports DOCKER SWARM.

```bash 
version: 3
services:
    redis:
        image: redis
    db:
        image: postgres:9.4
    vote:
        image: voting-app
        ports:
            - 5000:80
```




<br>

[Back to first page](../../README.md#docker--containers)