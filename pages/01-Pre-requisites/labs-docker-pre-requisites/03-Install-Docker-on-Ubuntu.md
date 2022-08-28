
# Install Docker on Ubuntu

This is a summary of the commands that you can run to install docker on Ubuntu.

```bash
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
$ sudo apt-get update -y 
$ sudo sudo apt-get install docker-ce docker-ce-cli containerd.io -y 
$ sudo usermod -aG docker ubuntu 
```

You can check out the [official Docker installation guide](https://docs.docker.com/engine/install/ubuntu/) for more details.
  
</details>