
# Kubernetes Ecosystem

- [Helm](#helm)
- [Kustomize.io](#kustomizeio)
- [Prometheus](#prometheus)
- [Kubeflow](#kubeflow)
- [Knative](#knative)

## Helm 

Helm is a package manager for Kuberentes. The packages are known as charts and can be installed using the Helm CLI.

- Helm charts contain all the resources for a package
- Helm charts make it easy to share complete applications
- Public charts can be found in hub.helm.sh

## Kustomize

Kustomize.io allows us to customize YAML manifest files and helps us to manage complexities of our applications:

- It can help manage environments and stages
- Uses **kustomization.yaml** that declares customization rules
- Original manifests are untouched and remain usable
- directly integrated with kubectl

Examples:

- Generating ConfigMaps and Secrets from files
- Configure common fields across multiple resources 
- Apply patches to any field in a manifest

## Prometheus 

Prometheus is an opensource monitoring and alerting system used for pulling in time-series metric data and storing it. 

- The de-facto standard in monitoring Kubernetes clusters.
- Each Kubernetes components has their own metrics in Prometheus format 
- Adapters that allows Kubernetes to get metrics from Prometheus
- Commonly paired with Grafana for visualizations and dashboards
- Allows you to define alert rules and notifications
- Can be installed using a Helm chart

## Kubeflow 

Kubeflow makes it simple to deploy machine learning workflows on Kubernetes. It is complete with machine learning models and how to deploy and serve them.

- Leverages autoscaling of Kubernetes
- Allow deploying anywhere

## Knative

Knative is platform for building, deploying, and managing serverless workloads on Kubernetes.

- Focus more on the code, instead of the underlying resources
- Can be deployed anywhere, avoiding vendor lock-in
- Supported by Google, IBM, and SAP



<br>

[Back to first page](../../README.md#kubernetes)
