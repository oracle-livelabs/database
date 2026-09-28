# Use True Cache through JDBC

## Introduction

This lab validates the JDBC behavior that keeps one logical connection while routing eligible read-only work to True Cache. Read-write work remains on the Primary database.

*Estimated Time:* 10 minutes.

Use one shell for this lab. After entering the application container, run the commands directly in that shell.

## Objectives

- Validate JDBC read routing with the supplied BasicApp.
- Confirm that the read-only operation reaches True Cache while writes remain on Primary.

## Task 1: Open the Application Container

From the desktop Terminal, load the lab environment and open the application container. The environment file contains the generated Transactions password used by the lab services. Do not use the VNC password or a sample password.

~~~text
<copy>
source /home/opc/.truecache_lab_env
sudo podman exec -e DB_PASS="$DB_PASS" -it appclient /bin/bash
cd /stage/clientapp
</copy>
~~~

If `prod` or `truedb` was restarted after Initialize Environment, verify the database services before running the application. The proxy normally performs this reconciliation automatically. Use the idempotent service-start commands in Initialize Environment only when the service query is empty.

## Task 2: Validate JDBC Routing

Run the supplied BasicApp from the application container:

~~~text
<copy>
cd /stage/clientapp/BasicApp
/stage/jdk-17.0.6/bin/java -cp ojdbc8.jar:. TrueCache 172.20.1.2:1521/sales1 transactions "$DB_PASS"
cd /stage/clientapp
</copy>
~~~

The result identifies the database role used by the read-only operation. When True Cache is configured and the work is marked read-only, the JDBC driver can route eligible read-only queries to True Cache; read-write operations remain on the Primary database.

## Completion

The routing validation is complete when the output shows the Primary role first and then the True Cache role on service `SALES1_TC`.

## Next Lab

Continue to [Performance Comparison and Lag Observability](../performance/performance_dbw26.md).

## Acknowledgements

* **Authors** - Sambit Panda, Consulting Member of Technical Staff, Oracle Database Product Management
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Jyoti Verma, Nithin Thekkupadam Narayanan, Sarvesh Gupta
* **Last Updated By/Date** - Sambit Panda, Consulting Member of Technical Staff, Sep 2026
