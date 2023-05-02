# Post Execution Debugging

## Introduction

Oracle's JavaScript Engine allows developers to debug their code by conveniently and efficiently collecting runtime state during program execution. After the code has finished executing, the collected data can be used to analyze program behavior and discover and fix bugs. This form of debugging is known as _post-execution debugging_.

The post-execution debug option enables developers to instrument their code by specifying debugpoints in the code. Debugpoints allow you to log program state conditionally or unconditionally, including values of individual variables as well as execution snapshots. Debugpoints are specified as JSON documents separate from the application code. No change to the application is necessary for debug points to fire.

When activated, debug information is collected according to the debug specification and can be fetched for later analysis by a wide range of tools thanks to its standard format.

Estimated Lab Time: 15 minutes

### Objectives

In this lab, you will:

- Learn about the format of debug specifications
- Create a debug specification for a JavaScript module
- Run code with debugging enabled
- Parse the debug output
- Learn how to write code with an option to enable debugging dynamically at runtime

### Prerequisites

This lab assumes you have:

- An Oracle Database 23c Free - Developer Release environment available to use
- Created the `jstest` account as per Lab 1
- Completed Lab 2 where you created a number of JavaScript modules in the database

## Task 1: Create a database session

Connect to the pre-created Pluggable Database (PDB) `freepdb1` using the same credentials you supplied in Lab 1.

```bash
<copy>sqlplus jstest/yourNewPasswordGoesHere@localhost/freepdb1</copy>
```

## Task 2: Prepare the debug specification

The necessary debug specification is defined as a JSON document. It consists of

- A preamble
- An array of debugpoints

Each debugpoint in turn defines

- The location in the module's code where to fire
- Which action to take, optionally providing a condition for the probe to fire

Actions include printing the value of a single variable (`watch` point) or taking a `snapshot` of all variables in the current scope.

1. Review the `business_logic` module's source code

    ```
    SQL> select line, text from user_source where name = 'BUSINESS_LOGIC';

    LINE TEXT
    ---- ----------------------------------------------------------------------------
    1    import { string2obj } from 'helpers';
    2
    3    export function processOrder(orderData) {
    4
    5      const orderDataJSON = string2obj(orderData);
    6      const result = session.execute(`
    7         insert into orders (
    8             order_id,
    9             order_date,
    10             order_mode,
    11             customer_id,
    12             order_status,
    13             order_total,
    14             sales_rep_id,
    15             promotion_id
    16         )
    17         select
    18             jt.*
    19         from
    20             json_table(:orderDataJSON, '$' columns
    21                 order_id             path '$.order_id',
    22                 order_date timestamp path '$.order_date',
    23                 order_mode           path '$.order_mode',
    24                 customer_id          path '$.customer_id',
    25                 order_status         path '$.order_status',
    26                 order_total          path '$.order_total',
    27                 sales_rep_id         path '$.sales_rep_id',
    28                 promotion_id         path '$.promotion_id'
    29         ) jt`,
    30         {
    31             orderDataJSON: {
    32                 val: orderDataJSON,
    33                 type: oracledb.DB_TYPE_JSON
    34             }
    35         }
    36     );
    37
    38     if ( result.rowsAffected === 1 ) {
    39         return true;
    40     } else {
    41         return false;
    42     }
    43 }

    43 rows selected.
    ```

2. Define the debug specification

    In this step you create a debug specification with the following contents:
    - A watchpoint to print the contents of `orderDataJSON` in line 6
    - A snapshot of the entire stack in line 38

    The debug specification consists primarily of an array of JavaScript objects defining which action to take at a given code location.

    ```json
    {
        "version": "1.0",
        "debugpoints": [
            {
                "at": {
                    "name": "BUSINESS_LOGIC",
                    "line": 6
                },
                "actions": [
                    {
                        "type": "watch",
                        "id": "orderDataJSON"
                    }
                ]
            },
            {
                "at": {
                    "name": "BUSINESS_LOGIC",
                    "line": 38
                },
                "actions": [
                    {
                        "type": "snapshot"
                    }
                ]
            }
        ]
    }
    ```

## Task 3: Run the code with the debug specification attached

This step brings it all together. The debug specification is stored in a variable of type `JSON`, the code is executed with the debug specification attached, and the result is printed on screen.

```sql
<copy>
set serveroutput on
declare
    -- variables needed for post-execution debugging
    l_debugspec       JSON;
    l_debugsink       BLOB;
    l_debugtext       JSON;

    -- variables related to the business logic
    l_success         boolean := false;
    l_order_as_string varchar2(512);
begin
    -- initialise the debug specification
    l_debugspec := JSON('
        {
            "version": "1.0",
            "debugpoints": [
                {
                    "at": {
                        "name": "BUSINESS_LOGIC",
                        "line": 6
                    },
                    "actions": [
                        {
                            "type": "watch",
                            "id": "orderDataJSON"
                        }
                    ]
                },
                {
                    "at": {
                        "name": "BUSINESS_LOGIC",
                        "line": 38
                    },
                    "actions": [
                        {
                            "type": "snapshot"
                        }
                    ]
                }
            ]
        }');

    -- before any information can appended to a LOB it must be initialised first
    dbms_lob.createTemporary(l_debugsink, false, dbms_lob.session);

    -- enable debugging
    dbms_mle.enable_debugging(l_debugspec, l_debugsink);

    -- run the business logic
    l_order_as_string := 'order_id=1;order_date=2023-04-24T10:27:52;order_mode=theMode;customer_id=1;order_status=2;order_total=42;sales_rep_id=1;promotion_id=1';
    l_success  := business_logic_pkg.process_order(l_order_as_string);

    -- get the debug output as JSON (not normally done this way, 
    -- tools such as Database Actions should be used instead because
    -- the debug output quickly becomes hard to read on screen when tracking
    -- many variables)
    l_debugtext := dbms_mle.parse_debug_output(l_debugsink);
    dbms_output.put_line('-- debug output: ' ||
        json_serialize(l_debugtext returning clob pretty)
    );

    -- disable debugging
    dbms_mle.disable_debugging();
exception
    when others then
        raise;
end;
/
</copy>
```

## Task 4: Review the generated debug output

When executing the above code snippet the following information is printed on screen:

```json
[
  [
    {
      "at": {
        "name": "JSTEST.BUSINESS_LOGIC",
        "line": 6
      },
      "values": {
        "orderDataJSON": {
          "customer_id": "1",
          "order_date": "2023-04-24T10:27:52",
          "order_id": "1",
          "order_mode": "theMode",
          "order_status": "2",
          "order_total": "42",
          "promotion_id": "1",
          "sales_rep_id": "1"
        }
      }
    }
  ],
  [
    {
      "at": {
        "name": "JSTEST.BUSINESS_LOGIC",
        "line": 38
      },
      "values": {
        "result": {
          "rowsAffected": 1
        },
        "this": {},
        "orderData": "order_id=1;order_date=2023-04-24T10:27:52;order_mode=theMode;customer_id=1;order_status=2;order_total=42;sales_rep_id=1;promotion_id=1",
        "orderDataJSON": {
          "customer_id": "1",
          "order_date": "2023-04-24T10:27:52",
          "order_id": "1",
          "order_mode": "theMode",
          "order_status": "2",
          "order_total": "42",
          "promotion_id": "1",
          "sales_rep_id": "1"
        }
      }
    }
  ]
]
```

You can see that both probes fired:

- The watchpoint recorded the contents of `orderDataJSON`
- The snapshot caused all variables defined in memory to be dumped:

    - `result`
    - `this`
    - `orderData`
    - `orderDataJSON`

## Task 5: Prepare for dynamic debugging

In an ideal scenario post-execution debugging should be simple to enable without having to change any code, maybe even by a "super user" application account. Otherwise, support will find it very hard to troubleshoot problems reported by the user base. Rather than hard-coding calls to `dbms_mle.enable_debugging()` and `dbms_mle.disable_debugging()`, in this task you will learn how to run business logic with debugging enabled on demand.

1. Create a table containing the debug specifications

    ```sql
    <copy>
    create table debug_metadata (
        debug_id number generated always as identity,
        constraint pk_debug_metadata primary key(debug_id),
        debug_spec JSON not null,
        valid boolean not null
    );
    </copy>
    ```

2. Add the debug specification created earlier to the table

    ```sql
    <copy>
    insert into debug_metadata (
        debug_spec,
        valid
    ) values (
        JSON('{
            "version": "1.0",
            "debugpoints": [
                {
                    "at": {
                        "name": "BUSINESS_LOGIC",
                        "line": 6
                    },
                    "actions": [
                        {
                            "type": "watch",
                            "id": "orderDataJSON"
                        }
                    ]
                },
                {
                    "at": {
                        "name": "BUSINESS_LOGIC",
                        "line": 38
                    },
                    "actions": [
                        {
                            "type": "snapshot"
                        }
                    ]
                }
            ]
        }'),
        true
    );

    commit;
    </copy>
    ```

3. The following table contains the result of each debug run for later analysis

    ```sql
    <copy>
    create table debug_runs (
        run_id number generated always as identity,
        constraint pk_debug_runs primary key(run_id),
        debug_spec number not null,
        constraint fk_spec_run foreign key (debug_spec) 
            references debug_metadata,
        run_start timestamp,
        run_end timestamp,
        debug_info BLOB not null
    );
    </copy>
    ```

4. Create a wrapper function for `business_logic_pkg.process_order()`

    The wrapper function adds another layer of abstraction to `process_order()` allowing the execution with and without a debug specification attached. The revised code of the `business_logic_pkg` is as follows:

    ```sql
    <copy>
    create or replace package business_logic_pkg as

        procedure process_order(
            p_order_data varchar2,
            p_debug_id debug_metadata.debug_id%type default null
        );

    end business_logic_pkg;
    /
    </copy>
    ```

    ```sql
    <copy>
    create or replace package body business_logic_pkg as

        -- process_order() is now a private function
        function process_order_prvt(
            p_order_data varchar2
        ) return boolean
            as mle module business_logic
            env business_module_env
            signature 'processOrder(string)';
        
        -- (public) wrapper function to process_order()
        procedure process_order(
            p_order_data varchar2,
            p_debug_id debug_metadata.debug_id%type default null
        ) as
            l_debugspec debug_metadata.debug_spec%type;
            l_debugsink BLOB;

            l_success   boolean := false;
            l_run_start timestamp;
            l_run_end   timestamp;
        begin
            -- check if debugging is required
            if p_debug_id is null then
                -- run normally
                dbms_output.put_line('running normally, no debug spec referenced in the call');
                l_success := process_order_prvt(p_order_data);
            else
                dbms_output.put_line('running with debugging enabled');

                -- run with debugging enabled, but only if a
                -- corresponding debug spec can be fetched
                -- from the metadata table
                begin
                    select 
                        debug_spec
                    into
                        l_debugspec
                    from
                        debug_metadata
                    where
                            debug_id = p_debug_id
                        and valid;
                exception
                    when no_data_found then
                        raise_application_error(
                            -20001, 
                            'no such debug spec: ' || p_debug_id
                        );
                    when others then
                        raise;
                end;
            
                -- before any information can appended to a LOB it must be initialised first
                dbms_lob.createTemporary(l_debugsink, false, dbms_lob.session);

                -- enable debugging
                dbms_mle.enable_debugging(l_debugspec, l_debugsink);
                
                -- record the start time
                l_run_start := systimestamp;

                -- run the business logic
                l_success := process_order_prvt(p_order_data);

                -- record the end time
                l_run_end := systimestamp;

                -- persist the debug information in the table
                insert into debug_runs (
                    debug_spec,
                    run_start,
                    run_end,
                    debug_info
                ) values (
                    p_debug_id,
                    l_run_start,
                    l_run_end,
                    l_debugsink
                );

                -- disable debugging
                dbms_mle.disable_debugging();
            end if;

            -- raise an error if the order couldn't be processed
            if not l_success then
                raise_application_error(
                    -20002,
                    'could not process the order'
                );
            end if;

            dbms_output.put_line('execution finished successfully');
        
        -- anything not caught should bubble up the error stack and dealt with
        -- by the caller of this procedure
        exception
            when others then
                raise;
        end process_order;

    end business_logic_pkg;
    /
    </copy>
    ```

## Task 6: Run code with optional debug info gathered

1. Run the wrapper code with debugging disabled

    ```sql
    <copy>
    declare
        -- variables related to the business logic
        l_order_as_string varchar2(512);
    begin
        l_order_as_string := 'order_id=1;order_date=2023-04-24T10:27:52;order_mode=theMode;customer_id=1;order_status=2;order_total=42;sales_rep_id=1;promotion_id=1';
        business_logic_pkg.process_order(l_order_as_string, null);
    exception
        when others then
            raise;
    end;
    /
    </copy>
    ```

    You should get the following output (some of it removed for clarity)

    ```
    SQL> /
    running normally, no debug spec referenced in the call
    execution finished successfully

    PL/SQL procedure successfully completed.
    ```

2. Run the wrapper code with debugging enabled

    ```sql
    <copy>
    declare
        -- variables related to the business logic
        l_order_as_string varchar2(512);
    begin
        l_order_as_string := 'order_id=1;order_date=2023-04-24T10:27:52;order_mode=theMode;customer_id=1;order_status=2;order_total=42;sales_rep_id=1;promotion_id=1';
        business_logic_pkg.process_order(l_order_as_string, 1);
    exception
        when others then
            raise;
    end;
    /
    </copy>
    ```

    You should get the following output (some of it removed for clarity)

    ```
    SQL> /
    running with debugging enabled
    execution finished successfully

    PL/SQL procedure successfully completed.
    ```

    In addition to the information printed on screen you can find the result of the debug run in the `debug_run` table. Get run metadata as follows (assuming this was the first successful execution the run ID will be 1, adjust as needed):

    ```sql
    <copy>
    select
        json_serialize(md.debug_spec pretty) debug_spec,
        r.run_start,
        r.run_end
    from
        debug_metadata md
        join debug_runs r
        on (md.debug_id = r.debug_spec)
    where
        r.run_id = 1
    </copy>
    ```

    You will see output like this:

    ```
    DEBUG_SPEC                          RUN_START                      RUN_END
    ----------------------------------- ------------------------------ ------------------------------
    {                                   26-APR-23 02.14.22.434468 PM   26-APR-23 02.14.22.463601 PM
    "version" : "1.0",
    "debugpoints" :
    [
        {
        "at" :
        {
            "name" : "BUSINESS_LOGIC",
            "line" : 6
        },
        "actions" :
        [
            {
            "type" : "watch",
            "id" : "orderDataJSON"
            }
        ]
        },
        {
        "at" :
        {
            "name" : "BUSINESS_LOGIC",
            "line" : 38
        },
        "actions" :
        [
            {
            "type" : "snapshot"
            }
        ]
        }
    ]
    }
    ```

    Now you can use whichever tool you like to pull the debug information from the `BLOB` column and anlyse it offline. You also have a history of debug activities including the results.

## Learn More

- Chapter 8 in [JavaScript Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/mlejs/post-execution-debugging.html#GUID-100D0D45-205A-44C7-BEF6-2A3241F41BF4) describes modules and environments in detail

## Acknowledgements

- **Author** - Martin Bach, Senior Principal Product Manager, ST & Database Development
- **Contributors** -  Lucas Braun, Sarah Hirschfeld
- **Last Updated By/Date** - Martin Bach 02-MAY-2023
