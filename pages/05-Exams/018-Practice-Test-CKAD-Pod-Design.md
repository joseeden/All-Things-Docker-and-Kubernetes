
# Practice Test: CKAD

> *Some of the scenario questions here are based on [Kodekloud's CKAD course labs](https://kodekloud.com/courses/labs-certified-kubernetes-application-developer/?utm_source=udemy&utm_medium=labs&utm_campaign=kubernetes).*

- [Configuration](016-Practice-Test-CKAD-Configuration.md) 

- [Multi-Container PODs](017-Practice-Test-CKAD-Multi-Container-Pods.md)

- [POD Design](018-Practice-Test-CKAD-Pod-Design.md)

- [Services & Networking](019-Practice-Test-CKAD-Services-Networking,md)

- [State Persistence](020-Practice-Test-CKAD-State-Persistence.md)

- [Additional Updates](021-Practice-Test-CKAD-Additional-Updates.md)

- [Mock Exams](022-Practice-Test-CKAD-Mock-Exams.md) 


## Pod Design 

**Note**

CKAD and CKA can have similar scenario questions. 
It is recommended to go through the [CKA practice tests.](./002-Practice-Test-CKA.md)

**Shortcuts**

First run the two commands below for shortcuts.

```bash
export do="--dry-run=client -o yaml" 
export now="--force --grace-period=0" 
```

**Questions** 


1. Upgrade the application by setting the image on the deployment to kodekloud/webapp-color:v2. Do not delete and re-create the deployment. Only set the new image name for the existing deployment.

    ```bash
    controlplane ~ ✦ ➜  k get deployments.apps 
    NAME       READY   UP-TO-DATE   AVAILABLE   AGE
    frontend   4/4     4            4           6m46s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ✦ ✖ k set image deploy frontend simple-webapp=kodekloud/webapp-color:v2
    deployment.apps/frontend image updated
    ```
    ```bash
    controlplane ~ ➜  k get deployments.apps 
    NAME       READY   UP-TO-DATE   AVAILABLE   AGE
    frontend   5/4     4            3           5m18s 
    ```
    
    </details>
    </br>


2. Change the deployment strategy to Recreate.

    ```bash
    controlplane ~ ✦ ➜  k get deployments.apps 
    NAME       READY   UP-TO-DATE   AVAILABLE   AGE
    frontend   4/4     4            4           6m46s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ✦2 ➜  k get deployments.apps 
    NAME       READY   UP-TO-DATE   AVAILABLE   AGE
    frontend   4/4     4            4           8m14s

    controlplane ~ ✦2 ➜  k get deployments.apps frontend -o yaml > frontend.yml

    controlplane ~ ✦2 ➜  k delete -f frontend.yml 
    deployment.apps "frontend" deleted

    controlplane ~ ✦2 ➜  k get deployments.apps 
    No resources found in default namespace. 
    ```
    ```yaml
    ## frontend.yml
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: frontend
      namespace: default
    spec:
      replicas: 4
      selector:
        matchLabels:
          name: webapp
      strategy:
        type: Recreate
      template:
        metadata:
          labels:
            name: webapp
        spec:
          containers:
          - image: kodekloud/webapp-color:v2
            name: simple-webapp
            ports:
            - containerPort: 8080
              protocol: TCP
    ```
    
    ```bash
    controlplane ~ ✦2 ➜  k apply -f frontend.yml 
    deployment.apps/frontend created

    controlplane ~ ✦2 ➜  k get deployments.apps 
    NAME       READY   UP-TO-DATE   AVAILABLE   AGE
    frontend   4/4     4            4           6s
    ```
    
    </details>
    </br>



3. A pod definition file named throw-dice-pod.yaml is given. The image throw-dice randomly returns a value between 1 and 6. 6 is considered success and all others are failure. Try deploying the POD and view the POD logs for the generated number. File is located at /root/throw-dice-pod.yaml

    ```bash
    controlplane ~ ➜  cat throw-dice-pod.yaml 
    apiVersion: v1
    kind: Pod
    metadata:
      name: throw-dice-pod
    spec:
      containers:
      - image: kodekloud/throw-dice
        name: throw-dice
    restartPolicy: Never 
    ```

    Next, create a Job using this POD definition file or from the imperative command and look at how many attempts does it take to get a '6'.

    - Job Name: throw-dice-job

    - Image Name: kodekloud/throw-dice

    Then update the job definition to run as many times as required to get 3 successful 6's

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k apply  -f throw-dice-pod.yaml 
    pod/throw-dice-pod created

    controlplane ~ ➜  k get po
    NAME             READY   STATUS              RESTARTS   AGE
    throw-dice-pod   0/1     ContainerCreating   0          3s

    controlplane ~ ➜  k get po
    NAME             READY   STATUS   RESTARTS   AGE
    throw-dice-pod   0/1     Error    0          4s

    controlplane ~ ➜  k logs throw-dice-pod 
    5
    ```

    Create the job. 

    ```bash
    controlplane ~ ➜  k create job throw-dice-job --image kodekloud/throw-dice $do
    apiVersion: batch/v1
    kind: Job
      metadata:
      creationTimestamp: null
      name: throw-dice-job
    spec:
      template:
        metadata:
          creationTimestamp: null
        spec:
          containers:
          - image: kodekloud/throw-dice
            name: throw-dice-job
            resources: {}
        restartPolicy: Never
    status: {}

    controlplane ~ ➜  k create job throw-dice-job --image kodekloud/throw-dice $do > job.yml
    ```
    
    ```bash
    ## job.yml
    apiVersion: batch/v1
    kind: Job
    metadata:
      creationTimestamp: null
      name: throw-dice-job
    spec:
      backoffLimit: 15
      template:
        metadata:
        creationTimestamp: null
        spec:
        containers:
        - image: kodekloud/throw-dice
            name: throw-dice-job
            resources: {}
        restartPolicy: Never
    status: {} 
    ```
    ```bash
    controlplane ~ ➜  k apply -f job.yml 
    job.batch/throw-dice-job created

    controlplane ~ ➜  k get job
    NAME             COMPLETIONS   DURATION   AGE
    throw-dice-job   0/1           4s         4s
    ```

    Update the job definition to run as many times as required to get 3 successful 6's

    ```yaml
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: throw-dice-job
    spec:
      completions: 3
      backoffLimit: 25 # This is so the job does not quit before it succeeds.
      template:
        spec:
          containers:
          - name: throw-dice
            image: kodekloud/throw-dice
        restartPolicy: Never
    ```
        
    </details>
    </br>


4. Using the same YAML file from the previous question, speed it up by running upto 3 jobs in parallel.

    ```bash
    controlplane ~ ✦2 ➜  k get job
    NAME             COMPLETIONS   DURATION   AGE
    throw-dice-job   3/3           15s        40s 
    ```
        
    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ✦2 ➜  k delete job throw-dice-job 
    job.batch "throw-dice-job" deleted

    controlplane ~ ✦2 ➜  k get job
    No resources found in default namespace. 
    ```
    ```yaml
    ## job.yml
    apiVersion: batch/v1
    kind: Job
    metadata:
    name: throw-dice-job
    spec:
    parallelism: 3
    completions: 3
    backoffLimit: 25 # This is so the job does not quit before it succeeds.
    template:
        spec:
        containers:
        - name: throw-dice
            image: kodekloud/throw-dice
        restartPolicy: Never
    ```
    ```bash
    controlplane ~ ✦2 ➜  k apply -f job.yml 
    job.batch/throw-dice-job created 
    ```
    
    </details>
    </br>

5. Using the same YAML file from the previous question, schedule that job to run at 21:30 hours every day.

    <details><summary> Answer </summary>
        
    ```yaml 
    ## cronjob.yml
    apiVersion: batch/v1
    kind: CronJob
    metadata:
    name: throw-dice-cron-job
    spec:
    schedule: "30 21 * * *"
    jobTemplate:
        spec:
        completions: 3
        parallelism: 3
        backoffLimit: 25 # This is so the job does not quit before it succeeds.
        template:
            spec:
            containers:
            - name: throw-dice
                image: kodekloud/throw-dice
            restartPolicy: Never 
    ```
    ```bash
    controlplane ~ ✦5 ➜  k apply -f cronjob.yml
    cronjob.batch/throw-dice-cron-job created

    controlplane ~ ✦5 ➜  k get cronjobs.batch 
    NAME                  SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
    throw-dice-cron-job   30 21 * * *   False     0        <none>          8s
    ```
        
    </details>
    </br>




[Back to the top](#practice-test-ckad)    

