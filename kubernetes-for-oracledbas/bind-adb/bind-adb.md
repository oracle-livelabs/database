# Provision and Bind to an Oracle Autonomous Database (ADB)

## Introduction

In this lab, you will provision a new Oracle Autonomous Database (ADB) and bind to an existing one using the OraOperator.

![OraOperator for ADB](images/k8s_operator_adb.png "OraOperator for ADB")

*Estimated Lab Time:* 10 minutes

Watch the video below for a quick walk through of the lab.
[](youtube:zNKxJjkq0Pw)

### Objectives

* Provision a new Oracle Autonomous Database (ADB) using the OraOperator
* Bind to an existing ADB using the OraOperator

### Prerequisites

This lab assumes you have:

* [Generated a Kubeconfig File](?lab=generate-kubeconfig)
* A [Running and Healthy OraOperator](?lab=deploy-oraoperator)
* A provisioned Oracle ADB in OCI

## Task 1: Retrieve the existing ADB OCID

During the [Deploy Workshop Stack Lab](?lab=setup-stack), a new Autonomous Database was provisioned in Oracle Cloud Infrastructure for you.

Retrieve the OCID for the Autonomous Database, by running the following in Cloud Shell:

```bash
<copy>
# Get the Compartment OCID
COMPARTMENT_OCID=$(oci iam compartment list \
  --name [](var:oci_compartment) | 
  jq -r '.data[].id')

# Get the ADB OCID from the Compartment
ADB_OCID=$(oci db autonomous-database list \
  --lifecycle-state AVAILABLE \
  --compartment-id $COMPARTMENT_OCID | 
  jq -r '.data[].id')

echo "ADB OCID: $ADB_OCID"
</copy>
```

## Task 2: Create a manifest to Bind

Create a manifest file to define the resource of an existing ADB, leveraging the **AutonomousDatabase** Custom Resource:

```bash
<copy>
cat > adb_bind.yaml << EOF
---
apiVersion: database.oracle.com/v1alpha1
kind: AutonomousDatabase
metadata:
  name: adb-existing
spec:
  hardLink: false
  details:
    autonomousDatabaseOCID: $ADB_OCID
EOF
</copy>
```

The above YAML sends a request to the `database.oracle.com/v1alpha1` API exposed by the OraOperator to define a resource of `kind: AutonomousDatabase`.

The resource `name` will be called `adb-existing`.  

It will bind to an existing ADB with `autonomousDatabaseOCID` equal to `$ADB_OCID` (substituted by the real value stored in *Task 1*).

**Important:** the `spec.hardLink: false` (default) field indicates that if you delete this `AutonomousDatabase` resource from the K8s cluster, *do not* delete the ADB associated with it.
> Good for Production... Bad for DevOps!

If it were set to `true` then deleting the resource from K8s *WOULD* delete ADB itself.

## Task 3: Apply the existing ADB Manifest

Define the **AutonomousDatabase** Custom Resource in K8s by applying the manifest file to the `adb` namespace:

```bash
<copy>
kubectl apply -f adb_bind.yaml
</copy>
```

Output:

```text
autonomousdatabase.database.oracle.com/adb-existing created
```

## Task 4: Review the Existing ADB Custom Resource

The bind manifest created a new *AutonomousDatabase* resource called *adb-existing* in the *adb* namespace.

To retrieve its details run (`kubectl get <resource> <resource_name> -n <namespace>`).  You can omit the `-n <namespace>` as your `kubeconfig` context has already set it for you:

```bash
<copy>
kubectl get AutonomousDatabase adb-existing
</copy>
```

With the exception of the **DISPLAY NAME** and **DB NAME**, you should see similar output:

![kubectl get AutonomousDatabase adb-existing -n adb](images/kubectl_get_adb.png "kubectl get AutonomousDatabase adb-existing -n adb")

To get more details, lets describe the resource (`kubectl describe <resource_type> <resource_name> -n <namespace>`).  Use the resource_type alias `adb` for `AutonomousDatabase`:

```bash
<copy>
kubectl describe adb adb-existing
</copy>
```

A lot of interesting information will be displayed including CPU and Storage settings, Connection Strings, and its Lifecycle State (AVAILABLE).  You will modify these fields later to manage the ADB via K8s.

Note that in the last command `AutonomousDatabase` was abbreviated to `adb`.  This is the "SHORTNAME" for the `AutonomousDatabase` kind determined by running `kubectl api-resources`.

## Task 5: Generate Password/Generate Wallet Manifest

The password currently assigned to the ADB was randomised and is unknown, so you will need to set it for connectivity.  As calls to the OraOperator controllers are declarative you will be instructing the Controller to modify the ADB to the newly defined, desired state.  

Additionally, the ADB was provisioned with mTLS, so you will need a Wallet to connect to the ADB securely.  You'll create a Secret for the Wallet password and the OraOperator will download the wallet into another Secret.

In Cloud Shell, assign the `ADB_PWD` variable a password (for Workshop purposes only).  You can choose any password so long as it complies with the [Password Complexity](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/manage-users-create.html#GUID-72DFAF2A-C4C3-4FAC-A75B-846CC6EDBA3F) rules.

For example:

```bash
<copy>
ADB_PWD=$(echo "K8s4DBAs_$(date +%H%S%M)")
</copy>
```

Start a manifest file to create a Secret and apply it to the exiting ADB:

```bash
<copy>
cat > adb_modify.yaml << EOF
---
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: adb-admin-password
stringData:
  adb-admin-password: $ADB_PWD
---
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: adb-instance-wallet-password
stringData:
  adb-instance-wallet-password: $ADB_PWD
---
apiVersion: database.oracle.com/v1alpha1
kind: AutonomousDatabase
metadata:
  name: adb-existing
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

Take a quick look at the syntax:  

You are defining two resources of `kind: Secret` of `type: Opaque`.  The first is named: `adb-admin-password` and the second is named: `adb-instance-wallet-password`.  The last part of the manifest **redefines** the `adb-existing` resource, setting the adminPassword and wallet.  Under the wallet section, you are specifying the name of the `Secret`, `adb-tns-admin` that will be defined to to store the wallet.

## Task 6: Apply Manifest

Apply the manifest in Cloud Shell:

```bash
<copy>
kubectl apply -f adb_modify.yaml
</copy>
```

Output:

```text
secret/adb-admin-password created
secret/adb-instance-wallet-password created
autonomousdatabase.database.oracle.com/adb-existing configured
```

## Task 7: Review ADB Secrets

Get the Secrets in the ADB namespace (`kubectl get secrets -n <namespace>`):

```bash
<copy>
kubectl get secrets
</copy>
```

Output:

![ADB Secrets](images/adb_secrets.png "ADB Secrets")

You created the first two and instructed OraOperator to create the third `adb-tns-admin`.  Take a closer look at the **adb-tns-admin** secret by describing it (`kubectl describe secrets <secret_name> -n <namespace>`):

```bash
<copy>
kubectl describe secrets adb-tns-admin
</copy>
```

Output:

![kubectl describe secrets adb-tns-admin -n adb](images/adb_tns_admin.png "kubectl describe secrets adb-tns-admin -n adb")

You'll see what equates to a `TNS_ADMIN` directory, and in fact, this Secret will be used by applications for just that purpose.

## Learn More

* [Oracle Autonomous Database](https://www.oracle.com/uk/autonomous-database/)
* [OCI - Instance Principal](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/callingservicesfrominstances.htm)
* [Kubernetes Secrets](https://K8s.io/docs/concepts/configuration/secret/)

## Acknowledgements

* **Author** - John Lathouwers, Developer Advocate, Database Development Operations
* **Last Updated By/Date** - John Lathouwers, May 2023
