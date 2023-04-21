# Configure setup materials and tools

## Introduction

In this lab, we'll be downloading materials and setting up the necessary tools required to execute the rest of the LiveLab. We'll also be opening SQL Developer and starting the ORDS service that you will need to use Oracle Application Express (APEX) later.

Estimated Time: 5 minutes


### Objectives

In this lab, you will:

- Download the graph setup files and materials onto your noVNC instance
- Open SQL Developer
- Start running ORDS to enable APEX 

### Prerequisites

This lab assumes you have:
- An instance with 23c Free Developer Release database installed
- Access to the instance's remote desktop


## Task 1: Download the graph setup materials


1. Click Activities in the upper left corner, then click Terminal.

    ![Access Terminal through activities](images/activities-terminal.png)

2. Go into the right directory.

    ```
    $ <copy>cd ~/examples</copy>
    ```

    ![Open directory](images/directory.png)

3. Pull down the materials for setup.

    ```
    $ <copy>wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/23cfree-property-graph.zip</copy>
    ```

    ![Wget to pull materials](images/material-pulldown-setup.png)

3. Unzip the file. Inside this zip file are the files to setup your schema and APEX application.

    ```
    $ <copy>unzip -o 23cfree-property-graph.zip</copy>
    ```

    <!-- ![Unzip file](images/unzip-file.png) -->

    ![Unzip the file](images/unzip2.png)

4. Remove the remaining zip file after you've unzpped it.

    ```
    $ <copy>rm -rf 23cfree-property-graph.zip</copy>
    ```

    <!-- ![Remaining zip file removed](images/remove-zip.png) -->


## Task 2: Login and create APEX workspace

1. Open Activities -> Google Chrome

    ![Open Google Chrome](images/activities-chrome.png)


2. Go to this URL and wait for the screen to load.
    ```
    <copy>
    http://localhost:8080/ords/apex_admin
    </copy>
    ```

    ![URL login screen](images/admin-services.png)

3. Login as ADMIN with your password Welcome123# or whatever you had set it to in Lab 1.

    ![Login using credentials](images/login-details.png)

4. You can see the welcome screen for APEX now. 

    ![Welcome screen after login](images/welcome-screen-apex2.png)

5. Click create workspace

    ![workspace welcome screen](images/workspace-name.png)

6. Name the workspace 'graph' and click Next

    ![enter graph for the workspace](images/graph-next.png)

7. Set reuse existing schema to Yes. Click the menu icon next to schema name and select HOL23C. Set your schema password to whatever but write it down. Leave the default for space quota.

    ![Schema information input changes](images/schema-info.png)

8. Admin username: admin, password: Welcome123#, email: your email.

    ![admin password email input](images/admin-password-email.png)

9. Review the output then click Create workspace.

    ![Create workspace](images/create-workspace.png)

10. Success! Now click done.

    ![completetion screen](images/done.png)

## Task 3: Create schema tables

1. In the upper right corner, click the admin icon then click sign out.
    ![sign out from admin](images/logout.png)

2.  Log back in as the admin info you just created along with the workspace name as graph.
    ![log back in](images/log-back-in.png)

3. Change password
    ![password change](images/change-password.png)

4. Click SQL Workshop -> Utilities -> Data Workshop
    ![Data workshop](images/utilities-dataworkshop2.png)

5. Click Load Data
    ![Load data](images/load-data2.png)

6. Click Choose File
    ![Choose file](images/choose-file2.png)

7. Click to Home -> Examples -> Graph -> BANK_ACCOUNTS.csv
    ![Bank accounts graph](images/home-examples-graph27.png)

8. Add the table name to be BANK_ACCOUNTS
    ![Add table bank accounts](images/bankaccts28.png)

9. Accept the rest of the defaults and click load data
    ![Load the data](images/accept-defaults29.png)

10. After seeing a successful load, click the X and click Load Data again.
    ![successful load](images/after-success-load210.png)

11. Now load the file by clicking to Home -> Examples -> Graph -> BANK_TRANSFERS.csv
    ![bank transfers load](images/banktransfers-load211.png)

12. Add the table name to be BANK_TRANSFERS
    ![add table name](images/bank-transfers-name212.png)

13. Accept the rest of the defaults and click load data
    ![Accept rest](images/btransfer-load-data213.png)

14. After seeing a successful load, click the X
    ![sucessful load](images/successful-load214.png)

## Task 4: Alter the schema tables
Before we begin the rest of the lab, we wanted to emphasize that all of the following queries we are about to do can be achieved in SQL Developer. We are using APEX for simplicity and to show how it could be done through here, but these are standardized SQL commands that you could run on other tools, such as SQL Developer or SQL Developer Web.

1. Click SQL Workshop -> SQL Commands

    ![SQL workshop commands](images/sqlworkshop-commands241.png)

2. Run each of the following commands one by one. You may erase the command sheet after executing by clicking Clear Command.

    ```
    $ <copy>ALTER TABLE bank_accounts DROP COLUMN ID_1;</copy>
    ```
    ![alter bank accounts](images/run242.png)

3. 

    ```
    $ <copy>ALTER TABLE bank_transfers DROP COLUMN ID;</copy>
    ```
    ![alter bank transfers](images/run243.png)
4. 

    ```
    $ <copy>ALTER TABLE bank_accounts ADD PRIMARY KEY (id);</copy>
    ```
    ![add primary key to bank_accounts](images/add-primary-key.png)

5. 
    ```
    $ <copy>ALTER TABLE bank_transfers ADD PRIMARY KEY (txn_id);</copy>
    ```
    ![Alter bank transfers table](images/alter245.png)

6. 

    ```
    $ <copy>ALTER TABLE bank_transfers MODIFY src_acct_id REFERENCES bank_accounts (id);</copy>
    ```
    ![Alter bank transfers](images/alter246.png)

7. 

    ```
    $ <copy>ALTER TABLE bank_transfers MODIFY dst_acct_id REFERENCES bank_accounts (id);</copy>
    ```
    ![modify](images/alter247.png)

8. 

    ```
    $ <copy>SELECT * FROM USER_CONS_COLUMNS WHERE table_name IN ('BANK_ACCOUNTS', 'BANK_TRANSFERS');</copy>
    ```
    ![select from table](images/select248.png)



## Learn More
* [Oracle Property Graph](https://docs.oracle.com/en/database/oracle/property-graph/index.html)
* [SQL Property Graph syntax in Oracle Database 23c Free - Developer Release](https://docs.oracle.com/en/database/oracle/property-graph/23.1/spgdg/sql-ddl-statements-property-graphs.html#GUID-6EEB2B99-C84E-449E-92DE-89A5BBB5C96E)

## Acknowledgements

- **Author** - Kaylien Phan, Thea Lazarova, William Masdon
- **Contributors** - Melliyal Annamalai, Jayant Sharma, Ramu Murakami Gutierrez, Rahul Tasker
- **Last Updated By/Date** - Kaylien Phan, Thea Lazarova
