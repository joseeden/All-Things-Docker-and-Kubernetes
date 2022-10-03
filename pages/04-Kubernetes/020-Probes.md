
# Probes and Init Containers 


- [Probes](#probes)
- [Declaring Probes](#declaring-probes)
- [Init Containers](#init-containers)


## Probes

Kubernetes assumes that a Pod is ready as soon as the container is not started. However, containers may need time to warm up before it can cater to any incoming traffic.

It is also possible that a Pod is up and running but becomes unresponsive after some time. In this scenario, Kubernetes should not send traffic to these Pods and instead restart a new Pod.

In both scenarios, Kubernetes has a feature called **Probes** which allows us to run some health checks on the probes and monitor its state. Here are some types of probes:

**Readiness Probes** 
Checks if a Pod is ready to server traffic and handle requests.

- useful after startup to check external dependencies
- controls the "ready" condition of a Pod
- services must only send traffic to "Ready" Pods

**Liveness Probes**
Detects if a Pod enters a broken state where it can no longer serve traffic.

- Pod is restarted by Kubernetes
- declared in the same way as readiness probes

## Declaring Probes

Probes can be declared in a Pod's containers. This means that all container probes running in the Pod must pass before the Pod can pass.

Probe actions can be command that can be run in the container:

- HTTP GET requests,
- Opening TCP sockets, etc

Probes checks containers every 10 seconds by default.

To see probes in actions check out this [lab](../../lab46_Probes/README.md).


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

