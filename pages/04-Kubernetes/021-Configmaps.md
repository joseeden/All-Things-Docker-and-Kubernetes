
# ConfigMaps and Secrets 



## ConfigMaps 

ConfigMaps allows us to separate some custom configurations from Pod specs to make it easier to manage and makes more portable manifests.

- data is stored in key-value pairs
- pods reference ConfigMaps and secrets to use their data
- can be mounted as volumes or set as environment variables


## Secrets

Similar to ConfigMaps, Secrets are also custom resources which can be stored separately instead of including them in the specs file. The main difference between these two custom resources is that secrets are specifically useed for storing sensitive information. In addition to this, secrets have **specialized types** for storing Docker registry credentials and TLS certs.


To see probes in actions check out this [lab](../../lab49_ConfigMaps_and_Secrets/README.md).
