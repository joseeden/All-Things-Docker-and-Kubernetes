# Practice Test: CKA 

> *Some of the scenario questions here are based on Kodekloud's [CKA course labs](https://kodekloud.com/courses/ultimate-certified-kubernetes-administrator-cka-mock-exam/).*

- [Core Concepts](003-Practice-Test-CKA-Core-concepts.md) 
- [Scheduling](004-Practice-Test-CKA-Scheduling.md) 
- [Logging and Monitoring](005-Practice-Test-CKA-Logging-Monitoring.md)
- [Application Lifecycle Management](006-Practice-Test-CKA-App-Lifecycle-Management.md) 
- [Cluster Maintenance](007-Practice-Test-CKA-Cluster-Maintenance.md) 
- [Security](008-Practice-Test-CKA-Security.md) 
- [Storage](009-Practice-Test-CKA-Storage.md) 
- [Networking](010-Practice-Test-CKA-Networking.md)
- [Kubernetes-the-hard-way](011-Practice-Test-CKA-K8S-The-Hard-Way.md)
- [Troubleshooting](012-Practice-Test-CKA-Troubleshooting.md)
- [Other Topics](013-Practice-Test-CKA-Other-Topics.md)
- [Mock Exam](014-Practice-Test-CKA-Mock-Exam.md)


## Application Lifecycle Management

1. Inspect the current deployment and determine the strategy used.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get deployments.apps 
    NAME       READY   UP-TO-DATE   AVAILABLE   AGE
    frontend   4/4     4            4           84s 

    controlplane ~ ➜  k describe deployments.apps frontend | grep -i strategy
    StrategyType:           RollingUpdate
    RollingUpdateStrategy:  25% max unavailable, 25% max surge
    ```
    
    </details>
    </br>



2. Upgrade the application by setting the image on the deployment to kodekloud/webapp-color:v2. Do not delete and re-create the deployment. Only set the new image name for the existing deployment.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k edit deployments.apps frontend 
    deployment.apps/frontend edited 
    ```
    ```bash
    apiVersion: apps/v1
    kind: Deployment
    metadata:
    annotations:
        deployment.kubernetes.io/revision: "1"
    creationTimestamp: "2023-12-29T17:01:17Z"
    generation: 1
    name: frontend
    namespace: default
    resourceVersion: "855"
    uid: 05c0c824-dd8a-4f28-9c88-0f45cfd1702d
    spec:
    minReadySeconds: 20
    progressDeadlineSeconds: 600
    replicas: 4
    revisionHistoryLimit: 10
    selector:
        matchLabels:
        name: webapp
    strategy:
        rollingUpdate:
        maxSurge: 25%
        maxUnavailable: 25%
        type: RollingUpdate
    template:
        metadata:
        creationTimestamp: null
        labels:
            name: webapp
        spec:
        containers:
        - image: kodekloud/webapp-color:v2
    ```
    ```bash
    controlplane ~ ➜  k get deployments.apps 
    NAME       READY   UP-TO-DATE   AVAILABLE   AGE
    frontend   5/4     4            3           5m18s 
    ```
    
    </details>
    </br>



3. Up to how many PODs can be down for upgrade at a time. Consider the current strategy settings and number of PODs - 4

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ✦ ➜  k get deployments.apps 
    NAME       READY   UP-TO-DATE   AVAILABLE   AGE
    frontend   4/4     4            4           6m30s

    controlplane ~ ✦ ➜  k describe deployments.apps frontend | grep -i unavailable
    Replicas:               4 desired | 4 updated | 4 total | 4 available | 0 unavailable
    RollingUpdateStrategy:  25% max unavailable, 25% max surge
    ```
    
    </details>
    </br>



4. Change the deployment strategy to Recreate. Delete and re-create the deployment if necessary. Only update the strategy type for the existing deployment.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ✦ ➜  k get deployments.apps 
    NAME       READY   UP-TO-DATE   AVAILABLE   AGE
    frontend   4/4     4            4           6m30s

    controlplane ~ ✦ ➜  k describe deployments.apps frontend | grep -i unavailable
    Replicas:               4 desired | 4 updated | 4 total | 4 available | 0 unavailable
    RollingUpdateStrategy:  25% max unavailable, 25% max surge 
    ```

    ```bash
    controlplane ~ ✦ ➜  k edit deployments.apps frontend   
    ``` 

    ```bash
    apiVersion: apps/v1
    kind: Deployment
    metadata:
    annotations:
        deployment.kubernetes.io/revision: "2"
    creationTimestamp: "2023-12-29T17:01:17Z"
    generation: 2
    name: frontend
    namespace: default
    resourceVersion: "1060"
    uid: 05c0c824-dd8a-4f28-9c88-0f45cfd1702d
    spec:
    minReadySeconds: 20
    progressDeadlineSeconds: 600
    replicas: 4
    revisionHistoryLimit: 10
    selector:
        matchLabels:
        name: webapp
    strategy:
        type: Recreate  
    ``` 

    ```bash
    controlplane ~ ✦ ➜  k get deployments.apps 
    NAME       READY   UP-TO-DATE   AVAILABLE   AGE
    frontend   4/4     4            4           10m  
    ``` 

    </details>
    </br>



5. In the current pod, what is the command used to run the pod ubuntu-sleeper?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po
    NAME             READY   STATUS    RESTARTS   AGE
    ubuntu-sleeper   1/1     Running   0          22s

    controlplane ~ ➜  k get po ubuntu-sleeper -o yaml | grep -i command -A 5
    - command:
        - sleep
        - "4800"
        image: ubuntu
        imagePullPolicy: Always
        name: ubuntu 
    ```
    
    </details>
    </br>



6. Create a pod with the ubuntu image to run a container to sleep for 5000 seconds.

    <details><summary> Answer </summary>
    
    ```bash
    apiVersion: v1
    kind: Pod 
    metadata:
    name: ubuntu-sleeper-2
    spec:
    containers:
    - name: ubuntu
        image: ubuntu
        command: 
        - "sleep"
        - "5000"
    ```
    
    ```bash
    controlplane ~ ➜  k apply -f ubuntu-sleeper-2.yaml 
    pod/ubuntu-sleeper-2 created

    controlplane ~ ➜  k get po
    NAME               READY   STATUS    RESTARTS   AGE
    ubuntu-sleeper     1/1     Running   0          4m5s
    ubuntu-sleeper-2   1/1     Running   0          4s 
    ```
    
    </details>
    </br>



7. Create a pod using the file named ubuntu-sleeper-3.yaml. There is something wrong with it. Try to fix it

    ```yaml
    apiVersion: v1 
    kind: Pod 
    metadata:
      name: ubuntu-sleeper-3 
    spec:
      containers:
      - name: ubuntu
        image: ubuntu
        command:
        - "sleep"
        - 1200  
    ```

    <details><summary> Answer </summary>

    Commands should be enclosed in quotes. 

    ```bash
    apiVersion: v1
    kind: Pod 
    metadata:
    name: ubuntu-sleeper-3
    spec:
    containers:
    - name: ubuntu
        image: ubuntu
        command:
        - "sleep"
        - "1200"
    ```
    ```bash
    controlplane ~ ✦2 ➜  k apply -f ubuntu-sleeper-3.yaml 
    pod/ubuntu-sleeper-3 created

    controlplane ~ ✦2 ➜  k get po
    NAME               READY   STATUS    RESTARTS   AGE
    ubuntu-sleeper     1/1     Running   0          11m
    ubuntu-sleeper-2   1/1     Running   0          3m19s
    ubuntu-sleeper-3   1/1     Running   0          25s 
    ```

    </details>
    </br>



8. Create a pod with the given specifications. By default it displays a blue background. Set the given command line arguments to change it to green.

    - Pod Name: webapp-green
    - Image: kodekloud/webapp-color
    - Command line arguments: --color=green

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  export do="--dry-run=client -o yaml"

    controlplane ~ ➜  export now="--force --grace-period 0" 

    controlplane ~ ✦2 ➜  k run webapp-green --image  kodekloud/webapp-color $do -o yaml > green.yml
    ```
    ```bash
    apiVersion: v1
    kind: Pod
    metadata:
    creationTimestamp: null
    labels:
        run: webapp-green
    name: webapp-green
    spec:
    containers:
    - image: kodekloud/webapp-color
        name: webapp-green
        resources: {}
        args:
        - "--color"
        - "green"
    dnsPolicy: ClusterFirst
    restartPolicy: Always
    status: {}
    ~              
    ```
    ```bash
    controlplane ~ ✦2 ➜  k apply -f green.yml 
    pod/webapp-green created

    controlplane ~ ✦2 ➜  k get po
    NAME               READY   STATUS    RESTARTS   AGE
    ubuntu-sleeper     1/1     Running   0          21m
    ubuntu-sleeper-2   1/1     Running   0          13m
    ubuntu-sleeper-3   1/1     Running   0          8m50s
    webapp-green       1/1     Running   0          3s
    ```
    
    
    </details>
    </br>



9. What is the environment variable name set on the container in the pod?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po
    NAME           READY   STATUS    RESTARTS   AGE
    webapp-color   1/1     Running   0          19s

    controlplane ~ ➜  k describe po webapp-color | grep -i env -A 5
        Environment:
        APP_COLOR:  pink 
    ```
    
    </details>
    </br>



9. Identify the database host from the config map db-config.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ✦ ➜  k get cm 
    NAME               DATA   AGE
    kube-root-ca.crt   1      13m
    db-config          3      9s

    controlplane ~ ✦ ➜  k describe cm db-config 
    Name:         db-config
    Namespace:    default
    Labels:       <none>
    Annotations:  <none>

    Data
    ====
    DB_HOST:
    ----
    SQL01.example.com
    DB_NAME:
    ----
    SQL01
    DB_PORT:
    ----
    3306

    BinaryData
    ====

    Events:  <none> 
    ```
    
    </details>
    </br>



10. Create a new ConfigMap for the webapp-color POD. Use the spec given below.

    - ConfigMap Name: webapp-config-map

    - Data: APP_COLOR=darkblue

    - Data: APP_OTHER=disregard

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  export do="--dry-run=client -o yaml"

    controlplane ~ ➜  export now="--force --grace-period 0" 

    controlplane ~ ✦ ➜  k create cm webapp-config-map $do > webapp-color.yml
    ```
    ```bash
    apiVersion: v1
    kind: ConfigMap
    metadata:
    creationTimestamp: null
    name: webapp-config-map
    data:
    APP_COLOR: "darkblue"
    APP_OTHER: "disregard"
    ~                         
    ```
    ```bash
    controlplane ~ ✦ ➜  k apply -f webapp-color.yml 
    configmap/webapp-config-map created

    controlplane ~ ✦ ➜  k get cm
    NAME                DATA   AGE
    kube-root-ca.crt    1      17m
    db-config           3      4m56s
    webapp-config-map   2      3s

    controlplane ~ ✦ ➜  k describe cm webapp-config-map 
    Name:         webapp-config-map
    Namespace:    default
    Labels:       <none>
    Annotations:  <none>

    Data
    ====
    APP_OTHER:
    ----
    disregard
    APP_COLOR:
    ----
    darkblue

    BinaryData
    ====

    Events:  <none> 
    ```
    
    </details>
    </br>



11. Update the environment variable on the POD to use only the APP_COLOR key from the newly created ConfigMap.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  export do="--dry-run=client -o yaml"

    controlplane ~ ➜  export now="--force --grace-period 0" 
    ```
    
    ```bash
    controlplane ~ ✦ ➜  k get po
    NAME           READY   STATUS    RESTARTS   AGE
    webapp-color   1/1     Running   0          8m

    controlplane ~ ✦ ➜  k get cm
    NAME                DATA   AGE
    kube-root-ca.crt    1      20m
    db-config           3      7m53s
    webapp-config-map   2      3m 

    controlplane ~ ✦ ➜  k create cm webapp-config-map $do > webapp-color.yml

    controlplane ~ ✦ ➜  k get po webapp-color -o yaml > color.yml

    controlplane ~ ✦ ➜  k delete -f color.yml $now
    Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
    pod "webapp-color" force deleted

    controlplane ~ ✦ ➜  k get po
    No resources found in default namespace.
    ```

    Follow the K8s docs on how to configure pods to use configmaps.
    
    ```bash
    apiVersion: v1
    kind: Pod
    metadata:
    creationTimestamp: "2023-12-29T17:36:54Z"
    labels:
        name: webapp-color
    name: webapp-color
    namespace: default
    resourceVersion: "781"
    uid: 1e5515fa-9479-4ddd-a463-1df7723c1f8c
    spec:
    containers:
    - env:
        - name: APP_COLOR
        valueFrom:
            configMapKeyRef:
            name: webapp-config-map
            key: APP_COLOR
    ```
    
    ```bash
    controlplane ~ ✦ ➜  k apply -f color.yml 
    pod/webapp-color created

    controlplane ~ ✦ ➜  k get po
    NAME           READY   STATUS    RESTARTS   AGE
    webapp-color   1/1     Running   0          5s 
    ```
    
    </details>
    </br>


12. 


<details><summary> Answer </summary>
 
```bash
 
```
 

<details><summary> Answer </summary>
 
```bash
 
```
 

<details><summary> Answer </summary>
 
```bash
 
```
 

<details><summary> Answer </summary>
 
```bash
 
```
 

<details><summary> Answer </summary>
 
```bash
 
```
 

<details><summary> Answer </summary>
 
```bash
 
```
 

<details><summary> Answer </summary>
 
```bash
 
```
 

<details><summary> Answer </summary>
 
```bash
 
```
 

<details><summary> Answer </summary>
 
```bash
 
```
 

<details><summary> Answer </summary>
 
```bash
 
```
 




</details>
</br>



[Back to the top](#practice-test-cka)    
