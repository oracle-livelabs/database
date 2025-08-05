# Introduction to the JSON to Duality Migrator

## Introduction

This lab walks you through the steps to use the JSON to Duality Migrator.

Estimated Lab Time: 15 minutes

### About the JSON to Duality Migrator

The JSON to Duality Migrator addresses the challenge of preserving JSON document semantics in relational schemas. By inferring implicit relationships from document collections, it generates updatable duality views that mirror original JSON structures. This method ensures backward compatibility for applications reliant on document APIs while leveraging relational optimization, such as indexing and ACID compliance. The tool supports iterative refinement, allowing developers to adjust inferred schemas post-migration.

### Objectives

In this lab, you will:

* Learn how to infer a relational schema using the JSON to Duality Migrator
* Learn how to import data into a duality view using the JSON to Duality Migrator

## Task 1: Create JSON collections and load some data

In this task, we will create JSON collection tables 'speaker, 'attendee', and 'session' that represents collections required for a database conference application.

1. Create the speaker, attendee, and session collections.

   ```sql
   <copy>
   CREATE JSON COLLECTION TABLE IF NOT EXISTS speaker;
   CREATE JSON COLLECTION TABLE IF NOT EXISTS attendee;
   CREATE JSON COLLECTION TABLE IF NOT EXISTS session;
   </copy>
   ```

2. Insert data into the speaker, attendee, and session collections.

   ```sql
   <copy>
   INSERT INTO speaker VALUES
     ('{"_id"            : 101,
        "name"           : "Abdul J.",
        "phoneNumber"    : "222-555-011",
        "yearsAtOracle"  : 25,
        "department"     : "Product Management",
        "sessionsTaught" : [ {"id" : 10, "sessionName" : "JSON and SQL",  "classType" : "Online"},
                             {"id" : 20, "sessionName" : "PL/SQL or Javascript", "classType" : "In-person"} ]}'),
     ('{"_id"            : 102,
        "name"           : "Betty Z.",
        "phoneNumber"    : "222-555-022",
        "yearsAtOracle"  : 30,
        "department"     : "Autonomous Databases",
        "sessionsTaught" : [ {"id" : 30, "sessionName" : "MongoDB API Internals", "classType" : "In-person"},
                             {"id" : 40, "sessionName" : "Oracle ADB on iPhone", "classType" : "Online"}, ]}'),
     ('{"_id"            : 103,
        "name"           : "Colin J.",
        "phoneNumber"    : "222-555-023",
        "yearsAtOracle"  : 27,
        "department"     : "In-Memory and Data",
        "sessionsTaught" : [ {"id" : 50, "sessionName" : "JSON Duality Views", "classType" : "Online"} ]}');

   INSERT INTO attendee VALUES
     ('{"_id"          : 1,
        "name"         : "Beda",
        "age"          : 20,
        "phoneNumber"  : "222-111-021",
        "coffeeItem"   : "Espresso",
        "sessions" : [ {"id" : 10, "sessionName" : "JSON and SQL", "credits" : 3, "testScore": 90},
                       {"id" : 20, "sessionName" : "PL/SQL or Javascript", "credits" : 4, "testScore": 70},
                       {"id" : 30, "sessionName" : "MongoDB API Internals", "credits" : 5, "testScore": 75},
                       {"id" : 40, "sessionName" : "Oracle ADB on iPhone", "credits" : 3, "testScore": 45},
                       {"id" : 50, "sessionName" : "JSON Duality Views", "credits" : 3, "testScore": 70} ]}'),
     ('{"_id"          : 2,
        "name"         : "Hermann",
        "age"          : 22,
        "phoneNumber"  : "222-112-023",
        "coffeeItem"   : "Cappuccino",
        "sessions" : [ {"id" : 40, "sessionName" : "JSON Duality Views", "credits" : 3, "testScore": 60},
                       {"id" : 30, "sessionName" : "MongoDB API Internals", "credits" : 5, "testScore": 70},
                       {"id" : 10, "sessionName" : "JSON and SQL", "credits" : 3, "testScore": 50} ]}'),
     ('{"_id"           : 3,
        "name"          : "Shashank",
        "age"           : 23,
        "phoneNumber"   : "222-112-024",
        "coffeeItem"    : "Americano",
        "sessions" : [ {"id" : 30, "sessionName" : "MongoDB API Internals", "credits" : 5, "testScore": 60},
                       {"id" : 10, "sessionName" : "JSON and SQL", "credits" : 3, "testScore": 50} ]}'),
     ('{"_id"          : 4,
        "name"         : "Julian",
        "age"          : 24,
        "phoneNumber"  : "222-113-025",
        "coffeeItem"   : "Decaf",
        "sessions" : [ {"id" : 40, "sessionName" : "JSON Duality Views", "credits" : 3, "testScore": 35} ]}');

   INSERT INTO session VALUES
     ('{"_id"               : 10,
        "sessionName"       : "JSON and SQL",
        "creditHours"       : 3,
        "attendeesEnrolled" : [ {"_id" : 1, "name": "Beda"}, {"_id" : 2, "name": "Hermann"}, {"_id" : 3, "name": "Shashank"} ]}'),
     ('{"_id"               : 20,
        "sessionName"       : "PL/SQL or Javascript",
        "creditHours"       : 4,
        "attendeesEnrolled" : [ {"_id" : 1, "name": "Beda"} ]}'),
     ('{"_id"               : 30,
        "sessionName"       : "MongoDB API Internals",
        "creditHours"       : 5,
        "attendeesEnrolled" : [ {"_id" : 1, "name": "Beda"}, {"_id" : 2, "name": "Hermann"}, {"_id" : 3, "name": "Shashank"} ]}'),
     ('{"_id"               : 40,
        "sessionName"       : "Oracle ADB on iPhone",
        "creditHours"       : 3,
        "attendeesEnrolled" : [ {"_id" : 1, "name": "Beda"} ]}'),
     ('{"_id"               : 50,
        "sessionName"       : "JSON Duality Views",
        "creditHours"       : 3,
        "attendeesEnrolled" : [ {"_id" : 1, "name": "Beda"}, {"_id" : 2, "name": "Hermann"}, {"_id" : 4, "name": "Julian"} ]}');

   COMMIT;
   </copy>
   ```

## Task 2: Schema inference using the JSON to Duality Migrator

In this task, we will infer a normalized relational schema using data from our JSON collections. The JSON to Duality Migrator will analyze the data in the input collections, and recommend a set of relational tables (including constraints, indexes, and sequences) and a set of duality views to match the input JSON collections.

1. Run the INFER\_AND\_GENERATE\_SCHEMA procedure to infer a relational schema using a few lines of PL/SQL code. This procedure will analyze the data in our input collections, infer an optimized normalized relational schema, and generate a DDL script to create the relational schema along with duality views for each collection. Here we store the generated DDL script in a CLOB variable and then call the 'EXECUTE IMMEDIATE' PL/SQL construct to execute the script.

   ```sql
   <copy>
   SET SERVEROUTPUT ON
   DECLARE
     schema_sql CLOB;
   BEGIN
     -- Infer relational schema
     schema_sql :=
      DBMS_JSON_DUALITY.INFER_AND_GENERATE_SCHEMA(
        JSON('{"tableNames" : [ "SESSION", "ATTENDEE", "SPEAKER" ]}')
      );

     -- Print DDL script
     DBMS_OUTPUT.PUT_LINE(schema_sql);

     -- Create relational schema
     EXECUTE IMMEDIATE schema_sql;
   END;
   /
   </copy>
   ```

2. Check the objects created by the migrator. Note that the relational schema is completely normalized - one table is created per logical entity, one for speaker (speaker\_root), one for attendee (attendee\_root), and one for sessions (sessions\_root). The many-to-many relationship between attendees and sessions is automatically identified and a mapping table is created to map attendees to sessions.

   ```sql
   <copy>
   SELECT object_name, object_type
   FROM user_objects
   WHERE created > sysdate-1/24
   ORDER BY object_type DESC;
   </copy>
   ```

   You can also use the two-phase API (INFER\_SCHEMA and GENERATE\_SCHEMA) to split the schema inference and DDL script generation into separate calls. This is useful when you want to inspect and hand-modify the resulting schema before generating the final DDL script.

3. Validate the schema using the VALIDATE\_SCHEMA\_REPORT table function. This should show no rows selected for each duality view, which means that there are no validation failures.

   ```sql
   <copy>
   SELECT * FROM DBMS_JSON_DUALITY.VALIDATE_SCHEMA_REPORT(table_name => 'SESSION', view_name => 'SESSION_DUALITY');
   SELECT * FROM DBMS_JSON_DUALITY.VALIDATE_SCHEMA_REPORT(table_name => 'ATTENDEE', view_name => 'ATTENDEE_DUALITY');
   SELECT * FROM DBMS_JSON_DUALITY.VALIDATE_SCHEMA_REPORT(table_name => 'SPEAKER', view_name => 'SPEAKER_DUALITY');
   </copy>
   ```

The result shows no rows selected indicating that the resulting schema fits the input collections.

## Task 3 - Data import using the JSON to Duality Migrator

In this task, we will import data from input JSON collections into the duality views. We will also look at techniques to find document that cannot be imported successfully and validate that data has been imported successfully.

1. Let’s create error logs to log errors for documents that do not get imported successfully.

   ```sql
   <copy>
   BEGIN
     DBMS_ERRLOG.CREATE_ERROR_LOG(dml_table_name => 'SESSION', err_log_table_name => 'SESSION_ERR_LOG', skip_unsupported => TRUE);
     DBMS_ERRLOG.CREATE_ERROR_LOG(dml_table_name => 'ATTENDEE', err_log_table_name => 'ATTENDEE_ERR_LOG', skip_unsupported => TRUE);
     DBMS_ERRLOG.CREATE_ERROR_LOG(dml_table_name => 'SPEAKER', err_log_table_name => 'SPEAKER_ERR_LOG', skip_unsupported => TRUE);
   END;
   /
   </copy>
   ```

2. Let’s import the data into the duality views using the IMPORT\_ALL procedure.

   ```sql
   <copy>
   BEGIN
     DBMS_JSON_DUALITY.IMPORT_ALL(
                         JSON('{"tableNames" : [ "SESSION", "ATTENDEE", "SPEAKER" ],
                                "viewNames"  : [ "SESSION_DUALITY", "ATTENDEE_DUALITY", "SPEAKER_DUALITY" ],
                                "errorLog"   : [ "SESSION_ERR_LOG", "ATTENDEE_ERR_LOG", "SPEAKER_ERR_LOG" ]}'
                         )
     );
   END;
   /
   </copy>
   ```

3. Query the error logs. The error logs are empty, showing that there are no import errors — there are no documents that did not get imported.

   ```sql
   <copy>
   SELECT ora_err_number$, ora_err_mesg$, ora_err_tag$ FROM SESSION_ERR_LOG;
   SELECT ora_err_number$, ora_err_mesg$, ora_err_tag$ FROM ATTENDEE_ERR_LOG;
   SELECT ora_err_number$, ora_err_mesg$, ora_err_tag$ FROM SPEAKER_ERR_LOG;
   </copy>
   ```

## Learn More

* [Blog: JSON-to-Duality Migrator](https://blogs.oracle.com/database/post/jsontoduality-migrator)
* [Migrating from JSON to Duality](https://docs.oracle.com/en/database/oracle/oracle-database/23/sutil/migrating-from-json-to-duality.html)
* [JSON-Relational Duality Views](https://docs.oracle.com/en/database/oracle/oracle-database/23/jsnvu/overview-json-relational-duality-views.html)

## Acknowledgements

* **Author** - Shashank Gugnani
* **Contributors** - Julian Dontcheff
* **Last Updated By/Date** - Shashank Gugnani, August 2025
