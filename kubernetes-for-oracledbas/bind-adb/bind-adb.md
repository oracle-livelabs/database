# Bind the OraOperator to an Oracle Autonomous Database (ADB)

## Introduction

In this lab, we bind the OraOperator to an Oracle Autonomous Database (ADB).

*Estimated Lab Time:* 5 minutes

Watch the video below for a quick walk through of the lab.
[](youtube:zNKxJjkq0Pw)

### Objectives

* Connect the OraOperator to an existing ADB

### Prerequisites

This lab assumes you have:

* A Running and Healthy OraOperator
* A provisioned Oracle ADB in OCI

## Task 1: Retrieve the ADB OCID

```bash
<copy>
COMPARTMENT_OCID=$(oci iam compartment list --name K8S4DBAS | jq -r '.data[].id')
ADB_OCID=$(oci db autonomous-database list --compartment-id $COMPARTMENT_OCID | jq -r '.data[].id')
</copy>
```

## Task 2: Create Namespace

```bash
<copy>
kubectl create namespace adb
</copy>
```

## Task 4: Create the Bind Manifest

```bash
<copy>
cat > adb_bind.yaml << EOF
apiVersion: v1
stringData:
  adb-admin-password: ZVVvOTRXZEcySFNzXzUtTg==
kind: Secret
metadata:
  labels:
    app.kubernetes.io/part-of: database
  name: adb-admin-password
  namespace: adb
type: Opaque
---
apiVersion: v1
stringData:
  adb-instance-wallet-password: ZVVvOTRXZEcySFNzXzUtTg==
kind: Secret
metadata:
  labels:
    app.kubernetes.io/part-of: database
  name: adb-instance-wallet-password
  namespace: adb
type: Opaque
---
apiVersion: database.oracle.com/v1alpha1
kind: AutonomousDatabase
metadata:
  labels:
    app.kubernetes.io/part-of: database
  name: adb
  namespace: adb
spec:
  details:
    autonomousDatabaseOCID: $ADB_OCID
    adminPassword:
      k8sSecret:
        name: adb-admin-password
    wallet:
      name: adb-tns-admin
      password:
        k8sSecret:
          name: adb-instance-wallet-password
EOF
</copy>
```

## Task 5: Apply the Bind Manifest

kubectl apply -f adb.yaml

## Task 6: Review Deployment and TNS_ADMIN

kubectl get adb adb -n adb
kubectl describe adb adb -n adb
kubectl describe secrets adb-tns-admin -n adb


## Learn More

* [Oracle Autonomous Database](https://www.oracle.com/uk/autonomous-database/)
* [OCI - API Key Authentication](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm)
* [OCI - Instance Principal](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/callingservicesfrominstances.htm)

## Acknowledgements

* **Author** - John Lathouwers, Developer Advocate, Database Development Operations
* **Last Updated By/Date** - John Lathouwers, May 2023
