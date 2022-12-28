
# Probes and Init Containers 



- [Probes](#probes)
    - [Readiness Probes](#readiness-probes)
    - [Liveness Probes](#liveness-probes)
    - [Startup Probes](#startup-probes)
- [Declaring Probes](#declaring-probes)
- [Init Containers](#init-containers)


## Probes

Kubernetes assumes that a Pod is ready as soon as the container is not started. However, containers may need time to warm up before it can cater to any incoming traffic.

It is also possible that a Pod is up and running but becomes unresponsive after some time. In this scenario, the running Pods may have etered an internal failed state such as a deadlock and Kubernetes should not send traffic to these Pods and instead restart a new Pod.

In both scenarios, Kubernetes has a feature called **Probes** which allows us to run some health checks on the probes and monitor its state. Here are some types of probes:

### Readiness Probes
Checks if a Pod is ready to server traffic and handle requests.

- useful after startup when large amounts of data are being loaded
- for checking external dependencies
- controls the "ready" condition of a Pod
- when Pod is accessed through a Service, the Service will not serve traffic to any Pods that have a failing readiness probe. 

### Liveness Probes
Detects if a Pod enters a broken state where it can no longer serve traffic.

- bugs can cause Pods to enter a broken state
- by detecting the state, Kubernetes can restart the Pod
- declared in the same way as readiness probes

### Startup Probes
Used when an application starts slowly and may otherwise be killed due to failed liveness probes

- runs before readiness and liveness probes
- can be configured with a startup time longer than the time needed to detect a broken state 

A container can define up to one of each type of probe. All probes are also configured the same way.

The main difference between the three is that Readiness and Liveness probes run for the entire lifetime of the container they are declared in, while Startng probes only run until they first succeed.

## Declaring Probes

Probes can be declared in a Pod's containers. This means that all container probes running in the Pod must pass before the Pod can pass.

Probe actions can be commands that can be run in the container. These actions can be used to assess the readiness of a Pod's containers:


Commands | Description | Output
---------|----------|---------
 exec | Issue a command in the container. | If the exit code is zero the container is a success, otherwise it is a failed probe.
 httpGet | Send and HTTP GET request to the container at a specified path and port. | If the HTTP response status code is a 2xx or 3xx then the container is a success, otherwise, it is a failure.
 tcpSocket | Attempt to open a socket to the container on a specified port. | If the connection cannot be established, the probe fails.

Probes checks containers every 10 seconds by default. The following threshold can also be configured:

- **successThreshold** - number of consecutive successes 
- **failureThreshold** - number of consecutive failures required to transition from success to failure
- **periodSeconds** - interval of the probe run 
- **timeoutSeconds** - each probe will wait for this value to complete

To see probes in actions check out this [lab](../../lab46_Probes/README.md).
To see monitoring and debugging in action check out this [lab](../../lab26_Monitoring/README.md)

## Init Containers

We've now learned how probes work and how we can use them to run health checks on containers inside a Pod. However, probes only kick in AFTER containers are started.

There will be scenarios where you need to perform some task right before the main application container even starts, like waiting for a pre-requisite service to be created, downloading files, or grabbing the dynamic ports assigned.

To do this, we can use **init containers** initialize the task before the main application starts. This allows us to delay or block the starting of an application if pre-conditions are not met.

- Pods can delare multiple init containers
- Init containers are ran in the order they are declared
- Init containers can use different images
- Previous init container must complete before the next can begin
- Once all init containers are complete, main application container can then start

Note that init containers are ran EVERY TIME a Pod is created. This means Init containers will also run if Pods are restarted.

To see init containers in actions check out this [lab](../../lab47_Init_Containers/README.md).

