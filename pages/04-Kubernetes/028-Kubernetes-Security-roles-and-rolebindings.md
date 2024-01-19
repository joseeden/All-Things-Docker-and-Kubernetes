
# Role-Based Access Control

- [Roles](#roles)
- [Rolebindings](#rolebindings)
- [Cluster](#cluster)
- [Verify access](#can-i)
  - [Can I?](#can-i)
  - [Check access of another user](#check-access-of-another-user)
- [Cluster Admin Rolebinding](#cluster-admin-rolebinding)
- [Cluster Admin Role](#cluster-admin-role)
- [Resources](#resources)

## Role-Based Access Control

**Role-based access control** (RBAC) is a common way to control access to Kubernetes resources using roles. 

- RBAC can be dynamically configured using the Kubernetes API 
- Does not require modifying files compared to other user access control modules.
- Authorization, including RBAC, applies to both normal users and service accounts. 

You can also use RBAC on groups to simplify access control management. 

## Roles 

To create a role:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]  
```

In the role manifest above, we can see that the rules have three sections:

- apiGroups - normally left blank for core group 
- resources - objects that the role can access 
- verbs - actions that the role can perform

To allow developers to create ConfigMaps, we can also add it as a rule.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
rules:

- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]  

- apiGroups: [""] # "" indicates the core API group
  resources: ["ConfigMap"]
  verbs: ["create"]  
```

Make sure to run the YAML file for the role to be created.

```bash
kubectl apply -f my-role.yml 
```

**Make the role more granular**

To make the access more granular, we can specify the specific object in the role. As an example, instead of allowing access to all pods, we can just restrict the access to specific pods.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
rules:

- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]  
  resourceNames: ["podA", "podB"]
```


## Rolebindings

Once the role is created, the next step is to link the user to the role. Roles can be bound to subjects within a:

- specific namespace (role binding), or
- cluster-wide (cluster role binding). 

It is a best practice to authorize access to the minimal amount of resources required by any subject, following the principle of least privilege. If a subject only needs access to a subset of namespaces, they should not be bound to a role using a cluster role binding.

To create a rolebinding, create the necessary YAML file. Make sure to run **kubectl apply**.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
# This role binding allows "jane" to read pods in the "default" namespace.
# You need to already have a Role named "pod-reader" in that namespace.
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
# You can specify more than one "subject"
- kind: User
  name: jane # "name" is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  # "roleRef" specifies the binding to a Role / ClusterRole
  kind: Role #this must be Role or ClusterRole
  name: pod-reader # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io 
```

To list the roles:

```bash
kubectl get roles  
```

To get more details on a specific role:

```bash
kubectl describe role my-role 
```

## Cluster 

To list all of the role bindings in the cluster:

```bash
$ kubectl get rolebinding --all-namespaces

NAMESPACE              NAME                                                ROLE                                                  AGE
kube-public            kubeadm:bootstrap-signer-clusterinfo                Role/kubeadm:bootstrap-signer-clusterinfo             151d
kube-public            system:controller:bootstrap-signer                  Role/system:controller:bootstrap-signer               151d
kube-system            kube-proxy                                          Role/kube-proxy                                       151d
kube-system            kubeadm:kubelet-config                              Role/kubeadm:kubelet-config                           151d
kube-system            kubeadm:nodes-kubeadm-config                        Role/kubeadm:nodes-kubeadm-config                     151d
kube-system            metrics-server-auth-reader                          Role/extension-apiserver-authentication-reader        151d
kube-system            system::extension-apiserver-authentication-reader   Role/extension-apiserver-authentication-reader        151d
kube-system            system::leader-locking-kube-controller-manager      Role/system::leader-locking-kube-controller-manager   151d
kube-system            system::leader-locking-kube-scheduler               Role/system::leader-locking-kube-scheduler            151d
kube-system            system:controller:bootstrap-signer                  Role/system:controller:bootstrap-signer               151d
kube-system            system:controller:cloud-provider                    Role/system:controller:cloud-provider                 151d
kube-system            system:controller:token-cleaner                     Role/system:controller:token-cleaner                  151d
kubernetes-dashboard   kubernetes-dashboard                                Role/kubernetes-dashboard                             151d
```

There are several role bindings created as part of cluster initialization. Notice that role bindings are always associated with a specific NAMESPACE and do not grant any access outside of the specified namespace. Also, note that the **system: prefix** is reserved for Kubernetes system use and should not be used when you create names.

To list all of the role bindings in the cluster:

```bash
$ kubectl get clusterrolebinding
NAME                                                   ROLE                                                                               AGE
admin-cluster-binding                                  ClusterRole/cluster-admin                                                          151d
calico-kube-controllers                                ClusterRole/calico-kube-controllers                                                151d
calico-node                                            ClusterRole/calico-node                                                            151d
cluster-admin                                          ClusterRole/cluster-admin                                                          151d
ebs-csi-attacher-binding                               ClusterRole/ebs-external-attacher-role                                             130d
ebs-csi-node-getter-binding                            ClusterRole/ebs-csi-node-role                                                      130d
ebs-csi-provisioner-binding                            ClusterRole/ebs-external-provisioner-role                                          130d
ebs-csi-resizer-binding                                ClusterRole/ebs-external-resizer-role                                              130d
ebs-csi-snapshotter-binding                            ClusterRole/ebs-external-snapshotter-role                                          130d
kubeadm:get-nodes                                      ClusterRole/kubeadm:get-nodes                                                      151d
kubeadm:kubelet-bootstrap                              ClusterRole/system:node-bootstrapper                                               151d
kubeadm:node-autoapprove-bootstrap                     ClusterRole/system:certificates.k8s.io:certificatesigningrequests:nodeclient       151d
kubeadm:node-autoapprove-certificate-rotation          ClusterRole/system:certificates.k8s.io:certificatesigningrequests:selfnodeclient   151d
kubeadm:node-proxier                                   ClusterRole/system:node-proxier                                                    151d
kubernetes-dashboard                                   ClusterRole/kubernetes-dashboard                                                   151d
metrics-server:system:auth-delegator                   ClusterRole/system:auth-delegator                                                  151d
system:basic-user                                      ClusterRole/system:basic-user                                                      151d
system:controller:attachdetach-controller              ClusterRole/system:controller:attachdetach-controller                              151d
system:controller:certificate-controller               ClusterRole/system:controller:certificate-controller                               151d
system:controller:clusterrole-aggregation-controller   ClusterRole/system:controller:clusterrole-aggregation-controller                   151d
system:controller:cronjob-controller                   ClusterRole/system:controller:cronjob-controller                                   151d
 ....

 (output shortened)                                            
```

Notice there are many **system:** bindings for each of the various controllers and components in the cluster. The controllers can be used with resources in any namespace, so it makes sense that they are cluster-wide role bindings. There are also a few cluster role bindings that are not prefixed with system:. For example, the **cluster-admin** binding is what gives the admin user in your current kubectl context access to all the resources in the cluster.

## Can I? 

As a user, we can also see if we have access to a resource by running:

```bash
kubectl auth can-i <action> <resource>
```

As an example, to check if I can created pods:

```bash
kubectl auth can-i delete pods  
```

## Check access of another user 

If you are an administrator, you can also check if user has permissions on the object:

```bash
kubectl auth can-i <action> <object> --as <user>
```

As an example, to check if user Dave can create pods on the "dev" namespace:

```bash
kubectl auth can-i create pods --as dave --namespace dev
```

## Cluster Admin Rolebinding

We can check the **cluster-admin** cluster role-binding by generating the YAML file.

```bash
$ kubectl get clusterrolebinding cluster-admin -o yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  creationTimestamp: "2022-08-09T19:47:23Z"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: cluster-admin
  resourceVersion: "140"
  uid: 4ba86c3c-ff70-4f9e-97c3-78e3cb9efb28
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:masters
```

The **roleRef** specifies which role or **ClusterRole** the binding applies to. cluster-admin is the name of a cluster role that is created during cluster creation. 

The role **name** is not required to have the same name as the binding, but they are usually the same by convention. 

The **subjects** specify which subjects are bound to the role. In this case, any user that is a member of the **system:masters** Group. 

The **apiGroup** defines the Kubernetes API Group of the subject, which is **rbac.authorization.k8s.io** for users and groups.

We can learn more about the subject by running the **explain** command.

```bash
$ kubectl explain clusterrolebinding.subjects

KIND:     ClusterRoleBinding
VERSION:  rbac.authorization.k8s.io/v1

RESOURCE: subjects <[]Object>

DESCRIPTION:
     Subjects holds references to the objects the role applies to.

     Subject contains a reference to the object or user identities a role
     binding applies to. This can either hold a direct API object reference, or
     a value for non-objects such as user and group names.

FIELDS:
   apiGroup     <string>
     APIGroup holds the API group of the referenced subject. Defaults to "" for
     ServiceAccount subjects. Defaults to "rbac.authorization.k8s.io" for User
     and Group subjects.

   kind <string> -required-
     Kind of object being referenced. Values defined by this API group are
     "User", "Group", and "ServiceAccount". If the Authorizer does not
     recognized the kind value, the Authorizer should report an error.

   name <string> -required-
     Name of the object being referenced.

   namespace    <string>
     Namespace of the referenced object. If the object kind is non-namespace,
     such as "User" or "Group", and this value is not empty the Authorizer
     should report an error. 
```

To describe the cluster-admin cluster role:

```bash
$ kubectl describe clusterrole cluster-admin
Name:         cluster-admin
Labels:       kubernetes.io/bootstrapping=rbac-defaults
Annotations:  rbac.authorization.kubernetes.io/autoupdate: true
PolicyRule:
  Resources  Non-Resource URLs  Resource Names  Verbs
  ---------  -----------------  --------------  -----
  *.*        []                 []              [*]
             [*]                []              [*] 
```

A **role** is a list of policy rules (**PolicyRule**). Each rule defines the **Resources** that the rule applies to or **Non-Resource URLs** that it applies to. This can be specified using a kind of resource (for example pods or services) or kind of resource and specific resource names to apply to only a subset of all the resources of a kind (for example pods named my-pod). 

**Non-Resource URLs** refer Kubernetes API endpoints that are not for resources, such as the /healthz cluster health endpoint. Each rule also defines a list of Verbs that specify the actions that are allowed, for example get, list, and watch for read-only access. 

Wildcards (*) can be used to apply to all possible values. In the case of the cluster-admin role, they can use any verb on any resource or non-resource URL.

## Cluster Admin Role

View the YAML for the cluster-admin cluster role:

```bash
$ kubectl get clusterrole cluster-admin -o yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  creationTimestamp: "2022-08-09T19:47:23Z"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: cluster-admin
  resourceVersion: "78"
  uid: b698d652-4d9f-4e38-b9fe-d5ec31b2121a
rules:
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
- nonResourceURLs:
  - '*'
  verbs:
  - '*' 
```

Here we can see that a role is simply a list of rules. The rules can apply to **resources** or **nonResourceURLs**. Again, you see the **apiGroups** key referring to API Groups in Kubernetes. 


## Resources 

- [CKA Certification Course – Certified Kubernetes Administrator](https://kodekloud.com/courses/certified-kubernetes-administrator-cka/)

- [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)



<br>

[Back to first page](../../README.md#kubernetes-security)
