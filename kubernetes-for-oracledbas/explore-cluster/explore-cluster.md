# Explore The Cluster

## Introduction

In this lab you will explore the the Kubernetes Cluster.  You've already seen the *kube-apiserver* and *etcd* components of the *Control Plane* node, now explore the rest of the cluster to gain a better understanding of the **why** and **how** Kubernetes is an exciting technology.

### Objectives

* Understand the Core Compenents of Kubernetes

### Prerequisites

This lab assumes you have:

* An accessible Oracle Kubernetes Engine Cluster
* [Generated a Kubeconfig File](?lab=access-cluster)

Running a container on a laptop is relatively simple. But connecting containers across multiple hosts, scaling them, deploying
applications without downtime, and service discovery among several aspects, can be difficult.

## Task 1: Pods

*Pods* are the data of a Database.  Without data, you don't need a table, without tables you don't need a schema or an instance... there is no point to a Database without data and similarly, there is no point to Kubernetes without *Pods*.  Everything in Kubernetes revolves around *Pods*, the smallest computing object in a Kubernetes Cluster.

*Pods* consists of one or more *Containers*, applications with all their libraries and dependencies, packaged to run in any environment.

1. Start a *Pod* called `mypod` that runs the container image `nginx`, a lightweight webserver:

    ```bash
    <copy>
    kubectl run mypod --image=nginx --restart=Never
    kubectl get pod mypod -o wide
    </copy>
    ```

2. Access your *Pod* and make a call to the webserver.

    With the webserver application currently only accessible inside the cluster, connect to pod in order to access it.

    ```bash
    <copy>
    kubectl exec -it pod mypod -c nginx -- /bin/bash -c "curl localhost"
    </copy>
    ```

3. Cause an unrecoverable Failure and query the *Pod*:

    ```bash
    <copy>
    kubectl exec -it pod/mypod -- /bin/bash -c "kill 1"
    kubectl get pod mypod
    </copy>
    ```




## Task 2: Worker Nodes

*Worker Nodes* are often referred to as the backbone of a Kubernetes cluster, as they form the foundation and perform the bulk of the computational and operational tasks. They have three main components:

* *Container Runtime* - Responsible for pulling container and running container images. 
* *Kubelet* - The primary `node-agent` responsible for interacting with the *Container Runtime* to ensure that containers are running and healthy on the node. 
* *Kube-Proxy* - Acts as a sort of proxy and loadbalancer, responsible for routing traffic to the appropriate container based on IP and port number of the incoming request.

![Worker Nodes](images/worker_nodes.png "Worker Nodes")

1. Ask the *kube-apiserver* about your *Worker Nodes*

    ```bash
    <copy>
    kubectl get nodes -o wide
    </copy>
    ```

2. Connect to a *Worker Node*

    ```bash
    <copy>
    kubectl debug node/10.157.124.4 -it --image=oraclelinux:8
    </copy>
    ```

3. See the core process that make this a *Worker Node* in the cluster:

    ```bash
    <copy>
    ps -e |grep crio
    ps -e |grep kubelet
    ps -e |grep kube-proxy
    </copy>
    ```

You may now **proceed to the next lab**

## Learn More

[Kubernetes Worker Nodes](https://kubernetes.io/docs/concepts/architecture/nodes/)

## Acknowledgements

* **Authors** - [](var:authors)
* **Contributors** - [](var:contributors)
* **Last Updated By/Date** - John Lathouwers, May 2023