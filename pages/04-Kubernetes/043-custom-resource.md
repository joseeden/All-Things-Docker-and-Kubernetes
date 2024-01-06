
# Custom Resource 

It is an extension of the Kubernetes API that is not necessarily available in a default Kubernetes installation.


## CRD Manifest 

Below is an example of a CRD. Details:

- It is called internals.datasets.kodekloud.com.
- Group is assigned to datasets.kodekloud.com.
- Resource is accessible only from a specific namespace. 

```yaml
## crd.yml 
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: internals.datasets.kodekloud.com 
spec:
  group: datasets.kodekloud.com
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                internalLoad:
                  type: string
                range:
                  type: integer
                percentage:
                  type: string
  scope: Namespaced 
  names:
    plural: internals
    singular: internal
    kind: Internal
    shortNames:
    - int
```

The CRD then refers to the custom resource:

```bash
## custom.yml  
---
kind: Internal
apiVersion: datasets.kodekloud.com/v1
metadata:
  name: internal-space
  namespace: default
spec:
  internalLoad: "high"
  range: 80
  percentage: "50"
```

We should have both files:

```bash
controlplane ~ ➜  ls -l
total 8
-rw-rw-rw- 1 root root 678 Jan  6 01:56 crd.yaml
-rw-rw-rw- 1 root root 171 Dec  1 06:17 custom.yaml
```

The CRD needs to be created first, before the custom resource. 

```bash
controlplane ~ ➜  k apply -f crd.yaml 
customresourcedefinition.apiextensions.k8s.io/internals.datasets.kodekloud.com created

controlplane ~ ➜  k apply -f custom.yaml 
internal.datasets.kodekloud.com/internal-space created

controlplane ~ ➜  k get crd
NAME                               CREATED AT
collectors.monitoring.controller   2024-01-06T06:20:57Z
globals.traffic.controller         2024-01-06T06:20:58Z
internals.datasets.kodekloud.com   2024-01-06T07:00:06Z
```

## Another example 

Create a custom resource called datacenter and the apiVersion should be traffic.controller/v1.

Set the dataField length to 2 and access permission should be true

```bash
## datacenter.yml
kind: Global 
apiVersion: traffic.controller/v1
metadata:
  name: datacenter
spec:
  dataField: 2
  access: true
```
```bash
controlplane ~ ➜  k apply -f datacenter.yml 
global.traffic.controller/datacenter created 
```
```bash
controlplane ~ ➜  k get global
NAME         AGE
datacenter   64s 
```