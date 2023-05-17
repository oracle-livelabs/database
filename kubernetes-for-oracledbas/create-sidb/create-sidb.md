# Create a Containerised Single Instance Database

## Introduction

In this lab, we use the OraOperator to create a Single Instance Database inside the Kubernetes Cluster.

*Estimated Lab Time:* 5 minutes

Watch the video below for a quick walk through of the lab.
[](youtube:zNKxJjkq0Pw)

### Objectives

* Create a Containerised Single Instance Database

### Prerequisites

This lab assumes you have:

* A Running and Healthy OraOperator
* Authentication Credentials to Oracle's Container Registry

## Task 1: Verify Access to the Oracle Container Registry

## Task 2: Create a Namespace

```bash
<copy>
kubectl create namespace containerdb
</copy>
```

## Task 2: Create a Secret for Container Registry Authentication

```bash
<copy>
kubectl create secret docker-registry oracle-container-registry-secret --docker-server=container-registry.oracle.com --docker-username='<oracle-sso-email-address>' --docker-password='<oracle-sso-password>' --docker-email='<oracle-sso-email-address>' -n containerdb
</copy>
```

```bash
<copy>
kubectl describe secret oracle-container-registry-secret -n containerdb
kubectl get secret oracle-container-registry-secret -n containerdb  --template="{{index .data \".dockerconfigjson\" | base64decode}}"
</copy>
```

## Task 3: Create the SIDB Provision Manifest

```bash
<copy>
cat > adb_bind.yaml << EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: sidb-sys-secret
  namespace: containerdb
type: Opaque
stringData:
  ## Specify your Database password here
  oracle_pwd: Welcome_1234
---
apiVersion: v1
kind: Secret
metadata:
  name: cdb-secrets
  namespace: containerdb
type: Opaque
stringData:
  ords_pwd: Welcome_1234
  cdbadmin_user: C##DBAPI_CDB_ADMIN
  cdbadmin_pwd: Welcome_1234
  webserver_user: sql_admin
  webserver_pwd: Welcome_1234
---
apiVersion: database.oracle.com/v1alpha1
kind: SingleInstanceDatabase
metadata:
  name: sidb-orcl1
  namespace: containerdb
spec:
  sid: ORCL1
  edition: enterprise
  ## Secret containing SIDB password mapped to secretKey
  adminPassword:
    secretName: sidb-sys-secret
  ## DB character set
  charset: AL32UTF8
  ## PDB name
  pdbName: ORCLPDB1
  listenerPort: 31521
  ## Enable/Disable ArchiveLog. Should be true to allow DB cloning
  archiveLog: false
  ## Database image details
  image:
    pullFrom: container-registry.oracle.com/database/enterprise:21.3.0.0
    pullSecrets: oracle-container-registry-secret
  ## size is the required minimum size of the persistent volume
  ## storageClass is specified for automatic volume provisioning
  ## accessMode can only accept one of ReadWriteOnce, ReadWriteMany
  persistence:
    size: 10Gi
    ## oci-bv applies to OCI block volumes.
    storageClass: "oci-bv"
    accessMode: "ReadWriteOnce"
  ## Count of Database Pods.
  replicas: 1
---
apiVersion: database.oracle.com/v1alpha1
kind: OracleRestDataService
metadata:
  name: ords-orcl1
  namespace: containerdb
spec:
  ## Database ref. This can be of kind SingleInstanceDatabase.
  databaseRef: "sidb-orcl1"
  ## Secret containing databaseRef password mapped to secretKey. 
  adminPassword:
    secretName: sidb-sys-secret
  ## Secret containing ORDS_PUBLIC_USER password mapped to secretKey.
  ordsPassword:
    secretName: ords-secret
  ## To configure APEX with ORDS, specfiy the apexPassword secret details. 
  ## Leave empty if Apex is not needed.
  ## This is a secret containing a common password for:
  ## APEX_PUBLIC_USER, APEX_REST_PUBLIC_USER, APEX_LISTENER and Apex administrator
  apexPassword:
    secretName: apex-secret
  ## ORDS image details
  image:
    pullFrom: container-registry.oracle.com/database/ords:21.4.2-gh
EOF
</copy>
```

## Task 4: Apply the SIDB Provision Manifest

```bash
<copy>
kubectl apply -f singleinstancedatabase_create.yaml
</copy>
```

## Task 5: Review Deployment and Logs

```bash
<copy>
POD=$(kubectl get pods -n containerdb --no-headers | awk '{print $1}')

kubectl describe pod $POD -n containerdb

kubectl logs $POD -n containerdb -f

kubectl get singleinstancedatabase sidb -n containerdb
# CDB Connect String
kubectl get singleinstancedatabase sidb -n containerdb -o "jsonpath={.status.connectString}"
# PDB Connect String
kubectl get singleinstancedatabase sidb -n containerdb -o "jsonpath={.status.pdbConnectString}"
</copy>
```

## Task 6: Create Certificate Secrets

```bash
<copy>
openssl genrsa -out ca.key 2048
openssl req -new -x509 -days 365 -key ca.key -subj "/C=CN/ST=GD/L=SZ/O=oracle, Inc./CN=oracle Root CA" -out ca.crt
openssl req -newkey rsa:2048 -nodes -keyout tls.key -subj "/C=CN/ST=GD/L=SZ/O=oracle, Inc./CN=cdb-dev-ords" -out server.csr
/usr/bin/echo "subjectAltName=DNS:cdb-dev-ords,DNS:www.example.com" > extfile.txt
openssl x509 -req -extfile extfile.txt -days 365 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out tls.crt
</copy>
```

```bash
<copy>
kubectl create secret tls db-tls --key="tls.key" --cert="tls.crt"  -n containerdb
kubectl create secret generic db-ca --from-file=ca.crt -n containerdb
</copy>
```

## Learn More

* [Oracle Container Registry](https://container-registry.oracle.com)
* [cert-manager](https://cert-manager.io/)

## Acknowledgements

* **Author** - John Lathouwers, Developer Advocate, Database Development Operations
* **Last Updated By/Date** - John Lathouwers, May 2023
