
# Practice Test: CKA 

> *Some of the scneario questions here are based on Kodekloud's [CKA course labs](https://kodekloud.com/courses/ultimate-certified-kubernetes-administrator-cka-mock-exam/).*


- [Pods](#pods)
- [ReplicaSets](#replicasets)
- [Deployments](#deployments)
- [Namespaces](#namespaces)
- [Services](#services)
- [Scheduling](#scheduling)
- [Labels and Selectors](#labels-and-selectors)
- [Taints and Tolerations](#taints-and-tolerations)
- [Node Affinity](#node-affinity)


## Pods 

1. Create a new pod with the nginx image.

    <details><summary> Answer </summary>

    ```bash
    k run nginx --image=nginx  
    k get po
    ```

    </details>
    <br>

2. What is the state of the container agentx in the pod webapp?

    ```bash
    controlplane ~ ➜  k get po
    NAME            READY   STATUS             RESTARTS   AGE
    nginx           1/1     Running            0          16m
    newpods-vwgw4   1/1     Running            0          4m58s
    newpods-tkscd   1/1     Running            0          4m58s
    newpods-jc7l5   1/1     Running            0          4m58s
    webapp          1/2     ImagePullBackOff   0          3m41s
    ```

    <details><summary> Answer </summary>

    ```bash 
    controlplane ~ ➜  k describe po webapp | grep agentx -A 5
    agentx:
        Container ID:   
        Image:          agentx
        Image ID:       
        Port:           <none>
        Host Port:      <none>
        State:          Waiting
        Reason:       ImagePullBackOff 
    ``` 
    </details>
    <br>


3. What does the READY column in the output of the kubectl get pods command indicate?

    <details><summary> Answer </summary>

    ```bash
    Running containers in pod/Total containers in pod 
    ```
    </details>
    <br>


4. Delete the webapp Pod.

    <details><summary> Answer </summary>

    ```bash
    k delete po webapp --force --grace-period=0  
    ```
    </details>
    <br>


5. Create a new pod with the name redis and the image redis123. Use a pod-definition YAML file. 

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k run redis --image=redis123 --dry-run=client -o yaml > redis.yml

    controlplane ~ ➜  ls
    redis.yml   

    controlplane ~ ➜  k apply -f redis.yml 
    pod/redis created 

    controlplane ~ ➜  k get po
    NAME            READY   STATUS             RESTARTS   AGE
    redis           0/1     ImagePullBackOff   0          40s
    ```
    </details>
    <br> 

6. Deploy a redis pod using the redis:alpine image with the labels set to tier=db 


    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ✖ k run redis --image="redis:alpine" --labels="tier=db" --dry-run=client
    pod/redis created (dry run)

    controlplane ~ ➜  k run redis --image="redis:alpine" --labels="tier=db" 
    pod/redis created

    controlplane ~ ➜  k get po -o wide
    NAME        READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
    nginx-pod   1/1     Running   0          2m13s   10.42.0.9    controlplane   <none>           <none>
    redis       1/1     Running   0          7s      10.42.0.10   controlplane   <none>           <none>

    controlplane ~ ➜  k describe po redis | grep Label
    Labels:           tier=db    
    ```
    </details>
    <br>

7. A pod definition file nginx.yaml is given. Create a pod using the file.

    ```yaml 
    ---
    apiVersion: v1
    kind: Pod
    metadata:
    name: nginx
    spec:
    containers:
    -  image: nginx
        name: nginx  
    ```

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k apply -f nginx.yaml 
    pod/nginx created

    controlplane ~ ➜  k get po
    NAME    READY   STATUS    RESTARTS   AGE
    nginx   0/1     Pending   0          4s    
    ```
    </details>


## ReplicaSets 

1. What is the image used to create the pods in the new-replica-set?

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get po
    NAME                    READY   STATUS             RESTARTS   AGE
    new-replica-set-988qh   0/1     ImagePullBackOff   0          84s
    new-replica-set-b4blf   0/1     ImagePullBackOff   0          84s
    new-replica-set-fqlg2   0/1     ImagePullBackOff   0          84s
    new-replica-set-9qn8h   0/1     ImagePullBackOff   0          84s

    controlplane ~ ➜  k get rs
    NAME              DESIRED   CURRENT   READY   AGE
    new-replica-set   4         4         0       86s

    controlplane ~ ✖ k describe rs new-replica-set | grep Image
        Image:      busybox777  
    ```
    </details>
    <br>


2. Why do you think the PODs are not ready?

    <details><summary> Answer </summary>

    The image BUSYBOX777 doesn't exist

    ```bash
    controlplane ~ ➜  k get po
    NAME                    READY   STATUS             RESTARTS   AGE
    new-replica-set-fqlg2   0/1     ImagePullBackOff   0          3m39s
    new-replica-set-b4blf   0/1     ImagePullBackOff   0          3m39s
    new-replica-set-9qn8h   0/1     ImagePullBackOff   0          3m39s
    new-replica-set-988qh   0/1     ImagePullBackOff   0          3m39s

    controlplane ~ ➜  k describe po new-replica-set-b4blf | grep Events -A 5
    Events:
    Type     Reason     Age                    From               Message
    ----     ------     ----                   ----               -------
    Normal   Scheduled  3m49s                  default-scheduler  Successfully assigned default/new-replica-set-b4blf to controlplane
    Normal   Pulling    2m16s (x4 over 3m49s)  kubelet            Pulling image "busybox777"
    Warning  Failed     2m15s (x4 over 3m48s)  kubelet            Failed to pull image "busybox777": rpc error: code = Unknown desc = failed to pull and unpack image "docker.io/library/busybox777:latest": failed to resolve reference "docker.io/library/busybox777:latest": pull access denied, repository does not exist or may require authorization: server message: insufficient_scope: authorization failed  
    ```
    </details>
    <br>


3. Create a ReplicaSet using the replicaset-definition-1.yaml file located at /root/. There is an issue with the file, so try to fix it.

    ```yaml
    apiVersion: v1
    kind: ReplicaSet
    metadata:
    name: replicaset-1
    spec:
    replicas: 2
    selector:
        matchLabels:
        tier: frontend
    template:
        metadata:
        labels:
            tier: frontend
        spec:
        containers:
        - name: nginx
            image: nginx
    ```
    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k apply -f replicaset-definition-1.yaml 
    error: resource mapping not found for name: "replicaset-1" namespace: "" from "replicaset-definition-1.yaml": no matches for kind "ReplicaSet" in version "v1"
    ensure CRDs are installed first

    controlplane ~ ✖ k api-resources | grep rep
    replicationcontrollers            rc           v1                                     true         ReplicationController
    replicasets                       rs           apps/v1                                true         ReplicaSet 
    ```

    Fix apiVersion then apply.

    ```bash
    apiVersion: apps/v1
    kind: ReplicaSet
    metadata:
    name: replicaset-1
    spec:
    replicas: 2
    selector:
        matchLabels:
        tier: frontend
    template:
        metadata:
        labels:
            tier: frontend
        spec:
        containers:
        - name: nginx
            image: nginx  
    ```
    ```bash
    controlplane ~ ➜  k apply -f replicaset-definition-1.yaml 
    replicaset.apps/replicaset-1 created

    controlplane ~ ➜  k get rs
    NAME              DESIRED   CURRENT   READY   AGE
    replicaset-1      2         2         0       4s 
    ```
    </details>
    <br>


4. Fix the issue in the replicaset-definition-2.yaml file and create a ReplicaSet using it.

    ```yaml
    apiVersion: apps/v1
    kind: ReplicaSet
    metadata:
    name: replicaset-2
    spec:
    replicas: 2
    selector:
        matchLabels:
        tier: frontend
    template:
        metadata:
        labels:
            tier: nginx
        spec:
        containers:
        - name: nginx
            image: nginx 
    ```

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k apply -f replicaset-definition-2.yaml 
    The ReplicaSet "replicaset-2" is invalid: spec.template.metadata.labels: Invalid value: map[string]string{"tier":"nginx"}: `selector` does not match template `labels`  
    ```

    Fix labels and apply.

    ```bash
    apiVersion: apps/v1
    kind: ReplicaSet
    metadata:
    name: replicaset-2
    spec:
    replicas: 2
    selector:
        matchLabels:
        tier: frontend
    template:
        metadata:
        labels:
            tier: frontend
        spec:
        containers:
        - name: nginx
            image: nginx 
    ```

    ```bash
    controlplane ~ ➜  k apply -f replicaset-definition-2.yaml 
    replicaset.apps/replicaset-2 created

    controlplane ~ ➜  k get rs
    NAME              DESIRED   CURRENT   READY   AGE
    new-replica-set   4         4         0       11m
    replicaset-1      2         2         2       2m22s
    replicaset-2      2         2         2       6s 
    ```
    </details>
    <br>


5. Delete the two newly created ReplicaSets - replicaset-1 and replicaset-2.

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get rs
    NAME              DESIRED   CURRENT   READY   AGE
    new-replica-set   4         4         0       12m
    replicaset-1      2         2         2       3m22s
    replicaset-2      2         2         2       66s

    controlplane ~ ➜  k delete rs replicaset-1
    replicaset.apps "replicaset-1" deleted

    controlplane ~ ➜  k delete rs replicaset-2
    replicaset.apps "replicaset-2" deleted

    controlplane ~ ➜  k get rs
    NAME              DESIRED   CURRENT   READY   AGE
    new-replica-set   4         4         0       12m  
    ```
    </details>
    <br>


6. Fix the original replica set new-replica-set to use the correct busybox image.

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get rs
    NAME              DESIRED   CURRENT   READY   AGE
    new-replica-set   4         4         0       13m

    controlplane ~ ➜  k get rs new-replica-set -o yaml > new-rs.yml

    controlplane ~ ➜  ls
    new-rs.yml                   
    ```
    ```bash
    controlplane ~ ➜  cat new-rs.yml 
    apiVersion: apps/v1
    kind: ReplicaSet
    metadata:
    creationTimestamp: "2023-12-28T14:59:48Z"
    generation: 1
    name: new-replica-set
    namespace: default
    resourceVersion: "952"
    uid: b23fad99-5515-4e17-abb2-0f9524180759
    spec:
    replicas: 4
    selector:
        matchLabels:
        name: busybox-pod
    template:
        metadata:
        creationTimestamp: null
        labels:
            name: busybox-pod
        spec:
        containers:
        - command:
            - sh
            - -c
            - echo Hello Kubernetes! && sleep 3600
            image: busybox777
            imagePullPolicy: Always
            name: busybox-container
            resources: {}
            terminationMessagePath: /dev/termination-log
            terminationMessagePolicy: File
        dnsPolicy: ClusterFirst
        restartPolicy: Always
        schedulerName: default-scheduler
        securityContext: {}
        terminationGracePeriodSeconds: 30
    status:
    fullyLabeledReplicas: 4
    observedGeneration: 1
    replicas: 4 
    ```
    ```bash
    controlplane ~ ➜  k delete -f new-rs.yml 
    replicaset.apps "new-replica-set" deleted

    controlplane ~ ➜  k get po
    No resources found in default namespace.
    ```

    Fix the image used and apply.

    ```bash
    image: busybox 
    ```
    ```bash
    controlplane ~ ➜  k apply -f new-rs.yml 
    replicaset.apps/new-replica-set created

    controlplane ~ ➜  k get rs
    NAME              DESIRED   CURRENT   READY   AGE
    new-replica-set   4         4         4       4s

    controlplane ~ ➜  k get po
    NAME                    READY   STATUS    RESTARTS   AGE
    new-replica-set-kp7m5   1/1     Running   0          7s
    new-replica-set-v6ts5   1/1     Running   0          7s
    new-replica-set-j5k5x   1/1     Running   0          7s
    new-replica-set-tzbrt   1/1     Running   0          7s 
    ```
    </details>
    <br>


7. Scale the ReplicaSet to 5 PODs.

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get rs
    NAME              DESIRED   CURRENT   READY   AGE
    new-replica-set   4         4         4       33s

    controlplane ~ ➜  k edit rs new-replica-set 
    ```
    ```bash
    spec:
    replicas: 5
    ```
    ```bash
    controlplane ~ ➜  k get rs
    NAME              DESIRED   CURRENT   READY   AGE
    new-replica-set   5         5         5       118s 
    ```
    </details>


## Deployments 

1. What is the image used to create the pods in the new deployment?

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get deploy
    NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
    frontend-deployment   0/4     4            0           103s

    controlplane ~ ➜  k get po
    NAME                                   READY   STATUS             RESTARTS   AGE
    frontend-deployment-577494fd6f-kcjjq   0/1     ImagePullBackOff   0          107s
    frontend-deployment-577494fd6f-mth6d   0/1     ImagePullBackOff   0          107s
    frontend-deployment-577494fd6f-8ffvh   0/1     ErrImagePull       0          107s
    frontend-deployment-577494fd6f-4tgk4   0/1     ErrImagePull       0          107s

    controlplane ~ ➜  k describe deploy frontend-deployment | grep Image
        Image:      busybox888  
    ```
    </details>
    <br>


2. Why do you think the deployment is not ready?

    <details><summary> Answer </summary>

    The image BUSYBOX888 doesn't exist

    ```bash
    controlplane ~ ➜  k get deploy
    NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
    frontend-deployment   0/4     4            0           103s

    controlplane ~ ➜  k get po
    NAME                                   READY   STATUS             RESTARTS   AGE
    frontend-deployment-577494fd6f-kcjjq   0/1     ImagePullBackOff   0          107s
    frontend-deployment-577494fd6f-mth6d   0/1     ImagePullBackOff   0          107s
    frontend-deployment-577494fd6f-8ffvh   0/1     ErrImagePull       0          107s
    frontend-deployment-577494fd6f-4tgk4   0/1     ErrImagePull       0          107s  

    controlplane ~ ➜  k describe po frontend-deployment-577494fd6f-kcjjq | grep Events -A 10
    Events:
    Type     Reason     Age                  From               Message
    ----     ------     ----                 ----               -------
    Normal   Scheduled  2m56s                default-scheduler  Successfully assigned default/frontend-deployment-577494fd6f-kcjjq to controlplane
    Normal   Pulling    83s (x4 over 2m55s)  kubelet            Pulling image "busybox888"
    Warning  Failed     83s (x4 over 2m54s)  kubelet            Failed to pull image "busybox888": rpc error: code = Unknown desc = failed to pull and unpack image "docker.io/library/busybox888:latest": failed to resolve reference "docker.io/library/busybox888:latest": pull access denied, repository does not exist or may require authorization: server message: insufficient_scope: authorization failed
    ```
    </details>
    <br>


3. Create a new Deployment using the deployment-definition-1.yaml file located at /root/. There is an issue with the file, so try to fix it.

    ```yaml
    ---
    apiVersion: apps/v1
    kind: deployment
    metadata:
    name: deployment-1
    spec:
    replicas: 2
    selector:
        matchLabels:
        name: busybox-pod
    template:
        metadata:
        labels:
            name: busybox-pod
        spec:
        containers:
        - name: busybox-container
            image: busybox888
            command:
            - sh
            - "-c"
            - echo Hello Kubernetes! && sleep 3600 
    ```
    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k apply -f deployment-definition-1.yaml 
    Error from server (BadRequest): error when creating "deployment-definition-1.yaml": deployment in version "v1" cannot be handled as a Deployment: no kind "deployment" is registered for version "apps/v1" in scheme "k8s.io/apimachinery@v1.27.1-k3s1/pkg/runtime/scheme.go:100" 

    controlplane ~ ✖ k api-resources | grep deploy
    deployments                       deploy       apps/v1                                true         Deployment
    ```

    Fix kind and apply.

    ```bash
    ---
    apiVersion: apps/v1
    kind: Deployment
    ```
    ```bash
    controlplane ~ ➜  k apply -f deployment-definition-1.yaml 
    deployment.apps/deployment-1 created  
    ```

    </details>
    <br>

4. Create a new Deployment with the below attributes using your own deployment definition file.

    - Name: httpd-frontend
    - Replicas: 3
    - Image: httpd:2.4-alpine

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k create deploy httpd-frontend --image="httpd:2.4-alpine" --replicas=3 --dry-run=client
    deployment.apps/httpd-frontend created (dry run)

    controlplane ~ ➜  k create deploy httpd-frontend --image="httpd:2.4-alpine" --replicas=3 --dry-run=client -o yaml > httpd.yml

    controlplane ~ ➜  k apply -f httpd.yml 
    deployment.apps/httpd-frontend created

    controlplane ~ ➜  k get deploy
    NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
    frontend-deployment   0/4     4            0           18m
    deployment-1          0/2     2            0           7m26s
    httpd-frontend        0/3     3            0           5s  
    ```
    </details>
    <br>

5. Create a new deployment called redis-deploy in the dev-ns namespace with the redis image. It should have 2 replicas.

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  export dr="--dry-run=client"

    controlplane ~ ➜  k create deploy redis-deploy --namespace=dev-ns --image=redis --replicas=2 $dr
    deployment.apps/redis-deploy created (dry run)

    controlplane ~ ➜  k create deploy redis-deploy --namespace=dev-ns --image=redis --replicas=2
    deployment.apps/redis-deploy created

    controlplane ~ ➜  k get po -n dev-ns
    NAME                           READY   STATUS    RESTARTS   AGE
    redis-deploy-8b745d48d-f9m8t   1/1     Running   0          6s
    redis-deploy-8b745d48d-vlqg4   1/1     Running   0          6s

    controlplane ~ ➜  k get deploy -n dev-ns
    NAME           READY   UP-TO-DATE   AVAILABLE   AGE
    redis-deploy   2/2     2            2           18s    
    ```
    </details>

## Namespaces

1. How many pods exist in the research namespace? 

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get po -n research
    NAME    READY   STATUS             RESTARTS      AGE
    dna-1   0/1     CrashLoopBackOff   3 (18s ago)   71s
    dna-2   0/1     CrashLoopBackOff   3 (17s ago)   71s
    ```
    </details>
    <br>

2. Create a POD in the finance namespace.
    - Name: redis
    - Image name: redis

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k run redis --image=redis --namespace=finance --dry-run=client
    pod/redis created (dry run)

    controlplane ~ ➜  k run redis --image=redis --namespace=finance
    pod/redis created

    controlplane ~ ➜  k get po -n finance
    NAME      READY   STATUS    RESTARTS   AGE
    payroll   1/1     Running   0          2m19s
    redis     1/1     Running   0          8s   
    ```
    </details>
    <br>

3. Which namespace has the blue pod in it?


    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get po -A | grep blue
    marketing       blue                                     1/1     Running     0              3m14s    
    ```
    </details>
    <br>


4. What DNS name should the Blue application use to access the database db-service in its own namespace - marketing?

    ```bash
    controlplane ~ ➜  k get po -n marketing
    NAME       READY   STATUS    RESTARTS   AGE
    redis-db   1/1     Running   0          5m50s
    blue       1/1     Running   0          5m50s

    controlplane ~ ➜  k get svc -n marketing
    NAME           TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
    blue-service   NodePort   10.43.27.58   <none>        8080:30082/TCP   5m53s
    db-service     NodePort   10.43.187.8   <none>        6379:31378/TCP   5m53s 
    ```

    <details><summary> Answer </summary>

    Since the blue application and the db-service are in the same namespace, we can simply use the service name to access the database.

    ```bash
    db-service 
    ```

    </details>
    <br>

5. What DNS name should the Blue application use to access the database db-service in the dev namespace?

    ```bash
    controlplane ~ ➜  k get po -n marketing
    NAME       READY   STATUS    RESTARTS   AGE
    redis-db   1/1     Running   0          7m11s
    blue       1/1     Running   0          7m11s

    controlplane ~ ➜  k get svc -n dev
    NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
    db-service   ClusterIP   10.43.48.220   <none>        6379/TCP   7m19s 
    ```

    <details><summary> Answer </summary>

    Since the blue application and the db-service are in different namespaces. In this case, we need to use the service name along with the namespace to access the database. The FQDN (fully Qualified Domain Name) for the db-service in this example would be db-service.dev.svc.cluster.local.

    You can also access it using the service name and namespace like this: db-service.dev

    ```bash
    db-service.dev.svc.cluster.local
    ```
    </details>
    <br>

6. Create a new namespace called dev-ns. 

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k create ns dev-ns
    namespace/dev-ns created    

    controlplane ~ ➜  k get ns
    NAME              STATUS   AGE
    kube-system       Active   28m
    default           Active   28m
    kube-public       Active   28m
    kube-node-lease   Active   28m
    dev-ns            Active   49s    
    ```
    </details>
    

## Services 

1. What is the targetPort configured on the kubernetes service? 

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get svc
    NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
    kubernetes   ClusterIP   10.43.0.1    <none>        443/TCP   6m33s

    controlplane ~ ➜  k describe svc kubernetes
    Name:              kubernetes
    Namespace:         default
    Labels:            component=apiserver
                    provider=kubernetes
    Annotations:       <none>
    Selector:          <none>
    Type:              ClusterIP
    IP Family Policy:  SingleStack
    IP Families:       IPv4
    IP:                10.43.0.1
    IPs:               10.43.0.1
    Port:              https  443/TCP
    TargetPort:        6443/TCP
    Endpoints:         192.35.187.6:6443
    Session Affinity:  None
    Events:            <none>    
    ```
    </details>
    <br>

2. Create a new service to access the web application using the service-definition-1.yaml file.

    - Name: webapp-service
    - Type: NodePort
    - targetPort: 8080
    - port: 8080
    - nodePort: 30080
    - selector:
         name: simple-webapp


    <details><summary> Answer </summary>

    Create the file and apply. 

    ```bash
    apiVersion: v1
    kind: Service
    metadata:
      name: webapp-service
    spec:
      type: NodePort
      selector:
        name: simple-webapp
      ports:
      - protocol: TCP
        port: 8080
        targetPort: 8080
        nodePort: 30080
    ```

    ```bash
    controlplane ~ ➜  k apply -f service-definition-1.yaml 
    service/webapp-service created

    controlplane ~ ➜  k get svc -o wide
    NAME             TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE   SELECTOR
    kubernetes       ClusterIP   10.43.0.1     <none>        443/TCP          14m   <none>
    webapp-service   NodePort    10.43.22.35   <none>        8080:30080/TCP   73s   name=simple-webapp 
    ```
    </details>
    <br>


3. Create a service redis-service to expose the redis application within the cluster on port 6379.


    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get deploy
    No resources found in default namespace.

    controlplane ~ ➜  k get po
    NAME        READY   STATUS    RESTARTS   AGE
    nginx-pod   1/1     Running   0          9m28s
    redis       1/1     Running   0          5m42s

    controlplane ~ ➜  k expose po redis --port=6379 --name=redis-service --dry-run=client
    service/redis-service exposed (dry run)

    controlplane ~ ➜  k expose po redis --port=6379 --name=redis-service
    service/redis-service exposed

    controlplane ~ ➜  k get svc
    NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
    kubernetes      ClusterIP   10.43.0.1       <none>        443/TCP    18m
    redis-service   ClusterIP   10.43.109.102   <none>        6379/TCP   5s   
    ```
    </details>
    <br>

4. Create a new pod called custom-nginx using the nginx image and expose it on container port 8080.

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k run custom-nginx --image=nginx --port=8080
    pod/custom-nginx created  
    ```
    </details>
    <br>


5. Create a pod called httpd using the image httpd:alpine in the default namespace. Next, create a service of type ClusterIP by the same name (httpd). The target port for the service should be 80.

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  export dr="--dry-run=client"

    controlplane ~ ➜  k run httpd --image="httpd:alpine"
    pod/httpd created

    controlplane ~ ➜  k get po
    NAME                      READY   STATUS    RESTARTS   AGE
    nginx-pod                 1/1     Running   0          25m
    redis                     1/1     Running   0          21m
    webapp-7fdf67dd49-2swjm   1/1     Running   0          11m
    webapp-7fdf67dd49-rrz5r   1/1     Running   0          11m
    webapp-7fdf67dd49-pkpzx   1/1     Running   0          11m
    custom-nginx              1/1     Running   0          6m13

    controlplane ~ ✖ k expose po httpd --port=80 --type=ClusterIP $dr
    service/httpd exposed (dry run)

    controlplane ~ ➜  k expose po httpd --port=80 --type=ClusterIP
    service/httpd exposed

    controlplane ~ ➜  k get svc
    NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
    kubernetes      ClusterIP   10.43.0.1       <none>        443/TCP    35m
    redis-service   ClusterIP   10.43.109.102   <none>        6379/TCP   17m
    httpd           ClusterIP   10.43.129.55    <none>        80/TCP     6s
    ```
    </details>

## Scheduling 

1. Fix th nginx pod. The YAML file is given. 

    ```bash
    controlplane ~ ➜  k get po
    NAME    READY   STATUS    RESTARTS   AGE
    nginx   0/1     Pending   0          3m18s 
    ```

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
    name: nginx
    spec:
    containers:
    -  image: nginx
        name: nginx  
    ```

    <details><summary> Answer </summary>

    Check the details of all pods, including pods in the kube-system namespace. Here we can see that there is no scheduler pod. Without this scheduler pod, all other pods in the default namespace will remain in pending state forever.

    ```bash
    controlplane ~ ➜  k get po
    NAME    READY   STATUS    RESTARTS   AGE
    nginx   0/1     Pending   0          25s

    controlplane ~ ➜  

    controlplane ~ ➜  k get po -o wide
    NAME    READY   STATUS    RESTARTS   AGE   IP       NODE     NOMINATED NODE   READINESS GATES
    nginx   0/1     Pending   0          31s   <none>   <none>   <none>           <none>

    controlplane ~ ➜  k get po -A -o wide
    NAMESPACE      NAME                                   READY   STATUS    RESTARTS   AGE     IP             NODE           NOMINATED NODE   READINESS GATES
    default        nginx                                  0/1     Pending   0          38s     <none>         <none>         <none>           <none>
    kube-flannel   kube-flannel-ds-hn474                  1/1     Running   0          8m23s   192.38.195.8   node01         <none>           <none>
    kube-flannel   kube-flannel-ds-zvkr9                  1/1     Running   0          8m38s   192.38.195.6   controlplane   <none>           <none>
    kube-system    coredns-5d78c9869d-5nt4f               1/1     Running   0          8m37s   10.244.0.2     controlplane   <none>           <none>
    kube-system    coredns-5d78c9869d-8wwkp               1/1     Running   0          8m37s   10.244.0.3     controlplane   <none>           <none>
    kube-system    etcd-controlplane                      1/1     Running   0          8m52s   192.38.195.6   controlplane   <none>           <none>
    kube-system    kube-apiserver-controlplane            1/1     Running   0          8m53s   192.38.195.6   controlplane   <none>           <none>
    kube-system    kube-controller-manager-controlplane   1/1     Running   0          8m52s   192.38.195.6   controlplane   <none>           <none>
    kube-system    kube-proxy-9qxp8                       1/1     Running   0          8m23s   192.38.195.8   node01         <none>           <none>
    kube-system    kube-proxy-dptpt                       1/1     Running   0          8m38s   192.38.195.6   controlplane   <none>           <none>  
    ```

    Delete pod first and manually schedule on a node. 

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS   ROLES           AGE     VERSION
    controlplane   Ready    control-plane   8m15s   v1.27.0
    node01         Ready    <none>          7m34s   v1.27.0

    controlplane ~ ➜  k delete po nginx
    pod "nginx" deleted

    controlplane ~ ➜  k get po
    No resources found in default namespace.    
    ```

    To manually schedule, modify the YAML file and apply.

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: nginx
    spec:
      nodeName=node01
      containers:
      - image: nginx
        name: nginx  
    ```
    ```bash
    controlplane ~ ➜  k apply -f nginx.yaml 
    pod/nginx created

    controlplane ~ ➜  k get po 
    NAME    READY   STATUS    RESTARTS   AGE
    nginx   1/1     Running   0          8s  
    ```

    </details>


## Labels and Selectors

1. We have deployed a number of PODs. They are labelled with tier, env and bu. How many PODs exist in the dev environment (env)?

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get po
    NAME          READY   STATUS    RESTARTS   AGE
    app-1-whhgk   1/1     Running   0          107s
    db-1-9qjgg    1/1     Running   0          106s
    db-1-jhqfb    1/1     Running   0          107s
    app-1-sk7dg   1/1     Running   0          107s
    app-1-rtm89   1/1     Running   0          107s
    auth          1/1     Running   0          106s
    db-1-5z6hx    1/1     Running   0          106s
    app-1-zzxdf   1/1     Running   0          106s
    app-2-wdhp9   1/1     Running   0          107s
    db-1-8nlqw    1/1     Running   0          106s
    db-2-ds4b8    1/1     Running   0          106s

    controlplane ~ ➜  k get po --show-labels=true
    NAME          READY   STATUS    RESTARTS   AGE    LABELS
    app-1-whhgk   1/1     Running   0          111s   bu=finance,env=dev,tier=frontend
    db-1-9qjgg    1/1     Running   0          110s   env=dev,tier=db
    db-1-jhqfb    1/1     Running   0          111s   env=dev,tier=db
    app-1-sk7dg   1/1     Running   0          111s   bu=finance,env=dev,tier=frontend
    app-1-rtm89   1/1     Running   0          111s   bu=finance,env=dev,tier=frontend
    auth          1/1     Running   0          110s   bu=finance,env=prod
    db-1-5z6hx    1/1     Running   0          110s   env=dev,tier=db
    app-1-zzxdf   1/1     Running   0          110s   bu=finance,env=prod,tier=frontend
    app-2-wdhp9   1/1     Running   0          111s   env=prod,tier=frontend
    db-1-8nlqw    1/1     Running   0          110s   env=dev,tier=db
    db-2-ds4b8    1/1     Running   0          110s   bu=finance,env=prod,tier=db

    controlplane ~ ➜  k get po --show-labels=true | grep "env=dev"
    app-1-whhgk   1/1     Running   0          2m     bu=finance,env=dev,tier=frontend
    db-1-9qjgg    1/1     Running   0          119s   env=dev,tier=db
    db-1-jhqfb    1/1     Running   0          2m     env=dev,tier=db
    app-1-sk7dg   1/1     Running   0          2m     bu=finance,env=dev,tier=frontend
    app-1-rtm89   1/1     Running   0          2m     bu=finance,env=dev,tier=frontend
    db-1-5z6hx    1/1     Running   0          119s   env=dev,tier=db
    db-1-8nlqw    1/1     Running   0          119s   env=dev,tier=db    
    ```
    </details>
    <br>

2. How many PODs are in the finance business unit (bu)?


    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get po --show-labels=true | grep "bu=finance"
    app-1-whhgk   1/1     Running   0          2m43s   bu=finance,env=dev,tier=frontend
    app-1-sk7dg   1/1     Running   0          2m43s   bu=finance,env=dev,tier=frontend
    app-1-rtm89   1/1     Running   0          2m43s   bu=finance,env=dev,tier=frontend
    auth          1/1     Running   0          2m42s   bu=finance,env=prod
    app-1-zzxdf   1/1     Running   0          2m42s   bu=finance,env=prod,tier=frontend
    db-2-ds4b8    1/1     Running   0          2m42s   bu=finance,env=prod,tier=db    
    ```
    </details>
    <br>

3. How many objects are in the prod environment including PODs, ReplicaSets and any other objects?

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get all --show-labels=true | grep "env=prod"
    pod/auth          1/1     Running   0          4m7s   bu=finance,env=prod
    pod/app-1-zzxdf   1/1     Running   0          4m7s   bu=finance,env=prod,tier=frontend
    pod/app-2-wdhp9   1/1     Running   0          4m8s   env=prod,tier=frontend
    pod/db-2-ds4b8    1/1     Running   0          4m7s   bu=finance,env=prod,tier=db
    service/app-1        ClusterIP   10.43.234.201   <none>        3306/TCP   4m7s   bu=finance,env=prod
    replicaset.apps/app-2   1         1         1       4m8s   env=prod
    replicaset.apps/db-2    1         1         1       4m7s   env=prod    
    ```
    </details>
    <br>

4. Identify the POD which is part of the prod environment, the finance BU and of frontend tier?


    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get po -l bu=finance,env=prod,tier=frontend
    NAME          READY   STATUS    RESTARTS   AGE
    app-1-zzxdf   1/1     Running   0          6m43s    
    ```
    </details>

## Taints and Tolerations

1. Do any taints exist on node01 node?

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS   ROLES           AGE   VERSION
    controlplane   Ready    control-plane   21m   v1.27.0
    node01         Ready    <none>          20m   v1.27.0

    controlplane ~ ➜  k describe no node01 | grep Taints
    Taints:             <none>  
    ```
    </details>
    <br>


2. Create a taint on node01 with:

    - key of spray
    - value of mortein
    - effect of NoSchedule

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k taint no node01 spray=mortein:NoSchedule
    node/node01 tainted

    controlplane ~ ➜  k describe no node01 | grep Taints
    Taints:             spray=mortein:NoSchedule   
    ```
    </details>
    <br>

3. Create another pod named bee with the nginx image, which has a toleration set to the taint mortein.

    <details><summary> Answer </summary>

    Generate the YAML file first. 

    ```bash
    controlplane ~ ➜  export dr="--dry-run=client"

    controlplane ~ ➜  k run bee --image=nginx $dr
    pod/bee created (dry run)

    controlplane ~ ➜  k run bee --image=nginx $dr -o yaml > bee.yml

    controlplane ~ ➜  ls
    bee.yml    
    ```

    Search on the k8s docs the paramters for tolerations and add it to the YAML file. Apply afterwards.

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
    creationTimestamp: null
    labels:
        run: bee
    name: bee
    spec:
    containers:
    - image: nginx
        name: bee
        resources: {}
    dnsPolicy: ClusterFirst
    restartPolicy: Always
    tolerations:
    - key: "spray"
        value: "mortein"
        effect: "NoSchedule"  
    status: {}  
    ```

    ```bash
    controlplane ~ ➜  k apply -f bee.yml
    pod/bee created

    controlplane ~ ➜  k get po
    NAME       READY   STATUS    RESTARTS   AGE
    bee        1/1     Running   0          9s
    mosquito   0/1     Pending   0          8m48s  
    ```

    </details>
    <br>

4. Remove the taint on controlplane.

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS   ROLES           AGE   VERSION
    controlplane   Ready    control-plane   35m   v1.27.0
    node01         Ready    <none>          34m   v1.27.0

    controlplane ~ ➜  k describe no controlplane | grep Taint
    Taints:             node-role.kubernetes.io/control-plane:NoSchedule 

    controlplane ~ ✖ k taint no controlplane node-role.kubernetes.io/control-plane:NoSchedule-
    node/controlplane untainted

    controlplane ~ ➜  k describe no controlplane | grep Taint
    Taints:             <none>
    ```
    </details>


## Node Affinity

    <details><summary> Answer </summary>

    ```bash
    
    ```
    </details>
    <br>








    <details><summary> Answer </summary>

    ```bash
    
    ```
    </details>
    <br>




    <details><summary> Answer </summary>

    ```bash
    
    ```
    </details>
    <br>




    <details><summary> Answer </summary>

    ```bash
    
    ```
    </details>
    <br>




    <details><summary> Answer </summary>

    ```bash
    
    ```
    </details>
    <br>




    <details><summary> Answer </summary>

    ```bash
    
    ```
    </details>
    <br>




    <details><summary> Answer </summary>

    ```bash
    
    ```
    </details>
    <br>




    <details><summary> Answer </summary>

    ```bash
    
    ```
    </details>
    <br>




    <details><summary> Answer </summary>

    ```bash
    
    ```
    </details>
    <br>




