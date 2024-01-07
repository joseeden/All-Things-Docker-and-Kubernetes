
# Kubernetes Security - Security Contexts 




## Security Contexts 

A security context allows you to set access control for pods, as well as containers and volumes in pods, when applicable. Examples of access controls that can be set with security contexts include:

* The user ID and group IDs of the first process running in a container
* The group ID of volumes
* If a container's root file system is read-only
* Security Enhanced Linux (SELinux) options
* The privileged status of containers, which allows the container to do almost everything root can do on the host, if enabled
* Whether or not privilege escalation, where child processes can have more privileges than their parent, is allowed

When a security context field is configured for a pod and one of the pod's containers, the container's setting takes precedence. Configuring the security context of pods and containers can greatly reduce the security risk posed by using third-party images.

## Pod-level Security Context 

To see the options that can be set at the Pod-level:

```bash
$ kubectl explain pod.spec.securityContext

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

## Container-level Security Context 

To see the options that can be set at the Pod-level:

```bash
$ kubectl explain pod.spec.containers.securityContext

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

## Risks of Privileged Containers 

Below is an example of a manifest that creates a privileged container. This means that the container has similar-to-root permissions. 

```bash
# pod-privileged.yml 

apiVersion: v1
kind: Pod
metadata:
  name: pod-privileged
spec:
  containers:
  - image: busybox
    name: busybox
    args:
    - sleep
    - "3600"
    securityContext:
      privileged: true
```

Using privileged containers introduces several other security vulnerabilities, and is equivalent to granting root access to the host. To avoid the potential downfalls of privileged containers, there are several best practices including:

* Avoid using privileged containers, and ensure any third-party Kuberentes templates you use do not stealthily grant privileged access
* Use RBAC to prevent users and service accounts from using exec or attach (the relevant RBAC resources are pod/exec and pod/attach)
* Use a trusted image registry
* Enable **PodSecurityPolicies** to enforce all containers running in unprivileged mode
* Do not run containers as the root user 

## Run as Non-Root 

Below is manifest that creates a Pod with container-level and pod-level Security contexts. 
- the pod security context enforces the container processes to run as a non-root user through the **runAsNonRoot** property. Instead, the container processes uses a user ID of 1000.

- The container securityContext sets the container process' user ID to 2000 and sets the root file system to read-only.

**Wait, two user IDs?**

When both the container and pod security contexts contains the same field, the container security context overrides the setting in the pod security context.

```bash
# pod-secured.yml 

apiVersion: v1
kind: Pod
metadata:
  name: pod-secured
  namespace: test
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
  containers:
  - image: busybox
    name: busybox
    args:
    - sleep
    - "3600"
    securityContext:
      runAsUser: 2000
      readOnlyRootFilesystem: true 
```

## Security Contexts in Action 

To see how security contexts works in a real scenario, check out this [lab](../../Lab23_Security_Contexts/README.md).

## Resources

- [Security Group Rules in EKS](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html)

- [Kubernetes Security - Best Practice Guide](https://github.com/freach/kubernetes-security-best-practice/blob/master/README.md#firewall-ports-fire)

- [Using Security Contexts to Secure Kubernetes Clusters](https://cloudacademy.com/lab/using-security-contexts-to-secure-kubernetes-cluster/?context_id=888&context_resource=lp)




<br>

[Back to first page](../../README.md#kubernetes-security)
