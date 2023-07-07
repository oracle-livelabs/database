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
* Oracle Database 23c Free Developer Release
* All previous labs successfully completed
* SQL Developer Web 23.1 or a compatible tool for running SQL statements

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

    > Note: The Run button runs just one SQL Statement and formats the output into a data grid. The Run Script button runs many SQL statements and spools their output.
    ![Image alt text](images/run_buttons.png " ")

2. To get an idea how to use it, let's create a simple example - an email domain - and use it in a person table.
    ```
    <copy>
    create domain if not exists myemail_domain AS VARCHAR2(100)
    default on null 'XXXX' || '@missingmail.com'
    constraint email_c CHECK (regexp_like (myemail_domain, '^(\S+)\@(\S+)\.(\S+)$'))
    display substr(myemail_domain, instr(myemail_domain, '@') + 1);
    </copy>
    ```

    We now have a domain called `myemail_domain`. The check constraint `EMAIL\_C` examines if the column stores a valid email, `DISPLAY` specifies how to convert the domain column for display purposes. You may use the SQL function `DOMAIN_DISPLAY` on the given column to display it.

3. Now let's use it in the table person.
    ```
    <copy>
    drop table if exists person;
    create table person
        ( p_id number(5),
        p_name varchar2(50),
        p_sal number,
        p_email varchar2(100) domain myemail_domain
        )
    annotations (display 'person_table');
    </copy>
    ```

    We now have a table called `person`. As you can see, you may also use annotations in combination with SQL domains. If you want more information on annotations, you find explanation and examples in [Annotations - The new metadata in 23c](https://blogs.oracle.com/coretec/post/annotations-the-new-metadata-in-23c).

4. Now let's insert additional rows with valid data.

    ```
    <copy>
    insert into person values (1,'Bold',3000,null);
    insert into person values (1,'Schulte',1000, 'user-schulte@gmx.net');
    insert into person values (1,'Walter',1000,'user_walter@t_online.de');
    insert into person values (1,'Schwinn',1000, 'UserSchwinn@oracle.com');
    insert into person values (1,'King',1000, 'user-king@aol.com');
    commit;
    </copy>
    ```

5. Let's try to insert invalid data.
    ```
    SQL> <copy>insert into person values (1,'Schulte',3000, 'user-schulte%gmx.net');</copy>
    ```
    You will get the following error message:
    ```
    ERROR at line 1:
    ORA-11534: check constraint (SCOTT.SYS_C008254) due to domain constraint
    SCOTT.EMAIL_C of domain SCOTT.MYEMAIL_DOMAIN violated
    ```

6. Now let's query the table PERSON.
    ```
    SQL> <copy>select * from person;</copy>
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
    SQL> <copy>desc person</copy>
    ```

    ```
    Name                                Null?    Type
    ----------------------------------- -------- ------------------------------------
    P_ID                                         NUMBER(5)
    P_NAME                                       VARCHAR2(50)
    P_SAL                                        NUMBER
    P_EMAIL                                      NOT NULL VARCHAR2(100) SCOTT.MYEMAIL_DOMAIN
    ```
2. As previously mentioned, there are new domain functions you may use in conjunction with the table columns to get more information about the domain properties. `DOMAIN_NAME` for example returns the qualified domain name of the domain that the argument is associated with, `DOMAIN_DISPLAY` returns the domain display expression for the domain that the argument is associated with. More information can be found in the [documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/index.html).
    ```
    SQL> <copy>col p_name format a25</copy>
    SQL> <copy>col DISPLAY format a25</copy>
    SQL> <copy>select p_name, domain_display(p_email) "Display" from person;</copy>
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
3. Another way to monitor SQl domains are data dictionary views such as `USER_DOMAIN`, `USER_DOMAIN_COLS`, and `USER_DOMAIN_CONSTRAINTS` (also with `ALL/DBA`).

    Here are some examples:
    ```
    SQL> <copy>col owner format a15</copy>
    SQL> <copy>select owner, name, data_display from user_domains;</copy>
    ```

    ```
    OWNER           NAME
    --------------- ------------------------------
    DATA_DISPLAY
    ------------------------------------------------------
    SCOTT           MYEMAIL_DOMAIN
    SUBSTR(myemail_domain, INSTR(myemail_domain, '@') + 1)
    ```

    ```
    SQL> <copy>select * from user_domain_constraints where domain_name='MYEMAIL_DOMAIN';</copy>
    ```

    ```
    NAME                           DOMAIN_OWNER    DOMAIN_NAME          C
    ------------------------------ --------------- -------------------- -
    SEARCH_CONDITION                                                                 STATUS
    -------------------------------------------------------------------------------- --------
    DEFERRABLE     DEFERRED  VALIDATED     GENERATED      BAD RELY INVALID ORIGIN_CON_ID
    -------------- --------- ------------- -------------- --- ---- ------- -------------
    EMAIL_C                        SCOTT           MYEMAIL_DOMAIN       C
    REGEXP_LIKE (myemail_domain, '^(\S+)\@(\S+)\.(\S+)$')                            ENABLED
    NOT DEFERRABLE IMMEDIATE VALIDATED     USER NAME                                   3
    SYS_DOMAIN_C0034               SCOTT           MYEMAIL_DOMAIN       C
    "MYEMAIL_DOMAIN" IS NOT NULL                                                     ENABLED
    NOT DEFERRABLE IMMEDIATE VALIDATED     GENERATED NAME                              3
    ```

4. But what about the "good old" package `DBMS_METADATA` to get the `DDL` command?

    Let's try `GET_DDL` and use `SQL_DOMAIN` as an object_type argument.

    ```
    SQL> <copy>select dbms_metadata.get_ddl('SQL_DOMAIN', 'MYEMAIL_DOMAIN') from dual;</copy>
    ```

    And et voila you will get the result.

    ```
    DBMS_METADATA.GET_DDL('SQL_DOMAIN','MYEMAIL_DOMAIN')
    ----------------------------------------------------------------------------------------------------
    CREATE DOMAIN "SCOTT"."MYEMAIL_DOMAIN" AS VARCHAR2(100) DEFAULT ON NULL 'XXXX' || '@missingmail.com'
    CONSTRAINT "EMAIL_C" CHECK (REGEXP_LIKE (myemail_domain, '^(\S+)\@(\S+)\.(\S+)$')) ENABLE
    DISPLAY SUBSTR(myemail_domain, INSTR(myemail_domain, '@') + 1)
    ```

## Task 3: Use built-in domains

In addition, to make it easier for you to start with Oracle provides built-in domains you can use directly on table columns - for example, email, ssn, and credit_card. You find a list of them with names, allowed values and description in the documentation.

1. Another way to get this information is to query `ALL_DOMAINS` and filter on owner `SYS`. Then you will receive the built-in domains.
    ```
    SQL> <copy>select name from all_domains where owner='SYS';</copy>
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
    SQL> <copy>col domain_ddl format a100</copy>
    SQL> <copy>select dbms_metadata.get_ddl('SQL_DOMAIN', 'EMAIL_D','SYS') domain_ddl from dual;</copy>
    ```

    ```
    DOMAIN_DDL
    ----------------------------------------------------------------------------------------------------
    CREATE DOMAIN "SYS"."EMAIL_D" AS VARCHAR2(4000) CHECK (REGEXP_LIKE (email_d, '^([a-zA-Z0-9!#$%&*+=
    ?^_`{|}~-]+(\.[A-Za-z0-9!#$%&*+=?^_`{|}~-]+)*)@(([a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z0-
    9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)$')) ENABLE
    ```
3. Now let's re-create our table `PERSON`.
    ```
    <copy>
    create table person
    ( p_id number(5),
    p_name varchar2(50),
    p_sal number,
    p_email varchar2(4000) domain EMAIL_D
        )
    annotations (display 'person_table');
    </copy>
    ```

    Keep in mind that we need to adjust the length of the column `P_EMAIL` to **4000** - otherwise you will receive the following error:
    ```
    SQL> create table person
        ( p_id number(5),
        p_name varchar2(50),
        p_sal number,
        p_email varchar2(2000) domain EMAIL_D
        )
    annotations (display 'person_table');
    ```

    ```
    create table person
    *
    ERROR at line 1:
    ORA-11517: the column data type does not match the domain column
    ```

4. In the next step let's insert some data.
    ```
    <copy>insert into person values (1,'Bold',3000,null);</copy>
    1 row created.
    ```

    ```
    <copy>insert into person values (1,'Schulte',1000, 'user-schulte@gmx.net');</copy>
    1 row created.
    ```

    We'll need to format our entries to avoid error.
    ```
    insert into person values (1,'Walter',1000,'user-walter@t_online.de')
    *
    ERROR at line 1:
    ORA-11534: check constraint (SCOTT.SYS_C008255) due to domain constraint SYS.SYS_DOMAIN_C002 of domain SYS.EMAIL_D
    violated
    ```
    The email with the sign '_'  is not a valid entry, so we need to change it to '-'.
    ```
    SQL> <copy>insert into person values (1,'Walter',1000,'user-walter@t-online.de');</copy>
    1 row created.
    ```

## Task 4: Validate JSON

The 23c Oracle database supports not only the JSON datatype but also **JSON schema validation**.  A JSON schema - similar to XML schema - defines the rules that allow you to annotate and validate JSON documents. The schema specifies the permitted keywords, data types for their values, and the structure in which they can be nested. You can define the key-value pairs as mandatory or optional. Now you can validate a JSON document using a JSON schema with the `IS JSON` check constraint clause `VALIDATE`; in addition you may even use shorthand syntax without the check constraint instead.

1. The following example shows how to use an inline schema definition in a `CREATE TABLE` command (the shorthand syntax without a check constraint).
    ```
    create table person
    (id NUMBER,
    p_record JSON VALIDATE '<json-schema>')
    ```

    SQL domains also support JSON validation now. The difference between the inline schema definition and the SQL domain is that a SQL domain stores a reference to the SQL domain (call by reference instead of call by value). If the SQL domain changes, so does the validation logic. If the SQL domain is dropped, validation does not happen and an error to this effect is raised.

2. Let's give an example using a SQL domain with the JSON validation clause `[VALIDATE USING <json_schema_string>]`. The JSON schema describes a person JSON document.
    ```
    <copy>
    create domain p_record domain AS JSON VALIDATE USING '{
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

    create person (id NUMBER,
                p_record JSON DOMAIN p_recorddomain);
    </copy>
    ```

3. Now we insert valid data.
    ```
    <copy>
    insert into person values (1, '{
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
    ```

4. The next record is not a valid entry.
    ```
    SQL> <copy>insert into person values (2, '{
    "name": "George Washington",
    "birthday": "February 22, 1732",
    "address": "Mount Vernon, Virginia, United States"
        }');
    </copy>
    ```

    ```
    insert into person values (2, '{
                *
    ERROR at line 1:
    ORA-40875: JSON schema validation error
    ```

    Automatically a check constraint to validate the schema is created. Query `USER_DOMAIN_CONSTRAINTS` to verify this.
    ```
    SQL> <copy>set long 400</copy>
    SQL> <copy>col name format a20</copy>
    SQL> <copy>select name, generated, constraint_type, search_condition
        from user_domain_constraints where domain_name like 'P_RECORD%'</copy>
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
* [Blog: Less coding using new SQL Domains in 23c](https://blogs.oracle.com/coretec/post/less-coding-with-sql-domains-in-23c)
* [Blog: Annotations - The new metadata in 23c](https://blogs.oracle.com/coretec/post/annotations-the-new-metadata-in-23c)

## Acknowledgements
* **Author** - Ulrike Schwinn, Distinguished Data Management Expert; Hope Fisher, Program Manager
* **Last Updated By/Date** - Hope Fisher, June 2023