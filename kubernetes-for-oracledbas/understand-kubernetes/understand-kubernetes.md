# Understanding Microservices and Kubernetes

## Introduction

In this lab, we will review the basics of the Microservices Architecture and Kubernetes Infrastructure.

*Estimated Lab Time:* 10 minutes

### Objectives

* Understand the Microservices Architecture
* Understand the Kubernetes Infrastructure

## Task 1: What are Microservices?

Imagine yourself in the role of a DBA for a new micro-brewery named "Query Brews."  It is a small-scale operation featuring a single standout beer known as the "Drop Cascade IPA," but your responsibilities as the DBA will be significant. You have been entrusted with designing and supporting the database that will:

* Record ingredient inventory.
* Manage the brewing process.
* Track the available stock for sale.

Given the size and sole beer offering, you choose a straightforward and efficient approach by implementing a single schema design, enabling **seamless data access** and **streamlined querying** with **minimal complexity**.

After a highly successful year, a range of fresh new beers, such as the "SQL Saison" and "OLAP Porter," were meticulously crafted to expand the brewery's offerings.  However, these additions required modifications to the current single schema objects.

It became apparent that modifying the schema was not only challenging, but also **prone to errors** and **disruptive** to the different operations the database supported.  In response, you made the strategic decision to segregate the inventory, brewing, and stock objects into dedicated schemas, ensuring **greater organisation** while **minimising potential disruptions** between the different operations.

![Schema Progression](images/schema_ms.png "Schema Progression")

As the brewery's reputation soared, the workforce expanded to include dedicated inventory and stock/e-commerce personnel, as well as new brewers.  Each team member brought valuable insights for enhancing their respective domains, necessitating adjustments to both the front-end application and the backend database schemas.  Simultaneously, the responsibility of upholding the database's performance and stability rested on your shoulders, requiring occasional upgrades, patches, and handling of planned outages.  However, **obtaining consensus for modifications** to the applications and **coordinating maintenance tasks** proved to be an insurmountable challenge.

To alleviate the administrative overhead associated with **change coordination**, a resolution was reached to divide the infrastructure.  Each team was allocated its own dedicated database and application tier, granting them the freedom to **progress at their own pace** without impeding the progress or disrupting the other teams.

![Database Progression](images/db_ms.png "Database Progression")

By initially dividing the schema and subsequently breaking down the architectural components by operation, including the database, into smaller, more manageable services capable of independent deployment and scalability, you have naturally embraced the concept of *Microservices*!

## Task 2: What is Kubernetes?

Query Brews has evolved into a national success with "Relational Red Ale" being voted the Countries Favourite!  Brews are being produced round-the-clock and the online store is getting tens-of-thousands hits per day.  Resources have been **over-allocated** to handle the peaks of the system and **additional hardware** has been purchased to implement High-Availability/Disaster Recovery to avoid outages.

In general, everything is now running smoothly, but there is a **significant administrative burden** when it comes to upgrades and patching.  These tasks need to be carefully executed in a co-ordinated, rolling manner to prevent any service disruptions or outages.  Additionally, it is evident that there is a substantial amount of **computing resources being underutilised** to accommodate sales and production peaks, while the inventory system remains largely inactive except overnight when the batch processing is taking place.

The IT department, including yourself, have been asked to reassess the infrastructure and explore possibilities for restructuring to address these problems.  Your colleagues are quick to suggest *Kubernetes*, an **orchestration** platform that **automates the deployment, scaling, and management** of your application Microservices as containers.

Utilising Kubernetes at the brewery would simplify the management of the existing infrastructure and potentially allow you to consolidate it.  It will also enable developers to focus on building and deploying their applications without worrying about the underlying infrastructure.  Finally, it enable efficient application deployment, scaling, and automated management.

## Task 4: Why Kubernetes?

You have already addressed a number of operational issues at Query Brews by embracing the Microservices Architecture.  However, there are a number of infrastructure issues that have come to the surface that also need some attention.  Lets take a quick look at a few of these and explore why your colleagues have suggested Kubernetes:

![K8s](images/k8s.png)

### Resource Optimisation and Scalability

Beer production stops on Wednesdays and Thursdays, giving the brewers a well needed break, with the focus shifting to online sales and stock.  This switch has a direct impact on the infrastructure as there is, understandably, a massive spike in the online web application and stock database on these weekend preparation days.  Instead of over-allocating resources to handle peaks, ideally it would be great to re-allocate resources and scale the applications up or down when needed.

With Kubernetes, you can efficiently allocate and manage resources. It intelligently schedules and balances services across the cluster, maximising resource utilisation and performance.  It also provides built-in scaling features.  Kubernetes allows you to easily increase or decrease the resources of your application based on demand, ensuring optimal resource utilisation and responsiveness.

### High Availability

A lot of infrastructure was put into place to ensure High Availability at Query Brews.  Each microservices has a number of application and database servers dedicated to them should node failures occur.  Unfortunately, due to their hardware isolation, just like with the resources, none of them can take advantage of the others hardware should multiple failures occur.

Kubernetes provides built-in mechanisms for high availability. It automatically restarts failed containers or reschedules them on other healthy nodes, minimising downtime and ensuring uninterrupted service availability while still maintaining isolation.  Combined this with the Resource Optimisation and Scalability features, the existing hardware can be consolidated.

### Hybrid or Multi-Cloud Deployments

As Query Brews continues to experience success, it may become more cost-effective for them to consider transitioning some of their services to the cloud instead of investing in additional hardware and expanding the data centre.

Kubernetes supports hybrid or multi-cloud deployments. It provides portability and flexibility, allowing consistent management of applications across different environments, whether on-premises or across multiple cloud providers... Run the applications in the Cloud with the database on-premises, the options are endless.

## Task 3: Explore Kubernetes Components

Kubernetes appears to be a promising solution for addressing the infrastructure challenges faced by Query Brews. Although you may have never been exposed to Kubernetes, as an experienced Oracle DBA with knowledge of Oracle Real Application Clusters (**RAC**), you can leverage your familiarity with the concepts of distributed computing environments.  Drawing parallels between the two clustering technologies can help flatten the learning curve and ease the transition to Kubernetes.

Lets see how Kubernetes (**K8s**) Compares to an Oracle RAC running on Grid Infrastructure (**GI**).

![GI vs K8s](images/gi_k8s.png "GI vs K8s")

### *User Interface* - Kubectl and SRVCTL

<details>
When managing a RAC Cluster, such as creating, starting, stopping, or deleting cluster resources, your go-to CLI tool is SRVCTL (or CRSCTL if you're feeling brave).  A similar CLI tool is used for managing a K8s cluster, kubectl.

Kubectl allows you to interact with the K8s API server and perform various operations such as deploying applications, managing pods, services, and scaling resources.  It operates at the container and cluster level, allowing management of pods, deployments, services, replica sets, and other Kubernetes-specific resources.

You will be using Kubectl throughout the workshop to interact with the K8s Cluster.
</details>

### *Control Plane*

<details>
Similar to the Clusterware stack in Oracle GI, the *Control Plane* in K8s plays a crucial role as the central point in managing and controlling cluster operations.  Both the GI Clusterware Stack and the K8s *Control Plane* are composed of multiple components that work together to provide essential services and functionalities such as high availability, scalability, and extensibility.

The K8s *Control Plane* consists of the following components:

* API Server: The API server exposes the Kubernetes API, which allows users, via kubectl, and other components to interact with the cluster.  It handles API requests, authentication, and authorisation.
* Scheduler: The scheduler assigns pods to available nodes based on resource requirements, constraints, and other policies.
* Controller Manager: The controller manager runs various controllers that handle cluster-wide functions such as node management, pod replication, and service discovery.
* etcd: etcd is a distributed key-value store used by Kubernetes to store cluster configuration data, including the state of the cluster, configuration settings, and metadata.

### *etcd* and OCR

Oracle Cluster Registry (OCR) and etcd are both distributed key-value stores which maintain cluster state and configuration in their respective systems.

OCR stores cluster configuration information, resource dependencies, and policies in a distributed manner.  It ensures consistency and synchronisation of cluster state across multiple nodes.

Similarly, etcd stores critical cluster information, including configuration data, service discovery, and coordination among cluster nodes.  etcd provides a reliable and distributed data store that allows consistent data access and coordination among the nodes in the cluster.

Just as in GI and the OCR, it is highly recommended to regularly backup the etcd data.

### *API Server* and CSSD

Both the Oracle Cluster Synchronisation Services Daemon (CSSD) and Kubernetes API Server provide an interface for managing and controlling cluster operations, handle coordination among cluster nodes, and facilitate communication between various components in the cluster.

The Kubernetes API Server accepts API requests from users, administrators, and other components, processing and executing them to manage the cluster's state and resources.  Similarly, the Oracle CSSD in Oracle Clusterware handles cluster synchronisation, coordinates actions among cluster nodes, and ensures consistent communication and control throughout the cluster.
</details>

### *Nodes* - Worker and RAC

<details>
A worker node is one of the key components that make up a Kubernetes cluster.  A worker node, just like a RAC node, is a physical or virtual machine.  It runs the containerised workloads orchestrated by Kubernetes similarly to a RAC node running a database instance.  Worker Nodes consists of several key components, including the container runtime (such as Docker), kubelet, and optional features like the kube-proxy.

The worker node is responsible for executing and managing containers, as well as communicating with the control plane components of Kubernetes.

### *Kubelet* and CRSD

The Kubelet and the Cluster Ready Services Daemon (CRSD) operate at the node level and are responsible for managing and controlling resources on individual cluster nodes.  They both have built-in monitoring capabilities to detect failures and ensure the cluster, as well as its resources, remain highly available.

### *Kube-Proxy*, *Services* and Listeners

Kube-Proxy and Services provide the network abstraction and stable endpoints for accessing Microservices in a K8s cluster.  Kube-Proxy operates at the Node Level, just as Local Listeners do, while Services operate at the "Namespace" level and are similar to the SCAN Listener.  They all contribute to achieving high availability, load balancing, and routing.
</details>

### *Namespaces*

<details>
One distinct advantage to a K8s cluster that is not available in Grid Infrastructure clusters is the Namespace.  A Namespace is virtual clusters within the physical cluster and is used to create logical partitions and separate resources. They provide isolation, resource allocation, and security boundaries for applications running in the cluster.

Consider when having to consolidate multiple databases onto the same cluster.  Isolation is difficult to achieve.  Sure you can implement strategies, such as instance caging, to address resource limits, but physical access to the database host brings challenges, especially with security boundaries and administrators.  Namespaces address these challenges in a K8s cluster and in the case of a database, you could have the Inventory, Brewing, and Stock databases all running in the same physcial cluster, in separate Namespaces to provide complete operational separation.
</details>

### *Containers and Pods*

<details>
Containerisation involves encapsulating an application, along with its dependencies and runtime environment, into a self-contained unit that can be executed consistently across different computing environments.

Let's consider a RAC node as an illustration for a container. Envision the ability to bundle the OS, GI, ORACLE_HOMEs, TNS_ADMIN, along with all the necessary patches into a single, installable package.  You would then be able to effortlessly deploy it to either expand an existing cluster or establish a new one.  The time, effort, and potential for errors that could be eliminated would be substantial.

A pod can be thought of as a logical host for containers, where each container within the pod shares the same IP address and port space. Containers within the same pod can communicate with each other using localhost, making it easier to build and manage interconnected applications.

A Pod would be the equivalent of a "shared database server", where multiple databases, independent of each other run on the same host.
</details>

## Task 4: Summarise

Initially, when Query Brews began with its single beer offering, both the business and its supporting IT infrastructure were straightforward and manageable. At that point, adopting a Microservices Architecture and Kubernetes Infrastructure would have been excessive and unnecessary. However, as the business expanded, it became evident that adjustments were necessary to enable IT to scale alongside it.

Microservices and Kubernetes are powerful tools and architectural approaches that would bring numerous benefits to Query Brews. However, whether they are the right choice depends on various factors and considerations.

Here are some advantages and disadvantages to keep in mind:

### Advantages

* **Flexibility and Agility**: Microservices with Kubernetes promotes flexibility as each service can be developed, deployed, and updated independently.  This allows for faster development cycles and allows for developers to easily adapt to changing requirements.

* **Scalability**: Microservices architecture allows for independent scaling of individual services based on their specific needs.  Kubernetes automates the scaling and distribution of the microservices within the cluster, ensuring efficient resource utilisation and cost efficiency.

* **Fault Isolation**: With microservices, if one service fails or experiences issues, it does not affect the entire system and Kubernetes self-healing/fault tolerance features enables this seamlessly.

* **Team Autonomy**: Microservices architecture and Kubernetes infrastructure enables different teams to work independently on different services.  This autonomy allows teams to choose the most efficient development processes and deployment strategies for their specific service.

* **Continuous Deployment and DevOps**: Microservices are well-suited for continuous deployment and DevOps practices.  Since services can be deployed independently, updates and bug fixes can be rolled out more frequently, enabling faster delivery of new features.  Kubernetes can be used to orchestrate the rollouts.

### Disadvantages

* **Learning Curve**: Adopting microservices requires a shift in mindset and skill set for both development teams and operational teams.  Understanding and implementing the principles and best practices of microservices architecture may involve a learning curve.  Kubernetes, even for those familiar with related technologies, has its own set of tools, concepts, and terminologies that need to be understood.

* **Increased Complexity**: Microservices and Kubernetes introduce additional complexity due to the distributed nature of the architecture.  Managing inter-service communication, data consistency, and service discovery can be challenging.

* **Distributed System Challenges**: Effective communication between services is essential, but it can also introduce challenges such as latency, network failures, and longer response times. Therefore, it becomes imperative to establish resilient and robust communication mechanisms to mitigate these issues.

* **Service Coordination**: In scenarios where multiple services need to work together to accomplish a task, coordinating and managing the flow of data and transactions across services can be complex and require careful design.

## Learn More

* [Oracle Container Engine for Kubernetes (OKE)](https://www.oracle.com/uk/cloud/cloud-native/container-engine-kubernetes/)
* [Kubernetes](https://kubernetes.io/)

## Acknowledgements

* **Author** - John Lathouwers, Developer Advocate, Database Development Operations
* **Last Updated By/Date** - John Lathouwers, May 2023
