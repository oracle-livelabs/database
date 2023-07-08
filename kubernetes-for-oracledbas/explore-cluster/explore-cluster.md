# Explore The Cluster

## Introduction

In this lab you will explore the the Kubernetes Cluster.  You've already 

### Objectives

### Prerequisites

## Task 1: What is a Kubernetes Cluster?

So you've deployed a Kubernetes cluster, created a `kubeconfig` file to access it, and created a namespace for an application that you are going to deploy later in the Workshop... but what is a Kubernetes Cluster?

To put in Oracle DBA terms; a Kubernetes Cluster is to a Microservice Application what a Real Application Cluster (RAC) is to Single Instance Databases (SIDB).  

RAC provides fault-tolerance, high-availability, resource management, and scalability to a SIDB while the Grid Infrastructure component is essentially an orchestration system used to deploy, configure, and manage the nodes and instances within the cluster.  Kubernetes does all this, and more, for containerised applications.

In fact, a Kubernetes Cluster and a RAC Cluster share very similar concepts.  We already touched on `etcd`, the equivalent of the `Oracle Cluster Registry (OCR)` 


will touch on a few of the core concepts here and explore more throughout the remaining Labs.

## Task 1: Manifest Files

## Task 2: Pods



Take a quick look at what **Pods** are running on your newly built cluster, use the `--all-namespaces`, or its shorthand `-A`, to return **Pods** from all namespaces:

```bash
<copy>
kubectl get pods -A
</copy>
```



**Pods** are the Sun of a Kubernetes Cluster, that is, everything in the cluster revolves around **Pods**.  They are the smallest deployable unit of computing in Kubernetes and contain your application all wrapped up into a nice logical host object.




Kubernetes is an orchestration system to deploy and manage containers. Containers are not managed
individually; instead they are part of a larger object called a Pod. A Pod consists of one or more containers which share an
IP address, access to storage and namespace. Typically one container in a Pod runs an application while other containers
support the primary application.



## Task 1: View Worker Nodes

Worker Nodes are often referred to as the backbone of a Kubernetes cluster, as they form the foundation and perform the bulk of the computational and operational tasks. They have three main components:

* Kubelet
* Container Runtime
* Kube-Proxy

which handle the actual workload by running containers, executing applications, and processing requests, making them an essential component in the cluster's functioning.

![Worker Nodes](images/worker_nodes.png "Worker Nodes")

To view the nodes in the cluster, query the kube-apiserver:

```bash
<copy>
kubectl get nodes -o wide
</copy>
```

## Kubelet

You can see the nodes by querying the kube-apiserver because the Kubelet on each node has registered itself with the cluster.  The kubelet is a system process that does most of the node worker heavy-lifting.  It  accepts API calls for **Pod** specifications and interacts with the Container Runtime to ensure   

## Container Runtime

The output from `kubectl get nodes -o wide` displays the nodes **Container Runtime**, which in your cluster will be `CRI-O`, a lightweight alternative to using Docker or Podman.  



## Kube-Proxy



## Task 3: Lookup Namespaces


## Task 4: Lookup Pods


## Task 4: Lookup Services and Endpoint
Namespaces provide the mechanism for applications deployed onto a cluster to isolate resources from each other when deployed in a cluster.

List all of the namespaces present.


Copy
kubectl get namespaces -A


Lookup Secrets deployed on the Kubernetes cluster.

Kubernetes uses Secrets to hold confidential data, such as passwords, keys, or tokens. It helps by keeping them separate from the container image, thereby ensuring no confidential data remains with the application code contained within the container.


Copy
kubectl get secrets -A

Lookup Services and Endpoint
Services within a Kubernetes cluster represent the endpoint(s) used to access applications deployed onto the cluster instead of connecting directly to a container. Which allows an individual pod to terminate, or be replaced, without interrupting the end user’s interaction with the application.

Endpoints track and map the IP addresses of the objects created for a Service to ensure all traffic is routed correctly to the correct application and is managed automatically by Kubernetes. However, if debugging an issue, this is how to look up their details.

List all the Services deployed.


Copy
kubectl get services -A

List all the Pods deployed on the Kubernetes cluster.

List any Endpoints on the Kubernetes cluster.


Copy
kubectl get endpoints -A


Copy
kubectl get pods -A


Lookup Pod Information
Retrieve information about any pod deployed on the cluster.

The previous kubectl get pods -A command returns a list of all the pods currently running on the cluster. Because this is a fresh install of Oracle Cloud Native Environment, only the ‘system’ pods are running. However, kubectl can retrieve more information about any of these deployed pods. All that needs noting are the NAMESPACE and NAME values. Because many pods are dynamically assigned names, these values may change from those shown when you execute the same command. However, the etcd pod should remain the same, so this is the example used for the lab.


Copy
kubectl describe pods etcd-ocne-control -n kube-system

