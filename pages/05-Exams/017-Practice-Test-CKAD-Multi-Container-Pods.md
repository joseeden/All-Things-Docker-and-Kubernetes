
# Practice Test: CKAD

> *Some of the scenario questions here are based on [Kodekloud's CKAD course labs](https://kodekloud.com/courses/labs-certified-kubernetes-application-developer/?utm_source=udemy&utm_medium=labs&utm_campaign=kubernetes).*

- [Configuration](016-Practice-Test-CKAD-Configuration.md) 

- [Multi-Container PODs](017-Practice-Test-CKAD-Multi-Container-Pods.md)

- [POD Design](018-Practice-Test-CKAD-Pod-Design.md)

- [Services & Networking](019-Practice-Test-CKAD-Services-Networking,md)

- [State Persistence](020-Practice-Test-CKAD-State-Persistence.md)

- [Additional Updates](021-Practice-Test-CKAD-Additional-Updates.md)

- [Mock Exams](022-Practice-Test-CKAD-Mock-Exams.md) 


## Multi-Container Pods

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

1. Create a multi-container pod with 2 containers. Use the spec given below. If the pod goes into the crashloopbackoff then add the command sleep 1000 in the lemon container.

    - Name: yellow

    - Container 1 Name: lemon

    - Container 1 Image: busybox

    - Container 2 Name: gold

    - Container 2 Image: redis


    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k run yellow --image busybox $do > yellow.yml

    controlplane ~ ➜  ls -l
    total 8
    drwxr-xr-x 3 root root 4096 Jan  5 09:40 elastic-search
    -rw-r--r-- 1 root root  237 Jan  5 09:43 yellow.yml 
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
      - image: redis
        name: gold
        resources: {}
    dnsPolicy: ClusterFirst
    restartPolicy: Always
    status: {}
    ```
    
    ```bash
    controlplane ~ ➜  k apply -f yellow.yml 
    pod/yellow created

    controlplane ~ ➜  k get po
    NAME        READY   STATUS              RESTARTS   AGE
    app         1/1     Running             0          5m2s
    blue        2/2     Running             0          3m30s
    fluent-ui   1/1     Running             0          5m3s
    red         3/3     Running             0          4m50s
    yellow      0/2     ContainerCreating   0          3s 
    ```
    
    </details>
    </br>


2. Update the newly created pod 'simple-webapp-2' with a readinessProbe using the given specs:

    - Pod Name: simple-webapp-2

    - Image Name: kodekloud/webapp-delayed-start

    - Readiness Probe: httpGet

    - Http Probe: /ready

    - Http Port: 8080

    ```bash
    controlplane ~ ➜  k get po
    NAME              READY   STATUS    RESTARTS   AGE
    simple-webapp-1   1/1     Running   0          2m7s
    simple-webapp-2   1/1     Running   0          111s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po simple-webapp-2 -o yaml > simple-webapp-2.yml

    controlplane ~ ➜  k delete po simple-webapp-2 $now
    Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
    pod "simple-webapp-2" force deleted

    controlplane ~ ➜  k get po
    NAME              READY   STATUS    RESTARTS   AGE
    simple-webapp-1   1/1     Running   0          3m5s

    controlplane ~ ➜  ls -l
    total 16
    -rwxr-xr-x 1 root root  114 Dec  1 06:17 crash-app.sh
    -rwxr-xr-x 1 root root  216 Dec  1 06:17 curl-test.sh
    -rwxr-xr-x 1 root root  123 Dec  1 06:17 freeze-app.sh
    -rw-r--r-- 1 root root 2772 Jan  5 09:56 simple-webapp-2.yml 
    ```

    Modify the YAML file. 

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: "2024-01-05T14:53:47Z"
      labels:
        name: simple-webapp
      name: simple-webapp-2
      namespace: default
      resourceVersion: "631"
      uid: 302ac3b8-bb0b-4294-89dd-4eef603bf001
    spec:
      containers:
      - env:
        - name: APP_START_DELAY
        value: "80"
        image: kodekloud/webapp-delayed-start
        imagePullPolicy: Always
        name: simple-webapp
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
    ```
    ```bash
    controlplane ~ ➜  k apply -f simple-webapp-2.yml 
    pod/simple-webapp-2 created

    controlplane ~ ➜  k get po
    NAME              READY   STATUS              RESTARTS   AGE
    simple-webapp-1   1/1     Running             0          6m37s
    simple-webapp-2   0/1     ContainerCreating   0          8s 
    ```
    
    </details>
    </br>


3. Update both the pods with a livenessProbe using the given spec

    - Pod Name: simple-webapp-1

    - Image Name: kodekloud/webapp-delayed-start

    - Liveness Probe: httpGet

    - Http Probe: /live

    - Http Port: 8080

    - Period Seconds: 1

    - Initial Delay: 80

    - Pod Name: simple-webapp-2

    - Image Name: kodekloud/webapp-delayed-start

    - Liveness Probe: httpGet

    - Http Probe: /live

    - Http Port: 8080

    - Initial Delay: 80

    - Period Seconds: 1

    ```bash
    controlplane ~ ✦ ➜  k get po
    NAME              READY   STATUS    RESTARTS   AGE
    simple-webapp-1   1/1     Running   0          9m15s
    simple-webapp-2   1/1     Running   0          2m46s 
    ```


    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ✦ ➜  k get po simple-webapp-1 -o yaml > simple-webapp-1.yml

    controlplane ~ ✦ ➜  k get po simple-webapp-2 -o yaml > simple-webapp-2.yml

    controlplane ~ ✦ ➜  k delete po simple-webapp-1 $now
    Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
    pod "simple-webapp-1" force deleted

    controlplane ~ ✦ ➜  k delete po simple-webapp-2 $now
    Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
    pod "simple-webapp-2" force deleted

    controlplane ~ ✦ ➜  k get po
    No resources found in default namespace. 
    ```

    Modify the first pod first. 

    ```yaml 
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: "2024-01-05T14:53:31Z"
      labels:
        name: simple-webapp
      name: simple-webapp-1
      namespace: default
      resourceVersion: "605"
      uid: 5843cf05-165d-4f4c-9293-21f21e9a7905
    spec:
      containers:
      - image: kodekloud/webapp-delayed-start
        imagePullPolicy: Always
        name: simple-webapp
        livenessProbe:
          initialDelaySeconds: 80
          periodSeconds: 1
          httpGet:
            path: /live
            port: 8080
        ports:
        - containerPort: 8080
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
        name: kube-api-access-zwmnp
        readOnly: true
    ```
    ```bash
    controlplane ~ ✦ ➜  k apply -f simple-webapp-1.yml 
    pod/simple-webapp-1 created

    controlplane ~ ✦ ➜  k get po
    NAME              READY   STATUS    RESTARTS   AGE
    simple-webapp-1   1/1     Running   0          51s
    ```

    Next, modify the YAML file for the second pod. 

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: "2024-01-05T15:00:00Z"
      labels:
        name: simple-webapp
      name: simple-webapp-2
      namespace: default
      resourceVersion: "1286"
      uid: cfdd23e3-e7e3-4be7-9dd9-b2abf5f0ad0e
    spec:
      containers:
      - env:
        - name: APP_START_DELAY
        value: "80"
        image: kodekloud/webapp-delayed-start
        imagePullPolicy: Always
        name: simple-webapp
        livenessProbe:
          initialDelaySeconds: 80
          periodSeconds: 1
          httpGet:
            path: /live
            port: 8080
        ports:
        - containerPort: 8080
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /ready
            port: 8080
            scheme: HTTP
            periodSeconds: 10
        successThreshold: 1
        timeoutSeconds: 1
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
        name: kube-api-access-xvbr6
        readOnly: true
    ```
    ```bash
    controlplane ~ ✦ ➜  k apply -f simple-webapp-2.yml 
    pod/simple-webapp-2 created

    controlplane ~ ✦ ➜  k get po
    NAME              READY   STATUS    RESTARTS   AGE
    simple-webapp-1   1/1     Running   0          118s
    simple-webapp-2   0/1     Running   0          6s
    ```
    
    </details>
    </br>





[Back to the top](#practice-test-ckad)    

