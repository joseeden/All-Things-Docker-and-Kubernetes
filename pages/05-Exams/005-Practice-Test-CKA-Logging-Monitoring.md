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
- [Mock Exam](014-Practice-Test-CKA-Mock-Exam.md)



## Logging and Monitoring 


1. Deploy metrics-server to monitor the PODs and Nodes.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po
    NAME       READY   STATUS    RESTARTS   AGE
    elephant   1/1     Running   0          10s
    lion       1/1     Running   0          10s
    rabbit     1/1     Running   0          10s

    controlplane ~ ➜  git clone https://github.com/kodekloudhub/kubernetes-metrics-server.git
    Cloning into 'kubernetes-metrics-server'...
    remote: Enumerating objects: 31, done.
    remote: Counting objects: 100% (19/19), done.
    remote: Compressing objects: 100% (19/19), done.
    remote: Total 31 (delta 8), reused 0 (delta 0), pack-reused 12
    Unpacking objects: 100% (31/31), 8.06 KiB | 1.34 MiB/s, done.

    controlplane ~ ➜  ls -l
    total 4
    drwxr-xr-x 3 root root 4096 Dec 29 03:44 kubernetes-metrics-server
    -rw-rw-rw- 1 root root    0 Dec 13 05:39 sample.yaml

    controlplane ~ ✖ k apply -f kubernetes-metrics-server/
    clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
    clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
    rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
    apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
    serviceaccount/metrics-server created
    deployment.apps/metrics-server created
    service/metrics-server created
    clusterrole.rbac.authorization.k8s.io/system:metrics-server created
    clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created
    ```

    Start monitoring the nodes. 

    ```bash
    controlplane ~ ➜  k top node
    NAME           CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
    controlplane   241m         0%     1159Mi          0%        
    node01         24m          0%     300Mi           0%   
    ```
    
    </details>
    </br>

2. Identify the POD that consumes the most Memory(bytes) in default namespace.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po
    NAME       READY   STATUS    RESTARTS   AGE
    elephant   1/1     Running   0          4m33s
    lion       1/1     Running   0          4m33s
    rabbit     1/1     Running   0          4m33s

    controlplane ~ ➜  k top pod
    NAME       CPU(cores)   MEMORY(bytes)   
    elephant   15m          31Mi            
    lion       1m           18Mi            
    rabbit     107m         252Mi  
    ```
    
    </details>
    </br>

3. A user - USER5 - has expressed concerns accessing the application. Identify the cause of the issue.

    ```bash
    controlplane ~ ➜  k get po
    NAME       READY   STATUS    RESTARTS   AGE
    webapp-1   1/1     Running   0          108s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ✖ k logs webapp-1 | grep WARNING
    [2023-12-29 08:49:33,717] WARNING in event-simulator: USER5 Failed to Login as the account is locked due to MANY FAILED ATTEMPTS.
    [2023-12-29 08:49:36,719] WARNING in event-simulator: USER7 Order failed as the item is OUT OF STOCK.
    [2023-12-29 08:49:38,722] WARNING in event-simulator: USER5 Failed to Login as the account is locked due to MANY FAILED ATTEMPTS.
    [2023-12-29 08:49:43,728] WARNING in event-simulator: USER5 Failed to Login as the account is locked due to MANY FAILED ATTEMPTS. 
    ```
    
    </details>
    </br>

4. A user is reporting issues while trying to purchase an item. Identify the user and the cause of the issue. Inspect the logs of the webapp-2 in the POD

    ```bash
    controlplane ~ ➜  k get po 
    NAME       READY   STATUS    RESTARTS   AGE
    webapp-1   1/1     Running   0          2m53s
    webapp-2   2/2     Running   0          17s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k logs webapp-2 | grep WARNING
    Defaulted container "simple-webapp" out of: simple-webapp, db
    [2023-12-29 08:52:05,219] WARNING in event-simulator: USER5 Failed to Login as the account is locked due to MANY FAILED ATTEMPTS.
    [2023-12-29 08:52:08,221] WARNING in event-simulator: USER30 Order failed as the item is OUT OF STOCK.
    [2023-12-29 08:52:10,224] WARNING in event-simulator: USER5 Failed to Login as the account is locked due to MANY FAILED ATTEMPTS.
    [2023-12-29 08:52:15,228] WARNING in event-simulator: USER5 Failed to Login as the account is locked due to MANY FAILED ATTEMPTS.
    [2023-12-29 08:52:16,229] WARNING in event-simulator: USER30 Order failed as the item is OUT OF STOCK. 
    ```
    
    </details>
    </br>


[Back to the top](#practice-test-cka)    
