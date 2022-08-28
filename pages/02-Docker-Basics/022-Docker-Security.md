
# Docker Security

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
