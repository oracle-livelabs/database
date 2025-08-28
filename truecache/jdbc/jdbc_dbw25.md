# Use True Cache through JDBC

## Introduction

In this lab, you will test the connection to True Cache through JDBC and run the transaction processing application against the primary database first, then against True Cache to observe the improvement in performance. 

Estimated Time: 10 minutes

### About True Cache using JDBC
The application maintains one logical connection by using the database application service name of the primary database, and the JDBC Thin driver (Oracle Database 23ai and later) maintains two physical connections. The read/write split between True Cache and the primary database is controlled by the application through special calls to flag the logical connection as read-only or read-write. This mode is only for JDBC-based applications.

The application used here is a transaction processing application, which does various transaction operations against a database. Some of the operations include, get the balance of the customer, get customer details and update the balance. Each thread simulates a user performing different operations. 

### Objectives

In this lab, you will:
* Run the application while connecting to the primary database 
* Run the application while connecting to True Cache and observe the difference in performance

### Prerequisites (Optional)

This lab assumes you have:
* An Oracle Cloud account
* All previous labs successfully completed

## Task 1: Run the application

1. Login to application podman container

    ```
    <copy>
    sudo podman exec -it appclient /bin/bash
    </copy>
    ```
![app container](https://oracle-livelabs.github.io/database/truecache/jdbc/images/appcontainer.png " ")

2. Go to the directory /stage/clientapp 

     ```
    <copy>
     cd /stage/clientapp
    </copy>
    ```

2. Run the application by running TransactionApp.sh , This first runs the application against the primary database for 2 minutes. Then it identifies the tables and index in the schema and does a wamrup to populate the True Cache. Then it runs the application against True Cache for 2 minutes with 50 threads.
    
    ```
    <copy>
     sh TransactionApp.sh
    </copy>
    ```
![transaction app](https://oracle-livelabs.github.io/database/truecache/jdbc/images/transactionapp_dbw25.png " ")

3. Observe the improve in performance while using True Cache.

4. You can change TransactionApp.sh, to increase the number of users and the duration of the test.

## Learn More

[True Cache documentation for internal purposes] (https://docs-uat.us.oracle.com/en/database/oracle/oracle-database/23/odbtc/oracle-true-cache.html#GUID-147CD53B-DEA7-438C-9639-EDC18DAB114B)


## Acknowledgements
* **Authors** - Sambit Panda, Consulting Member of Technical Staff , Vivek Vishwanathan Software Developer, Oracle Database Product Management
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Param Saini, Thirumalai Thathachary
* **Last Updated By/Date** - Vivek Vishwanathan ,Software Developer, Oracle Database Product Management, August 2023
