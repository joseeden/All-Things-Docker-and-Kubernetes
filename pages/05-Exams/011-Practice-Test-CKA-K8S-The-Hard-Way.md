
# Practice Test: CKA 

> *Some of the scenario questions here are based on Kodekloud's [CKA course labs](https://kodekloud.com/courses/ultimate-certified-kubernetes-administrator-cka-mock-exam/).*

- [Core Concepts](003-Practice-Test-CKA-Core-concepts.md) 

- [Scheduling](004-Practice-Test-CKA-Scheduling.md) 

- [Logging and Monitoring](005-Practice-Test-CKA-Logging-Monitoring.md)

- [Application Lifecycle Management](006-Practice-Test-CKA-App-Lifecycle-Management.md) 

- [Cluster Maintenance](007-Practice-Test-CKA-Cluster-Maintenance.md) 

- [Security](008-Practice-Test-CKA-Security.md) 

- [Storage](009-Practice-Test-CKA-Storage.md) 

- [Networking](010-Practice-Test-CKA-Networking.md)

- [Kubernetes-the-hard-way](011-Practice-Test-CKA-K8S-The-Hard-Way.md)

- [Mock Exams](./014-Practice-Test-CKA-Mock-Exam.md)




## Kubernetes - The Hard Way 

1. Install the kubeadm and kubelet packages on the controlplane and node01 nodes.

    Use the exact version of 1.27.0-2.1 for both.

    <details><summary> Answer </summary>

    Complete steps can be found here:
    https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

    ```bash
    sudo apt-get update
    # apt-transport-https may be a dummy package; if so, you can skip that package
    sudo apt-get install -y apt-transport-https ca-certificates curl gpg
    ```

    Check if OS is Ubuntu,if it is, then need to create the /etc/apt/keyrings.

    ```bash
    controlplane ~ ➜  cat /etc/os-release 
    NAME="Ubuntu"
    VERSION="20.04.6 LTS (Focal Fossa)"
    ID=ubuntu
    ID_LIKE=debian
    PRETTY_NAME="Ubuntu 20.04.6 LTS"
    VERSION_ID="20.04"
    HOME_URL="https://www.ubuntu.com/"
    SUPPORT_URL="https://help.ubuntu.com/"
    BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
    PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
    VERSION_CODENAME=focal
    UBUNTU_CODENAME=focal

    controlplane ~ ➜  sudo mkdir -m 755 /etc/apt/keyrings 
    ```
    
    Continue with the steps from the docs.

    ```bash
    controlplane ~ ➜  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.27/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg  

    # This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.27/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

    sudo apt-get install -y \
    kubelet=1.27.0-2.1 \
    kubeadm=1.27.0-2.1 \
    kubectl=1.27.0-2.1 
    ```

    Verify. 

    ```bash
    controlplane ~ ➜  kubeadm version
    kubeadm version: &version.Info{Major:"1", Minor:"27", GitVersion:"v1.27.0", GitCommit:"1b4df30b3cdfeaba6024e81e559a6cd09a089d65", GitTreeState:"clean", BuildDate:"2023-04-11T17:09:06Z", GoVersion:"go1.20.3", Compiler:"gc", Platform:"linux/amd64"}

    controlplane ~ ➜  kubectl version
    WARNING: This version information is deprecated and will be replaced with the output from kubectl version --short.  Use --output=yaml|json to get the full version.
    Client Version: version.Info{Major:"1", Minor:"27", GitVersion:"v1.27.0", GitCommit:"1b4df30b3cdfeaba6024e81e559a6cd09a089d65", GitTreeState:"clean", BuildDate:"2023-04-11T17:10:18Z", GoVersion:"go1.20.3", Compiler:"gc", Platform:"linux/amd64"}
    Kustomize Version: v5.0.1
    Error from server (NotFound): the server could not find the requested resource
    ```

    Repeat the same steps to setup node01.

    </details>
    </br>

2. After installing the required tools in the previous question, bootstrap the Kubernetes cluster using kubeadm. Initialize Control Plane Node (Master Node). Use the following options:

    - apiserver-advertise-address - Use the IP address allocated to eth0 on the controlplane node

    - apiserver-cert-extra-sans - Set it to controlplane

    - pod-network-cidr - Set to 10.244.0.0/16

    Once done, set up the default kubeconfig file and wait for node to be part of the cluster.

    <details><summary> Answer </summary>

    Complete steps can be found here:
    https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/ 

    Get the controlplane's IP first.

    ```bash
    controlplane ~ ✖ ip addr | grep eth0
    5817: eth0@if5818: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP group default 
        inet 192.17.66.9/24 brd 192.17.66.255 scope global eth0 
    ```

    Then run kube init with the supplied values. 

    ```bash
    kubeadm init \
    --apiserver-advertise-address 192.17.66.9 \
    --apiserver-cert-extra-sans controlplane \
    --pod-network-cidr 10.244.0.0/16
    ```

    To make kubectl work for your non-root user, setup the default kubeconfig file. Run these commands, which are also part of the kubeadm init output:

    ```bash
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config 
    ```

    Take note of the output:

    ```bash
    Then you can join any number of worker nodes by running the following on each as root:

    kubeadm join 192.17.66.9:6443 --token n3131u.ndrbw41snadbex5r \
            --discovery-token-ca-cert-hash sha256:0d557809cfe18f10cbba69fe455aa3b03dad336824cbba62a29fe81ee8a18d9f  
    ```
    
    </details>
    </br>





3. After controlplane is bootstrapped, join the node01 to the cluster.

    <details><summary> Answer </summary>

    Run the kubeadm join command which was returned by the kubeadm output. 

    ```bash
    kubeadm join 192.17.66.9:6443 --token n3131u.ndrbw41snadbex5r \
            --discovery-token-ca-cert-hash sha256:0d557809cfe18f10cbba69fe455aa3b03dad336824cbba62a29fe81ee8a18d9f  
    ```

    Once it's done running, return to the controlplane and verify if it can see the node01 in the cluster. 

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS     ROLES           AGE     VERSION
    controlplane   NotReady   control-plane   3m37s   v1.27.0
    node01         NotReady   <none>          35s     v1.27.0 
    ```
    
    </details>
    </br>



4. To install a network plugin, we will go with Flannel as the default choice. For inter-host communication, we will utilize the eth0 interface.

    Please ensure that the Flannel manifest includes the appropriate options for this configuration.



    <details><summary> Answer </summary>

    Download the YAML file. 

    ```bash
    curl -LO https://raw.githubusercontent.com/flannel-io/flannel/v0.20.2/Documentation/kube-flannel.yml
    ```

    Modify the file:

    ```bash
        args:
        - --ip-masq
        - --kube-subnet-mgr
        - --iface=eth0 
    ```

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS     ROLES           AGE     VERSION
    controlplane   NotReady   control-plane   3m37s   v1.27.0
    node01         NotReady   <none>          35s     v1.27.0

    controlplane ~ ➜  curl -LO https://raw.githubusercontent.com/flannel-io/flannel/v0.20.2/Documentation/kube-flannel.yml
    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                    Dload  Upload   Total   Spent    Left  Speed
    100  4591  100  4591    0     0  34780      0 --:--:-- --:--:-- --:--:-- 34780

    controlplane ~ ➜  vi kube-flannel.yml 

    controlplane ~ ➜  kubectl apply -f kube-flannel.yml
    namespace/kube-flannel created
    clusterrole.rbac.authorization.k8s.io/flannel created
    clusterrolebinding.rbac.authorization.k8s.io/flannel created
    serviceaccount/flannel created
    configmap/kube-flannel-cfg created
    daemonset.apps/kube-flannel-ds created
    ```

    Both nodes should change to Ready status now. 

    ```bash
    controlplane ~ ➜  k get no
    NAME           STATUS   ROLES           AGE     VERSION
    controlplane   Ready    control-plane   6m27s   v1.27.0
    node01         Ready    <none>          3m25s   v1.27.0  
    ```
    
    </details>
    </br>




[Back to the top](#practice-test-cka)    
