# Explore The Cluster

## Introduction

In this lab you will explore the the Kubernetes Cluster.  You've already

### Objectives

### Prerequisites

## Task 1: kubectl-fu

I say kube-C-T-L, some say kube-control, while others opt for kube-cuddle; but no matter how you say it there's no point in typing it and its verbs out all the time.

Two cheats to save you precious time interacting with Kubernetes is **Autocompletion** and an **Alias**:

### Autocompletion

To enable autocompletion in your current shell run:

```bash
<copy>
# bash-completion package should be installed first (it is in Cloud Shell)
source <(kubectl completion bash) 
</copy>
```

To add autocomplete permanently:

```bash
<copy>
echo "source <(kubectl completion bash)" >> ~/.bashrc
</copy>
```

### Alias

You will see `k` being used online as an alias to `kubectl`, to set this up and have it work with the above autocompletion, run:

```bash
<copy>
alias k=kubectl
complete -o default -F __start_kubectl k
</copy>
```

and to make it permanent in your shell:

```bash
<copy>
echo "alias k=kubectl" >> ~/.bashrc
echo "complete -o default -F __start_kubectl k" >> ~/.bashrc
</copy>
```

## Task 2: View Worker Nodes

Nodes are the workhorse of a Kubernetes cluster, so the number of control and worker nodes deployed on a cluster is vital for the administrator to be aware of.

Concisely confirm the node information.

This command display an abridged listing showing the node names (NAME), node roles (ROLES) and the Kubernetes version (VERSION)

```bash
kubectl get nodes
```

Return more detailed information about the nodes.

```bash
kubectl get nodes -o wide
```

This command shows the more detailed information than the previous command by including this additional information:

Internal and External IP information (INTERNAL-IP and EXTERNAL-IP)
Operating System information on the node (OS_IMAGE)
Kernel version on the node (KERNEL-VERSION)
Container runtime information and version (CONTAINER-RUNTIME)

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

