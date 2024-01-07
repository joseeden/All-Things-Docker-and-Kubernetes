
# Jobs and CronJobs 


- [Jobs vs. CronJobs](#jobs-vs-cronjobs)
- [Sample Lab: One-off Job](#sample-lab-one-off-job)
- [Sample Lab: Pod that always fail](#sample-lab-pod-that-always-fail)
- [Sample Lab: CronJob that runs every minute](#sample-lab-cronjob-that-runs-every-minute)
- [Resource](#resource)



While Deployments are used for long-running Pods like web servers, we can take advantage of Jobs and CronJobs for Pods that perform batch work operations.

## Jobs vs. CronJobs

**Jobs** allow you to set a specific number of Pods that must run to completion. If a Pod fails, the Job will start a new Pod until the desired number of Pods reaching completion is met. 

Jobs can run multiple Pods in parallel. When the desired number of Pods successfully complete, the Job is complete. The Pods the Job creates are not automatically deleted allowing you to view their logs and statuses. Jobs can be delete using kubectl.

CronJobs run Jobs based on a declared schedule, similar to the Unix cron tool.

To learn more about Jobs:

```bash
kubectl explain job.spec  
```

## Sample Lab: One-off Job

Below is an example manifest called **jobs.yml** that creates a namespace called **jobs** and then create a Job called **one-off** in that namespace. Notice that each resource definitions are separated by a "---".

```bash
apiVersion: v1
kind: Namespace
metadata:
  name: jobs 
---
apiVersion: batch/v1
kind: Job
metadata:
  name: one-off
  namespace: jobs
  labels:
    job-name: one-off
spec:
  backoffLimit: 6
  completions: 1
  parallelism: 1
  template:
    metadata:
      labels:
        job-name: one-off
    spec:
      restartPolicy: Never
      containers:
      - name: one-off
        image: alpine
        imagePullPolicy: Always
        command:
        - sleep
        - "30"
```



There are some important properties that we defined in the Job manifest:

- **backoffLimit**: Number of times a Job will retry before marking a Job as failed

- **completions**: Number of Pod completions the Job needs before being considered a success

- **parallelism**: Number of Pods the Job is allowed to run in parallel

- **spec.template.spec.restartPolicy**: Job Pods default to never attempting to restart. Instead, the Job is responsible for managing the restart of failed Pods.

Also, note the Job uses a selector to track its Pods.

To create the job: 

```bash 
kubectl apply -f jobs.yaml
```

Wait until the **Completion** changes to "1/1".

```bash
$ watch kubectl get jobs

NAME      COMPLETIONS   DURATION   AGE
one-off   1/1           36s        2m48s
```

We can also see the status in the **Events** when we try to **describe** the job.

```bash
$ kubectl describe job | grep Events -A 10

Events:
  Type    Reason            Age    From            Message
  ----    ------            ----   ----            -------
  Normal  SuccessfulCreate  5m39s  job-controller  Created pod: one-off-vqj8s
  Normal  Completed         5m3s   job-controller  Job completed
```

We can also create the same job through the command line.

```bash
kubectl create job one-off --image=alpine -- sleep 30 
```


## Sample Lab: Pod that always fail

Let's use **pod-fail.yml** to create a Pod that always after sleeping for 20 seconds, caused by the "exit 1" command. Recall that returning a non-zero exit code is treated as a failure.

```bash
apiVersion: batch/v1
kind: Job
metadata:
  name: pod-fail
spec:
  backoffLimit: 3
  completions: 6
  parallelism: 2
  template:
    spec:
      containers:
      - image: alpine
        name: fail
        command: ['sleep 20 && exit 1']
      restartPolicy: Never 
```

Create the job.

```bash
kubectl apply -f pod-fail.yml 
```

Notice that one of the event that occured says "Job has reached the specified backoff limit". The job-controller automatically provisions new Pods as prior Pods fail. Eventually, the Job stops retrying after exceeding the backoff limit.

```bash
$ kubectl describe jobs pod-fail | grep Events -A 10

Events:
  Type     Reason                Age    From            Message
  ----     ------                ----   ----            -------
  Normal   SuccessfulCreate      3m47s  job-controller  Created pod: pod-fail-whrt8
  Normal   SuccessfulCreate      3m47s  job-controller  Created pod: pod-fail-krbq9
  Normal   SuccessfulCreate      3m43s  job-controller  Created pod: pod-fail-sbcqr
  Normal   SuccessfulCreate      3m41s  job-controller  Created pod: pod-fail-66hwk
  Warning  BackoffLimitExceeded  3m37s  job-controller  Job has reached the specified backoff limit 
```

## Sample Lab: CronJob that runs every minute

We'll use **cronjob.yml** to create a CronJob that runs a Job every minute.

```bash
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cronjob-example
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - image: alpine
            name: fail
            command: ['date']
          restartPolicy: Never 
```
```bash
kubectl apply -f cronjob.yml 
```

The jobs we've ran have created Pods, as we can see below. After each minute, a new "cronjob-example-" Pod will appear. The Pods will remain until they are deleteds or the Job associated with them are deleted.

Setting a Job's ttlSecondsAfterFinished can free you from manually cleaning up the Pods.

```bash
$ watch kubectl get pods 

NAME                             READY   STATUS       RESTARTS   AGE
cronjob-example-27873064-kbds2   0/1     Completed    0          86s
cronjob-example-27873065-8jwwl   0/1     Completed    0          26s
one-off-kplgg                    0/1     Completed    0          10m
pod-fail-66hwk                   0/1     StartError   0          7m54s
pod-fail-krbq9                   0/1     StartError   0          8m
pod-fail-sbcqr                   0/1     StartError   0          7m56s
pod-fail-whrt8                   0/1     StartError   0          8m 
```

We can also see the status of the jobs:

```bash
$ watch kubectl get jobs 

NAME                       COMPLETIONS   DURATION   AGE
cronjob-example-27873077   1/1           4s         65s
cronjob-example-27873078   1/1           4s         5s
one-off                    1/1           37s        3m46s
pod-fail                   0/6           2m54s      2m54s
```

## Resource

- [Kubernetes Pod Design for Application Developers: Jobs and CronJobs](https://cloudacademy.com/lab/kubernetes-pod-design-application-developers-jobs-and-cronjobs/?context_id=888&context_resource=lp)



<br>

[Back to first page](../../README.md#kubernetes)
