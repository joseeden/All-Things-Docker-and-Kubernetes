
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


<details><summary> Answer </summary>
 
```bash
 
```
 
</details>
</br>


<details><summary> Answer </summary>
 
```bash
 
```
 
</details>
</br>


<details><summary> Answer </summary>
 
```bash
 
```
 
</details>
</br>


<details><summary> Answer </summary>
 
```bash
 
```
 
</details>
</br>


<details><summary> Answer </summary>
 
```bash
 
```
 
</details>
</br>


<details><summary> Answer </summary>
 
```bash
 
```
 
</details>
</br>


<details><summary> Answer </summary>
 
```bash
 
```
 
</details>
</br>


<details><summary> Answer </summary>
 
```bash
 
```
 
</details>
</br>




[Back to the top](#practice-test-cka)    
