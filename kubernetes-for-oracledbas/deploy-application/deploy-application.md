# Deploy Microservice Application

## Introduction

You will deploy an Microservice Application which will create a new user in the Database via Liquibase and use the new user access the Oracle Database.

The application will be the SQL Web Developer from Oracle Rest Data Services (ORDS).

*Estimated Lab Time:* 20 minutes

Watch the video below for a quick walk through of the lab.
[](youtube:zNKxJjkq0Pw)

### Objectives

* Have a running Microservice Application connected to the Oracle Database

### Prerequisites

This lab assumes you have:

* [Generated a Kubeconfig File](?lab=generate-kubeconfig)
* A [Running and Healthy OraOperator](?lab=deploy-oraoperator)
* The [OraOperator bound to an ADB](?lab=bind-adb)

## Task 1: Create a Namespace

In K8s, a *Namespace* is a virtual cluster that provides a way to divide the physical K8s cluster resources logically between multiple users or teams.  Additionally, Namespaces enable fine-grained control over access and resource allocation.  By defining appropriate Role-Based Access Control (RBAC) policies, you can control which users or groups have access to specific resources within Namespaces.  You'll see an example of this when scheduling a Stop/Start CronJob.

In Cloud Shell, create a namespace for the Microservice Application:

```bash
<copy>
kubectl create namespace sqldev-web
</copy>
```

Output:

```text
namespace/adb created
```

### Namespace Best Practices

* For production clusters, avoid using the `default` namespace. Instead, make other namespaces and use those.
* Avoid creating namespaces with the prefix `kube-`, it is reserved for K8s system namespaces.

## Task 2: Create the Database Secrets

Your application will want to talk to the Oracle Database and to do so, just like a non-Microservice application, will need both Authentication credentials and Database (Names) Resolution strings.  Whether you use Oracle Enterprise User Security and LDAP or username/passwords and TNS_ADMIN, the general requirements will be the same.

Set some variables to assist in creating the K8s manifests.  Use the Secrets and data from the AutonomousDatabase resources in the `adb` namespace:

```bash
<copy>
ADB_PWD=$(kubectl get secrets/adb-admin-password -n adb \
    --template="{{index .data \"adb-admin-password\" | base64decode}}")

SERVICE_NAME=$(kubectl get adb -n adb -o json | jq -r .items[0].spec.details.dbName)_TP
</copy>
```

```bash
<copy>
cat > sqldev-web.yaml << EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: db-secrets
type: Opaque
stringData:
  db.username: ADMIN
  db.password: ${ADB_PWD}
  db.service_name: ${SERVICE_NAME}
  ords.password: ${ADB_PWD}
EOF
<copy>
```

For the Database (Names) Resolution, copy the wallet secret from the `adb` namespace to the `sqlweb-dev` namespace.  This can be done with a `kubectl` one-liner:

```bash
<copy>
kubectl get secret adb-tns-admin -n adb -o json | 
    jq 'del(.metadata | .ownerReferences, .namespace, .resourceVersion, .uid)' | 
    kubectl apply -n sqldev-web -f -
</copy>
```

The above command will export the `adb-tns-admin` secret to YAML, replace the `namespace` field to the new namespace, and load the secret back into K8s.

## Task 3: Create the ConfigMaps

You'll create two ConfigMaps, one will be the ORDS configuration file and the other will be a Liquibase ChangeLog.

### ORDS Configuration

```bash
<copy>
cat > sqldev-web.yaml << EOF
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: ords-config
  labels:
    name: ords-config
data:
  pool.xml: |-
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
    <properties>
    <entry key="feature.sdw">true</entry>
    <entry key="restEnabledSql.active">true</entry>
    <entry key="db.connectionType">tns</entry>
    <entry key="db.tnsDirectory">/opt/oracle/ords/network/admin</entry>
    <entry key="db.tnsAliasName">${SERVICE_NAME}</entry>
    <entry key="db.username">ORDS_PUBLIC_USER_K8</entry>
    <entry key="plsql.gateway.mode">proxied</entry>
    </properties>
EOF
<copy>
```

### Liquibase ChangeLog

```bash
<copy>
cat >> sqldev-web.yaml << EOF
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: liquibase-changelog
data:
  liquibase.sql: "liquibase update -chf changelog.sql"
  changelog.sql: |-
    -- liquibase formatted sql

    -- changeset gotsysdba:1 endDelimiter:/
    DECLARE
        L_USER  VARCHAR2(255);
    BEGIN
        BEGIN
            SELECT USERNAME INTO L_USER FROM DBA_USERS WHERE USERNAME='ORDS_PUBLIC_USER_K8';
            execute immediate 'ALTER USER "ORDS_PUBLIC_USER_K8" IDENTIFIED BY "\${ORDS_PWD}"';
        EXCEPTION WHEN NO_DATA_FOUND THEN
            execute immediate 'CREATE USER "ORDS_PUBLIC_USER_K8" IDENTIFIED BY "\${ORDS_PWD}"';
        END;
        BEGIN
            SELECT USERNAME INTO L_USER FROM DBA_USERS WHERE USERNAME='ORDS_PLSQL_GATEWAY_K8';
            execute immediate 'ALTER USER "ORDS_PLSQL_GATEWAY_K8" IDENTIFIED BY "\${ORDS_PWD}"';
        EXCEPTION WHEN NO_DATA_FOUND THEN
            execute immediate 'CREATE USER "ORDS_PLSQL_GATEWAY_K8" IDENTIFIED BY "\${ORDS_PWD}"';
        END;
    END;    
    /
    --rollback drop user "DEMO" cascade;

    -- changeset gotsysdba:2
    GRANT CONNECT TO ORDS_PUBLIC_USER_K8;
    ALTER USER ORDS_PUBLIC_USER_K8 PROFILE ORA_APP_PROFILE;
    GRANT CONNECT TO ORDS_PLSQL_GATEWAY_K8;
    ALTER USER ORDS_PLSQL_GATEWAY_K8 PROFILE ORA_APP_PROFILE;
    ALTER USER ORDS_PLSQL_GATEWAY_K8 GRANT CONNECT THROUGH ORDS_PUBLIC_USER_K8;

    -- changeset gotsysdba:3 endDelimiter:/
    BEGIN
        ORDS_ADMIN.PROVISION_RUNTIME_ROLE (
            p_user => 'ORDS_PUBLIC_USER_K8',
            p_proxy_enabled_schemas => TRUE
        );
    END;
    /

    -- changeset gotsysdba:4 endDelimiter:/
    BEGIN
        ORDS_ADMIN.CONFIG_PLSQL_GATEWAY (
            p_runtime_user => 'ORDS_PUBLIC_USER_K8',
            p_plsql_gateway_user => 'ORDS_PLSQL_GATEWAY_K8'
        );
    END;
    /
EOF
<copy>
```

## Task 4: Create the Deployment

```bash
<copy>
cat >> sqldev-web.yaml << EOF
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: sqldev-web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sqldev-web
  template:
    metadata:
      labels:
        app: sqldev-web
    spec:
      initContainers:
      - name: liquibase
        image: container-registry.oracle.com/database/sqlcl:23.1.0
        imagePullPolicy: IfNotPresent
        args: ["-L", "-nohistory", "\$(LB_COMMAND_USERNAME)/\$(LB_COMMAND_PASSWORD)@\$(LB_COMMAND_URL)", "@liquibase.sql"]
        env:
        - name: ORDS_PWD
          valueFrom:
            secretKeyRef:
              name: db-secrets
              key: ords.password
        - name: LB_COMMAND_SERVICE
          valueFrom:
            secretKeyRef:
              name: db-secrets
              key: db.service_name
        - name: LB_COMMAND_URL
          value: jdbc:oracle:thin:@\$(LB_COMMAND_SERVICE)?TNS_ADMIN=/opt/oracle/network/admin
        - name: LB_COMMAND_USERNAME
          valueFrom:
            secretKeyRef:
              name: db-secrets
              key: db.username
        - name: LB_COMMAND_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secrets
              key: db.password
        volumeMounts:
        - mountPath: /opt/oracle/network/admin
          name: tns-admin
          readOnly: true
        - mountPath: /opt/oracle/sql_scripts
          name: liquibase-changelog
          readOnly: true
      containers:
        - image: "container-registry.oracle.com/database/ords:23.1.3"
          imagePullPolicy: IfNotPresent
          name: sqldev-web
          lifecycle:
            postStart:
              exec:
                command:
                  - /bin/bash
                  - -c
                  - |
                    ords --config "\$ORDS_CONFIG" config secret --password-stdin db.password <<< \$(ORDS_PWD)
          #command: ["sh", "-c", "tail -f /dev/null"]
          command: ["ords --config \$ORDS_CONFIG serve"]
          env:
            - name: ORDS_CONFIG
              value: /etc/ords/config
            - name: ORACLE_HOME
              value: /opt/oracle/ords
            - name: ORDS_PWD
              valueFrom:
                secretKeyRef:
                  name: db-secrets
                  key: ords.password
            - name: LB_COMMAND_SERVICE
              valueFrom:
                secretKeyRef:
                  name: db-secrets
                  key: db.service_name
          volumeMounts:
            - name: ords-config
              mountPath: "/etc/ords/config/databases/default/"
              readOnly: true
            - name: ords-wallet
              mountPath: "/etc/ords/config/databases/default/wallet"
              readOnly: false
            - name: tns-admin
              mountPath: "/opt/oracle/ords/network/admin"
              readOnly: true
            - name: liquibase-changelog
              mountPath: "/opt/oracle/sql_scripts"
              readOnly: true
          ports:
            - containerPort: 8080
          resources:
            limits:
              cpu: 100m
              memory: 512Mi
            requests:
              cpu: 50m
              memory: 256Mi
#          securityContext:
#            capabilities:
#              drop:
#                - ALL
#            runAsNonRoot: true
#            runAsUser: 1978
#            readOnlyRootFilesystem: false
#            allowPrivilegeEscalation: false
      volumes:
        - name: ords-config
          configMap:
            name: ords-config
        - name: ords-wallet
          emptyDir: {}
        - name: liquibase-changelog
          configMap:
            name: liquibase-changelog
        - name: tns-admin
          secret:
            secretName: adb-tns-admin
EOF
<copy>
```

## Task 5: Deploy the Application

```bash
<copy>
kubectl apply -f sqldev-web.yaml -n sqldev-web
</copy>
```

## Task 5: Create the Service

```bash
<copy>
cat > open_app.yaml << EOF
---
apiVersion: v1
kind: Service
metadata:
  name: sqldev-web
spec:
  selector:
    app: sqldev-web
  ports:
    - name: http
      port: 80
      targetPort: 8080
EOF
<copy>
```

## Task 5: Create the Ingress

```bash
<copy>
cat >> open_app.yaml << EOF
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sqldev-web
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: sqldev-web
            port:
              number: 80
EOF
<copy>
```

## Task 6: Access your new Microservice Application

## Learn More

* [SQLcl](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/23.1/index.html)
* [Liquibase](https://www.liquibase.org/)

## Acknowledgements

* **Author** - John Lathouwers, Developer Advocate, Database Development Operations
* **Last Updated By/Date** - John Lathouwers, May 2023
