# Install the Database Operator

## Introduction

<!-- This lab will show you how to create an Autonomous Database on your Kubernetes cluster, walk through the functionality and explain how it works. -->

Estimated Time:  XX minutes

<!-- Quick walk through on how to deploy the microservices on your Kubernetes cluster. -->

### Objectives

* Deploy and access the microservices
* Learn how they work

### Prerequisites

<!-- * The OKE cluster and the Autonomous Transaction Processing databases that you created in Lab 1 -->

## Task 1: Install the DB Operator for Kubernetes

The operator uses webhooks for validating user input before persisting it in Etcd. Webhooks require TLS certificates that are generated and managed by a certificate manager.

1. Install the certificate manager with the following command:

    ```bash
    <copy>kubectl apply -f https://github.com/jetstack/cert-manager/releases/latest/download/cert-manager.yaml</copy>
    ```

2. To install the operator in the cluster quickly, run the following command:

    ```bash
    <copy>kubectl apply -f https://raw.githubusercontent.com/oracle/oracle-database-operator/main/oracle-database-operator.yaml</copy>
    ```

    ```bash
    labuserexa@cloudshell:cbworkshop (us-phoenix-1)$ kubectl apply -f https://raw.githubusercontent.com/oracle/oracle-database-operator/main/oracle-database-operator.yaml
    namespace/oracle-database-operator-system created
    customresourcedefinition.apiextensions.k8s.io/autonomouscontainerdatabases.database.oracle.com created
    customresourcedefinition.apiextensions.k8s.io/autonomousdatabasebackups.database.oracle.com created
    customresourcedefinition.apiextensions.k8s.io/autonomousdatabaserestores.database.oracle.com created
    customresourcedefinition.apiextensions.k8s.io/autonomousdatabases.database.oracle.com created
    customresourcedefinition.apiextensions.k8s.io/cdbs.database.oracle.com created
    customresourcedefinition.apiextensions.k8s.io/dbcssystems.database.oracle.com created
    customresourcedefinition.apiextensions.k8s.io/oraclerestdataservices.database.oracle.com created
    customresourcedefinition.apiextensions.k8s.io/pdbs.database.oracle.com created
    customresourcedefinition.apiextensions.k8s.io/shardingdatabases.database.oracle.com created
    customresourcedefinition.apiextensions.k8s.io/singleinstancedatabases.database.oracle.com created
    role.rbac.authorization.k8s.io/oracle-database-operator-leader-election-role created
    clusterrole.rbac.authorization.k8s.io/oracle-database-operator-manager-role created
    clusterrole.rbac.authorization.k8s.io/oracle-database-operator-metrics-reader created
    clusterrole.rbac.authorization.k8s.io/oracle-database-operator-oracle-database-operator-proxy-role created
    rolebinding.rbac.authorization.k8s.io/oracle-database-operator-oracle-database-operator-leader-election-rolebinding created
    clusterrolebinding.rbac.authorization.k8s.io/oracle-database-operator-oracle-database-operator-manager-rolebinding created
    clusterrolebinding.rbac.authorization.k8s.io/oracle-database-operator-oracle-database-operator-proxy-rolebinding created
    service/oracle-database-operator-controller-manager-metrics-service created
    service/oracle-database-operator-webhook-service created
    certificate.cert-manager.io/oracle-database-operator-serving-cert created
    issuer.cert-manager.io/oracle-database-operator-selfsigned-issuer created
    mutatingwebhookconfiguration.admissionregistration.k8s.io/oracle-database-operator-mutating-webhook-configuration created
    validatingwebhookconfiguration.admissionregistration.k8s.io/oracle-database-operator-validating-webhook-configuration created
    deployment.apps/oracle-database-operator-controller-manager created
    labuserexa@cloudshell:cbworkshop (us-phoenix-1)$ 
    ```

    Once the above has been executed, you can view the created pods that the DB operator is compromised of in your cluster:

    ```bash
    <copy>kubectl get pods -n oracle-database-operator-system</copy>
    ```

## Task 2: Setup Secrets and Provision an ADB

With a working DB operator installed in your Kubernetes cluster, you can now provision Autonomous Databases (ADB), Single-Instance Databases (SIDB), Oracle On-Premises Databases, etc.

For this lab, we will use an Autonomous Database. To provision an Oracle Autonomous Database through the DB Operator for Kubernetes, you can use the below sample YAML file and configure it to your specific uses. More properties can be set and are shown in the official sample YAML file for ADB and can be found [<strong>here</strong>](https://github.com/oracle/oracle-database-operator/blob/main/config/samples/adb/autonomousdatabase_create.yaml)


```yaml
# Copyright (c) 2022, Oracle and/or its affiliates. 
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#
apiVersion: database.oracle.com/v1alpha1
kind: AutonomousDatabase
metadata:
  name: autonomousdatabase-sample
spec:
  details:
    compartmentOCID: < compartment_ocid >
    dbName: NewADB
    displayName: NewADB
    cpuCoreCount: 1
    adminPassword:
      k8sSecret:
        name: admin-password
    dataStorageSizeInTBs: 1
  ociConfig:
    configMapName: oci-cred
    secretName: oci-privatekey
```

With the Kubernetes Operator, you only need to configure the below and apply it to create databases, similar to the below command.

```bash
kubectl apply -f your-adb-configuration.yaml
```

To get started with creating an Oracle Autonomous Database, you will need to create the secrets and configmap above, which will have the same name as above (only per lab configuration; the names can be different for own your purposes).

1. Create the __config map oci-cred__

    This config map is used to authorize the operator with API signing key pair. To create it, run the following, which will retrieve the values for you from earlier in __Lab 1__.

    ```bash
        <copy>
        kubectl create configmap oci-cred \
        --from-literal=tenancy=$(state_get .lab.ocid.tenancy) \
        --from-literal=user=$(state_get .lab.ocid.user) \
        --from-literal=fingerprint=$(state_get .lab.apikey.fingerprint) \
        --from-literal=region=$(state_get .lab.region.identifier)
        </copy>
    ```

2. Create the __secret oci-privatekey__

    This secret is used to authorize the operator with API signing key pair. To create this secret, run the following, which will use the private key file you uploaded earlier in __Lab 1__ and moved inside the `cbworkshop` directory.

    ```bash
        <copy>
        (cd $CB_STATE_DIR ; kubectl create secret generic oci-privatekey --from-file=privatekey=private.pem)
        </copy>
    ```

3. Create the __secret admin-password__

    This secret is used to contain and provide the Admin password when the ADB is created. To create this secret, run the following, which will retrieve the default password set for the lab (per lab configuration; the password can be different for own your purposes).

    ```bash
    <copy>
        kubectl create secret generic admin-password --from-literal=admin-password=$(state_get .lab.fixed_demo_user_credential)
    </copy>
    ```

4. Create an `Autonomous Database`

    To make things easier, there are ways to generate the lab-related YAML files to create the autonomous database.

    ```bash
    <copy>
        (cd $CB_STATE_DIR ; ./gen-adb-create.sh)
    </copy>
    ```

    The `gen-adb-create.sh` script will produce an output similar to the below on your terminal with an instruction for applying the generated YAML file. Copy the the last command: `kubectl apply ...` and run it.

    ```
    Retreiving Compartment OCID...DONE

    Generating YAML file...DONE
    Updating generated YAML file...DONE

    To apply:
    kubectl apply -f /home/labuserexa/cbworkshop/generated/adb-create.yaml
    ```

    You can also run the following:
    ```bash
    <copy>
    (cd $CB_STATE_DIR ; ./generated/adb-create.yaml)
    </copy>
    ```

5. View the `Autonomous Database` resource created.

    ```bash
    <copy>
    kubectl get AutonomousDatabase
    </copy>
    ```
    

    On the OCI Console, you can navigate to the Databases page and see that you have a new AutonomousDatabase listed as: `cloudbankdb`


## Task 3: Setup Secrets for SIDB (Used in Lab 4-6)

For Labs 4-6, you will be making use of Single-Instance Databases (SIDB). To provision SIDBs through the DB Operator for Kubernetes, you can use the below sample YAML file and configure it to your specific uses. More types can be found and properties can be set are available in the official sample YAML files for SIDB and can be found [<strong>here</strong>](https://github.com/oracle/oracle-database-operator/tree/main/config/samples/sidb).

```yaml
# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.

apiVersion: database.oracle.com/v1alpha1
kind: SingleInstanceDatabase
metadata:
  name: prebuiltdb-sample
  namespace: default
spec:
  edition: express
  adminPassword:
    secretName: sidb-admin-secret
  image:
    pullFrom: container-registry.oracle.com/database/express:latest
    prebuiltDB: true
  replicas: 1
  ```

1. __Login to container-registry.oracle.com__
    
    Login to the official Oracle Container Registry with your Oracle Account credentials.

    ```bash
    <copy>
    docker login container-registry.oracle.com
    </copy>
    ```
    
    ```bash
    docker login container-registry.oracle.com
    Username: <oracle-sso-email-address>
    Password: <oracle-sso-password>

    Login Succeeded
    ```

2. To create the __secret oracle-container-reegistry-secret__

    This secret is required to authorize Kubernetes to use the pre-built images to expedite Database provisioning, you will need to create a secret with the dockerconfigjson.

    ```bash
    <copy>
    (cd ~ ; kubectl create secret generic oracle-container-registry-secret --from-file=.dockerconfigjson=.docker/config.json --type=kubernetes.io/dockerconfigjson)
    </copy>
    ```

3. Create the __secret sidb-admin-secret__
    
    ```bash
    <copy>
    kubectl create secret generic sidb-admin-secret --from-literal=oracle_pwd=$(state_get .lab.fixed_demo_user_credential)
    </copy>
    ```


## Task 4: Creating a secret with the Autonomous Database Wallet

In the microservices application related to the lab, we have configured the back-end to connect to the database with a database wallet. The Oracle Database operator for Kubernetes provides means to generate a wallet and create a secret to enable you to inject it into deployments that need it. Below, the secret will be named `instance-wallet`.

```yaml
# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
apiVersion: database.oracle.com/v1alpha1
kind: AutonomousDatabase
metadata:
  name: cloudbankdb
  namespace: cloudbank
spec:
  details:
    autonomousDatabaseOCID: < autonomous_database_ocid >
    wallet:
      name: instance-wallet
      password:
        k8sSecret:
          name: instance-wallet-password
  ociConfig:
    configMapName: oci-cred
    secretName: oci-privatekey
```

1. Before creating the `instance-wallet`, we will need a secret with the instance wallet password. Above this is referenced as `instance-wallet-password`.
    ```bash
    <copy>
    kubectl create secret generic instance-wallet-password --from-literal=instance-wallet-password=$(state_get .lab.pwd.db_wallet)
    </copy>
    ```

2. To make things easier, you can run the following script to generate the lab-related YAML files to create the autonomous database wallet
    ```bash
    <copy>
        (cd $CB_STATE_DIR ; ./gen-adb-wallet.sh)
    </copy>
    ```

    The `gen-adb-create.sh` script will produce an output similar to the below with an instruction for applying the generated YAML file.
    ```
    Retreiving Autonomous Database OCID...DONE

    Generating YAML file...DONE
    Updating generated YAML file...DONE

    To apply:
    kubectl apply -f /home/labuserexa/cbworkshop/generated/adb-wallet.yaml
    ```

3. Copy the `kubectl apply ...` command and run it.

    ```bash
    <copy>
        (cd $CB_STATE_DIR ; kubectl apply -f ./generated/adb-wallet.yaml)
    </copy>
    ```


4. View the `Autonomous Database wallet` secret created. There should be _two secrets listed_.

    ```bash
    <copy>
    kubectl get secrets | grep instance-wallet
    </copy>
    ```

## Task 5: Initializing the Autonomous Database

To begin initializing the database, simply run the following command below. This script will connect to the database to execute SQL scripts and initialize the Autonomous Database with lab-related database tables and create users.

```bash
<copy>
(cd $CB_STATE_DIR ; ./init-database.sh)
</copy>
```

## Acknowledgements

* **Authors** - Norman Aberin, Developer Advocate
* **Last Updated By/Date** - Norman Aberin, August 2022
