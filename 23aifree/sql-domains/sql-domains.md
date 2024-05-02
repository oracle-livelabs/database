# Leverage SQL Domains

## Introduction

Estimated Time: 10 minutes

Let's start with a short definition:  A SQL domain is a dictionary object that belongs to a schema and encapsulates a set of optional properties and constraints for common values. SQL domains provide constraints, display, ordering and annotations attributes. After you define a SQL domain, you can define table columns to be associated with that domain, thereby explicitly applying the domain's optional properties and constraints to those columns. So SQL domains are used to provide additional information to a stored column (JSON or relational), and therefore, used to define and validate data.
> Note: Oracle's SQL domain implementation provides a wider range of functions than the one specified in the SQL standard.

You can create, alter and drop a domain in your own schema. To work with domains you require the privilege `CREATE DOMAIN`, which the **RESOURCE** and new **DB\_DEVELOPER\_ROLE** roles already include.

There are 3 different types of domains: single column, multi column and flexible domains. In addition there are also built-in domains that you may use.

### Objectives

In this lab, you will:
* Create and drop a single column domain
* Monitor SQL domains
* Use built-in domains
* Validate JSON

### Prerequisites

This lab assumes you have:
* Oracle Database 23ai Free Developer Release
* All previous labs successfully completed
* SQL Developer Web 23.1 or a compatible tool for running SQL statements

[Leverage SQL Domains](videohub:1_2f1zmgrm)

## Task 1: Create a single column domain

1. First, let's get familiar with the syntax. To create a SQL Domain, use `CREATE DOMAIN`:
    ```
    CREATE DOMAIN [IF NOT EXISTS]  DomainName  AS  <Type> [STRICT]
    [ DEFAULT [ON NULL..] <expression>]
    [ [NOT] NULL]
    [ CONSTRAINT [Name] CHECK (<expression>) [ ENABLE | DISABLE] ..]*
    [ VALIDATE USING <json_schema_string>]
    [ COLLATE collation ]
    [ DISPLAY <expression> ]
    [ ORDER <expression> ]
    ```

    You can also drop domains with ...
    ```
    DROP DOMAIN [IF EXISTS] domain_name [FORCE [PRESERVE]]
    ```
    **Please keep in mind:** Using `FORCE` in contrast to `PRESERVE` disassociates the domain from all its dependent columns. This includes dropping all the constraints on columns that were inherited from the domain. Defaults inherited from the domain are also dropped unless these defaults were set specifically on columns.

    You may consult the [documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/index.html) to get a detailed description of the different parts of SQL domain syntax.

2. To get an idea how to use it, let's create a simple example - an email domain - and use it in a person table.
    If you closed to your terminal, connect again as hol23c again. Remember we're using Welcome123 as the password, but change the values to match your own here.
    ```
    <copy>
    sqlplus hol23c/Welcome123@localhost:1521/freepdb1
    </copy>
    ```
    Now let's create that domain.
    >Note: As a reminder, and trailing numbers when pasting into terminal will not effect command output.

    ```
    <copy>
    CREATE DOMAIN IF NOT EXISTS myemail_domain AS VARCHAR2(100)
    default on null 'XXXX' || '@missingmail.com'
    constraint email_c CHECK (regexp_like (myemail_domain, '^(\S+)\@(\S+)\.(\S+)$'))
    display substr(myemail_domain, instr(myemail_domain, '@') + 1);
    </copy>
    ```

    We now have a domain called `myemail_domain`. The check constraint `EMAIL_C` examines if the column stores a valid email, `DISPLAY` specifies how to convert the domain column for display purposes. You may use the SQL function `DOMAIN_DISPLAY` on the given column to display it.

3. Now let's use it in the table person.
    ```
    <copy>
    DROP TABLE IF EXISTS person;
    </copy>
    ```
    ```
    <copy>
    CREATE TABLE person
        ( p_id number(5),
        p_name varchar2(50),
        p_sal number,
        p_email varchar2(100) domain myemail_domain
        )
    annotations (display 'person_table');
    </copy>
    ```

    We now have a table called `person`. As you can see, you may also use annotations in combination with SQL domains. If you want more information on annotations, you find explanation and examples in [Annotations - The new metadata in 23ai](https://blogs.oracle.com/coretec/post/annotations-the-new-metadata-in-23c).

4. Now insert additional rows with valid data.

    ```
    <copy>
    INSERT INTO person values (1,'Bold',3000,null),
    (1,'Schulte',1000, 'user-schulte@gmx.net'),
    (1,'Walter',1000,'user_walter@t_online.de'),
    (1,'Schwinn',1000, 'UserSchwinn@oracle.com'),
    (1,'King',1000, 'user-king@aol.com');
    </copy>
    5 rows created.
    ```
    ```
    <copy>
    commit;
    </copy>
    Commit complete.
    ```

5. Here's an insert example with invalid data.
    ```
    <copy>INSERT INTO person values (1,'Schulte',3000, 'user-schulte%gmx.net');</copy>
    ```
    You will get the following error message:
    ```
    ERROR at line 1:
    ORA-11534: check constraint (SYS.SYS_C008254) due to domain constraint
    SYS.EMAIL_C of domain SYS.MYEMAIL_DOMAIN violated
    ```
    The number of your constraint may vary slightly from the `SYS_C008254` shown here, but the error is the same. This is our domain constraint at work.

6. Now let's query the table PERSON.
    ```
    <copy>SELECT * FROM person;</copy>
    ```
    The results:
    ```
      P_ID P_NAME                                  P_SAL P_EMAIL
---- ---------------------------------- ---------- --------------------------
         1 Bold                                     3000 XXXX@missingmail.com
         1 Schulte                                  1000 user-schulte@gmx.net
         1 Walter                                   1000 user-walter@t_online.de
         1 Schwinn                                  1000 UserSchwinn@oracle.com
         1 King                                     1000 user-king@aol.com
    ```

## Task 2: Monitor SQL domains

1. There are different possibilities to monitor SQL domains. ​For example ​​​​using SQL*Plus `DESCRIBE` already displays columns and associated domain and Null constraint.
    ```
    <copy>desc person;</copy>
    ```

    ```
    Name                                Null?    Type
    ----------------------------------- -------- ------------------------------------
    P_ID                                         NUMBER(5)
    P_NAME                                       VARCHAR2(50)
    P_SAL                                        NUMBER
    P_EMAIL                             NOT NULL VARCHAR2(100) HOL23C.MYEMAIL_DOMAIN
    ```
2. As previously mentioned, there are new domain functions you may use in conjunction with the table columns to get more information about the domain properties. `DOMAIN_NAME` for example returns the qualified domain name of the domain that the argument is associated with, `DOMAIN_DISPLAY` returns the domain display expression for the domain that the argument is associated with. More information can be found in the [documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/index.html).
    ```
    <copy>col p_name format a30;
    col DISPLAY format a25;</copy>
    ```
    ```
    <copy>SELECT p_name, domain_display(p_email) "Display" FROM person;</copy>
    ```

    ```
    P_NAME                    Display
    ------------------------- -------------------------
    Bold                      missingmail.com
    Schulte                   gmx.net
    Walter                    t_online.de
    Schwinn                   oracle.com
    King                      aol.com
    ```
3. Another way to monitor SQL domains are data dictionary views such as `USER_DOMAIN`, `USER_DOMAIN_COLS`, and `USER_DOMAIN_CONSTRAINTS` (also with `ALL/DBA`).

    Here are some examples:
    ```
    <copy>
    col owner format a15;
    col name format a30;
    set pagesize 100;
    </copy>
    ```
    ```
    <copy>SELECT owner, name, data_display FROM user_domains;</copy>
    ```

    ```
    OWNER           NAME
    --------------- ------------------------------
    DATA_DISPLAY
    ------------------------------------------------------
    HOL23C           MYEMAIL_DOMAIN
    SUBSTR(myemail_domain, instr(myemail_domain, '@') + 1)
    ```

    ```
    <copy>SELECT * FROM user_domain_constraints WHERE domain_name='MYEMAIL_DOMAIN';</copy>
    ```

    ```
    NAME                           DOMAIN_OWNER    DOMAIN_NAME          C
    ------------------------------ --------------- -------------------- -
    SEARCH_CONDITION                                                                 STATUS
    -------------------------------------------------------------------------------- --------
    DEFERRABLE     DEFERRED  VALIDATED     GENERATED      BAD RELY INVALID ORIGIN_CON_ID
    -------------- --------- ------------- -------------- --- ---- ------- -------------
    EMAIL_C                        SYS           MYEMAIL_DOMAIN       C
    REGEXP_LIKE (myemail_domain, '^(\S+)\@(\S+)\.(\S+)$')                            ENABLED
    NOT DEFERRABLE IMMEDIATE VALIDATED     USER NAME                                   1
    SYS_DOMAIN_C0034               SYS           MYEMAIL_DOMAIN       C
    "MYEMAIL_DOMAIN" IS NOT NULL                                                     ENABLED
    NOT DEFERRABLE IMMEDIATE VALIDATED     GENERATED NAME                              1
    ```

4. But what about the "good old" package `DBMS_METADATA` to get the `DDL` command?

    Let's try `GET_DDL` and use `SQL_DOMAIN` as an object_type argument.
    ```
    <copy>set long 10000;</copy>
    ```
    ```
    <copy>SELECT dbms_metadata.get_ddl('SQL_DOMAIN', 'MYEMAIL_DOMAIN') FROM dual;</copy>
    ```

    And et voila you will get a similar result.

    ```
    DBMS_METADATA.GET_DDL('SQL_DOMAIN','MYEMAIL_DOMAIN')
    ----------------------------------------------------------------------------------------------------
    CREATE DOMAIN "SYS"."MYEMAIL_DOMAIN" AS VARCHAR2(100) DEFAULT ON NULL 'XXXX' || '@missingmail.com'
    CONSTRAINT "EMAIL_C" CHECK (REGEXP_LIKE (myemail_domain, '^(\S+)\@(\S+)\.(\S+)$')) ENABLE
    DISPLAY SUBSTR(myemail_domain, INSTR(myemail_domain, '@') + 1)
    ```

## Task 3: Use built-in domains

In addition, to make it easier for you to start with Oracle provides built-in domains you can use directly on table columns - for example, email, ssn, and credit_card. You find a list of them with names, allowed values and description in the documentation.

1. First, we'll connect as the sysdba.
    ```
    <copy>
    connect / as sysdba;
    </copy>
    Connected.
    ```
    ```
    <copy>
    alter session set container=FREEPDB1;
    </copy>
    Session altered.
    ```

1. Another way to get this information is to query `ALL_DOMAINS` and filter on owner `SYS`. Then you will receive the built-in domains.
    ```
    <copy>SELECT name FROM all_domains where owner='SYS';</copy>
    ```

    ```
    NAME
    -------------------------
    PHONE_NUMBER_D
    EMAIL_D
    DAY_SHORT_D
    DAY_D
    MONTH_SHORT_D
    MONTH_D
    YEAR_D
    POSITIVE_NUMBER_D
    ...
    ```
2. Let's investigate the domain `EMAIL_D` for email entries. Query the data dictionary views or use the package `DBMS_METADATA` to get the definition.
    ```
    <copy>col domain_ddl format a100;</copy>
    ```
    ```
    <copy>SELECT dbms_metadata.get_ddl('SQL_DOMAIN', 'EMAIL_D','SYS') domain_ddl from dual;</copy>
    ```

    ```
    DOMAIN_DDL
    ----------------------------------------------------------------------------------------------------
    CREATE DOMAIN "SYS"."EMAIL_D" AS VARCHAR2(4000) CHECK (REGEXP_LIKE (email_d, '^([a-zA-Z0-9!#$%&*+=
    ?^_`{|}~-]+(\.[A-Za-z0-9!#$%&*+=?^_`{|}~-]+)*)@(([a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z0-
    9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)$')) ENABLE
    ```
3. Now let's connect as hol23c and re-create our table `PERSON`.
    ```
    <copy>
    connect hol23c/Welcome123@localhost:1521/freepdb1
    </copy>
    Connected.
    ```

    ```
    <copy>
    DROP TABLE IF EXISTS person;
    </copy>
    Table dropped.
    ```
    ```
    <copy>
    CREATE TABLE IF NOT EXISTS person
    ( p_id number(5),
    p_name varchar2(50),
    p_sal number,
    p_email varchar2(4000) domain EMAIL_D
        )
    annotations (display 'person_table');
    </copy>
    Table created.
    ```

    > Keep in mind that we need to adjust the length of the column `P_EMAIL` to **4000** - otherwise you will receive the following error:
    ```
    CREATE TABLE person
        ( p_id number(5),
        p_name varchar2(50),
        p_sal number,
        p_email varchar2(2000) domain EMAIL_D
        )
    annotations (display 'person_table');
    ```
    ```
    CREATE TABLE person
    *
    ERROR at line 1:
    ORA-11517: the column data type does not match the domain column
    ```

4. Let's insert some data.
    ```
    <copy>INSERT INTO person values (1,'Bold',3000,null);</copy>
    1 row created.
    ```

    ```
    <copy>INSERT INTO person values (1,'Schulte',1000, 'user-schulte@gmx.net');</copy>
    1 row created.
    ```

    We'll need to format our entries to avoid error. Here's an example of such an error:
    ```
    INSERT INTO person values (1,'Walter',1000,'user-walter@t_online.de')
    *
    ERROR at line 1:
    ORA-11534: check constraint (SCOTT.SYS_C008255) due to domain constraint SYS.SYS_DOMAIN_C002 of domain SYS.EMAIL_D
    violated
    ```
    The email with the underscore sign '_'  is not a valid entry, so we need to change it to a hyphen '-'.
    ```
    <copy>INSERT INTO person values (1,'Walter',1000,'user-walter@t-online.de');</copy>
    1 row created.
    ```

## Task 4: Validate JSON

The 23ai Oracle database supports not only the JSON datatype but also **JSON schema validation**.  A JSON schema - similar to XML schema - defines the rules that allow you to annotate and validate JSON documents. The schema specifies the permitted keywords, data types for their values, and the structure in which they can be nested. You can define the key-value pairs as mandatory or optional. Now you can validate a JSON document using a JSON schema with the `IS JSON` check constraint clause `VALIDATE`; in addition you may even use shorthand syntax without the check constraint instead.

1. The following example shows how to use an inline schema definition in a `CREATE TABLE` command (the shorthand syntax without a check constraint).
    ```
    CREATE TABLE IF NOT EXISTS person
    (id NUMBER,
    p_record JSON VALIDATE '<json-schema>');
    ```

    SQL domains also support JSON validation now. The difference between the inline schema definition and the SQL domain is that a SQL domain stores a reference to the SQL domain (call by reference instead of call by value). If the SQL domain changes, so does the validation logic. If the SQL domain is dropped, validation does not happen and an error to this effect is raised.

2. Let's give an example using a SQL domain with the JSON validation clause `[VALIDATE USING <json_schema_string>]`. The JSON schema describes a person JSON document.
    ```
    <copy>
    CREATE DOMAIN p_recorddomain AS JSON VALIDATE USING '{
    "type": "object",
    "properties": {
        "first_name": { "type": "string" },
        "last_name": { "type": "string" },
        "birthday": { "type": "string", "format": "date" },
        "address": {
        "type": "object",
        "properties": {
            "street_address": { "type": "string" },
                    "city": { "type": "string" },
                    "state": { "type": "string" },
                    "country": { "type" : "string" }
                        }
                    }
                }
    }' ;
    </copy>
    Domain created.
    ```
    ```
    <copy>
    DROP TABLE IF EXISTS person;
    </copy>
    Table dropped.
    ```
    ```
    <copy>
    CREATE TABLE IF NOT EXISTS person (id NUMBER,
                p_record JSON DOMAIN p_recorddomain);
    </copy>
    Table created.
    ```

3. Now we insert valid data.
    ```
    <copy>
    INSERT INTO person values (1, '{
    "first_name": "George",
    "last_name": "Washington",
    "birthday": "1732-02-22",
    "address": {
                "street_address": "3200 Mount Vernon Memorial Highway",
                "city": "Mount Vernon",
                "state": "Virginia",
                "country": "United States"
            }
    }');
    </copy>
    1 row created.
    ```

4. The next record is not a valid entry.
    ```
    <copy>INSERT INTO person values (2, '{
    "name": "George Washington",
    "birthday": "February 22, 1732",
    "address": "Mount Vernon, Virginia, United States"
    }');
    </copy>
    ```

    ```
    INSERT INTO person values (2, '{
                *
    ERROR at line 1:
    ORA-40875: JSON schema validation error
    ```

    Automatically a check constraint to validate the schema is created. Query `USER_DOMAIN_CONSTRAINTS` to verify this.
    ```
    <copy>set long 1000;
    col name format a30;</copy>
    ```
    ```
    <copy>SELECT name, generated, constraint_type, search_condition
        FROM user_domain_constraints where domain_name like 'P_RECORD%';</copy>
    ```

    ```
    NAME                 GENERATED      C
    -------------------- -------------- -
    SEARCH_CONDITION
    ---------------------------------------------------------------------
    SYS_DOMAIN_C0035     GENERATED NAME C
    "P_RECORDDOMAIN" IS JSON VALIDATE USING '{
    "type": "object",
    "properties": {
    "first_name": { "type": "string" },
    "last_name": { "type": "string" },
    "birthday": { "type": "string", "format": "date" },
    "address": {
    "type": "object",
    "properties": {
    "street_address": { "type": "string" },
    "city": { "type": "string" },
    "state": { "type": "string" },
    "country": { "type" : "string" } } } } }'
    ```

You have now **completed this workshop**.

## Learn More

* [SQL Language Reference](https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/index.html)
* [Database Development Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/adfns/registering-application-data-usage-database.html#GUID-6F630041-B7AE-4183-9F97-E54682CA6319)
* [Blog: Less coding using new SQL Domains in 23ai](https://blogs.oracle.com/coretec/post/less-coding-with-sql-domains-in-23c)
* [Blog: Annotations - The new metadata in 23ai](https://blogs.oracle.com/coretec/post/annotations-the-new-metadata-in-23c)

## Acknowledgements
* **Author** - Ulrike Schwinn, Distinguished Data Management Expert; Hope Fisher, Program Manager
* **Last Updated By/Date** - Hope Fisher, Oct 2023