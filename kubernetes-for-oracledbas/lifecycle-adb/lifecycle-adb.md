# Lifecycle Operations - Oracle Autonomous Database (ADB)

## Introduction

In this lab, we use the OraOperator to perform Lifecycle operations against an Oracle Autonomous Database (ADB).

*Estimated Lab Time:* 5 minutes

Watch the video below for a quick walk through of the lab.
[](youtube:zNKxJjkq0Pw)

### Objectives

* Perform Lifecycle Operations on an ADB using the OraOperator

### Prerequisites

This lab assumes you have:

* A Running and Healthy OraOperator
* The OraOperator bound to an ADB

## Task 1: Retrieve the ADB OCID

COMPARTMENT_OCID=$(oci iam compartment list --name K8S4DBAS | jq -r '.data[].id')
ADB_OCID=$(oci db autonomous-database list --compartment-id $COMPARTMENT_OCID | jq -r '.data[].id')

## Task 1: Download the Wallet/TNSNames

export ORACLE_HOME=$(pwd)
export TNS_ADMIN=$ORACLE_HOME/network/admin
mkdir -p $ORACLE_HOME/network/admin

kubectl get secret/adb-tns-admin -n adb --template="{{ index .data \"tnsnames.ora\" | base64decode }}" > $ORACLE_HOME/network/admin/tnsnames.ora

kubectl get secret/adb-tns-admin -n adb --template="{{ index .data \"sqlnet.ora\" | base64decode }}" > $ORACLE_HOME/network/admin/sqlnet.ora

kubectl get secret/adb-tns-admin -n adb --template="{{ index .data \"cwallet.sso\" | base64decode }}" > $ORACLE_HOME/network/admin/cwallet.sso

## Task 2: Manage ADMIN password

set +o history

NOW=$(date +%y%m%d)
ADMIN_PWD=$(echo "Welcome_$NOW")
echo $ADMIN_PWD

cat > adb_admin_pwd.yaml << EOF
apiVersion: v1
stringData:
  adb-admin-password-$NOW: $ADMIN_PWD
kind: Secret
metadata:
  labels:
    app.kubernetes.io/part-of: database
  name: adb-admin-password-$NOW
  namespace: adb
type: Opaque
---
apiVersion: database.oracle.com/v1alpha1
kind: AutonomousDatabase
metadata:
  name: adb
  namespace: adb
spec:
  details:
    autonomousDatabaseOCID: $ADB_OCID
    adminPassword:
      k8sSecret:
        name: adb-admin-password-$NOW
EOF

kubectl apply -f adb_admin_pwd.yaml
rm adb_admin_pwd.yaml
set -o history

## Task 3: Manually Connect to the ADB

sqlplus /nolog
connect admin@eagledb_high

## Task 4: Scale the OCPU and Storage

cat > adb_cpu_up.yaml << EOF
---
apiVersion: database.oracle.com/v1alpha1
kind: AutonomousDatabase
metadata:
  name: adb
  namespace: adb
spec:
  details:
    autonomousDatabaseOCID: $ADB_OCID
    cpuCoreCount: 2
    dataStorageSizeInTBs: 2
    isAutoScalingEnabled: false
EOF

cat > adb_cpu_down.yaml << EOF
---
apiVersion: database.oracle.com/v1alpha1
kind: AutonomousDatabase
metadata:
  name: adb
  namespace: adb
spec:
  details:
    autonomousDatabaseOCID: $ADB_OCID
    cpuCoreCount: 1
    dataStorageSizeInTBs: 1
    isAutoScalingEnabled: false
EOF

These could be separated into different operations.  For example, just to scale the CPU:

```bash
---
apiVersion: database.oracle.com/v1alpha1
kind: AutonomousDatabase
metadata:
  name: adb
  namespace: adb
spec:
  details:
    autonomousDatabaseOCID: $ADB_OCID
    cpuCoreCount: 5
    isAutoScalingEnabled: false
```

We can also do manually:

kubectl edit autonomousdatabase adb -n adb

## Task 7: Create Manual Backup



apiVersion: database.oracle.com/v1alpha1
kind: AutonomousDatabaseBackup
metadata:
  name: adb-ad-hoc
  namespace: adb
spec:
  target:
    k8sADB:
      name: adb
  displayName: adb-ad-hoc

## Task 8: Restore from Backup

kubectl get AutonomousDatabaseBackup -n adb
BACKUP_NAME=$(kubectl get AutonomousDatabaseBackup -n adb | tail -n 1 | awk '{print $1}')

cat > adb_restore.yaml << EOF
---
apiVersion: database.oracle.com/v1alpha1
kind: AutonomousDatabaseRestore
metadata:
  name: adb-ad-hoc-restore
  namespace: adb
spec:
  target:
    k8sADB:
      name: adb
  source:
    k8sADBBackup:
      name: $BACKUP_NAME
    # Uncomment the below fields to perform PIT restore
    # pointInTime:
    #   timestamp: 2022-12-23 11:03:13 UTC
EOF

kubectl get adb -n adb
kubectl describe adb adb-ad-hoc-restore -n adb

## Task 6: Manually Stop and Start an Autonomous Database

---
apiVersion: database.oracle.com/v1alpha1
kind: AutonomousDatabase
metadata:
  name: adb
  namespace: adb
spec:
  details:
    lifecycleState: STOPPED

Copy:
kubectl patch adb adb -n adb -p '{"spec":{"details":{"lifecycleState":"STOPPED"}}}' --type=merge

---
apiVersion: database.oracle.com/v1alpha1
kind: AutonomousDatabase
metadata:
  name: adb
  namespace: adb
spec:
  details:
    lifecycleState: AVAILABLE

Copy:
kubectl patch autonomousdatabase adb -n adb -p '{"spec":{"details":{"lifecycleState":"AVAILABLE"}}}' --type=merge

## Schedule Start/Stop Jobs

### Grant Permissions

Create a role and bind it to the service account to provide the required access. In this case, we will use the "default" service account:

cat > adb_role.yaml << EOF
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: autonomousdatabases-reader
  namespace: adb
rules:
- apiGroups: ["database.oracle.com"]
  resources: ["autonomousdatabases"]
  verbs: ["get", "list", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: autonomousdatabases-reader-binding
  namespace: adb
subjects:
- kind: ServiceAccount
  name: default
  namespace: adb
roleRef:
  kind: Role
  name: autonomousdatabases-reader
  apiGroup: rbac.authorization.k8s.io
EOF

After applying the Role and RoleBinding, the service account "default" in the "adb" namespace should have the necessary permissions to access the "autonomousdatabases" resource in the "database.oracle.com" API group.

### Schedule a CronJob

cat > adb_cron.yaml << EOF
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: adb-stop
  namespace: adb
spec:
  concurrencyPolicy: Forbid
  schedule: '30 18 ** *'
  jobTemplate:
    spec:
      ttlSecondsAfterFinished: 86400
      backoffLimit: 2
      activeDeadlineSeconds: 600
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: kubectl
              image: bitnami/kubectl
              command:
                - 'kubectl'
                - 'patch'
                - 'autonomousdatabase'
                - 'adb'
                - '-n'
                - 'adb'
                - '-p'
                - '{"spec":{"details":{"lifecycleState":"STOPPED"}}}'
                - '--type=merge'
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: adb-stop
  namespace: adb
spec:
  concurrencyPolicy: Forbid
schedule: '30 8* **'
  jobTemplate:
    spec:
      ttlSecondsAfterFinished: 86400
      backoffLimit: 2
      activeDeadlineSeconds: 600
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: kubectl
              image: bitnami/kubectl
              command:
                - 'kubectl'
                - 'patch'
                - 'autonomousdatabase'
                - 'adb'
                - '-n'
                - 'adb'
                - '-p'
                - '{"spec":{"details":{"lifecycleState":"AVAILABLE"}}}'
                - '--type=merge'
EOF

kubectl get cronjob -n adb
kubectl get jobs --watch -n adb

## Learn More

* [Oracle Autonomous Database](https://www.oracle.com/uk/autonomous-database/)
* [Kubernetes CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)

## Acknowledgements

* **Author** - John Lathouwers, Developer Advocate, Database Development Operations
* **Last Updated By/Date** - John Lathouwers, May 2023
