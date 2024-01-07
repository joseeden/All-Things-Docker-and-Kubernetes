
# Helm Chart and Templates

- [Helm Chart](#helm-chart)
- [Helm Chart Starting Directory Structure](#helm-chart-starting-directory-structure)
- [Packaging the Chart](#packaging-the-chart) 
- [Sharing the Chart](#sharing-the-chart)
- [Hosting the Chart](#hosting-the-chart)

## Helm Chart 

A Helm chart is simply a collection of templates plus a couple of extra metadata and default config value files which represents an application to be deployed.

Some charts are designed to deploy a single application or service, whereas others can be much more complex, designed to deploy a full application stack consisting of multiple microservices, web servers, databases, and so on.

## Helm Chart Starting Directory Structure

To build a chart, you can run the command:

```bash
helm create <chart-name 
```

This will then create a directory structure for you.

```bash
└── app-tier
    ├── Chart.yml
    ├── charts
    ├── templates
    │   ├── NOTES.txt
    │   ├── _helpers.tpl
    │   ├── deployment.yml
    │   ├── hpa.yaml 
    │   ├── ingress.yaml
    │   ├── service.yaml
    │   ├── serviceaccount.yaml 
    │   └── tests
    │       └── test-connection.yaml
    └── values.yaml
```

The **Chart.yaml** contains top-level metadata which explains the purpose of the chart. This includes the name and other details of the chart.

- **type: application**
When "type" is set to "application", chart becomes deployable and resources are created within the cluster.

- **type: library**
When "type" is set to "library", the chart will host reusable functions that can be used with other charts

```bash
apiVersion: v2
name: sample-app 
description: Custom chart of sample app 
type: application
version: 1.1.0 
appVersion: 1.0.3
```

The **charts** folder contains other charts that the current chart depends on. These nested charts that are deployed into the cluster.

The **templates** folder is where all the template files are stored together. Each template file usually define a single resource for the cluster. Thus you can have a template dedicated for the deployment and another template for the service account.

The **values.yaml** defines a structured list of default values that are injected onto the chart templates that reference them during deployment. They are declared in a YAML format. 

```bash
replicaCount: 1

image:
    repositoryL nginx
    pullPolicy: IfNotPresent 

serviceAccount:
    name: "app-svc"
    create: true 
    annotations: {}

service:
    type: ClusterIP 
    port: 80 
```

Note that these default values can be overwritten when you run "helm upgrade" commands along with required parameters. In the example below, we're changing the service port from 80 to 8081.

```bash
helm upgrade sample-app ./app-tier --set=service.port=8081 
```

## Packaging the Chart 

Once you're done with the development of the chart, you can now package it by running:

```bash
helm package <chart-directory> 
```

Going back to the directory structure that we used previously, we can package the entire directory and label it as "app-tier" as it is the top-level directory that contains the chart.

```bash
└── app-tier
    ├── Chart.yml
    ├── charts
    ├── templates
    │   ├── NOTES.txt
    │   ├── _helpers.tpl
    │   ├── deployment.yml
    │   ├── hpa.yaml 
    │   ├── ingress.yaml
    │   ├── service.yaml
    │   ├── serviceaccount.yaml 
    │   └── tests
    │       └── test-connection.yaml
    └── values.yaml
```

To package this chart, we can run:

```bash
helm package app-tier 
```

This will then produce an archive file that used the name and version defined in the **Chart.yaml** file:

```bash
apiVersion: v2
name: sample-app 
description: Custom chart of sample app 
type: application
version: 1.1.0 
appVersion: 1.0.3
```

Thus the archive file will be named:

```bash
sample-app-1.1.0.tgz 
```

## Sharing the Chart 

This archive file can then be shared with anyone. They can be installed simply by running: 

```bash
helm install <package-name> <chart>
```

In our case:

```bash
helm install app-tier sample-app-1.1.0.tgz 
```

To perform a dry-run installation:

```bash
helm install app-tier sample-app-1.1.0.tgz --dry-run
```

## Hosting the Chart 

We can also host the chart in a chart repository by creating an index chart file:

```bash
helm repo index .  
```

This command will perform a recursive directory scan within the provided directory and search for any archive files. Discovered archive files are then written on an **index.yaml** which can be used when searching the repo, as shown below:

```bash
helm search repo app-tier 
```



<br>

[Back to first page](../../README.md#helm)
