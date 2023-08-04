
# Exam Tips and Tricks 

- [Recommendations](#recommendations)
    - [General tips:](#general-tips)
    - [Checkin process:](#checkin-process)
    - [Moved to remote desktop environment in June 2022:](#moved-to-remote-desktop-environment-in-june-2022)
    - [Copy/paste:](#copypaste)
    - [Terminal:](#terminal)
    - [Miscellaneous recommendations:](#miscellaneous-recommendations)
    - [Use shortnames and aliases/variables:](#use-shortnames-and-aliasesvariables)
- [Persist Vim settings](#persist-vim-settings)
- [Use kubectl to view examples](#use-kubectl-to-view-examples)
- [Sample scenarios](#sample-scenarios)
    - [Scenario 1: Create resource](#scenario-1-create-resource)
    - [Scenario 2: Deleting pods without waiting](#scenario-2-deleting-pods-without-waiting)
    - [Scenario 3: Temporary pods](#scenario-3-temporary-pods)
- [Useful links that can be opened during exam](#useful-links-that-can-be-opened-during-exam)
- [Resources](#resources)



## Recommendations

### General tips:

- Adopt Killer Shell's tips regarding .bashrc and env variables (the vi settings were fine on my exam, but check anyway)

- The PSI Exam environment looks the same as Killer Shell, so use Killer Shell to adopt a fast workflow.

- The desktop shows several workspaces in the top right corner, use them. 

    - In the first workspace - Kubernetes Docu open, 
    - in the second workspace - terminal 
    - in the third - notepad  for note taking

- The "copy" button on the tasks page might not work in the real exam. You have to type in everything manually.  

- Use "CTRL + R" for reverse search of your commands - this is really handy for context switching and other stuff.

- In the Linux terminal, you can try:

    - "CTRL + SHIFT + C" for copy
    - "CTRL + SHIFT + V" for paste

- To copy texts from the K8s documentation, select text, right click, copy (don’t use the web function in the header of the templates to copy, as this doesn’t work with indentations).

- If you need to select a bunch of text, make a little selection at the top, scroll to the end and shift click to where you want to expand the selection to.

- First click through all tasks and filter out all > 10% questions, do these first, then all > 5% and finally the rest

- Write down completed tasks in your notes, because PSI Browser doesn't have such a function

- I won't give any details here, but there could be tasks that require a longer waiting time, use this time to open a second tab in the terminal and do a task that is very easy for you in parallel

- Check your results - this assumes you know how to check. Test this at Killer Shell and you'll be fast in the exam.

### Checkin process:

- ID check and camera scan
- clean your testing area
- one monitor
- don't stress

### Moved to remote desktop environment in June 2022:

- XFCE, Firefox
- expect some lag
- multiple terminals and browser tabs allowed
- keyboard layout preserved

### Copy/paste:

- right click menu
- ctrl-shift-(c|v)
- one-click copy from instructions (recommended to avoid typos)
- copying from firefox will trigger a warning (and maybe miss a character)

### Terminal:

- kubectl is pre-aliased to k with autocompletion
- .vimrc is pre-set (no need to remember):
    
    ```bash
    shiftwidth=2; expandtab=true; tabstop=2
    ```
- vscode and webstorm available as well more here
- tmux available but not necessary

### Miscellaneous recommendations:

- use a big screen
- hide the PSI top bar
- maximize your comfort

### Use shortnames and aliases/variables:

- Enable kubectl auto-completion:

    ```bash
    source <(kubectl completion bash)
    echo "source <(kubectl completion bash)" >> ~/.bashrc 
    ```

- never type out a full resource name if you can help it, example: 

    - cm -> configmap
    - pvc -> persistentvolumeclaim

- useful aliases:

    ```bash
    ## create yaml on-the-fly faster
    export do='--dry-run=client -o yaml'

    ## create/destroy from yaml faster
    alias kaf='k apply -f '
    alias kdf='k delete -f '

    ## namespaces (poor man's `kubens`)
    export nk='-n kube-system'
    export n='-n important-ns' # set this as needed

    ## destroy things without waiting
    export now='--grace-period 0 --force'

    ## Other aliases 
    alias k=kubectl
    alias kgp="k get pod"
    alias kgd="k get deploy"
    alias kgs="k get svc"
    alias kgn="k get nodes"
    alias kd="k describe"
    alias kge="k get events --sort-by='.metadata.creationTimestamp' |tail -8"    

    ## For dry-run 
    export do="--dry-run=client -o yaml"
    ```
- check all shortnames with:

    ```bash
    k api-resources
    ```


## Persist Vim settings 

Create the ~/.vimrc file.

```bash
vim ~/.vimrc  
```
```bash
set expandtab  
set tabstop=2
set shiftwidth=2
```

This now becomes the default Vim settings when you open a terminal:

- expandtab - use spaces for tab 
- tabstop - amounts of spaces used for tab
- shiftwidth - amounts of spaces used during indentation 

## Use kubectl to view examples

```bash
kubectl run --help
Create and run a particular image in a pod.

Examples:
  # Start a nginx pod.
  kubectl run nginx --image=nginx

  # Start a hazelcast pod and let the container expose port 5701.
  kubectl run hazelcast --image=hazelcast/hazelcast --port=5701

  # Start a hazelcast pod and set environment variables "DNS_DOMAIN=cluster" and "POD_NAMESPACE=default" in the
container.
  kubectl run hazelcast --image=hazelcast/hazelcast --env="DNS_DOMAIN=cluster" --env="POD_NAMESPACE=default"

  # Start a hazelcast pod and set labels "app=hazelcast" and "env=prod" in the container.
  kubectl run hazelcast --image=hazelcast/hazelcast --labels="app=hazelcast,env=prod"

  # Dry run. Print the corresponding API objects without creating them.
  kubectl run nginx --image=nginx --dry-run=client

  # Start a nginx pod, but overload the spec with a partial set of values parsed from JSON.
  kubectl run nginx --image=nginx --overrides='{ "apiVersion": "v1", "spec": { ... } }'

  # Start a busybox pod and keep it in the foreground, don't restart it if it exits.
  kubectl run -i -t busybox --image=busybox --restart=Never

  # Start the nginx pod using the default command, but use custom arguments (arg1 .. argN) for that command.
  kubectl run nginx --image=nginx -- <arg1> <arg2> ... <argN>

  # Start the nginx pod using a different command and custom arguments.
  kubectl run nginx --image=nginx --command -- <cmd> <arg1> ... <argN> 
```

## Sample scenarios

You can use dry run to generate a basic yaml file, then make any necessary changes on that file, and then use the modified file to create the required resources. 

### Scenario 1: Create resource

Create an nginx pod, set the request memory to 1M and the CPU to 500m can be solved with the following commands: 

Save a shortcut:

```bash
export do="--dry-run=client -o yaml" 
```

Then we can do the following:

```bash
k run nginx --image=nginx --dry-run=client -oyaml > pod.yaml
vi pod.yaml //添加 resource limit 设置
k create -f pod.yaml 
```

From this:

```bash
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yml
```

Instead we can just run this:

```bash
k run nginx --image=nginx $do > pod.yml
```

### Scenario 2: Deleting pods without waiting 

Save shortcut:

```bash
export now="--force --grace-period 0"  
```

Then delete pod _podname_

```bash
k delete pod podname $now 
```

### Scenario 3: Temporary pods 

Create a busybox pod, run wget command in it to test a k8s service created in the previous step. 

Since this is only for testing, we don't need the pod to persist after it has completed running wget. We cna use the _-rm_ option which will delete the pod immediately after running the specified command.

```bash
$ k run busybox --image=busybox -it -rm -- sh

If you don't see a command prompt, try pressing enter.
/ # wget -O- 172.17.254.255
```

## Useful links that can be opened during exam 

API overview 
- can be accessed through:
    ```bash
    https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.27/  
    ```

- or simply go to site then **Documentation** > **Reference** > **One-page API Reference for Kubernetes v1.27**

    ```bash
    kubernetes.io 
    ```

Others:

- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/
- https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker
- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/#steps-for-the-first-control-plane-node
- https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/
- https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#snapshot-using-etcdctl-options
- https://kubernetes.io/docs/tasks/debug-application-cluster/debug-cluster/
- https://github.com/kubernetes/ingress-nginx/blob/main/docs/deploy/index.md

## Resources

- https://github.com/ascode-com/wiki/tree/main/certified-kubernetes-administrator
- https://www.zhaohuabing.com/post/2022-02-08-how-to-prepare-cka-en/


