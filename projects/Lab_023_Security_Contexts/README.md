# Lab 023: Security Contexts


## Pre-requisites

- [Basic Understanding of Kubernetes](../../README.md#kubernetes)
- [AWS account](../../pages/01-Pre-requisites/labs-optional-tools/README.md#create-an-aws-account)
- [AWS IAM Requirements](../../pages/01-Pre-requisites/labs-optional-tools/01-AWS-IAM-requirements.md)
- [AWS CLI, kubectl, and eksctl](../../pages/01-Pre-requisites/labs-kubernetes-pre-requisites/README.md#install-cli-tools) 

Here's a breakdown of the sections for this lab.


- [Introduction](#introduction)
- [Launch a Simple EKS Cluster](#launch-a-simple-eks-cluster)
- [Familiarize with Security Contexts parameters](#familiarize-with-security-contexts-parameters)
- [Create a Pod with no security context](#create-a-pod-with-no-security-context)
- [Create a Pod with Security Contexts](#create-a-pod-with-security-contexts)
- [Pod security context and Container security context](#pod-security-context-and-container-security-context)
- [Cleanup](#cleanup)
- [Resources](#resources)


## Introduction

In this lab, we'll configure security contexts to ensure our Pods and containers are not exposed to security risk which could sometimes be posed by using third-party images. We will then configure multiple pods with differing security contexts.

A **security context** allows you to set access control for Pods, as well as containers and volumes in Pods, when applicable. Below are some examples of access controls which can be set:

* user ID and group IDs of the first process running in a container
* group ID of volumes
* set a container's root file system to read-only
* Security-Enhanced Linux (SELinux) options
* allow privilege status to containers, granting them root permissions
* privilege escalations, where child processes can have more privileges than their parent


## Launch a Simple EKS Cluster

Before we start, let's first verify if we're using the correct IAM user's access keys. This should be the user we created from the **pre-requisites** section above.

```bash
$ aws sts get-caller-identity 
```
```bash
{
    "UserId": "AIDxxxxxxxxxxxxxx",
    "Account": "1234567890",
    "Arn": "arn:aws:iam::1234567890:user/k8s-admin"
} 
```

For the cluster, we can reuse the **eksops.yml** file from the other labs.

<details><summary> eksops.yml </summary>
 
```bash
apiVersion: eksctl.io/v1alpha5
# apiVersion: client.authentication.k8s.io/v1beta1
kind: ClusterConfig

metadata:
    version: "1.23"
    name: eksops
    region: ap-southeast-1 
nodeGroups:
    -   name: ng-dover
        instanceType: t3.large
        minSize: 1
        maxSize: 5
        desiredCapacity: 3
        ssh: 
            publicKeyName: "k8s-kp"
```
 
</details>

Launch the cluster.

```bash
time eksctl create cluster -f eksops.yml 
```

Check the nodes.

```bash
kubectl get nodes 
```

Save the cluster, region, and AWS account ID in a variable. We'll be using these in a lot of the commands later.

```bash
MYREGION=ap-southeast-1
MYCLUSTER=eksops 
MYAWSID=$(aws sts get-caller-identity | python3 -c "import sys,json; print (json.load(sys.stdin)['Account'])")
```


## Familiarize with Security Contexts parameters

Let's start with understanding the avaialble security contexts fields. Run the **explain** command, followed by the parameter.

```bash
$ kubectl explain pod.spec.securityContext | more

KIND:     Pod
VERSION:  v1

RESOURCE: securityContext <Object>

DESCRIPTION:
     SecurityContext holds pod-level security attributes and common container
     settings. Optional: Defaults to empty. See type description for default
     values of each field.

     PodSecurityContext holds pod-level security attributes and common container
     settings. Some fields are also present in container.securityContext. Field
     values of container.securityContext take precedence over field values of
     PodSecurityContext.

FIELDS:
   fsGroup      <integer>
     A special supplemental group that applies to all containers in a pod. Some
     volume types allow the Kubelet to change the ownership of that volume to be
     owned by the pod:

     1. The owning GID will be the FSGroup 2. The setgid bit is set (new files
     created in the volume will be owned by FSGroup) 3. The permission bits are
     OR'd with rw-rw----

     If unset, the Kubelet will not modify the ownership and permissions of any
     volume. Note that this field cannot be set when spec.os.name is windows.

   fsGroupChangePolicy  <string>
     fsGroupChangePolicy defines behavior of changing ownership and permission
     of the volume before being exposed inside Pod. This field will only apply
     to volume types which support fsGroup based ownership(and permissions). It
     will have no effect on ephemeral volume types such as: secret, configmaps
     and emptydir. Valid values are "OnRootMismatch" and "Always". If not
     specified, "Always" is used. Note that this field cannot be set when
     spec.os.name is windows.

   runAsGroup   <integer>
     The GID to run the entrypoint of the container process. Uses runtime
     default if unset. May also be set in SecurityContext. If set in both
     SecurityContext and PodSecurityContext, the value specified in
     SecurityContext takes precedence for that container. Note that this field
     cannot be set when spec.os.name is windows.

   runAsNonRoot <boolean>
     Indicates that the container must run as a non-root user. If true, the
     Kubelet will validate the image at runtime to ensure that it does not run
     as UID 0 (root) and fail to start the container if it does. If unset or
     false, no such validation will be performed. May also be set in
     SecurityContext. If set in both SecurityContext and PodSecurityContext, the
     value specified in SecurityContext takes precedence.

   runAsUser    <integer>
     The UID to run the entrypoint of the container process. Defaults to user
     specified in image metadata if unspecified. May also be set in
     SecurityContext. If set in both SecurityContext and PodSecurityContext, the
     value specified in SecurityContext takes precedence for that container.
     Note that this field cannot be set when spec.os.name is windows.

   seLinuxOptions       <Object>
     The SELinux context to be applied to all containers. If unspecified, the
     container runtime will allocate a random SELinux context for each
     container. May also be set in SecurityContext. If set in both
     SecurityContext and PodSecurityContext, the value specified in
     SecurityContext takes precedence for that container. Note that this field
     cannot be set when spec.os.name is windows.

   seccompProfile       <Object>
     The seccomp options to use by the containers in this pod. Note that this
     field cannot be set when spec.os.name is windows.

   supplementalGroups   <[]integer>
     A list of groups applied to the first process run in each container, in
     addition to the container's primary GID. If unspecified, no groups will be
     added to any container. Note that this field cannot be set when
     spec.os.name is windows.

   sysctls      <[]Object>
     Sysctls hold a list of namespaced sysctls used for the pod. Pods with
     unsupported sysctls (by the container runtime) might fail to launch. Note
     that this field cannot be set when spec.os.name is windows.

   windowsOptions       <Object>
     The Windows specific settings applied to all containers. If unspecified,
     the options within a container's SecurityContext will be used. If set in
     both SecurityContext and PodSecurityContext, the value specified in
     SecurityContext takes precedence. Note that this field cannot be set when
     spec.os.name is linux.
```

There are also container-level security contexts which could set.

```bash
$ kubectl explain pod.spec.containers.securityContext | more

KIND:     Pod
VERSION:  v1

RESOURCE: securityContext <Object>

DESCRIPTION:
     SecurityContext defines the security options the container should be run
     with. If set, the fields of SecurityContext override the equivalent fields
     of PodSecurityContext. More info:
     https://kubernetes.io/docs/tasks/configure-pod-container/security-context/

     SecurityContext holds security configuration that will be applied to a
     container. Some fields are present in both SecurityContext and
     PodSecurityContext. When both are set, the values in SecurityContext take
     precedence.

FIELDS:
   allowPrivilegeEscalation     <boolean>
     AllowPrivilegeEscalation controls whether a process can gain more
     privileges than its parent process. This bool directly controls if the
     no_new_privs flag will be set on the container process.
     AllowPrivilegeEscalation is true always when the container is: 1) run as
     Privileged 2) has CAP_SYS_ADMIN Note that this field cannot be set when
     spec.os.name is windows.

   capabilities <Object>
     The capabilities to add/drop when running containers. Defaults to the
     default set of capabilities granted by the container runtime. Note that
     this field cannot be set when spec.os.name is windows.

   privileged   <boolean>
     Run container in privileged mode. Processes in privileged containers are
     essentially equivalent to root on the host. Defaults to false. Note that
     this field cannot be set when spec.os.name is windows.

   procMount    <string>
     procMount denotes the type of proc mount to use for the containers. The
     default is DefaultProcMount which uses the container runtime defaults for
     readonly paths and masked paths. This requires the ProcMountType feature
     flag to be enabled. Note that this field cannot be set when spec.os.name is
     windows.

   readOnlyRootFilesystem       <boolean>
     Whether this container has a read-only root filesystem. Default is false.
     Note that this field cannot be set when spec.os.name is windows.

   runAsGroup   <integer>
     The GID to run the entrypoint of the container process. Uses runtime
     default if unset. May also be set in PodSecurityContext. If set in both
     SecurityContext and PodSecurityContext, the value specified in
     SecurityContext takes precedence. Note that this field cannot be set when
     spec.os.name is windows.

   runAsNonRoot <boolean>
     Indicates that the container must run as a non-root user. If true, the
     Kubelet will validate the image at runtime to ensure that it does not run
     as UID 0 (root) and fail to start the container if it does. If unset or
     false, no such validation will be performed. May also be set in
     PodSecurityContext. If set in both SecurityContext and PodSecurityContext,
     the value specified in SecurityContext takes precedence.

   runAsUser    <integer>
     The UID to run the entrypoint of the container process. Defaults to user
     specified in image metadata if unspecified. May also be set in
     PodSecurityContext. If set in both SecurityContext and PodSecurityContext,
     the value specified in SecurityContext takes precedence. Note that this
     field cannot be set when spec.os.name is windows.

   seLinuxOptions       <Object>
     The SELinux context to be applied to the container. If unspecified, the
     container runtime will allocate a random SELinux context for each
     container. May also be set in PodSecurityContext. If set in both
     SecurityContext and PodSecurityContext, the value specified in
     SecurityContext takes precedence. Note that this field cannot be set when
     spec.os.name is windows.

   seccompProfile       <Object>
     The seccomp options to use by this container. If seccomp options are
     provided at both the pod & container level, the container options override
     the pod options. Note that this field cannot be set when spec.os.name is
     windows.

   windowsOptions       <Object>
     The Windows specific settings applied to all containers. If unspecified,
     the options from the PodSecurityContext will be used. If set in both
     SecurityContext and PodSecurityContext, the value specified in
     SecurityContext takes precedence. Note that this field cannot be set when
     spec.os.name is linux. 
```

## Create a Pod with no security context

Let's create a simple Pod that runs a container that sleeps.

```bash
$ vi pod-insecure.yml 

apiVersion: v1
kind: Pod
metadata:
  name: security-context-test-1
spec:
  containers:
  - image: busybox:1.30.1
    name: busybox
    args:
    - sleep
    - "3600"
```
```bash
kubectl apply -f pod-insecure.yml 
```

Verify that its running and list the available devices in the container. Notice it will only display few devices which doesn't pose any harm. There are also no block devices, specifically the **nvme0n1p1** which is the host's file system disk.

```bash
kubectl get pods
```
```bash
$ kubectl exec security-context-test-1 -- ls -la /dev

total 4
drwxr-xr-x    5 root     root           360 Dec 18 10:59 .
drwxr-xr-x    1 root     root          4096 Dec 18 10:59 ..
lrwxrwxrwx    1 root     root            11 Dec 18 10:59 core -> /proc/kcore
lrwxrwxrwx    1 root     root            13 Dec 18 10:59 fd -> /proc/self/fd
crw-rw-rw-    1 root     root        1,   7 Dec 18 10:59 full
drwxrwxrwt    2 root     root            40 Dec 18 10:59 mqueue
crw-rw-rw-    1 root     root        1,   3 Dec 18 10:59 null
lrwxrwxrwx    1 root     root             8 Dec 18 10:59 ptmx -> pts/ptmx
drwxr-xr-x    2 root     root             0 Dec 18 10:59 pts
crw-rw-rw-    1 root     root        1,   8 Dec 18 10:59 random
drwxrwxrwt    2 root     root            40 Dec 18 10:59 shm
lrwxrwxrwx    1 root     root            15 Dec 18 10:59 stderr -> /proc/self/fd/2
lrwxrwxrwx    1 root     root            15 Dec 18 10:59 stdin -> /proc/self/fd/0
lrwxrwxrwx    1 root     root            15 Dec 18 10:59 stdout -> /proc/self/fd/1
-rw-rw-rw-    1 root     root             0 Dec 18 10:59 termination-log
crw-rw-rw-    1 root     root        5,   0 Dec 18 10:59 tty
crw-rw-rw-    1 root     root        1,   9 Dec 18 10:59 urandom
crw-rw-rw-    1 root     root        1,   5 Dec 18 10:59 zero 
```

Delete the Pod.

```bash
kubectl delete -f pod-insecure.yml  
```

## Create a Pod with Security Contexts 

Let's create another Pod, but this time let's add the **securityContext** parameter under the Pod's spec.

```bash
$ vi pod-privileged.yml 

apiVersion: v1
kind: Pod
metadata:
  name: security-context-test-2
spec:
  containers:
  - image: busybox:1.30.1
    name: busybox
    args:
    - sleep
    - "3600"
    securityContext:
      privileged: true
```

Run the new Pod and list the devices again. This time, we could now see more devices including the host file system disk **nvme0n1p1**, which can become a major security issue for our Pod.  

Delete the pod.

```bash
kubectl delete -f pod-privileged.yml 
```

## Pod security context and Container security context 

Let's now create a third pod that has Pod security contexts and container-level security contexts.

```bash
$ vi pod-secured.yml 

apiVersion: v1
kind: Pod
metadata:
  name: security-context-test-3
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
  containers:
  - image: busybox:1.30.1
    name: busybox
    args:
    - sleep
    - "3600"
    securityContext:
      runAsUser: 2000
      readOnlyRootFilesystem: true
```
```bash
kubectl apply -f pod-secured.yml  
```

This Pod has two levels of security: 

- the Pod security context ensures that the container process does not run as root ("*runAsNonRoot*") and sets the user ID of the container process to 1000

- the container security context sets the container process' user ID to 2000 and sets the root file system to read-only.

Check the running processes inside this Pod. Notice that all the processes are owned by the user ID 2000. We can see that the container security context overrides the USER ID setting in the Pod security context when both security contexts include the same field. Whenever possible you should not run as root.

```bash
$ kubectl exec security-context-test-3 -it -- ps

PID   USER     TIME  COMMAND
    1 2000      0:00 sleep 3600
   16 2000      0:00 ps
```

Now try to create a **test.txt** in the /tmp directory. This will fail because the filesystem is **read-only.** When possible, it is best to use read-only root file systems to harden your container environments. A best practice is to use volumes to mount any files that require modification, allowing the root file system to be read-only.

```bash
$ kubectl exec security-context-test-3 -it -- touch /tmp/test.txt

touch: /tmp/test.txt: Read-only file system
command terminated with exit code 1
```

## Cleanup 

Before we officially close this lab, make sure to destroy all resources to prevent incurring additional costs.

```bash
$ time eksctl delete cluster -f  eksops.yml
```

Note that when you delete your cluster, make sure to double-check the AWS Console and ensure that the Cloudformation stacks (which we created by eksctl) are dropped cleanly.

## Resources

- [Mastering Kubernetes Pod Configuration: Security Contexts](https://cloudacademy.com/lab/mastering-kubernetes-pod-configuration-security-contexts/?context_resource=lp&context_id=888)