# Create IAM Credentials and log into the database

## Introduction

Now that you have enabled IAM as the identity provider of your ADB, in this lab you will
create IAM credentails for your user and use them to connect to the database. First we connect with our IAM username and password, then with a token. Using a token lets you connect to the database without a password, and is possible for you because of the OCI_TOKEN parameter you added to the tnsnames.ora file in the previous lab. Not needing a password is useful if you have hundreds of databases in your environment, as managing passwords for each DB can be time consuming.

*Estimated Lab Time*: 15 minutes

### Objectives
- Create IAM credentials for users of your ADB
- Use IAM credentials to log into and query the database
- Use a IAM Token to connect to and query the database

### Prerequisites
This lab assumes that you have completed the introduction lab.

### Prerequisites
This lab assumes that you have completed the previous labs and successfully enabled IAM as your database identity provider.

## Task 1: Connect to the database as your OCI user.

1. Create IAM credentials for your OCI user

    ```
    <copy>oci iam user create-db-credential --user-id $OCI_CS_USER_OCID --password Oracle123+Oracle123+ --description "DB password for your OCI account"</copy>
    ```

2. Connect to database with IAM credentials as your OCI user. All values you see should match the output below except for **AUTHENTICATED\_IDENTITY** and **ENTERPIRSE\_IDENTITY**. These are unique to your user.

    ```
    <copy>sql /nolog <<EOF
    connect "${OCI_USER_NAME}"/Oracle123+Oracle123+@lltest_high
    select sys_context('SYS_SESSION_ROLES', 'SR_DBA_ROLE') from dual;
    select sys_context('USERENV','CURRENT_USER') from dual;
    select sys_context('USERENV','AUTHENTICATED_IDENTITY') from dual;
    select sys_context('USERENV','ENTERPRISE_IDENTITY') from dual;
    select sys_context('USERENV','AUTHENTICATION_METHOD') from dual;
    select sys_context('USERENV','IDENTIFICATION_TYPE') from dual;
    select sys_context('USERENV','network_protocol') from dual;
    EOF</copy>
    ```

    ```
    <copy>SYS_CONTEXT('SYS_SESSION_ROLES','SR_DBA_ROLE')    
    _________________________________________________
    FALSE                                             


    SYS_CONTEXT('USERENV','CURRENT_USER')    
    ________________________________________
    USER_SHARED                              


    SYS_CONTEXT('USERENV','AUTHENTICATED_IDENTITY')    
    __________________________________________________
    oci-demo-user@oracle.com   


    SYS_CONTEXT('USERENV','ENTERPRISE_IDENTITY')                                    
    _______________________________________________________________________________
    ocid1.user.oc1.aaaaaaaaghe4e5nskdl6ls1pdkd9q


    SYS_CONTEXT('USERENV','AUTHENTICATION_METHOD')    
    _________________________________________________
    PASSWORD_GLOBAL                                   


    SYS_CONTEXT('USERENV','IDENTIFICATION_TYPE')    
    _______________________________________________
    GLOBAL SHARED                                   


    SYS_CONTEXT('USERENV','NETWORK_PROTOCOL')    
    ____________________________________________
    tcps</copy>
    ```

3. Add your OCI user to the **DB_ADMIN** group.

    ```
    <copy>oci iam group add-user --user-id $OCI_CS_USER_OCID --group-id $DB_ADMIN_OCID</copy>
    ```

4. Connect to the database with IAM credentials again. Because the **DB\_ADMIN** IAM group is mapped to the **SR\_DBA\_ROLE** ADB group you will see the first query of this script now return TRUE. Again, all all values you see should match the output below except for **AUTHENTICATED\_IDENTITY** and **ENTERPIRSE\_IDENTITY**. These are unique to your user.

    ```
    <copy>sql /nolog <<EOF
    connect "${OCI_USER_NAME}"/Oracle123+Oracle123+@lltest_high
    select sys_context('SYS_SESSION_ROLES', 'SR_DBA_ROLE') from dual;
    select sys_context('USERENV','CURRENT_USER') from dual;
    select sys_context('USERENV','AUTHENTICATED_IDENTITY') from dual;
    select sys_context('USERENV','ENTERPRISE_IDENTITY') from dual;
    select sys_context('USERENV','AUTHENTICATION_METHOD') from dual;
    select sys_context('USERENV','IDENTIFICATION_TYPE') from dual;
    select sys_context('USERENV','network_protocol') from dual;
    EOF</copy>
    ```

    ```
    <copy>SYS_CONTEXT('SYS_SESSION_ROLES','SR_DBA_ROLE')    
    _________________________________________________
    TRUE                                              


    SYS_CONTEXT('USERENV','CURRENT_USER')    
    ________________________________________
    USER_SHARED                              


    SYS_CONTEXT('USERENV','AUTHENTICATED_IDENTITY')    
    __________________________________________________
    oci-demo-user@oracle.com                                  


    SYS_CONTEXT('USERENV','ENTERPRISE_IDENTITY')                                    
    _______________________________________________________________________________
    ocid1.user.oc1.aaaaaaaaghe4e5nskdl6ls1pdkd9q    


    SYS_CONTEXT('USERENV','AUTHENTICATION_METHOD')    
    _________________________________________________
    PASSWORD_GLOBAL                                   


    SYS_CONTEXT('USERENV','IDENTIFICATION_TYPE')    
    _______________________________________________
    GLOBAL SHARED                                   


    SYS_CONTEXT('USERENV','NETWORK_PROTOCOL')    
    ____________________________________________
    tcps</copy>
    ```

## Task 2: Connect to the database with a token.

1. Generate a token used for database access. It is possible to generate this token because of the OCI_TOKEN parameter we added to the tnsnames.ora file in the previous lab. Not needing a password is useful if you have hundreds of databases in your environment, as managing passwords for each DB can be time consuming.

    ```
    <copy>oci iam db-token get</copy>
    ```

2. Connect to the database using your token. Notice that the **AUTHENTICATION\_METHOD** is now listed as **TOKEN\_GLOBAL**, rather than **PASSWORD\_GLOBAL**, which it is when you access the database with an IAM username and password.

    ```
    <copy>sql /@lltest_high <<EOF
    select sys_context('SYS_SESSION_ROLES', 'SR_DBA_ROLE') from dual;
    select sys_context('USERENV','CURRENT_USER') from dual;
    select sys_context('USERENV','AUTHENTICATED_IDENTITY') from dual;
    select sys_context('USERENV','ENTERPRISE_IDENTITY') from dual;
    select sys_context('USERENV','AUTHENTICATION_METHOD') from dual;
    select sys_context('USERENV','IDENTIFICATION_TYPE') from dual;
    select sys_context('USERENV','network_protocol') from dual;
    EOF</copy>
    ```

    ```
    <copy>SYS_CONTEXT('SYS_SESSION_ROLES','SR_DBA_ROLE')    
    _________________________________________________
    TRUE                                              


    SYS_CONTEXT('USERENV','CURRENT_USER')    
    ________________________________________
    USER_SHARED                              


    SYS_CONTEXT('USERENV','AUTHENTICATED_IDENTITY')    
    __________________________________________________
    oci-demo-user@oracle.com                                


    SYS_CONTEXT('USERENV','ENTERPRISE_IDENTITY')                                    
    _______________________________________________________________________________
    ocid1.user.oc1.aaaaaaaaghe4e5nskdl6ls1pdkd9q    


    SYS_CONTEXT('USERENV','AUTHENTICATION_METHOD')    
    _________________________________________________
    TOKEN_GLOBAL                                  


    SYS_CONTEXT('USERENV','IDENTIFICATION_TYPE')    
    _______________________________________________
    GLOBAL SHARED                                   


    SYS_CONTEXT('USERENV','NETWORK_PROTOCOL')    
    ____________________________________________
    tcps</copy>
    ```

You may now **proceed to the next lab.**

## Learn More

* [Connecting to Autonomous Database with Identity and Access Management (IAM) Authentication](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/iam-access-database.html#GUID-CFC74EAF-E887-4B1F-9E9A-C956BCA0BEA9)
* [Connecting to Autonomous Database using a token] (https://blogs.oracle.com/cloudsecurity/post/password-free-authentication-to-autonomous-database-using-sqlcl-with-cloud-shell)

## Acknowledgements
* **Author**
  * Richard Evans, Database Security Product Management
  * Miles Novotny, Solution Engineer, North America Specialist Hub
  * Noah Galloso, Solution Engineer, North America Specialist Hub
* **Last Updated By/Date** - Miles Novotny, December 2022
