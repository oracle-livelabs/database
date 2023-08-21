# Load data into database

## Introduction

In this lab, you will create the transaction processing schema and load data into it.

*Estimated Time:* 20 minutes

### About Oracle True Cache
Modern applications often require massive scalability in terms of both the number of connections and the amount of data that can be cached.

A popular approach is to place caches in front of the database. Those caches rely on the fact that applications often don't need to see the most current data. For example, when someone browses a flight reservation system, the system can show flight data that's one second old. When someone reserves a flight, then the system shows the most current data.

Oracle True Cache satisfies queries by using only data from its buffer cache. Like Oracle Active Data Guard, True Cache is a fully functional, read-only replication of the primary database, except that it's mostly diskless.

### Objectives


In this lab, you will:
* Find how to create a  schema in in the newly created env, create tables.
* Upload data to those tables

### Prerequisites (Optional)

This lab assumes you have:
* An Oracle Cloud account
* All previous labs successfully completed

## Task 1: Create user and tables

1. Open a terminal window and connect to the podman container for primary database

    ```
    <copy>
    podman exec -it dbmc1 /bin/bash
    </copy>
    ```
![primary database](https://oracle-livelabs.github.io/database/truecache/data-load/images/dataload.png " ")
2. Connect to the database as a sysdba user
    ```
    <copy>
    sqlplus / as sysdba
    </copy>
    ```

3. Alter session to login to PDB
    ```
    <copy>
    alter session set container=PRODPDB;
    </copy>
    ```

4. Execute step1 as the sysdba user. This will create the transaction user and provide necessary permission to the transactions user.

![dataload step1](https://oracle-livelabs.github.io/database/truecache/data-load/images/dataloadstep1.png " ")

4. Log on to SALES service as the transactions user and run the step2 and step3.

![dataload step3](https://oracle-livelabs.github.io/database/truecache/data-load/images/dataloadstep3.png " ")

## Task 2: Load data into tables

1. Run step4 as the transactions user
![dataload step4](https://oracle-livelabs.github.io/database/truecache/data-load/images/dataloadstep4.png " ")

2. After completion of step4, it should display the commit complete message.
![dataload commit](https://oracle-livelabs.github.io/database/truecache/data-load/images/dataloadcommit.png " ")

## Task 3: Verify True Cache 

1. Open a terminal window and connect to the podman container for true cache.
    ```
    <copy>
    podman exec -it tcmc1 /bin/bash
    </copy>
    ```
![dataload truecache](https://oracle-livelabs.github.io/database/truecache/data-load/images/dataloadtruecache.png " ")

2. Login to the database using the transaction user.
![dataload truecache login](https://oracle-livelabs.github.io/database/truecache/data-load/images/dataloadtruecachelogin.png " ")


3. Verify the role of the database.
![dataload truecache verify](https://oracle-livelabs.github.io/database/truecache/data-load/images/dataloadtruecacheverify.png " ")

You may now proceed to the next lab.

## Learn More
[True Cache documentation for internal purposes] (https://docs-uat.us.oracle.com/en/database/oracle/oracle-database/23/odbtc/oracle-true-cache.html#GUID-147CD53B-DEA7-438C-9639-EDC18DAB114B)

## Acknowledgements
* **Authors** - Sambit Panda, Consulting Member of Technical Staff , Vivek Vishwanathan Software Developer, Oracle Database Product Management
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Param Saini, Thirumalai Thathachary
* **Last Updated By/Date** - Vivek Vishwanathan ,Software Developer, Oracle Database Product Management, August 2023
