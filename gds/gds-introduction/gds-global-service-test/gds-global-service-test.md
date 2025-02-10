# Prepare a sample Schema and Test Global Service

Once GDS's Global service(s) are configured, those can be used in database connect strings. These connect strings can be used from client-sides e.g., using SQL, PL/SQL, Java, python etc.

*Estimated Time*:  15 minutes

### Objectives

In this lab, you will:

* Use Global services connection.
* Prepare a sample schema.
* Run a sample shell script to from the appclient container to insert records.
* Prepare a jdbc connect string using global service to be used with Java based application.

### Prerequisites

This lab assumes you have:
* A Free Tier, Paid or LiveLabs Oracle Cloud account
* You have completed:
    * Lab: Validate workshop environment
    * Lab: GDS Installation
    * Lab: Database updates to enable GDS
    * Lab: GDS Configuration using GDSCTL

## 
## Task 1: Create a schema from "appclient" podman container

1. Run the below command on the new terminal window that is logged in as **oracle** user.

```
<copy>
sudo podman exec -i -t appclient /bin/bash
su - oracle
</copy>
```

2. Using a Global service, prepare app_schema

```
<copy>
# View the contents of a shell script which creates a schema using a database connection with global service:
cat appclient_schema_prep.sh

# Run the script to prepare app_schema as below:
./appclient_schema_prep.sh
</copy>
```

3. Verify the output of prepare app_schema

![<app_schema-create>](./images/app_schema-create.png " ")

## Task 2: Insert records in app_schema.emp table from "appclient" podman container

We are Using a Global service connection in "insert_records.sh".

```
<copy>
# View the contents of a shell script which continuously inserts records in app_schema.emp table using a database connection with global service
cat insert_records.sh

# Run the script
./insert_records.sh
</copy>
```

5. Verify the output of insert records in app_schema

![<insert_records>](./images/insert_records.png " ")

This result shows the "HOST_NAME" value as primary database in Data-Guard configuration which is currently set to "primary". Global service connects with the current primary database.


## Task 3. Test Global service connection string with both gsms (for load-balance / disaster recovery)

1. Connect app_schema using Global service connection string with both gsms for load-balance / disaster recovery like below:

```
<copy>
sqlplus app_schema/Oracle_23ai@'(DESCRIPTION=(FAILOVER=ON)(CONNECT_TIMEOUT=5)(TRANSPORT_CONNECT_TIMEOUT=3)(RETRY_COUNT=3)(ADDRESS_LIST=(ADDRESS=(HOST=gsm1.example.com)(PORT=1522)(PROTOCOL=tcp))(ADDRESS=(HOST=gsm2.example.com)(PORT=1522)(PROTOCOL=tcp)) )(CONNECT_DATA=(SERVICE_NAME=gds01_rw_srvc_1.dbpoolora.gds01)))';
</copy>
```

2. How to connect Application using JDBC URL of Global service? (optional)

For example using the global service "gds01\_rw\_srvc\_1.dbpoolora\.gds01":

```nohighlighting
jdbc:oracle:thin:@((DESCRIPTION=(FAILOVER=ON)(CONNECT_TIMEOUT=5)(TRANSPORT_CONNECT_TIMEOUT=3)(RETRY_COUNT=3)(ADDRESS_LIST=(ADDRESS=(HOST=gsm1.example.com)(PORT=1522)(PROTOCOL=tcp))(ADDRESS=(HOST=gsm2.example.com)(PORT=1522)(PROTOCOL=tcp)) )(CONNECT_DATA=(SERVICE_NAME=gds01_rw_srvc_1.dbpoolora.gds01)))
```

Note: Such Global Service's JDBC URL can be used from application to connect Oracle database via Global Service.

This completes Global service usage and its verification by insert records in a sample application schema.

You may now **proceed to the next lab**.
