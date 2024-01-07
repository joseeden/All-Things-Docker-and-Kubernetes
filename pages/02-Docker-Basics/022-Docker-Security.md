
# Container Security


## Security Risks 

- Containers address the same kernel 
- Containers running as root 
- Public images may contain malicious software

## Cloud Native Security 

In Cloud Native Security, four layers are identified:

- Cloud/Colocation/Corporate datacenter
- Cluster
- Container
- Code

## Docker Security 

These are the security features that Docker uses under the hood.

**Swarm mode** 

- security settings are turned-on by default
- uses PKI infrastructure for handling certificates 
- tunnel are created between endpoints on the containers

**Docker Content Trust** 

- Sign images for integrity verification

    ```bash
    export DOCKER_CONTENT_TRUST=1 
    ```

**Security Scanning**

- scans images for vulnerabilities

**Secrets**

- data is encrypted and stored

    ```bash
    docker secret 
    ```

## Best Practices 

To learn more about container security best practices, check out [Container Best Practices.](./023-Container-Best-Practices.md)



<br>

[Back to first page](../../README.md#docker--containers)