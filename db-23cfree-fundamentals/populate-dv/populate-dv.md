# Populate Duality Views with REST

## Introduction

This lab focuses on populating the duality views -- and therefore the underlying tables -- with POST calls. You will use REST calls to upload data into your database with the json documents you downloaded in the previous lab. 

Note that while you are POST directly to a duality view, nothing is actually stored within the view. All of the inserted data will be stored on the tables that make up the view. 

Estimated Time: 5 minutes


### Objectives

In this lab, you will:

- Insert a single document to team\_dv
- Bulk insert documents on team\_dv and race\_dv

### Prerequisites

This lab assumes you have:
- Downloaded the files from the previous lab
- Created the tables and duality views from the previous lab


## Task 1: Insert a single document


1. View the `teamMercedes.json` file to see the document we will be inserting. 

    ```
    $ <copy>cd /home/oracle/json-ords</copy>
    $ <copy>cat teamMercedes.json</copy>
    ```

    Notice that this document contains one JSON object, referring to team Mercedes. However, it also contains two entries for driver, George and Lewis. When you POST this document to the database, you will be inserting one entry into the duality view `team_dv` but it will translate the three entries on the underlying tables: 1 entry into the team table and 2 entries into the driver table. 

2. Using the `teamMercedes.json` file, we will insert a document into the duality view `team_dv`. 

    ```
    $ <copy>curl -i -X POST --data-binary @teamMercedes.json -H "Content-Type: application/json" http://localhost:8080/ords/janus/soda/latest/team_dv</copy>
    ```

2. Examine the response you received from the database. You will see the Oracle Database generated two fields: a document-key (aka ID) and an eTag. 

    The ID is a unique reference to that document in the duality view - computed automatically by the database as a hex representation of the underlying table's primary key. The eTag is a unqiue idenitifer for that version of the document used for optimistic locking. If you were to change the data in that document, the eTag would change to signify a newer version of the document. 

## Task 2: Bulk insert

1. You can also insert multiple documents into a duality view with one call. View the `team.json` file to see what we will insert. The file contains an array of 2 JSON objects, each one representing a different team document. 

    ```
    $ <copy>cat team.json</copy>
    ```

2. Using the `team.json` file, we will bulk insert into the duality view `team_dv`. 

    **Note:** The URL is different for this call. Instead of pathing to `team_dv`, you refer to the `custom-actions/insert/team_dv` path. Custom action insert on a POST request causes the array to be inserted as a set of documents, rather than as a single document. You can alternatively use the equivalent url http://localhost:8080/ords/janus/soda/latest/team_dv?action=insert

    ```
    $ <copy>curl -i -X POST --data-binary @team.json -H "Content-Type: application/json" http://localhost:8080/ords/janus/soda/latest/custom-actions/insert/team_dv</copy>
    ```

    A successful POST bulk insert operation returns a response code 200. The response body is a JSON document containing an ID and eTag for each inserted document. 

3. Bulk load data into `race_dv` using the `race.json` file. 

    ```
    $ <copy>curl -i -X POST --data-binary @race.json -H "Content-Type: application/json" http://localhost:8080/ords/janus/soda/latest/custom-actions/insert/race_dv</copy>
    ```

You may **proceed to the next lab.**

## Learn More

- [JSON Relational Duality Blog](https://blogs.oracle.com/database/post/json-relational-duality-app-dev)
- [23c Beta Docs - TO BE CHANGED](https://docs-stage.oracle.com/en/database/oracle/oracle-database/23/index.html)

## Acknowledgements

- **Author**- William Masdon, Product Manager, Database 
- **Last Updated By/Date** - William Masdon, Product Manager, Database, March 2023
