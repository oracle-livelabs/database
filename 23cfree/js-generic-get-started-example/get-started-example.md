# Get started with JavaScript using a community module

## Introduction

Before jumping into the description of JavaScript features and all their details let's begin with a practical example. Enhancing data quality is a focus area for many businesses. Poor data quality prevents analysts from making properly informed decisions, and it all starts at the source system. In this lab you will read about validating email addresses, a common scenario in many applications. Validating email addresses isn't a new problem, and there are plenty of solutions available. This lab explores the open source `validator.js` module's `isEmail()` function and demonstrates how to use it in your application.

> If you intend to use `validator.js` in your own project please refer to validator's GitHub project site for more details about the project's license and implications of use.

Estimated Time: 10 minutes

[](videohub:1_d307bfag)

### Objectives

In this lab, you will:

- Create a schema to store the JavaScript module
- Download the ECMAScript version of the `validator.js` module
- Create an MLE module in the database
- Expose the module to PL/SQL and SQL
- Validate email addresses

### Prerequisites

This lab assumes you have:

- Oracle Database 23c Free - Developer Release
- You have a working noVNC environment or comparable setup

## Task 1: Create a schema to store the JavaScript module

All the steps in this lab can either be completed in `sqlplus` or `sqlcl`. The instructions refer to `sqlplus` but apart from the initial connection the two options are identical. Instead of typing the instructions you can use the "copy" button to copy the code to the clipboard. Select the terminal window you want to paste the code into, then hit CTRL + SHIFT + V to insert the text at your cursor's position.

1. Start by connecting to the database as `SYS`

    ```sql
    <copy>sqlplus / as sysdba</copy>
    ```

    Should you get the message `connected to an idle instance` or `sqlplus: command not found` you need to source the correct environment variables first:

    ```bash
    <copy>ORACLE_SID=FREE ORAENV_ASK=NO source oraenv</copy>
    ```

    Verify the success by echoing both `ORACLE_SID` and `ORACLE_HOME`:

    ```bash
    <copy>echo "ORACLE_SID is set to ${ORACLE_SID} for ORACLE_HOME ${ORACLE_HOME}"</copy>
    ```

    If you see the following output on your screen you are all set:

    ```
    ORACLE_SID is set to FREE for ORACLE_HOME /opt/oracle/product/23c/dbhomeFree
    ```

2. Once you are successfully connected to the database, switch to the pre-created Pluggable Database (PDB) `freepdb1`

    ```sql
    <copy>alter session set container = freepdb1;</copy>
    ```

    Verify whether you are in the correct container using the following query:

    ```sql
    <copy>select sys_context('userenv','con_name') as container_name;</copy>
    ```

    If you see `FREEPDB1` you are good to go.

    ```
    CONTAINER_NAME
    ------------------------------------
    FREEPDB1
    ```

3. Create a new user in freepdb1 with the necessary privileges to create, store and run JavaScript code

    In this step you prepare the creation of the developer account. The instructions in the following snippet create a new account, named `emily`. It will be used to store JavaScript modules in the database.

    Save the snippet in a file, for example `${HOME}/setup.sql` and execute it in `sqlcl` or `sqlplus`. You can use graphical text editors installed on the system via the Activities button or the command line.

    ```sql
    <copy>set echo on
    drop user if exists emily cascade;

    create user emily identified by &secretpassword
    default tablespace users quota unlimited on users;

    grant create session to emily;
    grant db_developer_role to emily;
    grant execute on javascript to emily;

    host mkdir /home/oracle/hol23c 2> /dev/null || echo "directory exists"

    drop directory if exists javascript_src_dir;
    create directory javascript_src_dir as '/home/oracle/hol23c';
    grant read, write on directory javascript_src_dir to emily;

    exit</copy>
    ```

    You should still be connected to `freebdb1` as `SYS` as per the previous step. If not, connect to `freepdb1` as `SYS` before executing the following command:

    ```sql
    <copy>start ${HOME}/setup.sql</copy>
    ```

    Here is some sample output of an execution:

    ```
    SQL> @hol23c/setup
    SQL> drop user if exists emily cascade;

    User dropped.

    SQL> create user emily identified by &secretpassword
      2  default tablespace users quota unlimited on users;
    Enter value for secretpassword: yoursupersecretpasswordhere
    old   1: create user emily identified by &secretpassword
    new   1: create user emily identified by yoursupersecretpasswordhere

    User created.

    SQL> grant create session to emily;

    Grant succeeded.

    SQL> grant db_developer_role to emily;

    Grant succeeded.

    SQL> grant execute on javascript to emily;

    Grant succeeded.

    SQL> host mkdir /home/oracle/hol23c 2> /dev/null || echo "directory exists"
    directory exists
    
    SQL> drop directory if exists javascript_src_dir;

    Directory dropped.

    SQL> create directory javascript_src_dir as '/home/oracle/hol23c';

    Directory created.

    SQL> grant read, write on directory javascript_src_dir to emily;

    Grant succeeded.

    SQL> exit
    ```

    You will be prompted you for a password to be assigned to the user. Please remember the password, you will need it later.

4. ORDS-enable the new schema

    With the new account created you need to enable it for use with Oracle Restful Data Service (ORDS). You will point Database Actions against the schema in later modules. Connect to the database as the `emily` user:

    ```bash
    <copy>sqlplus emily/yourNewPasswordGoesHere@localhost/freepdb1</copy>
    ```

    REST-enable the schema by calling `ords.enable_schema()`

    ```sql
    <copy>
    begin
        ords.enable_schema;
        commit;
    end;
    /
    </copy>
    ```

    This command should complete with acknowledgement that the command completed successfully as shown in this example:

    ```
    SQL> begin
      2    ords.enable_schema;
      3    commit;
      4  end;
    SQL> /

    PL/SQL procedure successfully completed.
    ```

    Now disconnect from the database in preparation of the next step.

## Task 2: Get the ECMAScript version of the validator.js module

The `validator` module can be downloaded from multiple sources. As long as you pick a trustworthy one it doesn't really matter where the file originates from. Ensure that you get the ECMAScript (ESM) version of the module from your preferred Content Delivery Network (CDN) as they are the only ones supported in Oracle. The necessary file has been staged on Object Storage and can be copied to the directory pointed at by `javascript_src_dir` as follows:

```bash
<copy>
curl -Lo /home/oracle/hol23c/validator.min.js 'https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/validator.min.jsvalidator.min.js' 
</copy>
```

## Task 3: Create the JavaScript module in the database

JavaScript in Oracle Database 23c Free - Developer Release allows you to load JavaScript modules using the `BFILE` clause, specifying a directory object and file name. You prepared for the `create mle module` command in the previous step, now it's time to execute it:

1. Connect to the database as the `emily` user:

    ```bash
    <copy>sqlplus emily/yourNewPasswordGoesHere@localhost/freepdb1</copy>
    ```

2. With the session established, create the module as follows:

    ```sql
    <copy>
    create  mle module validator
    language javascript
    using bfile (javascript_src_dir, 'validator.min.js');
    /
    </copy>
    ```

3. Verify the module has been created:

    ```sql
    <copy>
    col MODULE_NAME for a30
    col LANGUAGE_NAME for a30

    select 
        module_name, 
        language_name 
    from 
        user_mle_modules
    where
        module_name = 'VALIDATOR';</copy>
    ```

    The query should return exactly 1 row as shown here:

    ```
    MODULE_NAME                    LANGUAGE_NAME
    ------------------------------ ------------------------------
    VALIDATOR                      JAVASCRIPT
    ```

You can read more about creating JavaScript modules in Oracle Database 23c Free - Developer release in chapter 2 of the JavaScript Developer's Guide.

## Task 4: Expose the module's functionality to PL/SQL and SQL

With the module successfully created in the schema the hardest part is complete. The validator module exposes quite a few string validators for any purpose imaginable, the project's GitHub page lists them all in a convenient tabular format. As per the introduction to this lab the goal is to validate email addresses. A PL/SQL call specification links the module's JavaScript functions to SQL and PL/SQL. In this simple case a stand-alone function does the trick:

```sql
<copy>
create or replace function isEmail(
  p_str varchar2
) return boolean
as mle module validator
signature 'default.isEmail';
/
</copy>
```

The validator library's `index.js` (in src/index.js in the project’s Github repository) declares the validator object as the module's default export, requiring the use of the `default` keyword in the function's signature.

In case where multiple JavaScript functions are made available to PL/SQL and SQL you should follow the industry's best practice and encapsulate them in a package.

Please refer to chapter 5 in the JavaScript Developer's Guide for more information about call specifications and module calls.

## Task 5: Validate email addresses

After the JavaScript module has been created in the schema and exposed to SQL and PL/SQL it can be used like any other PL/SQL code unit. Go ahead and validate a few email addresses:

```sql
<copy>
select isEmail('user-no-domain') as test1;
select isEmail('@domain.but.no.user') as test2;
select isEmail('user@example.com') as test3;
</copy>
```

You can see that the function works as expected:

```
SQL> select isEmail('user-no-domain') as test1;

TEST1
-----------
FALSE

SQL> select isEmail('@domain.but.no.user') as test2;

TEST2
-----------
FALSE

SQL> select isEmail('user@example.com') as test3;

TEST3
-----------
TRUE
```

You many now proceed to the next lab.

## Learn More

- [JavaScript Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/mlejs/index.html)
- [Server-Side JavaScript API Documentation](https://oracle-samples.github.io/mle-modules/)
- [Validator.js on Github](https://github.com/validatorjs/validator.js)

## Acknowledgements

- **Author** - Martin Bach, Senior Principal Product Manager, ST & Database Development
- **Contributors** -  Lucas Braun, Sarah Hirschfeld
- **Last Updated By/Date** - Martin Bach 09-MAY-2023
