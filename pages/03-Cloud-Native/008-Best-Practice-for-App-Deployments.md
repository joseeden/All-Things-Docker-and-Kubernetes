
# Best Practices for Application Deployments

<p align=center>
<img src="../../Images/udacity-suse-2-bestpractices.png">
</p>

The appropriate model has been decided and we've carefully reviewed the requirements against the monoliths vs. microservices, so what's next? Implementation.

It is essential to understand best practices and follow them during the release and maintenance phases when building solution. Of course, there is no one-size-fits-all strategy and each organization works differently, but knowin these best practices ensures we have resiliency and high availability.

## Health Checks

Refers to the status of the application and ensuring the expected behavior to take on the traffic is met. 
- normally HTTP endpoints such as <code>/health</code> or <code>status</code>
- returns HTTP response codes to let you know if the application is healthy.

## Metrics

Measures the performance of an application.
- include statistics collected on the services 
- number of logins, number of active users, number of requests handled, CPU utilization, memory, etc.
- usually  returned via an HTTP endpoint such as <code>/metrics</code>.

## Logs

Logs aggregation provides significant insights on the application's operation on a particular timeframe
- like metrics, Logs are extremely useful in troubleshooting
- used for debugging application issues. 
- usually collected through *standard out*(STDOUT) or *standard error* (STDERR) 
- collected through a passive logging mechanism and then sent to the shell
- can be collected through logging tools such as Splunk and stored at the backend
- can also go directly to the backend storage without a monitoring tool by using *active logging*.
- common practice to associate each log line with a **timestamp**, that will exactly record when an operation was invoked

| **Logging Levels** | Meaning |
|---|---|
| **DEBUG** | record fine-grained events of application processes |
| **INFO** | provide coarse-grained information about an operation 
| **WARN** | records a potential issue with the service
| **ERROR** | notifies an error has been encountered, however, the application is still running
| **FATAL** | represents a critical situation, when the application is not operational |


## Tracing

Helpful for understanding the full journey of a request.
- includes all the invoked functions
- usually integrated through a library
- can be utilized by the developer to record each time a service is invoked. 
- records for individual services are defined as spans
- A collection of spans define a trace that recreates the entire lifecycle of a request.

## Resource Consumption

Refers to how much resources an application uses to perform its operations.
- usually CPU, memory, network throughput, and number of concurrent requests.



<br>

[Back to first page](../../README.md#cloud-native)