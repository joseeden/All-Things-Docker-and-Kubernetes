
# Lab 42: Service Discovery

Pre-requisites:

- [Basic Understanding of Kubernetes](../README.md#kubernetes)
- [AWS account](../pages/01-Pre-requisites/labs-optional-tools/README.md#create-an-aws-account)
- [AWS IAM Requirements](../pages/01-Pre-requisites/labs-optional-tools/01-AWS-IAM-requirements.md)
- [AWS CLI, kubectl, and eksctl](../pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md#install-cli-tools) 

Here's a breakdown of sections for this lab.

- [Introduction](#introduction)
- [Launch a Simple EKS Cluster](#launch-a-simple-eks-cluster)
- [Namespace](#namespace)
- [Data tier](#data-tier)
- [App tier using Environment Variables for Service Discovery](#app-tier-using-environment-variables-for-service-discovery)
- [Support Tier using DNS for Service Discovery](#support-tier-using-dns-for-service-discovery)
- [Cleanup](#cleanup)

## Introduction

We'll redesigned the architecture from the [previous lab](../Lab_041-Multi_Container_Pods/README.md) and break down the containers into their own pods. This will no introduce some networking issues since the containers are not on the same pod anymore.

<p align=center>
<img width=700 src="../Images/lab42-service-discovery-diag.png">
</p>

To resolve this, we'll use **Services** which will provide a static endpoint that will handle communication between pods. 

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

We'll use [svc-discovery-namespace.yml](manifests/svc-discovery-namespace.yml) to create the **service-discovery** namespace for this project.

```bash
apiVersion: v1
kind: Namespace
metadata:
  name: service-discovery
  labels:
    app: counter
```

Apply.

```bash
kubectl apply -f svc-discovery-namespace.yml 
```

## Data tier 

Next, we'll use three manifests for each tier, starting with the [data-tier.yml](manifests/data-tier.yml) which will create the Redis pod and the Service that will allow it to talk to the NodeJS pod in a separate container.

When we run the command below, the resources will be created in the order the are specified in the file.

```bash
kubectl apply -f data-tier.yml
```

The pod has a label "tier:data" which will be used by the Service as its selector. The service resource also publishes a port (it can publish as many ports as you need) and name it "redis".

Lastly, the Service is specified as a **ClusterIP** type which is the default. ClusterIP creates an internal virtual IP for access  between resources inside the cluster only.

Verify that the pod is running.

```bash
$ kubectl get pods -n service-discovery
NAME        READY   STATUS    RESTARTS   AGE
data-tier   1/1     Running   0          59s 
```

Check for the service.

```bash
$ kubectl get svc -n service-discovery
NAME        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
data-tier   ClusterIP   10.100.66.141   <none>        6379/TCP   113s 
```

## App tier using Environment Variables for Service Discovery

Let's use [app-tier.yml](manifests/app-tier.yml) to create the resources for the NodeJS server. It follows the same structure as the data tier manifest, but now we're using an environment variable that is set by Kubernetes.

```bash
apiVersion: v1
kind: Service
metadata:
  name: app-tier
  labels:
    app: microservices
spec:
  ports:
  - port: 8080
  selector:
    tier: app
---
apiVersion: v1
kind: Pod
metadata:
  name: app-tier
  namespace: service-discovery
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

In the [previous lab](../Lab_041-Multi_Container_Pods/README.md#multi-container-pods), the **REDIS_URL** is set to localhost because all containers are contained the same pod and they talk over localhost. Since the containers are now in separate pods, the containers cannot rely on the IP address of each Pod because the IP address may change as Pods are created and deleted.

Instead, Kubernetes will use environment variables for the service that will provide the static endpoint for each Pod. We can use the variable **DATA_TIER_SERVICE_HOST** and Kubernetes will automatically know that we're referring to the service resource in the data tier. THe same way goes for the variable for the port, **DATA_TIER_SERVICE_PORT_REDIS**, making sure we specify the name of the port.

**Services must first be created before using an environment variable**

Since environment variables rely on Kubernetes to find the service, it is important that the service are created first before the Pod resource can use the variable.

**Environment variables has to be on the same namespace as the resources**

As we've learn, namespace is use to group resources. This includes environment variables.

Let's now create the app tier.

```bash
kubectl apply -f app-tier.yml
```

Check the pods.

```bash
$ kubectl get pods -n service-discovery
NAME        READY   STATUS    RESTARTS   AGE
app-tier    1/1     Running   0          22s
data-tier   1/1     Running   0          25m 
```

## Support Tier using DNS for Service Discovery

Finally, let's create the support tier using [support-tier.yml](manifests/support-tier.yml). Instead of just environment variables, we'll tell Kubernetes to rely on DNS to find the app tier resources. Note that the poller uses variables while the counter uses DNS.

```bash
apiVersion: v1
kind: Pod
metadata:
  name: support-tier
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
          value: http://app-tier.service-discovery:8080

    - name: poller
      image: lrakai/microservices:poller-v1
      env:
        - name: API_URL
          # omit namespace to only search in the same namespace
          value: http://app-tier:$(APP_TIER_SERVICE_PORT)
```

Apply.

```bash
kubectl apply -f support-tier.yml 
```

We now have three running pods at this point.

```bash
$ kubectl get pods -n service-discovery
NAME           READY   STATUS    RESTARTS   AGE
app-tier       1/1     Running   0          6m25s
data-tier      1/1     Running   0          40m
support-tier   2/2     Running   0          39s 
```

Let's now check if the is able to continuously send GET requests from the NodejS server.

```bash
$ kubectl logs support-tier poller -n service-discovery --tail 10
Current counter: 1625
Current counter: 1637
Current counter: 1647
Current counter: 1657
Current counter: 1673
Current counter: 1688
Current counter: 1702
Current counter: 1711
Current counter: 1720
Current counter: 1739 
```

## Cleanup

Make sure to delete the cluster after the lab to save costs.

```bash
$ time eksctl delete cluster -f eksops.yml 
```

When you delete your cluster, make sure to double check the AWS Console and that the Cloudformation stacks (which we created by eksctl) are dropped cleanly.