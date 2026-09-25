# Use True Cache through JDBC

## Introduction

In this lab, you will test the connection to True Cache using JDBC and run a transaction processing application against the primary database ,and then against True Cache to observe the performance improvement. 

Estimated Time: 10 minutes

<if type="nonsandbox">
Watch the video for a quick walk through of the Lab3.
[Lab3](videohub:1_wx3n5ug3)
</if>

### About True Cache using JDBC
The application maintains a single logical connection using the database application service name of the primary database. The JDBC Thin driver (Oracle Database 23ai and later) establishes two physical connections. The read/write split between True Cache and the primary database is controlled by the application through special calls that designate the logical connection as either read-only or read-write. This mode is supported only for JDBC-based applications.

The application used in this lab is a transaction processing application that performs various operations against a database. These operations include retrieving a customer's balance, fetching customer details and updating the balance. Each thread simulates a user performing different operations. 

### Objectives

In this lab, you will:
* Run the application while connecting to the primary database 
* Run the application while connecting to True Cache and observe the performance difference

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

2. Run the application by running TransactionsApp.sh , This first runs the application against the primary database for 2 minutes. Then it identifies the tables and index in the schema and does a wamrup to populate the True Cache. Then it runs the application against True Cache for 2 minutes with 50 threads.
    
    ```
    <copy>
     sh TransactionsApp.sh
    </copy>
    ```
    ![transaction app](https://oracle-livelabs.github.io/database/truecache/jdbc/images/transactionapp_dbw25.png " ")

3. Observe the improvement in performance while using True Cache compare to primary.

4. You can change TransactionApp.sh, to increase the number of users and the duration of the test.

5. You might see a error like the one shown below after the load completes. Ignore this error, as it occurs due to UCP  closing the true cache driver connection.
    ![transaction app error](https://oracle-livelabs.github.io/database/truecache/jdbc/images/transactionapperror.png " ")

## Learn More

[True Cache documentation] (https://docs.oracle.com/en/database/oracle/oracle-database/23/odbtc/using-oracle-true-cache-your-applications.html)


## Acknowledgements
* **Authors** - Sambit Panda, Consulting Member of Technical Staff , Vivek Vishwanathan Software Developer, Oracle Database Product Management
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Jyoti Verma, Ilam Siva
* **Last Updated By/Date** - Sambit Panda, Consulting Member of Technical Staff, Aug 2025
