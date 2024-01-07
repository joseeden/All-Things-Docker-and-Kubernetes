
# Enabling API versions 

> *This is a practice scenario which I encountered during the CKA and CKAD Exams study.* 

Enable the v1alpha1 version for rbac.authorization.k8s.io API group on the controlplane node.

Note: If you made a mistake in the config file could result in the API server being unavailable and can break the cluster.


```bash
controlplane ~ ➜  k api-resources | grep authorization.k8s.io
localsubjectaccessreviews                      authorization.k8s.io/v1                true         LocalSubjectAccessReview
selfsubjectaccessreviews                       authorization.k8s.io/v1                false        SelfSubjectAccessReview
selfsubjectrulesreviews                        authorization.k8s.io/v1                false        SelfSubjectRulesReview
subjectaccessreviews                           authorization.k8s.io/v1                false        SubjectAccessReview
clusterrolebindings                            rbac.authorization.k8s.io/v1           false        ClusterRoleBinding
clusterroles                                   rbac.authorization.k8s.io/v1           false        ClusterRole
rolebindings                                   rbac.authorization.k8s.io/v1           true         RoleBinding
roles                                          rbac.authorization.k8s.io/v1           true         Role 
```

**Solution:**

As a good practice, take a backup of that apiserver manifest file before going to make any changes.

In case, if anything happens due to misconfiguration you can replace it with the backup file.

```bash
controlplane ~ ➜  ls -l /etc/kubernetes/manifests/
total 16
-rw------- 1 root root 2399 Jan  6 00:36 etcd.yaml
-rw------- 1 root root 3877 Jan  6 00:36 kube-apiserver.yaml
-rw------- 1 root root 3393 Jan  6 00:36 kube-controller-manager.yaml
-rw------- 1 root root 1463 Jan  6 00:36 kube-scheduler.yaml

controlplane ~ ➜  cd /etc/kubernetes/manifests/

controlplane /etc/kubernetes/manifests ➜  cp kube-apiserver.yaml kube-apiserver.yaml.bak

controlplane /etc/kubernetes/manifests ➜  ls -l
total 20
-rw------- 1 root root 2399 Jan  6 00:36 etcd.yaml
-rw------- 1 root root 3877 Jan  6 00:36 kube-apiserver.yaml
-rw------- 1 root root 3877 Jan  6 01:07 kube-apiserver.yaml.bak
-rw------- 1 root root 3393 Jan  6 00:36 kube-controller-manager.yaml
-rw------- 1 root root 1463 Jan  6 00:36 kube-scheduler.yaml 
```

Modify the kube-apiserver.yaml.
Add the --runtime-config flag in the command field as follows :

```bash
apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubeadm.kubernetes.io/kube-apiserver.advertise-address.endpoint: 192.8.142.6:6443
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
    - --advertise-address=192.8.142.6
    - --allow-privileged=true
    - --authorization-mode=Node,RBAC
    - --client-ca-file=/etc/kubernetes/pki/ca.crt
    - --enable-admission-plugins=NodeRestriction
    - --enable-bootstrap-token-auth=true
    - --runtime-config=rbac.authorization.k8s.io/v1alpha1
```

After that kubelet will detect the new changes and will recreate the apiserver pod. It may take some time.

Check the status of the apiserver pod. It should be in running condition.

```bash
controlplane /etc/kubernetes/manifests ➜  kubectl get po -n kube-system
NAME                                   READY   STATUS    RESTARTS      AGE
coredns-5d78c9869d-s664z               1/1     Running   0             33m
coredns-5d78c9869d-xvhgl               1/1     Running   0             33m
etcd-controlplane                      1/1     Running   0             33m
kube-apiserver-controlplane            1/1     Running   0             109s
kube-controller-manager-controlplane   1/1     Running   2 (40s ago)   33m
kube-proxy-p24r9                       1/1     Running   0             33m
kube-scheduler-controlplane            1/1     Running   2 (41s ago)   33m 
```



<br>

[Back to first page](../../README.md#kubernetes)
