
# Kubernetes Security - Authentication and Authorization 


- [Authentication](#authentication)
- [Integration](#integration)
- [Cluster Roles and  Cluster Rolebindings](#cluster-roles-and--cluster-rolebindings)
- [Cluster Admin Rolebinding](#cluster-admin-rolebinding)
- [Cluster Admin Role](#cluster-admin-role)
- [Sample Lab: Sending authenticated requests to the API Server](#sample-lab-sending-authenticated-requests-to-the-api-server)
- [Authentication and Authorization in Action](#authentication-and-authorization-in-action)



## Authentication

There are two categories of users in Kubernetes: normal users and service accounts:

- **Normal Users**
These users represent the actual humans using Kubernetes and are managed externally by an independent service. 

- **Service Accounts**
These accounts represent identities used by processes running in pods and managed by Kubernetes.

Kubernetes supports authentication using:

* x509 certificates
* Bearer tokens
* Basic authentication (usernames and passwords)
* OpenID Connect (OIDC) tokens (currently limited support)

## Integration 

Kubernetes can also integrate with LDAP, SAML, and other authentication protocols by using plugins. Users can be members of groups to allow for easier access control management.

## Cluster Roles and  Cluster Rolebindings

When you send requests to Kubernetes, you are first authenticated, and then Kubernetes determines if you are authorized to complete the request. Kubernetes supports several [Authorization modules](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#authorization-modules). 

Role-based access control (RBAC) is a common way to control access to Kubernetes resources using roles. RBAC can be dynamically configured using the Kubernetes API and does not require modifying files compared to other user access control modules. Authorization, including RBAC, applies to both normal users and service accounts. You can also use RBAC on groups to simplify access control management. That is to say that normal users, service accounts, and groups are all valid subjects in RBAC.

Roles can be bound to subjects within a specific namespace (role binding) or cluster-wide (cluster role binding). It is a best practice to authorize access to the minimal amount of resources required by any subject, following the principle of least privilege. If a subject only needs access to a subset of namespaces, they should not be bound to a role using a cluster role binding.

To list all of the cluster role bindings in the cluster:

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

## Sample Lab: Sending authenticated requests to the API Server 

Let's first see the availabel API groups. Send an authenticated request to the secure API server endpoint using the commadn below. The response will show all the API groups, which will be a lot to display so we'll just note some fo them.


```bash
# Get the  API server endpoint and save it to a variable.

$ kubectl get endpoints kubernetes | tail -1 | awk '{print "https://" $2}'

https://10.0.0.100:6443 
```
```bash
$ api_endpoint=$(kubectl get endpoints kubernetes | tail -1 | awk '{print "https://" $2}')

$ sudo curl \
--cacert /etc/kubernetes/pki/ca.crt \
--cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
--key /etc/kubernetes/pki/apiserver-kubelet-client.key \
$api_endpoint
{
  "paths": [
    "/.well-known/openid-configuration",
    "/api",
    "/api/v1",
    "/apis",
    "/apis/",
    "/apis/admissionregistration.k8s.io",
    "/apis/admissionregistration.k8s.io/v1",
    "/apis/apiextensions.k8s.io",
    "/apis/apiextensions.k8s.io/v1",
    "/apis/apiregistration.k8s.io",
    "/apis/apiregistration.k8s.io/v1",
    "/apis/apps",
    "/apis/apps/v1",
    "/apis/authentication.k8s.io",
    "/apis/authentication.k8s.io/v1",


 ....

 (output shortened)    
```

The curl command borrows certificates created during cluster creation to authenticate the request. We could also extract the admin certificate out of the kubeconfig file and get the same result. The API server is configured to only expose a secure port (6443). 

We can view the API server configuration with:

```bash
$ sudo more /etc/kubernetes/manifests/kube-apiserver.yaml

apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubeadm.kubernetes.io/kube-apiserver.advertise-address.endpoint: 10.0.0.100:6443
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
    - --advertise-address=10.0.0.100
    - --allow-privileged=true
    - --authorization-mode=Node,RBAC
    - --client-ca-file=/etc/kubernetes/pki/ca.crt
    - --cloud-provider=aws
    - --enable-admission-plugins=NodeRestriction
    - --enable-bootstrap-token-auth=true
    - --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
 

 ....

 (output shortened)
```

Sending a request with no URL path to the API server returns a list of all the supported paths. The paths beginning with /api or /apis refer to different API Groups. 

For example, recall the **authorization.k8s.io** API Group used in defining a cluster role binding appears in the list (/apis/authorization.k8s.io) and there are two versions of the API Group:

- v1 (/apis/authorization.k8s.io/v1) 
- v1beta1 (/apis/authorization.k8s.io/v1beta1)

New features are incorporated in beta versions of API Groups. In general, it is best to avoid beta versions, when possible, as they are more likely to have security flaws. 

The **/api** path is the core API Group with most common resources such as pods and services.

We can list all the available resource API Groups:

```bash
$ kubectl api-versions

admissionregistration.k8s.io/v1
apiextensions.k8s.io/v1
apiregistration.k8s.io/v1
apps/v1
authentication.k8s.io/v1
authorization.k8s.io/v1
autoscaling/v1
autoscaling/v2
autoscaling/v2beta1
autoscaling/v2beta2
batch/v1
batch/v1beta1
certificates.k8s.io/v1
coordination.k8s.io/v1
crd.projectcalico.org/v1
discovery.k8s.io/v1
discovery.k8s.io/v1beta1
events.k8s.io/v1
events.k8s.io/v1beta1
flowcontrol.apiserver.k8s.io/v1beta1
flowcontrol.apiserver.k8s.io/v1beta2
metrics.k8s.io/v1beta1
networking.k8s.io/v1
node.k8s.io/v1
node.k8s.io/v1beta1
policy/v1
policy/v1beta1
rbac.authorization.k8s.io/v1
scheduling.k8s.io/v1
storage.k8s.io/v1
storage.k8s.io/v1beta1
v1 
```

Send a request for the authorization API Group using the command below. Notice that a **preferredVersion** sets which version to use when an explicit version is not specified.

```bash
$ sudo curl \
--cacert /etc/kubernetes/pki/ca.crt \
--cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
--key /etc/kubernetes/pki/apiserver-kubelet-client.key \
$api_endpoint/apis/authorization.k8s.io

{
  "kind": "APIGroup",
  "apiVersion": "v1",
  "name": "authorization.k8s.io",
  "versions": [
    {
      "groupVersion": "authorization.k8s.io/v1",
      "version": "v1"
    }
  ],
  "preferredVersion": {
    "groupVersion": "authorization.k8s.io/v1",
    "version": "v1" 
```

Send a request for version v1 of the core API Group (/api) using the command below. When you a version is specified, the resources in the API Group are returned.

```bash
$ sudo curl \
--cacert /etc/kubernetes/pki/ca.crt \
--cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
--key /etc/kubernetes/pki/apiserver-kubelet-client.key \
$api_endpoint/api/v1 \
| more

 
 {
  "kind": "APIResourceList",
  "groupVersion": "v1",
  "resources": [
    {
      "name": "bindings",
      "singularName": "",
      "namespaced": true,
      "kind": "Binding",
      "verbs": [
        "create"
      ]
    },
    {
      "name": "componentstatuses",
      "singularName": "",
      "namespaced": false,
      "kind": "ComponentStatus",
      "verbs": [
        "get",
        "list"
      ],
      "shortNames": [
        "cs"
      ]
    },
 

 ....

 (output shortened)   
```

All of the verbs that are supported for the resource are given. This can be helpful for defining rules in roles. It can also be helpful to use kubectl with maximum verbosity (--v=9) to display the API Server requests that are being sent, and extract the API Group and version from the URL path. It may not always be clear what a specific verb grants access for.


Using a different path (api/v1/pods):

```bash
sudo curl \
  --cacert /etc/kubernetes/pki/ca.crt \
  --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
  --key /etc/kubernetes/pki/apiserver-kubelet-client.key \
  $api_endpoint/api/v1/pods
```

From the description and operationId, we can see that the GET verb on /api/v1/pods is for listing pods across all namespaces. 


## Authentication and Authorization in Action 

To see how Kubernetes clusters are secured using authentication and authorization, check out this [lab](../../Lab27_Securing_Kubernetes_using_Authentication_and_Authorization/README.md).

