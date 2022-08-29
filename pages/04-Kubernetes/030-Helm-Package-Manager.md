# Helm 

- [What is Helm](#what-is-helm)
- [Concepts](#concepts)
- [Helm 2 vs. Helm 3](#helm-2-vs-helm-3)
- [Components](#components)
- [Setting up Helm](#setting-up-helm)
    - [Install Helm](#install-helm)
    - [Initialize a Repository](#initialize-a-repository)
    - [Deploy a Sample Chart](#deploy-a-sample-chart)
    - [Delete the Chart](#delete-the-chart)


## What is Helm 

**Helm** is the Kubernetes package manager which helps package installation in Kubernetes and manages package dependencies. 

To learn more, visit the official [Helm website.](https://helm.sh/)

## Concepts 

- **Chart** - contains all the dependencies to deploy a Kubernetes cluster
- **Config** - optional configs to override default configs
- **Release** - a running instance of a chart

## Helm 2 vs. Helm 3 

There is a new Helm 3 version, which differs with Helm 2.

- Helm 2 architecture is different
- Helm 2 command line and chart structure might differ 
- Helm 2 charts are compatible with Helm 3

## Components

- **Helm Client** - CLI client for managing repositories, releases, and interfacing with Helm library

- **Helm Library** - responsible for Helm operations towards the API Server.

## Setting up Helm 

Helm can be installed either from a source, or from pre-built binary releases. The steps for setting up Helm.

- [Install Helm](https://helm.sh/docs/intro/install/) 

- [Initialize a Helm Chart Repository](https://helm.sh/docs/intro/quickstart/#initialize-a-helm-chart-repository)


### Install Helm 

If you're using a Windows Machine with WSL2 that's running Ubuntu, you can simply run these commands:

```bash
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

$ chmod 700 get_helm.sh

$ ./get_helm.sh
```

### Initialize a Repository

Next, add a repository. Note that starting with Helm v3, there are no repositories installed by default. We can also add other repositories.

In the command below, we named the repo "stable".

```bash
$ helm repo add stable https://charts.helm.sh/stable 
```

Let's try to add another repo and give it the name "bitnami"

```bash
$ helm repo add bitnami https://charts.bitnami.com/bitnami 
```

To check the repositories added,

```bash
$ helm repo list 
```

It's best practice to fetch the latest updates from the repo.

```bash
$ helm repo update 
```

We can take a look at all the charts contained in the repository.

```bash
$ helm search repo 
```

### Deploy a Sample Chart 

Let's try to install a redis chart and name it "my-test-redis1

```bash
$ helm install my-test-redis1 bitnami/redis 
```

Verify that the pods are running.

```bash
$ kubectl get pods 
```

To get a list of deployed charts,

```bash
$ helm ls 
```

### Delete the Chart 

Run the uninstall command and specify the chart name.

```bash
$ helm uninstall my-test-1 
```

</details>

