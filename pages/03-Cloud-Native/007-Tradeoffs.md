
# Tradeoffs

Depending on which model we choose, each one will have their own set of tradeoffs:

 Tradeoffs | Description | Monoliths | Microservices
---------|----------|---------|---------
**Development Complexity** | Effort required to deploy and manage an application. | <ul><li>one programming language</li><li>one repository</li><li>enables sequential development </li></ul> | <ul><li>multiple programming languages</li><li>multiple repositories</li><li>enables concurrent development </li></ul> |
**Scalability**  | Scaling up or down, based on the incoming traffic. | <ul><li>entire stack is replicated</li><li>heavy on resource consumption</li></ul> | <ul><li>single unit is replicated</li><li>on-demand consumption of resources</li></ul> |
**Time to deploy** | Time to deploy encapsulates the build of a delivery pipeline that is used to ship features. | <ul><li>one delivery pipeline that deploys the entire stack</li><li>more risk with each deployment leading to a lower velocity rate</li></ul> | <ul><li>multiple delivery pipelines that deploy separate units</li><li>less risk with each deployment leading to a higher feature development rate</li></ul> |
**Flexibility** | Ability to adapt to new technologies and introduce new functionalities. | <ul><li>low rate</li><li>entire application stack might need restructuring to incorporate new functionalities</li></ul> | <ul><li>high rate</li><li>since changing an independent unit is straightforward</li></ul> |
**Operational Cost** | Represents the cost of necessary resources to release a product. | <ul><li>low initial cost</li><li>one code base and one pipeline should be managed</li><li>cost increases exponentially when the application needs to operate at scale</li></ul> | <ul><li>high initial cost</li><li>multiple repositories and pipelines require management</li><li>to scale, the cost remains proportional to the consumed resources at that point in time</li></ul>
**Reliability** | Reliability captures practices for an application to recover from failure and tools to monitor an application.| <ul><li>in a failure scenario, the entire stack needs to be recovered</li><li>the visibility into each functionality is low, since all the logs and metrics are aggregated together</li></ul> | <ul><li>in a failure scenario, only the failed unit needs to be recovered</li><li>there is high visibility into the logs and metrics for each unit</li></ul>


<br>

[Back to first page](../../README.md##cloud-native)
