# Granting the Developer Role

## Introduction

Welcome to the "Granting the Developer Role" lab. In this lab, you will learn how to grant and revoke the new Developer Role along with the benefits of using it in the Oracle Database for application development purposes. The Developer Role offers a full set of privileges for designing, developing, and deploying applications without having to constantly grant and manage additional privileges as the application gets created.

Estimated Lab Time: 10 minutes

### Objective:
The objective of this lab is to familiarize you with the Developer Role in Oracle Database 23ai and show you how to enable it. By the end of this lab, you will understand how to use the Developer Role effectively for granting privileges to application users.

### Prerequisites:
- Access to Oracle Database 23ai.
- Basic understanding of SQL is helpful.

## Task 1: Lab setup and understanding the developer role

1. The Developer Role gives us a full set of system privileges, object privileges, predefined roles, PL/SQL package privileges, and tracing privileges required by application developers. It simplifies privilege management and helps keep the database as secure as possible for the development environment. As always, please review the privileges granted and compare with your organizations security protocol.

2. Benefits of Developer Role:
   - **Least-Privilege Principle**: Granting the Developer Role follows the least-privilege principle. This means that application developers (and all other database users) only have access to the necessary privileges. 
   - **Enhanced Security**: Using the Developer Role improves database security by reducing the risk of granting unneeded privileges to application users, which ties into the least-privilege principle from above.
   - **Simplified Management**: Granting the Developer Role simplifies the management of role grants and revokes for application users.

## Task 2: Generating a list of granted privileges and roles

1. If you haven't done so already, from the Autonomous Database home page, **click** Database action and then **click** SQL.
    ![click SQL](../common-images/im1.png =50%x*)

2. Before we begin, this lab will be using Database Actions Web. If you're unfamiliar, please see the picture below for a simple explanation of the tool. You can click on the photo to enlarge it.

    ![click SQL](images/simple-db-actions.png =50%x*)

2. To check all of the system privileges, object privileges, and roles granted by the Developer Role, run the following PL/SQL script:


    ```
    <copy>
    set serveroutput on format wrapped;
    DECLARE
        procedure printRolePrivileges(
          p_role             in varchar2,
          p_spaces_to_indent in number) IS
          v_child_roles   DBMS_SQL.VARCHAR2_TABLE;
          v_system_privs  DBMS_SQL.VARCHAR2_TABLE;
          v_table_privs   DBMS_SQL.VARCHAR2_TABLE;
          v_indent_spaces varchar2(2048);
        BEGIN
          -- Indentation for nested privileges via granted roles.
          for space in 1..p_spaces_to_indent LOOP
            v_indent_spaces := v_indent_spaces || ' ';
          end LOOP;
          -- Get the system privileges granted to p_role
          select PRIVILEGE bulk collect into v_system_privs
          from DBA_SYS_PRIVS
          where GRANTEE = p_role
          order by PRIVILEGE;

          -- Print the system privileges granted to p_role
          for privind in 1..v_system_privs.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE(
              v_indent_spaces || 'System priv: ' || v_system_privs(privind));
          END LOOP;

          -- Get the object privileges granted to p_role
          select PRIVILEGE || ' ' || OWNER || '.' || TABLE_NAME
            bulk collect into v_table_privs
          from DBA_TAB_PRIVS
          where GRANTEE = p_role
          order by TABLE_NAME asc;

          -- Print the object privileges granted to p_role
          for tabprivind in 1..v_table_privs.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE(
              v_indent_spaces || 'Object priv: ' || v_table_privs(tabprivind));
          END LOOP;

          -- get all roles granted to p_role
          select GRANTED_ROLE bulk collect into v_child_roles
          from DBA_ROLE_PRIVS
          where GRANTEE = p_role
          order by GRANTED_ROLE asc;

          -- Print all roles granted to p_role and handle child roles recursively.
          for roleind in 1..v_child_roles.COUNT LOOP
            -- Print child role
            DBMS_OUTPUT.PUT_LINE(
             v_indent_spaces || 'Role priv: ' || v_child_roles(roleind));

            -- Print privileges for the child role recursively. Pass 2 additional
            -- spaces to illustrate these privileges belong to a child role.
            printRolePrivileges(v_child_roles(roleind), p_spaces_to_indent + 2);
          END LOOP;

          EXCEPTION
            when OTHERS then
              DBMS_OUTPUT.PUT_LINE('Got exception: ' || SQLERRM );

        END printRolePrivileges;

    BEGIN
        printRolePrivileges('DB_DEVELOPER_ROLE', 0);
    END;
    /
    </copy>
    ```
    ![run the PL/SQL](images/im2.png " ")

## Task 3: Performing grants and revokes

1. To grant the Developer Role to another user, use the GRANT statement. We'll create a user and check the granted roles to start.

    ```
    <copy>
    DROP USER IF EXISTS KILLIAN CASCADE;
    CREATE USER KILLIAN IDENTIFIED BY Oracle123_long;
    SELECT GRANTED_ROLE FROM DBA_ROLE_PRIVS WHERE GRANTEE='KILLIAN';    
    </copy>
    ```
    this will show 'no data found' as expected because we haven't granted anything yet.
    
    ![grant roles](images/im3.png " ")

2. Now grant the roles to `killian`
   
    ```
    <copy>
    GRANT DB_DEVELOPER_ROLE TO killian;
    </copy>
    ```
    ![grant our new user roles](images/im4.png " ")

3. After granting the role, we can verify the grant by executing the following SQL query:
   
    ```
    <copy>
    SELECT GRANTED_ROLE FROM DBA_ROLE_PRIVS WHERE GRANTEE='KILLIAN';
    </copy>
    ```
    ![verify the roles](images/im5.png " ")

4. To revoke the Developer Role from a user, use the REVOKE statement:
   
    ```
    <copy>
    REVOKE DB_DEVELOPER_ROLE FROM KILLIAN;
    </copy>
    ```
    ![revoke the user roles](images/im6.png " ")

5. Again, we can check that the role was removed

    ```
    <copy>
    SELECT GRANTED_ROLE FROM DBA_ROLE_PRIVS WHERE GRANTEE='KILLIAN';
    </copy>
    ```
    ![check the revoke worked](images/im7.png " ")

6. To clean up from the lab we can drop the user

    ```
    <copy>
    drop user IF EXISTS killian CASCADE;    
    </copy>
    ```
    ![drop the role](images/im8.png " ")

7. In this lab, we explored the Developer Role in Oracle Database 23ai for application development. By granting the Developer Role, it can help simplify privilege management and improve your database security during the development process of applications.

You may now **proceed to the next lab** 


## Learn More

* [Use of the DB\_DEVELOPER\_ROLE for Application Developers Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/dbseg/managing-security-for-application-developers.html#DBSEG-GUID-DCEEC563-4F6C-4B0A-9EB2-9F88CDF351D7)

## Acknowledgements
* **Author** - Killian Lynch, Database Product Management
* **Contributors** - Dom Giles, Distinguished Database Product Manager
* **Last Updated By/Date** - Killian Lynch, April 2024