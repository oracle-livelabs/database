# Create IAM Credentials and Log into the Database

## Introduction

Now that you have enabled IAM as the identity provider of your ADB, in this lab you will
create IAM credentails for users and use those connections to connect to the database and interact with it.

*Estimated Lab Time*: 15 minutes

### Objectives
- Create IAM credentials for users of your ADB
- Use IAM credentials to log into and query the database
- Use a IAM Token to connect to and query the database

## Task 1: Connect to the database as your OCI user.

1. Create IAM credentials for your OCI user

    ```
    oci iam user create-db-credential --user-id $OCI_CS_USER_OCID --password Oracle123+Oracle123+ --description "DB password for your OCI account"
    ```

2. Connect to database with IAM credentials as your OCI user.
    >**Note:** The output for AUTHENTICATED IDENTITY and ENTERPRISE IDENTITY is obscurified in the example output to protect user information, but will appear unobscured for you.

    ```
    sql /nolog <<EOF
    connect "${OCI_USER_NAME}"/Oracle123+Oracle123+@lltest_high
    select sys_context('SYS_SESSION_ROLES', 'SR_DBA_ROLE') from dual;
    select sys_context('USERENV','CURRENT_USER') from dual;
    select sys_context('USERENV','AUTHENTICATED_IDENTITY') from dual;
    select sys_context('USERENV','ENTERPRISE_IDENTITY') from dual;
    select sys_context('USERENV','AUTHENTICATION_METHOD') from dual;
    select sys_context('USERENV','IDENTIFICATION_TYPE') from dual;
    select sys_context('USERENV','network_protocol') from dual;
    EOF
    ```

    ```
    SYS_CONTEXT('SYS_SESSION_ROLES','SR_DBA_ROLE')    
    _________________________________________________
    FALSE                                             


    SYS_CONTEXT('USERENV','CURRENT_USER')    
    ________________________________________
    USER_SHARED                              


    SYS_CONTEXT('USERENV','AUTHENTICATED_IDENTITY')    
    __________________________________________________
    xxxxxxxxxxxxxxxxxxxxxxx                          


    SYS_CONTEXT('USERENV','ENTERPRISE_IDENTITY')                                    
    _______________________________________________________________________________
    xxxxxxxxxxxxxxxxxxxxxxx    


    SYS_CONTEXT('USERENV','AUTHENTICATION_METHOD')    
    _________________________________________________
    PASSWORD_GLOBAL                                   


    SYS_CONTEXT('USERENV','IDENTIFICATION_TYPE')    
    _______________________________________________
    GLOBAL SHARED                                   


    SYS_CONTEXT('USERENV','NETWORK_PROTOCOL')    
    ____________________________________________
    tcps
    ```

3. Add your OCI user to the **DB_ADMIN** group.

    ```
    oci iam group add-user --user-id $OCI_CS_USER_OCID --group-id $DB_ADMIN_OCID
    ```

4. Connect to the database with IAM credentials again. Because the **DB_ADMIN** IAM group is mapped to the **SR\_DBA\_ROLE** ADB group you will see the first query of this script now return TRUE.
    >**Note:** The output for AUTHENTICATED IDENTITY and ENTERPRISE IDENTITY is obscurified in the example output to protect user information, but will appear unobscured for you.

    ```
    sql /nolog <<EOF
    connect "${OCI_USER_NAME}"/Oracle123+Oracle123+@lltest_high
    select sys_context('SYS_SESSION_ROLES', 'SR_DBA_ROLE') from dual;
    select sys_context('USERENV','CURRENT_USER') from dual;
    select sys_context('USERENV','AUTHENTICATED_IDENTITY') from dual;
    select sys_context('USERENV','ENTERPRISE_IDENTITY') from dual;
    select sys_context('USERENV','AUTHENTICATION_METHOD') from dual;
    select sys_context('USERENV','IDENTIFICATION_TYPE') from dual;
    select sys_context('USERENV','network_protocol') from dual;
    EOF
    ```

    ```
    SYS_CONTEXT('SYS_SESSION_ROLES','SR_DBA_ROLE')    
    _________________________________________________
    TRUE                                              


    SYS_CONTEXT('USERENV','CURRENT_USER')    
    ________________________________________
    USER_SHARED                              


    SYS_CONTEXT('USERENV','AUTHENTICATED_IDENTITY')    
    __________________________________________________
    xxxxxxxxxxxxxxxxxxxxxxx                                 


    SYS_CONTEXT('USERENV','ENTERPRISE_IDENTITY')                                    
    _______________________________________________________________________________
    xxxxxxxxxxxxxxxxxxxxxxx    


    SYS_CONTEXT('USERENV','AUTHENTICATION_METHOD')    
    _________________________________________________
    PASSWORD_GLOBAL                                   


    SYS_CONTEXT('USERENV','IDENTIFICATION_TYPE')    
    _______________________________________________
    GLOBAL SHARED                                   


    SYS_CONTEXT('USERENV','NETWORK_PROTOCOL')    
    ____________________________________________
    tcps   
    ```

## Task 2: Connect to the database with a token.

1. Get generate a token used for database access.

    ```
    oci iam db-token get
    ```

2. Connect to the database using your token. This lets you connect to the database without a password. Not needing a password is useful if you have hundreds of databases in your environment, as managing passwords for each DB can be time consuming. For more information on parameters in the sqlnet.ora or tnsnames.ora files, please see the Oracle Database 19c Net Services Reference book. You should see the same output from this query as in the previous step.

    ```
    sql /@lltest_high <<EOF
    select sys_context('SYS_SESSION_ROLES', 'SR_DBA_ROLE') from dual;
    select sys_context('USERENV','CURRENT_USER') from dual;
    select sys_context('USERENV','AUTHENTICATED_IDENTITY') from dual;
    select sys_context('USERENV','ENTERPRISE_IDENTITY') from dual;
    select sys_context('USERENV','AUTHENTICATION_METHOD') from dual;
    select sys_context('USERENV','IDENTIFICATION_TYPE') from dual;
    select sys_context('USERENV','network_protocol') from dual;
    EOF
    ```

You may now proceed to the next lab!

## Learn More

* [Connecting to Autonomous Database with Identity and Access Management (IAM) Authentication](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/iam-access-database.html#GUID-CFC74EAF-E887-4B1F-9E9A-C956BCA0BEA9)
* [Connecting to Autonomous Database using a token] (https://blogs.oracle.com/cloudsecurity/post/password-free-authentication-to-autonomous-database-using-sqlcl-with-cloud-shell)

## Acknowledgements
* **Author**
	* Miles Novotny, Solution Engineer, North America Specalist Hub
	* Noah Galloso, Solution Engineer, North America Specalist Hub
* **Contributors** - Richard Events, Database Security Product Management
* **Last Updated By/Date** - Miles Novotny, December 2022
