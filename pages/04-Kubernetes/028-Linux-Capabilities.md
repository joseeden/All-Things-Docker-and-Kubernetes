
# Linux Capabilities


- [Linux Capabilities](#linux-capabilities)
- [Effective, Inheritable, and Permitted Sets](#effective-inheritable-and-permitted-sets)
- [Dropping Privileges](#dropping-privileges)
- [Examples of Linux Capabilities](#examples-of-linux-capabilities)
- [Linux Capabilities in Kubernetes](#linux-capabilities-in-kubernetes)

## Linux Capabilities 

Linux capabilities are part of the kernel's security model and are used to enhance security by reducing the attack surface of applications.

**Traditional Privileges vs. Capabilities**
Traditionally, processes running with root privileges have all or nothing. They have full control over the system. Linux capabilities allow more fine-grained control by dividing these privileges into separate units.

**Bounding Set**
Each process has a set of capabilities known as the bounding set. The bounding set restricts the capabilities a process can gain through user or group privileges.


To check what capabilities is needed by a command, example is ping:

```bash
$ which ping
/usr/bin/ping

$ getcap /usr/bin/ping
/usr/bin/ping = cap_net_raw+ep
```

To get the capabilities needed by a process, example is ssh:

```bash
$ which sshd
/usr/sbin/sshd

$ ps -ef | grep /usr/bin/sshd
joseeden   740    1  0 18:29 ?    00:00:00 /usr/bin/sshd =D

$ getpcaps 740
Capabilities for `740': =cap_net_bind_service,cap_net_raw+ep
```


## Effective, Inheritable, and Permitted Sets 

For each process, there are three sets of capabilities: effective, inheritable, and permitted. These sets determine the actual privileges a process has.

- **Permitted (CAP_PERMITTED):** The capabilities that the process can use.
- **Inheritable (CAP_INHERITABLE):** Capabilities preserved across an `execve()` system call.
- **Effective (CAP_EFFECTIVE):** The capabilities currently in effect.


## Dropping Privileges
Processes can drop specific capabilities to reduce their privileges after they have started.

   - The `prctl()` system call is often used to manipulate capabilities programmatically.

## Examples of Linux Capabilities

- **CAP_NET_BIND_SERVICE:** Allow binding to privileged ports (<1024) without root.
- **CAP_DAC_READ_SEARCH:** Bypass file read and directory search permission checks.
- **CAP_SYS_ADMIN:** Perform a range of administrative tasks.
- **CAP_SYS_PTRACE:** Trace arbitrary processes.
- **CAP_NET_RAW:** Use raw sockets.

## Linux Capabilities in Kubernetes 

To leverage Linux capabilities in Kubernetes, we can dfeine them under security context in a pod definition file. 

```yaml 
apiVersion: v1
kind: Pod
metadata:
  name: time-cap-pod
spec:
  containers:
  - name: ubuntu-container
    image: ubuntu:latest
    command: ["sleep", "3600"]
    securityContext:
      capabilities:
        add: ["SYS_TIME"]
```

Similarly, we can also drop Linux capabilities:

```yaml 
apiVersion: v1
kind: Pod
metadata:
  name: time-cap-pod
spec:
  containers:
  - name: ubuntu-container
    image: ubuntu:latest
    command: ["sleep", "3600"]
    securityContext:
      capabilities:
        add: ["SYS_TIME"]
        drop: ["CHOWN"]
```

To learn more, check out [Set capabilities for a Container.](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-capabilities-for-a-container) 






<br>

[Back to first page](../../README.md#kubernetes-security)
