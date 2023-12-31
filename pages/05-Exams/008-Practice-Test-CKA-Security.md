
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


## Security 

1. Identify the certificate file used for the kube-api server.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po -A
    NAMESPACE      NAME                                   READY   STATUS    RESTARTS   AGE
    kube-flannel   kube-flannel-ds-rvnsq                  1/1     Running   0          4m43s
    kube-system    coredns-5d78c9869d-q28bn               1/1     Running   0          4m43s
    kube-system    coredns-5d78c9869d-sdgcj               1/1     Running   0          4m43s
    kube-system    etcd-controlplane                      1/1     Running   0          4m54s
    kube-system    kube-apiserver-controlplane            1/1     Running   0          4m57s
    kube-system    kube-controller-manager-controlplane   1/1     Running   0          4m54s
    kube-system    kube-proxy-5ngt7                       1/1     Running   0          4m43s
    kube-system    kube-scheduler-controlplane            1/1     Running   0          4m58s

    controlplane ~ ➜  k describe -n kube-system po kube-apiserver-controlplane | grep -i cert
        --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
        --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt
        --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt
        --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
        /etc/ca-certificates from etc-ca-certificates (ro)
        /etc/kubernetes/pki from k8s-certs (ro)
        /etc/ssl/certs from ca-certs (ro)
        /usr/local/share/ca-certificates from usr-local-share-ca-certificates (ro)
        /usr/share/ca-certificates from usr-share-ca-certificates (ro)
    ca-certs:
        Path:          /etc/ssl/certs
    etc-ca-certificates:
        Path:          /etc/ca-certificates
    k8s-certs:
    usr-local-share-ca-certificates:
        Path:          /usr/local/share/ca-certificates
    usr-share-ca-certificates:
        Path:          /usr/share/ca-certificates

    controlplane ~ ➜  k describe -n kube-system po kube-apiserver-controlplane | grep -i cert | grep api
        --tls-cert-file=/etc/kubernetes/pki/apiserver.crt 
    ```
    
    </details>
    </br>


2. Identify the Certificate file used to authenticate kube-apiserver as a client to ETCD Server.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po -A
    NAMESPACE      NAME                                   READY   STATUS    RESTARTS   AGE
    kube-flannel   kube-flannel-ds-rvnsq                  1/1     Running   0          4m43s
    kube-system    coredns-5d78c9869d-q28bn               1/1     Running   0          4m43s
    kube-system    coredns-5d78c9869d-sdgcj               1/1     Running   0          4m43s
    kube-system    etcd-controlplane                      1/1     Running   0          4m54s
    kube-system    kube-apiserver-controlplane            1/1     Running   0          4m57s
    kube-system    kube-controller-manager-controlplane   1/1     Running   0          4m54s
    kube-system    kube-proxy-5ngt7                       1/1     Running   0          4m43s
    kube-system    kube-scheduler-controlplane            1/1     Running   0          4m58s

    controlplane ~ ➜  k describe -n kube-system po kube-apiserver-controlplane | grep -i cert | grep api
        --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt
    ```
    
    </details>
    </br>


3. Identify the key used to authenticate kubeapi-server to the kubelet server.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po -A
    NAMESPACE      NAME                                   READY   STATUS    RESTARTS   AGE
    kube-flannel   kube-flannel-ds-rvnsq                  1/1     Running   0          4m43s
    kube-system    coredns-5d78c9869d-q28bn               1/1     Running   0          4m43s
    kube-system    coredns-5d78c9869d-sdgcj               1/1     Running   0          4m43s
    kube-system    etcd-controlplane                      1/1     Running   0          4m54s
    kube-system    kube-apiserver-controlplane            1/1     Running   0          4m57s
    kube-system    kube-controller-manager-controlplane   1/1     Running   0          4m54s
    kube-system    kube-proxy-5ngt7                       1/1     Running   0          4m43s
    kube-system    kube-scheduler-controlplane            1/1     Running   0          4m58s

    controlplane ~ ➜  k describe -n kube-system po kube-apiserver-controlplane | grep -i key
        --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
        --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key 
    ```
    
    </details>
    </br>


4. Identify the ETCD Server Certificate used to host ETCD server.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po -A
    NAMESPACE      NAME                                   READY   STATUS    RESTARTS   AGE
    kube-flannel   kube-flannel-ds-rvnsq                  1/1     Running   0          4m43s
    kube-system    coredns-5d78c9869d-q28bn               1/1     Running   0          4m43s
    kube-system    coredns-5d78c9869d-sdgcj               1/1     Running   0          4m43s
    kube-system    etcd-controlplane                      1/1     Running   0          4m54s
    kube-system    kube-apiserver-controlplane            1/1     Running   0          4m57s
    kube-system    kube-controller-manager-controlplane   1/1     Running   0          4m54s
    kube-system    kube-proxy-5ngt7                       1/1     Running   0          4m43s
    kube-system    kube-scheduler-controlplane            1/1     Running   0          4m58s 

    controlplane ~ ➜  k describe -n kube-system po etcd-controlplane | grep -i cert
        --cert-file=/etc/kubernetes/pki/etcd/server.crt
    ```
    
    </details>
    </br>


5. Identify the ETCD Server CA Root Certificate used to serve ETCD Server.
    ETCD can have its own CA. So this may be a different CA certificate than the one used by kube-api server.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po -A
    NAMESPACE      NAME                                   READY   STATUS    RESTARTS   AGE
    kube-flannel   kube-flannel-ds-rvnsq                  1/1     Running   0          4m43s
    kube-system    coredns-5d78c9869d-q28bn               1/1     Running   0          4m43s
    kube-system    coredns-5d78c9869d-sdgcj               1/1     Running   0          4m43s
    kube-system    etcd-controlplane                      1/1     Running   0          4m54s
    kube-system    kube-apiserver-controlplane            1/1     Running   0          4m57s
    kube-system    kube-controller-manager-controlplane   1/1     Running   0          4m54s
    kube-system    kube-proxy-5ngt7                       1/1     Running   0          4m43s
    kube-system    kube-scheduler-controlplane            1/1     Running   0          4m58s 

    controlplane ~ ➜  k describe -n kube-system po etcd-controlplane | grep -i ca
    Priority Class Name:  system-node-critical
        --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
        --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
    ```
    
    </details>
    </br>


6. What is the Common Name (CN) configured on the Kube API Server Certificate?

    <details><summary> Answer </summary>

    Find the kube-api server cert first. 

    ```bash
    controlplane ~ ➜  k get po -A
    NAMESPACE      NAME                                   READY   STATUS    RESTARTS   AGE
    kube-flannel   kube-flannel-ds-rvnsq                  1/1     Running   0          15m
    kube-system    coredns-5d78c9869d-q28bn               1/1     Running   0          15m
    kube-system    coredns-5d78c9869d-sdgcj               1/1     Running   0          15m
    kube-system    etcd-controlplane                      1/1     Running   0          16m
    kube-system    kube-apiserver-controlplane            1/1     Running   0          16m
    kube-system    kube-controller-manager-controlplane   1/1     Running   0          16m
    kube-system    kube-proxy-5ngt7                       1/1     Running   0          15m
    kube-system    kube-scheduler-controlplane            1/1     Running   0          16m

    controlplane ~ ➜  k describe -n kube-system po kube-apiserver-controlplane | grep cert
        --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
    ```

    Based on: https://kubernetes.io/docs/tasks/administer-cluster/certificates/
    Use the openssl command to view the certificate. 

    ```bash
    openssl x509  -noout -text -in /etc/kubernetes/pki/apiserver.crt
    ```

    The answer is kube-apiserver.

    ```bash
    controlplane ~ ➜  openssl x509  -noout -text -in /etc/kubernetes/pki/apiserver.crt | grep CN
            Issuer: CN = kubernetes
            Subject: CN = kube-apiserver
    ```
    
    </details>
    </br>


7. What are the alternate names configured on the Kube API Server Certificate?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  openssl x509  -noout -text -in /etc/kubernetes/pki/apiserver.crt | grep -i alternative -A 10
                X509v3 Subject Alternative Name: 
                    DNS:controlplane, DNS:kubernetes, DNS:kubernetes.default, DNS:kubernetes.default.svc, DNS:kubernetes.default.svc.cluster.local, IP Address:10.96.0.1, IP Address:192.20.62.6 
    ```
    
    </details>
    </br>


8. What is the Common Name (CN) configured on the ETCD Server certificate?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po -A
    NAMESPACE      NAME                                   READY   STATUS    RESTARTS   AGE
    kube-flannel   kube-flannel-ds-rvnsq                  1/1     Running   0          20m
    kube-system    coredns-5d78c9869d-q28bn               1/1     Running   0          20m
    kube-system    coredns-5d78c9869d-sdgcj               1/1     Running   0          20m
    kube-system    etcd-controlplane                      1/1     Running   0          21m
    kube-system    kube-apiserver-controlplane            1/1     Running   0          21m
    kube-system    kube-controller-manager-controlplane   1/1     Running   0          21m
    kube-system    kube-proxy-5ngt7                       1/1     Running   0          20m
    kube-system    kube-scheduler-controlplane            1/1     Running   0          21m

    controlplane ~ ➜  k describe -n kube-system po etcd-controlplane | grep cert
        --cert-file=/etc/kubernetes/pki/etcd/server.crt 
    ```

    Based on: https://kubernetes.io/docs/tasks/administer-cluster/certificates/
    Use the openssl command to view the certificate. 

    ```bash
    openssl x509  -noout -text -in /etc/kubernetes/pki/etcd/server.crt 
    ```

    The answer is the controlplane. Issuer is the CA.

    ```bash
    controlplane ~ ➜  openssl x509  -noout -text -in /etc/kubernetes/pki/etcd/server.crt | grep CN
            Issuer: CN = etcd-ca
            Subject: CN = controlplane  
    ``` 
    </details>
    </br>


9. How long, from the issued date, is the Kube-API Server Certificate valid for?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po -A
    NAMESPACE      NAME                                   READY   STATUS    RESTARTS   AGE
    kube-flannel   kube-flannel-ds-rvnsq                  1/1     Running   0          20m
    kube-system    coredns-5d78c9869d-q28bn               1/1     Running   0          20m
    kube-system    coredns-5d78c9869d-sdgcj               1/1     Running   0          20m
    kube-system    etcd-controlplane                      1/1     Running   0          21m
    kube-system    kube-apiserver-controlplane            1/1     Running   0          21m
    kube-system    kube-controller-manager-controlplane   1/1     Running   0          21m
    kube-system    kube-proxy-5ngt7                       1/1     Running   0          20m
    kube-system    kube-scheduler-controlplane            1/1     Running   0          21m

    controlplane ~ ➜  k describe -n kube-system po kube-apiserver-controlplane | grep cert
        --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
    ```

    Based on: https://kubernetes.io/docs/tasks/administer-cluster/certificates/
    Use the openssl command to view the certificate. 

    ```bash
    openssl x509  -noout -text -in /etc/kubernetes/pki/apiserver.crt
    ```
    ```bash
    controlplane ~ ➜  openssl x509  -noout -text -in /etc/kubernetes/pki/apiserver.crt | grep -i validity -A 5
            Validity
                Not Before: Dec 30 13:41:34 2023 GMT
                Not After : Dec 29 13:41:34 2024 GMT
    ```
    
    </details>
    </br>


10. How long, from the issued date, is the Root CA Certificate valid for?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po -A
    NAMESPACE      NAME                                   READY   STATUS    RESTARTS   AGE
    kube-flannel   kube-flannel-ds-rvnsq                  1/1     Running   0          25m
    kube-system    coredns-5d78c9869d-q28bn               1/1     Running   0          25m
    kube-system    coredns-5d78c9869d-sdgcj               1/1     Running   0          25m
    kube-system    etcd-controlplane                      1/1     Running   0          26m
    kube-system    kube-apiserver-controlplane            1/1     Running   0          26m
    kube-system    kube-controller-manager-controlplane   1/1     Running   0          26m
    kube-system    kube-proxy-5ngt7                       1/1     Running   0          25m
    kube-system    kube-scheduler-controlplane            1/1     Running   0          26m

    controlplane ~ ➜  k describe -n kube-system po kube-apiserver-controlplane | grep ca
    Priority Class Name:  system-node-critical
        Image ID:      registry.k8s.io/kube-apiserver@sha256:89b8d9dbef2b905b7d028ca8b7f79d35ebd9baa66b0a3ee2ddd4f3e0e2804b45
        --client-ca-file=/etc/kubernetes/pki/ca.crt 
    ```
    Based on: https://kubernetes.io/docs/tasks/administer-cluster/certificates/
    Use the openssl command to view the certificate. 

    ```bash
    openssl x509  -noout -text -in /etc/kubernetes/pki/ca.crt 
    ```
        
    ```bash
    controlplane ~ ➜  openssl x509  -noout -text -in /etc/kubernetes/pki/ca.crt | grep -i validity -A 3
            Validity
                Not Before: Dec 30 13:41:34 2023 GMT
                Not After : Dec 27 13:41:34 2033 GMT
    ```
    
    </details>
    </br>


11. Kubectl suddenly stops responding to your commands. Check it out! Someone recently modified the /etc/kubernetes/manifests/etcd.yaml file

    You are asked to investigate and fix the issue. Once you fix the issue wait for sometime for kubectl to respond. Check the logs of the ETCD container.

    <details><summary> Answer </summary>

    Check the certs. 

    ```bash
    controlplane ~ ➜  grep cert /etc/kubernetes/manifests/etcd.yaml
        - --cert-file=/etc/kubernetes/pki/etcd/server-certificate.crt
        - --client-cert-auth=true
        - --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt
        - --peer-client-cert-auth=true
        name: etcd-certs
        name: etcd-certs

    controlplane ~ ➜  ls -la /etc/kubernetes/pki/etcd/
    total 40
    drwxr-xr-x 2 root root 4096 Dec 30 08:41 .
    drwxr-xr-x 3 root root 4096 Dec 30 08:41 ..
    -rw-r--r-- 1 root root 1086 Dec 30 08:41 ca.crt
    -rw------- 1 root root 1679 Dec 30 08:41 ca.key
    -rw-r--r-- 1 root root 1159 Dec 30 08:41 healthcheck-client.crt
    -rw------- 1 root root 1675 Dec 30 08:41 healthcheck-client.key
    -rw-r--r-- 1 root root 1208 Dec 30 08:41 peer.crt
    -rw------- 1 root root 1679 Dec 30 08:41 peer.key
    -rw-r--r-- 1 root root 1208 Dec 30 08:41 server.crt
    -rw------- 1 root root 1679 Dec 30 08:41 server.key 
    ```

    We can see above that the server cert defined is incorrect. Fix the YAML file. 

    ```bash
    --cert-file=/etc/kubernetes/pki/etcd/server.crt
    ```

    </details>
    </br>


12. The kube-api server stopped again! Check it out. Inspect the kube-api server logs and identify the root cause and fix the issue. Hint: Find the kube-apiserver container.

    <details><summary> Answer </summary>

    We can use crictl. 

    ```bash
    controlplane ~ ➜  crictl ps -a | grep apiserver
    7ca09e4553971       6f707f569b572       2 minutes ago       Exited              kube-apiserver            5                   ec0124d62fe6d       kube-apiserver-controlplane
    ```

    Then check logs.

    ```bash
    controlplane ~ ➜  crictl logs 7ca09e4553971 | tail -1 

    W1230 14:21:08.206143       1 logging.go:59] [core] [Channel #3 SubChannel #6] grpc: addrConn.createTransport failed to connect to {
    "Addr": "127.0.0.1:2379",
    "ServerName": "127.0.0.1",
    "Attributes": null,
    "BalancerAttributes": null,
    "Type": 0,
    "Metadata": null
    }. Err: connection error: desc = "transport: authentication handshake failed: tls: failed to verify certificate: x509: certificate signed by unknown authority"
    E1230 14:21:10.930501       1 run.go:74] "command failed" err="context deadline exceeded"
    ```

    This could be an issue on the ETCD CA cert used. Check the certs.

    ```bash
    controlplane ~ ✖ ls -la /etc/kubernetes/pki/
    total 72
    drwxr-xr-x 3 root root 4096 Dec 30 08:41 .
    drwxr-xr-x 1 root root 4096 Dec 30 08:41 ..
    -rw-r--r-- 1 root root 1289 Dec 30 08:41 apiserver.crt
    -rw-r--r-- 1 root root 1155 Dec 30 08:41 apiserver-etcd-client.crt
    -rw------- 1 root root 1675 Dec 30 08:41 apiserver-etcd-client.key
    -rw------- 1 root root 1679 Dec 30 08:41 apiserver.key
    -rw-r--r-- 1 root root 1164 Dec 30 08:41 apiserver-kubelet-client.crt
    -rw------- 1 root root 1679 Dec 30 08:41 apiserver-kubelet-client.key
    -rw-r--r-- 1 root root 1099 Dec 30 08:41 ca.crt
    -rw------- 1 root root 1675 Dec 30 08:41 ca.key
    drwxr-xr-x 2 root root 4096 Dec 30 08:41 etcd
    -rw-r--r-- 1 root root 1115 Dec 30 08:41 front-proxy-ca.crt
    -rw------- 1 root root 1679 Dec 30 08:41 front-proxy-ca.key
    -rw-r--r-- 1 root root 1119 Dec 30 08:41 front-proxy-client.crt
    -rw------- 1 root root 1679 Dec 30 08:41 front-proxy-client.key
    -rw------- 1 root root 1675 Dec 30 08:41 sa.key
    -rw------- 1 root root  451 Dec 30 08:41 sa.pub  

    controlplane ~ ➜  ls -la /etc/kubernetes/pki/etcd/
    total 40
    drwxr-xr-x 2 root root 4096 Dec 30 08:41 .
    drwxr-xr-x 3 root root 4096 Dec 30 08:41 ..
    -rw-r--r-- 1 root root 1086 Dec 30 08:41 ca.crt
    -rw------- 1 root root 1679 Dec 30 08:41 ca.key
    -rw-r--r-- 1 root root 1159 Dec 30 08:41 healthcheck-client.crt
    -rw------- 1 root root 1675 Dec 30 08:41 healthcheck-client.key
    -rw-r--r-- 1 root root 1208 Dec 30 08:41 peer.crt
    -rw------- 1 root root 1679 Dec 30 08:41 peer.key
    -rw-r--r-- 1 root root 1208 Dec 30 08:41 server.crt
    -rw------- 1 root root 1679 Dec 30 08:41 server.key
    ```

    ```bash
    controlplane ~ ➜  ls -la /etc/kubernetes/manifests/
    total 28
    drwxr-xr-x 1 root root 4096 Dec 30 09:17 .
    drwxr-xr-x 1 root root 4096 Dec 30 08:41 ..
    -rw------- 1 root root 2399 Dec 30 09:16 etcd.yaml
    -rw------- 1 root root 3872 Dec 30 09:17 kube-apiserver.yaml
    -rw------- 1 root root 3393 Dec 30 08:41 kube-controller-manager.yaml
    -rw------- 1 root root 1463 Dec 30 08:41 kube-scheduler.yaml  

    controlplane ~ ➜  grep etcd /etc/kubernetes/manifests/kube-apiserver.yaml 
        - --etcd-cafile=/etc/kubernetes/pki/ca.crt
        - --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
        - --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
        - --etcd-servers=https://127.0.0.1:2379
    ```

    Fix the --etcd-cafile in the YAML file. 

    ```bash
    --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
    ```
    
    </details>
    </br>


13. A new member akshay joined our team. He requires access to our cluster. The Certificate Signing Request is at the /root location.

    - Create a CertificateSigningRequest object with the name akshay with the contents of the akshay.csr file

    - As of kubernetes 1.19, the API to use for CSR is certificates.k8s.io/v1.

    - Please note that an additional field called signerName should also be added when creating CSR. 
    
    - For **client authentication** to the API server we will use the built-in signer kubernetes.io/kube-apiserver-client.

    - Approve the CSR Request

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  ls -l
    total 8
    -rw-r--r-- 1 root root  887 Dec 30 09:36 akshay.csr
    -rw------- 1 root root 1679 Dec 30 09:36 akshay.key 
    ```

    Generate the base64 encoded format:

    ```bash
    controlplane ~ ➜  cat akshay.csr | base64 -w 0

    LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1ZqQ0NBVDRDQVFBd0VURVBNQTBHQTFVRUF3d0dZV3R6YUdGNU1JSUJJakFOQmdrcW
    ``` 

    Create the YAML file.
    Follow: https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/#create-a-certificatesigningrequest-object-to-send-to-the-kubernetes-api

    ```bash
    ## akshay-csr.yaml 
    apiVersion: certificates.k8s.io/v1
    kind: CertificateSigningRequest
    metadata:
      name: akshay
    spec:
      request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1ZqQ0NBVDRDQVFBd0VURVBNQTBHQTFVRUF3d0dZV3R6YUdGNU1JSUJJakFOQmdrcW
      signerName: kubernetes.io/kube-apiserver-client
      usages:
      - client auth 
    ``` 
    ```bash
    controlplane ~ ➜  k apply -f akshay-csr.yaml 
    certificatesigningrequest.certificates.k8s.io/akshay created

    controlplane ~ ➜  k get csr
    NAME        AGE   SIGNERNAME                                    REQUESTOR                  REQUESTEDDURATION   CONDITION
    akshay      8s    kubernetes.io/kube-apiserver-client           kubernetes-admin           <none>              Pending
    csr-fnjbq   20m   kubernetes.io/kube-apiserver-client-kubelet   system:node:controlplane   <none>              Approved,Issued 
        
    controlplane ~ ➜  kubectl certificate approve akshay
    certificatesigningrequest.certificates.k8s.io/akshay approved

    controlplane ~ ➜  k get csr
    NAME        AGE     SIGNERNAME                                    REQUESTOR                  REQUESTEDDURATION   CONDITION
    akshay      3m10s   kubernetes.io/kube-apiserver-client           kubernetes-admin           <none>              Approved,Issued
    csr-fnjbq   23m     kubernetes.io/kube-apiserver-client-kubelet   system:node:controlplane   <none>              Approved,Issued    
    ``` 

    </details>
    </br>


14. There is a new CSR. What groups is this CSR requesting access to? 

    - We need to reject it.
    - After rejecting, delete the CSR.

    ```bash
    controlplane ~ ➜  k get csr
    NAME          AGE     SIGNERNAME                                    REQUESTOR                  REQUESTEDDURATION   CONDITION
    agent-smith   7s      kubernetes.io/kube-apiserver-client           agent-x                    <none>              Pending
    akshay        4m13s   kubernetes.io/kube-apiserver-client           kubernetes-admin           <none>              Approved,Issued
    csr-fnjbq     24m     kubernetes.io/kube-apiserver-client-kubelet   system:node:controlplane   <none>              Approved,Issued 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get csr agent-smith -o yaml
    apiVersion: certificates.k8s.io/v1
    kind: CertificateSigningRequest
    metadata:
      creationTimestamp: "2023-12-30T14:54:23Z"
      name: agent-smith
    resourceVersion: "2368"
    uid: 91311095-f323-42a0-a704-db17451ef8ff
    spec:
      groups:
      - system:masters
      - system:authenticated
      request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1dEQ0NBVUFDQVFBd0V6RVJNQThHQTFVRUF3d0libVYzTFhWelpYSXdnZ0VpTUEwR0NTcUdTSWIzRFFFQgpBUVVBQTRJQkR3QXdnZ0VLQW9JQkFRRE8wV0pXK0RYc0FKU0lyanBObzV2UklCcGxuemcrNnhjOStVVndrS2kwCkxmQzI3dCsxZUVuT041TXVxOTlOZXZtTUVPbnJEVU8vdGh5VnFQMncyWE5JRFJYall5RjQwRmJtRCs1eld5Q0sKeTNCaWhoQjkzTUo3T3FsM1VUdlo4VEVMcXlhRGtuUmwvanYvU3hnWGtvazBBQlVUcFdNeDRCcFNpS2IwVSt0RQpJRjVueEF0dE1Wa0RQUTdOYmVaUkc0M2IrUVdsVkdSL3o2RFdPZkpuYmZlek90YUF5ZEdMVFpGQy93VHB6NTJrCkVjQ1hBd3FDaGpCTGt6MkJIUFI0Sjg5RDZYYjhrMzlwdTZqcHluZ1Y2dVAwdEliT3pwcU52MFkwcWRFWnB3bXcKajJxRUwraFpFV2trRno4MGxOTnR5VDVMeE1xRU5EQ25JZ3dDNEdaaVJHYnJBZ01CQUFHZ0FEQU5CZ2txaGtpRwo5dzBCQVFzRkFBT0NBUUVBUzlpUzZDMXV4VHVmNUJCWVNVN1FGUUhVemFsTnhBZFlzYU9SUlFOd0had0hxR2k0CmhPSzRhMnp5TnlpNDRPT2lqeWFENnRVVzhEU3hrcjhCTEs4S2czc3JSRXRKcWw1ckxaeTlMUlZyc0pnaEQ0Z1kKUDlOTCthRFJTeFJPVlNxQmFCMm5XZVlwTTVjSjVURjUzbGVzTlNOTUxRMisrUk1uakRRSjdqdVBFaWM4L2RoawpXcjJFVU02VWF3enlrcmRISW13VHYybWxNWTBSK0ROdFYxWWllKzBIOS9ZRWx0K0ZTR2poNUw1WVV2STFEcWl5CjRsM0UveTNxTDcxV2ZBY3VIM09zVnBVVW5RSVNNZFFzMHFXQ3NiRTU2Q0M1RGhQR1pJcFVibktVcEF3a2ErOEUKdndRMDdqRytocGtueG11RkFlWHhnVXdvZEFMYUo3anUvVERJY3c9PQotLS0tLUVORCBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0K
      signerName: kubernetes.io/kube-apiserver-client
      usages:
      - digital signature
      - key encipherment
      - server auth
    username: agent-x
    status: {} 

    controlplane ~ ➜  k get csr
    NAME          AGE     SIGNERNAME                                    REQUESTOR                  REQUESTEDDURATION   CONDITION
    agent-smith   2m53s   kubernetes.io/kube-apiserver-client           agent-x                    <none>              Pending
    akshay        6m59s   kubernetes.io/kube-apiserver-client           kubernetes-admin           <none>              Approved,Issued
    csr-fnjbq     27m     kubernetes.io/kube-apiserver-client-kubelet   system:node:controlplane   <none>              Approved,Issued

    controlplane ~ ➜  kubectl certificate deny agent-smith
    certificatesigningrequest.certificates.k8s.io/agent-smith denied

    controlplane ~ ➜  k get csr
    NAME          AGE     SIGNERNAME                                    REQUESTOR                  REQUESTEDDURATION   CONDITION
    agent-smith   3m9s    kubernetes.io/kube-apiserver-client           agent-x                    <none>              Denied
    akshay        7m15s   kubernetes.io/kube-apiserver-client           kubernetes-admin           <none>              Approved,Issued
    csr-fnjbq     27m     kubernetes.io/kube-apiserver-client-kubelet   system:node:controlplane   <none>              Approved,Issued
    ```

    To delete the CSR, generate the YAML and use the kubectl delete.

    ```bash
    controlplane ~ ➜  k get csr agent-smith -o yaml > agent-smith.yml

    controlplane ~ ➜  k delete -f agent-smith.yml 
    certificatesigningrequest.certificates.k8s.io "agent-smith" deleted

    controlplane ~ ➜  k get csr
    NAME        AGE     SIGNERNAME                                    REQUESTOR                  REQUESTEDDURATION   CONDITION
    akshay      9m59s   kubernetes.io/kube-apiserver-client           kubernetes-admin           <none>              Approved,Issued
    csr-fnjbq   30m     kubernetes.io/kube-apiserver-client-kubelet   system:node:controlplane   <none>              Approved,Issued  
    ```
    
    </details>
    </br>


15. Where is the default kubeconfig file located in the current environment?

    <details><summary> Answer </summary>

    The answer is /root/.kube/config
    ```bash
    controlplane ~ ➜  ls -la
    total 60
    drwx------ 1 root root 4096 Dec 30 10:02 .
    drwxr-xr-x 1 root root 4096 Dec 30 09:57 ..
    -rw-r--r-- 1 root root 1272 Dec 30 09:57 .bash_profile
    -rw-r--r-- 1 root root 3265 Nov  2 11:39 .bashrc
    drwxr-xr-x 1 root root 4096 Dec 30 10:02 .cache
    drwxr-xr-x 2 root root 4096 Dec 30 10:02 CKA
    drwxr-xr-x 1 root root 4096 Nov  2 11:36 .config
    drwxr-xr-x 3 root root 4096 Dec 30 10:02 .kube
    -rw-rw-rw- 1 root root 1456 Dec 30 10:02 my-kube-config
    -rw-r--r-- 1 root root  161 Dec  5  2019 .profile
    -rw-rw-rw- 1 root root    0 Dec 13 05:39 sample.yaml
    drwx------ 2 root root 4096 Dec 30 10:02 .ssh
    drwxr-xr-x 4 root root 4096 Nov  2 11:37 .vim
    -rw-r--r-- 1 root root  132 Nov  2 11:37 .vimrc
    -rw-r--r-- 1 root root  165 Nov  2 11:38 .wget-hsts

    controlplane ~ ➜  ls -la .kube/
    total 24
    drwxr-xr-x 3 root root 4096 Dec 30 10:02 .
    drwx------ 1 root root 4096 Dec 30 10:02 ..
    drwxr-x--- 4 root root 4096 Dec 30 10:02 cache
    -rw------- 1 root root 5640 Dec 30 09:57 config 
    ```
    
    </details>
    </br>   


16. In the default kubeconfig file, what is the user configured in the current context?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~/.kube ➜  grep -i context config
    contexts:
    - context:
    current-context: kubernetes-admin@kubernetes

    controlplane ~/.kube ➜  grep -i current-context -A 5 config
    current-context: kubernetes-admin@kubernetes
    kind: Config
    preferences: {}
    users:
    - name: kubernetes-admin 
    ```
    
    </details>
    </br>


17. A new kubeconfig file named my-kube-config is created. It is placed in the /root directory. How many clusters are defined in that kubeconfig file?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  ls -l
    total 8
    drwxr-xr-x 2 root root 4096 Dec 30 10:02 CKA
    -rw-rw-rw- 1 root root 1456 Dec 30 10:08 my-kube-config
    -rw-rw-rw- 1 root root    0 Dec 13 05:39 sample.yaml

    controlplane ~ ➜  grep cluster my-kube-config 
    clusters:
    cluster:
    cluster:
    cluster:
    - name: test-cluster-1
    cluster:
        cluster: development
        cluster: kubernetes-on-aws
        cluster: production
        cluster: test-cluster-1 
    ```
    
    </details>
    </br>


18. In the new my-kube-config, what user is configured in the research context?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  grep -A 5 research my-kube-config 
    - name: research
    context:
        cluster: test-cluster-1
        user: dev-user 
    ```
    
    </details>
    </br>


19. In the new my-kube-config, what is the name of the client-certificate file configured for the aws-user?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  grep -A 10 aws-user  my-kube-config

    --
    - name: aws-user
    user:
        client-certificate: /etc/kubernetes/pki/users/aws-user/aws-user.crt
        client-key: /etc/kubernetes/pki/users/aws-user/aws-user.key
    ```
    
    </details>
    </br>


20. I would like to use the dev-user to access test-cluster-1. Set the current context to the right one so I can do that.

    Once the right context is identified, use the kubectl config use-context command.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ✖ k config --kubeconfig my-kube-config get-contexts
    CURRENT   NAME                         CLUSTER             AUTHINFO    NAMESPACE
            aws-user@kubernetes-on-aws   kubernetes-on-aws   aws-user    
            research                     test-cluster-1      dev-user    
    *         test-user@development        development         test-user   
            test-user@production         production          test-user  

    controlplane ~ ➜  k config --kubeconfig my-kube-config use-context research
    Switched to context "research".

    controlplane ~ ➜  k config --kubeconfig my-kube-config get-contexts
    CURRENT   NAME                         CLUSTER             AUTHINFO    NAMESPACE
            aws-user@kubernetes-on-aws   kubernetes-on-aws   aws-user    
    *         research                     test-cluster-1      dev-user    
            test-user@development        development         test-user   
            test-user@production         production          test-user            
    ```
    
    </details>
    </br>


21. We don't want to have to specify the kubeconfig file option on each command. Make the my-kube-config file the default kubeconfig.

    <details><summary> Answer </summary>

    There is no kubectl command to do this. Simply copy the contents of the custom kubeconfig to the default kubeconfig file.

    ```bash
    controlplane ~ ➜  cp my-kube-config .kube/config 
    ```
    
    </details>
    </br>


22. With the current-context set to research, we are trying to access the cluster. However something seems to be wrong. Identify and fix the issue.

    Try running the kubectl get pods command and look for the error. All users certificates are stored at /etc/kubernetes/pki/users.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ✖ k config get-contexts 
    CURRENT   NAME                         CLUSTER             AUTHINFO    NAMESPACE
            aws-user@kubernetes-on-aws   kubernetes-on-aws   aws-user    
    *         research                     test-cluster-1      dev-user    
            test-user@development        development         test-user   
            test-user@production         production          test-user   

    controlplane ~ ➜  k get po
    error: unable to read client-cert /etc/kubernetes/pki/users/dev-user/developer-user.crt for dev-user due to open /etc/kubernetes/pki/users/dev-user/developer-user.crt: no such file or directory 
    ```

    Incorrect cert defined in the kubeconfig. Fix it and then try to get the pods again.

    ```bash
    controlplane ~ ➜  ls -l /etc/kubernetes/pki/users/dev-user/
    total 12
    -rw-r--r-- 1 root root 1025 Dec 30 10:08 dev-user.crt
    -rw-r--r-- 1 root root  924 Dec 30 10:08 dev-user.csr
    -rw------- 1 root root 1675 Dec 30 10:08 dev-user.key
    ```
    ```bash
    - name: dev-user
    user:
        client-certificate: /etc/kubernetes/pki/users/dev-user/dev-user.crt
        client-key: /etc/kubernetes/pki/users/dev-user/dev-user.key 
    ```
    ```bash
    controlplane ~ ➜  k get po
    No resources found in default namespace.
    ```
    
    </details>
    </br>


23. Inspect the environment and identify the authorization modes configured on the cluster.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po -A
    NAMESPACE      NAME                                   READY   STATUS    RESTARTS   AGE
    blue           blue-app                               1/1     Running   0          10m
    blue           dark-blue-app                          1/1     Running   0          10m
    default        red-697496b845-fkmrr                   1/1     Running   0          10m
    default        red-697496b845-wxks5                   1/1     Running   0          10m
    kube-flannel   kube-flannel-ds-k46ss                  1/1     Running   0          12m
    kube-system    coredns-5d78c9869d-bmfpk               1/1     Running   0          12m
    kube-system    coredns-5d78c9869d-s27fp               1/1     Running   0          12m
    kube-system    etcd-controlplane                      1/1     Running   0          12m
    kube-system    kube-apiserver-controlplane            1/1     Running   0          12m
    kube-system    kube-controller-manager-controlplane   1/1     Running   0          12m
    kube-system    kube-proxy-tjxfp                       1/1     Running   0          12m
    kube-system    kube-scheduler-controlplane            1/1     Running   0          12m

    controlplane ~ ➜  k describe -n kube-system po kube-apiserver-controlplane | grep -i auth
        --authorization-mode=Node,RBAC
        --enable-bootstrap-token-auth=true
    ```
    
    </details>
    </br>


24. How many roles exist in the default namespace?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k api-resources | grep -i role
    clusterrolebindings                            rbac.authorization.k8s.io/v1           false        ClusterRoleBinding
    clusterroles                                   rbac.authorization.k8s.io/v1           false        ClusterRole
    rolebindings                                   rbac.authorization.k8s.io/v1           true         RoleBinding
    roles                                          rbac.authorization.k8s.io/v1           true         Role

    controlplane ~ ➜  k get roles
    No resources found in default namespace. 
    ```
    
    </details>
    </br>


25. How many roles exist in all namespaces together?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get roles -A
    NAMESPACE     NAME                                             CREATED AT
    blue          developer                                        2023-12-30T15:24:38Z
    kube-public   kubeadm:bootstrap-signer-clusterinfo             2023-12-30T15:22:42Z
    kube-public   system:controller:bootstrap-signer               2023-12-30T15:22:40Z
    kube-system   extension-apiserver-authentication-reader        2023-12-30T15:22:40Z
    kube-system   kube-proxy                                       2023-12-30T15:22:43Z
    kube-system   kubeadm:kubelet-config                           2023-12-30T15:22:41Z
    kube-system   kubeadm:nodes-kubeadm-config                     2023-12-30T15:22:41Z
    kube-system   system::leader-locking-kube-controller-manager   2023-12-30T15:22:40Z
    kube-system   system::leader-locking-kube-scheduler            2023-12-30T15:22:40Z
    kube-system   system:controller:bootstrap-signer               2023-12-30T15:22:40Z
    kube-system   system:controller:cloud-provider                 2023-12-30T15:22:40Z
    kube-system   system:controller:token-cleaner                  2023-12-30T15:22:40Z
    ```
    
    </details>
    </br>


26. What are the resources the kube-proxy role in the kube-system namespace is given access to?


    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get roles -A
    NAMESPACE     NAME                                             CREATED AT
    blue          developer                                        2023-12-30T15:24:38Z
    kube-public   kubeadm:bootstrap-signer-clusterinfo             2023-12-30T15:22:42Z
    kube-public   system:controller:bootstrap-signer               2023-12-30T15:22:40Z
    kube-system   extension-apiserver-authentication-reader        2023-12-30T15:22:40Z
    kube-system   kube-proxy                                       2023-12-30T15:22:43Z
    kube-system   kubeadm:kubelet-config                           2023-12-30T15:22:41Z
    kube-system   kubeadm:nodes-kubeadm-config                     2023-12-30T15:22:41Z
    kube-system   system::leader-locking-kube-controller-manager   2023-12-30T15:22:40Z
    kube-system   system::leader-locking-kube-scheduler            2023-12-30T15:22:40Z
    kube-system   system:controller:bootstrap-signer               2023-12-30T15:22:40Z
    kube-system   system:controller:cloud-provider                 2023-12-30T15:22:40Z
    kube-system   system:controller:token-cleaner                  2023-12-30T15:22:40Z 

    controlplane ~ ✖ k describe role kube-proxy -n kube-system 
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


27. Which account is the kube-proxy role assigned to?

    <details><summary> Answer </summary>

    It is binded to a group: system:bootstrappers:kubeadm:default-node-token

    ```bash
    controlplane ~ ➜  k get rolebindings.rbac.authorization.k8s.io  -n kube-system 
    NAME                                                ROLE                                                  AGE
    kube-proxy                                          Role/kube-proxy                                       17m
    kubeadm:kubelet-config                              Role/kubeadm:kubelet-config                           17m
    kubeadm:nodes-kubeadm-config                        Role/kubeadm:nodes-kubeadm-config                     17m
    system::extension-apiserver-authentication-reader   Role/extension-apiserver-authentication-reader        17m
    system::leader-locking-kube-controller-manager      Role/system::leader-locking-kube-controller-manager   17m
    system::leader-locking-kube-scheduler               Role/system::leader-locking-kube-scheduler            17m
    system:controller:bootstrap-signer                  Role/system:controller:bootstrap-signer               17m
    system:controller:cloud-provider                    Role/system:controller:cloud-provider                 17m
    system:controller:token-cleaner                     Role/system:controller:token-cleaner                  17m

    controlplane ~ ➜  k describe rolebindings.rbac.authorization.k8s.io -n kube-system kube-proxy 
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


28. A user dev-user is created. User's details have been added to the kubeconfig file. Inspect the permissions granted to the user. Check if the user can list pods in the default namespace.

    Use the --as dev-user option with kubectl to run commands as the dev-user.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po --as dev-user
    Error from server (Forbidden): pods is forbidden: User "dev-user" cannot list resource "pods" in API group "" in the namespace "default"
    ```
        
    </details>
    </br>


29. Create the necessary roles and role bindings required for the dev-user to create, list and delete pods in the default namespace. Use the given spec:

    - Role: developer

    - Role Resources: pods

    - Role Actions: list

    - Role Actions: create

    - Role Actions: delete

    - RoleBinding: dev-user-binding

    - RoleBinding: Bound to dev-user

    <details><summary> Answer </summary>
    
    ```yaml
    ## role-rolebinding.yaml 
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      namespace: default
      name: developer
    rules:
    - apiGroups: [""] # "" indicates the core API group
      resources: ["pods"]
      verbs: ["delete", "create", "list"]
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: dev-user-binding
      namespace: default
    subjects:
    - kind: User
      name: dev-user
      apiGroup: rbac.authorization.k8s.io
    roleRef:
      kind: Role #this must be Role or ClusterRole
      name: developer
      apiGroup: rbac.authorization.k8s.io
    ```
    ```bash
    controlplane ~ ➜  k apply -f role-rolebinding.yaml 
    role.rbac.authorization.k8s.io/developer created
    rolebinding.rbac.authorization.k8s.io/dev-user-binding created

    controlplane ~ ➜  k get role
    NAME        CREATED AT
    developer   2023-12-30T15:49:59Z

    controlplane ~ ➜  k get rolebindings.rbac.authorization.k8s.io 
    NAME               ROLE             AGE
    dev-user-binding   Role/developer   9s 
    ```

    </details>
    </br>


30. A set of new roles and role-bindings are created in the blue namespace for the dev-user. However, the dev-user is unable to get details of the dark-blue-app pod in the blue namespace. Investigate and fix the issue.

    ```bash
    controlplane ~ ➜  k get role -n blue
    NAME        CREATED AT
    developer   2023-12-30T15:24:38Z

    controlplane ~ ➜  k get rolebindings -n blue
    NAME               ROLE             AGE
    dev-user-binding   Role/developer   26m 
    ```

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k get po dark-blue-app -n blue --as dev-user
    Error from server (Forbidden): pods "dark-blue-app" is forbidden: User "dev-user" cannot get resource "pods" in API group "" in the namespace "blue"
    ```
    
    ```bash
    controlplane ~ ➜  export do="--dry-run=client -o yaml"

    controlplane ~ ➜  export now="--force --grace-period 0" 

    controlplane ~ ➜  k get role -n blue developer -o yaml > blue-dev-role.yaml

    controlplane ~ ➜  k get rolebindings.rbac.authorization.k8s.io -n blue dev-user-binding -o yaml > blue-dev-rolebinding.yaml
    ```

    Check the role. Here we can see that the resource name is incorrect. 

    ```bash
    ## blue-dev-rolebinding.yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      creationTimestamp: "2023-12-30T15:24:38Z"
      name: developer
      namespace: blue
      resourceVersion: "619"
      uid: 994093a1-b5e4-4256-b911-533769b6eb63
    rules:
    - apiGroups:
      - ""
      resourceNames:
      - blue-app
      resources:
      - pods
      verbs:
      - get
      - watch
      - create
      - delete 
    ```

    Fix it. 

    ```bash
    ## blue-dev-rolebinding.yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
    creationTimestamp: "2023-12-30T15:24:38Z"
    name: developer
    namespace: blue
    resourceVersion: "619"
    uid: 994093a1-b5e4-4256-b911-533769b6eb63
    rules:
    - apiGroups:
    - ""
    resourceNames:
    - dark-blue-app
    resources:
    - pods
    verbs:
    - get
    - watch
    - create
    - delete
    ```
    ```bash
    controlplane ~ ➜  k delete -f blue-dev-role.yaml 
    role.rbac.authorization.k8s.io "developer" deleted

    controlplane ~ ➜  k apply -f blue-dev-role.yaml 
    role.rbac.authorization.k8s.io/developer created

    controlplane ~ ➜  k get po dark-blue-app -n blue --as dev-user
    NAME            READY   STATUS    RESTARTS   AGE
    dark-blue-app   1/1     Running   0          37m 
    ```
    
    </details>
    </br>


31. Add a new rule in the existing role developer to grant the dev-user permissions to create deployments in the blue namespace.
    Remember to add api group "apps".

    ```bash
    controlplane ~ ➜  k get -n blue role
    NAME        CREATED AT
    developer   2023-12-30T16:01:43Z 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get role -n blue developer -o yaml > blue-dev-role.yaml 
    ```

    Add a new api-group in the YAML file.

    ```bash
    ## blue-dev-role.yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      creationTimestamp: "2023-12-30T15:24:38Z"
      name: developer
      namespace: blue
    resourceVersion: "619"
    uid: 994093a1-b5e4-4256-b911-533769b6eb63
    rules:

    - apiGroups:
      - ""
      resourceNames:
      - dark-blue-app
      resources:
      - pods
      verbs:
      - get
      - watch
      - create
      - delete
    
    - apiGroups:
      - apps
      resources:
      - deployments
      verbs:
      - create
    ```
    ```bash
    controlplane ~ ➜  k delete -f blue-dev-role.yaml 
    role.rbac.authorization.k8s.io "developer" deleted

    controlplane ~ ➜  k apply -f blue-dev-role.yaml 
    role.rbac.authorization.k8s.io/developer created
    ```

    Create a sample deployment as the dev-user. 

    ```bash
    controlplane ~ ➜  k create deployment testing-access --image nginx --namespace blue --as dev-user
    deployment.apps/testing-access created  
    ```
    
    </details>
    </br>


32. How many ClusterRoles do you see defined in the cluster?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get clusterroles --no-headers | wc -l
    70 
    ```
    
    </details>
    </br>


33. What user/groups are the cluster-admin role bound to?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get clusterrole | grep admin
    cluster-admin                                                          2023-12-30T16:00:55Z
    system:aggregate-to-admin                                              2023-12-30T16:00:55Z
    system:kubelet-api-admin                                               2023-12-30T16:00:55Z
    admin                                                                  2023-12-30T16:00:55Z

    controlplane ~ ➜  k get clusterrolebinding | grep admin
    cluster-admin                                          ClusterRole/cluster-admin                                          33m
    kube-apiserver-kubelet-admin                           ClusterRole/system:kubelet-api-admin                               32m
    helm-kube-system-traefik-crd                           ClusterRole/cluster-admin                                          32m
    helm-kube-system-traefik                               ClusterRole/cluster-admin                                          32m

    controlplane ~ ➜  k describe clusterrolebinding cluster-admin 
    Name:         cluster-admin
    Labels:       kubernetes.io/bootstrapping=rbac-defaults
    Annotations:  rbac.authorization.kubernetes.io/autoupdate: true
    Role:
    Kind:  ClusterRole
    Name:  cluster-admin
    Subjects:
    Kind   Name            Namespace
    ----   ----            ---------
    Group  system:masters   
    ```
    
    </details>
    </br>


34. What permissions does the clusterrole **cluster-admin** have?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get clusterrole | grep admin
    cluster-admin                                                          2023-12-30T16:00:55Z
    system:aggregate-to-admin                                              2023-12-30T16:00:55Z
    system:kubelet-api-admin                                               2023-12-30T16:00:55Z
    admin                                                                  2023-12-30T16:00:55Z 

    controlplane ~ ➜  k describe clusterrole cluster-admin 
    Name:         cluster-admin
    Labels:       kubernetes.io/bootstrapping=rbac-defaults
    Annotations:  rbac.authorization.kubernetes.io/autoupdate: true
    PolicyRule:
    Resources  Non-Resource URLs  Resource Names  Verbs
    ---------  -----------------  --------------  -----
    *.*        []                 []              [*]
                [*]                []              [*]
    ```
    
    </details>
    </br>


35. A new user michelle joined the team. She will be focusing on the nodes in the cluster. Create the required ClusterRoles and ClusterRoleBindings so she gets access to the nodes.

    <details><summary> Answer </summary>
    
    ```bash
    ## michelle-clusterrole.yaml 
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
    # "namespace" omitted since ClusterRoles are not namespaced
      name: nodes-access
    rules:
    - apiGroups: [""]
      resources:
      - nodes
      verbs: 
      - "*" 
    ```
    
    ```bash
    ## michelle-clusterrolebinding.yaml 
    apiVersion: rbac.authorization.k8s.io/v1
    # This cluster role binding allows anyone in the "manager" group to read secrets in any namespace.
    kind: ClusterRoleBinding
    metadata:
      name: nodes-access-binding
    subjects:
    - kind: User
      name: michelle # Name is case sensitive
      apiGroup: rbac.authorization.k8s.io
    roleRef:
      kind: ClusterRole
      name: nodes-access
      apiGroup: rbac.authorization.k8s.io 
    ```
    
    ```bash
    controlplane ~ ➜  k apply -f michelle-clusterrole.yaml 
    clusterrole.rbac.authorization.k8s.io/nodes-access created

    controlplane ~ ➜  k apply -f michelle-clusterrolebinding.yaml 
    clusterrolebinding.rbac.authorization.k8s.io/nodes-access-binding created 

    controlplane ~ ➜  k apply -f michelle-clusterrole.yaml 
    clusterrole.rbac.authorization.k8s.io/nodes-access created

    controlplane ~ ➜  k apply -f michelle-clusterrolebinding.yaml 
    clusterrolebinding.rbac.authorization.k8s.io/nodes-access-binding created

    controlplane ~ ➜  k get nodes --as michelle
    NAME           STATUS   ROLES                  AGE   VERSION
    controlplane   Ready    control-plane,master   39m   v1.27.1+k3s1
    ```

    
    </details>
    </br>



36. User michelle's responsibilities are growing and now she will be responsible for storage as well. Create the required ClusterRoles and ClusterRoleBindings to allow her access to Storage.

    - ClusterRole: storage-admin

    - Resource: persistentvolumes

    - Resource: storageclasses

    - ClusterRoleBinding: michelle-storage-admin

    - ClusterRoleBinding Subject: michelle

    - ClusterRoleBinding Role: storage-admin

    <details><summary> Answer </summary>
    
    ```bash
    ## storage-admin-clusterrole.yaml 
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
    # "namespace" omitted since ClusterRoles are not namespaced
      name: storage-admin
    rules:
    - apiGroups:
      - storage.k8s.io
      resources:
      - storageclasses
      verbs: 
      - "*"
    - apiGroups:
      - ""
      resources:
      - persistentvolumes
      verbs:
      - "*" 
    ```
    ```bash
    ## storage-admin-clusterrolebinding.yaml 
    apiVersion: rbac.authorization.k8s.io/v1
    # This cluster role binding allows anyone in the "manager" group to read secrets in any namespace.
    kind: ClusterRoleBinding
    metadata:
    name: michelle-storage-admin
    subjects:
    - kind: User
    name: michelle # Name is case sensitive
    apiGroup: rbac.authorization.k8s.io
    roleRef:
    kind: ClusterRole
    name: storage-admin
    apiGroup: rbac.authorization.k8s.io 
    ```
    ```bash
    controlplane ~ ➜  k apply -f storage-admin-clusterrole.yaml 
    clusterrole.rbac.authorization.k8s.io/storage-admin created

    controlplane ~ ➜  k apply -f storage-admin-clusterrolebinding.yaml 
    clusterrolebinding.rbac.authorization.k8s.io/michelle-storage-admin created

    controlplane ~ ➜  k get clusterrole | grep storage-admin
    storage-admin                                                          2023-12-30T16:45:41Z

    controlplane ~ ➜  k get clusterrolebinding | grep storage-admin
    michelle-storage-admin                                 ClusterRole/storage-admin                                          41s
    ```
    ```bash
    controlplane ~ ➜  k get sc --as michelle
    NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
    local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  48m

    controlplane ~ ➜  k get pv --as michelle
    No resources found 
    ```
    
    </details>
    </br>



37. What is the secret token used by the default service account?

    ```bash
    controlplane ~ ➜  k get sa
    NAME      SECRETS   AGE
    default   0         10m
    dev       0         76s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k describe sa default 
    Name:                default
    Namespace:           default
    Labels:              <none>
    Annotations:         <none>
    Image pull secrets:  <none>
    Mountable secrets:   <none>
    Tokens:              <none>
    Events:              <none> 
    ```
    
    </details>
    </br>



38. Inspect the Dashboard Application POD and identify the Service Account mounted on it.

    ```bash
    controlplane ~ ➜  k get po
    NAME                            READY   STATUS    RESTARTS   AGE
    web-dashboard-97c9c59f6-f6krx   1/1     Running   0          43s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k describe po web-dashboard-97c9c59f6-f6krx | grep -i service
    Service Account:  default
        /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-jcbls (ro) 
    ```
    
    </details>
    </br>



39. The application needs a ServiceAccount with the Right permissions to be created to authenticate to Kubernetes. The default ServiceAccount has limited access. Create a new ServiceAccount named dashboard-sa.

    ```bash
    controlplane ~ ➜  k get po
    NAME                            READY   STATUS    RESTARTS   AGE
    web-dashboard-97c9c59f6-f6krx   1/1     Running   0          43s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    ## dashboard-sa.yaml 
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: dashboard-sa
      annotations:
        kubernetes.io/enforce-mountable-secrets: "true"
    ```
    ```bash
    controlplane ~ ➜  k apply -f dashboard-sa.yaml 
    serviceaccount/dashboard-sa created

    controlplane ~ ➜  k get sa
    NAME           SECRETS   AGE
    default        0         15m
    dev            0         5m58s
    dashboard-sa   0         3s
    ```
    
    </details>
    </br>



40. Edit the deployment to change ServiceAccount from default to dashboard-sa.

    ```bash
    controlplane ~ ➜  k get deployments.apps 
    NAME            READY   UP-TO-DATE   AVAILABLE   AGE
    web-dashboard   1/1     1            1           6m22s 

    controlplane ~ ➜  k get sa
    NAME           SECRETS   AGE
    default        0         20m
    dev            0         10m
    dashboard-sa   0         4m26s
    ```

    <details><summary> Answer </summary>
    
    ```bash
    k edit deployments.apps web-dashboard  
    ```
    ```bash
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      annotations:
        deployment.kubernetes.io/revision: "1"
      creationTimestamp: "2023-12-30T16:53:13Z"
      generation: 1
      name: web-dashboard
      namespace: default
    resourceVersion: "854"
    uid: 937b66d9-e256-4944-9a5b-426731eda7ce
    spec:
      progressDeadlineSeconds: 600
      replicas: 1
      revisionHistoryLimit: 10
      selector:
        matchLabels:
          name: web-dashboard
      strategy:
        rollingUpdate:
          maxSurge: 25%
          maxUnavailable: 25%
        type: RollingUpdate
      template:
        metadata:
          creationTimestamp: null
          labels:
            name: web-dashboard
        spec:
          serviceAccountName: dashboard-sa 
    ```
    
    </details>
    </br>



41. What secret type must we choose for docker registry?

    <details><summary> Answer </summary>
    
    ```bash
    root@controlplane ~ ➜  k create secret --help | grep docker
    docker-registry   Create a secret for use with a Docker registry
    ```
    
    </details>
    </br>



42. Update the image of the deployment to use a new image from myprivateregistry.com:5000

    ```bash
    root@controlplane ~ ➜  k get deployments.apps 
    NAME   READY   UP-TO-DATE   AVAILABLE   AGE
    web    2/2     2            2           104s 
    ```

    <details><summary> Answer </summary>
    
    We simply need to append at the beginning of the image. 

    ```bash
    k edit deployments.apps  
    ```
    
    ```bash
        spec:
        containers:
        - image: myprivateregistry.com:5000/nginx:alpine 
    ```
    
    </details>
    </br>



43. Create a secret object with the credentials required to access the registry.

    - Name: private-reg-cred
    - Username: dock_user
    - Password: dock_password
    - Server: myprivateregistry.com:5000
    - Email: dock_user@myprivateregistry.com

    Secret Type: docker-registry

    <details><summary> Answer </summary>

    Based on: https://kubernetes.io/docs/concepts/configuration/secret/

    ```bash
    kubectl create secret docker-registry private-reg-cred \
    --docker-email=dock_user@myprivateregistry.com \
    --docker-username=dock_user \
    --docker-password=dock_password \
    --docker-server=myprivateregistry.com:5000
    ```
    ```bash
    root@controlplane ~ ➜  kubectl create secret docker-registry private-reg-cred \
    >   --docker-email=dock_user@myprivateregistry.com \
    >   --docker-username=dock_user \
    >   --docker-password=dock_password \
    >   --docker-server=myprivateregistry.com:5000
    secret/private-reg-cred created

    root@controlplane ~ ➜  k get secrets 
    NAME               TYPE                             DATA   AGE
    private-reg-cred   kubernetes.io/dockerconfigjson   1      8s

    root@controlplane ~ ➜  k describe secrets  private-reg-cred 
    Name:         private-reg-cred
    Namespace:    default
    Labels:       <none>
    Annotations:  <none>

    Type:  kubernetes.io/dockerconfigjson

    Data
    ====
    .dockerconfigjson:  176 bytes 
    ```

    When we try to generate the YAML file, we can see that the data is hidden.

    ```bash
    root@controlplane ~ ➜  k get secrets private-reg-cred -o yaml
    apiVersion: v1
    data:
      .dockerconfigjson: eyJhdXRocyI6eyJteXByaXZhdGVyZWdpc3RyeS5jb206NTAwMCI6eyJ1c2VybmFtZSI6ImRvY2tfdXNlciIsInBhc3N3b3JkIjoiZG9ja19wYXNzd29yZCIsImVtYWlsIjoiZG9ja191c2VyQG15cHJpdmF0ZXJlZ2lzdHJ5LmNvbSIsImF1dGgiOiJaRzlqYTE5MWMyVnlPbVJ2WTJ0ZmNHRnpjM2R2Y21RPSJ9fX0=
    kind: Secret
    metadata:
      creationTimestamp: "2023-12-30T17:26:54Z"
      name: private-reg-cred
      namespace: default
      resourceVersion: "2092"
      uid: 7bd9c254-9f9e-425a-b7f2-589c85f5df0a
    type: kubernetes.io/dockerconfigjson 
    ```

    </details>
    </br>



44. Configure the deployment to use credentials from the new secret to pull images from the private registry

    ```bash
    root@controlplane ~ ➜  k get secrets 
    NAME               TYPE                             DATA   AGE
    private-reg-cred   kubernetes.io/dockerconfigjson   1      2m40s

    root@controlplane ~ ➜  k get deployments.apps 
    NAME   READY   UP-TO-DATE   AVAILABLE   AGE
    web    2/2     1            2           13m 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  export do="--dry-run=client -o yaml"

    controlplane ~ ➜  export now="--force --grace-period 0" 
    ```
    
    ```bash
    root@controlplane ~ ➜  k get deployments.apps web -o yaml > web.yaml

    root@controlplane ~ ➜  k delete -f web.yaml 
    deployment.apps "web" deleted

    root@controlplane ~ ➜  k get deployments.apps 
    No resources found in default namespace. 
    ```

    Modify the YAML file. 
    Follow: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/

    ```bash
        spec:
        containers:
        - image: myprivateregistry.com:5000/nginx:alpine
            imagePullPolicy: IfNotPresent
            name: nginx
            resources: {}
            terminationMessagePath: /dev/termination-log
            terminationMessagePolicy: File
        imagePullSecrets:
            - name: private-reg-cred
    ```
    
    ```bash
    root@controlplane ~ ➜  k apply -f web.yaml 
    deployment.apps/web created

    root@controlplane ~ ➜  k get deployments.apps 
    NAME   READY   UP-TO-DATE   AVAILABLE   AGE
    web    2/2     2            2           3s 
    ```
    
    </details>
    </br>



45. What is the user used to execute the sleep process within the ubuntu-sleeper pod?

    ```bash
    controlplane ~ ➜  k get po
    NAME             READY   STATUS    RESTARTS   AGE
    ubuntu-sleeper   1/1     Running   0          76s 
    ```

    <details><summary> Answer </summary>

    Enter the pod and run whoami.

    ```bash
    controlplane ~ ➜  k exec -it ubuntu-sleeper -- whoami
    root
    ```
    
    </details>
    </br>



46. Edit the pod ubuntu-sleeper to run the sleep process with user ID 1010.

    ```bash
    controlplane ~ ➜  k get po
    NAME             READY   STATUS    RESTARTS   AGE
    ubuntu-sleeper   1/1     Running   0          76s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  export do="--dry-run=client -o yaml"

    controlplane ~ ➜  export now="--force --grace-period 0" 
    ```
    
    ```bash
    controlplane ~ ➜  k get po ubuntu-sleeper -o yaml > ubuntu-sleeper.yaml

    controlplane ~ ✦ ➜  k delete po ubuntu-sleeper $now
    Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
    pod "ubuntu-sleeper" force deleted

    controlplane ~ ✦ ✖ k get po
    No resources found in default namespace.
    ```
    
    ```bash
    ## ubuntu-sleeper.yaml 
    apiVersion: v1
    kind: Pod
    metadata:
      creationTimestamp: "2023-12-30T17:40:14Z"
      name: ubuntu-sleeper
      namespace: default
      resourceVersion: "814"
      uid: f866a186-25d6-45f3-9fb8-f8e37cf91c38
    spec:
      securityContext:
        runAsUser: 1010
      containers:
      - command:
        - sleep
        - "4800"
        image: ubuntu
        imagePullPolicy: Always
        name: ubuntu 
    ```
    
    ```bash
    controlplane ~ ➜  k apply -f ubuntu-sleeper.yaml 
    pod/ubuntu-sleeper created

    controlplane ~ ➜  k get po
    NAME             READY   STATUS    RESTARTS   AGE
    ubuntu-sleeper   1/1     Running   0          3s

    controlplane ~ ➜  k exec -it ubuntu-sleeper -- whoami
    whoami: cannot find name for user ID 1010
    command terminated with exit code 1
    ```
    
    </details>
    </br>



47. Update pod ubuntu-sleeper to run as Root user and with the SYS_TIME capability.

    ```bash
    controlplane ~ ➜  k get po
    NAME             READY   STATUS    RESTARTS   AGE
    ubuntu-sleeper   1/1     Running   0          2m48s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  export do="--dry-run=client -o yaml"

    controlplane ~ ➜  export now="--force --grace-period 0"

    controlplane ~ ➜  k get po ubuntu-sleeper -o yaml > ubuntu-sleeper.yaml

    controlplane ~ ➜  k delete po ubuntu-sleeper $now
    Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
    pod "ubuntu-sleeper" force deleted

    controlplane ~ ➜  k get po
    No resources found in default namespace.
    ```
    
    ```bash
    ## ubuntu-sleeper.yaml 
    ---
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
        name: ubuntu-sleeper
        securityContext:
          capabilities:
            add: ["SYS_TIME"]
    ```
    
    ```bash
    controlplane ~ ➜  k apply -f ubuntu-sleeper.yaml 
    pod/ubuntu-sleeper created

    controlplane ~ ➜  k get po
    NAME             READY   STATUS    RESTARTS   AGE
    ubuntu-sleeper   1/1     Running   0          6s 

    controlplane ~ ➜  k exec -it ubuntu-sleeper -- whoami
    root
    ```

    </details>
    </br>



48. How many network policies do you see in the environment?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k api-resources | grep -i network
    ingressclasses                                 networking.k8s.io/v1                   false        IngressClass
    ingresses                         ing          networking.k8s.io/v1                   true         Ingress
    networkpolicies                   netpol       networking.k8s.io/v1                   true         NetworkPolicy

    controlplane ~ ➜  k get netpol
    NAME             POD-SELECTOR   AGE
    payroll-policy   name=payroll   37s 
    ```
    
    </details>
    </br>


49. Which pod is the Network Policy applied on?

    ```bash
    controlplane ~ ➜  k get netpol
    NAME             POD-SELECTOR   AGE
    payroll-policy   name=payroll   37s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k describe networkpolicies.networking.k8s.io payroll-policy 
    Name:         payroll-policy
    Namespace:    default
    Created on:   2023-12-30 13:01:40 -0500 EST
    Labels:       <none>
    Annotations:  <none>
    Spec:
    PodSelector:     name=payroll
    Allowing ingress traffic:
        To Port: 8080/TCP
        From:
        PodSelector: name=internal
    Not affecting egress traffic
    Policy Types: Ingress
    
    ```
    
    </details>
    </br>


49. Create a network policy to allow traffic from the Internal application only to the payroll-service and db-service. Use the spec given below. You might want to enable ingress traffic to the pod to test your rules in the UI.

    - Policy Name: internal-policy

    - Policy Type: Egress

    - Egress Allow: payroll

    - Payroll Port: 8080

    - Egress Allow: mysql

    - MySQL Port: 3306

    <details><summary> Answer </summary>
    
    ```bash
    ## internal-policy.yaml
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: internal-policy
      namespace: default
    spec:
      podSelector:
        matchLabels:
        name: internal
      policyTypes:
      - Egress
      - Ingress
      ingress:
        - {}
      egress:
      - to:
        - podSelector:
            matchLabels:
            name: mysql
        ports:
        - protocol: TCP
          port: 3306

      - to:
        - podSelector:
            matchLabels:
            name: payroll
        ports:
        - protocol: TCP
          port: 8080

    - ports:
        - port: 53
          protocol: UDP
        - port: 53
          protocol: TCP 
    ```
    Note: We have also allowed Egress traffic to TCP and UDP port. This has been added to ensure that the internal DNS resolution works from the internal pod. 


    ```bash
    controlplane ~ ➜  k apply -f internal-policy.yaml 
    networkpolicy.networking.k8s.io/internal-policy created

    controlplane ~ ➜  k get networkpolicies.networking.k8s.io 
    NAME              POD-SELECTOR    AGE
    internal-policy   name=internal   3s
    payroll-policy    name=payroll    17m 
    ```
    
    </details>
    </br>


[Back to the top](#practice-test-cka)    
