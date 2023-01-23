
# Labels, Selectors, and Annotations

- [Labels](#labels)
- [Selectors](#selectors)
- [Annotations](#annotations)
- [Sample Lab](#sample-lab)
- [Resources](#resources)


## Labels 

Labels are key-value pairs that are associated with Kubernetes Objects, such as Pods. We can use labels to organize the resources we have in Kubernetes. For example, we may create a label that declares the application tier resources belonged to, such as frontend or backend. Labels do not have to be unique across different resources of a given kind, unlike names and UIDs. Therefore, you can have multiple Pods labeled as frontend.

## Selectors 

Label selectors identify a set of Kubernetes Objects using labels. A selector provides conditions for what label should be present (or absent) on Objects and also what values are allowed (or disallowed). For example, a selector could be used to get the set of all Pods that have a tier label or all Pods that have a tier label with a value of frontend.

## Annotations 

While labels are attributes that identify resources, Kubernetes also has the concept of **annotations**, which are non-identifying Object attributes. An example of an annotation is the phone number of a person to call if an issue is discovered with a resource. Just like labels, annotations are also defined as key-value pairs. But you cannot select sets of Objects using annotations. Annotations are often used by Kubernetes client applications (such as kubectl) and Kubernetes extensions.

## Sample Lab

Below is an example manifest called **pods-labels.yml** that creates a namespace called **labels** and then create Pods in that namespace. Notice that each resource definitions are separated by a "---".

```bash
apiVersion: v1
kind: Namespace
metadata:
  name: labels 
---
apiVersion: v1
kind: Pod
metadata:
  name: red-frontend
  namespace: labels # declare namespace in metadata 
  labels: # labels mapping in metadata
    color: red
    tier: frontend
  annotations: # Example annotation
    Lab: Kubernetes Pod Design for Application Developers
spec:
  containers:
  - image: httpd:2.4.38
    name: web-server
---
apiVersion: v1
kind: Pod
metadata:
  name: green-frontend
  namespace: labels
  labels:
    color: green
    tier: frontend
spec:
  containers:
  - image: httpd:2.4.38
    name: web-server
---
apiVersion: v1
kind: Pod
metadata:
  name: red-backend
  namespace: labels
  labels:
    color: red
    tier: backend
spec:
  containers:
  - image: postgres:11.2-alpine
    name: db
---
apiVersion: v1
kind: Pod
metadata:
  name: blue-backend
  namespace: labels
  labels:
    color: blue
    tier: backend
spec:
  containers:
  - image: postgres:11.2-alpine
    name: db
---
apiVersion: v1
kind: Pod
metadata:
  name: no-color-backend
  namespace: labels
  labels:
    tier: backend
spec:
  containers:
  - image: postgres:11.2-alpine
    name: db
---
apiVersion: v1
kind: Pod
metadata:
  name: no-color-frontend
  namespace: labels
  labels:
    tier: backend
spec:
  containers:
  - image: postgres:11.2-alpine
    name: db
```

To create the resources: 
```bash 
kubectl apply -f pod-labels.yaml
```

Retrieve the list of Pods using the **get** command.

```bash
$ kubectl get pods

NAME                READY   STATUS    RESTARTS   AGE
blue-backend        1/1     Running   0          25s
green-frontend      1/1     Running   0          25s
no-color-backend    1/1     Running   0          25s
no-color-frontend   1/1     Running   0          25s
red-backend         1/1     Running   0          25s
red-frontend        1/1     Running   0          25s
```

We can see also isplay the columns for their labels using "-L" parameter. Here we can see that two of the Pods has no "color" label.

```bash
$ kubectl get pods -L color,tier

NAME                READY   STATUS    RESTARTS   AGE   COLOR   TIER
blue-backend        1/1     Running   0          50s   blue    backend
green-frontend      1/1     Running   0          50s   green   frontend
no-color-backend    1/1     Running   0          50s           backend
no-color-frontend   1/1     Running   0          50s           backend
red-backend         1/1     Running   0          50s   red     backend
red-frontend        1/1     Running   0          50s   red     frontend
```

We can filter the Pods to show only those which has the "color" label using the "-l" parameter. 

```bash
$ kubectl get pods -L color,tier -l color 

NAME             READY   STATUS    RESTARTS   AGE   COLOR   TIER
blue-backend     1/1     Running   0          75s   blue    backend
green-frontend   1/1     Running   0          75s   green   frontend
red-backend      1/1     Running   0          75s   red     backend
red-frontend     1/1     Running   0          75s   red     frontend
```

We can do the opposite and display only those which does not have the "color" label by adding the "!". This will return the two "no-color" Pods.

```bash
$ kubectl get pods -L color,tier -l '!color'

NAME                READY   STATUS    RESTARTS   AGE   COLOR   TIER
no-color-backend    1/1     Running   0          96s           backend
no-color-frontend   1/1     Running   0          96s           backend
```

We can also display Pods with "red" as the "color" label by using the "=", followed by the value.

```bash
$ kubectl get pods -L color,tier -l color=red

NAME           READY   STATUS    RESTARTS   AGE     COLOR   TIER
red-backend    1/1     Running   0          2m36s   red     backend
red-frontend   1/1     Running   0          2m36s   red     frontend
```

Multiple conditions can also be set for filtering:

```bash
$ kubectl get pods -L color,tier -l 'color=red,tier!=frontend'

NAME          READY   STATUS    RESTARTS   AGE     COLOR   TIER
red-backend   1/1     Running   0          4m17s   red     backend
```

The **in** condition allows you to specify the allowed values in parentheses. There is also a **notin** condition that allows you to specify disallowed values.

```bash
$ kubectl get pods -L color,tier -l 'color in (blue,green)'

NAME             READY   STATUS    RESTARTS   AGE     COLOR   TIER
blue-backend     1/1     Running   0          5m32s   blue    backend
green-frontend   1/1     Running   0          5m32s   green   frontend 
```

The annotations can be seen when we ran the **describe** command on the Pod.

```bash
$ kubectl describe pod red-frontend | grep Annotations -A 2

Annotations:  Lab: Kubernetes Pod Design for Application Developers
              cni.projectcalico.org/podIP: 192.168.23.130/32
              cni.projectcalico.org/podIPs: 192.168.23.130/32
```

To overwrite and remove the existin annotation, simply use the **annotate** command, followed by the specific line and a dash (-).

```bash
kubectl annotate pod red-frontend Lab-
```

The "Lab: Kubernetes Pod Design for Application Developers" should now be removed.

```bash
$ kubectl describe pod red-frontend | grep Annotations -A 2

Annotations:  cni.projectcalico.org/podIP: 192.168.23.130/32
              cni.projectcalico.org/podIPs: 192.168.23.130/32
```

## Resources 

- [Kubernetes Pod Design for Application Developers: Labels, Selectors, and Annotations](https://cloudacademy.com/lab/kubernetes-pod-design-application-developers-labels-selectors-and-annotations/?context_id=888&context_resource=lp)
