# Deploy the Oracle Operator for Kubernetes (OraOperator)

## Introduction

This lab will walk you through deploying the Oracle Operator for Kubernetes (OraOperator).  In Kubernetes (K8s), an **Operator** is a software component that extends the behaviour of K8s clusters without modifying the Kubernetes code itself.  

> K8s Operators are designed to mimic the role of a human data centre operator

The human operator gains their system knowledge from the Subject Matter Experts (SMEs) through documented Standard Operation Procedures (SOPs).  Over time, the human operator also gains the experience of how the systems should behave and how to respond when problems occur, enhancing the maturity of the SOPs.  They may even take responsibility for some of the SMEs tasks such as: deploying software, performing generic configurations, and lifecycle management.

![Operator/DBA Relationship](images/dba_oper_dev.png "Operator/DBA Relationship")

In short, human operators become extensions of the SMEs, and in this case, the Oracle Operator for Kubernetes becomes an extension of the Oracle DBA.

*Estimated Lab Time:* 5 minutes

Watch the video below for a quick walk through of the lab.
[](youtube:zNKxJjkq0Pw)

### Objectives

* Have a Running and Healthy OraOperator

### Prerequisites

This lab assumes you have:

* [Generated a Kubeconfig File](?lab=AccesstheKubernetesCluster)
* [Are using the demo namespace](?lab=AccesstheKubernetesCluster#ChangethedefaultNamespaceContext)

## Task 1: Kubernetes Resources

In the Oracle Database there are built-in Datatypes (CHAR, DATE, INTEGER, etc.) that define the structure of the data and the ways of operating on it.  However, there maybe cases where you may want extend on the built-in Datatypes and define additional kinds of data.  This can be accomplished with "User-Defined Datatypes".

Similarly Kubernetes has built-in resources, or API endpoints, that usually represent a collection of concrete objects on the cluster, like a namespace or nodes.  And similarly to User-Defined Datatypes, you can extend the API in Kubernetes to define additional resources using **Custom Resource Definitions**, or **CRDs**.

Take a look at the built-in resources available, along with their shortnames, API group, whether they are namespaced, and their kind, in your cluster.  

In Cloud Shell:

```bash
<copy>
kubectl api-resources
</copy>
```

You'll notice there doesn't appear to be anything related to an Oracle Database.  When you install the OraOperator later in this Lab, you will be extending the Kubernetes API in order to define an Oracle Database in Kubernetes, making it "Kubernetes Native".

On their own though, Custom Resources only let you define your objects, but when you combine them with a **Custom Controller**, you now have an **Operator** and a true declarative API to fully manage your new resources.

## Task 2: Resource Controllers

The **kube-control-manager**, which is a core component of the Control Plane, operates in a continuous loop to monitor the current state of the cluster via the **kube-apiserver**.  It manages controllers, including **Custom Controllers** which continuously watch and maintain the desired state of resources.

![kube-control-manager](images/kube-control-manager.png "kube-control-manager")

You will take a closer look at the OraOperator controllers after the installation of the OraOperator, but keep in mind the APIs are declarative.  This means that if you define a new Oracle Database **Custom Resource** and it does not currently exist, it is the Controllers responsibility to bring that resource to the desired state... that is: create it.

## Task 3: Install OraOperator

The OraOperator is developed and supported by Oracle, with **Custom Controllers** for provisioning, configuring, and managing the lifecycle of Oracle databases deployed within or outside Kubernetes clusters, including Cloud databases.

To install the OraOperator, you will first need to install a dependency, **cert-manager**:

In Cloud Shell run:

```bash
<copy>
kubectl apply -f https://github.com/jetstack/cert-manager/releases/latest/download/cert-manager.yaml
</copy>
```

To check its installed resources:

```bash
<copy>
kubectl get all -n cert-manager
</copy>
```

The output will be similar to:

![kubectl get all -n cert-manager](images/kubectl_cert_manager.png "kubectl get all -n cert-manager")

Next to install the OraOperator, in Cloud Shell run:

```bash
<copy>
kubectl apply -f https://raw.githubusercontent.com/oracle/oracle-database-operator/main/oracle-database-operator.yaml
</copy>
```

The output will look similar to this:

![OraOperator Install](images/oraoperator_install.png "OraOperator Install")

To check its installed resources:

```bash
<copy>
kubectl get all -n oracle-database-operator-system
</copy>
```

The output will be similar to:

![kubectl get all -n oracle-database-operator-system](images/kubectl_oraoper.png "kubectl get all -n oracle-database-operator-system")

Notice all the resources in the namespace are **Custom Controllers** which will watch your cluster to ensure the new **Custom Resources** are in their desired state.

### Custom Resource Definitions

Finally, rerun query to get the `api-resources`, but this time filter it on the new **database.oracle.com** group:

```bash
<copy>
kubectl api-resources --api-group=database.oracle.com
</copy>
```

You will now see all the new CRDs introduced by the OraOperator.

![kubectl api-resources --api-group=database.oracle.com](images/oraoperator_crds.png "kubectl api-resources --api-group=database.oracle.com")

## Learn More

* [Kubernetes Operators](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)
* [Kubernetes Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
* [Oracle Operator for Kubernetes](https://github.com/oracle/oracle-database-operator)
* [Cert-Manager](https://cert-manager.io/)

## Acknowledgements

* **Author** - John Lathouwers, Developer Advocate, Database Development Operations
* **Last Updated By/Date** - John Lathouwers, May 2023
