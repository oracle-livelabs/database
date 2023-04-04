# Query Duality Views with REST

## Introduction

Now that our tables been populated, we will view the data as JSON documents with GET calls and query-by-example (QBE) calls. The duality view `team_dv` joins the team table with the driver table, so the insert from the previous lab ensured data was populated on both tables. Now you can query the `driver_dv` duality view to see the data in its documents.

Estimated Time: 5 minutes


### Objectives

In this lab, you will:

- Use a GET call to view the driver_dv duality view
- Use a GET call to query a specific document
- Use QBE to view a single document from the race_dv duality view

### Prerequisites

This lab assumes you have:
- Populated the data from the previous lab


## Task 1: Use a GET call to query a duality view


Throughout this lab and the ones that follow, you will see the use of ` | json_pp` at the end of some cURL commands. This is simply a tool to help you better visualize the data that is returned. In some cases, this tool isn't used so that you may see the HTTP Codes that come in response to our cURL commands. When experimenting, you can use ` | json_pp` to better visualize the data, but note that it will not work when the returned values don't adhere to JSON syntax (such as when you use the `-i` parameter in cURL). 

1. View the contents of the `driver_dv` duality view. 

    ```
    $ <copy>curl -X GET -H "Content-Type: application/json" http://localhost:8080/ords/janus/soda/latest/driver_dv</copy>
    ```

    Documents corresponding to six drivers now appear in the driver_dv duality view. For each document, the following fields are included in the result: 
    - id - Document key, aka ID. The value is a hex representation of a unique encoded value automatically computed by the duality view, based on the primary key of the underlying duality view root table.
    - etag - Document eTag. Used for optimistic locking. Automatically computed by the duality view.
    - value - Document content. For duality views (unlike other SODA collections based on tables and regular views), the content also includes _id and _etag. That info is the same as in the "id" and "etag" field described immediately above.

    **Note:** The "race" field under each driver is empty. This is because no information connecting the driver to the races has been entered yet. That information will be added in the next lab. 

## Task 2: Use a GET call to query a specific document

1. To view only one document from a duality view, simply append the document's ID to the end of your GET call URL. 

    ```
    $ <copy>curl -X GET -H "Content-Type: application/json" http://localhost:8080/ords/janus/soda/latest/driver_dv/FB03C2020300 | json_pp</copy>
    ```

    This call has hardcoded the document ID for Sergio Perez, but you can exchange the ID with another driver to GET their information. 

## Task 3: Find a document matching a QBE filter

Documents can be fetched by supplying a QBE. Only documents matching the QBE will be returned. 

1. This operation uses QBE1.json with the following content: 

    ```
    {"raceId" : 201}
    ```

2. Fetch the documents that match this filter.

    ```
    $ <copy>curl -X POST --data-binary @QBE1.json -H "Content-Type: application/json" http://localhost:8080/ords/janus/soda/latest/custom-actions/query/race_dv | json_pp</copy>
    ```

    Write down the ID and etag of this response. You will need it in the next lab. 

3. You can alternatively use the equivalent URL.

    ```
    $ <copy>curl -X POST --data-binary @QBE1.json -H "Content-Type: application/json" http://localhost:8080/ords/janus/soda/latest/race_dv?action=query | json_pp</copy>
    ```


You may **proceed to the next lab.**

## Learn More

- [JSON Relational Duality Blog](https://blogs.oracle.com/database/post/json-relational-duality-app-dev)
- [23c Beta Docs - TO BE CHANGED](https://docs-stage.oracle.com/en/database/oracle/oracle-database/23/index.html)
- [Overview of SODA Filter Specifications](https://docs.oracle.com/en/database/oracle/simple-oracle-document-access/adsdi/overview-soda-filter-specifications-qbes.html)

## Acknowledgements

- **Author**- William Masdon, Product Manager, Database 
- **Last Updated By/Date** - William Masdon, Product Manager, Database, March 2023
