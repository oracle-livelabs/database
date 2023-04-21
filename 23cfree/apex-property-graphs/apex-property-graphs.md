# Bank Transfers Graph Example with SQL/PGQ in 23c

## Introduction

In this lab you will view the queries created the graph (that is, `bank_graph`) in APEX.

Estimated Time: 10 minutes.

<!-- Watch the video below for a quick walk through of the lab. -->

<!-- update video link. Previous iteration: [](youtube:XnE1yw2k5IU) -->

### Objectives
Learn how to:
- Use APEX and SQL to query, analyze, and visualize a graph.

### Prerequisites
This lab assumes:
- The graph user and graph bank_graph exists
- You have ORDS running so you can open APEX

## Task 1: Login and create APEX workspace

1. Open Activities -> Google Chrome

    ![Open Google Chrome](images/activities-chrome.png)


2. Go to this URL and wait for the screen to load.
    ```
    <copy>
    http://localhost:8080/ords/apex_admin
    </copy>
    ```

    ![URL login screen](images/admin-services.png)

3. Login as ADMIN with the password Welcome123# and reset it to as you please.

    ![Login using credentials](images/login-details.png)

4. You can see the welcome screen for APEX now. 

    ![Welcome screen after login](images/welcome-screen-apex2.png)

5. Click create workspace

    ![workspace welcome screen](images/workspace-name.png)

6. Name the workspace 'graph' and click Next

    ![enter graph for the workspace](images/graph-next.png)

7. Set reuse existing schema to Yes. Click the menu icon next to schema name and select HOL23C. Leave the default for space quota and password.

    ![Schema information input changes](images/schema-info.png)

8. Admin username: admin, password: Welcome123#, email: your email.

    ![admin password email input](images/admin-password-email.png)

9. Review the output then click Create workspace.

    ![Create workspace](images/create-workspace.png)

10. Success! Now click done.

    ![completetion screen](images/done.png)

## Task 2 : Import APEX app to visualize queries

1. App Builder -> Import

    ![Import from app builder](images/app-builder-import.png)

2. Click to add a file to open for import. Go to Home -> example -> graph -> f106.sql and open that file. Leave the defaults and click next.

    ![open f106 sql file](images/graph-f106-open.png)

    ![Import f106 sql file](images/f106-import.png)

3. Click next.
    ![Import f106 sql file](images/f106-import-2.png)
    
4.  Leave all defaults, except check Reuse app 106 from file under Install Application and click Install Application. 

    ![Install the application](images/install-application.png)

5.  Click run application

    ![Run the application](images/run-application.png)


6.  Login.

    ![Log back in](images/login-final.png)


7. Click property graph queries with pgq box
    ![Property graph queries selection](images/property-graph-queries.png)
    
8. Scroll through output.
    ![Final scroll through the output](images/final-output.png)

9. You have now completed this lab.

## Learn More
* [Oracle Property Graph](https://docs.oracle.com/en/database/oracle/property-graph/index.html)
* [SQL Property Graph syntax in Oracle Database 23c Free - Developer Release](https://docs.oracle.com/en/database/oracle/property-graph/23.1/spgdg/sql-ddl-statements-property-graphs.html#GUID-6EEB2B99-C84E-449E-92DE-89A5BBB5C96E)

## Acknowledgements
- **Author** - Kaylien Phan, Thea Lazarova, William Masdon
- **Contributors** - Melliyal Annamalai, Jayant Sharma, Ramu Murakami Gutierrez, Rahul Tasker
- **Last Updated By/Date** - Kaylien Phan, Thea Lazarova
