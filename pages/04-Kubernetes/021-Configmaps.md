
# ConfigMaps and Secrets 


- [ConfigMaps](#configmaps)
    - [Inject the ConfigMap](#inject-the-configmap)
- [Secrets](#secrets)
    - [Base64 encoded](#base64-encoded)
    - [Best Practices](#best-practices)
    - [How Kubernetes handles secrets](#how-kubernetes-handles-secrets)
    - [Ways to create a secret](#ways-to-create-a-secret)
    - [Inject the Secrets](#inject-the-secrets)
- [ConfigMaps and Secrets in Action](#configmaps-and-secrets-in-action)



## ConfigMaps 

ConfigMaps are a type of Kubernetes Resource that is used to decouple configuration artifacts from container image content to keep containerized applications portable. The configuration data is stored as key-value pairs.  

- data is stored in key-value pairs
- pods reference ConfigMaps and secrets to use their data
- can be mounted as volumes or set as environment variables

ConfigMaps can be created from:

- Environment variable files consisting of key-value pairs separated by equal signs
- Regular files or directories of files result in keys that are the names of the files and values that are the contents of the files.
- Literals consisting of individual key-value pairs that you specify on the command line.
- Writing a YAML manifest file of kind: **ConfigMap**.

Like most Kubernetes Resources, ConfigMaps are namespaced so only Pods in the same Namespace as a ConfigMap can use the ConfigMap.

### Inject the ConfigMap 

To see an example of a ConfigMap file, check out this [lab](../../Lab49_ConfigMaps_and_Secrets/README.md). 
After the ConfigMap is created, the next step is to inject it to the Pod.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
  labels:
    name: myapp
spec:
  containers:
  - name: myapp
    image: <Image>
    ports:
      - containerPort: <Port>
    envFrom:
      - configMapRef:
            name: USERNAME
```

**Ways to inject the ConfigMap in Pods**

As an environment variable:

```yaml
    envFrom:
      - configMapRef:
            name: USERNAME
```

As a single environment variable:

```yaml
    env:
      - name: DB_Username 
        valueFrom:
            configMapKeyRef:
                name: app_configMap
                key: DB_Username
```

Mount the configMap as a volume to the container 

```yaml
    volumes:
      - name: app-configMap-volumes 
        configMap:
            name: app-configMap
```




## Secrets

Similar to ConfigMaps, Secrets are also custom resources which can be stored separately instead of including them in the specs file. The main difference between these two custom resources is that secrets are specifically used for storing sensitive information. 

Secrets reduce the risk of accidental exposure compared to if they were stored in an image or put in a Pod specification. 

In addition to this, secrets supports the following:

- storing secrets as **key-value pairs**, and
- **specialized support** for storing Docker registry credentials and TLS certs.

### Base64 encoded

It is important to note that secrets are **not encrypted at rest by default** and are instead only **base-64 encoded**.  Anyone with the base64 encoded secret can easily decode it. As such the secrets can be considered as not very safe.

The Kubernetes documentation page and a lot of blogs out there refer to secrets as a "safer option" to store sensitive data. They are safer than storing in plain text as they reduce the risk of accidentally exposing passwords and other sensitive data. In general, it's not the secret itself that is safe, it is the practices around it. 

### Best Practices 

Secrets are not encrypted, so it is not safer in that sense. However, some best practices around using secrets make it safer:

- Not checking-in secret object definition files to source code repositories.

- Enabling Encryption at Rest for Secrets so they are stored encrypted in ETCD.

- Separately control access to ConfigMaps and Secrets

By following the pattern of storing sensitive data in Secrets, users of the cluster can be denied access to Secrets but granted access to ConfigMaps using Kubernetes access control mechanisms. 

### How Kubernetes handles secrets
Kubernetes also handles secrets in various ways:

- A secret is only sent to a node if a pod on that node requires it.

- Kubelet stores the secret into a tmpfs so that the secret is not written to disk storage.

- Once the Pod that depends on the secret is deleted, kubelet will delete its local copy of the secret data as well.


Having said that, there are other better ways of handling sensitive data like passwords in Kubernetes, such as using tools like:

- Helm Secrets
- HashiCorp Vault

### Ways to create a secret

**Imperative** approach, using the command below:

    ```bash
    # Supply secrets directly on the command 
    kubectl create secret generic  \
         <secret-name></secret-name>  \
         --from-literal=<key>=<value>

    # Use secrets defined in a file
    kubectl create secret generic  \
         <secret-name></secret-name>  \
         --from-file=<filename.json>
    ```

**Declarative** approach, using a spec file:

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
        name: mysecret  
    type: Opaque
    data:
        variable1: sdferr==
        variable1: vdsrfg==
        variable1: weri34rf

    ## Note that the value for the variable should be the 
    ## base64-encoded format of the original secret. 
    ## To encode the original secret:
    #       echo -n 'original-password' | base64 
    ```

To retrieve the secrets:

```bash
kubectl get secrets 
```
```bash
kubectl describe secrets 
```

The next step is to inject the secret to the Pod or Deployment manifest.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
  labels:
    name: myapp
spec:
  containers:
  - name: myapp
    image: <Image>
    ports:
      - containerPort: <Port>
    envFrom:
      - secretRef:
            name: USERNAME
```
 
### Inject the Secrets

As an environment variable:

```yaml
    envFrom:
      - secretRef:
            name: USERNAME
```

As a single environment variable :

```yaml
    env:
      - name: DB_Username 
        valueFrom:
            secretKeyRef:
                name: app_secret
                key: DB_Username
```

Mount the secret as a volume to the container 

```yaml
    volumes:
      - name: app-secret-volumes 
        secret:
            secretName: app-secret
```



## ConfigMaps and Secrets in Action

To see ConfigMaps and Secrets in actions check out this [lab](../../projects/Lab_049_ConfigMaps_and_Secrets/README.md).



<br>

[Back to first page](../../README.md#kubernetes)
