# Understanding Kubernetes

## Introduction

In this lab, we will review the basics of Kubernetes.

*Estimated Lab Time:* 10 minutes

Watch the video below for a quick walk through of the lab.
[](youtube:zNKxJjkq0Pw)

### Objectives

* Understand the Kubernetes Infrastructure
* Get comfortable with Kubernetes Concepts

## Task 1: What are Kubernetes and Microservices?

Kubernetes is an open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications. It was originally developed by Google and is now maintained by the Cloud Native Computing Foundation (CNCF). Kubernetes provides a platform for managing and scaling distributed applications, making it easier to deploy and manage containerized applications.

Microservices, on the other hand, is an architectural approach to building software systems that are made up of small, independently deployable services. Each service focuses on a specific business capability and communicates with other services through well-defined APIs. Microservices architecture is designed to break down large, monolithic applications into smaller, more manageable services that can be deployed and scaled independently.

Kubernetes and Microservices are often used together because Kubernetes provides a platform for deploying, scaling, and managing microservices-based applications. Kubernetes makes it easy to deploy and manage containers, which are a key component of microservices architecture. Kubernetes provides features such as service discovery, load balancing, and automatic scaling, which are essential for building scalable and resilient microservices-based applications.

## Task 2: Why Kubernetes and Microservices?

## Task 3: Kubernetes Infrastructure

## Task 4: Namespaces

In Kubernetes, a namespace is a virtual cluster that provides a way to divide cluster resources between multiple users or teams. It allows you to create a logical separation between resources in the same cluster, providing a way to isolate, manage and control access to these resources.

By default, Kubernetes comes with four namespaces: default, kube-system, kube-public, and kube-node-lease. The default namespace is the one used for most applications, while the other namespaces are used by Kubernetes itself to manage its own components.

You can create additional namespaces to organize and manage your resources. This allows you to limit the scope of resources visible to different teams or applications. For example, you can create a separate namespace for your development environment, testing environment, and production environment, and manage the resources for each environment separately.

Kubernetes provides several features that allow you to manage resources across different namespaces. For example, you can use labels and selectors to select resources across different namespaces, and you can configure network policies to control network traffic between resources in different namespaces.

## Task 5: Containers

In Kubernetes, a container is a lightweight, standalone, and executable software package that includes everything needed to run an application or a service, including the code, runtime, system tools, libraries, and settings. Containers are isolated from each other and from the host system, providing a secure and predictable environment for running applications.

Kubernetes uses containers as the basic unit of deployment and management. Containers are deployed as part of a Pod, which is the smallest and simplest unit in Kubernetes. A Pod can contain one or more containers that share the same network namespace and can communicate with each other using the localhost interface.

Containers in Kubernetes are typically created from Docker images, although other container runtimes like CRI-O and containerd are also supported. Kubernetes provides a container runtime interface (CRI) that allows different container runtimes to be used interchangeably.

Kubernetes provides several benefits when it comes to containers. It provides a platform-agnostic way of running and managing containers, allowing you to deploy the same application across different cloud providers and on-premises data centers. It also provides advanced features like load balancing, scaling, rolling updates, and self-healing, making it easy to manage and scale containerized applications in production.

Overall, containers are a core building block of Kubernetes and a key technology for modern software development and deployment. They provide a lightweight and secure way to run applications, and Kubernetes provides a powerful platform for managing and scaling containerized applications in production.

### Init Containers

In Kubernetes, an Init Container is a container that runs before the main container in a Pod and is used to perform initialization tasks, such as setting up configuration files, populating a database, or running a script.

Init Containers are designed to run once and complete their task before the main container starts. This ensures that the main container only starts once all of the necessary initialization tasks have been completed. Init Containers are also useful for performing tasks that require specialized tools or knowledge that is not available in the main container.

Init Containers are defined in the same Pod specification as the main container, but they have a separate container specification that defines the image, command, and arguments for the container. Init Containers are run in order, with each container starting after the previous one has completed.

Init Containers can be useful in a variety of scenarios, such as initializing a database, configuring a web server, or performing complex initialization tasks that require specialized tools or knowledge. They are a powerful tool for managing the initialization process in Kubernetes, providing a way to ensure that the main container starts only once all necessary initialization tasks have been completed.

## Task 6: Pods

In Kubernetes, a pod is the smallest and simplest unit in the Kubernetes object model. A pod represents a single instance of a running process in a cluster, and it can contain one or more containers that share the same network namespace and mount the same volumes.

A pod is created and managed by the Kubernetes API server, and it is scheduled to run on a specific node in the cluster. Pods can be created, updated, and deleted using Kubernetes API calls or using declarative configuration files that describe the desired state of the pod.

Pods provide several benefits in Kubernetes. They provide a layer of abstraction that makes it easier to manage containerized applications. They also provide a way to group related containers together and ensure that they are always scheduled together on the same node. This makes it easier to manage dependencies between containers and ensures that they can communicate with each other over the same network namespace.

One important thing to note about pods is that they are not designed to be long-lived. Pods are designed to be ephemeral, meaning that they can be created and destroyed dynamically in response to changes in the cluster. This allows Kubernetes to provide high availability and scaling capabilities for containerized applications.

## Task 7: ConfigMaps

In Kubernetes, a ConfigMap is an API object used to store configuration data in key-value pairs. ConfigMaps provide a way to decouple configuration data from application code, making it easier to manage and update configuration data without modifying the application code.

ConfigMaps can be created manually using the Kubernetes API or using declarative configuration files. Once created, they can be referenced by pods and other Kubernetes objects using environment variables, command-line arguments, or volume mounts.

ConfigMaps are useful for storing configuration data such as environment variables, command-line arguments, configuration files, or any other configuration data that can be expressed as key-value pairs. This makes it easy to manage configuration data for containerized applications running in Kubernetes.

ConfigMaps can be updated dynamically by updating the corresponding ConfigMap object in Kubernetes. Once updated, all pods that reference the ConfigMap will receive the updated configuration data.

Overall, ConfigMaps are a powerful tool for managing configuration data in Kubernetes, providing a way to decouple configuration data from application code and making it easier to manage and update configuration data for containerized applications running in Kubernetes.

## Task 8: Secrets

In Kubernetes, a Secret is an object that allows you to store and manage sensitive information, such as passwords, OAuth tokens, and SSH keys, in a secure way. Secrets are used to ensure that sensitive data is kept confidential and is not exposed to unauthorized users or processes.

Secrets are similar to ConfigMaps in Kubernetes, but they are specifically designed to store sensitive information, while ConfigMaps are used to store configuration data.

When you create a Secret in Kubernetes, the data is stored in a base64-encoded format. The Secret can then be mounted as a volume in a Pod or referenced as an environment variable, allowing you to use the sensitive data in your application.

Secrets are encrypted at rest in etcd, the distributed key-value store that Kubernetes uses to store its data. When you create a Secret, Kubernetes automatically encrypts the data and stores it securely in etcd.

Overall, Secrets are a powerful tool for managing sensitive data in Kubernetes, providing a way to store and manage passwords, keys, and other sensitive information in a secure way.

## Task 9: Deployments

In Kubernetes, a Deployment is an API object that manages a set of replica Pods. Deployments provide a way to declaratively manage the lifecycle of Pods, including their creation, scaling, rolling updates, and rollback.

Deployments are used to ensure that a specified number of replica Pods are running at all times. Deployments also provide rolling updates and rollback capabilities, allowing you to update your application without downtime or interruption to the end users.

When a Deployment is created, Kubernetes creates and manages a ReplicaSet object that ensures the desired number of replica Pods are running. The ReplicaSet then creates and manages the actual Pods.

Deployments provide several benefits in Kubernetes. They provide a declarative way to manage the desired state of your application, making it easy to create, scale, update, and rollback your application. They also provide high availability and fault tolerance for your application, ensuring that your application can continue to run even if some Pods fail.

Overall, Deployments are a powerful tool for managing the lifecycle of Pods in Kubernetes, providing a way to declaratively manage the desired state of your application and ensuring high availability and fault tolerance.

## Task 10: Replicas

In Kubernetes, a Replica is a copy of a Pod that is created and managed by a ReplicaSet or a Deployment. Replicas are used to ensure that a specified number of identical Pods are running at all times, providing high availability and scalability for your applications.

Replicas are created and managed by a ReplicaSet or a Deployment. When you create a ReplicaSet or a Deployment, you specify the number of replicas that you want to create. The ReplicaSet or Deployment then creates and manages the replicas, ensuring that the specified number of replicas are running at all times.

Replicas are useful for creating scalable and fault-tolerant applications. By creating multiple identical replicas of a Pod, you can ensure that your application can continue to run even if some of the replicas fail. You can also use replicas to scale your application horizontally, by increasing or decreasing the number of replicas in response to changes in demand.

Overall, replicas are a powerful tool for creating scalable and fault-tolerant applications in Kubernetes, providing a way to ensure high availability and scalability for your applications.

## Task 11: Services

In Kubernetes, a Service is an abstraction layer that provides a stable IP address and DNS name for a set of replica Pods. Services allow you to expose your application to other components within a Kubernetes cluster or to the external network, providing a way to connect and communicate with your application.

Services are used to abstract the network connectivity between a set of replica Pods and other components in the cluster, allowing you to refer to the set of Pods by a stable DNS name and IP address, regardless of the Pods' actual location or status.

When you create a Service in Kubernetes, you specify the set of replica Pods that the Service should connect to. Kubernetes creates an endpoint for the Service, which is a list of IP addresses of the replica Pods that the Service should route traffic to.

Services provide several benefits in Kubernetes. They allow you to abstract the network connectivity between Pods and other components in the cluster, providing a way to refer to the Pods by a stable DNS name and IP address. They also provide load balancing and fault tolerance, distributing traffic evenly among the replica Pods and ensuring that traffic continues to be routed even if some of the Pods fail.

Overall, Services are a powerful tool for managing the network connectivity of your applications in Kubernetes, providing a way to connect and communicate with your application and ensuring that traffic is distributed evenly among the replica Pods.

## Learn More

* [Oracle Container Engine for Kubernetes (OKE)](https://www.oracle.com/uk/cloud/cloud-native/container-engine-kubernetes/)
* [Kubernetes](https://kubernetes.io/)

## Acknowledgements

* **Author** - John Lathouwers, Developer Advocate, Database Development Operations
* **Last Updated By/Date** - John Lathouwers, May 2023
