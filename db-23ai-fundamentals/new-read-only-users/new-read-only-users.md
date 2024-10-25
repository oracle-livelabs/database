## Exploring Read-Only User Configuration in Oracle Database

### Introduction

Welcome to the "Exploring Read-Only User Configuration in Oracle Database" lab. In this session, we will look at configuring read-only users in Oracle Database 23ai. This feature allows administrators to restrict users from performing write operations against the database to improve data integrity and security.

Estimated Lab Time: 15 minutes

### Objective

The objective of this lab is to familiarize you with setting up read-only users in Oracle Database 23ai. By the end of this session, you will understand how to create, modify, and verify the read-only status of users.

### Prerequisites

- Access to Oracle Database 23ai.
- Basic understanding of SQL and user management in Oracle.

## Task 1: Understanding Read-Only Users

1. If you haven't done so already, from the Autonomous Database home page, **click** Database action and then **click** SQL.
    ![click SQL](images/im1.png =50%x*)

    Using the ADMIN user isn’t typically advised due to the high level of access and security concerns it poses. **However**, for this demo, we’ll use it to simplify the setup and ensure we can show the full range of features effectively. 

2. Before we begin, this lab will be using Database Actions Web. If you're unfamiliar, please see the picture below for a simple explanation of the tool. You can click on the photo to enlarge it.

    ![click SQL](images/simple-db-actions.png =50%x*)

1. Read-only users in Oracle Database 23ai are configured to allow `SELECT` operations only, disallowing any modifications such as `CREATE`, `INSERT`, `UPDATE`, or `DELETE`.

2. This feature provides flexibility for administrators to setup read-only access temporarily or permanently, improving database security and governance.

## Task 2: Configuring Read-Only Users

1. To create a read-only user, we'll use the `CREATE USER` statement with the `READ ONLY` clause. This statement creates a user named testuser with read-only privileges.


    ```
    <copy>
    CREATE USER testuser identified by Oracle123long READ ONLY;
    </copy>
    ```

    We can also modify an existing user to be read-only. Here is the syntax you'd use to do that. 

    ```sql
    ALTER USER <your_user> READ ONLY;
    ```


3. Lets sign into the new user and try to create a table. First we'll want to rest enable our user.

    ```
    <copy>
    -- ADD ROLES
    GRANT CONNECT TO TESTUSER;
    GRANT DB_DEVELOPER_ROLE TO TESTUSER;
    GRANT RESOURCE TO TESTUSER;
    GRANT DB_DEVELOPER_ROLE TO TESTUSER WITH ADMIN OPTION;
    ALTER USER TESTUSER DEFAULT ROLE CONNECT,RESOURCE;

    -- REST ENABLE
    BEGIN
        ORDS_ADMIN.ENABLE_SCHEMA(
            p_enabled => TRUE,
            p_schema => 'TESTUSER',
            p_url_mapping_type => 'BASE_PATH',
            p_url_mapping_pattern => 'testuser',
            p_auto_rest_auth=> FALSE
        );
        -- ENABLE DATA SHARING
        C##ADP$SERVICE.DBMS_SHARE.ENABLE_SCHEMA(
                SCHEMA_NAME => 'TESTUSER',
                ENABLED => TRUE
        );
        commit;
    END;
    /

    -- QUOTA
    ALTER USER TESTUSER QUOTA UNLIMITED ON DATA;
    </copy>
    ```

4. If you're using 23ai ADB free please follow the steps below. If you're not on 23ai ADB Free, please regularly connect as the new user and skip to number .

    I'll also take this time to show you Database actions as well. First select the hamburger menu in the top left hand corner and then click Database Users under the Administration section (see pic below if you can't find it)





## Task 3: Verifying Read-Only Status

1. To check the read-only status of a user, query the `READ_ONLY` column of the `DBA_USERS` or `ALL_USERS` data dictionary view:

    ```sql
    SELECT USERNAME, READ_ONLY FROM DBA_USERS WHERE USERNAME = 'username';
    ```

    This query provides information about whether the user is set to read-only.

### Conclusion

In this lab, we have explored the configuration of read-only users in Oracle Database. You've learned how to create, modify, and verify the read-only status of users, enabling fine-grained control over database access privileges.

## Learn More

- [Oracle Database Documentation: Managing Users](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/CREATE-USER.html#GUID-DCAD8FA0-15B7-40E2-B90F-4DCA1A3C9D35)
