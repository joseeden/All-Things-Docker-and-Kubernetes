
# Exam  

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

- never type out a full resource name if you can help it, example: 

    - cm -> configmap
    - pvc -> persistentvolumeclaim

- check all shortnames with:

    ```bash
    k api-resources
    ```

- useful aliases 

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
    ```



References:https://github.com/ascode-com/wiki/tree/main/certified-kubernetes-administrator


## Useful links that can be opened during exam 

- API overview 
    - can be accessed through:
        ```bash
        https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.27/  
        ```

    - or simply go to site then **Documentation** > **Reference** > **One-page API Reference for Kubernetes v1.27**

        ```bash
        kubernetes.io 
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

