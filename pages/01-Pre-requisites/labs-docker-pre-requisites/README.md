# Pre-requisites for Docker Labs

## Install Docker

With the introduction of Hyper-V, this gave way for **Docker Desktop for Windows** which under the hood, uses WSL2's to launch a VM as the host Linux operating system.

**NOTE:** Running containers on Windows machines is suited for local development purposes only and is NOT RECOMMENDED FOR PRODUCTION USE.

- [Install Docker on WSL2 without Docker Desktop](01-Install-Docker-on-WSL2-without-Docker-Desktop.md)

- [Install Docker on RHEL/CentOS](02-Install-Docker-on-RHEL-CentOS.md)

- [Install Docker on Ubuntu](03-Install-Docker-on-Ubuntu.md)

- [Install Docker on Ubuntu using Terraform](04-Install-Docker-on-Ubuntu-using-Terraform.md) 


## Install Docker Compose
 
If you're using Ubuntu, you can install docker-compose by simply running the two commands below:

```bash
$ sudo apt-get update 
$ sudo apt-get install -y docker-compose 
```

Read more about it in [Install Docker Compose CLI plugin page.](https://docs.docker.com/compose/install/compose-plugin/#installing-compose-on-linux-systems)


## Error: Cannot connect to the Docker daemon

In case you encounter this message when you test Docker for the first time:

```bash
docker: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
```

To resolve this, start the docker service and docker daemon,

```bash
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker
```
```bash
sudo dockerd
```

You can checkout this [Stackoverflow discussion](https://stackoverflow.com/questions/44678725/cannot-connect-to-the-docker-daemon-at-unix-var-run-docker-sock-is-the-docker) to know more.



<br>

[Back to first page](../../../README.md#projects)