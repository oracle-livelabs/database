# Configure ORDS

## Introduction

Oracle Rest Data Service (ORDS) is a service that allows you to connect to the Oracle Database and use CRUD operations through REST calls. In this lab, you will setup ORDS to be used on the 23c Free Developer Release database. 

Estimated Time: 5 minutes


### Objectives

In this lab, you will:

- Create a new schema for ORDS
- Install ORDS on the database
- Enable the ORDS Schema and allow anonymous access

### Prerequisites

This lab assumes you have:
- An instance with 23c Free Developer Release database installed
- Access to the instance's remote desktop


## Task 1: Download the graph setup materials


1. Click Activities in the upper left corner, then click Terminal.

    ![Insert alt text](images/example.png)

2. Go into the right directory.

    ```
    $ <copy>cd ~/examples</copy>
    ```

    ![Insert alt text](images/example.png)

3. Pull down the materials for setup.

    ```
    $ <copy>wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/23cfree-property-graph.zip</copy>
    ```

    ![Insert alt text](images/example.png)

4. Unzip the file.

    ```
    $ <copy>unzip -o 23cfree-property-graph.zip</copy>
    ```

    ![Insert alt text](images/example.png)

3. Remove the remaining zip file after you've unzpped it.

    ```
    $ <copy>rm -rf 23cfree-property-graph.zip</copy>
    ```

    ![Insert alt text](images/example.png)

## Task 2: Open SQL Developer

1. Get into the correct directory to open SQL Developer.

    ```
    $ <copy>cd /opt/sqldeveloper/</copy>
    ```

    ![Insert alt text](images/example.png)

2. Run the command to start up SQL Developer.

    ```
    $ <copy>./sqldeveloper.sh</copy>
    ```

    ![Insert alt text](images/example.png)

3. On the left side menu, you'll see hol23c_freepdb1 underneath Oracle Connections. Double click it to open the connection.


    ![Insert alt text](images/example.png)

4. Fill out the connection information with your password. The default password we will be using throughout this lab is Welcome123#. If you have changed yours, please use that one. After you click okay, you should be connected to your user.

    ![Insert alt text](images/example.png)

5. Click File -> Open

    ![Insert alt text](images/example.png)

6. Click Home -> examples -> graph

    ![Insert alt text](images/example.png)

7. Open the CreateKeys.sql.

    ![Insert alt text](images/example.png)

8. Click the button that shows a document with the small green play button on it to run the whole script. If it asks you to select a connection in a popup window, choose hol23c_freepdb1 from the drop down and then click okay.

    ![Insert alt text](images/example.png)

9. Scroll through the output to see that the data has been loaded.

    ![Insert alt text](images/example.png)

10. There should be about 5000 rows loaded into BANK_TRANSFERS and 1000 rows loaded in BANK_ACCOUNTS.

    ![Insert alt text](images/example.png)

11. Your schema setup is now complete.

14. Once the install completes, you will see a few lines such as the ones below, denoting that ORDS has been installed and is now running. 

    **NOTE:** You must leave this terminal open and the process running. Closing either will stop ORDS from running. 


## Task 2: Enable ORDS in the schema

*You don't need to take screenshots for this part*

1. In your terminal window, make a new tab by clicking File -> New Tab.


2. Execute the following commands to start running ORDS. 

    ``` 
    <copy>ords serve > /dev/null 2>&1 &</copy>
    ```
    
3. To confirm ORDS has been installed and is anonymously accessible, open a browser and go to: 

    ```
    <copy>http://localhost:8080/ords/hol23c/soda/latest</copy>
    ```

    If all steps succeeded, you should see:

    ```
    {"items":[],"hasMore":false}
    ```

You may **proceed to the next lab.**

## Learn More

- [JSON Relational Duality Blog](https://blogs.oracle.com/database/post/json-relational-duality-app-dev)
- [23c Beta Docs - TO BE CHANGED](https://docs-stage.oracle.com/en/database/oracle/oracle-database/23/index.html)

## Acknowledgements

- **Author**- William Masdon, Product Manager, Database 
- **Last Updated By/Date** - William Masdon, Product Manager, Database, March 2023
