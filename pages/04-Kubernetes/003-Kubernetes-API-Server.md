# Kubernetes API Server

This is the main way to interact with the cluster. It is a RESTful API that runs over HTTP or HTTPS using JSON. 

- composed of **API Objects**, which are a collection of primitives to represent your system's state

- Enables to declaratively configuring the state, which means we define what we want the end result to look like instead of defining the individual steps.

- information exchanged with the cluster are persisted and serialized to the data store