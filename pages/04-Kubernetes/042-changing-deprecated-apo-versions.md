

# Changing deprecated API versions using kubectl convert

> *This is a practice scenario which I encountered during the CKA and CKAD Exams study.* 

## Install the kubectl convert 

Install the kubectl convert plugin on the controlplane node Download the latest release version using curl:

```bash
root@controlplane:~#  curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl-convert
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   138  100   138    0     0   8625      0 --:--:-- --:--:-- --:--:--  8117
100 45.8M  100 45.8M    0     0  55.8M      0 --:--:-- --:--:-- --:--:-- 55.8M

root@controlplane:~# ls
kubectl-convert  multi-pod.yaml  sample.yaml
```

Change the permission of the file and move to the /usr/local/bin/ directory.

```bash

root@controlplane:~# pwd
/root
root@controlplane:~# chmod +x kubectl-convert 
root@controlplane:~# 
root@controlplane:~# mv kubectl-convert /usr/local/bin/kubectl-convert
root@controlplane:~# 
Use the --help option to see more option.

root@controlplane:~# kubectl-convert --help
If it'll show more options that means it's configured correctly if it'll give an error that means we haven't set up properly.
``` 

## Verify 

Use the manifest file. It uses a deprecated API version.

```yaml
## ingress-old.yml  
---
# Deprecated API version
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: ingress-space
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /video-service
        pathType: Prefix
        backend:
          serviceName: ingress-svc
          servicePort: 80
```

Use the command kubectl-convert to change the deprecated API version. Make sure to forward to a new file. 

```bash
controlplane ~ ➜  kubectl-convert -f ingress-old.yaml --output-version networking.k8s.io/v1
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
  creationTimestamp: null
  name: ingress-space
spec:
  rules:
  - http:
      paths:
      - backend:
          service:
            name: ingress-svc
            port:
              number: 80
        path: /video-service
        pathType: Prefix
status:
  loadBalancer: {}

controlplane ~ ✖ kubectl-convert -f ingress-old.yaml --output-version networking.k8s.io/v1 > ingress-new.yaml

controlplane ~ ➜  ls -l
total 8
-rw-r--r-- 1 root root 398 Jan  6 01:18 ingress-new.yaml
-rw-rw-rw- 1 root root 348 Dec  1 06:17 ingress-old.yaml  

controlplane ~ ➜  k apply -f  ingress-new.yaml 
ingress.networking.k8s.io/ingress-space created

controlplane ~ ➜  k get ing
NAME            CLASS    HOSTS   ADDRESS   PORTS   AGE
ingress-space   <none>   *                 80      12s

controlplane ~ ➜  k get ing ingress-space -o yaml | grep -i apiversion
apiVersion: networking.k8s.io/v1
```