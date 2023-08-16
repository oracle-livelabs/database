# Use True Cache through JDBC

## Introduction


Estimated Lab Time: 10 minutes

### About True Cache using JDBC
The Application maintains one logical connection by using the single database application service name of the primary database, and the JDBC Thin driver (Oracle Database 23c and later) maintains two physical connections. The read/write split between True Cache and primary database instances is controlled by the application through special calls to flag the logical connection as read-only or read-write. This mode is only for JDBC-based applications.

The application used here is a transaction processing application, which does various transaction operations against a database. Some of the operations include, get balance of the customer, get customer details, update balance. Each thread simulates a user performing different operations. 

### Objectives

In this lab, you will:
* Run the application while connecting to primary database 
* Run the application while connecting to true cache and observe the difference in performance

### Prerequisites (Optional)

This lab assumes you have:
* An Oracle Cloud account
* All previous labs successfully completed

## Task 1: Run the application

1. Set JAVA_HOME by running the setjava17.sh

2. Test the connection to true cache by running the BasicApp.sh. The successful outcome of the script 
makes sure that jdbc is able to connect to true cache instance through the oracle.jdbc.useTrueCacheDriverConnection=true parameter.
2. Run the application by running TransactionApp.sh , this will first run the application against primary for 2 minutes than it will run the application against true cache instance for 2 minutes with 50 threads.

3. Observe the improve in performance while using true cache.

4. You could modify the TransactionApp.sh, to increase the number of users and duration of the test.

## Learn More

-  **Oracle True Cache ** 
[True Cache documentation for internal purposes] (https://docs-uat.us.oracle.com/en/database/oracle/oracle-database/23/odbtc/oracle-true-cache.html#GUID-147CD53B-DEA7-438C-9639-EDC18DAB114B)


## Acknowledgements
* **Authors** - Sambit Panda, Consulting Member of Technical Staff , Vivek Vishwanathan Software Developer, Oracle Database Product Management
* **Contributors** - Pankaj Chandiramani, Shefali Bhargava, Param Saini, Thirumalai Thathachary
* **Last Updated By/Date** - Vivek Vishwanathan ,Software Developer, Oracle Database Product Management, August 2023
