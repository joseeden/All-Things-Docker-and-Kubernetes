
# Log Locations 

Use *ls -lrt* to see which logs are updated most recently in each directory. 

```bash
/var/log/pods
/var/log/containers
/var/log/syslog
```

For self-managed Kubernetes clusters, we can also use crictl. 

```bash
crictl ps + crictl logs
docker ps + docker logs (in case when Docker is used)
kubelet logs:  or journalctl 
```

Example:

```bash
controlplane $ crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                      ATTEMPT             POD ID              POD
a01eab90b2306       b462ce0c8b1ff       34 seconds ago      Running             kube-scheduler            7                   65c628412e339       kube-scheduler-controlplane
f50331b651f99       821b3dfea27be       36 seconds ago      Running             kube-controller-manager   6                   dc31eea7af32a       kube-controller-manager-controlplane
a1c7ff1001706       f9c3c1813269c       6 minutes ago       Running             calico-kube-controllers   2                   c980b2805dd65       calico-kube-controllers-9d57d8f49-mwjrd
699b6fcec9065       e6ea68648f0cd       16 minutes ago      Running             kube-flannel              0                   df66746a0e14c       canal-zlfvr
2416199476dd5       75392e3500e36       16 minutes ago      Running             calico-node               0                   df66746a0e14c       canal-zlfvr
49f8782e5cd33       2947d8f11d3b0       8 days ago          Running             local-path-provisioner    0                   9eb0558b5d62a       local-path-provisioner-5d854bc5c4-mzrp6
b664f4f6e4f11       73deb9a3f7025       8 days ago          Running             etcd                      0                   948aeb95f5692       etcd-controlplane
2b9f53ea3d711       ead0a4a53df89       8 days ago          Running             coredns                   0                   94e0627188fdf       coredns-7cbb7cccb8-s8frn
fb0aaa805fd41       ead0a4a53df89       8 days ago          Running             coredns                   0                   94bf16c625436       coredns-7cbb7cccb8-qhxvw
2fa8f600a80d7       6cdbabde3874e       8 days ago          Running             kube-proxy                0                   cc8ec1cdc63cc       kube-proxy-x56jw
```

```bash
controlplane $ crictl logs a01ea
E1123 05:48:54.733434       1 reflector.go:147] vendor/k8s.io/client-go/informers/factory.go:150: Failed to watch *v1.ReplicationController: failed to list *v1.ReplicationController: Get "https://172.30.1.2:6443/api/v1/replicationcontrollers?limit=500&resourceVersion=0": dial tcp 172.30.1.2:6443: connect: connection refused
W1123 05:48:59.174489       1 reflector.go:535] vendor/k8s.io/client-go/informers/factory.go:150: failed to list *v1.Node: Get "https://172.30.1.2:6443/api/v1/nodes?limit=500&resourceVersion=0": dial tcp 172.30.1.2:6443: connect: connection refused
E1123 05:48:59.174535       1 reflector.go:147] vendor/k8s.io/client-go/informers/factory.go:150: Failed to watch *v1.Node: failed to list *v1.Node: Get "https://172.30.1.2:6443/api/v1/nodes?limit=500&resourceVersion=0": dial tcp 172.30.1.2:6443: connect: connection refused
```
```bash
controlplane $ journalctl | grep apiserver 
Nov 23 05:50:01 controlplane kubelet[25086]: E1123 05:50:01.049407   25086 mirror_client.go:138] "Failed deleting a mirror pod" err="Delete \"https://172.30.1.2:6443/api/v1/namespaces/kube-system/pods/kube-apiserver-controlplane\": dial tcp 172.30.1.2:6443: connect: connection refused" pod="kube-system/kube-apiserver-controlplane"
Nov 23 05:50:01 controlplane kubelet[25086]: E1123 05:50:01.049950   25086 pod_workers.go:1300] "Error syncing pod, skipping" err="failed to \"StartContainer\" for \"kube-apiserver\" with CrashLoopBackOff: \"back-off 20s restarting failed container=kube-apiserver pod=kube-apiserver-controlplane_kube-system(5adc793c6b0fca0b07ed510f4d741def)\"" pod="kube-system/kube-apiserver-controlplane" podUID="5adc793c6b0fca0b07ed510f4d741def" 
```
```bash
controlplane $ tail -f /var/log/syslog | grep apiserver 
Nov 23 05:50:59 controlplane kubelet[25086]: I1123 05:50:59.049147   25086 kubelet.go:1872] "Trying to delete pod" pod="kube-system/kube-apiserver-controlplane" podUID="c4771523-d406-4a03-aebb-fb807d9d60e1"
Nov 23 05:50:59 controlplane kubelet[25086]: I1123 05:50:59.049880   25086 status_manager.go:853] "Failed to get status for pod" podUID="5adc793c6b0fca0b07ed510f4d741def" pod="kube-system/kube-apiserver-controlplane" err="Get \"https://172.30.1.2:6443/api/v1/namespaces/kube-system/pods/kube-apiserver-controlplane\": dial tcp 172.30.1.2:6443: connect: connection refused"
Nov 23 05:50:59 controlplane kubelet[25086]: E1123 05:50:59.050085   25086 mirror_client.go:138] "Failed deleting a mirror pod" err="Delete \"https://172.30.1.2:6443/api/v1/namespaces/kube-system/pods/kube-apiserver-controlplane\": dial tcp 172.30.1.2:6443: connect: connection refused" pod="kube-system/kube-apiserver-controlplane"
Nov 23 05:50:59 controlplane kubelet[25086]: E1123 05:50:59.050595   25086 pod_workers.go:1300] "Error syncing pod, skipping" err="failed to \"StartContainer\" for \"kube-apiserver\" with CrashLoopBackOff: \"back-off 40s restarting failed container=kube-apiserver pod=kube-apiserver-controlplane_kube-system(5adc793c6b0fca0b07ed510f4d741def)\"" pod="kube-system/kube-apiserver-controlplane" podUID="5adc793c6b0fca0b07ed510f4d741def"
```