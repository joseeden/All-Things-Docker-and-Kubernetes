
# Practice Test: CKAD

> *Some of the scenario questions here are based on [Kodekloud's CKAD course labs](https://kodekloud.com/courses/labs-certified-kubernetes-application-developer/?utm_source=udemy&utm_medium=labs&utm_campaign=kubernetes).*

- [Configuration](016-Practice-Test-CKAD-Configuration.md) 

- [Multi-Container PODs](017-Practice-Test-CKAD-Multi-Container-Pods.md)

- [POD Design](018-Practice-Test-CKAD-Pod-Design.md)

- [Services & Networking](019-Practice-Test-CKAD-Services-Networking,md)

- [State Persistence](020-Practice-Test-CKAD-State-Persistence.md)

- [Additional Updates](021-Practice-Test-CKAD-Additional-Updates.md)

- [Mock Exams](022-Practice-Test-CKAD-Mock-Exams.md) 


## Additional Updates 

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


1. How many container images are in the host?

    <details><summary> Answer </summary>
    
    ```bash
    $ docker images
    REPOSITORY                      TAG       IMAGE ID       CREATED         SIZE
    redis                           latest    eca1379fe8b5   8 months ago    117MB
    mysql                           latest    8189e588b0e8   8 months ago    564MB
    nginx                           latest    6efc10a0510f   8 months ago    142MB
    postgres                        latest    ceccf204404e   8 months ago    379MB
    nginx                           alpine    8e75cbc5b25c   9 months ago    41MB
    alpine                          latest    9ed4aefc74f6   9 months ago    7.04MB
    ubuntu                          latest    08d22c0ceb15   10 months ago   77.8MB
    kodekloud/simple-webapp-mysql   latest    129dd9f67367   5 years ago     96.6MB
    kodekloud/simple-webapp         latest    c6e3cd9aae36   5 years ago     84.8MB 
    ```
    
    </details>
    </br>

2. Build a docker image using the Dockerfile and name it webapp-color. No tag to be specified.

    ```bash
    $ ls -l
    total 4
    drwxr-xr-x 4 root root 4096 Jan  6 04:18 webapp-color

    $ ls -l webapp-color/
    total 16
    -rw-r--r-- 1 root root  113 Jan  6 04:18 Dockerfile
    -rw-r--r-- 1 root root 2259 Jan  6 04:18 app.py
    -rw-r--r-- 1 root root    5 Jan  6 04:18 requirements.txt
    drwxr-xr-x 2 root root 4096 Jan  6 04:18 templates 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    $ docker build -t webapp-color webapp-color/
    Sending build context to Docker daemon  125.4kB
    Step 1/6 : FROM python:3.6
    ---> 54260638d07c
    Step 2/6 : RUN pip install flask
    ---> Using cache
    ---> 94c3f6b51c29
    Step 3/6 : COPY . /opt/
    ---> Using cache
    ---> cd1ff9e242bb
    Step 4/6 : EXPOSE 8080
    ---> Using cache
    ---> 95dbaf915fbe
    Step 5/6 : WORKDIR /opt
    ---> Using cache
    ---> fb1706a0b0fc
    Step 6/6 : ENTRYPOINT ["python", "app.py"]
    ---> Using cache
    ---> ea2b85406064
    Successfully built ea2b85406064
    Successfully tagged webapp-color:latest
    $ 
    $ docker images
    REPOSITORY                      TAG           IMAGE ID       CREATED              SIZE
    webapp-color                    latest        ea2b85406064   About a minute ago   913MB
    redis                           latest        eca1379fe8b5   8 months ago         117MB
    mysql                           latest        8189e588b0e8   8 months ago         564MB
    ```
    
    </details>
    </br>


3. Run an instance of the image webapp-color and publish port 8080 on the container to 8282 on the host.

    ```bash
    $ docker images | grep webapp
    webapp-color                    latest        ea2b85406064   2 minutes ago   913MB 
    ```

    <details><summary> Answer </summary>
    
    Use docker run, and then for exposing the port: 

    ```bash
    docker run -p <host-port>:<container:port>
    ```
    ```bash
    $ docker run -p 8282:8080 webapp-color             
    This is a sample web application that displays a colored background. 
    A color can be specified in two ways. 

    1. As a command line argument with --color as the argument. Accepts one of red,green,blue,blue2,pink,darkblue 
    2. As an Environment variable APP_COLOR. Accepts one of red,green,blue,blue2,pink,darkblue 
    3. If none of the above then a random color is picked from the above list. 
    Note: Command line argument precedes over environment variable.


    No command line argument or environment variable. Picking a Random Color =green
    * Serving Flask app 'app' (lazy loading)
    * Environment: production
    WARNING: This is a development server. Do not use it in a production deployment.
    Use a production WSGI server instead.
    * Debug mode: off
    * Running on all addresses.
    WARNING: This is a development server. Do not use it in a production deployment.
    * Running on http://172.12.0.2:8080/ (Press CTRL+C to quit)
    ```
    
    </details>
    </br>


4. What is the base Operating System used by the python:3.6 image?

    ```bash
    $ docker images | grep python
    python                          3.6           54260638d07c   2 years ago     902MB 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    $ docker run python:3.6 cat /etc/*release*

    PRETTY_NAME="Debian GNU/Linux 11 (bullseye)"
    NAME="Debian GNU/Linux"
    VERSION_ID="11"
    VERSION="11 (bullseye)"
    VERSION_CODENAME=bullseye
    ID=debian
    HOME_URL="https://www.debian.org/"
    SUPPORT_URL="https://www.debian.org/support"
    BUG_REPORT_URL="https://bugs.debian.org/"
    ```
    
    </details>
    </br>


5. Build a new smaller docker image by modifying the same Dockerfile and name it webapp-color and tag it lite.

    Find a smaller base image for python:3.6. Make sure the final image is less than 150MB.

    Hint: Use python:3.6-alpine

    ```bash
    $ cd webapp-color/
    $ ls -l
    total 16
    -rw-r--r-- 1 root root  113 Jan  6 04:18 Dockerfile
    -rw-r--r-- 1 root root 2259 Jan  6 04:18 app.py
    -rw-r--r-- 1 root root    5 Jan  6 04:18 requirements.txt
    drwxr-xr-x 2 root root 4096 Jan  6 04:18 templates
    $ 
    $ cat Dockerfile 
    FROM python:3.6

    RUN pip install flask

    COPY . /opt/

    EXPOSE 8080

    WORKDIR /opt

    ENTRYPOINT ["python", "app.py"] 
    ```

    <details><summary> Answer </summary>
    
    Edit the Dockerfile. 

    ```bash
    FROM python:3.6-alpine
    
    RUN pip install flask

    COPY . /opt/

    EXPOSE 8080

    WORKDIR /opt

    ENTRYPOINT ["python", "app.py"]
    ```

    Build the image.

    ```bash
    $ docker build -t webapp-color:lite .
    Sending build context to Docker daemon  125.4kB
    Step 1/6 : FROM python:3.6-alpine
    3.6-alpine: Pulling from library/python
    59bf1c3509f3: Pull complete 
    8786870f2876: Pull complete 
    acb0e804800e: Pull complete 
    52bedcb3e853: Pull complete 
    b064415ed3d7: Pull complete

    $ docker images | grep lite
    webapp-color                    lite          a56a7c8ff6ff   15 seconds ago   51.9MB
    ```
    
    </details>
    </br>


6. Run an instance of the new image webapp-color:lite and publish port 8080 on the container to 8383 on the host.

    ```bash
    $ docker images | grep lite
    webapp-color                    lite          a56a7c8ff6ff   About a minute ago   51.9MB 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    docker run -p 8383:8080 webapp-color:lite
    ```
    
    </details>
    </br>


7. I would like to use the dev-user to access test-cluster-1. Set the current context to the right one so I can do that.

    ```bash
    controlplane ~ ➜  k config get-contexts --kubeconfig my-kube-config
    CURRENT   NAME                         CLUSTER             AUTHINFO    NAMESPACE
            aws-user@kubernetes-on-aws   kubernetes-on-aws   aws-user    
            research                     test-cluster-1      dev-user    
    *         test-user@development        development         test-user   
            test-user@production         production          test-user  
    ```
        
    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k config use-context research --kubeconfig my-kube-config
    Switched to context "research".

    controlplane ~ ➜  k config get-contexts --kubeconfig my-kube-config
    CURRENT   NAME                         CLUSTER             AUTHINFO    NAMESPACE
            aws-user@kubernetes-on-aws   kubernetes-on-aws   aws-user    
    *         research                     test-cluster-1      dev-user    
            test-user@development        development         test-user   
            test-user@production         production          test-user 
    ```
    
    </details>
    </br>


8. Inspect the environment and identify the authorization modes configured on the cluster.<details><summary> Answer </summary>

    ```bash
    controlplane ~ ✦ ➜  k get po -n kube-system 
    NAME                                   READY   STATUS    RESTARTS   AGE
    coredns-5d78c9869d-5vk8b               1/1     Running   0          8m31s
    coredns-5d78c9869d-snn5g               1/1     Running   0          8m31s
    etcd-controlplane                      1/1     Running   0          8m38s
    kube-apiserver-controlplane            1/1     Running   0          8m46s
    kube-controller-manager-controlplane   1/1     Running   0          8m42s
    kube-proxy-65s6j                       1/1     Running   0          8m31s
    kube-scheduler-controlplane            1/1     Running   0          8m43s 
    ```
    
    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ✦ ✖ k describe -n kube-system po kube-apiserver-controlplane | grep -i auth
        --authorization-mode=Node,RBAC
        --enable-bootstrap-token-auth=true 
    ```
    
    </details>
    </br>


9. What are the resources the kube-proxy role in the kube-system namespace is given access to?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ✦ ➜  k get roles -A | grep kube-proxy
    kube-system   kube-proxy                                       2024-01-06T04:39:22Z

    controlplane ~ ✦ ➜  k describe role -n kube-system kube-proxy 
    Name:         kube-proxy
    Labels:       <none>
    Annotations:  <none>
    PolicyRule:
    Resources   Non-Resource URLs  Resource Names  Verbs
    ---------   -----------------  --------------  -----
    configmaps  []                 [kube-proxy]    [get] 
    ```
    
    </details>
    </br>


10. Which account is the kube-proxy role assigned to?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ✦ ➜  k get rolebinding -A | grep kube-proxy
    kube-system   kube-proxy                                          Role/kube-proxy                                       12m

    controlplane ~ ✦ ➜  k describe rolebinding -n kube-system kube-proxy 
    Name:         kube-proxy
    Labels:       <none>
    Annotations:  <none>
    Role:
    Kind:  Role
    Name:  kube-proxy
    Subjects:
    Kind   Name                                             Namespace
    ----   ----                                             ---------
    Group  system:bootstrappers:kubeadm:default-node-token   
    ```
    
    </details>
    </br>


11. Create the necessary roles and role bindings required for the dev-user to create, list and delete pods in the default namespace. Use the given spec:

    - Role: developer

    - Role Resources: pods

    - Role Actions: list

    - Role Actions: create

    - Role Actions: delete

    - RoleBinding: dev-user-binding

    - RoleBinding: Bound to dev-user

    <details><summary> Answer </summary>
    
    ```yaml
    controlplane ~ ✦ ➜  k create role developer --verb "list,create,delete" --resource "pods" $do
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
    creationTimestamp: null
    name: developer
    rules:
    - apiGroups:
    - ""
    resources:
    - pods
    verbs:
    - list
    - create
    - delete

    controlplane ~ ✦ ➜  k create role developer --verb "list,create,delete" --resource "pods"
    role.rbac.authorization.k8s.io/developer created

    controlplane ~ ✦ ➜  k create rolebinding dev-user-binding --role developer --user dev-user $do
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
    creationTimestamp: null
    name: dev-user-binding
    roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: Role
    name: developer
    subjects:
    - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: dev-user

    controlplane ~ ✦ ➜  k create rolebinding dev-user-binding --role developer --user dev-user
    rolebinding.rbac.authorization.k8s.io/dev-user-binding created
    ```

    </details>
    </br>


12. Which admission controller is enabled by default?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k describe -n kube-system po kube-apiserver-controlplane  | grep -i admission
        --enable-admission-plugins=NodeRestriction 
    ```
    
    </details>
    </br>



13. NamespaceExists admission controller enabled which rejects requests to namespaces that do not exist. So, to create a namespace that does not exist automatically, we could enable the NamespaceAutoProvision admission controller

    Enable the NamespaceAutoProvision admission controller.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  ls -l /etc/kubernetes/manifests/
    total 16
    -rw------- 1 root root 2399 Jan  6 00:08 etcd.yaml
    -rw------- 1 root root 3877 Jan  6 00:08 kube-apiserver.yaml
    -rw------- 1 root root 3393 Jan  6 00:08 kube-controller-manager.yaml
    -rw------- 1 root root 1463 Jan  6 00:08 kube-scheduler.yaml

    controlplane ~ ➜  cd /etc/kubernetes/manifests/ 
    ```

    Modify the kube-apiserver YAML file. 

    ```bash
    apiVersion: v1
    kind: Pod
    metadata:
    annotations:
        kubeadm.kubernetes.io/kube-apiserver.advertise-address.endpoint: 192.7.174.8:6443
    creationTimestamp: null
    labels:
        component: kube-apiserver
        tier: control-plane
    name: kube-apiserver
    namespace: kube-system
    spec:
    containers:
    - command:
        - kube-apiserver
        - --advertise-address=192.7.174.8
        - --allow-privileged=true
        - --authorization-mode=Node,RBAC
        - --client-ca-file=/etc/kubernetes/pki/ca.crt
        - --enable-admission-plugins=NodeRestriction,NamespaceAutoProvision
    ```
    Once you update kube-apiserver yaml file, please wait for a few minutes for the kube-apiserver to restart completely.

    ```bash
    controlplane /etc/kubernetes/manifests ➜  k get po -n kube-system 
    NAME                                   READY   STATUS    RESTARTS      AGE
    coredns-5d78c9869d-bqnjq               1/1     Running   0             14m
    coredns-5d78c9869d-wxjg5               1/1     Running   0             14m
    etcd-controlplane                      1/1     Running   0             14m
    kube-apiserver-controlplane            0/1     Pending   0             8s
    kube-controller-manager-controlplane   1/1     Running   1 (33s ago)   14m
    kube-proxy-jld6s                       1/1     Running   0             14m
    kube-scheduler-controlplane            1/1     Running   1 (32s ago)   14m  
    ```

    Verify: 

    ```bash
    controlplane /etc/kubernetes/manifests ➜  k get ns
    NAME              STATUS   AGE
    default           Active   15m
    kube-flannel      Active   15m
    kube-node-lease   Active   15m
    kube-public       Active   15m
    kube-system       Active   15m  

    controlplane /etc/kubernetes/manifests ➜ k run nginx --image nginx -n testing
    pod/nginx created

    controlplane /etc/kubernetes/manifests ➜  k get ns
    NAME              STATUS   AGE
    default           Active   15m
    kube-flannel      Active   15m
    kube-node-lease   Active   15m
    kube-public       Active   15m
    kube-system       Active   15m
    testing           Active   3s
    ```
    
    </details>
    </br>



14. Disable DefaultStorageClass admission controller
    This admission controller observes creation of PersistentVolumeClaim objects that do not request any specific storage class and automatically adds a default storage class to them. This way, users that do not request any special storage class do not need to care about them at all and they will get the default one.

    <details><summary> Answer </summary>
    
    ```bash
    apiVersion: v1
    kind: Pod
    metadata:
    annotations:
        kubeadm.kubernetes.io/kube-apiserver.advertise-address.endpoint: 192.7.174.8:6443
    creationTimestamp: null
    labels:
        component: kube-apiserver
        tier: control-plane
    name: kube-apiserver
    namespace: kube-system
    spec:
    containers:
    - command:
        - kube-apiserver
        - --advertise-address=192.7.174.8
        - --allow-privileged=true
        - --authorization-mode=Node,RBAC
        - --client-ca-file=/etc/kubernetes/pki/ca.crt
        - --enable-admission-plugins=NodeRestriction,NamespaceAutoProvision
        - --disable-admission-plugins=DefaultStorageClass
    ```
    
    </details>
    </br>



15. Create TLS secret webhook-server-tls for secure webhook communication in webhook-demo namespace.

    - Certificate : /root/keys/webhook-server-tls.crt

    - Key : /root/keys/webhook-server-tls.key

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k create secret tls webhook-server-tls --namespace webhook-demo --cert /root/keys/webhook-server-tls.crt --key /root/keys/webhook-server-tls.key 
    secret/webhook-server-tls created

    controlplane ~ ➜  k get secrets -n webhook-demo 
    NAME                 TYPE                DATA   AGE
    webhook-server-tls   kubernetes.io/tls   2      8s
    ```
    
    </details>
    </br>



16. Enable the v1alpha1 version for rbac.authorization.k8s.io API group on the controlplane node.

17. Create a custom resource called datacenter and the apiVersion should be traffic.controller/v1.

    Set the dataField length to 2 and access permission should be true


    <details><summary> Answer </summary>
    

    ```yaml
    ## datacenter.yml
    kind: Global 
    apiVersion: traffic.controller/v1
    metadata:
    name: datacenter
    spec:
    dataField: 2
    access: true
    ```
    ```bash
    controlplane ~ ➜  k apply -f datacenter.yml 
    global.traffic.controller/datacenter created 
    ```
    ```bash
    controlplane ~ ➜  k get global
    NAME         AGE
    datacenter   64s 
    ```

    
    </details>
    </br>



18. A deployment has been created in the default namespace. What is the deployment strategy used for this deployment?

    ```bash
    controlplane ~ ➜  k get deployments.apps 
    NAME       READY   UP-TO-DATE   AVAILABLE   AGE
    frontend   5/5     5            5           95s 
    ```
        
    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k describe deployments.apps frontend | grep -i strategy
    StrategyType:           RollingUpdate
    RollingUpdateStrategy:  25% max unavailable, 25% max surge 
    ```
    
    </details>
    </br>



19. What is the selector used by the **frontend-service** service?

    ```bash
    controlplane ~ ➜  k get svc
    NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
    frontend-service   NodePort    10.104.213.172   <none>        8080:30080/TCP   2m26s
    kubernetes         ClusterIP   10.96.0.1        <none>        443/TCP          7m27s 
    ```


    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k describe svc frontend-service | grep -i selector
    Selector:                 app=frontend 
    ```
    
    </details>
    </br>


20. A new deployment called frontend-v2 has been created in the default namespace using the image kodekloud/webapp-color:v2. This deployment will be used to test a newer version of the same app.

    Configure the deployment in such a way that the service called frontend-service routes less than 20% of traffic to the new deployment.

    Do not increase the replicas of the frontend deployment.

    ```bash
    controlplane ~ ➜  k get deployments.apps 
    NAME          READY   UP-TO-DATE   AVAILABLE   AGE
    frontend      5/5     5            5           4m23s
    frontend-v2   2/2     2            2           21s 
    ```

    <details><summary> Answer </summary>

    The frontend deployment currently has 7 replicas
    The frontend-v2 deployment currently has 2 replicas
    In total, there are 7 replicas or 7 pods.  

    The frontend-service distributes the traffice to all 7 pods equally, which means:

    - per 1 pod = 14.28% of the traffic

    - frontend deployment:
        5 pods = 71.4% of the traffic

    - frontend-v2 deployment:
        2 pods = 28.56% of the traffic 

    If we want to reduce the percent of traffic being directed to frontend-v2 deployment, scale down the replica to 2, which means:

    - per 1 pod = 16.66% of the traffic

    - frontend deployment:
        5 pods = 83.3% of the traffic

    - frontend-v2 deployment:
        2 pods = 16.66% of the traffic 

    Scale down the frontend-v2 to 1 replica. 

    ```bash
    controlplane ~ ➜  k scale deployment frontend-v2 --replicas 1
    deployment.apps/frontend-v2 scaled

    controlplane ~ ➜  k get deployments.apps 
    NAME          READY   UP-TO-DATE   AVAILABLE   AGE
    frontend      5/5     5            5           5m47s
    frontend-v2   1/1     1            1           105s 
    ```
    
    </details>
    </br>


21. Search for a wordpress helm chart package from the Artifact Hub.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  helm search --help

    Usage:
    helm search [command]

    Available Commands:
    hub         search for charts in the Artifact Hub or your own hub instance
    repo        search repositories for a keyword in charts

    controlplane ~ ➜  helm search hub --help

    Usage:
    helm search hub [KEYWORD] [flags]
    ```
    ```bash
    helm search hub wordpress 
    ```
    
    </details>
    </br>


22. Add a bitnami helm chart repository in the controlplane node.

    - name - bitnami

    - chart repo name - https://charts.bitnami.com/bitnami

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  helm repo add --help
    add a chart repository

    Usage:
    helm repo add [NAME] [URL] [flags] 

    controlplane ~ ➜  helm repo add bitnami https://charts.bitnami.com/bitnami
    "bitnami" has been added to your repositories

    controlplane ~ ➜  helm list
    NAME    NAMESPACE       REVISION        UPDATED STATUS  CHART   APP VERSION

    controlplane ~ ➜  helm repo list
    NAME    URL                               
    bitnami https://charts.bitnami.com/bitnami  
    ```
    
    </details>
    </br>



23. What command is used to search for the joomla package from the added repository?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  helm repo list
    NAME    URL                               
    bitnami https://charts.bitnami.com/bitnami

    controlplane ~ ➜  helm search --help

    Search provides the ability to search for Helm charts in the various places
    they can be stored including the Artifact Hub and repositories you have added.
    Use search subcommands to search different locations for charts.

    Usage:
    helm search [command]

    Available Commands:
    hub         search for charts in the Artifact Hub or your own hub instance
    repo        search repositories for a keyword in charts

    controlplane ~ ➜  helm search repo joomla
    NAME            CHART VERSION   APP VERSION     DESCRIPTION                                       
    bitnami/joomla  18.0.0          5.0.1           Joomla! is an award winning open source CMS pla...

    ```
    
    </details>
    </br>



24. Install drupal helm chart from the bitnami repository.

    - Release name should be bravo.

    - Chart name should be bitnami/drupal.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  helm install --help

    Usage:
    helm install [NAME] [CHART] [flags]

    controlplane ~ ➜  helm install bitnami/drupal bravo
    Error: INSTALLATION FAILED: non-absolute URLs should be in form of repo_name/path_to_chart, got: bravo

    controlplane ~ ➜ helm install bravo bitnami/drupal 
    NAME: bravo
    LAST DEPLOYED: Sat Jan  6 02:43:29 2024
    NAMESPACE: default
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    NOTES:
    CHART NAME: drupal
    CHART VERSION: 17.0.0
    APP VERSION: 10.2.0** Please be patient while the chart is being deployed **
    ```
    
    </details>
    </br>


25. Uninstall the drupal helm package which was installed in the previous question.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  helm uninstall bravo
    release "bravo" uninstalled
    ```
    
    </details>
    </br>


26. Download the bitnami apache package under the /root directory.
    Note: Do not install the package. Just download it.

    ```bash
    controlplane ~ ➜  helm repo list
    NAME            URL                                                 
    bitnami         https://charts.bitnami.com/bitnami                  
    puppet          https://puppetlabs.github.io/puppetserver-helm-chart
    hashicorp       https://helm.releases.hashicorp.com    
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  helm search repo apache
    NAME                            CHART VERSION   APP VERSION     DESCRIPTION                                       
    bitnami/apache                  10.2.4          2.4.58          Apache HTTP Server is an open-source HTTP serve...
    bitnami/airflow                 16.1.10         2.8.0           Apache Airflow is a tool to express and execute...
    bitnami/apisix                  2.2.8           3.7.0           Apache APISIX is high-performance, real-time AP...
    bitnami/cassandra               10.6.8          4.1.3           Apache Cassandra is an open source distributed ...
    bitnami/dataplatform-bp2        12.0.5          1.0.1           DEPRECATED This Helm chart can be used for the ...
    bitnami/flink                   0.5.3           1.18.0          Apache Flink is a framework and distributed pro...
    bitnami/geode                   1.1.8           1.15.1          DEPRECATED Apache Geode is a data management pl...
    bitnami/kafka                   26.6.2          3.6.1           Apache Kafka is a distributed streaming platfor...
    bitnami/mxnet                   3.5.2           1.9.1           DEPRECATED Apache MXNet (Incubating) is a flexi...
    bitnami/schema-registry         16.2.6          7.5.3           Confluent Schema Registry provides a RESTful in...
    bitnami/solr                    8.3.4           9.4.0           Apache Solr is an extremely powerful, open sour...
    bitnami/spark                   8.1.7           3.5.0           Apache Spark is a high-performance engine for l...
    bitnami/tomcat                  10.11.10        10.1.17         Apache Tomcat is an open-source web server desi...
    bitnami/zookeeper               12.4.1          3.9.1           Apache ZooKeeper provides a reliable, centraliz...

    controlplane ~ ➜  helm pull --help

    Retrieve a package from a package repository, and download it locally.
    Usage:
    helm pull [chart URL | repo/chartname] [...] [flags]

    controlplane ~ ➜  helm pull bitnami/apache  

    controlplane ~ ➜  ls -l
    total 36
    -rw-r--r-- 1 root root 35248 Jan  6 02:48 apache-10.2.4.tgz

    controlplane ~ ➜  tar -xf apache-10.2.4.tgz 

    controlplane ~ ➜  ls -l
    total 40
    drwxr-xr-x 5 root root  4096 Jan  6 02:49 apache
    -rw-r--r-- 1 root root 35248 Jan  6 02:48 apache-10.2.4.tgz
    ```
    
    </details>
    </br>


[Back to the top](#practice-test-ckad)    

