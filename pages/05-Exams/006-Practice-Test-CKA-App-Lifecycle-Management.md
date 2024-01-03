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


## Application Lifecycle Management

1. Inspect the current deployment and determine the strategy used.

    ```bash
    controlplane ~ ➜  k get deployments.apps 
    NAME       READY   UP-TO-DATE   AVAILABLE   AGE
    frontend   4/4     4            4           84s  
    ```

    <details><summary> Answer </summary>
    
    ```bash
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

    ```bash
    controlplane ~ ✦ ➜  k get deployments.apps 
    NAME       READY   UP-TO-DATE   AVAILABLE   AGE
    frontend   4/4     4            4           6m30s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ✦ ➜  k describe deployments.apps frontend | grep -i unavailable
    Replicas:               4 desired | 4 updated | 4 total | 4 available | 0 unavailable
    RollingUpdateStrategy:  25% max unavailable, 25% max surge
    ```
    
    </details>
    </br>



4. Change the deployment strategy to Recreate. Delete and re-create the deployment if necessary. Only update the strategy type for the existing deployment.

    ```bash
    controlplane ~ ✦ ➜  k get deployments.apps 
    NAME       READY   UP-TO-DATE   AVAILABLE   AGE
    frontend   4/4     4            4           6m30s 
    ```

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

    ```bash
    controlplane ~ ➜  k get po
    NAME             READY   STATUS    RESTARTS   AGE
    ubuntu-sleeper   1/1     Running   0          22s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
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
    ## ubuntu-sleeper-2.yaml 
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
    ## ubuntu-sleeper-3.yaml
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
    ## ubuntu-sleeper-3.yaml
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
    ## green.yml
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

    ```bash
    controlplane ~ ➜  k get po
    NAME           READY   STATUS    RESTARTS   AGE
    webapp-color   1/1     Running   0          19s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k describe po webapp-color | grep -i env -A 5
        Environment:
        APP_COLOR:  pink 
    ```
    
    </details>
    </br>



9. Identify the database host from the config map db-config.

    ```bash
    controlplane ~ ✦ ➜  k get cm 
    NAME               DATA   AGE
    kube-root-ca.crt   1      13m
    db-config          3      9s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
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
    ## webapp-color.yml
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

    ```bash
    controlplane ~ ✦ ➜  k get po
    NAME           READY   STATUS    RESTARTS   AGE
    webapp-color   1/1     Running   0          8m 
    ```


    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  export do="--dry-run=client -o yaml"

    controlplane ~ ➜  export now="--force --grace-period 0" 
    ```
    
    ```bash
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
    ## color.yml 
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


12. How many secrets are defined in the dashboard-token secret?

    ```bash
    controlplane ~ ➜  k get secrets 
    NAME              TYPE                                  DATA   AGE
    dashboard-token   kubernetes.io/service-account-token   3      40s
    ```


    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k describe secrets dashboard-token 
    Name:         dashboard-token
    Namespace:    default
    Labels:       <none>
    Annotations:  kubernetes.io/service-account.name: dashboard-sa
                kubernetes.io/service-account.uid: dec16229-5c52-414f-928d-28380a3fb4b3

    Type:  kubernetes.io/service-account-token

    Data
    ====
    ca.crt:     570 bytes
    namespace:  7 bytes
    token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IjlEc25IMUFwZ1pfZlRVcmVla3pvbS0yTXlsa1ZzT1RyZktaWmJCR1dYVHcifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNl 
    ```
    
    </details>
    </br>


13. Create a new secret named db-secret with the data given below.

    - Secret Name: db-secret

    - Secret 1: DB_Host=sql01

    - Secret 2: DB_User=root

    - Secret 3: DB_Password=password123

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  export do="--dry-run=client -o yaml"

    controlplane ~ ➜  export now="--force --grace-period 0"
    
    ```
    ```bash
    controlplane ~ ➜  kubectl create secret generic db-secret \
        --from-literal='DB_Host=sql01' \
        --from-literal='DB_User=root' \
        --from-literal='DB_Password=password123' 

    secret/db-secret created
    ```
    ```bash
    controlplane ~ ➜  k get secret
    NAME              TYPE                                  DATA   AGE
    dashboard-token   kubernetes.io/service-account-token   3      8m18s
    db-secret         Opaque                                3      23s

    controlplane ~ ➜  k describe secrets db-secret 
    Name:         db-secret
    Namespace:    default
    Labels:       <none>
    Annotations:  <none>

    Type:  Opaque

    Data
    ====
    DB_Host:      5 bytes
    DB_Password:  11 bytes
    DB_User:      4 bytes 
    ```
    
    </details>
    </br>



14. Configure webapp-pod to load environment variables from the newly created secret (from the previous question).

    - Pod name: webapp-pod

    - Image name: kodekloud/simple-webapp-mysql

    - Env From: Secret=db-secret

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  export do="--dry-run=client -o yaml"

    controlplane ~ ➜  export now="--force --grace-period 0"

    controlplane ~ ➜  k get po
    NAME         READY   STATUS    RESTARTS   AGE
    webapp-pod   1/1     Running   0          6m55s
    mysql        1/1     Running   0          6m55s

    controlplane ~ ➜  k get po webapp-pod -o yaml > webapp-pod.yml

    controlplane ~ ✦2 ➜  k delete -f webapp-pod.yml $now
    Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
    pod "webapp-pod" force deleted

    controlplane ~ ✦2 ➜  k get po
    NAME    READY   STATUS    RESTARTS   AGE
    mysql   1/1     Running   0          8m1s
    ```

    Follow steps on how to configure all key-value pairs in a Secret as container environment variables from K8S docs. 

    ```bash
    ## webapp-pod.yml
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: "2023-12-29T17:57:07Z"
      labels:
        name: webapp-pod
    name: webapp-pod
    namespace: default
    resourceVersion: "802"
    uid: b134a439-e86d-45d2-af52-717d17717da1
    spec:
      containers:
      - image: kodekloud/simple-webapp-mysql
        imagePullPolicy: Always
        name: webapp
        envFrom:
        - secretRef:
            name: db-secret 
    ```
    
    ```bash
    controlplane ~ ✦2 ➜  k apply -f webapp-pod.yml 
    pod/webapp-pod created

    controlplane ~ ✦2 ➜  k get po
    NAME         READY   STATUS    RESTARTS   AGE
    mysql        1/1     Running   0          13m
    webapp-pod   1/1     Running   0          2s 
    ```
    
    </details>
    </br>



15. Identify the name of the containers running in the blue pod.

    ```bash
    controlplane ~ ➜  k get po
    NAME        READY   STATUS              RESTARTS   AGE
    app         1/1     Running             0          36s
    blue        0/2     ContainerCreating   0          7s
    fluent-ui   1/1     Running             0          37s
    red         0/3     ContainerCreating   0          23s 
    ```


    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k describe po blue
    Name:             blue
    Namespace:        default
    Priority:         0
    Service Account:  default
    Node:             controlplane/192.36.217.6
    Start Time:       Fri, 29 Dec 2023 13:12:32 -0500
    Labels:           <none>
    Annotations:      <none>
    Status:           Pending
    IP:               
    IPs:              <none>
    Containers:
    teal:
        Container ID:  
        Image:         busybox
        Image ID:      
        Port:          <none>
        Host Port:     <none>
        Command:
        sleep
        4500
        State:          Waiting
        Reason:       ContainerCreating
        Ready:          False
        Restart Count:  0
        Environment:    <none>
        Mounts:
        /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-vrvfc (ro)
    navy:
        Container ID:  
        Image:         busybox
        Image ID:      
        Port:          <none>
        Host Port:     <none>
        Command:
        sleep
        4500
        State:          Waiting
        Reason:       ContainerCreating
        Ready:          False
        Restart Count:  0
        Environment:    <none>
        Mounts:
        /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-vrvfc (ro) 
    ```
    
    </details>
    </br>



16. Create a multi-container pod with 2 containers. If the pod goes into the crashloopbackoff then add the command sleep 1000 in the lemon container. Use the spec given below:

    - Name: yellow

    - Container 1 Name: lemon

    - Container 1 Image: busybox

    - Container 2 Name: gold

    - Container 2 Image: redis


    <details><summary> Answer </summary>
    
    ```bash
    ontrolplane ~ ➜  k run yellow --image busybox $do
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: null
      labels:
        run: yellow
    name: yellow
    spec:
      containers:
      - image: busybox
        name: yellow
        resources: {}
    dnsPolicy: ClusterFirst
    restartPolicy: Always
    status: {}

    controlplane ~ ➜  k run yellow --image busybox $do > yellow.yml 
    ```
    ```yaml
    ## yellow.yml
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: null
      labels:
        run: yellow
    name: yellow
    spec:
      containers:
      - image: busybox
        name: lemon
        resources: {}
      - image: redis
        name: gold 
    dnsPolicy: ClusterFirst
    restartPolicy: Always
    status: {}
    ```
    ```bash
    controlplane ~ ➜  k apply -f yellow.yml 
    pod/yellow created 

    controlplane ~ ➜  k get po
    NAME        READY   STATUS             RESTARTS     AGE
    app         1/1     Running            0            8m39s
    blue        2/2     Running            0            7m34s
    fluent-ui   1/1     Running            0            8m39s
    red         3/3     Running            0            8m26s
    yellow      1/2     CrashLoopBackOff   1 (4s ago)   7s
    ```
    ```bash
    ## yellow.yml
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: null
      labels:
        run: yellow
    name: yellow
    spec:
      containers:
      - image: busybox
        name: lemon
        resources: {}
        command:
        - "sleep"
        - "1000"
      - image: redis
        name: gold   
    dnsPolicy: ClusterFirst
    restartPolicy: Always
    status: {}
    ```
    ```bash
    controlplane ~ ➜  k delete -f yellow.yml 
    pod "yellow" deleted

    controlplane ~ ➜  k apply -f yellow.yml 
    pod/yellow created

    controlplane ~ ➜  k get po
    NAME        READY   STATUS    RESTARTS   AGE
    app         1/1     Running   0          9m44s
    blue        2/2     Running   0          8m39s
    fluent-ui   1/1     Running   0          9m44s
    red         3/3     Running   0          9m31s
    yellow      2/2     Running   0          3s 
    ```
    ```bash
    controlplane ~ ➜  k describe po yellow 
    Name:             yellow
    Namespace:        default
    Priority:         0
    Service Account:  default
    Node:             controlplane/192.11.203.9
    Start Time:       Sat, 30 Dec 2023 03:10:46 -0500
    Labels:           run=yellow
    Annotations:      <none>
    Status:           Running
    IP:               10.244.0.13
    IPs:
    IP:  10.244.0.13
    Containers:
    lemon:
        Container ID:  containerd://eba9ba778ac377f05a4061170c3229c0361103ab3dbad6710d28f32a95fc8f77
        Image:         busybox
        Image ID:      docker.io/library/busybox@sha256:ba76950ac9eaa407512c9d859cea48114eeff8a6f12ebaa5d32ce79d4a017dd8
        Port:          <none>
        Host Port:     <none>
        Command:
        sleep
        1000
        State:          Running
        Started:      Sat, 30 Dec 2023 03:10:48 -0500
        Ready:          True
        Restart Count:  0
        Environment:    <none>
        Mounts:
        /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-m8gtm (ro)
    gold:
        Container ID:   containerd://f0ab41cb48bb10d4006833ecb452800b58974d578a869cfac5e6e7dbe2052029
        Image:          redis
        Image ID:       docker.io/library/redis@sha256:a7cee7c8178ff9b5297cb109e6240f5072cdaaafd775ce6b586c3c704b06458e
        Port:           <none>
        Host Port:      <none>
        State:          Running
        Started:      Sat, 30 Dec 2023 03:10:48 -0500
        Ready:          True
        Restart Count:  0
        Environment:    <none>
        Mounts:
        /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-m8gtm (ro)
    ```
    
    </details>
    </br>



17. Inspect the app pod and identify the number of containers in it. It is deployed in the elastic-stack namespace.


    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po -n elastic-stack
    NAME             READY   STATUS    RESTARTS   AGE
    app              1/1     Running   0          13m
    elastic-search   1/1     Running   0          13m
    kibana           1/1     Running   0          13m

    controlplane ~ ➜  k describe po app
    Name:             app
    Namespace:        default
    Priority:         0
    Service Account:  default
    Node:             controlplane/192.11.203.9
    Start Time:       Sat, 30 Dec 2023 03:01:05 -0500
    Labels:           name=app
    Annotations:      <none>
    Status:           Running
    IP:               10.244.0.8
    IPs:
    IP:  10.244.0.8
    Containers:
    app:
        Container ID:   containerd://80c1ffb344a3f209d2014335e046bf7eef23c4d319274f047c7b8972ff578694
        Image:          kodekloud/event-simulator
        Image ID:       docker.io/kodekloud/event-simulator@sha256:1e3e9c72136bbc76c96dd98f29c04f298c3ae241c7d44e2bf70bcc209b030bf9
        Port:           <none>
        Host Port:      <none>
        State:          Running
        Started:      Sat, 30 Dec 2023 03:02:20 -0500
        Ready:          True
        Restart Count:  0
        Environment:    <none>
        Mounts:
        /log from log-volume (rw)
        /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-s4djx (ro) 
    ```
    
    </details>
    </br>



18. The application in the elastic-stack namespace outputs logs to the file /log/app.log. View the logs and try to identify the user having issues with Login.

    ```bash
    controlplane ~ ➜  k get po -n elastic-stack
    NAMESPACE       NAME                                   READY   STATUS    RESTARTS   AGE
    elastic-stack   app                                    1/1     Running   0          18m
    elastic-stack   elastic-search                         1/1     Running   0          18m
    elastic-stack   kibana                                 1/1     Running   0          18m
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k -n elastic-stack exec -it app -- tail -10 /log/app.log
    [2023-12-30 08:18:12,459] INFO in event-simulator: USER3 is viewing page3
    [2023-12-30 08:18:12,725] WARNING in event-simulator: USER5 Failed to Login as the account is locked due to MANY FAILED ATTEMPTS.
    [2023-12-30 08:18:12,725] INFO in event-simulator: USER4 is viewing page2
    [2023-12-30 08:18:13,460] INFO in event-simulator: USER3 is viewing page3
    [2023-12-30 08:18:13,726] INFO in event-simulator: USER3 logged in
    [2023-12-30 08:18:14,461] WARNING in event-simulator: USER7 Order failed as the item is OUT OF STOCK.
    [2023-12-30 08:18:14,461] INFO in event-simulator: USER1 logged in
    [2023-12-30 08:18:14,727] INFO in event-simulator: USER4 logged in
    [2023-12-30 08:18:15,462] INFO in event-simulator: USER1 logged in
    [2023-12-30 08:18:15,729] INFO in event-simulator: USER3 logged in 
    ```
    
    </details>
    </br>



19. Edit the pod to add a sidecar container to send logs to Elastic Search. Mount the log volume to the sidecar container. Only add a new container. Do not modify anything else. Use the spec provided below.

    - Name: app

    - Container Name: sidecar

    - Container Image: kodekloud/filebeat-configured

    - Volume Mount: log-volume

    - Mount Path: /var/log/event-simulator/

    - Existing Container Name: app

    - Existing Container Image: kodekloud/event-simulator

    ```bash
    controlplane ~ ➜  k get po -n elastic-stack
    NAMESPACE       NAME                                   READY   STATUS    RESTARTS   AGE
    elastic-stack   app                                    1/1     Running   0          18m
    elastic-stack   elastic-search                         1/1     Running   0          18m
    elastic-stack   kibana                                 1/1     Running   0          18m
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  export do="--dry-run=client -o yaml"

    controlplane ~ ➜  export now="--force --grace-period 0"

    controlplane ~ ➜  k get po app -n elastic-stack -o yaml > elastic-app.yml 
    ```

    Add a sidecar container to the YAML file. Follow K8S docs for steps.
    ```yaml
    ## elastic-app.yml
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: "2023-12-30T08:01:04Z"
      labels:
        name: app
    name: app
    namespace: elastic-stack
    resourceVersion: "1071"
    uid: ee0727bd-ef91-4817-b717-1582c890cae7
    spec:
      containers:
      - image: kodekloud/event-simulator
        imagePullPolicy: Always
        name: app
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /log
          name: log-volume
        - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
          name: kube-api-access-78bvz
          readOnly: true
      - name: sidecar
        image: kodekloud/filebeat-configured
        volumeMounts:
        - name: log-volume
          mountPath: /var/log/event-simulator/  
    ```
    
    ```bash
    controlplane ~ ✦ ✖ k delete -f elastic-app.yml  $now
    Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
    pod "app" force deleted 

    controlplane ~ ✦ ✖ vi elastic-app.yml 

    controlplane ~ ✦ ➜  k apply -f elastic-app.yml 
    pod/app created

    controlplane ~ ✦ ➜  k get po -n elastic-stack 
    NAME             READY   STATUS    RESTARTS   AGE
    app              2/2     Running   0          21s
    elastic-search   1/1     Running   0          43m
    kibana           1/1     Running   0          43m
    ```
    
    </details>
    </br>



20. What is the image used by the initContainer in the blue pod? What is its state?

    ```bash
    controlplane ~ ➜  k get po
    NAME    READY   STATUS    RESTARTS   AGE
    red     1/1     Running   0          32s
    green   2/2     Running   0          32s
    blue    1/1     Running   0          32s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k describe po blue
    Name:             blue
    Namespace:        default
    Priority:         0
    Service Account:  default
    Node:             controlplane/192.12.137.9
    Start Time:       Sat, 30 Dec 2023 08:47:05 +0000
    Labels:           <none>
    Annotations:      <none>
    Status:           Running
    IP:               10.42.0.10
    IPs:
    IP:  10.42.0.10
    Init Containers:
    init-myservice:
        Container ID:  containerd://a2eb2f74006ea5f3645334bdb11b774f1399e440e53a0a3105717eb260554740
        Image:         busybox
        Image ID:      docker.io/library/busybox@sha256:ba76950ac9eaa407512c9d859cea48114eeff8a6f12ebaa5d32ce79d4a017dd8
        Port:          <none>
        Host Port:     <none>
        Command:
        sh
        -c
        sleep 5
        State:          Terminated
        Reason:       Completed
        Exit Code:    0
        Started:      Sat, 30 Dec 2023 08:47:08 +0000
        Finished:     Sat, 30 Dec 2023 08:47:13 +0000
        Ready:          True
        Restart Count:  0
        Environment:    <none>
        Mounts:
        /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-7djbh (ro)
    ```
    
    </details>
    </br>



21. What is the state of the purple POD?

    ```bash
    controlplane ~ ➜  k get po
    NAME     READY   STATUS     RESTARTS   AGE
    red      1/1     Running    0          3m1s
    green    2/2     Running    0          3m1s
    blue     1/1     Running    0          3m1s
    purple   0/1     Init:0/2   0          40s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k describe po purple | grep -i status
    Status:           Pending
    Type              Status
    ```
    
    </details>
    </br>



22. Update the pod red to use an initContainer that uses the busybox image and sleeps for 20 seconds

    ```bash
    controlplane ~ ➜  k get po
    NAME     READY   STATUS     RESTARTS   AGE
    red      1/1     Running    0          5m27s
    green    2/2     Running    0          5m27s
    blue     1/1     Running    0          5m27s
    purple   0/1     Init:0/2   0          3m6s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  export do="--dry-run=client -o yaml"

    controlplane ~ ➜  export now="--force --grace-period 0" 

    controlplane ~ ➜  k get po red  -o yaml > red.yml
    ```

    Add the initContainer in the YAML file. Follow K8s docs for steps.
    ```yaml
    ## red.yml
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: "2023-12-30T08:47:05Z"
      name: red
      namespace: default
    resourceVersion: "909"
    uid: 2a18cd56-4b47-49f5-8a9b-a294020d2773
    spec:
      initContainers:
      - name: initcontainer
        image: busybox
        command: ['sh', '-c', 'sleep 20']
      containers:
      - command:
        - sh
        - -c
        - echo The app is running! && sleep 3600
        image: busybox:1.28
        imagePullPolicy: IfNotPresent
        name: red-container
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
        name: kube-api-access-r4zhp
        readOnly: true 
    ```
    ```bash
    controlplane ~ ✦ ➜  k delete -f red.yml $now
    Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
    pod "red" force deleted

    controlplane ~ ✦ ➜  k get po
    NAME     READY   STATUS     RESTARTS   AGE
    green    2/2     Running    0          10m
    blue     1/1     Running    0          10m
    purple   0/1     Init:0/2   0          7m53s

    controlplane ~ ✦ ➜  k apply -f red.yml 
    pod/red created

    controlplane ~ ✦ ➜  k get po
    NAME     READY   STATUS     RESTARTS   AGE
    green    2/2     Running    0          10m
    blue     1/1     Running    0          10m
    purple   0/1     Init:0/2   0          8m2s
    red      0/1     Init:0/1   0          2s 

    controlplane ~ ✦ ➜  k get po
    NAME     READY   STATUS     RESTARTS   AGE
    green    2/2     Running    0          10m
    blue     1/1     Running    0          10m
    purple   0/1     Init:0/2   0          8m33s
    red      1/1     Running    0          33s
    ```
    
    </details>
    </br>



23. A new application orange is deployed. There is something wrong with it. Identify and fix the issue.

    ```bash
    controlplane ~ ✦ ➜  k get po
    NAME     READY   STATUS       RESTARTS     AGE
    green    2/2     Running      0            11m
    blue     1/1     Running      0            11m
    purple   0/1     Init:0/2     0            9m31s
    red      1/1     Running      0            91s
    orange   0/1     Init:Error   1 (6s ago)   7s 
    ``` 

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  export do="--dry-run=client -o yaml"

    controlplane ~ ➜  export now="--force --grace-period 0"

    controlplane ~ ✦2 ➜  k logs orange 
    Defaulted container "orange-container" out of: orange-container, init-myservice (init)
    Error from server (BadRequest): container "orange-container" in pod "orange" is waiting to start: PodInitializing

    controlplane ~ ✦2 ✖ k get po orange -o yaml > orange.yml
    ```

    Inspect the YAML file. We can see that the command is wrong.

    ```yaml 
    ## orange.yml
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: "2023-12-30T08:58:50Z"
      name: orange
      namespace: default
    resourceVersion: "1228"
    uid: 79f7f539-c1e2-4f74-9ebe-cb6065cc49d2
    spec:
      containers:
      - command:
        - sh
        - -c
        - echo The app is running! && sleep 3600
        image: busybox:1.28
        imagePullPolicy: IfNotPresent
        name: orange-container
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
          name: kube-api-access-9d8th
          readOnly: true
      dnsPolicy: ClusterFirst
      enableServiceLinks: true
      initContainers:
      - command:
        - sh
        - -c
        - sleeeep 2;
        image: busybox
        imagePullPolicy: Always
        name: init-myservice
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
          name: kube-api-access-9d8th
          readOnly: true 
    ```

    Fix the command in initcontainer. 

    ```yaml 
    ## orange.yml
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: "2023-12-30T08:58:50Z"
      name: orange
      namespace: default
    resourceVersion: "1228"
    uid: 79f7f539-c1e2-4f74-9ebe-cb6065cc49d2
    spec:
      containers:
      - command:
        - sh
        - -c
        - echo The app is running! && sleep 3600
        image: busybox:1.28
        imagePullPolicy: IfNotPresent
        name: orange-container
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
          name: kube-api-access-9d8th
          readOnly: true
    dnsPolicy: ClusterFirst
    enableServiceLinks: true
      initContainers:
      - command:
        - sh
        - -c
        - sleep 2;
        image: busybox
        imagePullPolicy: Always
        name: init-myservice
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
          name: kube-api-access-9d8th
          readOnly: true 
    ```
    ```bash
    controlplane ~ ✦2 ➜  k delete -f orange.yml $now
    Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
    pod "orange" force deleted

    controlplane ~ ✦2 ➜  k apply -f orange.yml 
    pod/orange created

    controlplane ~ ✦2 ➜  k get po
    NAME     READY   STATUS     RESTARTS   AGE
    green    2/2     Running    0          20m
    blue     1/1     Running    0          20m
    red      1/1     Running    0          10m
    purple   0/1     Init:1/2   0          18m
    orange   0/1     Init:0/1   0          2s

    controlplane ~ ✦2 ➜  k get po
    NAME     READY   STATUS     RESTARTS   AGE
    green    2/2     Running    0          20m
    blue     1/1     Running    0          20m
    red      1/1     Running    0          10m
    purple   0/1     Init:1/2   0          18m
    orange   1/1     Running    0          5s 
    ```

    </details>
    </br>





[Back to the top](#practice-test-cka)    
