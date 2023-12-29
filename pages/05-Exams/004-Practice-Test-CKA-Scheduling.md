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



## Scheduling 

1. Fix the nginx pod. The YAML file is given. 

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
    <br>


2. We have deployed a number of PODs. They are labelled with tier, env and bu. How many PODs exist in the dev environment (env)?

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

3. How many PODs are in the finance business unit (bu)?


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

4. How many objects are in the prod environment including PODs, ReplicaSets and any other objects?

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

5. Identify the POD which is part of the prod environment, the finance BU and of frontend tier?


    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get po -l bu=finance,env=prod,tier=frontend
    NAME          READY   STATUS    RESTARTS   AGE
    app-1-zzxdf   1/1     Running   0          6m43s    
    ```
    </details>
    <br> 

6. How many labels does node01 have?

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k describe  no node01 | grep Labels -A 10
    Labels:             beta.kubernetes.io/arch=amd64
                        beta.kubernetes.io/os=linux
                        kubernetes.io/arch=amd64
                        kubernetes.io/hostname=node01
                        kubernetes.io/os=linux
    Annotations:        flannel.alpha.coreos.com/backend-data: {"VNI":1,"VtepMAC":"96:49:b7:34:27:94"}
                        flannel.alpha.coreos.com/backend-type: vxlan
                        flannel.alpha.coreos.com/kube-subnet-manager: true
                        flannel.alpha.coreos.com/public-ip: 192.10.195.3
                        kubeadm.alpha.kubernetes.io/cri-socket: unix:///var/run/containerd/containerd.sock
                        node.alpha.kubernetes.io/ttl: 0   
    ```
    </details>
    <br>

7. Apply a label color=blue to node node01

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k label no node01 color=blue
    node/node01 labeled   

    controlplane ~ ➜  k describe no node01 | grep -A 10 Labels
    Labels:             beta.kubernetes.io/arch=amd64
                        beta.kubernetes.io/os=linux
                        color=blue
                        kubernetes.io/arch=amd64
                        kubernetes.io/hostname=node01
                        kubernetes.io/os=linux
    ```
    </details>
    <br>


8. Do any taints exist on node01 node?

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


9. Create a taint on node01 with:

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

10. Create another pod named bee with the nginx image, which has a toleration set to the taint mortein.

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

11. Remove the taint on controlplane.

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
    <br>


12. Set Node Affinity to the deployment to place the pods on node01 only.

    <details><summary> Answer </summary>
    Get the YAML file and modify by adding the parameters for the node affinity. See K8s docs for format.

    ```bash
    controlplane ~ ➜  k get deployments.apps blue -o yaml > blue.yml     
    ```
    ```bash
    apiVersion: apps/v1
    kind: Deployment
    metadata:
    creationTimestamp: null
    labels:
        app: blue
    name: blue
    spec:
    replicas: 3
    selector:
        matchLabels:
        app: blue
    strategy: {}
    template:
        metadata:
        creationTimestamp: null
        labels:
            app: blue
        spec:
        containers:
        - image: nginx
            name: nginx
            resources: {}
        affinity:
            nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                - matchExpressions:
                - key: color
                    operator: In
                    values:
                    - blue

    status: {}
    ```

    ```bash
    controlplane ~ ➜  k apply -f blue.yml 
    deployment.apps/blue created

    controlplane ~ ➜  k get po -o wide
    NAME                   READY   STATUS    RESTARTS   AGE   IP           NODE     NOMINATED NODE   READINESS GATES
    blue-f69d4c887-6whqb   1/1     Running   0          10s   10.244.1.6   node01   <none>           <none>
    blue-f69d4c887-j8x27   1/1     Running   0          10s   10.244.1.4   node01   <none>           <none>
    blue-f69d4c887-z8hbl   1/1     Running   0          10s   10.244.1.5   node01   <none>           <none> 
    ```    
    </details>
    <br>

13. Create a new deployment named red with the nginx image and 2 replicas, and ensure it gets placed on the controlplane node only.

    Use the label key - node-role.kubernetes.io/control-plane - which is already set on the controlplane node.


    <details><summary> Answer </summary>
    
    Verify label.
    ```bash
    controlplane ~ ➜  k describe nodes controlplane | grep -A 10 Labels
    Labels:             beta.kubernetes.io/arch=amd64
                        beta.kubernetes.io/os=linux
                        kubernetes.io/arch=amd64
                        kubernetes.io/hostname=controlplane
                        kubernetes.io/os=linux
                        node-role.kubernetes.io/control-plane=
                        node.kubernetes.io/exclude-from-external-load-balancers=
    Annotations:        flannel.alpha.coreos.com/backend-data: {"VNI":1,"VtepMAC":"ca:c9:cd:c5:51:72"}
                        flannel.alpha.coreos.com/backend-type: vxlan
                        flannel.alpha.coreos.com/kube-subnet-manager: true
                        flannel.alpha.coreos.com/public-ip: 192.12.20.6
    ```

    Generate the YAML and add the affinity parameter. See K8s docs for format.

    ```bash
    controlplane ~ ➜  k create deployment red --image nginx --replicas 2 $do > red.yml
    ```
    ```bash
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
        containers:
        - image: nginx
            name: nginx
            resources: {}
        affinity:
            nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                - matchExpressions:
                - key: node-role.kubernetes.io/control-plane
                    operator: Exists
    ```

    ```bash
    controlplane ~ ➜  k apply -f red.yml 
    deployment.apps/red created 

    controlplane ~ ➜  k get deployments.apps 
    NAME   READY   UP-TO-DATE   AVAILABLE   AGE
    blue   3/3     3            3           10m
    red    2/2     2            2           13s
    ```
    </details>
    <br>


14. A pod called rabbit is deployed. Identify the CPU requirements set on the Pod.

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get po
    NAME     READY   STATUS             RESTARTS      AGE
    rabbit   0/1     CrashLoopBackOff   4 (31s ago)   118s

    controlplane ~ ➜  k describe po rabbit | grep -A 5 -i requests
        Requests:
        cpu:        1    
    ```
    </details>
    <br>

15. Another pod called elephant has been deployed in the default namespace. It fails to get to a running state. Inspect this pod and identify the Reason why it is not running.

    <details><summary> Answer </summary>

    ```bash
    The status OOMKilled indicates that it is failing because the pod ran out of memory. Identify the memory limit set on the POD. 

    controlplane ~ ➜  k get po
    NAME       READY   STATUS             RESTARTS      AGE
    elephant   0/1     CrashLoopBackOff   3 (33s ago)   86s

    controlplane ~ ➜  k describe pod elephant | grep -A 5 State
        State:          Terminated
        Reason:       OOMKilled
        Exit Code:    1
        Started:      Fri, 29 Dec 2023 07:25:52 +0000
        Finished:     Fri, 29 Dec 2023 07:25:52 +0000
        Last State:     Terminated
        Reason:       OOMKilled
        Exit Code:    1
        Started:      Fri, 29 Dec 2023 07:25:01 +0000
        Finished:     Fri, 29 Dec 2023 07:25:01 +0000
        Ready:          False    
    ```
    </details>
    <br>

16. The elephant pod runs a process that consumes 15Mi of memory. Increase the limit of the elephant pod to 20Mi.

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  export do="--dry-run=client -o yaml"
    controlplane ~ ➜  export now="--force --grace-period 0"     

    controlplane ~ ✦ ➜  k get po -o yaml > el.yaml
    ```

    ```bash
    apiVersion: v1
    items:
    - apiVersion: v1
    kind: Pod
    metadata:
        creationTimestamp: "2023-12-29T07:24:08Z"
        name: elephant
        namespace: default
        resourceVersion: "952"
        uid: fe698e64-ca6b-4990-813a-9b63c7cc2b2b
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
    controlplane ~ ✦ ➜  k delete po elephant $now
    Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
    pod "elephant" force deleted

    controlplane ~ ✦ ➜  k apply -f el.yaml 
    pod/elephant created  

    controlplane ~ ✦ ✖ k get po
    NAME       READY   STATUS    RESTARTS   AGE
    elephant   1/1     Running   0          39s
    ``` 
    </details>
    <br>


17. How many DaemonSets in all namespaces?

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get ds -A
    NAMESPACE      NAME              DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
    kube-flannel   kube-flannel-ds   1         1         1       1            1           <none>                   4m31s
    kube-system    kube-proxy        1         1         1       1            1           kubernetes.io/os=linux   4m34s

    ```
    </details>
    <br>

18. What is the image used by the POD deployed by the kube-flannel-ds DaemonSet?

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get ds -A
    NAMESPACE      NAME              DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
    kube-flannel   kube-flannel-ds   1         1         1       1            1           <none>                   6m57s
    kube-system    kube-proxy        1         1         1       1            1           kubernetes.io/os=linux   7m

    controlplane ~ ➜  k describe daemonsets.apps -n kube-flannel kube-flannel-ds  | grep Image
        Image:      docker.io/rancher/mirrored-flannelcni-flannel-cni-plugin:v1.1.0
        Image:      docker.io/rancher/mirrored-flannelcni-flannel:v0.19.2
        Image:      docker.io/rancher/mirrored-flannelcni-flannel:v0.19.2
    ```
    </details>
    <br>

19. Deploy a DaemonSet for FluentD Logging.

    - Name: elasticsearch
    - Namespace: kube-system
    - Image: registry.k8s.io/fluentd-elasticsearch:1.20

    <details><summary> Answer </summary>

    Copy the FluentD YAML from K8S docs and modify. Apply afterwards.

    ```bash
    apiVersion: apps/v1
    kind: DaemonSet
    metadata:
    name: elasticsearch
    namespace: kube-system
    labels:
        k8s-app: fluentd-logging
    spec:
    selector:
        matchLabels:
        name: fluentd-elasticsearch
    template:
        metadata:
        labels:
            name: fluentd-elasticsearch
        spec:
        tolerations:
        # these tolerations are to have the daemonset runnable on control plane nodes
        # remove them if your control plane nodes should not run pods
        - key: node-role.kubernetes.io/control-plane
            operator: Exists
            effect: NoSchedule
        - key: node-role.kubernetes.io/master
            operator: Exists
            effect: NoSchedule
        containers:
        - name: fluentd-elasticsearch
            image: registry.k8s.io/fluentd-elasticsearch:1.20
            resources:
            limits:
                memory: 200Mi
            requests:
                cpu: 100m
                memory: 200Mi
            volumeMounts:
            - name: varlog
            mountPath: /var/log
        # it may be desirable to set a high priority class to ensure that a DaemonSet Pod
        # preempts running Pods
        # priorityClassName: important
        terminationGracePeriodSeconds: 30
        volumes:
        - name: varlog
            hostPath:
            path: /var/log

    ```
    ```bash
    controlplane ~ ➜  k apply -f fluentd.yml 
    daemonset.apps/elasticsearch created

    controlplane ~ ➜  k get ds -A
    NAMESPACE      NAME              DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
    kube-flannel   kube-flannel-ds   1         1         1       1            1           <none>                   10m
    kube-system    elasticsearch     1         1         1       1            1           <none>                   4s
    kube-system    kube-proxy        1         1         1       1            1           kubernetes.io/os=linux   10m
    ```
    </details>
    <br>


20. How many static pods exist in this cluster in all namespaces? 

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get po -A | grep controlplane
    kube-system    etcd-controlplane                      1/1     Running   0          6m41s
    kube-system    kube-apiserver-controlplane            1/1     Running   0          6m39s
    kube-system    kube-controller-manager-controlplane   1/1     Running   0          6m39s
    kube-system    kube-scheduler-controlplane            1/1     Running   0          6m41s
    ```
    </details>
    <br>

21. On which nodes are the static pods created currently?

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get po -o wide -A | grep controlplane
    kube-system    etcd-controlplane                      1/1     Running   0          8m9s    192.13.225.9    controlplane   <none>           <none>
    kube-system    kube-apiserver-controlplane            1/1     Running   0          8m7s    192.13.225.9    controlplane   <none>           <none>
    kube-system    kube-controller-manager-controlplane   1/1     Running   0          8m7s    192.13.225.9    controlplane   <none>           <none>
    kube-system    kube-scheduler-controlplane            1/1     Running   0          8m9s    192.13.225.9    controlplane   <none>           <none>
    ```

    </details>
    <br>

22. What is the path of the directory holding the static pod definition files?

    <details><summary> Answer </summary>

    First idenity the kubelet config file (--config):

    ```bash
    controlplane ~ ➜  ps -aux | grep /usr/bin/kubelet
    root        4685  0.0  0.0 3775504 101080 ?      Ssl  02:35   0:10 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock --pod-infra-container-image=registry.k8s.io/pause:3.9
    root        9476  0.0  0.0   6748  2540 pts/0    S+   02:46   0:00 grep --color=auto /usr/bin/kubelet
    ```

    Next, lookup the value assigned for staticPodPath:

    ```bash
    controlplane ~ ➜  grep static /var/lib/kubelet/config.yaml 
    staticPodPath: /etc/kubernetes/manifests
    ```
    </details>
    <br>

23. How many pod definition files are present in the manifests directory?

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  ls -la /etc/kubernetes/manifests/
    total 28
    drwxr-xr-x 1 root root 4096 Dec 29 02:35 .
    drwxr-xr-x 1 root root 4096 Dec 29 02:35 ..
    -rw------- 1 root root 2405 Dec 29 02:35 etcd.yaml
    -rw------- 1 root root 3882 Dec 29 02:35 kube-apiserver.yaml
    -rw------- 1 root root 3393 Dec 29 02:35 kube-controller-manager.yaml
    -rw------- 1 root root 1463 Dec 29 02:35 kube-scheduler.yaml
    ```
    </details>
    <br>

24. What is the docker image used to deploy the kube-api server as a static pod?

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  ls -la /etc/kubernetes/manifests/
    total 28
    drwxr-xr-x 1 root root 4096 Dec 29 02:35 .
    drwxr-xr-x 1 root root 4096 Dec 29 02:35 ..
    -rw------- 1 root root 2405 Dec 29 02:35 etcd.yaml
    -rw------- 1 root root 3882 Dec 29 02:35 kube-apiserver.yaml
    -rw------- 1 root root 3393 Dec 29 02:35 kube-controller-manager.yaml
    -rw------- 1 root root 1463 Dec 29 02:35 kube-scheduler.yaml

    controlplane ~ ➜  grep image /etc/kubernetes/manifests/kube-apiserver.yaml 
        image: registry.k8s.io/kube-apiserver:v1.27.0
        imagePullPolicy: IfNotPresent
    ```
    </details>
    <br>



25. Create a static pod named static-busybox that uses the busybox image and the command sleep 1000

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  export do="--dry-run=client -o yaml"

    controlplane ~ ➜  export now="--force --grace-period 0"

    controlplane ~ ➜  k run po static-busy-box --image busybox $do > bb.yml
    ```

    Note that since it's a static pod, it needs to be created in the /etc/kubernetes/manifests directory. 

    ```bash
    controlplane ~ ➜  cd /etc/kubernetes/manifests/

    controlplane /etc/kubernetes/manifests ➜  

    controlplane /etc/kubernetes/manifests ➜  k run static-busybox --image busybox $do > /etc/kubernetes/manifests/static-busybox.yml

    controlplane /etc/kubernetes/manifests ➜  ls -la /etc/kubernetes/manifests/
    total 36
    drwxr-xr-x 1 root root 4096 Dec 29 02:56 .
    drwxr-xr-x 1 root root 4096 Dec 29 02:35 ..
    -rw------- 1 root root 2405 Dec 29 02:35 etcd.yaml
    -rw------- 1 root root 3882 Dec 29 02:35 kube-apiserver.yaml
    -rw------- 1 root root 3393 Dec 29 02:35 kube-controller-manager.yaml
    -rw------- 1 root root 1463 Dec 29 02:35 kube-scheduler.yaml
    -rw-r--r-- 1 root root  256 Dec 29 02:56 static-busybox.yml
    ```

    Add the command parameter and apply afterwards.

    ```bash
    apiVersion: v1
    kind: Pod
    metadata:
    creationTimestamp: null
    labels:
        run: static-busybox
    name: static-busybox
    spec:
    containers:
    - command:
        - sleep
        - "1000"
        image: busybox
        name: static-busybox
        resources: {}
    dnsPolicy: ClusterFirst
    restartPolicy: Never
    status: {}
    ```

    ```bash
    controlplane /etc/kubernetes/manifests ➜  k get po
    NAME                          READY   STATUS    RESTARTS   AGE
    static-busybox-controlplane   1/1     Running   0          2s 
    ```

    </details>
    <br>

26. We just created a new static pod named static-greenbox. Prevent this pod from restarting when it is deleted.

    <details><summary> Answer </summary>

    ```bash
    controlplane /etc/kubernetes/manifests ✦2 ➜  k get po
    NAME                          READY   STATUS    RESTARTS   AGE
    static-busybox-controlplane   1/1     Running   0          27s
    static-greenbox-node01        1/1     Running   0          14s

    controlplane /etc/kubernetes/manifests ✦2 ➜  k get po -o wide
    NAME                          READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
    static-busybox-controlplane   1/1     Running   0          32s   10.244.0.5   controlplane   <none>           <none>
    static-greenbox-node01        1/1     Running   0          19s   10.244.1.2   node01         <none>           <none>
    ```

    ```bash
    controlplane /etc/kubernetes/manifests ✦2 ✖ k delete po static-greenbox-node01 $now
    Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
    pod "static-greenbox-node01" force deleted

    controlplane /etc/kubernetes/manifests ✦2 ➜  k get po -o wide
    NAME                          READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
    static-busybox-controlplane   1/1     Running   0          81s   10.244.0.5   controlplane   <none>           <none>
    ```

    SSH to node01 and find the config file (--config).

    ```bash
    controlplane /etc/kubernetes/manifests ✦2 ➜  ssh node01
    Warning: Permanently added the ECDSA host key for IP address '192.14.237.3' to the list of known hosts.

    root@node01 ~ ➜  ps -aux | grep /usr/bin/kubelet 
    root        4435  0.0  0.0 3330296 94296 ?       Ssl  03:19   0:01 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock --pod-infra-container-image=registry.k8s.io/pause:3.9
    root        5398  0.0  0.0   5200   720 pts/0    S+   03:22   0:00 grep /usr/bin/kubelet

    root@node01 ~ ➜  grep static /var/lib/kubelet/config.yaml 
    staticPodPath: /etc/just-to-mess-with-you 

    root@node01 ~ ➜  ls -la /etc/just-to-mess-with-you/
    total 16
    drwxr-xr-x 2 root root 4096 Dec 29 03:20 .
    drwxr-xr-x 1 root root 4096 Dec 29 03:19 ..
    -rw-r--r-- 1 root root  301 Dec 29 03:20 greenbox.yaml

    root@node01 ~ ➜  sudo rm /etc/just-to-mess-with-you/greenbox.yaml 
    ```

    Return to the controlplane and verify that the greenbox pod does not restart anymore.

    </details>
    <br>


27. What is the image used in the scheduler pod?

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get po -A
    NAMESPACE      NAME                                   READY   STATUS    RESTARTS   AGE
    kube-flannel   kube-flannel-ds-bcc4q                  1/1     Running   0          4m13s
    kube-system    coredns-5d78c9869d-6jbzh               1/1     Running   0          4m12s
    kube-system    coredns-5d78c9869d-g5kln               1/1     Running   0          4m12s
    kube-system    etcd-controlplane                      1/1     Running   0          4m24s
    kube-system    kube-apiserver-controlplane            1/1     Running   0          4m24s
    kube-system    kube-controller-manager-controlplane   1/1     Running   0          4m24s
    kube-system    kube-proxy-cdzqm                       1/1     Running   0          4m13s
    kube-system    kube-scheduler-controlplane            1/1     Running   0          4m24s

    controlplane ~ ➜  k describe po -n kube-system kube-scheduler-controlplane | grep image

    controlplane ~ ✖ k describe po -n kube-system kube-scheduler-controlplane | grep -i image
        Image:         registry.k8s.io/kube-scheduler:v1.27.0
        Image ID:      registry.k8s.io/kube-scheduler@sha256:939d0c6675c373639f53f05d61b5035172f95afb47ecffee6baf4e3d70543b66
    ```
    </details>
    <br>



28. Create a configmap that the new scheduler will employ using the concept of ConfigMap as a volume.
We have already given a configMap definition file called my-scheduler-configmap.yaml at /root/ path that will create a configmap with name my-scheduler-config using the content of file /root/my-scheduler-config.yaml.

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  ls -l
    total 16
    -rw-r--r-- 1 root root 341 Dec 29 03:27 my-scheduler-configmap.yaml
    -rw-rw-rw- 1 root root 160 Dec 13 05:39 my-scheduler-config.yaml
    -rw-rw-rw- 1 root root 893 Dec 13 05:39 my-scheduler.yaml
    -rw-rw-rw- 1 root root 105 Dec 13 05:39 nginx-pod.yaml

    controlplane ~ ➜  k apply -f my-scheduler-configmap.yaml 
    configmap/my-scheduler-config created

    controlplane ~ ➜  k get cm
    NAME               DATA   AGE
    kube-root-ca.crt   1      7m58s

    controlplane ~ ➜  k get cm -A
    NAMESPACE         NAME                                                   DATA   AGE
    default           kube-root-ca.crt                                       1      8m1s
    kube-flannel      kube-flannel-cfg                                       2      8m11s
    kube-flannel      kube-root-ca.crt                                       1      8m1s
    kube-node-lease   kube-root-ca.crt                                       1      8m1s
    kube-public       cluster-info                                           2      8m15s
    kube-public       kube-root-ca.crt                                       1      8m1s
    kube-system       coredns                                                1      8m13s
    kube-system       extension-apiserver-authentication                     6      8m18s
    kube-system       kube-apiserver-legacy-service-account-token-tracking   1      8m18s
    kube-system       kube-proxy                                             2      8m13s
    kube-system       kube-root-ca.crt                                       1      8m1s
    kube-system       kubeadm-config                                         1      8m16s
    kube-system       kubelet-config                                         1      8m16s
    kube-system       my-scheduler-config                                    1      6s
    ```
    </details>
    <br>


29. Deploy an additional scheduler to the cluster following the given specification.
    Use the manifest file provided at /root/my-scheduler.yaml. Use the same image as used by the default kubernetes scheduler.

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  ls -l
    total 16
    -rw-r--r-- 1 root root 341 Dec 29 03:27 my-scheduler-configmap.yaml
    -rw-rw-rw- 1 root root 160 Dec 13 05:39 my-scheduler-config.yaml
    -rw-rw-rw- 1 root root 893 Dec 13 05:39 my-scheduler.yaml
    -rw-rw-rw- 1 root root 105 Dec 13 05:39 nginx-pod.yaml

    controlplane ~ ➜  k get po -n kube-system 
    NAME                                   READY   STATUS    RESTARTS   AGE
    coredns-5d78c9869d-6jbzh               1/1     Running   0          9m45s
    coredns-5d78c9869d-g5kln               1/1     Running   0          9m45s
    etcd-controlplane                      1/1     Running   0          9m57s
    kube-apiserver-controlplane            1/1     Running   0          9m57s
    kube-controller-manager-controlplane   1/1     Running   0          9m57s
    kube-proxy-cdzqm                       1/1     Running   0          9m46s
    kube-scheduler-controlplane            1/1     Running   0          9m57s

    controlplane ~ ✖ k describe po -n kube-system kube-scheduler-controlplane | grep -i image
        Image:         registry.k8s.io/kube-scheduler:v1.27.0
        Image ID:      registry.k8s.io/kube-scheduler@sha256:939d0c6675c373639f53f05d61b5035172f95afb47ecffee6baf4e3d70543b66
    ```

    ```bash
    apiVersion: v1
    kind: Pod
    metadata:
    labels:
        run: my-scheduler
    name: my-scheduler
    namespace: kube-system
    spec:
    serviceAccountName: my-scheduler
    containers:
    - command:
        - /usr/local/bin/kube-scheduler
        - --config=/etc/kubernetes/my-scheduler/my-scheduler-config.yaml
        image: registry.k8s.io/kube-scheduler:v1.27.0
    ```

    ```bash
    controlplane ~ ➜  k apply -f my-scheduler.yaml 
    pod/my-scheduler created 

    controlplane ~ ➜  k get po -n kube-system 
    NAME                                   READY   STATUS    RESTARTS   AGE
    coredns-5d78c9869d-6jbzh               1/1     Running   0          12m
    coredns-5d78c9869d-g5kln               1/1     Running   0          12m
    etcd-controlplane                      1/1     Running   0          12m
    kube-apiserver-controlplane            1/1     Running   0          12m
    kube-controller-manager-controlplane   1/1     Running   0          12m
    kube-proxy-cdzqm                       1/1     Running   0          12m
    kube-scheduler-controlplane            1/1     Running   0          12m
    my-scheduler                           1/1     Running   0          7s
    ```
    </details>
    <br>

30. Modify the nginx-pod.yml file POD to create a POD with the new custom scheduler.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ✦ ➜  k get po -A
    NAMESPACE      NAME                                   READY   STATUS    RESTARTS   AGE
    kube-flannel   kube-flannel-ds-bcc4q                  1/1     Running   0          14m
    kube-system    coredns-5d78c9869d-6jbzh               1/1     Running   0          14m
    kube-system    coredns-5d78c9869d-g5kln               1/1     Running   0          14m
    kube-system    etcd-controlplane                      1/1     Running   0          14m
    kube-system    kube-apiserver-controlplane            1/1     Running   0          14m
    kube-system    kube-controller-manager-controlplane   1/1     Running   0          14m
    kube-system    kube-proxy-cdzqm                       1/1     Running   0          14m
    kube-system    kube-scheduler-controlplane            1/1     Running   0          14m
    kube-system    my-scheduler                           1/1     Running   0          2m43s 
    ```

    Add the new custom scheduler. 

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
    name: nginx
    spec:
    schedulerName: my-scheduler
    containers:
    - image: nginx
        name: nginx 
    ```
    ```bash
    controlplane ~ ✦ ➜  k apply -f nginx-pod.yaml 
    pod/nginx created

    controlplane ~ ✦ ➜  k get po -A
    NAMESPACE      NAME                                   READY   STATUS    RESTARTS   AGE
    default        nginx                                  1/1     Running   0          3s
    kube-flannel   kube-flannel-ds-bcc4q                  1/1     Running   0          17m
    kube-system    coredns-5d78c9869d-6jbzh               1/1     Running   0          17m
    kube-system    coredns-5d78c9869d-g5kln               1/1     Running   0          17m
    kube-system    etcd-controlplane                      1/1     Running   0          17m
    kube-system    kube-apiserver-controlplane            1/1     Running   0          17m
    kube-system    kube-controller-manager-controlplane   1/1     Running   0          17m
    kube-system    kube-proxy-cdzqm                       1/1     Running   0          17m
    kube-system    kube-scheduler-controlplane            1/1     Running   0          17m
    kube-system    my-scheduler                           1/1     Running   0          5m47s 
    ```
    </details>
    </br>

[Back to the top](#practice-test-cka)    

