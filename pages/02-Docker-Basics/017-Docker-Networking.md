# Docker Networking


- [Container Network Model](#container-network-model)
- [Drivers](#driver)
- [Network Types](#network-types)
- [Overlay Networks](#overlay-networks)
- [VXLAN](#vxlan)

----------------------------------------------

## Container Network Model 

Docker follows the **Container Network Model** which breaks up networking into components:

- **Sandboxes** - containers running on the same Docker node won't be able to talk to each other

- **Endpoints** - virtual NICs created for each container

- **Networks** - creates a 'fake' network and attach the containers using the nedpoints

- **libnetwork** - made up of the 'control' and 'management' planes

## Driver

Drivers enable networking in containers. These are the available drivers in Linux:

- **bridge** - default driver, functions as a NAT

- **host** - allows container to access network stacj of the underlying node without NAT 

- **overlay** - creates networks that span multiple nodes, allowing secure, encrypted communication between containers 

- **macvlan** - allows attaching a container to internal LAN, container will have own IP, MAC, like any other device


To create a separate network:

```bash
docker network create -d driver <name> 
```

## Network Types

**Single-host Bridge Network**

- containers run on a single node
- uses bridge driver 

**Single-host Host Network**

- containers run on a single node 
- uses host driver
- bypasses network isolation, allowing container to access the node's network stack

**Multi-host Overlay Network**

- containers run on multiple nodes 
- virtual switch spans all the hosts (VXLAN)
- uses overlay driver 

**Existing Network**

- containers run on multiple nodes 
- can connect container to local network infrastructure
- does not work on public cloud (promiscuous mode)
- uses macvlan or transparent driver

## Overlay Networks

In an overlay network, we have containers running on multiple nodes.

- virtual switch that spans all the hosts (VXLAN)
- uses overlay driver
- sets the stage for "swarms"
- control plane is encrypted by default
- data plane can be encrypted using "-o encrypted"

To create an overlay network:

```bash
$ docker network create -d  overlay <name> 
```

To create services for swarms:

```bash
$ docker service create --name <name>  \
    --network <name> \
    --replicas 2 \ 
    <image>
```

## VXLAN 

Overlay networks uses VXLAN. The idea is to create a layer 2 network on top of layer 3.

- created as-needed on top of the existing L3 network 
- uses encapsulation to add VXLAN informaton to a L3 packet
- VXLAN Tunnel Endpoint (VTEP), tunnel is created between containers 