# Lifecycle Operations - Single Instance Database (SIDB)

## Introduction

In this lab, we use the OraOperator to perform Lifecycle operations against a Containerised Single Instance Database.

*Estimated Lab Time:* 5 minutes

Watch the video below for a quick walk through of the lab.
[](youtube:zNKxJjkq0Pw)

### Objectives

* Perform Lifecycle Operations on a Containerised SIDB using the OraOperator

### Prerequisites

This lab assumes you have:

* A Running and Healthy OraOperator
* The OraOperator bound to a Containerised SIDB

## Task 1: Manually Connect to the SIDB

kubectl port-forward service/sidb 1521:1521 -n containerdb &
sqlplus system/Welcome_1234@localhost:1521/ORCL1
sqlplus system/Welcome_1234@localhost:1521/ORCLPDB1

## Task 2: Connect to the SIDB Container

kubectl get pods -n containerdb
POD=$(kubectl get pods -n containerdb --no-headers | awk '{print $1}')
kubectl exec -it $POD -n containerdb -- /bin/bash

## Task 3: Update Initialization Parameters



## Task 4: Update Database Configuration (Flashback, Archivelog)

kubectl patch singleinstancedatabase sidb-orcl1 --type merge -p '{"spec":{"archiveLog": true}}' -n containerdb
kubectl patch singleinstancedatabase sidb-orcl1 --type merge -p '{"spec":{"forceLog": true}}' -n containerdb

## Task 6: Clone Database

Note: To clone a database, the source database must have archiveLog mode set to true.

apiVersion: database.oracle.com/v1alpha1
kind: SingleInstanceDatabase
metadata:
  name: sidb-orcl2
  namespace: containerdb
spec:
  sid: ORCL2
  cloneFrom: sidb-orcl1
  adminPassword:
    secretName: sidb-sys-secret
  image:
    pullFrom: container-registry.oracle.com/database/enterprise:21.3.0.0
    pullSecrets: oracle-container-registry-secret
  persistence:
    size: 10Gi
    storageClass: "oci-bv"
    accessMode: "ReadWriteOnce"
  replicas: 1

kubectl get singleinstancedatabase -n containerdb

## Learn More

* [Oracle Autonomous Database](https://www.oracle.com/uk/autonomous-database/)

## Acknowledgements

* **Author** - John Lathouwers, Developer Advocate, Database Development Operations
* **Last Updated By/Date** - John Lathouwers, May 2023
