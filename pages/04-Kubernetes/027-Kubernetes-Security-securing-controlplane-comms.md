
# Securing Control Plane Communications with Ciphers 


- [Ciphers](#ciphers)
- [Kubernetes Control Plane](#kubernetes-control-plane)
- [Sample Scenario](#sample-scenario)


## Ciphers 

TLS works by use of Public Key Encryption, and the encryption is performed by cryptographic mathematical algorithms known as ciphers. Mathematicians discover new ciphers from time to time that are more secure than their predecessors.

Each time a new cipher is discovered, it has to work its way into general usage, that is, that the software libraries that implement encryption need to be updated with the new cipher, whilst remaining compatible with the existing well-known ciphers.

These updates have to find their way into all software that makes use of HTTPS (TLS) protocols including, but not limited to:

- Browsers
- Web clients (e.g. curl, wget)
- Web servers (e.g. IIS, nginx, apache etc)
- Layer 7 appliances (e.g. AWS Application Load Balancer, Web Application Firewalls)
- Kubernetes components (API server, controller manager, kubelet, scheduler)
- etcd

When a TLS connection is established, the cipher to use is negotiated between the two ends, and usually the strongest possible cipher that both ends know is selected. The ciphers available to each end of the connection depend on how old that software is, and thus which ciphers are known to it.

Most TLS aware software packages, and for the purpose of CKS, this includes all the control plane components and etcd, have the ability to limit which ciphers should be available for negotiation when a connection is being established. Limiting the available ciphers to the newer (stronger) ones prevents older clients that do not have the newer ciphers from establishing a connection which may be able to be compromised due to use of an older (weaker) cipher for which a known exploit is available.


## Kubernetes Control Plane

All the control plane components (API server, controller manager, kubelet, scheduler) have the following two optional arguments:

- <code>--tls-min-version</code> – This argument sets the minimum version of TLS that may be used during connection negotiation. Possible values      
    
    - <code>VersionTLS10</code> (default)
    - <code>VersionTLS11</code>
    - <code>VersionTLS12</code>
    - <code>VersionTLS13</code>

- <code>--tls-cipher-suites</code> – This argument sets a comma-separated list of cipher suites that may be used during connection negotiation. There are many of these, and the full list may be found on the api server argument page. If this argument is omitted, the default value is the list provided by the GoLang cipher suites package.


<code>etcd</code> also has a command line argument to set cipher suites. Thus it is possible to secure api server → etcd communication to use only specific ciphers that they have in common. You would most likely want to select the newest/strongest.

- <code>--cipher-suites</code> – This argument sets a comma-separated list of cipher suites that may be used during connection negotiation. If this argument is omitted, the default value is the list provided by the GoLang cipher suites package.

Be aware that not all combinations of cipher suites and TLS versions are compatible with each other. If you set --tls-min-version to VersionTLS13, there will be certain ciphers that can’t be used so explicitly specifying an incompatible cipher with --tls-cipher-suites would cause API server to not come back up.

## Sample Scenario 

Restrict communication between etcd and api server. Use the following:

- **cipher**: TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
- **TLS version**: TLS 1.2

Solution:

- Edit the API server manifest and add the following two arguments:

    ```bash
    --tls-min-version=VersionTLS12
    --tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
    ```

- Edit the etcd manifest and add the following argument.

    ```bash
    --cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256  
    ```

- Wait for both pods to restart. This may take a minute or more.




<br>

[Back to first page](../../README.md#kubernetes-security)
