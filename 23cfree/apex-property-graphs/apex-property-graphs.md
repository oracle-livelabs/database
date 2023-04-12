# Bank Transfers Graph Example with SQL/PGQ in 23c

## Introduction

In this lab you will query the newly create graph (that is, `bank_graph`) in PGQL paragraphs.

Estimated Time: 30 minutes.

Watch the video below for a quick walk through of the lab.

<!-- update video link. Previous iteration: [](youtube:XnE1yw2k5IU) -->

### Objectives
Learn how to:
- Use APEX and PGQL to query, analyze, and visualize a graph.

### Prerequisites
This lab assumes:
- The graph user exists
- You have logged into APEX
- The graph bank_graph exists

*See Lab \_\_ for instructions to complete these prerequisites.*

### Tables are
| Name | Null? | Type |
| ------- |:--------:| --------------:|
| ACCT_ID | NOT NULL | NUMBER|
| NAME |  | VARCHAR2(4000) |
| BALANCE |  | NUMBER |
{: title="ACCOUNTS"}

| Name | Null? | Type |
| ------- |:--------:| --------------:|
| TXN_ID | NOT NULL | NUMBER|
| SRC\_ACCT\_ID |  | NUMBER |
| DST\_ACCT\_ID |  | NUMBER |
| DESCRIPTION |  | VARCHAR2(4000) |
| AMOUNT |  | NUMBER |
{: title="TRANSFERS"}

## Task 1 : Import APEX app to visualize queries

1. Open Activities -> Google Chrome

    ![Insert alt text](images/example.png)


2. Go to this URL and wait for the screen to load.
    ```
    <copy>
    http://localhost:8080/ords/apex_admin
    </copy>
    ```

    ![Insert alt text](images/example.png)


3. Login as ADMIN with Welcome123# as the password

    ![Insert alt text](images/example.png)

4. You can see the welcome screen for APEX now. 

    ![Insert alt text](images/example.png)

5. Click create workspace

    ![Insert alt text](images/example.png)

6. Name the workspace 'graph' and click Next

    ![Insert alt text](images/example.png)

7. Set reuse existing schema to Yes. Click the menu icon next to schema name and select HOL23C. Set your schema password to whatever but write it down. Leave the default for space quota.

    ![Insert alt text](images/example.png)

8. Admin username: admin, password: Welcome123#, email: your email.

    ![Insert alt text](images/example.png)

9. Review the output then click Create workspace.

    ![Insert alt text](images/example.png)

10. Success! Now click done.

    ![Insert alt text](images/example.png)


## Task 2 : Import app

1. In the upper right corner, click the admin icon then click logout.
    ![Insert alt text](images/example.png)


2.  Log back in as the admin info you just created along with the workspace name as graph.
    ![Insert alt text](images/example.png)


3. Change password
    ![Insert alt text](images/example.png)


4. App Builder -> Import

    ![Insert alt text](images/example.png)

5. Click to add a file to open for import. Go to Home -> example -> graph -> f106.sql and open that file. Leave the defaults and click next.

    ![Insert alt text](images/example.png)

6. Click next.
    
7.  Leave all defaults, except check Reuse app 106 from file under Install Application and click build application. 

    ![Insert alt text](images/example.png)

8.  Click run application

    ![Insert alt text](images/example.png)



9.  Login

    ![Insert alt text](images/example.png)


10. Click property graph queries with pgq box
    ![Insert alt text](images/example.png)
    
11. Scroll through output.
    ![Insert alt text](images/example.png)

12. You have now completed this lab.