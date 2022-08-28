# Install Docker on WSL2 without Docker Desktop 

Note on [Docker Desktop's changing to paid subscription](https://www.docker.com/legal/docker-subscription-service-agreement/):

> *After January 31, 2022, Docker Desktop will require a paid subscription*.
>
> *Commercial use of Docker Desktop in larger enterprises requires a Docker Pro, Team or Business subscription for as little as 5 USD per user per month.*
>
> *The existing Docker Free subscription has been renamed Docker Personal. Docker Desktop remains free for personal use, education, non-commercial open source projects, and small businesses (fewer than 250 employees AND less than 10M USD in annual revenue).*


## Installation 

A quick Google search shows how to [install Docker in WSL2 without Docker desktop:](https://dev.solita.fi/2021/12/21/docker-on-wsl2-without-docker-desktop.html)

Remove old Docker installations.

```bash
$ sudo apt remove docker \
docker-engine \
docker.io \
containerd runc 
```

Install some pre-requisites.

```bash
$ sudo apt update 
$ sudo apt install -y --no-install-recommends \
apt-transport-https ca-certificates curl gnupg2
```

Configure package repository

```bash
$ source /etc/os-release 
$ curl -fsSL https://download.docker.com/linux/${ID}/gpg | sudo apt-key add -
$ echo "deb [arch=amd64] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list
$ sudo apt update
```

Install Docker.

```bash
$ sudo apt install -y docker-ce docker-ce-cli containerd.io
```

## Configuration 

Add user to group

```bash
$ sudo usermod -aG docker $USER 
```

Configure dockerd

```bash
$ DOCKER_DIR=/mnt/wsl/shared-docker
$ mkdir -pm o=,ug=rwx "$DOCKER_DIR"
$ sudo chgrp docker "$DOCKER_DIR"
$ sudo mkdir /etc/docker
$ sudo vi /etc/docker/daemon.json 

    {
    "hosts": ["unix:///mnt/wsl/shared-docker/docker.sock"]
    }
```

Test if it works. Run the command below. It should return "API listen on.." message.

```bash
$ sudo dockerd 

API listen on /mnt/wsl/shared-docker/docker.sock
```

Do another test. Open another terminal and run the command below.

```bash
$ docker -H unix:///mnt/wsl/shared-docker/docker.sock run --rm hello-world
```

It should return this output.

<details><summary> run hello-world </summary>
 
```bash
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```
 
</details>

## Create Launch Script for Dockerd 

Create a launch script for dockerd. You can do this in two ways:

- Manual approach
- Automatic approach 

### Manual Approach 

Add the following to .bashrc or .profile 

```bash
$ cat >> ~/.bashrc

DOCKER_SOCK="/mnt/wsl/shared-docker/docker.sock"
test -S "$DOCKER_SOCK" && export DOCKER_HOST="unix://$DOCKER_SOCK"
```

### Automatic Approach 

Add the following to .bashrc or .profile 
```bash
$ cat >> ~/.bashrc

DOCKER_DISTRO=$(cat /etc/os-release | grep PRETTY_NAME | cut -c14- | cut -d ' ' -f1,2)
DOCKER_DIR=/mnt/wsl/shared-docker
DOCKER_SOCK="$DOCKER_DIR/docker.sock"
export DOCKER_HOST="unix://$DOCKER_SOCK"

if [ ! -S "$DOCKER_SOCK" ]; then
   mkdir -pm o=,ug=rwx "$DOCKER_DIR"
   sudo chgrp docker "$DOCKER_DIR"
   /mnt/c/Windows/System32/wsl.exe -d $DOCKER_DISTRO sh -c "nohup sudo -b dockerd < /dev/null > $DOCKER_DIR/dockerd.log 2>&1"
fi
```
 