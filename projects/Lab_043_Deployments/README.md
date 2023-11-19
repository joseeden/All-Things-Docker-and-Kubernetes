
# Lab 43: Deployments

Pre-requisites:

- [Basic Understanding of Kubernetes](../README.md#kubernetes)
- [AWS account](../pages/01-Pre-requisites/labs-optional-tools/README.md#create-an-aws-account)
- [AWS IAM Requirements](../pages/01-Pre-requisites/labs-optional-tools/01-AWS-IAM-requirements.md)
- [AWS CLI, kubectl, and eksctl](../pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md#install-cli-tools) 

Here's a breakdown of sections for this lab.

- [Introduction](#introduction)
- [Launch a Simple EKS Cluster](#launch-a-simple-eks-cluster)
- [Create the Namespace](#create-the-namespace)
- [Data Tier](#data-tier)
- [App Tier](#app-tier)
- [Support Tier](#support-tier)
- [Scale the Replicas](#scale-the-replicas)
- [Cleanup](#cleanup)


## Introduction

We've launched pods in the previous labs using pod manifests. However, Pods are not meant to be created directly. Instead they should be handled using deployments. This ensures that Kubernetes is able to leverage the scale functionality of deployments, as well as add useful features to the pods.

We'll use the same architecture from the [previous lab](../Lab_042_Service_Discovery/README.md).

<p align=center>
<img width=700 src="../Images/lab42-service-discovery-diag.png">
</p>


## Launch a Simple EKS Cluster

Before we start, let's first verify if we're using the correct IAM user's access keys. This should be the user we created from the **pre-requisites** section above.

```bash
$ aws sts get-caller-identity 
```
```bash
{
    "UserId": "AIDxxxxxxxxxxxxxx",
    "Account": "1234567890",
    "Arn": "arn:aws:iam::1234567890:user/k8s-admin"
} 
```

For the cluster, we can reuse the **eksops.yml** file from the previous labs.

<details><summary> eksops.yml </summary>
 
```bash
apiVersion: eksctl.io/v1alpha5
# apiVersion: client.authentication.k8s.io/v1beta1
kind: ClusterConfig

metadata:
    version: "1.23"
    name: eksops
    region: ap-southeast-1 
nodeGroups:
    -   name: ng-dover
        instanceType: t3.large
        minSize: 1
        maxSize: 5
        desiredCapacity: 1
        ssh: 
            publicKeyName: "k8s-kp"
```
 
</details>

Launch the cluster.

```bash
time eksctl create cluster -f eksops.yml 
```

Check the nodes and pods.

```bash
kubectl get nodes 
```

Save the cluster, region, and AWS account ID in a variable. We'll be using these in a lot of the commands later.

```bash
MYREGION=ap-southeast-1
MYCLUSTER=eksops 
MYAWSID=$(aws sts get-caller-identity | python3 -c "import sys,json; print (json.load(sys.stdin)['Account'])")
```

## Create the Namespace

We'll use [namespace-deployments.yml](manifests/namespace-deployments.yml) to create **deployments** namespace.

```bash
apiVersion: v1
kind: Namespace
metadata:
  name: deployments
  labels:
    app: counter
```

Apply.

```bash
kubectl apply -f namespace-deployments.yml 
```

Verify.

```bash
$ kubectl get ns
NAME                STATUS   AGE
default             Active   8h
deployments         Active   18s 
```

## Data Tier 

We'll use [deployment-data.yml](manifests/deployment-data.yml) to create the data tier Service and Deployments. We can specify the replica to 1 for now.

```bash
apiVersion: v1
kind: Service
metadata:
  name: data-tier
  namespace: deployments
  labels:
    app: microservices
spec:
  ports:
  - port: 6379
    protocol: TCP # default 
    name: redis # optional when only 1 port
  selector:
    tier: data 
  type: ClusterIP # default
---
apiVersion: apps/v1 # apps API group
kind: Deployment
metadata:
  name: data-tier
  namespace: deployments
  labels:
    app: microservices
    tier: data
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: data
  template:
    metadata:
      labels:
        app: microservices
        tier: data
    spec: # Pod spec
      containers:
      - name: redis
        image: redis:latest
        imagePullPolicy: IfNotPresent
        ports:
          - containerPort: 6379 
```

Apply.

```bash
kubectl apply -f deployment-data.yml 
```

## App Tier 

For the app tier, we'll use [deployment-app.yml.](manifests/deployment-app.yml).

```bash
apiVersion: v1
kind: Service
metadata:
  name: app-tier
  namespace: deployments
  labels:
    app: microservices
spec:
  ports:
  - port: 8080
  selector:
    tier: app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-tier
  namespace: deployments
  labels:
    app: microservices
    tier: app
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: app
  template:
    metadata:
      labels:
        app: microservices
        tier: app
    spec:
      containers:
      - name: server
        image: lrakai/microservices:server-v1
        ports:
          - containerPort: 8080
        env:
          - name: REDIS_URL
            # Environment variable service discovery
            # Naming pattern:
            #   IP address: <all_caps_service_name>_SERVICE_HOST
            #   Port: <all_caps_service_name>_SERVICE_PORT
            #   Named Port: <all_caps_service_name>_SERVICE_PORT_<all_caps_port_name>
            value: redis://$(DATA_TIER_SERVICE_HOST):$(DATA_TIER_SERVICE_PORT_REDIS)
            # In multi-container example value was
            # value: redis://localhost:6379  
```

Apply.

```bash
kubectl apply -f deployment-app.yml 
```

## Support Tier 

Finally, we'll use [deployment-support.yml](manifests/deployment-support.yml) to create the support tier.

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: support-tier
  namespace: deployments
  labels:
    app: microservices
    tier: support
spec:
  replicas: 1
  selector:
    matchLabels:
      tier: support
  template:
    metadata:
      labels:
        app: microservices
        tier: support
    spec:
        containers:

        - name: counter
          image: lrakai/microservices:counter-v1
          env:
            - name: API_URL
              # DNS for service discovery
              # Naming pattern:
              #   IP address: <service_name>.<service_namespace>
              #   Port: needs to be extracted from SRV DNS record
              value: http://app-tier.deployments:8080

        - name: poller
          image: lrakai/microservices:poller-v1
          env:
            - name: API_URL
              # omit namespace to only search in the same namespace
              value: http://app-tier:$(APP_TIER_SERVICE_PORT)
```

Apply.

```bash
kubectl apply -f deployment-support.yml 
```

We should now have three pods running.

```bash
$ kubectl get pods -n deployments
NAME                            READY   STATUS    RESTARTS   AGE
app-tier-74d6d7465d-hb7l9       1/1     Running   0          3m20s
data-tier-6c8f55b94f-zm5zc      1/1     Running   0          8m43s
support-tier-66f4cc4f7c-2gphl   2/2     Running   0          31s 
```

List the deployments.

```bash
$ kubectl get deployments -n deployments
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
app-tier       1/1     1            1           4m40s
data-tier      1/1     1            1           10m
support-tier   1/1     1            1           111s 
```

## Scale the Replicas 

Let's now try to scale the app tier to 3 pods.

```bash
kubectl scale deployments app-tier --replicas=3 -n deployments 
```

Verify that the deployment is scaled.

```bash
$ kubectl get deployments -n deployments
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
app-tier       3/3     3            3           7m15s
data-tier      1/1     1            1           12m
support-tier   1/1     1            1           4m26s 
```
```bash
$ kubectl get pods -n deployments
NAME                            READY   STATUS    RESTARTS   AGE
app-tier-74d6d7465d-bmjsp       1/1     Running   0          62s
app-tier-74d6d7465d-hb7l9       1/1     Running   0          7m59s
app-tier-74d6d7465d-nqb6f       1/1     Running   0          62s
data-tier-6c8f55b94f-zm5zc      1/1     Running   0          13m
support-tier-66f4cc4f7c-2gphl   2/2     Running   0          5m10s 
```

Let's try to delete one of the app-tier pods. Kubernetes detects the changes and spins up a new pod so that the desireed state of 3 pods is maintained.

```bash
kubectl delete pod app-tier-74d6d7465d-bmjsp -n deployments
```
```bash
$ kubectl get pods -n deployments
NAME                            READY   STATUS    RESTARTS   AGE
app-tier-74d6d7465d-hb7l9       1/1     Running   0          9m54s
app-tier-74d6d7465d-nqb6f       1/1     Running   0          2m57s
app-tier-74d6d7465d-z8kmj       1/1     Running   0          9s
data-tier-6c8f55b94f-zm5zc      1/1     Running   0          15m
support-tier-66f4cc4f7c-2gphl   2/2     Running   0          7m5s 
```

## Cleanup

Make sure to delete the cluster after the lab to save costs.

```bash
$ time eksctl delete cluster -f eksops.yml 
```

When you delete your cluster, make sure to double check the AWS Console and that the Cloudformation stacks (which we created by eksctl) are dropped cleanly.