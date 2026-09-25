# Interact with the database using the JavaScript SQL Driver

## Introduction

All previous labs have carefully avoided accessing the data layer to ease the transition into server-side JavaScript development. Beginning with this lab, you will use the SQL Driver to access the database. Whilst this lab sticks with the basic concepts, the next lab focuses on JSON from a document model's point of view.

Estimated Lab Time: 10 minutes

### Objectives

In this lab, you will:

- Learn about the built-in JavaScript SQL Driver
- Retrieve information from the database
- Perform an insert into a table fetching the auto-generated primary key in the process

### Prerequisites

This lab assumes you have:

- An Oracle AI Database 26ai Free environment available to use
- Created the `emily` account as per Lab 1
- Logged into Database Actions as `emily`

## Task 1: Get familiar with the SQL Driver

The SQL Driver is an integral part of the JavaScript Engine. It is very similar to the client-side driver, `node-oracledb`, to ease the transition from client-side code to an implementation within the database. Connection management is the main difference between the two. In a client-side JavaScript environment a database connection has to be established explicitly. This is not necessary in the server-side environment because it executes in an existing database session.

The SQL API is provided in the `oracledb` object which can be obtained in three different ways:

- Either by importing `mle-js-oracledb` explicitly
- By using the global constant `oracledb`
- Alternatively, use the `session` variable injected into the global namespace

Each of these will be explained in depth in this lab.

## Task 2: Query the database

By completing this task, you will learn more about selecting information from the database.

1. Log into Database Actions' JavaScript editor

    Before starting any of the following tasks, you need to log into Database Actions as emily. Make sure to switch to the JavaScript editor.

    If you forgot the URL to log in to the emily account, use the Database Actions dropdown and select Database Users as shown in this screenshot:

    ![Screenshot showing how to view/modify and delete Database Users](../js-generic-get-started-example/images/create-user-01.png)

    In the ensuing dialog, identify the emily account and take a note of the URL.

    ![Screenshot showing all user accounts in the database](../js-generic-modules-environments/images/identify-sdw-url-01.png)

    Copy/paste it into your favorite browser and access Database Actions; use the option pointed to by the arrow to open Database Actions in a new window.

2. Query the database

    Instead of using the Editor pane, switch to using Snippets. You can run anonymous JavaScript code this way, without having to create a module and a call specification. This speeds up testing and development and is ideally suited for this lab.

    ```js
    <copy>
    const connection = oracledb.defaultConnection();

    const result = connection.execute(
        'select user'
    );

    console.log(result.rows[0].USER);
    </copy>
    ```

    > **Note**: Unlike `node-oracledb` the default `outFormat` for the MLE JavaScript SQL Driver in 26ai Free is `oracledb.OUT_FORMAT_OBJECT`.

3. Query the database using global constants

    The `session` variable, injected into the global namespace, provides a shortcut to having to create a connection instance. The above statement can be simplified to read as follows:

    ```js
    <copy>
    const result = session.execute(
        'select user'
    );

    console.log(result.rows[0].USER);
    </copy>
    ```

    Most developers are going to use the `session` object for simplicity.

    For a complete list of available global variables, see JavaScript Developer’s Guide, chapter 7.

4. Use a `ResultSet` rather than a Direct Fetch

    The previous examples demonstrated direct fetches. In other words all results are returned in the `result.rows` property. This can cause strain on the available memory if the result set is large. A more efficient way to fetch larger result sets is available in the form of the `ResultSet`.

    Create a sample table with some data first. You could do this using the SQL Worksheet, or simply ask the JavaScript driver to take care of this task for you.

    ```js
    <copy>
    session.execute(
        `create table result_set_demo_t as 
            select 
                * 
            from
                all_objects`
    );
    </copy>
    ```

    Next create a JavaScript script to iterate over the table.

    ```js
    <copy>
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
        console.log(`${row.OBJECT_ID}    ${row.OWNER}    ${row.OBJECT_NAME}`);
    }
    // it is good practice to close the result set
    rs.close();
    </copy>
    ```

    When executing the procedure you will see the first 100 lines of the table printed to your screen.

5. Using Bind Variables

    So far none of the examples in this lab have made use of bind variables. Bind variables must be passed as the second argument to the `execute()` function and they can be provided as an array or an object. This task makes use of the simplified syntax offered by an array. Note that the order of the variables inside the array representing bind values must be aligned with the placeholders from the query text.

    ```js
    <copy>
    ( (object_id) => {

        if (Number.isInteger(object_id) && object_id > 0) {
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
                    outFormat: oracledb.OUT_FORMAT_OBJECT
                }
            );

            if (result.rows.length === 0) {
                throw new Error(`no data found for object ID ${object_id}`);
            }

            for (let row of result.rows) {
                console.log(`${row.OBJECT_ID}    ${row.OWNER}    ${row.OBJECT_NAME}`);
            }
        } else {
            throw new Error('you must provide a positive integer number');
        }
    })(140);
    </copy>
    ```

    The Immediately Invoked Function Expression (IIFE) you see in the snippet takes a single argument, the object ID to fetch from the table. This is a common way of providing values for bind variables in JavaScript. A quick check ensures that the parameter passed is indeed a whole integer number greater than 0. In case no rows are found for a given number, an error is thrown.

## Task 3: Calling PL/SQL from JavaScript

The previous lab showed you how to query the database using SQL. In addition to using plain SQL you can make use of the rich PL/SQL API provided by the database. In this example, you will use the `DBMS_APPLICATION_INFO` package to instrument your code.

`DBMS_APPLICATION_INFO` is an important PL/SQL package allowing database developers to associate an application module and action with a session. Should your application ever encounter a performance degradation, your operations team can perform a detailed analysis based on the information available in the Automatic Workload Repository (AWR) and Active Session History (ASH), provided that the Diagnostics Pack is licensed.

This task showcases several additional features:

- IN and OUT (bind) variables
- Global variables in an MLE module
- Private functions (`getModuleAction()` and `setModuleAction()`)
- Custom exception handling
- The PL/SQL Foreign Function Interface (FFI)

1. Create the JavaScript module

    Switch to the JavaScript Editor and create a new module by pasting the following code into the editor. Name it `PLSQL_DEMO`.

    ```js
    <copy>
    let savedModuleAction = {};

    // private function - preserve the current values for module and action
    function getModuleAction() {

        // read the current module and action. Out-variables can be used
        // to retrieve the actual values and store them in the global
        // variable `savedModuleAction`.
        // The MLE Foreign Function Interface (FFI) greatly simplified access
        // to the database's PL/SQL API and is used here for convenience.

        const dbmsAppInfo = plsffi.resolvePackage('SYS.DBMS_APPLICATION_INFO');
            
        // out and in-out parameters to PL/SQL need to be declared
        const currentModule = plsffi.arg();
        const currentAction = plsffi.arg();
        
        dbmsAppInfo.read_module(currentModule, currentAction);
        
        /* a more traditional approach is to use an anonymous PL/SQL block:
        this would imply a lot more typing, which is why the FFI is used
        instead.

        const result = session.execute(`
            begin dbms_application_info.read_module(
                :l_prev_module, 
                :l_prev_action); 
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
        */

        savedModuleAction.module = currentModule.val === undefined ? 'not set' : String(currentModule.val);
        savedModuleAction.action = currentAction.val === undefined ? 'not set' : String(currentAction.val);

        console.log(
            `getModuleAction(): module and action successfully retrieved as:
            - module: ${savedModuleAction.module}
            - action: ${savedModuleAction.action}`
        );
    }

    // private function - restore the previous module and action
    function setModuleAction(module, action) {

        if ( typeof (module) !== "string") {
            throw new Error(`module must be a string, you passed a ${typeof module}`);
        }

        if ( typeof (action) !== "string") {
            throw new Error(`action must be a string, you passed a ${typeof action}`);
        }

        // this call changes the current module and action to the
        // values provided to the function
        const dbmsAppInfo = plsffi.resolvePackage('SYS.DBMS_APPLICATION_INFO');
        dbmsAppInfo.set_module(
            module,
            action
        )

        console.log(
            `setModuleAction(): module and action successfully updated to:
            - module: ${module}
            - action: ${action}`
        );
    }

    // public function - entry point to the demo
    // to keep the example simple the changes in module
    // and action are printed to the console
    export function moduleActionDemo(object_id) {

        // save the current module and action
        getModuleAction();

        // set module and action for this task
        setModuleAction('JavaScript PL/SQL demo', `${object_id}`);

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
            ]
        );

        if (result.rows.length === 0) {
            // reset values before throwing the exception
            setModuleAction(
                savedModuleAction.module,
                savedModuleAction.action
            );
            throw new Error(`no data found for object ID ${object_id}`);
        }

        for (const row of result.rows) {
            console.log(`Found a matching record: ${row.OBJECT_ID}    ${row.OWNER}    ${row.OBJECT_NAME}`);
        }

        // make sure module and action are set to their previous values
        // before returning from this function
        setModuleAction(
            savedModuleAction.module,
            savedModuleAction.action
        );
    }

    </copy>
    ```

2. Create a call specification for `moduleActionDemo()`

    Switch to SQL Worksheets to complete the next few steps. First, create the call specification:

    ```sql
    <copy>
    create or replace procedure moduleActionDemo(p_object_id number)
    as mle module PLSQL_DEMO
    signature 'moduleActionDemo(number)';

    </copy>
    ```

3. Execute the call specification

    Run the following snippet as a script:

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

    The command should complete successfully, but results will vary because object IDs aren't guaranteed to be assigned in the same way for each database. Here is an example of a successful execution:

    ```text
    getModuleAction(): module and action successfully retrieved as:
            - module: /_/sql
            - action: POST
    setModuleAction(): module and action successfully updated to:
            - module: JavaScript PL/SQL demo
            - action: 140
    Found a matching record: 140    SYS    ORA$BASE
    setModuleAction(): module and action successfully updated to:
            - module: /_/sql
            - action: POST


    PL/SQL procedure successfully completed.

    Elapsed: 00:00:00.139
    ```

## Task 4: Perform a DML operation

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

    Note the use of an object to provide bind variables (both IN and OUT) to the statement. The out-variable will fetch the auto-generated value for the primary key and return it to the caller. In contrast to the previous example, this time so-called _named binds_ are provided to the function.

    ```js
    <copy>
    create or replace function log_me(
        "p_log_message" log_t.log_message%type
    ) return log_t.log_id%type 
    as mle language javascript
    <<
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
                    type: oracledb.NUMBER
                }
            },
        );

        // by definition the outBinds array can contain only a single
        // element in this scenario. 
        return result.outBinds.id[0];
    >>;
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
        log_t;
    </copy>
    ```

You may now proceed to the next lab.

## Learn More

- [Server-Side JavaScript API Documentation](https://oracle-samples.github.io/mle-modules/)
- [node-oracledb Documentation](https://oracle.github.io/node-oracledb/)
- Chapter 7 in [JavaScript Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/mlejs/calling-plsql-and-sql-from-mle-js-code.html#GUID-69CF9858-66D7-45B6-ACAF-F08B059CF4F6) is dedicated to interacting with the database and explains all the concepts from this lab in much more detail
- [`DBMS_APPLICATION_INFO` reference](https://docs.oracle.com/en/database/oracle/oracle-database/26/arpls/DBMS_APPLICATION_INFO.html#GUID-14484F86-44F2-4B34-B34E-0C873D323EAD)

## Acknowledgements

- **Author** - Martin Bach, Senior Principal Product Manager, ST & Database Development
- **Contributors** - Lucas Braun, Sarah Hirschfeld
- **Last Updated By/Date** - Martin Bach 18-DEC-2025
