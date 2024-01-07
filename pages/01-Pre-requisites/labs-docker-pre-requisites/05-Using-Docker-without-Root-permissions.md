
## Using Docker without Root Permission

By default, the Docker daemon will reject requests from users that aren't part of the docker group. If you encounter this message in your travels, you can either use root permission or add your user to the docker group.

```bash
docker info 
```
```bash
ERROR: Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/info": dial unix /var/run/docker.sock: connect: permission denied 
```

Verify the docker group exists by searching for it in the groups file:

```bash
grep docker /etc/group
```

Add the group if it doesn't exist.

```bash
sudo groupadd docker
```

Add your user to the docker group.

```bash
sudo gpasswd -a $USER docker
```

You can login again to have your groups updated by entering:

```bash
newgrp docker 
```

It is convenient to not have to terminate your current ssh session by using newgrp, but terminating the ssh session and logging in again will work just as well. In some instances, you may need to restart the Docker daemon by entering:

```bash
sudo systemctl restart docker.
```

Now try to run docker commands without issuing sudo:

```bash
docker info 
```



<br>

[Back to first page](../../README.md#docker--containers)