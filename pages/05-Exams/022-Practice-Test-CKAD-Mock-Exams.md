
# Practice Test: CKAD

> *Some of the scenario questions here are based on [Kodekloud's CKAD course labs](https://kodekloud.com/courses/labs-certified-kubernetes-application-developer/?utm_source=udemy&utm_medium=labs&utm_campaign=kubernetes).*

- [Configuration](016-Practice-Test-CKAD-Configuration.md) 

- [Multi-Container PODs](017-Practice-Test-CKAD-Multi-Container-Pods.md)

- [POD Design](018-Practice-Test-CKAD-Pod-Design.md)

- [Services & Networking](019-Practice-Test-CKAD-Services-Networking,md)

- [State Persistence](020-Practice-Test-CKAD-State-Persistence.md)

- [Additional Updates](021-Practice-Test-CKAD-Additional-Updates.md)

- [Mock Exams](022-Practice-Test-CKAD-Mock-Exams.md) 


## Mock Exams 

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

1. Create a Persistent Volume called log-volume. It should make use of a storage class name manual. It should use RWX as the access mode and have a size of 1Gi. The volume should use the hostPath /opt/volume/nginx

    Next, create a PVC called log-claim requesting a minimum of 200Mi of storage. This PVC should bind to log-volume.

    Mount this in a pod called logger at the location /var/www/nginx. This pod should use the image nginx:alpine.


    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po
    NAME           READY   STATUS    RESTARTS   AGE
    webapp-color   1/1     Running   0          75s

    controlplane ~ ➜  k get sc
    NAME     PROVISIONER                    RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
    manual   kubernetes.io/no-provisioner   Delete          Immediate           false                  77s

    controlplane ~ ➜  k get pv
    No resources found

    controlplane ~ ➜  k get pvc
    No resources found in default namespace.
    ```

    ```yaml
    ## pv.yml 
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: log-volume
    spec:
      capacity:
        storage: 1Gi
      volumeMode: Filesystem
      accessModes:
        - ReadWriteMany
      storageClassName: manual
      hostPath:
        path: /opt/volume/nginx
    ```

    ```yaml 
    ## pvc.yml 
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: log-claim
    spec:
      accessModes:
        - ReadWriteMany
      volumeMode: Filesystem
      resources:
        requests:
          storage: 200Mi
      storageClassName: manual
    ```
    ```yaml 
    ## nginx.yml 
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: null
      labels:
        run: logger
      name: logger
    spec:
      containers:
      - image: nginx:alpine
        name: logger
        resources: {}
        volumeMounts:
        - mountPath: /var/www/nginx
          name: log-volume
          readOnly: true
      volumes:
      - name: log-volume
        emptyDir: {}
      dnsPolicy: ClusterFirst
      restartPolicy: Always
    status: {}
    ```

    ```bash
    controlplane ~ ➜  ls -l
    total 12
    -rw-r--r-- 1 root root 385 Jan  6 03:06 nginx.yml
    -rw-r--r-- 1 root root 212 Jan  6 03:01 pvc.yml
    -rw-r--r-- 1 root root 231 Jan  6 03:04 pv.yml

    controlplane ~ ➜  k apply -f .
    pod/logger created
    persistentvolume/log-volume created
    persistentvolumeclaim/log-claim created
    ```

    ```bash
    controlplane ~ ➜  k get pv
    NAME         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS   REASON   AGE
    log-volume   1Gi        RWX            Retain           Bound    default/log-claim   manual                  4s

    controlplane ~ ➜  k get pvc
    NAME        STATUS   VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS   AGE
    log-claim   Bound    log-volume   1Gi        RWX            manual         7s

    controlplane ~ ➜  k get po
    NAME           READY   STATUS    RESTARTS   AGE
    logger         1/1     Running   0          10s
    webapp-color   1/1     Running   0          14m

    controlplane ~ ➜  k describe po logger  | grep -A 10 Volumes:
    Volumes:
    log-volume:
        Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
        Medium:     
        SizeLimit:  <unset>    
    ```

    </details>
    </br>

2. We have deployed a new pod called secure-pod and a service called secure-service. Incoming or Outgoing connections to this pod are not working.
Troubleshoot why this is happening.

    - Make sure that incoming connection from the pod webapp-color are successful.

    - Important: Don't delete any current objects deployed.

    - Create the necessary networking policy. 

    ```bash
    controlplane ~ ➜  k get po
    NAME                           READY   STATUS    RESTARTS   AGE
    logger                         1/1     Running   0          27m
    nginx-deploy-dcbd487f9-47592   1/1     Running   0          9m22s
    nginx-deploy-dcbd487f9-9r8tc   1/1     Running   0          9m25s
    nginx-deploy-dcbd487f9-r6tqp   1/1     Running   0          9m25s
    nginx-deploy-dcbd487f9-srmtx   1/1     Running   0          9m25s
    redis-77c4ffc68c-n4ndn         1/1     Running   0          3m52s
    secure-pod                     1/1     Running   0          25m
    webapp-color                   1/1     Running   0          32m

    controlplane ~ ➜  k get svc
    NAME             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
    kubernetes       ClusterIP   10.96.0.1        <none>        443/TCP   112m
    secure-service   ClusterIP   10.101.166.125   <none>        80/TCP    25m 
    ```

    <details><summary> Answer </summary>
    
    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-ingress
      namespace: default
    spec:
      podSelector:
        matchLabels:
          run: secure-pod
      policyTypes:
        - Ingress
      ingress:
        - from:
            - podSelector:
                matchLabels:
                  name: webapp-color
          ports:
            - protocol: TCP
              port: 80
    ```
    ```bash
    controlplane ~ ✦ ➜  k apply -f netpol.yml 
    networkpolicy.networking.k8s.io/test-network-policy created

    controlplane ~ ✦ ➜  k get netpol
    NAME            POD-SELECTOR     AGE
    allow-ingress   run=secure-pod   2m39s
    default-deny    <none>           33m

    controlplane ~ ➜  k exec -it webapp-color -- nc -v -z  secure-service 80
    secure-service (10.100.140.194:80) open
    ```
    
    </details>
    </br>

3. Create a pod called time-check in the dvl1987 namespace. This pod should run a container called time-check that uses the busybox image.

    - Create a config map called time-config with the data TIME_FREQ=10 in the same namespace.

    - The time-check container should run the command: while true; do date; sleep $TIME_FREQ;done and write the result to the location /opt/time/time-check.log.
    - The path /opt/time on the pod should mount a volume that lasts the lifetime of this pod.


    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ✦ ➜  k create ns dvl1987
    namespace/dvl1987 created

    controlplane ~ ✦ ➜  k get ns
    NAME              STATUS   AGE
    default           Active   139m
    dvl1987           Active   4s
    e-commerce        Active   58m
    kube-node-lease   Active   139m
    kube-public       Active   139m
    kube-system       Active   139m
    marketing         Active   58m
    ```
    ```yaml
    ## time-check-cm.yml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      creationTimestamp: null
      name: time-config
      namespace: dvl1987
    data:
      TIME_FREQ: "10"
    ```
    ```yaml
    ## time-check.yml 
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: null
      labels:
        run: time-check
      name: time-check
      namespace: dvl1987
    spec:
      containers:
      - image: busybox
        name: time-check
        resources: {}
        command: ["sh","-c"]
        args: ["while true; do date; sleep $TIME_FREQ;done > /opt/time/time-check.log"]
        env:
        - name: TIME_FREQ
          valueFrom:
            configMapKeyRef:
              name: time-config
              key: TIME_FREQ
        volumeMounts:
        - name: vol
          mountPath: /opt/time
      volumes:
      - name: vol
        emptyDir: {}
      dnsPolicy: ClusterFirst
      restartPolicy: Always
    status: {}
    ```

    ```bash
    controlplane ~ ✦2 ➜  ls -l
    total 20
    -rw-r--r-- 1 root root 132 Jan  6 03:20 time-check-cm.yml
    -rw-r--r-- 1 root root 630 Jan  6 03:22 time-check.yml

    controlplane ~ ✦2 ➜  k apply -f time-check-cm.yml 
    configmap/time-config created

    controlplane ~ ✦3 ➜ k apply -f time-check.yml 
    pod/time-check created

    controlplane ~ ✦3 ➜  k get -n dvl1987 cm
    NAME               DATA   AGE
    kube-root-ca.crt   1      4m59s
    time-config        1      111s

    controlplane ~ ➜  k describe -n dvl1987 po time-check | grep -A 10 Environment
        Environment:
          TIME_FREQ:  <set to the key 'TIME_FREQ' of config map 'time-config'>  Optional: false

    controlplane ~ ➜  k describe -n dvl1987 po time-check | grep -A 10 Volumes:
    Volumes:
      vol:
        Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
        Medium:     
        SizeLimit:  <unset>      
    ```
    
    </details>
    </br>


4. Create a new deployment called nginx-deploy, with one single container called nginx, image nginx:1.16 and 4 replicas.

    - The deployment should use RollingUpdate strategy with maxSurge=1, and maxUnavailable=2.

    - Next upgrade the deployment to version 1.17.

    - Finally, once all pods are updated, undo the update and go back to the previous version.


    <details><summary> Answer </summary>
    
    ```bash
    ## nginx-deploy.yml 
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      creationTimestamp: null
      labels:
        app: nginx-deploy
      name: nginx-deploy
    spec:
      replicas: 4
      selector:
        matchLabels:
          app: nginx-deploy
      strategy:
        type: RollingUpdate
        rollingUpdate:
          maxUnavailable: 2
          maxSurge: 1
      template:
        metadata:
          creationTimestamp: null
          labels:
            app: nginx-deploy
        spec:
          containers:
          - image: nginx:1.16
            name: nginx
            resources: {}
    status: {}
    ```
    ```bash
    controlplane ~ ➜ k apply -f nginx-deploy.yml 
    deployment.apps/nginx-deploy created

    controlplane ~ ➜  k get deployments.apps 
    NAME           READY   UP-TO-DATE   AVAILABLE   AGE
    nginx-deploy   4/4     4            4           30s
    ```

    Now upgrade the image: 

    ```bash
    controlplane ~ ✦ ➜  k edit deployments.apps nginx-deploy 
    deployment.apps/nginx-deploy edited
    ```
    ```bash
        spec:
        containers:
        - image: nginx:1.17
    ```
    
    ```bash
    controlplane ~ ✦ ➜  k describe deployments.apps nginx-deploy | grep -i image
        Image:        nginx:1.17
    ```
    ```bash
    controlplane ~ ✦ ➜  k rollout undo deployment nginx-deploy 
    deployment.apps/nginx-deploy rolled back

    controlplane ~ ✦ ➜  k describe deployments.apps nginx-deploy | grep -i image
        Image:        nginx:1.16
    ```

    </details>
    </br>


5. Create a redis deployment with the following parameters:

    - Name of the deployment should be redis using the redis:alpine image. It should have exactly 1 replica.

    - The container should request for .2 CPU. It should use the label app=redis.

    It should mount exactly 2 volumes.

    - An Empty directory volume called data at path /redis-master-data.

    - A configmap volume called redis-config at path /redis-master.

    - The container should expose the port 6379.


    The configmap has already been created.


    ```bash
    controlplane ~ ➜  k get cm
    NAME               DATA   AGE
    kube-root-ca.crt   1      128m
    redis-config       1      7m10s 

    controlplane ~ ➜  k get cm redis-config  -o yaml
    apiVersion: v1
    data:
    redis-config: |
        maxmemory 2mb
        maxmemory-policy allkeys-lru
    kind: ConfigMap
    metadata:
    creationTimestamp: "2024-01-06T08:32:05Z"
    name: redis-config
    namespace: default
    resourceVersion: "10206"
    uid: a378978a-d271-46dc-89e4-ea8d22551471
    ```

    <details><summary> Answer </summary>

    ```yaml 
    ## redis.yml 
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      creationTimestamp: null
      labels:
        app: redis
      name: redis
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: redis
      strategy: {}
      template:
        metadata:
          creationTimestamp: null
          labels:
            app: redis
        spec:
          containers:
          - image: redis:alpine
            name: redis
            resources:
              limits:
                cpu: "1"
              requests:
                cpu: "0.2"
            ports:
            - containerPort: 6379
            volumeMounts:
            - name: data
              mountPath: /redis-master-data
            - name: redis-config
              mountPath: /redis-master
          volumes:
          - name: data
            emptyDir: {}
          - name: redis-config
            configMap:
            name: redis-config
    status: {}
    ```
    
    ```bash
    controlplane ~ ✦ ➜  k get po
    NAME                           READY   STATUS    RESTARTS   AGE
    logger                         1/1     Running   0          24m
    nginx-deploy-dcbd487f9-47592   1/1     Running   0          6m16s
    nginx-deploy-dcbd487f9-9r8tc   1/1     Running   0          6m19s
    nginx-deploy-dcbd487f9-r6tqp   1/1     Running   0          6m19s
    nginx-deploy-dcbd487f9-srmtx   1/1     Running   0          6m19s
    redis-77c4ffc68c-n4ndn         1/1     Running   0          46s
    secure-pod                     1/1     Running   0          22m
    webapp-color                   1/1     Running   0          29m

    controlplane ~ ✦ ➜  k describe po redis-77c4ffc68c-n4ndn | grep -A 10 Mounts:
        Mounts:
        /redis-master from redis-config (rw)
        /redis-master-data from data (rw)
        /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-csrv6 (ro)

    controlplane ~ ➜  k describe po redis-77c4ffc68c-n4ndn | grep -A 10 Volumes
    Volumes:
    data:
        Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
        Medium:     
        SizeLimit:  <unset>
    redis-config:
        Type:      ConfigMap (a volume populated by a ConfigMap)
        Name:      redis-config
        Optional:  false
    kube-api-access-csrv6:
        Type:                    Projected (a volume that contains injected data from multiple sources)      
    ```
    
    </details>
    </br>





6. We have deployed a few pods in this cluster in various namespaces. Inspect them and identify the pod which is not in a Ready state. Troubleshoot and fix the issue.

    Next, add a check to restart the container on the same pod if the command ls /var/www/html/file_check fails. This check should start after a delay of 10 seconds and run every 60 seconds.

    ```bash
    controlplane ~ ➜  k get po -n dev1401
    NAME        READY   STATUS    RESTARTS   AGE
    nginx1401   0/1     Running   0          30m
    pod-kab87   1/1     Running   0          30m 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get -n dev1401 po nginx1401 -o yaml > nginx1401.yml

    controlplane ~ ✖ k delete po -n dev1401 nginx1401 $now
    Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
    pod "nginx1401" force deleted

    controlplane ~ ➜  k get po -n dev1401
    NAME        READY   STATUS    RESTARTS   AGE
    pod-kab87   1/1     Running   0          36m
    ```
    ```bash
    ## nginx1401.yml 
    apiVersion: v1
    kind: Pod
    metadata:
      labels:
        run: nginx
      name: nginx1401
      namespace: dev1401
    spec:
      containers:
      - image: kodekloud/nginx
        imagePullPolicy: IfNotPresent
        name: nginx
        ports:
        - containerPort: 9080
          protocol: TCP
        readinessProbe:
          httpGet:
            path: /
            port: 9080
            scheme: HTTP
        periodSeconds: 10
        successThreshold: 1
        timeoutSeconds: 1
        livenessProbe:
          exec:
            command:
            - ls 
            - /var/www/html/file_check
        initialDelaySeconds: 10
        periodSeconds: 60
    ```
    ```bash
    controlplane ~ ➜  k apply -f nginx1401.yml 
    pod/nginx1401 created

    controlplane ~ ➜  k get po -n dev1401
    NAME        READY   STATUS    RESTARTS   AGE
    nginx1401   1/1     Running   0          21s
    pod-kab87   1/1     Running   0          36m
    ```

    </details>
    </br>



7. Create a cronjob called dice that runs every one minute. Use the Pod template located at /root/throw-a-dice. The image throw-dice randomly returns a value between 1 and 6. The result of 6 is considered success and all others are failure.

    - The job should be non-parallel and complete the task once. Use a backoffLimit of 25.

    - If the task is not completed within 20 seconds the job should fail and pods should be terminated.

    <details><summary> Answer </summary>
    
    ```yaml
    ## cron-dice.yml 
    apiVersion: batch/v1
    kind: CronJob
    metadata:
      name: dice
    spec:
      schedule: "1 * * * *"
      jobTemplate:
        spec:
          backoffLimit: 25
          activeDeadlineSeconds: 20
          template:
            spec:
              containers:
              - name: dice
                image: throw-dice
                imagePullPolicy: IfNotPresent
              restartPolicy: Never
    ```
    ```bash
    controlplane ~ ➜  k apply -f  cron-dice.yml 
    cronjob.batch/dice created

    controlplane ~ ➜  k get cj
    NAME   SCHEDULE    SUSPEND   ACTIVE   LAST SCHEDULE   AGE
    dice   1 * * * *   False     0        <none>          13s 
    ```
    
    </details>
    </br>



8. Create a pod called my-busybox in the dev2406 namespace using the busybox image. The container should be called secret and should sleep for 3600 seconds.

    - The container should mount a read-only secret volume called secret-volume at the path /etc/secret-volume. 
    
    - The secret being mounted has already been created for you and is called dotfile-secret.

    - Make sure that the pod is scheduled on controlplane and no other node in the cluster.

    <details><summary> Answer </summary>
    
    Check the labels of the controlplane first. We'll use this label as nodeSelector for the pod. 

    ```bash
    controlplane ~ ➜  k get no controlplane --show-labels 
    NAME           STATUS   ROLES           AGE   VERSION   LABELS
    controlplane   Ready    control-plane   29m   v1.27.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=controlplane,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node.kubernetes.io/exclude-from-external-load-balancers=
    ```
    ```yaml 
    ## my-busybox.yml 
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: null
      labels:
        run: my-busybox
      name: my-busybox
      namespace: dev2406
    spec:
      nodeSelector:
        kubernetes.io/hostname: controlplane
      containers:
      - image: busybox
        name: secret
        resources: {}
        command:
        - sleep
        - "3600"
        volumeMounts:
        - name: secret-volume
          mountPath: /etc/secret-volume
          readOnly: true
      volumes:
      - name: secret-volume
        secret:
        secretName: dotfile-secret
      dnsPolicy: ClusterFirst
      restartPolicy: Always
    status: {}
    ```
    
    ```bash
    controlplane ~ ➜  k apply -f my-busybox.yml 
    pod/my-busybox created

    controlplane ~ ➜  k get -n dev2406 po -o wide
    NAME          READY   STATUS    RESTARTS   AGE   IP             NODE           NOMINATED NODE   READINESS GATES
    my-busybox    1/1     Running   0          18s   10.244.0.5     controlplane   <none>           <none>
    nginx2406     1/1     Running   0          21m   10.244.192.3   node01         <none>           <none>
    pod-var2016   1/1     Running   0          21m   10.244.192.5   node01         <none>           <none>
    ```
    
    </details>
    </br>

9. Create a single ingress resource called ingress-vh-routing. The resource should route HTTP traffic to multiple hostnames as specified below:

    - The service video-service should be accessible on http://watch.ecom-store.com:30093/video

    - The service apparels-service should be accessible on http://apparels.ecom-store.com:30093/wear

    - Here 30093 is the port used by the Ingress Controller

    ```bash
    controlplane ~ ➜  k get po | grep web
    webapp-apparels-56b6df9d5f-nrps8   1/1     Running     0          3m32s
    webapp-color                       1/1     Running     0          25m
    webapp-video-55fcd88897-ljnpg      1/1     Running     0          3m32s

    controlplane ~ ➜  k get svc
    NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
    apparels-service   ClusterIP   10.98.253.224   <none>        8080/TCP   3m35s
    kubernetes         ClusterIP   10.96.0.1       <none>        443/TCP    37m
    video-service      ClusterIP   10.104.57.104   <none>        8080/TCP   3m35s 
    ```


    <details><summary> Answer </summary>
    
    There is a trick here, specifically on the port used. The port 30093 is the port used by the Ingress Controller, but we should not specify it in the Ingress resource. Instead, we use the port specified in the service, which is 8080. 

    ```bash
    controlplane ~ ➜  k get svc
    NAME               TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
    apparels-service   ClusterIP   10.99.206.59   <none>        8080/TCP   9m14s
    kubernetes         ClusterIP   10.96.0.1      <none>        443/TCP    41m
    video-service      ClusterIP   10.107.72.29   <none>        8080/TCP   9m14s 
    ```

    The port numbers specified in the YAML file represent the target ports of the backend services, not the port used by the Ingress Controller itself. 

    - If the services (video-service and apparels-service) are running on port 8080 within Kubernetes cluster, then we should keep the port field as number: 8080.

    - The port field under each backend service does not refer to the external port used by the Ingress Controller. 

    - The external port (the one accessed from outside the cluster) is determined by the configuration of the Ingress Controller. 

    Create the YAML file. 

    ```yaml
    ## ingress-vh-routing.yml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: ingress-vh-routing
    spec:
      rules:
      - host: "watch.ecom-store.com"
        http:
          paths:
          - pathType: Prefix
            path: "/video"
            backend:
              service:
                name: video-service
                port:
                  number: 8080
      - host: "apparels.ecom-store.com"
        http:
          paths:
          - pathType: Prefix
            path: "/wear"
            backend:
              service:
                name: apparels-service
                port:
                  number: 8080
    ```
    
    ```bash
    controlplane ~ ➜  k apply -f  ingress-vh-routing.yml 
    ingress.networking.k8s.io/ingress-vh-routing created

    controlplane ~ ➜  k get ing
    NAME                 CLASS    HOSTS                                          ADDRESS   PORTS   AGE
    ingress-vh-routing   <none>   watch.ecom-store.com,apparels.ecom-store.com             80      6s

    controlplane ~ ➜  k describe ingress ingress-vh-routing 
    Name:             ingress-vh-routing
    Labels:           <none>
    Namespace:        default
    Address:          
    Ingress Class:    <none>
    Default backend:  <default>
    Rules:
    Host                     Path  Backends
    ----                     ----  --------
    watch.ecom-store.com     
                            /video   video-service:8080 (10.244.192.13:8080)
    apparels.ecom-store.com  
                            /wear   apparels-service:8080 (10.244.192.14:8080)
    Annotations:               nginx.ingress.kubernetes.io/rewrite-target: /
    Events:
    Type    Reason  Age   From                      Message
    ----    ------  ----  ----                      -------
    Normal  Sync    15s   nginx-ingress-controller  Scheduled for sync
    ```
    </details>
    </br>


10. A pod called dev-pod-dind-878516 has been deployed in the default namespace. Inspect the logs for the container called log-x and redirect the warnings to /opt/dind-878516_logs.txt on the controlplane node.

    ```bash
    controlplane ~ ➜  k get po 
    NAME                               READY   STATUS      RESTARTS   AGE
    dev-pod-dind-878516                3/3     Running     0          28m 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k logs dev-pod-dind-878516 -c log-x > /opt/dind-878516_logs.txt

    controlplane ~ ➜  ls -l /opt/
    total 204
    drwxr-xr-x 1 root root   4096 Nov  2 11:33 cni
    drwx--x--x 4 root root   4096 Nov  2 11:33 containerd
    -rw-r--r-- 1 root root 192493 Jan  6 05:35 dind-878516_logs.txt
    drwxr-xr-x 2 root root   4096 Jan  6 05:05 outputs
    ```
    
    </details>
    </br>



11. Create a service messaging-service to expose the redis deployment in the marketing namespace within the cluster on port 6379.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k expose -n marketing deploy redis --name messaging-service --port 6379 --type ClusterIP --target-port 6379 $do
    apiVersion: v1
    kind: Service
    metadata:
    creationTimestamp: null
    name: messaging-service
    namespace: marketing
    spec:
    ports:
    - port: 6379
        protocol: TCP
        targetPort: 6379
    selector:
        name: redis-pod
    type: ClusterIP
    status:
    loadBalancer: {}

    controlplane ~ ➜  k expose -n marketing deploy redis --name messaging-service --port 6379 --type ClusterIP --target-port 6379 
    service/messaging-service exposed

    controlplane ~ ➜  k get -n marketing po
    NAME                     READY   STATUS    RESTARTS   AGE
    redis-798b49c867-82n5n   1/1     Running   0          5m28s

    controlplane ~ ➜  k get -n marketing svc
    NAME                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
    messaging-service   ClusterIP   10.111.52.207   <none>        6379/TCP   21s
    ```
    
    </details>
    </br>

12. Create a new ConfigMap named cm-3392845. Use the spec given on the below.

    - Data: DB_NAME=SQL3322

    - Data: DB_HOST=sql322.mycompany.com

    - Data: DB_PORT=3306


    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k create cm cm-3392845 $do 
    apiVersion: v1
    kind: ConfigMap
    metadata:
    creationTimestamp: null
    name: cm-3392845

    controlplane ~ ➜  k create cm cm-3392845 $do > cm-3392845.yml
    ```
    
    ```yaml
    ## cm-3392845.yml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      creationTimestamp: null
      name: cm-3392845
    data:
      DB_NAME: "SQL3322"
      DB_HOST: "sql322.mycompany.com"
      DB_PORT: "3306"
    ```
    
    ```bash
    controlplane ~ ➜  k apply -f cm-3392845.yml 
    configmap/cm-3392845 created

    controlplane ~ ➜  k get cm
    NAME               DATA   AGE
    cm-3392845         3      6s
    kube-root-ca.crt   1      43m
    ```
    
    </details>
    </br>


13. Create a new Secret named db-secret-xxdf with the data given (on the below).

    - Secret Name: db-secret-xxdf

    - Secret 1: DB_Host=sql01

    - Secret 2: DB_User=root

    - Secret 3: DB_Password=password123


    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k create secret generic db-secret-xxdf --from-literal DB_Host=sql01 --from-literal DB_User=root --from-literal DB_Password=password123 $do
    
    apiVersion: v1
    data:
      DB_Host: c3FsMDE=
      DB_Password: cGFzc3dvcmQxMjM=
      DB_User: cm9vdA==
    kind: Secret
    metadata:
      creationTimestamp: null
      name: db-secret-xxdf

    controlplane ~ ➜  k create secret generic db-secret-xxdf --from-literal DB_Host=sql01 --from-literal DB_User=root --from-literal DB_Password=password123secret/db-secret-xxdf created

    controlplane ~ ➜  k get secrets 
    NAME             TYPE     DATA   AGE
    db-secret-xxdf   Opaque   3      4s

    controlplane ~ ➜  k describe secrets db-secret-xxdf 
    Name:         db-secret-xxdf
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




14. Update pod app-sec-kff3345 to run as Root user and with the SYS_TIME capability.


    ```bash
    controlplane ~ ➜  k get po
    NAME              READY   STATUS    RESTARTS   AGE
    app-sec-kff3345   1/1     Running   0          14m 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po app-sec-kff3345 -o yaml > app-sec-kff3345.yml
    controlplane ~ ➜  k delete po app-sec-kff3345 $now
    ```
    
    ```yaml
    ## app-sec-kff3345.yml
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: "2024-01-06T11:26:56Z"
      name: app-sec-kff3345
      namespace: default
      resourceVersion: "4432"
      uid: 6eee9699-6c12-4e8f-b579-0d2b19081d34
    spec:
      securityContext:
        runAsUser: 0
      containers:
      - command:
        - sleep
        - "4800"
        image: ubuntu
        imagePullPolicy: Always
        securityContext:
          capabilities:
            add: ["SYS_TIME"]
    ```

    ```bash
    controlplane ~ ➜  k apply -f app-sec-kff3345.yml 
    pod/app-sec-kff3345 created

    controlplane ~ ➜  k get po
    NAME                              READY   STATUS    RESTARTS   AGE
    app-sec-kff3345                   1/1     Running   0          3s 

    controlplane ~ ➜  k exec -it app-sec-kff3345 -- whoami
    root
    ```
    
    </details>
    </br>




15. Create a redis deployment using the image redis:alpine with 1 replica and label app=redis. Expose it via a ClusterIP service called redis on port 6379. Create a new Ingress Type NetworkPolicy called redis-access which allows only the pods with label access=redis to access the deployment.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k create deployment redis --image redis:alpine --replicas 1 $do
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      creationTimestamp: null
      labels:
        app: redis
      name: redis
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: redis
      strategy: {}
      template:
        metadata:
          creationTimestamp: null
          labels:
            app: redis
        spec:
          containers:
          - image: redis:alpine
            name: redis
            resources: {}
    status: {}

    controlplane ~ ➜  k create deployment redis --image redis:alpine --replicas 1 $do > redis.yml
    ```
    ```yaml
    ## redis.yml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      creationTimestamp: null
      labels:
        app: redis
      name: redis
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: redis
      strategy: {}
      template:
        metadata:
          creationTimestamp: null
          labels:
            app: redis
        spec:
          containers:
          - image: redis:alpine
            name: redis
            resources: {}
    status: {}
    ```
    ```bash
    controlplane ~ ➜  k apply -f redis.yml 
    deployment.apps/redis created

    controlplane ~ ➜  k get deployments.apps 
    NAME             READY   UP-TO-DATE   AVAILABLE   AGE
    httpd-frontend   3/3     3            3           20m
    redis            1/1     1            1           3s

    controlplane ~ ➜  k get po | grep redis
    redis-78d4b8b77c-8gq9f            1/1     Running   0          9s
    ```
    
    ```bash
    controlplane ~ ➜  k expose deployment redis --name redis --type ClusterIP --port 6379 --target-port 6379 $do
    apiVersion: v1
    kind: Service
    metadata:
      creationTimestamp: null
      labels:
        app: redis
      name: redis
    spec:
      ports:
      - port: 6379
        protocol: TCP
        targetPort: 6379
      selector:
        app: redis
      type: ClusterIP
    status:
    loadBalancer: {}

    controlplane ~ ➜  k expose deployment redis --name redis --type ClusterIP --port 6379 --target-port 6379
    service/redis exposed

    controlplane ~ ➜  k get svc
    NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
    kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP    58m
    redis        ClusterIP   10.108.162.236   <none>        6379/TCP   3s
    ```
    ```yaml
    ## netpol.yml 
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: redis-access
      namespace: default
    spec:
      podSelector:
        matchLabels:
          app: redis
      policyTypes:
      - Ingress
      ingress:
      - from:
        - podSelector:
            matchLabels:
              access: redis
        ports:
        - protocol: TCP
        port: 6379
    ```
    ```bash
    controlplane ~ ➜  k apply -f netpol.yml 
    networkpolicy.networking.k8s.io/redis-access created

    controlplane ~ ➜  k get netpol
    NAME           POD-SELECTOR   AGE
    redis-access   <none>         3s
    ```
    
    </details>
    </br>


16. Create a Pod called sega with two containers:

    - Container 1: Name tails with image busybox and command: sleep 3600.
    - Container 2: Name sonic with image nginx and Environment variable: NGINX_PORT with the value 8080.


    <details><summary> Answer </summary>
    
    ```yaml
    controlplane ~ ➜  k run sega --image busybox $do
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: null
      labels:
        run: sega
      name: sega
    spec:
      containers:
      - image: busybox
        name: sega
        resources: {}
      dnsPolicy: ClusterFirst
      restartPolicy: Always
    status: {}

    controlplane ~ ➜  k run sega --image busybox $do > sega.yml
    ```
    ```bash
    ## sega.yml 

    ```
    ```bash
    controlplane ~ ➜  k apply -f sega.yml 
    pod/sega created

    controlplane ~ ➜  k get po
    NAME                              READY   STATUS    RESTARTS   AGE
    app-sec-kff3345                   1/1     Running   0          16m
    httpd-frontend-5497fbb8f6-47zbb   1/1     Running   0          32m
    httpd-frontend-5497fbb8f6-hpzpn   1/1     Running   0          32m
    httpd-frontend-5497fbb8f6-xvc7b   1/1     Running   0          32m
    messaging                         1/1     Running   0          31m
    nginx-448839                      1/1     Running   0          32m
    redis-78d4b8b77c-8gq9f            1/1     Running   0          11m
    rs-d33393-2pnq4                   1/1     Running   0          29m
    rs-d33393-jnkb8                   1/1     Running   0          29m
    rs-d33393-mf62t                   1/1     Running   0          29m
    rs-d33393-z2782                   1/1     Running   0          29m
    sega                              2/2     Running   0          46s
    webapp-color                      1/1     Running   0          26m
    ```

    
    </details>
    </br>




17. Add a taint to the node node01 of the cluster. Use the specification below:

    - key: app_type
    - value: alpha
    - effect: NoSchedule

    Create a pod called alpha, image: redis with toleration to node01.


    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k taint node node01 app_type=alpha:NoSchedule
    node/node01 tainted

    controlplane ~ ➜  k describe no node01 | grep -i taint
    Taints:             app_type=alpha:NoSchedule
    ```
    
    ```yaml
    ## alpha.yml 
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: null
      labels:
        run: alpha
      name: alpha
    spec:
      tolerations:
      - key: "app_type"
        operator: "Equal"
        value: "alpha"
        effect: "NoSchedule"
      containers:
      - image: redis
        name: alpha
        resources: {}
      dnsPolicy: ClusterFirst
      restartPolicy: Always
    status: {}
    ```
    
    ```bash
    controlplane ~ ➜  k apply -f alpha.yml

    controlplane ~ ➜  k get po -o wide
    NAME                         READY   STATUS    RESTARTS   AGE    IP             NODE           NOMINATED NODE   READINESS GATES
    alpha                        1/1     Running   0          7s     10.244.192.2   node01         <none>           <none>
    my-webapp-54b7444d85-79rl7   1/1     Running   0          7m5s   10.244.0.4     controlplane   <none>           <none>
    my-webapp-54b7444d85-dls5v   1/1     Running   0          7m5s   10.244.192.1   node01         <none>           <none>
    ```
    
    </details>
    </br>   




18. Apply a label app_type=beta to node controlplane. Create a new deployment called beta-apps with image: nginx and replicas: 3. Set Node Affinity to the deployment to place the PODs on controlplane only.

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS   ROLES           AGE   VERSION
    controlplane   Ready    control-plane   28m   v1.27.0
    node01         Ready    <none>          27m   v1.27.0 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get no --show-labels 
    NAME           STATUS   ROLES           AGE   VERSION   LABELS
    controlplane   Ready    control-plane   28m   v1.27.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=controlplane,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node.kubernetes.io/exclude-from-external-load-balancers=

    controlplane ~ ➜  k label nodes controlplane app_type=beta
    node/controlplane labeled

    controlplane ~ ➜  k get no controlplane --show-labels 
    NAME           STATUS   ROLES           AGE   VERSION   LABELS
    controlplane   Ready    control-plane   29m   v1.27.0   app_type=beta,beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=controlplane,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node.kubernetes.io/exclude-from-external-load-balancers=
    ```
    ```bash
    controlplane ~ ➜  k create deployment beta-apps --image nginx --replicas 3 $do
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      creationTimestamp: null
      labels:
        app: beta-apps
      name: beta-apps
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: beta-apps
      strategy: {}
      template:
        metadata:
          creationTimestamp: null
          labels:
            app: beta-apps
        spec:
          containers:
          - image: nginx
            name: nginx
            resources: {}
    status: {}

    controlplane ~ ➜  k create deployment beta-apps --image nginx --replicas 3 $do > nginx.yml
    ```
    ```yaml
    ## nginx.yml 
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      creationTimestamp: null
      labels:
        app: beta-apps
      name: beta-apps
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: beta-apps
      strategy: {}
      template:
        metadata:
          creationTimestamp: null
          labels:
            app: beta-apps
        spec:
          affinity:
            nodeAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                - matchExpressions:
                  - key: app_type
                    operator: In
                    values:
                    - beta
          containers:
          - image: nginx
            name: nginx
            resources: {}
    status: {}
    ```
    ```bash
    controlplane ~ ➜  k get deployments.apps 
    NAME        READY   UP-TO-DATE   AVAILABLE   AGE
    beta-apps   3/3     3            3           17s
    my-webapp   2/2     2            2           14m

    controlplane ~ ➜  k get po -o wide | grep beta
    beta-apps-574fd8858c-2m8zj   1/1     Running   0          48s     10.244.0.7     controlplane   <none>           <none>
    beta-apps-574fd8858c-chc5d   1/1     Running   0          48s     10.244.0.6     controlplane   <none>           <none>
    beta-apps-574fd8858c-nlbh8   1/1     Running   0          48s     10.244.0.5     controlplane   <none>           <none>
    ```
    
    </details>
    </br>



19. Create a new Ingress Resource for the service my-video-service to be made available at the URL: http://ckad-mock-exam-solution.com:30093/video.

    To create an ingress resource, the following details are: -

    - annotation: nginx.ingress.kubernetes.io/rewrite-target: /

    - host: ckad-mock-exam-solution.com

    - path: /video

    Once set up, the curl test of the URL from the nodes should be successful: HTTP 200

    ```bash
    controlplane ~ ➜  k get po | grep video
    webapp-video-55fcd88897-h49ft   1/1     Running   0          114s

    controlplane ~ ➜  k get svc
    NAME                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
    front-end-service   NodePort    10.99.121.208   <none>        80:30083/TCP   15m
    kubernetes          ClusterIP   10.96.0.1       <none>        443/TCP        35m
    my-video-service    ClusterIP   10.106.189.83   <none>        8080/TCP       116s 
    ```

    <details><summary> Answer </summary>
    
    ```yaml
    ## ingress.yml 
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: ingress-wildcard-host
      annotations: 
        nginx.ingress.kubernetes.io/rewrite-target: /
    spec:
      rules:
      - host: "ckad-mock-exam-solution.com"
        http:
          paths:
          - pathType: Prefix
            path: "/video"
            backend:
              service:
                name: my-video-service
                port:
                  number: 8080
    ```
    ```bash
    controlplane ~ ➜  k apply -f  ingress.yml 
    ingress.networking.k8s.io/ingress-wildcard-host created

    controlplane ~ ➜  k get ing
    NAME                    CLASS    HOSTS                         ADDRESS   PORTS   AGE
    ingress-wildcard-host   <none>   ckad-mock-exam-solution.com             80      3s

    controlplane ~ ➜  k describe ingress ingress-wildcard-host 
    Name:             ingress-wildcard-host
    Labels:           <none>
    Namespace:        default
    Address:          
    Ingress Class:    <none>
    Default backend:  <default>
    Rules:
    Host                         Path  Backends
    ----                         ----  --------
    ckad-mock-exam-solution.com  
                                /video   my-video-service:8080 (10.244.0.8:8080)
    Annotations:                   nginx.ingress.kubernetes.io/rewrite-target: /
    Events:
    Type    Reason  Age   From                      Message
    ----    ------  ----  ----                      -------
    Normal  Sync    12s   nginx-ingress-controller  Scheduled for sync 

    controlplane ~ ➜  curl -I http://ckad-mock-exam-solution.com:30093/video
    HTTP/1.1 200 OK
    Date: Sat, 06 Jan 2024 12:23:10 GMT
    Content-Type: text/html; charset=utf-8
    Content-Length: 293
    Connection: keep-alive  
    ```
    
    </details>
    </br>



20. We have deployed a new pod called pod-with-rprobe. This Pod has an initial delay before it is Ready. Update the newly created pod pod-with-rprobe with a readinessProbe using the given spec

    - httpGet path: /ready

    - httpGet port: 8080

    ```bash
    controlplane ~ ➜  k get po
    NAME                            READY   STATUS    RESTARTS   AGE
    alpha                           1/1     Running   0          15m
    beta-apps-574fd8858c-2m8zj      1/1     Running   0          8m21s
    beta-apps-574fd8858c-chc5d      1/1     Running   0          8m21s
    beta-apps-574fd8858c-nlbh8      1/1     Running   0          8m21s
    my-webapp-54b7444d85-79rl7      1/1     Running   0          22m
    my-webapp-54b7444d85-dls5v      1/1     Running   0          22m
    pod-with-rprobe                 1/1     Running   0          28s
    webapp-video-55fcd88897-h49ft   1/1     Running   0          7m15s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po pod-with-rprobe -o yaml > podprobe.yml

    controlplane ~ ➜  k delete po pod-with-rprobe $now
    Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
    pod "pod-with-rprobe" force deleted

    ```
    
    ```yaml
    ## podprobe.yml 
    apiVersion: v1
    kind: Pod
    metadata:
      labels:
        name: pod-with-rprobe
      name: pod-with-rprobe
      namespace: default
    spec:
      containers:
      - env:
        - name: APP_START_DELAY
          value: "180"
        image: kodekloud/webapp-delayed-start
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 3
          periodSeconds: 3
        imagePullPolicy: Always
        name: pod-with-rprobe
        ports:
        - containerPort: 8080
          protocol: TCP
    ```
    
    ```bash
    controlplane ~ ➜  k apply -f podprobe.yml 
    pod/pod-with-rprobe created

    controlplane ~ ➜  k get po
    NAME                            READY   STATUS    RESTARTS   AGE
    alpha                           1/1     Running   0          19m
    beta-apps-574fd8858c-2m8zj      1/1     Running   0          12m
    beta-apps-574fd8858c-chc5d      1/1     Running   0          12m
    beta-apps-574fd8858c-nlbh8      1/1     Running   0          12m
    my-webapp-54b7444d85-79rl7      1/1     Running   0          26m
    my-webapp-54b7444d85-dls5v      1/1     Running   0          26m
    pod-with-rprobe                 1/1     Running   0          33s
    webapp-video-55fcd88897-h49ft   1/1     Running   0          11m 
    ```
    
    </details>
    </br>



21. Create a new pod called nginx1401 in the default namespace with the image nginx. Add a livenessProbe to the container to restart it if the command ls /var/www/html/probe fails. This check should start after a delay of 10 seconds and run every 60 seconds.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k run nginx1401 --image nginx $do 
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: null
      labels:
        run: nginx1401
      name: nginx1401
    spec:
      containers:
      - image: nginx
        name: nginx1401
        resources: {}
      dnsPolicy: ClusterFirst
      restartPolicy: Always
    status: {}

    controlplane ~ ➜  k run nginx1401 --image nginx $do  > nginx1401.yml
    ```
    
    ```yaml
    ## nginx1401.yml
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: null
      labels:
        run: nginx1401
      name: nginx1401
    spec:
      containers:
      - image: nginx
        name: nginx1401
        livenessProbe:
          exec:
            command:
            - ls
            - /var/www/html/probe
          initialDelaySeconds: 10
          periodSeconds: 60
        resources: {}
      dnsPolicy: ClusterFirst
      restartPolicy: Always
    status: {}
    ```
    
    ```bash
    controlplane ~ ➜  k apply -f nginx
    pod/nginx1401 created 
    ```
    
    
    </details>
    </br>


22. Create a job called whalesay with image docker/whalesay and command "cowsay I am going to ace CKAD!".

    - completions: 10

    - backoffLimit: 6

    - restartPolicy: Never


    <details><summary> Answer </summary>
    
    ```yaml
    ## job.yml 
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: whalesay
    spec:
      completions: 10
      backoffLimit: 6
      template:
        metadata:
          creationTimestamp: null
        spec:
          containers:
          - command:
            - sh 
            - -c
            - "cowsay I am going to ace CKAD!"
            image: docker/whalesay
            name: whalesay
          restartPolicy: Never
    ```
    
    ```bash
    k apply -f job.yml
    ```
    
    </details>
    </br>



[Back to the top](#practice-test-ckad)    

