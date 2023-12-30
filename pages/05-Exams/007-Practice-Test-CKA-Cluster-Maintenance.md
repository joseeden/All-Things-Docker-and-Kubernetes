
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


## Cluster Maintenance 

1. We need to take node01 out for maintenance. Empty the node of all applications and mark it unschedulable.

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS   ROLES           AGE   VERSION
    controlplane   Ready    control-plane   15m   v1.27.0
    node01         Ready    <none>          14m   v1.27.0 

    controlplane ~ ➜  k get po -o wide
    NAME                    READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
    blue-6b478c8dbf-ckr7g   1/1     Running   0          44s     10.244.0.5   node01         <none>           <none>
    blue-6b478c8dbf-s6wz7   1/1     Running   0          2m55s   10.244.0.4   node01         <none>           <none>
    blue-6b478c8dbf-znjvb   1/1     Running   0          44s     10.244.0.6   controlplane   <none>           <none>    
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  kubectl drain --ignore-daemonsets node01
    node/node01 cordoned
    Warning: ignoring DaemonSet-managed Pods: kube-flannel/kube-flannel-ds-xbjl9, kube-system/kube-proxy-tcbnn
    evicting pod default/blue-6b478c8dbf-rggmf
    evicting pod default/blue-6b478c8dbf-lscjp
    pod/blue-6b478c8dbf-lscjp evicted
    pod/blue-6b478c8dbf-rggmf evicted
    node/node01 drained

    controlplane ~ ➜  k get no
    NAME           STATUS                     ROLES           AGE   VERSION
    controlplane   Ready                      control-plane   17m   v1.27.0
    node01         Ready,SchedulingDisabled   <none>          17m   v1.27.0 

    controlplane ~ ➜  k get po -o wide
    NAME                    READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
    blue-6b478c8dbf-ckr7g   1/1     Running   0          44s     10.244.0.5   controlplane   <none>           <none>
    blue-6b478c8dbf-s6wz7   1/1     Running   0          2m55s   10.244.0.4   controlplane   <none>           <none>
    blue-6b478c8dbf-znjvb   1/1     Running   0          44s     10.244.0.6   controlplane   <none>           <none>
    ```
    
    </details>
    </br>

2. The maintenance tasks have been completed. Configure the node node01 to be schedulable again.

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS                     ROLES           AGE   VERSION
    controlplane   Ready                      control-plane   19m   v1.27.0
    node01         Ready,SchedulingDisabled   <none>          19m   v1.27.0 
    ```

    <details><summary> Answer </summary>

    resume scheduling new pods onto the node, we need to uncordon the node. 

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS                     ROLES           AGE   VERSION
    controlplane   Ready                      control-plane   19m   v1.27.0
    node01         Ready,SchedulingDisabled   <none>          19m   v1.27.0

    controlplane ~ ➜  k uncordon node01
    node/node01 uncordoned

    controlplane ~ ➜  k get no
    NAME           STATUS   ROLES           AGE   VERSION
    controlplane   Ready    control-plane   22m   v1.27.0
    node01         Ready    <none>          22m   v1.27.0
    ```
    
    </details>
    </br>





3. We need to carry out a maintenance activity on node01 again. When we try to drain the node, it is encoutnering an error.

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS   ROLES           AGE   VERSION
    controlplane   Ready    control-plane   25m   v1.27.0
    node01         Ready    <none>          25m   v1.27.0 
    ```

    <details><summary> Answer </summary>

    From the output below, we can see that there is a pod deployed on node01, and this pod is not part of a replicaset. This pod prevents the draining of the node. 
    We need to force the draining. 

    ```bash
    controlplane ~ ➜  k drain node01 --ignore-daemonsets 
    node/node01 cordoned
    error: unable to drain node "node01" due to error:cannot delete Pods declare no controller (use --force to override): default/hr-app, continuing command...
    There are pending nodes to be drained:
    node01
    cannot delete Pods declare no controller (use --force to override): default/hr-app 

    controlplane ~ ➜  k get po -o wide
    NAME                    READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
    blue-6b478c8dbf-ckr7g   1/1     Running   0          10m     10.244.0.5   controlplane   <none>           <none>
    blue-6b478c8dbf-s6wz7   1/1     Running   0          12m     10.244.0.4   controlplane   <none>           <none>
    blue-6b478c8dbf-znjvb   1/1     Running   0          10m     10.244.0.6   controlplane   <none>           <none>
    hr-app                  1/1     Running   0          2m14s   10.244.1.4   node01         <none>           <none>

    controlplane ~ ➜  k get rs -o wide
    NAME              DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES         SELECTOR
    blue-6b478c8dbf   3         3         3       12m   nginx        nginx:alpine   app=blue,pod-template-hash=6b478c8dbf

    controlplane ~ ➜  k drain --ignore-daemonsets node01 --force
    node/node01 already cordoned
    Warning: deleting Pods that declare no controller: default/hr-app; ignoring DaemonSet-managed Pods: kube-flannel/kube-flannel-ds-xbjl9, kube-system/kube-proxy-tcbnn
    evicting pod default/hr-app

    pod/hr-app evicted
    node/node01 drained

    controlplane ~ ➜  k get po -o wide
    NAME                    READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
    blue-6b478c8dbf-ckr7g   1/1     Running   0          13m   10.244.0.5   controlplane   <none>           <none>
    blue-6b478c8dbf-s6wz7   1/1     Running   0          15m   10.244.0.4   controlplane   <none>           <none>
    blue-6b478c8dbf-znjvb   1/1     Running   0          13m   10.244.0.6   controlplane   <none>           <none>
    ```
    
    </details>
    </br>





4. **hr-app** is a critical app and we do not want it to be removed and we do not want to schedule any more pods on node01.

    Mark node01 as unschedulable so that no new pods are scheduled on this node.
    Make sure that hr-app is not affected.

    ```bash
    controlplane ~ ➜  k get po
    NAME                     READY   STATUS    RESTARTS   AGE
    blue-6b478c8dbf-ckr7g    1/1     Running   0          15m
    blue-6b478c8dbf-s6wz7    1/1     Running   0          17m
    blue-6b478c8dbf-znjvb    1/1     Running   0          15m
    hr-app-6d6df76fc-259sn   1/1     Running   0          2m2s 
    ```

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k cordon node01 
    node/node01 cordoned 

    controlplane ~ ➜  k get no
    NAME           STATUS                     ROLES           AGE   VERSION
    controlplane   Ready                      control-plane   33m   v1.27.0
    node01         Ready,SchedulingDisabled   <none>          33m   v1.27.0

    controlplane ~ ➜  k get po -o wide
    NAME                     READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
    blue-6b478c8dbf-ckr7g    1/1     Running   0          15m     10.244.0.5   controlplane   <none>           <none>
    blue-6b478c8dbf-s6wz7    1/1     Running   0          17m     10.244.0.4   controlplane   <none>           <none>
    blue-6b478c8dbf-znjvb    1/1     Running   0          15m     10.244.0.6   controlplane   <none>           <none>
    hr-app-6d6df76fc-259sn   1/1     Running   0          2m21s   10.244.1.5   node01         <none>           <none>
    ```
    
    </details>
    </br>

5. What is the current version of the cluster?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get no -o wide
    NAME           STATUS   ROLES           AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION   CONTAINER-RUNTIME
    controlplane   Ready    control-plane   115m   v1.26.0   192.11.110.3   <none>        Ubuntu 20.04.6 LTS   5.4.0-1106-gcp   containerd://1.6.6
    node01         Ready    <none>          114m   v1.26.0   192.11.110.6   <none>        Ubuntu 20.04.5 LTS   5.4.0-1106-gcp   containerd://1.6.6
    
    ```
    
    </details>
    </br>





6. How many nodes can host workloads in this cluster?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k describe no node01 | grep -i taints
    Taints:             <none>

    controlplane ~ ➜  k describe no controlplane | grep -i taints
    Taints:             <none> 
    ```
    
    </details>
    </br>





7. The clsuter is managed via kubeadm. Check the latest stable version of Kubernetes as of today.

    <details><summary> Answer </summary>

    The latest version is the remote version in the output below.

    ```bash
    controlplane ~ ➜  kubeadm upgrade plan
    [upgrade/config] Making sure the configuration is correct:
    [upgrade/config] Reading configuration from the cluster...
    [upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
    [preflight] Running pre-flight checks.
    [upgrade] Running cluster health checks
    [upgrade] Fetching available versions to upgrade to
    [upgrade/versions] Cluster version: v1.26.0
    [upgrade/versions] kubeadm version: v1.26.0
    I1230 04:35:20.821410   23179 version.go:256] remote version is much newer: v1.29.0; falling back to: stable-1.26
    [upgrade/versions] Target version: v1.26.12
    [upgrade/versions] Latest version in the v1.26 series: v1.26.12 
    ```
    
    </details>
    </br>





8. What is the latest version available for an upgrade with the current version of the kubeadm tool installed?

    <details><summary> Answer </summary>

    The latest version available is the target version.

    ```bash
    controlplane ~ ➜  kubeadm upgrade plan
    [upgrade/config] Making sure the configuration is correct:
    [upgrade/config] Reading configuration from the cluster...
    [upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
    [preflight] Running pre-flight checks.
    [upgrade] Running cluster health checks
    [upgrade] Fetching available versions to upgrade to
    [upgrade/versions] Cluster version: v1.26.0
    [upgrade/versions] kubeadm version: v1.26.0
    I1230 04:35:20.821410   23179 version.go:256] remote version is much newer: v1.29.0; falling back to: stable-1.26
    [upgrade/versions] Target version: v1.26.12
    [upgrade/versions] Latest version in the v1.26 series: v1.26.12 
    ```
    
    </details>
    </br>

9. We will be upgrading the controlplane node first. 

    - Drain the controlplane node of workloads and mark it UnSchedulable

    - Upgrade the controlplane components to exact version v1.27.0

    - Upgrade the kubeadm tool (if not already), then the controlplane components, and finally the kubelet. Practice referring to the Kubernetes documentation page.

    - Note: While upgrading kubelet, if you hit dependency issues while running the apt-get upgrade kubelet command, use the apt install kubelet=1.27.0-00 command instead.

    - Mark the controlplane node as "Schedulable" again

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS                     ROLES           AGE    VERSION
    controlplane   Ready                      control-plane   122m   v1.26.0
    node01         Ready                      <none>          122m   v1.26.0
    ```

    <details><summary> Answer </summary>

    Drain the node first and verify.

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS                     ROLES           AGE    VERSION
    controlplane   Ready                      control-plane   122m   v1.26.0
    node01         Ready                      <none>          122m   v1.26.0

    controlplane ~ ➜  k get po -o wide
    NAME                   READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
    blue-987f68cb5-f2dlb   1/1     Running   0          7m17s   10.244.0.4   controlplane   <none>           <none>
    blue-987f68cb5-hnkgn   1/1     Running   0          7m17s   10.244.0.5   controlplane   <none>           <none>
    blue-987f68cb5-l29zd   1/1     Running   0          7m17s   10.244.1.3   node01         <none>           <none>
    blue-987f68cb5-q6vfg   1/1     Running   0          7m18s   10.244.1.2   node01         <none>           <none>
    blue-987f68cb5-svfwv   1/1     Running   0          7m17s   10.244.1.4   node01         <none>           <none>

    controlplane ~ ➜  k drain --ignore-daemonsets controlplane 
    node/controlplane cordoned
    Warning: ignoring DaemonSet-managed Pods: kube-flannel/kube-flannel-ds-6xt68, kube-system/kube-proxy-8gqnx
    evicting pod kube-system/coredns-787d4945fb-wjwgh
    evicting pod kube-system/coredns-787d4945fb-4xnj2
    evicting pod default/blue-987f68cb5-hnkgn
    evicting pod default/blue-987f68cb5-f2dlb
    pod/blue-987f68cb5-hnkgn evicted
    pod/blue-987f68cb5-f2dlb evicted
    pod/coredns-787d4945fb-wjwgh evicted
    pod/coredns-787d4945fb-4xnj2 evicted
    node/controlplane drained

    controlplane ~ ➜  k get no
    NAME           STATUS                     ROLES           AGE    VERSION
    controlplane   Ready,SchedulingDisabled   control-plane   122m   v1.26.0
    node01         Ready                      <none>          122m   v1.26.0
    ```

    Determine which version to upgrade to.

    ```bash
    apt update
    apt-cache madison kubeadm  
    ```

    Upgrade kubeadm to the specified version. 

    ```bash
    apt-mark unhold kubeadm && \
    apt-get update && apt-get install -y kubeadm='1.27.0*' && \
    apt-mark hold kubeadm  
    ```

    Verify that the download works and has the expected version:

    ```bash
    controlplane ~ ➜  kubeadm version
    kubeadm version: &version.Info{Major:"1", Minor:"27", GitVersion:"v1.27.0", GitCommit:"1b4df30b3cdfeaba6024e81e559a6cd09a089d65", GitTreeState:"clean", BuildDate:"2023-04-11T17:09:06Z", GoVersion:"go1.20.3", Compiler:"gc", Platform:"linux/amd64"} 
    ```

    Verify the upgrade plan:

    ```bash
    controlplane ~ ➜  kubeadm upgrade plan
    [upgrade/config] Making sure the configuration is correct:
    [upgrade/config] Reading configuration from the cluster...
    [upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
    [preflight] Running pre-flight checks.
    [upgrade] Running cluster health checks
    [upgrade] Fetching available versions to upgrade to
    [upgrade/versions] Cluster version: v1.26.0
    [upgrade/versions] kubeadm version: v1.27.0
    I1230 04:46:16.156339   27555 version.go:256] remote version is much newer: v1.29.0; falling back to: stable-1.27
    [upgrade/versions] Target version: v1.27.9
    [upgrade/versions] Latest version in the v1.26 series: v1.26.12
    W1230 04:46:16.419679   27555 compute.go:307] [upgrade/versions] could not find officially supported version of etcd for Kubernetes v1.27.9, falling back to the nearest etcd version (3.5.7-0)  
    ```

    Choose a version to upgrade to, and run the appropriate command. 

    ```bash
    controlplane ~ ➜  sudo kubeadm upgrade apply v1.27.0
    [upgrade/config] Making sure the configuration is correct:
    [upgrade/config] Reading configuration from the cluster...
    [upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
    [preflight] Running pre-flight checks.
    [upgrade] Running cluster health checks
    [upgrade/version] You have chosen to change the cluster version to "v1.27.0"
    [upgrade/versions] Cluster version: v1.26.0
    [upgrade/versions] kubeadm version: v1.27.0
    [upgrade] Are you sure you want to proceed? [y/N]: y  
    ```

    Upgrade the kubelet and kubectl:

    ```bash
    apt-mark unhold kubelet kubectl && \
    apt-get update && apt-get install -y kubelet='1.27.0-00' kubectl='1.27.0-00' && \
    apt-mark hold kubelet kubectl  
    ```

    Restart the kubelet:

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl restart kubelet  
    ```

    Verify version of kubelet.

    ```bash
    controlplane ~ ➜  kubelet --version
    Kubernetes v1.27.0  
    ```

    Verify if controlplane has been upgraded.

    ```bash
    controlplane ~ ➜  k get no -o wide
    NAME           STATUS                     ROLES           AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION   CONTAINER-RUNTIME
    controlplane   Ready,SchedulingDisabled   control-plane   135m   v1.27.0   192.11.110.3   <none>        Ubuntu 20.04.6 LTS   5.4.0-1106-gcp   containerd://1.6.6
    node01         Ready                      <none>          135m   v1.26.0   192.11.110.6   <none>        Ubuntu 20.04.5 LTS   5.4.0-1106-gcp   containerd://1.6.6 
    ```

    Bring the node back online by marking it schedulable:

    ```bash
    controlplane ~ ➜  k uncordon controlplane 
    node/controlplane uncordoned

    controlplane ~ ➜  k get no -o wide
    NAME           STATUS   ROLES           AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION   CONTAINER-RUNTIME
    controlplane   Ready    control-plane   137m   v1.27.0   192.11.110.3   <none>        Ubuntu 20.04.6 LTS   5.4.0-1106-gcp   containerd://1.6.6
    node01         Ready    <none>          136m   v1.26.0   192.11.110.6   <none>        Ubuntu 20.04.5 LTS   5.4.0-1106-gcp   containerd://1.6.6
    ```
    </details>
    </br>


10. Next is the worker node. Drain the worker node of the workloads and mark it UnSchedulable

    - Upgrade the worker node to the exact version v1.27.0


    ```bash
    controlplane ~ ➜  k get no -o wide
    NAME           STATUS   ROLES           AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION   CONTAINER-RUNTIME
    controlplane   Ready    control-plane   138m   v1.27.0   192.11.110.3   <none>        Ubuntu 20.04.6 LTS   5.4.0-1106-gcp   containerd://1.6.6
    node01         Ready    <none>          138m   v1.26.0   192.11.110.6   <none>        Ubuntu 20.04.5 LTS   5.4.0-1106-gcp   containerd://1.6.6 
    ```
        
    <details><summary> Answer </summary>

    Drain the worker node.

    ```bash
    controlplane ~ ➜  k get po -o wide
    NAME                   READY   STATUS    RESTARTS   AGE   IP            NODE     NOMINATED NODE   READINESS GATES
    blue-987f68cb5-hsljs   1/1     Running   0          16m   10.244.1.9    node01   <none>           <none>
    blue-987f68cb5-l29zd   1/1     Running   0          24m   10.244.1.3    node01   <none>           <none>
    blue-987f68cb5-nb49z   1/1     Running   0          16m   10.244.1.10   node01   <none>           <none>
    blue-987f68cb5-q6vfg   1/1     Running   0          24m   10.244.1.2    node01   <none>           <none>
    blue-987f68cb5-svfwv   1/1     Running   0          24m   10.244.1.4    node01   <none>           <none>

    controlplane ~ ➜  k drain --ignore-daemonsets node01 
    node/node01 cordoned
    Warning: ignoring DaemonSet-managed Pods: kube-flannel/kube-flannel-ds-m8ttw, kube-system/kube-proxy-rbjsl
    evicting pod kube-system/coredns-5d78c9869d-qtqfh
    evicting pod default/blue-987f68cb5-nb49z
    evicting pod default/blue-987f68cb5-svfwv
    evicting pod kube-system/coredns-5d78c9869d-q9ddk
    evicting pod default/blue-987f68cb5-q6vfg
    evicting pod default/blue-987f68cb5-hsljs
    evicting pod default/blue-987f68cb5-l29zd
    pod/blue-987f68cb5-q6vfg evicted
    pod/blue-987f68cb5-l29zd evicted
    pod/blue-987f68cb5-hsljs evicted
    pod/blue-987f68cb5-nb49z evicted
    pod/blue-987f68cb5-svfwv evicted
    I1230 04:55:53.254668   34934 request.go:696] Waited for 1.104208704s due to client-side throttling, not priority and fairness, request: GET:https://controlplane:6443/api/v1/namespaces/kube-system/pods/coredns-5d78c9869d-qtqfh
    pod/coredns-5d78c9869d-q9ddk evicted
    pod/coredns-5d78c9869d-qtqfh evicted
    node/node01 drained

    controlplane ~ ➜  k get no -o wide
    NAME           STATUS                     ROLES           AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION   CONTAINER-RUNTIME
    controlplane   Ready                      control-plane   139m   v1.27.0   192.11.110.3   <none>        Ubuntu 20.04.6 LTS   5.4.0-1106-gcp   containerd://1.6.6
    node01         Ready,SchedulingDisabled   <none>          139m   v1.26.0   192.11.110.6   <none>        Ubuntu 20.04.5 LTS   5.4.0-1106-gcp   containerd://1.6.6

    controlplane ~ ➜  k get po -o wide
    NAME                   READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
    blue-987f68cb5-2xpgf   1/1     Running   0          42s   10.244.0.8    controlplane   <none>           <none>
    blue-987f68cb5-42jnx   1/1     Running   0          42s   10.244.0.10   controlplane   <none>           <none>
    blue-987f68cb5-bwj8l   1/1     Running   0          42s   10.244.0.11   controlplane   <none>           <none>
    blue-987f68cb5-hfk4c   1/1     Running   0          42s   10.244.0.7    controlplane   <none>           <none>
    blue-987f68cb5-rv66x   1/1     Running   0          42s   10.244.0.12   controlplane   <none>           <none> 
    ```

    SSH to the worker node.

    ```bash
    controlplane ~ ➜  ssh node01  
    ```

    Upgrade the worker node to the exact version v1.27.0

    ```bash
    root@node01 ~ ➜  apt-mark unhold kubeadm && \
    > apt-get update && apt-get install -y kubeadm='1.27.0-00' && \
    > apt-mark hold kubeadm 
    ```

    For worker nodes this upgrades the local kubelet configuration:

    ```bash
    root@node01 ~ ➜  sudo kubeadm upgrade node 
    [upgrade] Reading configuration from the cluster...
    [upgrade] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
    [preflight] Running pre-flight checks
    [preflight] Skipping prepull. Not a control plane node.
    [upgrade] Skipping phase. Not a control plane node.
    [upgrade] Backing up kubelet config file to /etc/kubernetes/tmp/kubeadm-kubelet-config3810710231/config.yaml
    [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
    [upgrade] The configuration for this node was successfully updated!
    [upgrade] Now you should go ahead and upgrade the kubelet package using your package manager.
    ```

    Upgrade the kubelet and kubectl:

    ```bash
    apt-mark unhold kubelet kubectl && \
    apt-get update && apt-get install -y kubelet='1.27.0-00' kubectl='1.27.0-00' && \
    apt-mark hold kubelet kubectl 
    ```

    Restart the kubelet:

    ```bash
    sudo systemctl daemon-reload
    sudo systemctl restart kubelet 
    ```

    Verify kubelet version:

    ```bash
    root@node01 ~ ✖ kubelet --version
    Kubernetes v1.27.0 
    ```

    Return to the controlplane and verify if node is upgraded successfully.

    ```bash
    controlplane ~ ➜  k get no -o wide
    NAME           STATUS                     ROLES           AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION   CONTAINER-RUNTIME
    controlplane   Ready                      control-plane   149m   v1.27.0   192.11.110.3   <none>        Ubuntu 20.04.6 LTS   5.4.0-1106-gcp   containerd://1.6.6
    node01         Ready,SchedulingDisabled   <none>          148m   v1.27.0   192.11.110.6   <none>        Ubuntu 20.04.5 LTS   5.4.0-1106-gcp   containerd://1.6.6 
    ```

    Uncordon the node:

    ```bash
    controlplane ~ ➜  k uncordon node01 
    node/node01 uncordoned

    controlplane ~ ➜  k get no -o wide
    NAME           STATUS   ROLES           AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION   CONTAINER-RUNTIME
    controlplane   Ready    control-plane   149m   v1.27.0   192.11.110.3   <none>        Ubuntu 20.04.6 LTS   5.4.0-1106-gcp   containerd://1.6.6
    node01         Ready    <none>          149m   v1.27.0   192.11.110.6   <none>        Ubuntu 20.04.5 LTS   5.4.0-1106-gcp   containerd://1.6.6 
    ```

    </details>
    </br>





11. What is the version of ETCD running on the cluster?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po -A | grep etc
    kube-system    etcd-controlplane                      1/1     Running   0          5m10s

    controlplane ~ ➜  k logs -n kube-system etcd-controlplane | grep -i version
    {"level":"info","ts":"2023-12-30T10:04:34.410Z","caller":"embed/etcd.go:306","msg":"starting an etcd server","etcd-version":"3.5.7", 
    ```
    
    </details>
    </br>





12. At what address can you reach the ETCD cluster from the controlplane node?

    <details><summary> Answer </summary>

    Describe the etcd pod and look for the listen-client-url.

    ```bash
    controlplane ~ ➜  k get po -n kube-system | grep etc
    etcd-controlplane                      1/1     Running   0          9m41s

    controlplane ~ ✖ k describe -n kube-system po etcd-controlplane | grep -i listen-client
        --listen-client-urls=https://127.0.0.1:2379,https://192.14.168.6:2379 
    ```
    
    </details>
    </br>





    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po -n kube-system | grep etc
    etcd-controlplane                      1/1     Running   0          9m41s

    controlplane ~ ➜  k describe -n kube-system po etcd-controlplane | grep -iCERT
    grep: ERT: invalid context length argument

    controlplane ~ ✖ k describe -n kube-system po etcd-controlplane | grep -i cert
        --cert-file=/etc/kubernetes/pki/etcd/server.crt
    ```
    
    </details>
    </br>





13. Where is the ETCD CA Certificate file located?

    <details><summary> Answer </summary>
    
    ```bash
    controlplane ~ ➜  k get po -n kube-system | grep etc
    etcd-controlplane                      1/1     Running   0          9m41s

    controlplane ~ ➜  k describe -n kube-system po etcd-controlplane | grep -i ca
    Priority Class Name:  system-node-critical
        --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
        --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
    ```
    
    </details>
    </br>


14. The master node in our cluster is planned for a regular maintenance reboot tonight. While we do not anticipate anything to go wrong, we are required to take the necessary backups. Take a snapshot of the ETCD database using the built-in snapshot functionality.

    Store the backup file at location /opt/snapshot-pre-boot.db

    <details><summary> Answer </summary>

    The command is from K8S docs: 

    ```bash
    ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
    --cacert=<trusted-ca-file> --cert=<cert-file> --key=<key-file> \
    snapshot save <backup-file-location> 
    ```

    Get the ca-cert, cert, and the key file.

    ```bash
    controlplane ~ ➜  k get po -n kube-system | grep etc
    etcd-controlplane                      1/1     Running   0          18m

    controlplane ~ ➜  k describe -n kube-system po etcd-controlplane | grep -i cert
        --cert-file=/etc/kubernetes/pki/etcd/server.crt
        --client-cert-auth=true
        --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt
        --peer-client-cert-auth=true
        /etc/kubernetes/pki/etcd from etcd-certs (rw)
    etcd-certs:

    controlplane ~ ➜  k describe -n kube-system po etcd-controlplane | grep -i ca
    Priority Class Name:  system-node-critical
        --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
        --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt

    controlplane ~ ➜  k describe -n kube-system po etcd-controlplane | grep -i key
        --key-file=/etc/kubernetes/pki/etcd/server.key
        --peer-key-file=/etc/kubernetes/pki/etcd/peer.key 
    ```

    Supply the values to the command and run it.

    ```bash
    ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
    snapshot save /opt/snapshot-pre-boot.db
    ```

    ```bash
    controlplane ~ ➜  ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
    >   --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
    >   snapshot save /opt/snapshot-pre-boot.db

    Snapshot saved at /opt/snapshot-pre-boot.db 

    controlplane ~ ✖ ls -l /opt/
    total 2012
    drwxr-xr-x 1 root root    4096 Nov  2 11:33 cni
    drwx--x--x 4 root root    4096 Nov  2 11:33 containerd
    -rw-r--r-- 1 root root 2043936 Dec 30 05:25 snapshot-pre-boot.db
    ```
    </details>
    </br>


15. Restore the original state of the cluster using the backup file /opt/snapshot-pre-boot.db

    <details><summary> Answer </summary>

    The command from the K8S docs:

    ```bash
    ETCDCTL_API=3 etcdctl --data-dir <data-dir-location> snapshot restore snapshot.db 
    ```

    Find the data-dir from the pod's details:

    ```bash
    controlplane ~ ➜  k describe -n kube-system po etcd-controlplane | grep -i data
        --data-dir=/var/lib/etcd
        /var/lib/etcd from etcd-data (rw)
    etcd-data:  
    ```

    Specify a new data-dir for the restored etcd.
    Run the command with the supplied values. 

    ```bash
    ETCDCTL_API=3 etcdctl  --data-dir /var/lib/etcd-from-backup snapshot restore /opt/snapshot-pre-boot.db
    ```
    ```bash
    controlplane ~ ✖ ETCDCTL_API=3 etcdctl  --data-dir /var/lib/etcd-from-backup \
    > snapshot restore /opt/snapshot-pre-boot.db
    2023-12-30 05:33:31.725882 I | mvcc: restore compact to 1666
    2023-12-30 05:33:31.731201 I | etcdserver/membership: added member 8e9e05c52164694d [http://localhost:2380] to cluster cdf818194e3a8c32  
    ```

    Since we changed the data-dir, we need to update the etcd YAMl file.

    ```bash
    controlplane ~ ➜  ls -la /etc/kubernetes/manifests/
    total 28
    drwxr-xr-x 1 root root 4096 Dec 30 05:04 .
    drwxr-xr-x 1 root root 4096 Dec 30 05:04 ..
    -rw------- 1 root root 2405 Dec 30 05:04 etcd.yaml
    -rw------- 1 root root 3882 Dec 30 05:04 kube-apiserver.yaml
    -rw------- 1 root root 3393 Dec 30 05:04 kube-controller-manager.yaml
    -rw------- 1 root root 1463 Dec 30 05:04 kube-scheduler.yaml  

    controlplane ~ ➜  cd /etc/kubernetes/manifests/
    ```
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
    annotations:
        kubeadm.kubernetes.io/etcd.advertise-client-urls: https://192.14.168.6:2379
    creationTimestamp: null
    labels:
        component: etcd
        tier: control-plane
    name: etcd
    namespace: kube-system
    spec:
    containers:
    - command:
        - etcd
        - --advertise-client-urls=https://192.14.168.6:2379
        - --cert-file=/etc/kubernetes/pki/etcd/server.crt
        - --client-cert-auth=true
        - --data-dir=/var/lib/etcd-from-backup 

        volumeMounts:
        - mountPath: /var/lib/etcd-from-backup
        name: etcd-data
    
    volumes:
    - hostPath:
        path: /var/lib/etcd-from-backup
        type: DirectoryOrCreate
        name: etcd-data      
    ```

    To verify, check member list:

    ```bash
    ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key member list 
    ```
    ```bash
    ontrolplane ~ ➜ ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key member list 

    8e9e05c52164694d, started, controlplane, http://localhost:2380, https://192.14.168.6:2379  
    ```

    </details>
    </br>


16. How many clusters are defined in the kubeconfig on the student-node?

    ```bash
    student-node ~ ➜   
    ```

    <details><summary> Answer </summary>
    
    ```bash
    student-node ~ ➜  k config get-contexts
    CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
    *         cluster1   cluster1   cluster1   
            cluster2   cluster2   cluster2    
    ```
    
    </details>
    </br>


17. How many nodes (both controlplane and worker) are part of cluster1?

    <details><summary> Answer </summary>
    
    ```bash
    student-node ~ ➜  k get no
    NAME                    STATUS   ROLES           AGE    VERSION
    cluster1-controlplane   Ready    control-plane   121m   v1.24.0
    cluster1-node01         Ready    <none>          121m   v1.24.0
    ```
    
    </details>
    </br>


18. Switch to cluster2 and check how many nodes.

    <details><summary> Answer </summary>
    
    ```bash
    student-node ~ ➜  k config use-context cluster2
    Switched to context "cluster2".

    student-node ~ ➜  k config get-contexts
    CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
            cluster1   cluster1   cluster1   
    *         cluster2   cluster2   cluster2   

    student-node ~ ➜  k get no
    NAME                    STATUS   ROLES           AGE    VERSION
    cluster2-controlplane   Ready    control-plane   124m   v1.24.0
    cluster2-node01         Ready    <none>          123m   v1.24.0 
    ```
    
    </details>
    </br>

19. How is ETCD configured for cluster1?

    <details><summary> Answer </summary>
    
    ```bash
    student-node ~ ➜  k config use-context cluster1
    Switched to context "cluster1".

    student-node ~ ➜  k config get-contexts
    CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
    *         cluster1   cluster1   cluster1   
            cluster2   cluster2   cluster2   

    student-node ~ ➜  k get po -n kube-system | grep etc
    etcd-cluster1-controlplane                      1/1     Running   0              125m 
    ```

    This means that ETCD is set up as a Stacked ETCD Topology where the distributed data storage cluster provided by etcd is stacked on top of the cluster formed by the nodes managed by kubeadm that run control plane components.
    
    </details>
    </br>

20. Check for the etcd of cluster2. You are currently connected to cluster1.

    <details><summary> Answer </summary>
    
    ```bash
    student-node ~ ➜  k config use-context cluster2
    Switched to context "cluster2".

    student-node ~ ➜  k config get-contexts
    CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
            cluster1   cluster1   cluster1   
    *         cluster2   cluster2   cluster2   

    student-node ~ ➜  k get po -n kube-system | grep etc

    ```

    SSH to controlplane of cluster2 and check if there are any running etcd process.

    ```bash
    student-node ~ ➜  k get no
    NAME                    STATUS   ROLES           AGE    VERSION
    cluster2-controlplane   Ready    control-plane   129m   v1.24.0
    cluster2-node01         Ready    <none>          128m   v1.24.0

    student-node ~ ➜  ssh cluster2-controlplane
    Welcome to Ubuntu 18.04.6 LTS (GNU/Linux 5.4.0-1106-gcp x86_64)

    * Documentation:  https://help.ubuntu.com
    * Management:     https://landscape.canonical.com
    * Support:        https://ubuntu.com/advantage
    This system has been minimized by removing packages and content that are
    not required on a system that users do not log into.

    To restore this content, you can run the 'unminimize' command.

    cluster2-controlplane ~ ➜  ps -aux | grep etcd
    root        1733  0.0  0.1 1181432 363048 ?      Ssl  08:55   6:47 kube-apiserver --advertise-address=192.12.99.21  
    ```

    From here we can see that the process for the kube-apiserver is referencing an external etcd datastore.

    </details>
    </br>

21. Take a backup of etcd on cluster1 and save it on the student-node at the path /opt/cluster1.db

    <details><summary> Answer </summary>
    
    ```bash
    student-node ~ ✖ k config get-contexts
    CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
    *         cluster1   cluster1   cluster1   
            cluster2   cluster2   cluster2   
    ```

    Follow steps in K8S doc to backup etcd.

    ```bash
    ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
    --cacert=<trusted-ca-file> --cert=<cert-file> --key=<key-file> \
    snapshot save <backup-file-location>
    ```

    Get the ca-cert, cert, and key first and supply it to the command.

    ```bash
    student-node ~ ➜  k describe -n kube-system po etcd-cluster1-controlplane | grep cert
        --cert-file=/etc/kubernetes/pki/etcd/server.crt
        --client-cert-auth=true
        --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt
        --peer-client-cert-auth=true
        /etc/kubernetes/pki/etcd from etcd-certs (rw)
    etcd-certs:

    student-node ~ ➜  k describe -n kube-system po etcd-cluster1-controlplane | grep ca
    Priority Class Name:  system-node-critical
        --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
        --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt

    student-node ~ ➜  k describe -n kube-system po etcd-cluster1-controlplane | grep key
        --key-file=/etc/kubernetes/pki/etcd/server.key
        --peer-key-file=/etc/kubernetes/pki/etcd/peer.key  
    ```
    ```bash
    ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
    snapshot save /opt/cluster1.db 
    ```

    Then SSH to controlplane of cluster1 and run the command. 

    ```bash
    student-node ~ ➜  k get no
    NAME                    STATUS   ROLES           AGE    VERSION
    cluster1-controlplane   Ready    control-plane   145m   v1.24.0
    cluster1-node01         Ready    <none>          144m   v1.24.0

    student-node ~ ➜  ssh cluster1-controlplane
    Welcome to Ubuntu 18.04.6 LTS (GNU/Linux 5.4.0-1106-gcp x86_64)

    * Documentation:  https://help.ubuntu.com
    * Management:     https://landscape.canonical.com
    * Support:        https://ubuntu.com/advantage
    This system has been minimized by removing packages and content that are
    not required on a system that users do not log into.

    To restore this content, you can run the 'unminimize' command.

    cluster1-controlplane ~ ➜  ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
    >   --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
    >   snapshot save /opt/cluster1.db 
    Snapshot saved at /opt/cluster1.db  

    cluster1-controlplane ~ ➜  ls -l /opt
    total 2096
    -rw-r--r-- 1 root root 2129952 Dec 30 11:21 cluster1.db
    ```

    Finally, copy the backup back to the jumphost. 
    To do this, return to jumphost and use scp to grab the file from the cluster1's controlplane.

    ```bash
    cluster1-controlplane ~ ✖ exit
    logout
    Connection to cluster1-controlplane closed.

    student-node ~ ✖ 

    student-node ~ ✖ scp cluster1-controlplane:/opt/cluster1.db /opt
    cluster1.db                                                                                                              100% 2080KB 141.9MB/s   00:00    

    student-node ~ ➜  ls -l /opt
    total 2084
    -rw-r--r-- 1 root root 2129952 Dec 30 11:25 cluster1.db  
    ```
    
    </details>
    </br>

22. An ETCD backup for cluster2 is stored at /opt/cluster2.db. Use this snapshot file to carryout a restore on cluster2 to a new path /var/lib/etcd-data-new.

    - Once the restore is complete, ensure that the controlplane components on cluster2 are running.

    - The snapshot was taken when there were objects created in the critical namespace on cluster2. These objects should be available post restore.


    <details><summary> Answer </summary>

    First, copy the backup file to the etcd-server.

    ```bash
    student-node ~ ➜  ls -l /opt/
    total 4096
    -rw-r--r-- 1 root root 2129952 Dec 30 11:25 cluster1.db
    -rw-r--r-- 1 root root       0 Dec 30 11:20 cluster1.db.part
    -rw------- 1 root root 2056224 Dec 30 11:26 cluster2.db

    student-node ~ ➜  scp /opt/cluster2.db etcd-server:/root
    cluster2.db                                                                                                              100% 2008KB 109.6MB/s   00:00    

    student-node ~ ➜  ssh etcd-server
    Welcome to Ubuntu 18.04.6 LTS (GNU/Linux 5.4.0-1106-gcp x86_64)

    * Documentation:  https://help.ubuntu.com
    * Management:     https://landscape.canonical.com
    * Support:        https://ubuntu.com/advantage
    This system has been minimized by removing packages and content that are
    not required on a system that users do not log into.

    To restore this content, you can run the 'unminimize' command.

    etcd-server ~ ➜  ls -l
    total 2012
    -rw------- 1 root root 2056224 Dec 30 11:32 cluster2.db 
    ```

    In the etcd-server, perform the restore. Follow K8S docs.
    
    ```bash
    ETCDCTL_API=3 etcdctl --data-dir /var/lib/etcd-data-new snapshot restore /root/cluster2.db 
    ```
    
    ```bash
    etcd-server ~ ➜  ETCDCTL_API=3 etcdctl --data-dir /var/lib/etcd-data-new snapshot restore /root/cluster2.db 
    {"level":"info","ts":1703936127.6477966,"caller":"snapshot/v3_snapshot.go:296","msg":"restoring snapshot","path":"/root/cluster2.db","wal-dir":"/var/lib/etcd-data-new/member/wal","data-dir":"/var/lib/etcd-data-new","snap-dir":"/var/lib/etcd-data-new/member/snap"}
    {"level":"info","ts":1703936127.662703,"caller":"mvcc/kvstore.go:388","msg":"restored last compact revision","meta-bucket-name":"meta","meta-bucket-name-key":"finishedCompactRev","restored-compact-revision":11832}
    {"level":"info","ts":1703936127.6675162,"caller":"membership/cluster.go:392","msg":"added member","cluster-id":"cdf818194e3a8c32","local-member-id":"0","added-peer-id":"8e9e05c52164694d","added-peer-peer-urls":["http://localhost:2380"]}
    {"level":"info","ts":1703936127.6817799,"caller":"snapshot/v3_snapshot.go:309","msg":"restored snapshot","path":"/root/cluster2.db","wal-dir":"/var/lib/etcd-data-new/member/wal","data-dir":"/var/lib/etcd-data-new","snap-dir":"/var/lib/etcd-data-new/member/snap"} 
    ```

    Since this is an external etcd server, we need to update the unit file of the etcd service.
    
    ```bash
    etcd-server ~ ➜  sudo systemctl status etcd
    ● etcd.service - etcd key-value store
    Loaded: loaded (/etc/systemd/system/etcd.service; enabled; vendor preset: enabled)
    Active: active (running) since Sat 2023-12-30 08:55:28 UTC; 2h 44min ago
        Docs: https://github.com/etcd-io/etcd
    Main PID: 798 (etcd)
        Tasks: 41 (limit: 251379)
    CGroup: /system.slice/etcd.service
            └─798 /usr/local/bin/etcd --name etcd-server --data-dir=/var/lib/etcd-data --cert-file=/etc/etcd/pki/etcd.pem --key-file=/etc/etcd/pki/etcd-key.
    pem --peer-cert-file=/etc/etcd/pki/etcd.pem --peer-key-file=/etc/etcd/pki/etcd-key.pem --trusted-ca-file=/etc/etcd/pki/ca.pem --peer-trusted-ca-file=/etc/e
    tcd/pki/ca.pem --peer-client-cert-auth --client-cert-auth --initial-advertise-peer-urls https://192.12.99.9:2380 --listen-peer-urls https://192.12.99.9:238
    0 --advertise-client-urls https://192.12.99.9:2379 --listen-client-urls https://192.12.99.9:2379,https://127.0.0.1:2379 --initial-cluster-token etcd-cluste
    r-1 --initial-cluster etcd-server=https://192.12.99.9:2380 --initial-cluster-state new
    ```

    The service file is at /etc/systemd/system/etcd.service.

    ```bash
    [Unit]
    Description=etcd key-value store
    Documentation=https://github.com/etcd-io/etcd
    After=network.target

    [Service]
    User=etcd
    Type=notify
    ExecStart=/usr/local/bin/etcd \
    --name etcd-server \
    --data-dir=/var/lib/etcd-data-new \ 
    ```

    When we try to restart the etcd service, it will fail. This is because thenew directory doesn't have the correct permissions. Set the permissions. 

    ```bash
    etcd-server ~ ✖ chown -R etcd:etcd /var/lib/etcd-data-new/

    etcd-server ~ ➜  ls -la /var/lib/etcd-data-new/
    total 16
    drwx------ 3 etcd etcd 4096 Dec 30 11:48 .
    drwxr-xr-x 1 root root 4096 Dec 30 11:35 ..
    drwx------ 4 etcd etcd 4096 Dec 30 11:48 member
    ```

    Restart and verify. 

    ```bash
    etcd-server ~ ➜  sudo systemctl restart etcd

    etcd-server ~ ➜  sudo systemctl status etcd
    ● etcd.service - etcd key-value store
    Loaded: loaded (/etc/systemd/system/etcd.service; enabled; vendor preset: enabled)
    Active: active (running) since Sat 2023-12-30 11:48:51 UTC; 4s ago
        Docs: https://github.com/etcd-io/etcd
    Main PID: 3327 (etcd)
        Tasks: 50 (limit: 251379)
    CGroup: /system.slice/etcd.service
            └─3327 /usr/local/bin/etcd --name etcd-server --data-dir=/var/lib/etcd-data-new --cert-file=/etc/etcd/pki/etcd.pem --key-file=/etc/etcd/pki/etcd
    -key.pem --peer-cert-file=/etc/etcd/pki/etcd.pem --peer-key-file=/etc/etcd/pki/etcd-key.pem --trusted-ca-file=/etc/etcd/pki/ca.pem --peer-trusted-ca-file=/
    etc/etcd/pki/ca.pem --peer-client-cert-auth --client-cert-auth --initial-advertise-peer-urls https://192.12.99.9:2380 --listen-peer-urls https://192.12.99.
    9:2380 --advertise-client-urls https://192.12.99.9:2379 --listen-client-urls https://192.12.99.9:2379,https://127.0.0.1:2379 --initial-cluster-token etcd-c
    luster-1 --initial-cluster etcd-server=https://192.12.99.9:2380 --initial-cluster-state new
    ```

    To verify if the restore is successful, check the member list.

    ```bash
    etcd-server ~ ➜  ETCDCTL_API=3 etcdctl --endpoints 127.0.0.1:2379 \
    >   --cert=/etc/etcd/pki/etcd.pem \
    >   --key=/etc/etcd/pki/etcd-key.pem \
    >   --cacert=/etc/etcd/pki/ca.pem \
    >   member list

    8e9e05c52164694d, started, etcd-server, http://localhost:2380, https://192.12.99.9:2379, false
    ```
    
    </details>
    </br>





[Back to the top](#practice-test-cka)    
