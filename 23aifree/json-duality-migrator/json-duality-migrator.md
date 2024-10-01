# JSON-To-Duality Migrator

## Introduction

The **JSON-To-Duality Migrator** is a new tool in Oracle Database 23ai that can migrate one or more existing sets of JSON documents to JSON-relational duality views. The migrator can be used for database migration from any document database using JSON documents or build a new application using JSON documents as the migrator will automatically create the necessary duality views.
The JSON-To-Duality Migrator is PL/SQL based. Its PL/SQL subprograms generate the views based on implicit document-content relations (shared content). By default, document parts that can be shared are shared, and the views are defined for maximum updatability. In this lab, we will migrate a JSON collection called CONF_SCHEDULE into Oracle Database 23ai and will test the end-result from both SQL Developer and MongoDB Compass.
The new migrator which has two components:
- **Converter**: Create the database objects needed to support the original JSON documents: duality views and their underlying tables and indexes.
- **Importer**: Import Oracle Database JSON-type document sets that correspond to the original external documents into the duality views created by the converter.

The **converter** is composed of these PL/SQL functions in package **DBMS\_JSON\_DUALITY**:
- **infer\_schema** infers the JSON schema that represents all of the input document sets.
- **generate\_schema** produces the code to create the required database objects for each duality view.
- **infer\_and\_generate\_schema** performs both operations.


Estimated Time: 10 minutes


### Objectives

In this lab, you will:

- Create a native JSON collection using the new syntax
- Import data from JSON files
- Run the JSON-To-Duality Migrator (both converter and importer)
- Validate the newly created objects (tables and duality views)


### Prerequisites

- Oracle Database 23ai, version 23.4 or above
- MongoDB Compass [can be downloaded for free from here](https://www.mongodb.com/docs/compass/current/install/)


## Task 1: Connect to MongoDB Compass:

1. Open the MongoDB Compass and start the new connection:

    ![New Connection](images/new_connection_compass.png)

    - If you install ORDS in non-autonomous database, then you get the connection string during the installation process. The Oracle API for MongoDB connection string is:

        ```
        <copy>
        mongodb://[{user}:{password}@]localhost:27017/{user}?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true
        </copy>
        ```
    *Note: Replace the user, password and localhost with yours*

    - For ADB, it is given when enabling the MongoDB API.

2. Connect to the database:

    ![Connect to the database](images/compass_connection.png)

## Task 2: Clean up the environment:

1. Follow these steps to clean up your environment. These steps are only needed in case you're running the workshop more than once. If this is the first time you are using this workshop, you can skip the cleanup.

    ```
    <copy>
    DROP VIEW if exists CONF_SCHEDULE_DUALITY;
    DROP TABLE if exists CONF_SCHEDULE PURGE;
    DROP TABLE if exists CONF_SCHEDULE_SCHEDULE PURGE;
    DROP TABLE if exists CONF_SCHEDULE_ROOT PURGE;
    </copy>
    ```

## Task 3: Create a native JSON collection

1. Option 1: In SQL Developer run:

    ```
    <copy>CREATE JSON COLLECTION TABLE CONF_SCHEDULE;</copy>
    ```

2. Option 2: Create in MongoDB Compass the collection **CONF\_SCHEDULE**

    ![Create Collection](images/create_collection.png)


## Task 4: Import the document(s) from MongoDB Compass into CONF_SCHEDULE

1. Download the [BHRJ_Schedule.json](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/labfiles/BHRJ_Schedule.json) document.

    ![Add File](images/add_file.png)
    ![Choose File](images/import_data.png)

2. Import the BHRJ_Schedule.json file

    ![Import File](images/import_schedule.png)
    ![Show import](images/imported_completed.png)


## Task 5: Run the JSON-To-Duality Migrator

1. Follow this code to run the JSON-To-Duality Migrator: we will do infer\_schema and generate\_schema together.

    ```
    <copy>
    SET SERVEROUTPUT ON
    SET LINESIZE 10000
    DECLARE
        DBschema_sql clob;
        myCurrentSchema varchar2(128) default null;
    BEGIN
        SELECT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') into myCurrentSchema;

        DBschema_sql :=
        dbms_json_duality.infer_and_generate_schema(
            json('{"tableNames"    : [ "CONF_SCHEDULE" ],
                "useFlexFields" : false,
                "updatability"  : false,
                "sourceSchema"  : '''|| myCurrentSchema|| '''}'));
        dbms_output.put_line('DDL Script: ');
        dbms_output.put_line(DBschema_sql);

        execute immediate DBschema_sql;

        dbms_json_duality.import(table_name => 'CONF_SCHEDULE', view_name => 'CONF_SCHEDULE_DUALITY');
    END;
    /
    </copy>
    ```
## Task 6: Validate the newly created objects and check the output from the select statement below

1. In SQL Developer run:

    ```
    <copy>
    select json_serialize(data pretty) from "CONF_SCHEDULE_DUALITY";
    select * from user_objects where object_name like '%SCHEDULE%';
    select * from CONF_SCHEDULE_SCHEDULE;
    select * from CONF_SCHEDULE_ROOT;
    </copy>
    ```

2. In MongoDB Compass after refreshing the databases, click on the **CONF\_SCHEDULE\_DUALITY** collection under the ADMIN database

    ![Conf Schedule Duality](images/conf_schedule_duality%20collection.png)

3. In mongosh, verify the number of documents in the **CONF\_SCHEDULE\_DUALITY** collection:

    ```
    hol23> <copy>db.CONF_SCHEDULE_DUALITY.countDocuments({});
    </copy>
    ```
## Learn More

* [JSON-Relational Duality Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/jsnvu/json-duality.html)

## Acknowledgements

* **Author** - Julian Dontcheff, Hermann Baer
* **Contributors** -  David Start, Ranjan Priyadarshi
* **Last Updated By/Date** - Carmen Berdant, Technical Program Manager, July 2024