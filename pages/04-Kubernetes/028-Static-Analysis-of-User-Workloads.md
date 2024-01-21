
# Static Analysis of User Workloads


- [Static Analysis](#static-analysis)
- [Enforcing Policies Earlier](#enforcing-policies-earlier)
- [Available Tools](#available-tools)
- [Kubesec](#kubesec)
    - [Installation](#installation)
    - [Scan using kubesec](#scan-using-kubesec)


## Static Analysis 

Static analysis of user workloads in Kubernetes involves examining the configuration and specifications of deployed resources without actually running them. 

This analysis aims to identify potential issues, security vulnerabilities, or misconfigurations in the Kubernetes manifests before the workloads are deployed or during the CI/CD pipeline. 

Static analysis is an essential part of ensuring the reliability, security, and best practices adherence of Kubernetes workloads.

## Enforcing Policies Earlier 

In its core, Static Analysis is all about reviewing the resource files and enfoce policies earlier in the development cycle before it is actually pushed to the cluster 

## Available Tools 

Several tools can be used for static analysis and validation of Kubernetes manifests to ensure adherence to best practices, security, and correctness. 

1. **kube-score**
   - kube-score is a lightweight tool that performs static code analysis of Kubernetes YAML files. It provides a score based on best practices, security, and reliability.
   - To learn more, check out [kube-score](https://github.com/zegl/kube-score)

2. **kube-linter**
   - kube-linter is a static analysis tool for Kubernetes YAML files. It checks for security issues, best practices, and other common pitfalls in your manifests.
   - To learn more, check out [kube-linter](https://github.com/stackrox/kube-linter)

3. **kubeval**
   - kubeval is a command-line tool for validating Kubernetes YAML files against the Kubernetes schemas. It checks for syntax errors and validates the structure of your manifests.
   - To learn more, check out [kubeval](https://github.com/instrumenta/kubeval)

4. **Kubernetes Policy Controller**
   - Kubernetes Policy Controller is an Open Policy Agent (OPA) based policy engine for Kubernetes. It allows you to define and enforce policies on your Kubernetes resources.
   - To learn more, check out [Kubernetes Policy Controller](https://github.com/open-policy-agent/gatekeeper)

5. **kube-bench**
   - kube-bench is a tool that checks whether Kubernetes is deployed securely by running the checks documented in the CIS Kubernetes Benchmark.
   - To learn more, check out [kube-bench](https://github.com/aquasecurity/kube-bench)

6. **kube-hunter**
   - kube-hunter is a security tool that actively scans for security issues in Kubernetes clusters. It can be used for penetration testing and identifying vulnerabilities.
   - To learn more, check out [kube-hunter](https://github.com/aquasecurity/kube-hunter)

7. **Conftest**
   - Conftest is a tool for writing tests against structured configuration data. It can be used to validate Kubernetes manifests against policies defined in Rego (Open Policy Agent language).
   - To learn more, check out [Conftest](https://github.com/open-policy-agent/conftest)

8. **kube-psp-advisor**
   - kube-psp-advisor is a tool that analyzes RBAC policies and provides recommendations for creating PodSecurityPolicy (PSP) in Kubernetes clusters.
   - To learn more, check out [kube-psp-advisor](https://github.com/sysdiglabs/kube-psp-advisor)

These tools can be integrated into your CI/CD pipelines or used as part of the development workflow to catch issues early in the deployment lifecycle.

## Kubesec 

Kubesec is another tool in the Kubernetes ecosystem that focuses on static analysis of Kubernetes manifests to identify security issues and misconfigurations before deploying applications. It assesses the security posture of Kubernetes resources by analyzing the configurations in the manifest files.

- It looks for potential issues and advises on how to improve the security of the configurations. 

- Kubesec provides detailed advisories for detected security issues, offering guidance on how to address each problem.

- Kubesec can be integrated into CI/CD pipelines to automatically scan Kubernetes manifests as part of the continuous integration process. 

- Kubesec provides a JSON output option, which allows for easier integration with automation scripts and tools.

To learn more, check out [kubesec.io.](https://kubesec.io/)

### Installation 

- Docker container image at [docker.io/kubesec/kubesec:v2](https://hub.docker.com/r/kubesec/kubesec/tags)
- Linux/MacOS/Win binary (get the [latest release](https://github.com/controlplaneio/kubesec/releases))
- [Kubernetes Admission Controller](https://github.com/stefanprodan/kubesec-webhook)
- [Kubectl plugin](https://github.com/stefanprodan/kubectl-kubesec)

### Scan using kubesec 

To run kubesec:

```bash
kubesec scan pod.yaml 
```

Another option is through a POST request.

```bash
curl -sSX POST --data-binary @"pod.yaml" https://v2.kubesec.io/scan
```

Kubesec can also be ran as a server locally:

```bash
kubesec http 8080 & 
```

<br>

[Back to first page](../../README.md#kubernetes-security)
