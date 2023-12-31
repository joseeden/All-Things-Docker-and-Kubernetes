
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


## Storage 

1. Configure a volume to store the webapp logs (stored at /log/app.log) at /var/log/webapp on the host. Use the spec provided below.

    - Name: webapp

    - Image Name: kodekloud/event-simulator

    - Volume HostPath: /var/log/webapp

    - Volume Mount: /log

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po
    NAME     READY   STATUS    RESTARTS   AGE
    webapp   1/1     Running   0          48s

    controlplane ~ ➜  k exec -it webapp -- cat /log/app.log
    [2023-12-30 11:51:39,293] INFO in event-simulator: USER3 is viewing page3
    [2023-12-30 11:51:40,294] INFO in event-simulator: USER3 is viewing page3
    [2023-12-30 11:51:41,295] INFO in event-simulator: USER3 is viewing page3
    [2023-12-30 11:51:42,296] INFO in event-simulator: USER1 is viewing page1
    [2023-12-30 11:51:43,297] INFO in event-simulator: USER1 is viewing page2
    [2023-12-30 11:51:44,298] WARNING in event-simulator: USER5 Failed to Login as the account is locked due to MANY FAILED ATTEMPTS. 
    ```

    ```bash
    controlplane ~ ➜  export do="--dry-run=client -o yaml"

    controlplane ~ ➜  export now="--force --grace-period 0"  
    ```

    Generate a YAML file first and then delete the pod. 

    ```bash
    controlplane ~ ➜  k get po
    NAME     READY   STATUS    RESTARTS   AGE
    webapp   1/1     Running   0          4m54s

    controlplane ~ ➜  k get po webapp -o yaml > webapp.yml

    controlplane ~ ➜  ls -l
    total 4
    -rw-rw-rw- 1 root root    0 Dec 13 05:39 sample.yaml
    -rw-r--r-- 1 root root 2658 Dec 30 06:56 webapp.yml

    controlplane ~ ➜  k delete po webapp $now
    Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
    pod "webapp" force deleted

    controlplane ~ ➜  k get po
    No resources found in default namespace.  
    ```

    Add the volume and volumemount in the YAML file. Follow K8S docs. 

    ```bash
    ## webapp.yml 
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: "2023-12-30T11:51:34Z"
      name: webapp
      namespace: default
    resourceVersion: "506"
    uid: 45b2b932-fbe3-4106-8926-55425cc05627
    spec:
      containers:
      - env:
        - name: LOG_HANDLERS
          value: file
        image: kodekloud/event-simulator
        imagePullPolicy: Always
        name: event-simulator
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
          name: kube-api-access-77kjm
          readOnly: true
        - mountPath: /log
          name: log-volume
      volumes:
      - name: log-volume
        hostPath:
        path: /var/log/webapp # directory location on host
        type: Directory # this field is optional      
    ```
    ```bash
    controlplane ~ ➜  k apply -f webapp.yml 
    pod/webapp created

    controlplane ~ ➜  k get po
    NAME     READY   STATUS    RESTARTS   AGE
    webapp   1/1     Running   0          3s 
    ```
    
    </details>
    </br>



2. Create a Persistent Volume with the given specification.

    - Volume Name: pv-log

    - Storage: 100Mi

    - Access Modes: ReadWriteMany

    - Host Path: /pv/log

    - Reclaim Policy: Retain 

    <details><summary> Answer </summary>
    
    ```bash
    ## pv-log.yaml
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: pv-log
    spec:
      persistentVolumeReclaimPolicy: Retain
      accessModes:
        - ReadWriteMany
      capacity:
        storage: 100Mi
      storageClassName: ""
      hostPath:
        path: /pv/log
    ```
    ```bash
    controlplane ~ ➜  k apply -f pv-log.yaml 
    persistentvolume/pv-log created

    controlplane ~ ➜  k get pv
    NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
    pv-log   100Mi      RWX            Retain           Available                                   2s 
    ```
    
    </details>
    </br>



3. Create a Persistent Volume Claim with the given specification.

    - Volume Name: claim-log-1

    - Storage Request: 50Mi

    - Access Modes: ReadWriteMany

    <details><summary> Answer </summary>
    
    ```bash
    ## pvc-log.yaml
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: claim-log-1
    spec:
      accessModes:
        - ReadWriteMany
      resources:
        requests:
        storage: 50Mi
    ```
    ```bash
    controlplane ~ ➜  k apply -f pvc-log.yaml 
    persistentvolumeclaim/claim-log-1 created

    controlplane ~ ➜  k get pv
    NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                 STORAGECLASS   REASON   AGE
    pv-log   100Mi      RWX            Retain           Bound    default/claim-log-1                           4m9s

    controlplane ~ ➜  k get pvc
    NAME          STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
    claim-log-1   Bound    pv-log   100Mi      RWX                           11s 
    ```
    
    </details>
    </br>



4. Update the webapp pod to use the persistent volume claim as its storage.
    Replace hostPath configured earlier with the newly created PersistentVolumeClaim.

    ```bash
    controlplane ~ ➜  k get po
    NAME     READY   STATUS    RESTARTS   AGE
    webapp   1/1     Running   0          46m

    controlplane ~ ➜  k get pv
    NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                 STORAGECLASS   REASON   AGE
    pv-log   100Mi      RWX            Retain           Bound    default/claim-log-1                           39m

    controlplane ~ ➜  k get pvc
    NAME          STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
    claim-log-1   Bound    pv-log   100Mi      RWX                           35m                       30m 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  export do="--dry-run=client -o yaml"

    controlplane ~ ➜  export now="--force --grace-period 0" 

    controlplane ~ ➜  k get po webapp -o yaml > webapp.yml 
    ```

    Just need to modify the volume sectino:

    ```yaml
    ## webapp.yml 
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: "2023-12-30T12:55:20Z"
      name: webapp
      namespace: default
    resourceVersion: "978"
    uid: b6aec6fb-3333-4d77-9b34-0747f5de564c
    spec:
      containers:
      - env:
        - name: LOG_HANDLERS
          value: file
          image: kodekloud/event-simulator
          imagePullPolicy: Always
          name: event-simulator

    volumes:
    - name: log-volume
        persistentVolumeClaim:
            claimName: claim-log-1

    ```
    ```bash
    controlplane ~ ✦2 ➜  k apply -f webapp.yml 
    pod/webapp created

    controlplane ~ ✦2 ➜  k get po
    NAME     READY   STATUS    RESTARTS   AGE
    webapp   1/1     Running   0          2s
    ```

    
    </details>
    </br>



5. What is the reclaim policy set on pv-log?

    ```bash
    controlplane ~ ✦2 ➜  k get pv
    NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                 STORAGECLASS   REASON   AGE
    pv-log   100Mi      RWX            Retain           Bound    default/claim-log-1                           7m27s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ✦2 ➜  k describe pv pv-log 
    Name:            pv-log
    Labels:          <none>
    Annotations:     pv.kubernetes.io/bound-by-controller: yes
    Finalizers:      [kubernetes.io/pv-protection]
    StorageClass:    
    Status:          Bound
    Claim:           default/claim-log-1
    Reclaim Policy:  Retain 
    ```
    
    </details>
    </br>



6. How many storage classes are there in the cluster?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get sc
    NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
    local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  9m2s
    ```
    
    </details>
    </br>



7. What is the Volume Binding Mode used for this storage class **local-storage**?

    ```bash
    controlplane ~ ➜  k get sc
    NAME                        PROVISIONER                     RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
    local-path (default)        rancher.io/local-path           Delete          WaitForFirstConsumer   false                  9m44s
    local-storage               kubernetes.io/no-provisioner    Delete          WaitForFirstConsumer   false                  36s
    portworx-io-priority-high   kubernetes.io/portworx-volume   Delete          Immediate              false                  36s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ✖ k describe sc local-storage 
    Name:            local-storage
    IsDefaultClass:  No
    Annotations:     kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"storage.k8s.io/v1","kind":"StorageClass","metadata":{"annotations":{},"name":"local-storage"},"provisioner":"kubernetes.io/no-provisioner","volumeBindingMode":"WaitForFirstConsumer"}

    Provisioner:           kubernetes.io/no-provisioner
    Parameters:            <none>
    AllowVolumeExpansion:  <unset>
    MountOptions:          <none>
    ReclaimPolicy:         Delete
    VolumeBindingMode:     WaitForFirstConsumer
    Events:                <none> 
    ```
    
    </details>
    </br>



8. Create a new PersistentVolumeClaim by the name of local-pvc that should bind to the volume local-pv.

    - PVC: local-pvc

    - Correct Access Mode?

    - Correct StorageClass Used?

    - PVC requests volume size = 500Mi?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get pv
    NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS    REASON   AGE
    local-pv   500Mi      RWO            Retain           Available           local-storage            19m 

    controlplane ~ ➜  k describe pv local-pv 
    Name:              local-pv
    Labels:            <none>
    Annotations:       <none>
    Finalizers:        [kubernetes.io/pv-protection]
    StorageClass:      local-storage
    Status:            Available
    Claim:             
    Reclaim Policy:    Retain
    Access Modes:      RWO
    VolumeMode:        Filesystem
    Capacity:          500Mi
    Node Affinity:     
    Required Terms:  
        Term 0:        kubernetes.io/hostname in [controlplane]
    Message:           
    Source:
        Type:  LocalVolume (a persistent volume backed by local storage on a node)
        Path:  /opt/vol1
    Events:    <none>
    ```
    ```yaml
    ## local-pvc.yaml
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: local-pvc
    spec:
      accessModes:
        - ReadWriteOnce
      volumeMode: Filesystem
      storageClassName: local-storage
      resources:
        requests:
        storage: 500Mi 
    ```
    ```bash
    controlplane ~ ➜  k apply -f local-pvc.yaml 
    persistentvolumeclaim/local-pvc created 
    ```
    </details>
    </br>



9. Create a new pod called nginx with the image nginx:alpine. The Pod should make use of the PVC local-pvc and mount the volume at the path /var/www/html.
    The PV local-pv should be in a bound state.

    ```bash
    controlplane ~ ➜  k get pv
    NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS    REASON   AGE
    local-pv   500Mi      RWO            Retain           Available           local-storage            29m

    controlplane ~ ➜  k get pvc
    NAME        STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS    AGE
    local-pvc   Pending                                      local-storage   5m17s 
    ```
        
    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  export do="--dry-run=client -o yaml"

    controlplane ~ ➜  export now="--force --grace-period 0" 

    controlplane ~ ➜  k run nginx --image nginx:alpine $do > nginx.yaml
    ```

    ```bash
    ## nginx.yaml
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: null
      labels:
        run: nginx
    name: nginx
    spec:
      containers:
      - image: nginx:alpine
        name: nginx
        resources: {}
        volumeMounts:
        - mountPath: "/var/www/html"
          name: local-pv
    dnsPolicy: ClusterFirst
    restartPolicy: Always
    volumes:
    - name: local-pv
        persistentVolumeClaim:
            claimName: local-pvc
    status: {} 
    ```
    
    ```bash
    controlplane ~ ➜  k apply -f nginx.yaml 
    pod/nginx created

    controlplane ~ ➜  k get po
    NAME    READY   STATUS    RESTARTS   AGE
    nginx   1/1     Running   0          6s

    controlplane ~ ➜  k get pv
    NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS    REASON   AGE
    local-pv   500Mi      RWO            Retain           Bound    default/local-pvc   local-storage            31m

    controlplane ~ ➜  k get pvc
    NAME        STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS    AGE
    local-pvc   Bound    local-pv   500Mi      RWO            local-storage   7m16s 
    ```
    
    </details>
    </br>


10. Create a new Storage Class called delayed-volume-sc that makes use of the below specs:

    - provisioner: kubernetes.io/no-provisioner

    - volumeBindingMode: WaitForFirstConsumer

    <details><summary> Answer </summary>
    
    ```bash
    ## delayed-volume-sc.yaml 
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: delayed-volume-sc
      annotations:
        storageclass.kubernetes.io/is-default-class: "false"
    provisioner: kubernetes.io/no-provisioner
    volumeBindingMode: WaitForFirstConsumer 
    ```
    
    ```bash
    controlplane ~ ➜  k apply -f delayed-volume-sc.yaml 
    storageclass.storage.k8s.io/delayed-volume-sc created

    controlplane ~ ➜  k get sc
    NAME                        PROVISIONER                     RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
    local-path (default)        rancher.io/local-path           Delete          WaitForFirstConsumer   false                  45m
    local-storage               kubernetes.io/no-provisioner    Delete          WaitForFirstConsumer   false                  35m
    portworx-io-priority-high   kubernetes.io/portworx-volume   Delete          Immediate              false                  35m
    delayed-volume-sc           kubernetes.io/no-provisioner    Delete          WaitForFirstConsumer   false                  3s 
    ```
    </details>
    </br>






[Back to the top](#practice-test-cka)    
