# Deploy the Oracle Operator for Kubernetes (OraOperator)

## Introduction

In this lab, we will deploy the Oracle Operator for Kubernetes (OraOperator).

*Estimated Lab Time:* 5 minutes

Watch the video below for a quick walk through of the lab.
[](youtube:zNKxJjkq0Pw)

### Objectives

* Have a Running and Healthy OraOperator

### Prerequisites

This lab assumes you have:

* An accessible Kubernetes Cluster

## Task 1: Test Kubernetes Access

```bash
<copy>
kubectl get all -A
</copy>
```

## Task 2: Install Cert-Manager

```bash
<copy>
kubectl apply -f https://github.com/jetstack/cert-manager/releases/latest/download/cert-manager.yaml
</copy>
```

```bash
<copy>
kubectl get all -n cert-manager
</copy>
```

## Task 3: Install Oracle Operator for Kubernetes

```bash
<copy>
kubectl apply -f https://raw.githubusercontent.com/oracle/oracle-database-operator/main/oracle-database-operator.yaml
</copy>
```

```bash
<copy>
kubectl get all -n oracle-database-operator-system
</copy>
```

## Learn More

* [Oracle Operator for Kubernetes](https://github.com/oracle/oracle-database-operator)
* [cert-manager](https://cert-manager.io/)

## Acknowledgements

* **Author** - John Lathouwers, Developer Advocate, Database Development Operations
* **Last Updated By/Date** - John Lathouwers, May 2023
