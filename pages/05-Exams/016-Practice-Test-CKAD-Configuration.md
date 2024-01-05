
# Practice Test: CKAD

> *Some of the scenario questions here are based on [Kodekloud's CKAD course labs](https://kodekloud.com/courses/labs-certified-kubernetes-application-developer/?utm_source=udemy&utm_medium=labs&utm_campaign=kubernetes).*

- [Configuration](016-Practice-Test-CKAD-Configuration.md) 

- [Multi-Container PODs](017-Practice-Test-CKAD-Multi-Container-Pods.md)

- [POD Design](018-Practice-Test-CKAD-Pod-Design.md)

- [Services & Networking](019-Practice-Test-CKAD-Services-Networking,md)

- [State Persistence](020-Practice-Test-CKAD-State-Persistence.md)

- [Additional Updates](021-Practice-Test-CKAD-Additional-Updates.md)

- [Mock Exams](022-Practice-Test-CKAD-Mock-Exams.md) 


## Configuration 

First run the two commands below for shortcuts.

```bash
export do="--dry-run=client -o yaml" 
export now="--force --grace-period=0" 
```

Questions: 

1. Create a pod with the ubuntu image to run a container to sleep for 5000 seconds. 

    <details><summary> Answer </summary>
    
    ```bash
    ## ubuntu-sleeper-2.yml
    apiVersion: v1
    kind: Pod 
    metadata:
      name: ubuntu-sleeper-2
    spec:
      containers:
      - name: ubuntu
        image: ubuntu
        command:
        - sleep
        - "5000"
    ```
    ```bash
    controlplane ~ ➜  k apply -f ubuntu-sleeper-2.yaml 
    pod/ubuntu-sleeper-2 created

    controlplane ~ ➜  k get po
    NAME               READY   STATUS    RESTARTS   AGE
    ubuntu-sleeper     1/1     Running   0          86s
    ubuntu-sleeper-2   1/1     Running   0          7s 
    ```
    
    </details>
    </br>


2. Inspect the file Dockerfile2 given at /root/webapp-color directory. What command is run at container startup?

    ```bash
    FROM python:3.6-alpine

    RUN pip install flask

    COPY . /opt/

    EXPOSE 8080

    WORKDIR /opt

    ENTRYPOINT ["python", "app.py"]

    CMD ["--color", "red"] 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    oython app.py --color red
    ```
    
    </details>
    </br>


3. Inspect the two files under directory webapp-color-2. What command is run at container startup?

    ```bash
    controlplane ~ ➜  ls -l webapp-color-2/
    total 8
    -rw-r--r--    1 root     root           144 Jan  5 12:34 Dockerfile
    -rw-rw-rw-    1 root     root           205 Dec 13 10:39 webapp-color-pod.yaml

    controlplane ~ ➜  cat webapp-color-2/Dockerfile 
    FROM python:3.6-alpine

    RUN pip install flask

    COPY . /opt/

    EXPOSE 8080

    WORKDIR /opt

    ENTRYPOINT ["python", "app.py"]

    CMD ["--color", "red"]

    controlplane ~ ➜  cat webapp-color-2/webapp-color-pod.yaml 
    apiVersion: v1 
    kind: Pod 
    metadata:
      name: webapp-green
      labels:
        name: webapp-green 
    spec:
      containers:
      - name: simple-webapp
        image: kodekloud/webapp-color
        command: ["--color","green"] 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    --color green
    ```
    
    </details>
    </br>


4. Create a pod with the given specifications. By default it displays a blue background. Set the given command line arguments to change it to green.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k run webapp-green --image kodekloud/webapp-color --dry-run=client -o yaml 
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
    dnsPolicy: ClusterFirst
    restartPolicy: Always
    status: {}

    controlplane ~ ➜  k run webapp-green --image kodekloud/webapp-color --dry-run=client -o yaml > webapp-green.yml
    ```

    Modify the YAML file. 

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
        args: ["--color","green"]
    dnsPolicy: ClusterFirst
    restartPolicy: Always
    status: {}
    ```
    ```bash
    controlplane ~ ➜  k get po
    NAME               READY   STATUS    RESTARTS   AGE
    ubuntu-sleeper     1/1     Running   0          9m28s
    ubuntu-sleeper-2   1/1     Running   0          8m9s
    ubuntu-sleeper-3   1/1     Running   0          5m52s
    webapp-green       1/1     Running   0          14s
    ```
    
    </details>
    </br>

5. What is the environment variable name set on the container in the pod?

    ```bash
    controlplane ~ ➜  k get po
    NAME           READY   STATUS    RESTARTS   AGE
    webapp-color   1/1     Running   0          6s 
      ```

    <details><summary> Answer </summary>
    
    ```YAML
    controlplane ~ ➜  k get po webapp-color -o yaml
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: "2024-01-05T12:46:37Z"
      labels:
        name: webapp-color
      name: webapp-color
      namespace: default
      resourceVersion: "727"
      uid: 575e946a-f8e7-4a45-81af-be9e1e168b8c
    spec:
      containers:
      - env:
        - name: APP_COLOR
          value: pink
    ```
    
    </details>
    </br>

6. Identify the database host from the config map db-config.

    ```bash
    controlplane ~ ➜  k get cm
    NAME               DATA   AGE
    kube-root-ca.crt   1      6m51s
    db-config          3      5s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k describe cm db-config 
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

7. Create a new ConfigMap for the webapp-color POD. Use the spec given below.

    - ConfigMap Name: webapp-config-map

    - Data: APP_COLOR=darkblue

    - Data: APP_OTHER=disregard

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k create cm webapp-config-map $do
    apiVersion: v1
    kind: ConfigMap
    metadata:
      creationTimestamp: null
      name: webapp-config-map

    controlplane ~ ➜  k create cm webapp-config-map $do > webapp-color-cm.yml
    ```

    Modify the YAML file. 

    ```bash
    apiVersion: v1
    kind: ConfigMap
    metadata:
      creationTimestamp: null
      name: webapp-config-map
    data:
      APP_COLOR: "darkblue"
      APP_OTHER: "disregard"
    ```

    ```bash
    controlplane ~ ➜  k apply -f webapp-color-cm.yml 
    configmap/webapp-config-map created

    controlplane ~ ➜  k get cm
    NAME                DATA   AGE
    kube-root-ca.crt    1      15m
    db-config           3      8m42s
    webapp-config-map   2      3s

    controlplane ~ ➜  k describe cm webapp-config-map 
    Name:         webapp-config-map
    Namespace:    default
    Labels:       <none>
    Annotations:  <none>

    Data
    ====
    APP_COLOR:
    ----
    darkblue
    APP_OTHER:
    ----
    disregard

    BinaryData
    ====

    Events:  <none>
    ```

    </details>
    </br>


8. Update the environment variable on the POD to use only the APP_COLOR key from the newly created ConfigMap.

    ```bash
    controlplane ~ ➜  k get po
    NAME           READY   STATUS    RESTARTS   AGE
    webapp-color   1/1     Running   0          10m

    controlplane ~ ➜  k get cm
    NAME                DATA   AGE
    kube-root-ca.crt    1      16m
    db-config           3      10m
    webapp-config-map   2      92s

    controlplane ~ ➜  k describe cm webapp-config-map 
    Name:         webapp-config-map
    Namespace:    default
    Labels:       <none>
    Annotations:  <none>

    Data
    ====
    APP_COLOR:
    ----
    darkblue
    APP_OTHER:
    ----
    disregard

    BinaryData
    ====

    Events:  <none> 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po
    NAME           READY   STATUS    RESTARTS   AGE
    webapp-color   1/1     Running   0          11m

    controlplane ~ ➜  k get po webapp-color -o yaml > webcolor.yml 

    controlplane ~ ➜  k delete po webapp-color $now
    Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
    pod "webapp-color" force deleted

    controlplane ~ ➜  k get po
    No resources found in default namespace.
    ```
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      labels:
        name: webapp-color
      name: webapp-color
      namespace: default
    spec:
      containers:
      - env:
        - name: APP_COLOR
          value: green
        image: kodekloud/webapp-color
        env:
        - name: APP_COLOR
          valueFrom:
            configMapKeyRef:
              name: webapp-config-map
              key: APP_COLOR
        imagePullPolicy: Always
        name: webapp-color
        resources: {}
        volumeMounts:
        - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
          name: kube-api-access-9ggzh
          readOnly: true
    ```
    ```bash
    controlplane ~ ➜  k apply -f webcolor.yml 
    pod/webapp-color created

    controlplane ~ ➜  k get po
    NAME           READY   STATUS    RESTARTS   AGE
    webapp-color   1/1     Running   0          2s 
    ```
    
    </details>
    </br>


9. What type is secret **dashboard-token**?

    ```bash
    controlplane ~ ➜  k get secrets 
    NAME              TYPE                                  DATA   AGE
    dashboard-token   kubernetes.io/service-account-token   3      16s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k describe secrets dashboard-token 
    Name:         dashboard-token
    Namespace:    default
    Labels:       <none>
    Annotations:  kubernetes.io/service-account.name: dashboard-sa
                  kubernetes.io/service-account.uid: 4c24689d-326b-4273-8955-5168cd3e2031

    Type:  kubernetes.io/service-account-token
    ```
    
    </details>
    </br>


10. Create a new secret named db-secret with the data given below.

    - DB_Host=sql01
    - DB_User=root
    - DB_Password=password123

    Configure webapp-pod to load environment variables from the newly created secret.

    ```bash
    controlplane ~ ➜  k get po
    NAME         READY   STATUS    RESTARTS   AGE
    webapp-pod   1/1     Running   0          26s
    mysql        1/1     Running   0          26s

    controlplane ~ ➜  k get svc
    NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
    kubernetes       ClusterIP   10.43.0.1       <none>        443/TCP          8m56s
    webapp-service   NodePort    10.43.24.106    <none>        8080:30080/TCP   29s
    sql01            ClusterIP   10.43.130.206   <none>        3306/TCP         29s
    ```

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k create secret generic db-secret \
    > --from-literal=DB_Host=sql01 \
    > --from-literal=DB_User=root \
    > --from-literal=DB_Password=password123
    secret/db-secret created

    controlplane ~ ➜  k get secrets 
    NAME              TYPE                                  DATA   AGE
    dashboard-token   kubernetes.io/service-account-token   3      20m
    db-secret         Opaque                                3      5s

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

    Next, configure webapp pod. 

    ```bash
    controlplane ~ ➜  k get po
    NAME         READY   STATUS    RESTARTS   AGE
    webapp-pod   1/1     Running   0          19m
    mysql        1/1     Running   0          19m

    controlplane ~ ➜  k get po webapp-pod -o yaml > web-app.yml

    controlplane ~ ➜  k delete po webapp-pod $now
    Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
    pod "webapp-pod" force deleted

    controlplane ~ ➜  k get po
    NAME    READY   STATUS    RESTARTS   AGE
    mysql   1/1     Running   0          20m
    ```
    ```yaml
    ## web-app.yml
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: "2024-01-05T13:13:46Z"
      labels:
        name: webapp-pod
      name: webapp-pod
      namespace: default
      resourceVersion: "780"
      uid: 0691854a-31b3-407b-ad10-cabe6cdd1c35
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
    controlplane ~ ➜  k apply -f web-app.yml 
    pod/webapp-pod created

    controlplane ~ ➜  k get po
    NAME         READY   STATUS    RESTARTS   AGE
    mysql        1/1     Running   0          24m
    webapp-pod   1/1     Running   0          7s

    controlplane ~ ➜  k exec -it webapp-pod -- printenv | grep DB
    DB_Host=sql01
    DB_Password=password123
    DB_User=root
    ```
    
    </details>
    </br>


11. What is the user used to execute the sleep process within the ubuntu-sleeper pod?

    ```bash
    controlplane ~ ➜  k get po
    NAME             READY   STATUS    RESTARTS   AGE
    ubuntu-sleeper   1/1     Running   0          19s 
    ```
    
        
    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k exec -it ubuntu-sleeper -- whoami
    root
    ```
    
    </details>
    </br>


12. Edit the pod ubuntu-sleeper to run the sleep process with user ID 1010.

    ```bash
    controlplane ~ ➜  k get po
    NAME             READY   STATUS    RESTARTS   AGE
    ubuntu-sleeper   1/1     Running   0          19s 
    ```
        

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po ubuntu-sleeper -o yaml > ubuntu-sleeper.yml

    controlplane ~ ➜  k delete po ubuntu-sleeper $now
    Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
    pod "ubuntu-sleeper" force deleted

    controlplane ~ ➜  k get po
    No resources found in default namespace.
    ```

    Modify the YAML file. 

    ```yaml
    ---
    apiVersion: v1
    kind: Pod
    metadata:
      name: ubuntu-sleeper
      namespace: default
    spec:
      securityContext:
        runAsUser: 1010
      containers:
      - command:
        - sleep
        - "4800"
        image: ubuntu
        name: ubuntu-sleeper
    ```
    ```bash
    controlplane ~ ➜  k apply -f ubuntu-sleeper.yml 
    pod/ubuntu-sleeper created

    controlplane ~ ➜  k get po
    NAME             READY   STATUS    RESTARTS   AGE
    ubuntu-sleeper   1/1     Running   0          2s

    controlplane ~ ➜  k exec -it ubuntu-sleeper -- whoami
    whoami: cannot find name for user ID 1010
    command terminated with exit code 1 
    ```
    
    </details>
    </br>


13. A Pod definition file named multi-pod.yaml is given. With what user are the processes in the web container started?

    ```bash
    controlplane ~ ➜  k get po
    NAME             READY   STATUS    RESTARTS   AGE
    ubuntu-sleeper   1/1     Running   0          58s
    multi-pod        2/2     Running   0          7s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ✖ k exec -it multi-pod -c web -- whoami
    whoami: cannot find name for user ID 1002
    command terminated with exit code 1
    ```
    
    </details>
    </br>


14. Create pod **ubuntu-sleeper** to run as Root user and with the SYS_TIME capability.

    <details><summary> Answer </summary>
    
    ```yaml
    ## ubuntu-sleeper.yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: ubuntu-sleeper
      namespace: default
    spec:
      containers:
      - command:
        - sleep
        - "4800"
        image: ubuntu
        imagePullPolicy: Always
        name: ubuntu-sleeper
        securityContext:
          capabilities:
            add: ["SYS_TIME"]
        resources: {}
    ``` 
    ```bash
    controlplane ~ ➜  k apply -f  ubuntu-sleeper.yml 
    pod/ubuntu-sleeper created

    controlplane ~ ➜  k get po
    NAME             READY   STATUS    RESTARTS   AGE
    multi-pod        2/2     Running   0          6m27s
    ubuntu-sleeper   1/1     Running   0          3s 
    ```
    
    </details>
    </br>


15. The elephant pod is not running. Fix it. 

    ```bash
    controlplane ~ ➜  k get po
    NAME       READY   STATUS      RESTARTS     AGE
    elephant   0/1     OOMKilled   1 (2s ago)   5s
    ```

    <details><summary> Answer </summary>

    The elephant pod runs a process that consumes 15Mi of memory. Increase the limit of the elephant pod to 20Mi.

    ```bash
    controlplane ~ ➜  k get po elephant -o yaml >elephant.yml

    controlplane ~ ➜  k delete po elephant $now
    Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
    pod "elephant" force deleted

    controlplane ~ ➜  k get po
    No resources found in default namespace.
    ```

    ```bash
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: "2024-01-05T13:59:37Z"
      name: elephant
      namespace: default
      resourceVersion: "796"
      uid: 67ed2482-fcee-43be-a1b9-adb6b36448ff
    spec:
      containers:
      - args:
        - --vm
        - "1"
        - --vm-bytes
        - 15M
        - --vm-hang
        - "1"
        command:
        - stress
        image: polinux/stress
        imagePullPolicy: Always
        name: mem-stress
        resources:
          limits:
            memory: 20Mi
          requests:
            memory: 5Mi
    ```
    ```bash
    controlplane ~ ➜  k apply -f elephant.yml 
    pod/elephant created

    controlplane ~ ➜  k get po
    NAME       READY   STATUS    RESTARTS   AGE
    elephant   1/1     Running   0          3s 
    ```

    </details>
    </br>


16. Inspect the Dashboard Application POD and identify the Service Account mounted on it.

    ```bash
    controlplane ~ ➜  k get po
    NAME                            READY   STATUS    RESTARTS   AGE
    web-dashboard-97c9c59f6-p9gvc   1/1     Running   0          69s
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po -o yaml | grep -i service
          - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
        enableServiceLinks: true
        serviceAccount: default
        serviceAccountName: default
            - serviceAccountToken:
    ```
    
    </details>
    </br>


17. Create a taint on node01 with key of spray, value of mortein and effect of NoSchedule.

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS   ROLES           AGE     VERSION
    controlplane   Ready    control-plane   3m50s   v1.27.0
    node01         Ready    <none>          3m18s   v1.27.0 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k taint node node01 spray=mortein:NoSchedule
    node/node01 tainted

    controlplane ~ ➜  k describe nodes  node01 | grep -i taints
    Taints:             spray=mortein:NoSchedule 
    ```
    
    </details>
    </br>


18. Remove the taint on controlplane, which currently has the taint effect of NoSchedule

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS   ROLES           AGE     VERSION
    controlplane   Ready    control-plane   8m59s   v1.27.0
    node01         Ready    <none>          8m27s   v1.27.0 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k describe nodes controlplane | grep -i tain
                        kubeadm.alpha.kubernetes.io/cri-socket: unix:///var/run/containerd/containerd.sock
    Taints:             node-role.kubernetes.io/control-plane:NoSchedule
      Container Runtime Version:  containerd://1.6.6

    controlplane ~ ➜  k get no
    NAME           STATUS   ROLES           AGE     VERSION
    controlplane   Ready    control-plane   8m59s   v1.27.0
    node01         Ready    <none>          8m27s   v1.27.0

    controlplane ~ ➜  k taint node controlplane node-role.kubernetes.io/control-plane:NoSchedule-
    node/controlplane untainted

    controlplane ~ ➜  k describe nodes controlplane | grep -i tain
                        kubeadm.alpha.kubernetes.io/cri-socket: unix:///var/run/containerd/containerd.sock
    Taints:             <none>
      Container Runtime Version:  containerd://1.6.6 
    ```
    
    </details>
    </br>


19. What is the value set to the label key beta.kubernetes.io/arch on node01?

    ```bash
    controlplane ~ ➜  k get nodes 
    NAME           STATUS   ROLES           AGE     VERSION
    controlplane   Ready    control-plane   3m      v1.27.0
    node01         Ready    <none>          2m31s   v1.27.0 
    ```
        
    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get nodes 
    NAME           STATUS   ROLES           AGE     VERSION
    controlplane   Ready    control-plane   3m      v1.27.0
    node01         Ready    <none>          2m31s   v1.27.0

    controlplane ~ ➜  k get nodes node01 -o yaml 
    apiVersion: v1
    kind: Node
    metadata:
      annotations:
        flannel.alpha.coreos.com/backend-data: '{"VNI":1,"VtepMAC":"16:ff:13:00:fc:f2"}'
        flannel.alpha.coreos.com/backend-type: vxlan
        flannel.alpha.coreos.com/kube-subnet-manager: "true"
        flannel.alpha.coreos.com/public-ip: 192.32.16.6
        kubeadm.alpha.kubernetes.io/cri-socket: unix:///var/run/containerd/containerd.sock
        node.alpha.kubernetes.io/ttl: "0"
        volumes.kubernetes.io/controller-managed-attach-detach: "true"
      creationTimestamp: "2024-01-05T14:15:24Z"
      labels:
        beta.kubernetes.io/arch: amd64
        beta.kubernetes.io/os: linux
        kubernetes.io/arch: amd64
        kubernetes.io/hostname: node01
        kubernetes.io/os: linux 
    ```
    
    </details>
    </br>


20. Apply a label color=blue to node node01.

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS   ROLES           AGE     VERSION
    controlplane   Ready    control-plane   4m2s    v1.27.0
    node01         Ready    <none>          3m33s   v1.27.0 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    ontrolplane ~ ➜  k label nodes node01 color=blue
    node/node01 labeled

    controlplane ~ ➜  k get nodes node01 -o yaml 
    apiVersion: v1
    kind: Node
    metadata:
      annotations:
        flannel.alpha.coreos.com/backend-data: '{"VNI":1,"VtepMAC":"16:ff:13:00:fc:f2"}'
        flannel.alpha.coreos.com/backend-type: vxlan
        flannel.alpha.coreos.com/kube-subnet-manager: "true"
        flannel.alpha.coreos.com/public-ip: 192.32.16.6
        kubeadm.alpha.kubernetes.io/cri-socket: unix:///var/run/containerd/containerd.sock
        node.alpha.kubernetes.io/ttl: "0"
        volumes.kubernetes.io/controller-managed-attach-detach: "true"
      creationTimestamp: "2024-01-05T14:15:24Z"
      labels:
        beta.kubernetes.io/arch: amd64
        beta.kubernetes.io/os: linux
        color: blue
        kubernetes.io/arch: amd64
        kubernetes.io/hostname: node01
        kubernetes.io/os: linux 
    ```
    
    </details>
    </br>


21. Set Node Affinity to the deployment to place the pods on node01 only.

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS   ROLES           AGE     VERSION
    controlplane   Ready    control-plane   6m27s   v1.27.0
    node01         Ready    <none>          5m58s   v1.27.0

    controlplane ~ ➜  k get deployments.apps 
    NAME   READY   UP-TO-DATE   AVAILABLE   AGE
    blue   3/3     3            3           59s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get deployments.apps blue -o yaml > dep1.yml

    controlplane ~ ➜  k delete -f dep1.yml 
    deployment.apps "blue" deleted 
    ```

    Modify the YAML file. 

    ```yaml 
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      annotations:
        deployment.kubernetes.io/revision: "2"
      creationTimestamp: "2024-01-05T14:20:26Z"
      generation: 2
      labels:
        app: blue
      name: blue
      namespace: default
      resourceVersion: "1394"
      uid: 2df39c10-43d6-4a8d-bacb-2b440e90f166
    spec:
      progressDeadlineSeconds: 600
      replicas: 3
      revisionHistoryLimit: 10
      selector:
        matchLabels:
          app: blue
      strategy:
        rollingUpdate:
          maxSurge: 25%
          maxUnavailable: 25%
        type: RollingUpdate
      template:
        metadata:
          creationTimestamp: null
          labels:
            app: blue
        spec:
          affinity:
            nodeAffinity:
              requiredDuringSchedulingIgnoredDuringExecution: 
                nodeSelectorTerms:
                - matchExpressions:
                  - key: color
                    operator: In
                    values:
                    - blue
          containers:
          - image: nginx
            imagePullPolicy: Always
            name: nginx
            resources: {}
            terminationMessagePath: /dev/termination-log
            terminationMessagePolicy: File
    ```
    ```bash
    controlplane ~ ➜  k apply -f dep1.yml 
    deployment.apps/blue created

    controlplane ~ ➜  k get deployments.apps 
    NAME   READY   UP-TO-DATE   AVAILABLE   AGE
    blue   2/3     3            2           4s

    controlplane ~ ➜  k get po -o wide
    NAME                   READY   STATUS    RESTARTS   AGE   IP            NODE     NOMINATED NODE   READINESS GATES
    blue-f69d4c887-46xgc   1/1     Running   0          8s    10.244.1.9    node01   <none>           <none>
    blue-f69d4c887-6qb8w   1/1     Running   0          8s    10.244.1.8    node01   <none>           <none>
    blue-f69d4c887-ktl6r   1/1     Running   0          8s    10.244.1.10   node01   <none>           <none> 
    ```
    
    </details>
    </br>


22. Create a new deployment named red with the nginx image and 2 replicas, and ensure it gets placed on the controlplane node only.

    Use the label key - node-role.kubernetes.io/control-plane - which is already set on the controlplane node.

    
    - NodeAffinity: requiredDuringSchedulingIgnoredDuringExecution

    - Key: node-role.kubernetes.io/control-plane

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS   ROLES           AGE   VERSION
    controlplane   Ready    control-plane   17m   v1.27.0
    node01         Ready    <none>          16m   v1.27.0 
    ```
        
    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k describe no controlplane 
    Name:               controlplane
    Roles:              control-plane
    Labels:             beta.kubernetes.io/arch=amd64
                        beta.kubernetes.io/os=linux
                        kubernetes.io/arch=amd64
                        kubernetes.io/hostname=controlplane
                        kubernetes.io/os=linux
                        node-role.kubernetes.io/control-plane=
                        node.kubernetes.io/exclude-from-external-load-balancers=

    controlplane ~ ➜  k create deployment red --image nginx --replicas 2 $do > red.yml 
    ```
    ```bash
    ## red,yml 
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      creationTimestamp: null
      labels:
        app: red
      name: red
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: red
      strategy: {}
      template:
        metadata:
          creationTimestamp: null
          labels:
            app: red
        spec:
          affinity:
            nodeAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                - matchExpressions:
                  - key: node-role.kubernetes.io/control-plane
                    operator: Exists
          containers:
          - image: nginx
            name: nginx
            resources: {}
    status: {}
    ```
    ```bash
    controlplane ~ ➜  k apply -f red.yml 
    deployment.apps/red created 

    controlplane ~ ➜  k get deployments.apps 
    NAME   READY   UP-TO-DATE   AVAILABLE   AGE
    blue   3/3     3            3           10m
    red    2/2     2            2           20s
    ```
    
    </details>
    </br>




[Back to the top](#practice-test-ckad)    

