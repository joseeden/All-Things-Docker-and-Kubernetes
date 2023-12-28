# Lab 045: Rollouts and Rollbacks

- [Pre-requisites](#pre-requisites)
- [Introduction](#introduction)
- [Set the Replicas](#set-the-replicas)
- [Trigger a Rollout](#trigger-a-rollout)
- [Rollback](#rollback)
- [Rollout History](#rollout-history)
- [Cleanup](#cleanup)


## Pre-requisites

- [Lab 44: Horizontal Pod AutoScaler](../Lab_044_Horizontal_Pod_AutoScaler/README.md)

## Introduction

In the previous lab, we've learned how to scale out deployments using the Horizontal Pod Autoscaler (HPA). We'll now work on the rollou strategies available to Kubernetes, specifically rollouts and rollbacks.

Kubernetes uses rollouts to updates the deployments, which includes replacing the replicas that matches the specs in the enw deployment template. Other changes could also include environment variables, labels, and code changes. Basically any changes in the deployment template will trigger a rollout.

## Set the Replicas 

Let's start with deleting the current instance of HPA so we can modify it to add more replicas.

```bash
kubectl delete -f horizontal-autoscaler.yml
```

Edit the [deployment-data.yml](manifests/deployment-data.yml) and change set the replicas to 10. Also, we'll need to delete the resource request block so that Kubernetes won't have any issues with scheduling the huge number of replicas.

```bash
apiVersion: v1
kind: Service
metadata:
  name: app-tier
  namespace: autoscaling
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
  namespace: autoscaling
  labels:
    app: microservices
    tier: app
spec:
  replicas: 10
  selector:
    matchLabels:
      tier: app
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
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
            value: redis://$(DATA_TIER_SERVICE_HOST):$(DATA_TIER_SERVICE_PORT_REDIS)
```

Apply the changes.

```bash
kubectl apply -f deployment-app.yml  
```

Watch as the replicas are launched.

```bash
watch -n 1  kubectl get deployment app-tier -n autoscaling
```


## Trigger a Rollout 

Edit the [deployment-app.yml](manifests/deployment-app.yml). Change the **maxSurge** to 100%. This will allow new pods to be created without waiting for old ones to be deleted. Also change the **containerPort** to 8081

```bash
$ vim deployment-app.yml 

........

maxSurge: 100% 

........

containerPort: 8081

```

Apply the changes and quickly check the status.

```bash
kubectl apply -f deployment-app.yml; kubectl rollout status deployment app-tier -n autoscaling 
```

We should be able to see the rollout in real time.

```bash
service/app-tier unchanged
deployment.apps/app-tier configured
Waiting for deployment "app-tier" rollout to finish: 8 old replicas are pending termination...
Waiting for deployment "app-tier" rollout to finish: 8 old replicas are pending termination...
Waiting for deployment "app-tier" rollout to finish: 8 old replicas are pending termination...
Waiting for deployment "app-tier" rollout to finish: 7 old replicas are pending termination...
Waiting for deployment "app-tier" rollout to finish: 7 old replicas are pending termination...
Waiting for deployment "app-tier" rollout to finish: 7 old replicas are pending termination...
Waiting for deployment "app-tier" rollout to finish: 6 old replicas are pending termination...
Waiting for deployment "app-tier" rollout to finish: 6 old replicas are pending termination...
Waiting for deployment "app-tier" rollout to finish: 6 old replicas are pending termination...
Waiting for deployment "app-tier" rollout to finish: 5 old replicas are pending termination...
Waiting for deployment "app-tier" rollout to finish: 5 old replicas are pending termination...
Waiting for deployment "app-tier" rollout to finish: 5 old replicas are pending termination...
Waiting for deployment "app-tier" rollout to finish: 5 old replicas are pending termination...
Waiting for deployment "app-tier" rollout to finish: 4 old replicas are pending termination...
Waiting for deployment "app-tier" rollout to finish: 4 old replicas are pending termination...
Waiting for deployment "app-tier" rollout to finish: 2 old replicas are pending termination...
Waiting for deployment "app-tier" rollout to finish: 2 old replicas are pending termination...
Waiting for deployment "app-tier" rollout to finish: 2 old replicas are pending termination...
Waiting for deployment "app-tier" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "app-tier" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "app-tier" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "app-tier" rollout to finish: 8 of 10 updated replicas are available...
Waiting for deployment "app-tier" rollout to finish: 9 of 10 updated replicas are available...
deployment "app-tier" successfully rolled out 
```

## Rollback

We can also rollback the application to each previous version. But before we do that, let's check the port for our current app-tier deployment.

```bash
$ kubectl describe deployment app-tier -n autoscaling | grep 'Port:'

    Port:       8081/TCP
    Host Port:  0/TCP 
```

Now let's trigger a rollback.

```bash
kubectl rollout undo deployment app-tier -n autoscaling 
```

The port published should now revert back to the original one "8080".

```bash
$ kubectl describe deployment app-tier -n autoscaling | grep "Port:"

    Port:       8080/TCP
    Host Port:  0/TCP 
```

## Rollout History 

We can also check the revisions of our application. We can then grab the specific revision number and rollback to that version.

```bash
$ kubectl rollout history deployment app-tier -n autoscaling

deployment.apps/app-tier
REVISION  CHANGE-CAUSE
4         <none>
5         <none>

```


## Cleanup

Make sure to delete the cluster after the lab to save costs.

```bash
$ time eksctl delete cluster -f eksops.yml 
```

When you delete your cluster, make sure to double check the AWS Console and that the Cloudformation stacks (which we created by eksctl) are dropped cleanly.
