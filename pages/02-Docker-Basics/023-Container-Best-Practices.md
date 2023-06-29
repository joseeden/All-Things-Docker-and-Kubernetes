

# Container Best Practices 


- [Writing Dockerfiles](#writing-dockerfiles)
- [Container Security](#container-security)



## Writing Dockerfiles 

To learn more, check out [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/).

- Use Alpine as base image. Small and a full Linux distribution

    ```bash
    FROM alpine
    ```

- Add MAINTAINER to ensure people know who to contact  

    ```bash
    MAINTAINER John Smith <john.smith@abc.com>
    ```

- Run multiple commands in one RUN statement, connected by && 

    ```bash
    RUN apt-get update && apt-get install -y subversion 
    ```

- Split long RUN statements on multiple lines to keep them readable

    ```bash
    RUN apt-get update && apt-get install -y \
        bzr \
        cvs \
        git \
        mercurial \
        subversion \
        && rm -rf /var/lib/apt/lists/*
    ```

- Use ENV to set environment variables used by the entrypoint applications

    ```bash
    ENV PG_MAJOR=9.3
    ENV PG_VERSION=9.3.4
    RUN curl -SL https://example.com/postgres-$PG_VERSION.tar.xz | tar -xJC /usr/src/postgres && …
    ENV PATH=/usr/local/postgres-$PG_MAJOR/bin:$PATH
    ```

- Use COPY not ADD to copy files onto the containers 

    ```bash
    COPY requirements.txt /tmp/
    RUN pip install --requirement /tmp/requirements.txt
    COPY . /tmp/    
    ```

- Use USER to run as a non-root user

    ```bash
    USER Johnsmith  
    ```

## Container Security 

- Include as little as possible in the container images
- Run rootless containers
- Specify which user account to use in an image 
- Use verified images
- For custom images, sign your images 
- Use access control on container registries
- Run containers on isolated networks
- Use Kuberenetes for implementing Role-based Access Control (RBAC)
