
# Use Audit Logs to monitor access 


- [Auditing](#auditing)
- [Enable Auditing on the Kubernetes](#enable-auditing-on-the-kubernetes)


## Auditing 

Kubernetes provides auditing and it is handled by the kube-apiserver. However, we will still need to enable it.

**Flow of Request**

1. Request is sent to kube-apiserver.
2. It goes through **RequestReceived** stage. In this stage, events are generated regardless if requests are approved or not.
3. For requests that take some time to complete, they go through **RequestStarted.**
4. Once request is completed, it goes through **RequestComplete.** In this stage, a response body is returned.
5. For invalid requests or errors, the request goes through **Panic** stage.

If we record all events generated for every stage, we would end up with thousands of logs within no time. TO record specific events, we can create a **Policy** object. 

## Enable Auditing on the Kubernetes 

We can use a Policy object which will contain all our rules for the kube-apiserver to use and record events that match the condition.

```yaml
## /etc/kubernetes/audit-policy.yaml 

apiVersion: audit.k8s.io/v1
kind: Policy
omitStages: ["RequestReceived"]
metadata:
  name: sample-policy
rules:
  - namespaces: ["prod-namespace"]
    verb: ["delete"]               
    resources: 
    - groups: "" 
      resources: ["pods"]
      resourceNames: ["webapp-pod"]
    level: RequestResponse   

  - level: Metadata 
    resources:
    - groups: "" 
      resources: ["secrets"]
```

Levels:

- None
- Metadata
- Request 
- RequestResponse 

To enable auditing, we need to specify the audit file and the policy file in the kube-apiserver manifest.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
  - name: kube-apiserver
    image: k8s.gcr.io/kube-apiserver:v1.21.3
    command:
    - kube-apiserver
    - --advertise-address=0.0.0.0
    - --allow-privileged=true
    - --authorization-mode=Node,RBAC
    ......
    - --audit-log-path=/var/;pg/k8s-audit.log
    - --audit-policy-file=/etc/kubernetes/audit-policy.yaml
    - --audit-log-maxage=10 
    - --audit-log-maxbackup=5 
    - --audit-log-maxsize=100
```

If the kube-apiserver is deployed as a service, specify the files in the service unit file:

```bash
ExecStart=/usr/local/bin/kube-apiserver 
  --advertise-address=0.0.0.0 
  -allow-privileged=true 
  --authorization-mode=Node,RBAC 
  ......
  --audit-log-path=/var/;pg/k8s-audit.log
  --audit-policy-file=/etc/kubernetes/audit-policy.yaml 
  --audit-log-maxage=10  
  --audit-log-maxbackup=5  
  --audit-log-maxsize=100   
```


<br>

[Back to first page](../../README.md#kubernetes-security)
