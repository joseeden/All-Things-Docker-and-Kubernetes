
# ConfigMaps and Secrets 



## ConfigMaps 

ConfigMaps are a type of Kubernetes Resource that is used to decouple configuration artifacts from container image content to keep containerized applications portable. The configuration data is stored as key-value pairs.  

- data is stored in key-value pairs
- pods reference ConfigMaps and secrets to use their data
- can be mounted as volumes or set as environment variables

ConfigMaps can be created from:

- Environment variable files consisting of key-value pairs separated by equal signs
- Regular files or directories of files result in keys that are the names of the files and values that are the contents of the files.
- Literals consisting of individual key-value pairs that you specify on the command line.
- Writing a YAML manifest file of kind: **ConfigMap**.

Like most Kubernetes Resources, ConfigMaps are namespaced so only Pods in the same Namespace as a ConfigMap can use the ConfigMap.

## Secrets

Similar to ConfigMaps, Secrets are also custom resources which can be stored separately instead of including them in the specs file. The main difference between these two custom resources is that secrets are specifically useed for storing sensitive information. Secrets reduce the risk of accidental exposure compared to if they were stored in an image or put in a Pod specification. 

In addition to this, secrets supports the following:

- storing secrets as key-value paris, and
- **specialized support** for storing Docker registry credentials and TLS certs.

It is important to note that secrets are not encrypted at rest by default and are instead only base-64 encoded. However, Kubernetes can separately control access to ConfigMaps and Secrets. So by following the pattern of storing sensitive data in Secrets, users of the cluster can be denied access to Secrets but granted access to ConfigMaps using Kubernetes access control mechanisms.


To see ConfigMaps and Secrets in actions check out this [lab](../../lab49_ConfigMaps_and_Secrets/README.md).
