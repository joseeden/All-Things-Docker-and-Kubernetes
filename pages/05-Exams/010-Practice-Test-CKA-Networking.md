
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

## Networking 

1. What is the Internal IP address of the controlplane node in this cluster?

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS   ROLES           AGE   VERSION
    controlplane   Ready    control-plane   15m   v1.27.0
    node01         Ready    <none>          14m   v1.27.0
    ```

    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  k describe no controlplane  | grep -i ip
                        flannel.alpha.coreos.com/public-ip: 192.2.53.9
      InternalIP:  192.2.53.9 
    ```

    </details>
    </br>


2. What is the network interface configured for cluster connectivity on the controlplane node?

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS   ROLES           AGE   VERSION
    controlplane   Ready    control-plane   15m   v1.27.0
    node01         Ready    <none>          14m   v1.27.0
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get no -o wide
    NAME           STATUS   ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION   CONTAINER-RUNTIME
    controlplane   Ready    control-plane   20m   v1.27.0   192.2.120.9    <none>        Ubuntu 20.04.6 LTS   5.4.0-1106-gcp   containerd://1.6.6
    node01         Ready    <none>          19m   v1.27.0   192.2.120.12   <none>        Ubuntu 20.04.5 LTS   5.4.0-1106-gcp   containerd://1.6.6

    controlplane ~ ➜  ip addr | grep -B2 192.2
    13036: eth0@if13037: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP group default 
        link/ether 02:42:c0:02:78:09 brd ff:ff:ff:ff:ff:ff link-netnsid 0
        inet 192.2.120.9/24 brd 192.2.120.255 scope global eth0
    ```
    
    </details>
    </br>


3. What is the MAC address assigned to node01?

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS   ROLES           AGE   VERSION
    controlplane   Ready    control-plane   15m   v1.27.0
    node01         Ready    <none>          14m   v1.27.0
    ```

    <details><summary> Answer </summary>
    
    Need to ssh to node01. 

    ```bash
    controlplane ~ ➜  ssh node01

    root@node01 ~ ➜  ip addr | grep -B2 192.2
    13945: eth0@if13946: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP group default 
        link/ether 02:42:c0:02:78:0c brd ff:ff:ff:ff:ff:ff link-netnsid 0
        inet 192.2.120.12/24 brd 192.2.120.255 scope global eth0 
    ```
    
    </details>
    </br>


4. We use Containerd as our container runtime. What is the interface/bridge created by Containerd on the controlplane node?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ✖ ip link show | grep -i cni
    3: cni0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1400 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    4: vethcb46d51e@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1400 qdisc noqueue master cni0 state UP mode DEFAULT group default 
        link/ether 46:15:1c:5b:93:f2 brd ff:ff:ff:ff:ff:ff link-netns cni-3f59b276-21d3-2b70-df1a-514e9f7eb6cb
    5: veth35f1d3bb@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1400 qdisc noqueue master cni0 state UP mode DEFAULT group default 
        link/ether 96:21:56:39:34:10 brd ff:ff:ff:ff:ff:ff link-netns cni-d15387ac-89be-7f41-ecb3-79879ae016f1
    ```
    
    </details>
    </br>


5. If you were to ping google from the controlplane node, which route does it take?

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS   ROLES           AGE   VERSION
    controlplane   Ready    control-plane   15m   v1.27.0
    node01         Ready    <none>          14m   v1.27.0
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  ip route
    default via 172.25.0.1 dev eth1 
    ```
    
    </details>
    </br>


6. What is the port the kube-scheduler is listening on in the controlplane node?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  netstat -tulpn | grep -i sched
    tcp        0      0 127.0.0.1:10259         0.0.0.0:*               LISTEN      3706/kube-scheduler  
    ```
    
    </details>
    </br>


7. Notice that ETCD is listening on two ports. Which of these have more client connections established?

    <details><summary> Answer </summary>

    2379 is the port of ETCD to which all control plane components connect to. 2380 is only for etcd peer-to-peer connectivity when you have multiple controlplane nodes.

    ```bash
    controlplane ~ ➜  netstat -tulpn | grep -i etc
    tcp        0      0 192.2.120.9:2379        0.0.0.0:*               LISTEN      3723/etcd           
    tcp        0      0 127.0.0.1:2379          0.0.0.0:*               LISTEN      3723/etcd           
    tcp        0      0 192.2.120.9:2380        0.0.0.0:*               LISTEN      3723/etcd           
    tcp        0      0 127.0.0.1:2381          0.0.0.0:*               LISTEN      3723/etcd   

    controlplane ~ ➜  netstat -anp | grep etc | grep 2379 | wc -l
    63

    controlplane ~ ➜  netstat -anp | grep etc | grep 2380 | wc -l
    1

    controlplane ~ ➜  netstat -anp | grep etc | grep 2381 | wc -l
    1
    ```
    
    </details>
    </br>


8. Inspect the kubelet service and identify the container runtime endpoint value is set for Kubernetes.

    <details><summary> Answer </summary>

    Answer is unix:///var/run/containerd/containerd.sock.

    ```bash
    controlplane ~ ➜  ps -aux | grep kubelet | grep container
    root        4685  0.0  0.0 3702540 101388 ?      Ssl  20:02   0:12 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock --pod-infracontainer-image=registry.k8s.io/pause:3.9 
    ```
    
    </details>
    </br>


9. What is the path configured with all binaries of CNI supported plugins?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  ls -la /opt/cni
    total 20
    drwxr-xr-x 1 root root 4096 Nov  2 11:33 .
    drwxr-xr-x 1 root root 4096 Nov  2 11:38 ..
    drwxrwxr-x 1 root root 4096 Dec 30 20:02 bin

    controlplane ~ ➜  ls -la /opt/cni/bin/
    total 71424
    drwxrwxr-x 1 root root     4096 Dec 30 20:02 .
    drwxr-xr-x 1 root root     4096 Nov  2 11:33 ..
    -rwxr-xr-x 1 root root  3859475 Jan 16  2023 bandwidth
    -rwxr-xr-x 1 root root  4299004 Jan 16  2023 bridge
    -rwxr-xr-x 1 root root 10167415 Jan 16  2023 dhcp
    -rwxr-xr-x 1 root root  3986082 Jan 16  2023 dummy
    -rwxr-xr-x 1 root root  4385098 Jan 16  2023 firewall
    -rwxr-xr-x 1 root root  2474798 Dec 30 20:02 flannel
    -rwxr-xr-x 1 root root  3870731 Jan 16  2023 host-device
    -rwxr-xr-x 1 root root  3287319 Jan 16  2023 host-local
    -rwxr-xr-x 1 root root  3999593 Jan 16  2023 ipvlan
    -rwxr-xr-x 1 root root  3353028 Jan 16  2023 loopback
    -rwxr-xr-x 1 root root  4029261 Jan 16  2023 macvlan
    -rwxr-xr-x 1 root root  3746163 Jan 16  2023 portmap
    -rwxr-xr-x 1 root root  4161070 Jan 16  2023 ptp
    -rwxr-xr-x 1 root root  3550152 Jan 16  2023 sbr
    -rwxr-xr-x 1 root root  2845685 Jan 16  2023 static
    -rwxr-xr-x 1 root root  3437180 Jan 16  2023 tuning
    -rwxr-xr-x 1 root root  3993252 Jan 16  2023 vlan
    -rwxr-xr-x 1 root root  3586502 Jan 16  2023 vrf 
    ```
    
    </details>
    </br>


10. What is the CNI plugin configured to be used on this kubernetes cluster?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  ls -la /etc/cni/
    total 20
    drwx------ 1 root root 4096 Nov  2 11:33 .
    drwxr-xr-x 1 root root 4096 Dec 30 20:02 ..
    drwx------ 1 root root 4096 Dec 30 20:02 net.d

    controlplane ~ ➜  ls -la /etc/cni/net.d/
    total 16
    drwx------ 1 root root 4096 Dec 30 20:02 .
    drwx------ 1 root root 4096 Nov  2 11:33 ..
    -rw-r--r-- 1 root root  292 Dec 30 20:02 10-flannel.conflist
    
    ```
    
    </details>
    </br>


11. What binary executable file will be run by kubelet after a container and its associated namespace are created?

12. What binary executable file will be run by kubelet after a container and its associated namespace are created?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  ls -l /etc/cni/
    total 4
    drwx------ 1 root root 4096 Dec 30 20:02 net.d

    controlplane ~ ➜  ls -l /etc/cni/net.d/
    total 4
    -rw-r--r-- 1 root root 292 Dec 30 20:02 10-flannel.conflist 
    ```

    The answer is flannel. 

    ```bash
    controlplane ~ ✖ cat /etc/cni/net.d/10-flannel.conflist 
    {
      "name": "cbr0",
      "cniVersion": "0.3.1",
      "plugins": [
        {
          "type": "flannel",
          "delegate": {
            "hairpinMode": true,
            "isDefaultGateway": true
          }
        },
        {
          "type": "portmap",
          "capabilities": {
            "portMappings": true
          }
        }
      ]
    } 
    ```
    
    </details>
    </br>


13. Deploy weave-net networking solution to the cluster.

    NOTE: - We already have provided a weave manifest file under the /root/weave directory.

    <details><summary> Answer </summary>

    The pod cannot start because networking is not yet configured. 

    ```bash
    controlplane ~ ➜  k get po
    NAME   READY   STATUS              RESTARTS   AGE
    app    1/1     ContainerCreating   0          3m7s 
    ```

    Install weavenet via the weave manifest. 

    ```bash
    controlplane ~ ➜  ls -la /root/weave/
    total 20
    drwxr-xr-x 2 root root 4096 Dec 30 20:21 .
    drwx------ 1 root root 4096 Dec 30 20:20 ..
    -rw-r--r-- 1 root root 6259 Dec 30 20:21 weave-daemonset-k8s.yaml

    controlplane ~ ➜  k apply -f /root/weave/
    serviceaccount/weave-net created
    clusterrole.rbac.authorization.k8s.io/weave-net created
    clusterrolebinding.rbac.authorization.k8s.io/weave-net created
    role.rbac.authorization.k8s.io/weave-net created
    rolebinding.rbac.authorization.k8s.io/weave-net created
    daemonset.apps/weave-net created
    
    ```

    The app should now be able to run. 

    ```bash
    controlplane ~ ➜  k get po
    NAME   READY   STATUS    RESTARTS   AGE
    app    1/1     Running   0          3m7s 
    ```

    </details>
    </br>


14. What is the Networking Solution used by this cluster?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  ls -la /etc/cni/net.d/
    total 16
    drwx------ 1 root root 4096 Dec 30 22:19 .
    drwx------ 1 root root 4096 Nov  2 11:33 ..
    -rw-r--r-- 1 root root  318 Dec 30 22:19 10-weave.conflist

    controlplane ~ ➜  cat /etc/cni/net.d/10-weave.conflist 
    {
        "cniVersion": "0.3.0",
        "name": "weave",
        "plugins": [
            {
                "name": "weave",
                "type": "weave-net",
                "hairpinMode": true
            },
            {
                "type": "portmap",
                "capabilities": {"portMappings": true},
                "snat": true
            }
        ]
    } 
    ```
    
    </details>
    </br>


15. How many weave agents/peers are deployed in this cluster?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po -n kube-system 
    NAME                                   READY   STATUS    RESTARTS      AGE
    coredns-5d78c9869d-g5r7l               1/1     Running   0             24m
    coredns-5d78c9869d-kbzrl               1/1     Running   0             24m
    etcd-controlplane                      1/1     Running   0             24m
    kube-apiserver-controlplane            1/1     Running   0             24m
    kube-controller-manager-controlplane   1/1     Running   0             24m
    kube-proxy-6rzbz                       1/1     Running   0             24m
    kube-proxy-bqhf2                       1/1     Running   0             24m
    kube-scheduler-controlplane            1/1     Running   0             24m
    weave-net-mq78f                        2/2     Running   1 (23m ago)   24m
    weave-net-pxrzs                        2/2     Running   1 (23m ago)   24m 

    controlplane ~ ➜  k get po -n kube-system  -o wide ñ grep weave
    weave-net-mq78f                        2/2     Running   1 (24m ago)   24m   192.5.179.12   node01         <none>           <none>
    weave-net-pxrzs                        2/2     Running   1 (24m ago)   24m   192.5.179.9    controlplane   <none>           <none>
    ```
    
    </details>
    </br>


16. Identify the name of the bridge network/interface created by weave on each node.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  ip addr | grep weave
    4: weave: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1376 qdisc noqueue state UP group default qlen 1000
        inet 10.244.192.0/16 brd 10.244.255.255 scope global weave
    7: vethwe-bridge@vethwe-datapath: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1376 qdisc noqueue master weave state UP group default 
    10: vethwepl4a7ab64@if9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1376 qdisc noqueue master weave state UP group default 
    12: vethwepl6d8c184@if11: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1376 qdisc noqueue master weave state UP group default 

    ```
    
    </details>
    </br>


17. What is the default gateway configured on the PODs scheduled on node01?

    <details><summary> Answer </summary>

    We are interested with the route for weave, which shows default gateway of 10.244.0.1.

    ```bash
    root@node01 ~ ➜  ip route
    default via 172.25.0.1 dev eth1 
    10.244.0.0/16 dev weave proto kernel scope link src 10.244.0.1 
    172.25.0.0/24 dev eth1 proto kernel scope link src 172.25.0.35 
    192.5.179.0/24 dev eth0 proto kernel scope link src 192.5.179.12  
    ```
    
    </details>
    </br>


18. What is the range of IP addresses configured for PODs on this cluster? The network is configured with weave.

    <details><summary> Answer </summary>

    Check the pod for weave and see the logs. It should show the ip allocation range.

    ```bash
    controlplane ~ ➜  k get po -n kube-system
    NAME                                   READY   STATUS    RESTARTS      AGE
    coredns-5d78c9869d-9qdz4               1/1     Running   0             28m
    coredns-5d78c9869d-qzd27               1/1     Running   0             28m
    etcd-controlplane                      1/1     Running   0             28m
    kube-apiserver-controlplane            1/1     Running   0             28m
    kube-controller-manager-controlplane   1/1     Running   0             28m
    kube-proxy-gq9zh                       1/1     Running   0             28m
    kube-proxy-p6fhm                       1/1     Running   0             28m
    kube-scheduler-controlplane            1/1     Running   0             28m
    weave-net-5djnr                        2/2     Running   0             28m
    weave-net-wcmwp                        2/2     Running   1 (28m ago)   28m

    controlplane ~ ➜  k logs -n kube-system weave-net-5djnr | grep -i ip
    Defaulted container "weave" out of: weave, weave-npc, weave-init (init)
    INFO: 2023/12/31 03:24:40.683471 Command line options: map[conn-limit:200 datapath:datapath db-prefix:/weavedb/weave-net docker-api: expect-npc:true http-addr:127.0.0.1:6784 ipalloc-init:consensus=1 ipalloc-range:10.244.0.0/16 metrics-addr:0.0.0.0:6782 name:62:53:38:78:b6:a0 nickname:node01 no-dns:true no-masq-local:true port:6783] 
    ```
    
    </details>
    </br>


19. What is the IP Range configured for the services within the cluster?

    <details><summary> Answer </summary>

    From here we can see the the servuces are configured in the 10.96.0.x range. 

    ```bash
    controlplane ~ ➜  k get svc -A
    NAMESPACE     NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
    default       kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP                  31m
    kube-system   kube-dns     ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   31m
    ```

    We can also check the manifest for the kub-apiserver.

    ```bash
    controlplane ~ ➜  ls -l /etc/kubernetes/manifests/kube-apiserver.yaml 
    -rw------- 1 root root 3877 Dec 30 22:23 /etc/kubernetes/manifests/kube-apiserver.yaml

    controlplane ~ ➜  grep -i ip /etc/kubernetes/manifests/kube-apiserver.yaml 
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --service-cluster-ip-range=10.96.0.0/12  
    ```
    
    </details>
    </br>


20. What type of proxy is the kube-proxy configured to use?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po -n kube-system | grep kube-proxy
    kube-proxy-gq9zh                       1/1     Running   0             35m
    kube-proxy-p6fhm                       1/1     Running   0             36m

    controlplane ~ ➜  k logs -n kube-system kube-proxy-gq9zh | grep -i proxy
    I1231 03:24:13.560888       1 server_others.go:551] "Using iptables proxy"
    ```
    
    </details>
    </br>



21. How does this Kubernetes cluster ensure that a kube-proxy pod runs on all nodes in the cluster?

    <details><summary> Answer </summary>

    kube-proxy is managed through a DaemonSet. 
    
    ```bash
    controlplane ~ ➜  k get po -n kube-system | grep kube-pro
    kube-proxy-gq9zh                       1/1     Running   0             40m
    kube-proxy-p6fhm                       1/1     Running   0             40m

    controlplane ~ ➜  k describe  pod -n kube-system kube-proxy-gq9zh  | grep -i control
    Labels:               controller-revision-hash=7b6c5596fc
    Controlled By:  DaemonSet/kube-proxy 
    ```
    
    </details>
    </br>


22. Identify the DNS solution implemented in this cluster.

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ✖ k get po -A | grep dns
    kube-system    coredns-5d78c9869d-9gj8f               1/1     Running   0          5m23s
    kube-system    coredns-5d78c9869d-gp7z4               1/1     Running   0          5m23s 
    ```
    
    </details>
    </br>





23. What is the IP of the CoreDNS server that should be configured on PODs to resolve services?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get svc -n kube-system 
    NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
    kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   7m2s 
    ```
    
    </details>
    </br>





24. Where is the configuration file located for configuring the CoreDNS service?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po -n kube-system | grep dns
    coredns-5d78c9869d-9gj8f               1/1     Running   0          10m
    coredns-5d78c9869d-gp7z4               1/1     Running   0          10m

    controlplane ~ ➜  k describe -n kube-system pod coredns-5d78c9869d-gp7z4 | grep -i file
          /etc/coredns/Corefile 
    ```
    
    </details>
    </br>





25. How is the Corefile passed into the CoreDNS POD?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po -n kube-system | grep dns
    coredns-5d78c9869d-9gj8f               1/1     Running   0          11m
    coredns-5d78c9869d-gp7z4               1/1     Running   0          11m

    controlplane ~ ➜  k describe -n kube-system pod coredns-5d78c9869d-gp7z4 | grep -i control
    Node:                 controlplane/192.6.107.3
    Controlled By:  ReplicaSet/coredns-5d78c9869d
                                node-role.kubernetes.io/control-plane:NoSchedule
      Normal   Scheduled               11m   default-scheduler  Successfully assigned kube-system/coredns-5d78c9869d-gp7z4 to controlplane

    controlplane ~ ➜  k get rs -n kube-system 
    NAME                 DESIRED   CURRENT   READY   AGE
    coredns-5d78c9869d   2         2         2       11m
    ```

    When we try to check the YAML file for the ReplicaSet, we see that the file is passed as a ConfigMap object.

    ```bash
    controlplane ~ ➜  k get rs -n kube-system coredns-5d78c9869d -o yaml | grep -i corefile -B5
                  topologyKey: kubernetes.io/hostname
                weight: 100
          containers:
          - args:
            - -conf
            - /etc/coredns/Corefile
    --
            key: node-role.kubernetes.io/control-plane
          volumes:
          - configMap:
              defaultMode: 420
              items:
              - key: Corefile
                path: Corefile 
    ```
    
    </details>
    </br>





26. Since we know that the Corefile is passed as a ConfigMap object, determine the root domain/zone configured for this kubernetes cluster.

    <details><summary> Answer </summary>

    The root domain is **cluster.local**.

    ```bash
    controlplane ~ ➜  k get cm -n kube-system
    NAME                                                   DATA   AGE
    coredns                                                1      15m
    extension-apiserver-authentication                     6      16m
    kube-apiserver-legacy-service-account-token-tracking   1      16m
    kube-proxy                                             2      15m
    kube-root-ca.crt                                       1      15m
    kubeadm-config                                         1      15m
    kubelet-config                                         1      15m

    controlplane ~ ➜  k describe -n kube-system cm coredns
    Name:         coredns
    Namespace:    kube-system
    Labels:       <none>
    Annotations:  <none>

    Data
    ====
    Corefile:
    ----
    .:53 {
        errors
        health {
          lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          pods insecure
          fallthrough in-addr.arpa ip6.arpa
          ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
          max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }


    BinaryData
    ====

    Events:  <none> 
    ```
    
    </details>
    </br>





27. What name can be used to access the hr web server from the test Application?

    ```bash
    controlplane ~ ➜  k get po -A
    NAMESPACE      NAME                                   READY   STATUS    RESTARTS   AGE
    default        hr                                     1/1     Running   0          13m
    default        simple-webapp-1                        1/1     Running   0          13m
    default        simple-webapp-122                      1/1     Running   0          13m
    default        test                                   1/1     Running   0          13m
    kube-flannel   kube-flannel-ds-m267z                  1/1     Running   0          18m
    kube-system    coredns-5d78c9869d-9gj8f               1/1     Running   0          18m
    kube-system    coredns-5d78c9869d-gp7z4               1/1     Running   0          18m
    kube-system    etcd-controlplane                      1/1     Running   0          18m
    kube-system    kube-apiserver-controlplane            1/1     Running   0          18m
    kube-system    kube-controller-manager-controlplane   1/1     Running   0          18m
    kube-system    kube-proxy-hj5vp                       1/1     Running   0          18m
    kube-system    kube-scheduler-controlplane            1/1     Running   0          18m
    payroll        web                                    1/1     Running   0          13m

    controlplane ~ ➜  k get svc -A
    NAMESPACE     NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                  AGE
    default       kubernetes     ClusterIP   10.96.0.1       <none>        443/TCP                  18m
    default       test-service   NodePort    10.96.250.160   <none>        80:30080/TCP             13m
    default       web-service    ClusterIP   10.108.205.43   <none>        80/TCP                   13m
    kube-system   kube-dns       ClusterIP   10.96.0.10      <none>        53/UDP,53/TCP,9153/TCP   18m
    payroll       web-service    ClusterIP   10.96.157.205   <none>        80/TCP                   13m 
    ```

    <details><summary> Answer </summary>

    Remove the -A flag so that it only shows the resources in the default namespace where the hr pod is.

    ```bash
    controlplane ~ ➜  k get po
    NAME                READY   STATUS    RESTARTS   AGE
    hr                  1/1     Running   0          16m
    simple-webapp-1     1/1     Running   0          15m
    simple-webapp-122   1/1     Running   0          15m
    test                1/1     Running   0          16m

    controlplane ~ ➜  k get svc
    NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
    kubernetes     ClusterIP   10.96.0.1       <none>        443/TCP        21m
    test-service   NodePort    10.96.250.160   <none>        80:30080/TCP   16m
    web-service    ClusterIP   10.108.205.43   <none>        80/TCP         16m 
    ```

    Run a curl from within the hr pod. 

    ```bash
    controlplane ~ ✖ k exec -it hr -- curl web-service:80
    This is the HR server!
    ```
    
    </details>
    </br>





28. Which of the names CANNOT be used to access the HR service from the test pod?

    - web-service
    - web-service.default
    - web-service.default.pod
    - web-service.default.svc

    ```bash
    controlplane ~ ➜  k get po
    NAME                READY   STATUS    RESTARTS   AGE
    hr                  1/1     Running   0          19m
    simple-webapp-1     1/1     Running   0          19m
    simple-webapp-122   1/1     Running   0          19m
    test                1/1     Running   0          19m

    controlplane ~ ➜  k get svc
    NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
    kubernetes     ClusterIP   10.96.0.1       <none>        443/TCP        24m
    test-service   NodePort    10.96.250.160   <none>        80:30080/TCP   19m
    web-service    ClusterIP   10.108.205.43   <none>        80/TCP         19m
      
    ```
    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k exec -it test -- curl web-service:80
    This is the HR server!

    controlplane ~ ➜  k exec -it test -- curl web-service.default:80
    This is the HR server!

    controlplane ~ ➜  k exec -it test -- curl web-service.default.pod:80
    curl: (6) Could not resolve host: web-service.default.pod
    command terminated with exit code 6

    controlplane ~ ➜  k exec -it test -- curl web-service.default.svc:80
    This is the HR server! 
    ```

    The answer is web-service.default.pod.
    
    </details>
    </br>





29. Which of the below name can be used to access the payroll service from the test application?

    - web-service.payroll
    - web-service
    - web
    - web-service.default

    ```bash
    controlplane ~ ➜  k get svc -n payroll
    NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
    web-service   ClusterIP   10.96.157.205   <none>        80/TCP    26m

    controlplane ~ ➜  k get po
    NAME                READY   STATUS    RESTARTS   AGE
    hr                  1/1     Running   0          26m
    simple-webapp-1     1/1     Running   0          26m
    simple-webapp-122   1/1     Running   0          26m
    test                1/1     Running   0          26m
    ```

    <details><summary> Answer </summary>
        
    ```bash
    controlplane ~ ➜  k exec -it test -- curl web-service.payroll:80
    This is the PayRoll server!

    controlplane ~ ➜  k exec -it test -- curl web-service:80
    This is the HR server!

    controlplane ~ ➜  k exec -it test -- curl web:80
    curl: (6) Could not resolve host: web
    command terminated with exit code 6

    controlplane ~ ✖ k exec -it test -- curl web-service.default:80
    This is the HR server!
    ```

    The answers are:
    - web-service.payroll
    - web-service
    - web-service.default

    </details>
    </br>





30. We just deployed a web server - webapp - that accesses a database mysql - server. However the web server is failing to connect to the database server. Troubleshoot and fix the issue.

    ```bash
    controlplane ~ ➜  k get po -A
    NAMESPACE      NAME                                   READY   STATUS    RESTARTS   AGE
    default        hr                                     1/1     Running   0          30m
    default        simple-webapp-1                        1/1     Running   0          30m
    default        simple-webapp-122                      1/1     Running   0          30m
    default        test                                   1/1     Running   0          30m
    default        webapp-54b76556d-89b25                 1/1     Running   0          30s
    kube-flannel   kube-flannel-ds-m267z                  1/1     Running   0          35m
    kube-system    coredns-5d78c9869d-9gj8f               1/1     Running   0          35m
    kube-system    coredns-5d78c9869d-gp7z4               1/1     Running   0          35m
    kube-system    etcd-controlplane                      1/1     Running   0          35m
    kube-system    kube-apiserver-controlplane            1/1     Running   0          35m
    kube-system    kube-controller-manager-controlplane   1/1     Running   0          35m
    kube-system    kube-proxy-hj5vp                       1/1     Running   0          35m
    kube-system    kube-scheduler-controlplane            1/1     Running   0          35m
    payroll        mysql                                  1/1     Running   0          30s
    payroll        web                                    1/1     Running   0          30m 
    ```

    <details><summary> Answer </summary>

    From the given above, we can see that the web-app and mysql are in different namespaces. There are two options here:
    - Make sure both are in the same namespace
    - Configure the webapp to point to the mysql at payroll namespace.

    We will so the second option.

    ```bash
    controlplane ~ ➜  k get deploy
    NAME     READY   UP-TO-DATE   AVAILABLE   AGE
    webapp   1/1     1            1           7m54s

    controlplane ~ ➜  k edit deploy webapp
    ```

    Append the namespace after the hostname.  

    ```bash
        spec:
          containers:
          - env:
            - name: DB_Host
              value: mysql.payroll
            - name: DB_User
              value: root
            - name: DB_Password
              value: paswrd
            image: mmumshad/simple-webapp-mysql
            imagePullPolicy: Always
            name: simple-webapp-mysql
            ports:
    ```
    
    </details>
    </br>





31. From the hr pod nslookup the mysql service and redirect the output to a file /root/CKA/nslookup.out

    ```bash
    controlplane ~ ➜  k get po
    NAME                      READY   STATUS    RESTARTS   AGE
    hr                        1/1     Running   0          43m
    simple-webapp-1           1/1     Running   0          43m
    simple-webapp-122         1/1     Running   0          43m
    test                      1/1     Running   0          43m
    webapp-6fdb68c84f-wvgd2   1/1     Running   0          2m37s

    controlplane ~ ➜  k get svc -n payroll
    NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
    mysql         ClusterIP   10.96.128.66    <none>        3306/TCP   13m
    web-service   ClusterIP   10.96.157.205   <none>        80/TCP     43m
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k exec -it hr -- nslookup mysql.payroll
    Server:         10.96.0.10
    Address:        10.96.0.10#53

    Name:   mysql.payroll.svc.cluster.local
    Address: 10.96.128.66


    controlplane ~ ➜  k exec -it hr -- nslookup mysql.payroll > /root/CKA/nslookup.out

    controlplane ~ ➜  ls -la /root/CKA/nslookup.out 
    -rw-r--r-- 1 root root 111 Dec 30 23:53 /root/CKA/nslookup.out

    controlplane ~ ➜  cat /root/CKA/nslookup.out 
    Server:         10.96.0.10
    Address:        10.96.0.10#53

    Name:   mysql.payroll.svc.cluster.local
    Address: 10.96.128.66
    ```
    
    </details>
    </br>





32. Which namespace is the Ingress Controller deployed in?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get all -A | grep -i ingress
    ingress-nginx   pod/ingress-nginx-admission-create-ddtp2        0/1     Completed   0          84s
    ingress-nginx   pod/ingress-nginx-admission-patch-nn4hl         0/1     Completed   0          84s
    ingress-nginx   pod/ingress-nginx-controller-5d48d5445f-zwmd9   1/1     Running     0          85s
    ingress-nginx   service/ingress-nginx-controller             NodePort    10.103.62.71    <none>        80:30080/TCP,443:32103/TCP   85s
    ingress-nginx   service/ingress-nginx-controller-admission   ClusterIP   10.96.188.183   <none>        443/TCP                      85s
    ingress-nginx   deployment.apps/ingress-nginx-controller   1/1     1            1           85s
    ingress-nginx   replicaset.apps/ingress-nginx-controller-5d48d5445f   1         1         1       85s
    ingress-nginx   job.batch/ingress-nginx-admission-create   1/1           10s        85s
    ingress-nginx   job.batch/ingress-nginx-admission-patch    1/1           9s         84s 
    ```
    
    </details>
    </br>





33. What is the name of the ingress resource deployed?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k api-resources | grep -i ingress
    ingressclasses                                 networking.k8s.io/v1                   false        IngressClass
    ingresses                         ing          networking.k8s.io/v1                   true         Ingress

    controlplane ~ ➜  k get ing -A
    NAMESPACE   NAME                 CLASS    HOSTS   ADDRESS        PORTS   AGE
    app-space   ingress-wear-watch   <none>   *       10.103.62.71   80      4m12s 
    ```
    
    </details>
    </br>





34. What is the Host configured on the Ingress Resource?

    <details><summary> Answer </summary>

    All Hosts (*)

    ```bash
    controlplane ~ ➜  k api-resources | grep -i ingress
    ingressclasses                                 networking.k8s.io/v1                   false        IngressClass
    ingresses                         ing          networking.k8s.io/v1                   true         Ingress

    controlplane ~ ➜  k get ing -A
    NAMESPACE   NAME                 CLASS    HOSTS   ADDRESS        PORTS   AGE
    app-space   ingress-wear-watch   <none>   *       10.103.62.71   80      4m12s

    controlplane ~ ➜  k describe -n app-space ingress ingress-wear-watch 
    Name:             ingress-wear-watch
    Labels:           <none>
    Namespace:        app-space
    Address:          10.103.62.71
    Ingress Class:    <none>
    Default backend:  <default>
    Rules:
      Host        Path  Backends
      ----        ----  --------
      *           
                  /wear    wear-service:8080 (10.244.0.4:8080)
                  /watch   video-service:8080 (10.244.0.5:8080)
    Annotations:  nginx.ingress.kubernetes.io/rewrite-target: /
                  nginx.ingress.kubernetes.io/ssl-redirect: false
    Events:
      Type    Reason  Age                    From                      Message
      ----    ------  ----                   ----                      -------
      Normal  Sync    4m29s (x2 over 4m30s)  nginx-ingress-controller  Scheduled for sync 
    ```
    
    </details>
    </br>





35. You are requested to change the URLs at which the applications are made available. Make the change in the given Ingress Controller.

    ```bash
    controlplane ~ ➜  k get ing -A
    NAMESPACE   NAME                 CLASS    HOSTS   ADDRESS        PORTS   AGE
    app-space   ingress-wear-watch   <none>   *       10.103.62.71   80      7m48s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k edit -n app-space ingress ingress-wear-watch  
    ```
    ```bash
    # Please edit the object below. Lines beginning with a '#' will be ignored,
    # and an empty file will abort the edit. If an error occurs while saving this file will be
    # reopened with the relevant failures.
    #
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: /
        nginx.ingress.kubernetes.io/ssl-redirect: "false"
      creationTimestamp: "2023-12-31T04:54:24Z"
      generation: 1
      name: ingress-wear-watch
      namespace: app-space
      resourceVersion: "910"
      uid: 2e334919-c62f-4513-8400-e47ebf0eabf4
    spec:
      rules:
      - http:
          paths:
          - backend:
              service:
                name: wear-service
                port:
                  number: 8080
            path: /wear
            pathType: Prefix
          - backend:
              service:
                name: video-service
                port:
                  number: 8080
            path: /stream
            pathType: Prefix
    status:
      loadBalancer:
        ingress:
        - ip: 10.103.62.71 
    ```
 
    </details>
    </br>


36. You are requested to add a new path to your ingress to make the food delivery application available to your customers.

    Make the new application available at /eat.

    ```bash
    controlplane ~ ➜  k get deploy -n app-space
    NAME              READY   UP-TO-DATE   AVAILABLE   AGE
    default-backend   1/1     1            1           10m
    webapp-food       1/1     1            1           13s
    webapp-video      1/1     1            1           10m
    webapp-wear       1/1     1            1           10m 

    controlplane ~ ➜  k get svc -n app-space 
    NAME                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
    default-backend-service   ClusterIP   10.99.131.124   <none>        80/TCP     14m
    food-service              ClusterIP   10.109.123.30   <none>        8080/TCP   4m5s
    video-service             ClusterIP   10.98.228.143   <none>        8080/TCP   14m
    wear-service              ClusterIP   10.109.75.46    <none>        8080/TCP   14m

    controlplane ~ ➜  k get ing -A
    NAMESPACE   NAME                 CLASS    HOSTS   ADDRESS        PORTS   AGE
    app-space   ingress-wear-watch   <none>   *       10.103.62.71   80      11m    
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k edit -n app-space ingress ingress-wear-watch  
    ```
    ```bash
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: /
        nginx.ingress.kubernetes.io/ssl-redirect: "false"
      creationTimestamp: "2023-12-31T04:54:24Z"
      generation: 3
      name: ingress-wear-watch
      namespace: app-space
      resourceVersion: "2107"
      uid: 2e334919-c62f-4513-8400-e47ebf0eabf4
    spec:
      rules:
      - http:
          paths:
          - backend:
              service:
                name: wear-service
                port:
                  number: 8080
            path: /wear
            pathType: Prefix
          - backend:
              service:
                name: video-service
                port:
                  number: 8080
            path: /stream
            pathType: Prefix
          - backend:
              service:
                name: food-service
                port:
                  number: 8080
            path: /eat
            pathType: Prefix 
    ```
    
    </details>
    </br>



37. You are requested to make the new application **webapp-pay**  available at /pay.

    Identify and implement the best approach to making this application available on the ingress controller and test to make sure its working. Look into annotations: rewrite-target as well.

    ```bash
    controlplane ~ ➜  k get deploy -A
    NAMESPACE        NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
    app-space        default-backend            1/1     1            1           16m
    app-space        webapp-food                1/1     1            1           7m2s
    app-space        webapp-video               1/1     1            1           16m
    app-space        webapp-wear                1/1     1            1           16m
    critical-space   webapp-pay                 1/1     1            1           102s
    ingress-nginx    ingress-nginx-controller   1/1     1            1           16m
    kube-system      coredns                    2/2     2            2           20m 

    controlplane ~ ➜  k get svc -n critical-space 
    NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
    pay-service   ClusterIP   10.106.32.226   <none>        8282/TCP   2m13s

    controlplane ~ ➜  k get ing -A
    NAMESPACE   NAME                 CLASS    HOSTS   ADDRESS        PORTS   AGE
    app-space   ingress-wear-watch   <none>   *       10.103.62.71   80      17m    
    ```

    <details><summary> Answer </summary>

    Do not modify the existing ingress resource. Simply create a new one. 

    ```bash
    ## ingress-pay.yaml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: minimal-ingress
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: /
    spec:
      ingressClassName: nginx-example
      rules:
      - http:
          paths:
          - path: /testpath
            pathType: Prefix
            backend:
              service:
                name: test
                port:
                  number: 80             
    ```
    ```bash
    controlplane ~ ➜  k apply -f ingress-pay.yaml 
    ingress.networking.k8s.io/pay-ingress created

    controlplane ~ ➜  k get ing -A
    NAMESPACE        NAME                 CLASS    HOSTS   ADDRESS        PORTS   AGE
    app-space        ingress-wear-watch   <none>   *       10.103.62.71   80      25m
    critical-space   pay-ingress          <none>   *                      80      7s  
    ```
    
    </details>
    </br>


38. Deploy an Ingress Controller. 

    - First, create a namespace called ingress-nginx.
    - The NGINX Ingress Controller requires a ConfigMap object. Create a ConfigMap object with name ingress-nginx-controller in the ingress-nginx namespace.
    - The NGINX Ingress Controller requires two ServiceAccounts. Create both ServiceAccount with name ingress-nginx and ingress-nginx-admission in the ingress-nginx namespace. Use the spec provided below.
      - Name: ingress-nginx
      - Name: ingress-nginx-admission
    - The roles, clusterroles, rolebindings, and clusterrolebindings have been created
    - Create the Ingress Controller using the /root/ingress-controller.yaml. There are several issues with it. Try to fix them.
    - Finally, create the ingress resource to make the applications available at /wear and /watch on the Ingress service. Also, make use of rewrite-target annotation field.
      - Path: /wear
      - Path: /watch


    <details><summary> Answer </summary>

    ```bash
    controlplane ~ ➜  export do="--dry-run=client -o yaml"

    controlplane ~ ➜  export now="--force --grace-period=0" 
    ```

    ```bash
    controlplane ~ ➜  k create ns ingress-nginx
    namespace/ingress-nginx created

    controlplane ~ ➜  k get ns
    NAME              STATUS   AGE
    app-space         Active   67s
    default           Active   8m20s
    ingress-nginx     Active   2s
    kube-flannel      Active   8m14s
    kube-node-lease   Active   8m20s
    kube-public       Active   8m20s
    kube-system       Active   8m20s
    
    ```

    Create the ConfigMap.
    ```bash
    controlplane ~ ➜  k create configmap ingress-nginx-controller --namespace ingress-nginx $do
    apiVersion: v1
    kind: ConfigMap
    metadata:
      creationTimestamp: null
      name: ingress-nginx-controller
      namespace: ingress-nginx 

    controlplane ~ ➜  k create configmap ingress-nginx-controller --namespace ingress-nginx $do > cm-ingress-nginx-controller.yml

    controlplane ~ ➜  k create configmap ingress-nginx-controller --namespace ingress-nginx
    configmap/ingress-nginx-controller created

    controlplane ~ ➜  k get cm -n ingress-nginx 
    NAME                       DATA   AGE
    ingress-nginx-controller   0      53s
    kube-root-ca.crt           1      3m18s
    ```

    Next, create the service accounts. 

    ```bash
    controlplane ~ ➜  k create sa ingress-nginx-admission --namespace ingress-nginx $do
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      creationTimestamp: null
      name: ingress-nginx-admission
      namespace: ingress-nginx

    controlplane ~ ➜  k create sa ingress-nginx-admission --namespace ingress-nginx $do > sa-ingress-nginx-admission.yml

    controlplane ~ ➜  k create sa ingress-nginx-admission --namespace ingress-nginx
    serviceaccount/ingress-nginx-admission created

    controlplane ~ ➜  k get sa -n ingress-nginx 
    NAME                      SECRETS   AGE
    default                   0         8m53s
    ingress-nginx             0         67s
    ingress-nginx-admission   0         14s
    ```

    Fix the ingress-controller.yaml and apply afterwards.

    ```yaml
    ## ingress-controller.yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels:
        app.kubernetes.io/component: controller
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/managed-by: Helm
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/part-of: ingress-nginx
        app.kubernetes.io/version: 1.1.2
        helm.sh/chart: ingress-nginx-4.0.18
      name: ingress-nginx-controller
      namespace: ingress-nginx
    spec:
      minReadySeconds: 0
      revisionHistoryLimit: 10
      selector:
        matchLabels:
          app.kubernetes.io/component: controller
          app.kubernetes.io/instance: ingress-nginx
          app.kubernetes.io/name: ingress-nginx
      template:
        metadata:
          labels:
            app.kubernetes.io/component: controller
            app.kubernetes.io/instance: ingress-nginx
            app.kubernetes.io/name: ingress-nginx
        spec:
          containers:
          - args:
            - /nginx-ingress-controller
            - --publish-service=$(POD_NAMESPACE)/ingress-nginx-controller
            - --election-id=ingress-controller-leader
            - --watch-ingress-without-class=true
            - --default-backend-service=app-space/default-http-backend
            - --controller-class=k8s.io/ingress-nginx
            - --ingress-class=nginx
            - --configmap=$(POD_NAMESPACE)/ingress-nginx-controller
            - --validating-webhook=:8443
            - --validating-webhook-certificate=/usr/local/certificates/cert
            - --validating-webhook-key=/usr/local/certificates/key
            env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: LD_PRELOAD
              value: /usr/local/lib/libmimalloc.so
            image: registry.k8s.io/ingress-nginx/controller:v1.1.2@sha256:28b11ce69e57843de44e3db6413e98d09de0f6688e33d4bd384002a44f78405c
            imagePullPolicy: IfNotPresent
            lifecycle:
              preStop:
                exec:
                  command:
                  - /wait-shutdown
            livenessProbe:
              failureThreshold: 5
              httpGet:
                path: /healthz
                port: 10254
                scheme: HTTP
              initialDelaySeconds: 10
              periodSeconds: 10
              successThreshold: 1
              timeoutSeconds: 1
            name: controller
            ports:
            - name: http
              containerPort: 80
              protocol: TCP
            - containerPort: 443
              name: https
              protocol: TCP
            - containerPort: 8443
              name: webhook
              protocol: TCP
            readinessProbe:
              failureThreshold: 3
              httpGet:
                path: /healthz
                port: 10254
                scheme: HTTP
              initialDelaySeconds: 10
              periodSeconds: 10
              successThreshold: 1
              timeoutSeconds: 1
            resources:
              requests:
                cpu: 100m
                memory: 90Mi
            securityContext:
              allowPrivilegeEscalation: true
              capabilities:
                add:
                - NET_BIND_SERVICE
                drop:
                - ALL
              runAsUser: 101
            volumeMounts:
            - mountPath: /usr/local/certificates/
              name: webhook-cert
              readOnly: true
          dnsPolicy: ClusterFirst
          nodeSelector:
            kubernetes.io/os: linux
          serviceAccountName: ingress-nginx
          terminationGracePeriodSeconds: 300
          volumes:
          - name: webhook-cert
            secret:
              secretName: ingress-nginx-admission

    ---
    apiVersion: v1
    kind: Service
    metadata:
      creationTimestamp: null
      labels:
        app.kubernetes.io/component: controller
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/managed-by: Helm
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/part-of: ingress-nginx
        app.kubernetes.io/version: 1.1.2
        helm.sh/chart: ingress-nginx-4.0.18
      name: ingress-nginx-controller
      namespace: ingress-nginx
    spec:
      ports:
      - port: 80
        protocol: TCP
        targetPort: 80
        nodePort: 30080
      selector:
        app.kubernetes.io/component: controller
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/name: ingress-nginx
      type: NodePort 
    ```
    ```bash
    controlplane ~ ➜  k get -n ingress-nginx po
    NAME                                       READY   STATUS      RESTARTS   AGE
    ingress-nginx-admission-create-wtzf6       0/1     Completed   0          7m32s
    ingress-nginx-controller-cc9f46d74-fmc65   0/1     Running     0          13s

    controlplane ~ ➜  k get -n ingress-nginx svc
    NAME                                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
    ingress-nginx-controller             NodePort    10.104.168.175   <none>        80:30080/TCP   18s
    ingress-nginx-controller-admission   ClusterIP   10.105.49.126    <none>        443/TCP        7m37s 
    ```

    Next, create the ingress resource. 
    But first, get the services in the app-space namespace.

    ```bash
    controlplane ~ ➜  k get svc -n app-space
    NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
    default-http-backend   ClusterIP   10.104.25.24    <none>        80/TCP     29m
    video-service          ClusterIP   10.97.188.119   <none>        8080/TCP   29m
    wear-service           ClusterIP   10.98.183.145   <none>        8080/TCP   29m 
    ```

    ```yaml
    ## ingress-resource.yaml 
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: app-ingress
      namespace: app-space
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: /
    spec:
      ingressClassName: nginx-example
      rules:
      - http:
          paths:
          - path: /wear
            pathType: Prefix
            backend:
              service:
                name: wear-service
                port:
                  number: 8080
          - path: /watch
            pathType: Prefix
            backend:
              service:
                name: video-service
                port:
                  number: 8080
    ```
    ```bash
    controlplane ~ ➜  k apply -f ingress-resource.yaml 
    ingress.networking.k8s.io/app-ingress created

    controlplane ~ ➜  k get ing -n app-space
    NAME          CLASS           HOSTS   ADDRESS   PORTS   AGE
    app-ingress   nginx-example   *                 80      12s 
    ```
    </details>
    </br>



[Back to the top](#practice-test-cka)    



