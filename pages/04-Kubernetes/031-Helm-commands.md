
# Helm Commands 


- [Helm Chart Management](#helm-chart-management)
- [Repository Management](#repository-management)
- [Release Management](#release-management)
- [Build Management](#build-management)

## Helm Chart Management

These commands can be used for basic Helm chart management. 

```bash
helm search hub <keyword> 
```
```bash
helm search repo <keyword>
```
```bash
helm pull <chart> 
```
```bash
helm install <name> <chart> 
```
```bash
helm upgrade <release> <chart>
```
```bash
helm rollback <release> <chart>
```
```bash
helm uninstall <release> 
```

## Repository Management

These commanDs are focused on managing the repositories.

```bash
helm repo add <name> <url>
```
```bash
helm repo list 
```
```bash
helm repo remove <name>
```
```bash
helm repo update 
```
```bash
helm repo indec <directory> 
```


## Release Management

These commands are focused on maintaining Helm releases.

```bash
helm status <release>  
```
```bash
helm list 
```
```bash
helm history <release>
```
```bash
helm get manifest <release>
```

## Build Management 

These are the commands you can use to build and manage your own Helm charts.

```bash
helm create <name> 
```
```bash
helm template <name> <chart>
```
```bash
helm package <chart> 
```
```bash
helm lint <chart> 
```


<br>

[Back to first page](../../README.md#helm)
