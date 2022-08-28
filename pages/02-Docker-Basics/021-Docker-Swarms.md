
# Docker Swarms

- [What is a Swarm](#what-is-a-swarm)
- [Types of Nodes](#types-of-nodes)
- [Creating a Swarm](#creating-a-swarm)
- [Locking a Node](#locking-a-node)
- [Creating Services](#creating-services)


----------------------------------------------

## What is a Swarm 

A **swarm** is a cluster of nodes that work together. This is DOcker's official orchestration system and is similar with Kubernetes.

- provides an API
- uses services instead of running containers individually

A swarm encrypts these services by default:

    - distributed cluster store 
    - networks 
    - TLS
    - cluster joining tokens
    - PKI

## Types of Nodes 

**Manager Node**

- responsible for running the cluster
- cluster state
- schedules services
- receives API commands and converts them to actions 
- recommended to have "odd" number of nodes for HA 
- if you have "even" number of nodes (ex: 4 nodes), it's possible to have *split brain* issue
- maximum of 7 nodes 

**Worker Nodes**

- runs the containers
- needs at least 1 manager node 

To see all the nodes in your swarm:

```bash
$ docker node ls 
```

## Creating a Swarm 

Initialize on the first manager node:

```bash
$ docker swarm init \
    --advertise-addr <private-ip>:2377 \
    --listen-addr <private-ip>:2377
```

After initializing, create a token:

```bash
$ docker swarm join-token manager 
```

You can then use this token to join another manager node to the swarm.

To create a token for the worker nodes:

```bash
$ docker swarm join-token worker 
```

Use this token to join a node as a worker node to the swarm.

```bash
$ docker swarm join \
    --token <worker-node-token> \
    --advertise-addr <private-ip>:2377 \ 
    --listen-addr <private-ip>:2377
```


## Locking a Node 

Note that if a node goes down for some time and restarts, its data may be in conflict with the data in the swarm. To prevent this, enable locking to stops the restarted node from rejoining the swarm and require an administrator password first.

```bash
$ docker swarm init --autolock 
```
```bash
$ docker swarm update --autolock=true 
```

Note that is better to delete and recreate the node so that it gets the recent copy of the data.

## Creating Services 

Define the image to be used and then the service will run the container for you.

- also specify the desired state (replicas, etc.)
- *replicate mode* by default, containers are distributed evenly 
- *global mode*, a single replica on each node
- scaling up/down
