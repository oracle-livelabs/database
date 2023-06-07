# Deploy the Oracle Operator for Kubernetes (OraOperator)

"If everything seems under control, you're not moving fast enough."
\​- Mario Andretti.

## Introduction

This lab will walk you through deploying the Oracle Operator for Kubernetes (OraOperator).

*Estimated Lab Time:* 5 minutes

Watch the video below for a quick walk through of the lab.
[](youtube:zNKxJjkq0Pw)

### Objectives

* Have a Running and Healthy OraOperator

### Prerequisites

This lab assumes you have:

* Have [generated a Kubeconfig File](?lab=generate-kubeconfig)

## Kubernetes Operators

In Kubernetes (K8s), an **Operator** is a software component that extends the behavior of K8s clusters without modifying the Kubernetes code itself.

K8s Operators are designed to mimic the role of a human data centre operator:

The human operator gains their system knowledge from the Subject Matter Experts (SMEs) through documented Standard Operation Procedures (SOPs).  Over time, the human operator also gains the experience of how the systems should behave and how to respond when problems occur, enhancing the maturity of the SOPs.  They may even take responsibility for some of the SMEs tasks such as: deploying software, performing generic configurations, and lifecycle management.

![Operator/DBA Relationship](images/dba_oper_dev.png "Operator/DBA Relationship")

In short, human operators become extensions of the SMEs.

Like the human operator, the OraOperator in K8s, is an extension of the Oracle DBA in a K8s cluster.  The OraOperator is developed and supported by Oracle, with "built-in SOPs" for provisioning, configuring, and managing the lifecycle of Oracle databases deployed within or outside K8s clusters, including Cloud databases.

## Task 1: Install Cert-Manager

The OraOperator uses webhooks, automated messages sent from apps when something happens, to intercept and validate user requests to the OraOperator before they are persisted in etcd.  A sort of table check-constraint to ensure the input is valid before inserting it.

Webhooks require TLS certificates that are generated and managed by Cert-Manager, an open-source certificate management solution designed for Kubernetes.

To install Cert-Manager, in Cloud Shell run:

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

## Task 2: Install Oracle Operator for Kubernetes

To install the OraOperator, in Cloud Shell run:

```bash
<copy>
kubectl apply -f https://raw.githubusercontent.com/oracle/oracle-database-operator/main/oracle-database-operator.yaml
</copy>
```

To check its installed resources:

```bash
<copy>
kubectl get all -n oracle-database-operator-system
</copy>
```

The output will be similar to:

![kubectl get all -n oracle-database-operator-system](images/kubectl_oraoper.png "kubectl get all -n oracle-database-operator-system")

## Learn More

* [Kubernetes Operators](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)
* [Oracle Operator for Kubernetes](https://github.com/oracle/oracle-database-operator)
* [Cert-Manager](https://cert-manager.io/)

## Acknowledgements

* **Author** - John Lathouwers, Developer Advocate, Database Development Operations
* **Last Updated By/Date** - John Lathouwers, May 2023
