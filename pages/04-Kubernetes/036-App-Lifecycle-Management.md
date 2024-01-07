
# Application Lifecycle Management 


- [Rolling Updates and Rollbacks](#rolling-updates-and-rollbacks)
- [Environment Variables](#environment-variables)
- [ConfigMaps and Secrets](#configmaps-and-secrets)
- [Multi-Container Pods](#multi-container-pods)


## Rolling Updates and Rollbacks 

Kubernetes uses rollouts to updates the deployments, which includes replacing the replicas that matches the specs in the new deployment template. Other changes could also include environment variables, labels, and code changes.

To learn more, check out [Rollouts and Rollbacks](./019-Rollouts-and-Rollbacks.md)


## Environment Variables 

We can simply create environment variables by using the **env** property, followed by a key-value pairs of variables. As example: 

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
    env:
      - name: USERNAME 
        value: paul 
      - name: DEPARTMENT
        value: finance 
      - name: ROLE 
        value: read-only 
```

Other ways of setting environment variables are through:

- ConfigMaps 
- Secrets 

The main difference is how the variables are defined in the Pod manifest;

```yaml
# Set the environment variables directly in the Pod manifest
    env:
      - name: USERNAME 
        value: paul 
```
```yaml
# Pull the environment variables from a COnfigMap 
    env:
      - name: USERNAME 
        valuefrom:
            configMapKeyRef:
```
```yaml
# Pull the environment variables from a Secret 
    envFrom:
      - secretRef:
            name: USERNAME
```

## ConfigMaps and Secrets 

ConfigMaps are used to decouple configuration artifacts from container image content to keep containerized applications portable. The configuration data is stored as key-value pairs in a YAML file separate from the actual Deployment manifest.

On the other hand, Secrets are specifically used for storing sensitive information. Secrets reduce the risk of accidental exposure compared to if they were stored in an image or put in a Pod specification. 

To learn more, check out [ConfigMaps and Secrets](./021-Configmaps.md) 

## Multi-Container Pods 

With multi-container Pods, we have a number of Pods that share the same lifecycle, which means these Pods are created together and destroyed together.

- they share the same network space, so they communicate through ports 
- they have access to the same storage volume



<br>

[Back to first page](../../README.md#kubernetes)
