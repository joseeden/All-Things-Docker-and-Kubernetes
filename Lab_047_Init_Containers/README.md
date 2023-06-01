
# Lab 47: Init Containers 

Pre-requisites:

- [Lab 46: Probes](../Lab_046_Probes/README/md)

Here's a breakdown of sections for this lab.

- [Introduction](#introduction)
- [App Tier](#app-tier)
- [Cleanup](#cleanup)



## Introduction

In the previous lab, we've seen how probes work and how we can use them to run health checks on containers inside a Pod. However, probes only kick in AFTER containers are started.

There will be scenarios where you need to perform some task right before the main application container even starts, like waiting for a pre-requisite service to be created, downloading files, or grabbing the dynamic ports assigned.

To do this, we can use **init containers** initialize the task before the main application starts. This allows us to delay or block the starting of an application if pre-conditions are not met.

We'll use the same application architecture from the previous lab, but we'll add an init container to App tier that will wait for Redis to start before starting the application

<p align=center>
<img width=700 src="../Images/lab42-service-discovery-diag.png">
</p>

To learn more about init containers, check out this [page](../pages/04-Kubernetes/020-Probes.md).

## App Tier 

For this lab, we'll only be updating the app tier. Let's start with deleting the  deployments from the previous lab so that we have a fresh plate.

```bash
kubectl delete -f deployment-app.yml 
kubectl delete -f deployment-data.yml 
kubectl delete -f deployment-support.yml
```

We'll then use the new [deployment-app-init-containers.yml](manifests/deployment-app-init-containers.yml) manifest. Notice that we now have an init container spec section.

This defines the condition that must be met before proceeding with starting the main application container.

```bash
      initContainers:
        - name: await-redis
          image: lrakai/microservices:server-v1
          env:
          - name: REDIS_URL
            value: redis://$(DATA_TIER_SERVICE_HOST):$(DATA_TIER_SERVICE_PORT_REDIS)
          command:
            - npm
            - run-script
            - await-redis 
```

Now apply the manifest for the support and the modified app tier.

```bash
kubectl apply -f deployment-support.yml
kubectl apply -f deployment-app-init-containers.yml
```

Check the pods. Notice that the app tier failed to start.

```bash
$ kubectl get pods -n probes

NAME                            READY   STATUS                  RESTARTS      AGE
app-tier-7d66ff969d-spzh7       0/1     Init:CrashLoopBackOff   2 (24s ago)   43s
support-tier-66f4cc4f7c-r6b66   2/2     Running                 0             19m 
```

Checking the logs, we see that the container in the App tier is Pod is waiting.

```bash
$ kubectl logs -f app-tier-7d66ff969d-spzh7 -n probes

Defaulted container "server" out of: server, await-redis (init)
Error from server (BadRequest): container "server" in pod "app-tier-7d66ff969d-spzh7" is waiting to start: PodInitializing 
```

Let's now apply the manifest for the Data tier and immediately check the deployment for App tier.

```bash
kubectl apply -f deployment-data.yml; kubectl get deployments -n probes app-tier -w 
```

We'll see that the app server is now able to start successfully.

```bash
service/data-tier created
deployment.apps/data-tier created
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
app-tier   0/1     1            0           16s
app-tier   1/1     1            1           31s 
```

Checking the pods again:

```bash
$ kubectl get pods -n probes

NAME                            READY   STATUS    RESTARTS   AGE
app-tier-7d66ff969d-ckjzj       1/1     Running   0          75s
data-tier-6c8f55b94f-6g28w      1/1     Running   0          60s
support-tier-66f4cc4f7c-zh289   2/2     Running   0          3m46s 
```

We could see see the actual events that took place in the Pod.

```bash
$ kubectl describe pod app-tier-7d66ff969d-ckjzj -n probes | grep -I Events -A 10

Events:
  Type     Reason     Age                    From               Message
  ----     ------     ----                   ----               -------
  Normal   Scheduled  2m36s                  default-scheduler  Successfully assigned probes/app-tier-7d66ff969d-ckjzj to ip-192-168-0-18.ap-southeast-1.compute.internal
  Warning  BackOff    2m32s (x2 over 2m33s)  kubelet            Back-off restarting failed container
  Normal   Pulled     2m17s (x3 over 2m35s)  kubelet            Container image "lrakai/microservices:server-v1" already present on machine
  Normal   Created    2m17s (x3 over 2m35s)  kubelet            Created container await-redis
  Normal   Started    2m17s (x3 over 2m35s)  kubelet            Started container await-redis
  Normal   Pulled     2m16s                  kubelet            Container image "lrakai/microservices:server-v1" already present on machine
  Normal   Created    2m16s                  kubelet            Created container server
  Normal   Started    2m16s                  kubelet            Started container server 
```

## Cleanup 

Make sure to delete the cluster after the lab to save costs.

```bash
$ time eksctl delete cluster -f eksops.yml 
```

When you delete your cluster, make sure to also double check the AWS Console and ensure that the Cloudformation stacks (which we created by eksctl) are dropped cleanly.
