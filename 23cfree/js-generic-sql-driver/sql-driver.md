# Interact with the database using the SQL Driver

## Introduction

All previous labs have carefully avoided accessing the data layer to ease the transition into server-side JavaScript development. Beginning with this lab you will use the SQL Driver to access the database. Whilst this lab sticks with the basic concepts, the next lab focuses on JSON both from a relational as well as from a document model's point of view.

Estimated Lab Time: 10 minutes

### Objectives

In this lab, you will:

- Learn about the built-in JavaScript SQL Driver
- Retrieve information from the database
- Perform an insert into a table fetching the auto-generated primary key in the process

### Prerequisites

This lab assumes you have:

- An Oracle Database 23c Free - Developer Release environment available to use
- Created the `jstest` account as per Lab 1

## Task 1: Get familiar with the SQL Driver

The JavaScript SQL Driver is an integral part of Multilingual Engine (MLE). It is very similar to the client-side driver, `node-oracledb` to ease the transition from client-side code to an implementation within the database. Connection management is the main difference between the two. Whilst it is the developer's responsibility to establish a session with the database this step can be omitted in MLE because a session already exists.

There are two different ways to execute queries against the database

- Using the `node-oracledb` compatible syntax
- Using objects provided in JavaScript's global scope

Both of these will be explained in depth in this lab.

## Task 2: Querying the database

By completing this task, you will learn more about selecting information from the database.

1. Create a database session

    Connect to `freepdb1` just as you did in the previous labs, don't forget to substitute the dummy password with your own

    ```bash
    <copy>sqlplus jstest/yourNewPasswordGoesHere@localhost/freepdb1</copy>
    ```

2. Query the database using the `node-oracledb`-compatible syntax

    ```js
    <copy>
    create or replace mle module sql_driver_lab language javascript as

    import oracledb from "mle-js-oracledb";

    export function whoAmI() {
        // link the JavaScript SQL Driver to the existing session
        const connection = oracledb.defaultConnection();

        // execute the query, providing 
        // - the SQL text
        // - bind variables (there are none in the example)
        // - additional options to execute()
        const result = connection.execute(
            'select user',
            [],
            {
                outFormat: oracledb.OUT_FORMAT_OBJECT
            }
        );

        return result.rows[0].USER;
    }
    /
    </copy>
    ```

    > **Note**: Unlike `node-oracledb` the default `outFormat` for the MLE JavaScript SQL Driver in 23c Free-Developer Release is `oracledb.OUT_FORMAT_OBJECT`.

3. Query the database using variables provided in the global scope

    A number of variables have been added to the global scope to enhance the developer experience. In this example you can learn how to re-write the previous module to make use of the variables in the global scope.

    For a complete list of available global variables, see JavaScript Developer’s Guide, chapter 6.

    ```js
    <copy>
    create or replace mle module sql_driver_lab language javascript as

    // note the absence of the import statement

    export function whoAmI() {

        // there is no need to grab the defaultConnection()
        
        // execute the query, providing 
        // - the SQL text
        // - bind variables (there are none in the example)
        // - additional options to execute()
        const result = session.execute(
            'select user',
            [],
            {   // oracledb is also available in the global scope
                outFormat: oracledb.OUT_FORMAT_OBJECT
            }
        );

        return result.rows[0].USER;
    }
    /
    </copy>
    ```

    There are a few noteworthy differences in the code:

    - Because `oracledb` is part of the global scope there is no need to import it
    - The `session` object refers to the default connection you'd otherwise have to obtain using an extra line of code

4. Use a `ResultSet` rather than a Direct Fetch

    The previous examples demonstrated direct fetches. In other words all results are returned in the `result.rows` property. This can cause strain on the available memory if the result set is large. A more efficient way to fetch larger result sets is available in the form of the `ResultSet`.

    Create a sample table with some data first.

    ```sql
    <copy>
    create table result_set_demo_t as 
    select 
        * 
    from
        all_objects;
    </copy>
    ```

    Next create an inline JavaScript function to iterate over the table. Inline JavaScript functions only permit importing modules built-into MLE _dynamically_ (see below for the API reference). Because dynamic imports require additional language elements to be used it is easier to refer to the `oracledb` and `session` objects in the global scope.

    ```js
    <copy>
    create or replace procedure result_set_demo 
    as mle language javascript
    q'~
    const result = session.execute(
        `select
            owner,
            object_name,
            object_id
        from
            result_set_demo_t
        fetch first 100 rows only`,
        [],
        {
            resultSet: true,
            outFormat: oracledb.OUT_FORMAT_OBJECT
        }
    );

    const rs = result.resultSet;

    // use the iterable protocol with the resultSet
    for (let row of rs) {
        console.log(`${row.OBJECT_ID}\t${row.OWNER}\t${row.OBJECT_NAME}`);
    }
    ~';
    /
    </copy>
    ```

    When executing the procedure you will see the first 100 lines of the table printed to your screen.

5. Using Bind Variables

    So far none of the examples in this lab have made use of bind variables. Bind variables must be passed as the second argument to the `execute()` function and they can be provided as an array or an object. This tasks makes use of the simplified syntax offered by an array. Note that the order of the variables inside the array representing bind values must be aligned with the placeholders from the query text.

    ```js
    <copy>
    create or replace procedure result_set_demo_binds(
        "p_object_id" number
    )
    as mle language javascript
    q'~
    const result = session.execute(
        `select
            owner,
            object_name,
            object_id
        from
            result_set_demo_t
        where
            object_id = :p_object_id`,
        [
            p_object_id
        ],
        {
            resultSet: true,
            outFormat: oracledb.OUT_FORMAT_OBJECT
        }
    );

    const rs = result.resultSet;
    let numRows = 0;

    // use the iterable protocol with the resultSet
    for (let row of rs) {
        console.log(`${row.OBJECT_ID}\t${row.OWNER}\t${row.OBJECT_NAME}`);
        numRows++
    }

    rs.close();

    if ( numRows === 0 ) {
        throw `no data found for object ID ${p_object_id}`;
    }
    ~';
    /
    </copy>
    ```

    The newly created procedure `result_set_demo_binds` accepts integer values as input. Go ahead and try a few times to see if you can get output on your screen matching an `object_id` in the table.

## Lab 3: Calling PL/SQL from JavaScript

The previous lab showed you how to query the database using SQL. In addition to using plain SQL you can make use of the rich PL/SQL API provided by the database. In this example you will use the `DBMS_APPLICATION_INFO` package to instrument your code. This lab showcases several additional features:

- IN and OUT (bind-) Variables
- Global variables in an MLE module
- Private functions (`saveModuleAction()` and `setModuleAction()`)
- Custom exception handling

1. Create the JavaScript module

    ```js
    <copy>
    create or replace mle module plsql_demo
    language javascript as

    // global variable used to preserve the existing module and action
    let savedModuleAction = {};

    // private function - preserve the current values for module and action
    function saveModuleAction() {

        const result = session.execute(`
            begin 
                dbms_application_info.read_module(
                    :l_prev_module, 
                    :l_prev_action
                ); 
            end;`,
            {
                l_prev_module: {
                    dir: oracledb.BIND_OUT,
                    type: oracledb.STRING
                },
                l_prev_action: {
                    dir: oracledb.BIND_OUT,
                    type: oracledb.STRING
                }
            }
        );

        savedModuleAction.module = result.outBinds.l_prev_module;
        savedModuleAction.action = result.outBinds.l_prev_action;
    }

    // private function - restore the previous module and action
    function setModuleAction(module, action) {

        session.execute(`
            begin dbms_application_info.set_module(
                module_name => :module,
                action_name => :action);
            end;`,
            [ module, action ]
        );
    }

    // public function - entry point to the demo
    export function moduleActionDemo(object_id) {

        // save the current module and action
        saveModuleAction();

        // set module and action for this task
        setModuleAction('JavaScript PLSQL demo', object_id);

        // execute the "application code"
        const result = session.execute(
            `select
                owner,
                object_name,
                object_id
            from
                result_set_demo_t
            where
                object_id = :object_id`,
            [
                object_id
            ],
            {
                resultSet: true,
                outFormat: oracledb.OUT_FORMAT_OBJECT
            }
        );

        const rs = result.resultSet;
        let numRows = 0;

        for (let row of rs) {
            console.log(`${row.OBJECT_ID}\t${row.OWNER}\t${row.OBJECT_NAME}`);
            numRows++
        }

        rs.close();

        // check if any data was returned, throw an exception otherwise
        if ( numRows === 0 ) {
            // make sure module and action are set to their previous values
            setModuleAction(savedModuleAction.module, saveModuleAction.action);
            throw `no data found for object ID ${p_object_id}`;
        }
        
        // make sure module and action are set to their previous values
        setModuleAction(savedModuleAction.module, saveModuleAction.action);
    }
    /
    </copy>
    ```

2. Create a call specification for `moduleActionDemo()`

    ```sql
    <copy>
    create or replace procedure moduleActionDemo(p_object_id number)
    as mle module plsql_demo
    signature 'moduleActionDemo(number)';
    /
    </copy>
    ```

3. Execute the call specification

    ```sql
    <copy>
    declare
        l_object_id RESULT_SET_DEMO_T.object_id%type;
    begin
        select 
            min(object_id)
        into
            l_object_id
        from
            RESULT_SET_DEMO_T;
        
        moduleActionDemo(l_object_id);
    end;
    /
    </copy>
    ```

## Lab 4: Perform a DML operation

The previous tasks in this lab focused on _reading_ from the database. In this part of the lab you will perform an insert operation for a change. Rather than providing all columns as part of the insert, you will use a primary key that is defined as an Identity Column.

1. Create a new table for this example

    ```sql
    <copy>
    create table log_t (
        log_id number generated always as identity,
        constraint pk_log_t primary key (log_id),
        log_message varchar2(1024),
        log_time timestamp default systimestamp not null
    );
    </copy>
    ```

2. Create an inline JavaScript function to facilitate the insert statement

    ```js
    <copy>
    create or replace function log_me(
        "p_log_message" log_t.log_message%type
    ) return log_t.log_id%type 
    as mle language javascript
    q'~
    const result = session.execute(
        `insert into log_t (
            log_message
        ) values (
            :message
        )
        returning log_id into :id`,
        {
            message: {
                dir: oracledb.BIND_IN,
                val: p_log_message,
                type: oracledb.STRING
            },
            id: {
                dir: oracledb.BIND_OUT,
                type: oracledb.STRING
            }
        },
    );

    // by definition the outBinds array can contain only a single
    // element in this scenario. The value must be converted from
    // a string to a number or else an error occurs
    return parseInt(result.outBinds.id[0]);
    ~';
    /
    </copy>
    ```

3. Add an example log message

    ```sql
    <copy>
    declare
        l_id number;
    begin
        l_id := log_me('this is a first test');
        dbms_output.put_line('entry created with ID: ' || l_id);
    end;
    /
    </copy>
    ```

4. View the log message

    Query the log table using the log ID you just obtained

    ```sql
    <copy>
    select
        *
    from
        log_t
    where
        log_id = &id;
    </copy>
    ```

## Learn More

- [MLE API Reference](https://oracle-samples.github.io/mle-modules)
- [node-oracledb](https://oracle.github.io/node-oracledb/)
- Chapter 6 in [JavaScript Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/mlejs/calling-plsql-and-sql-from-mle-js-code.html#GUID-69CF9858-66D7-45B6-ACAF-F08B059CF4F6) is dedicated to interacting with the database
- [PL/SQL Packages and Types Reference](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/index.html)

## Acknowledgements

- **Author** - Martin Bach, Senior Principal Product Manager, ST & Database Development
- **Contributors** -  Lucas Braun, Sarah Hirschfeld
- **Last Updated By/Date** - Martin Bach APRIL 2023
