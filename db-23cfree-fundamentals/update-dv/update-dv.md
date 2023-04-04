# Update Duality Views with REST

## Introduction

In this lab you will update the data you have already inserted via duality views. You will update with a document key, merge patch, and QBE. You will also remap 2 drivers to different teams and attempt to update a non-updatable field

Estimated Time: 10 minutes


### Objectives

In this lab, you will:

- Replace a document identified by document key
- Update specific fields in a document using merge patch and QBE
- Re-parent sub-objects between documents
- Attempt to update a non-updatable field

### Prerequisites

This lab assumes you have:
- Populated the data from the previous lab


## Task 1: Replace a document identified by document key


1. First you must determine the document key, aka ID, and eTag of the document to replace. If you did not write these down in the previous lab, run this command to get them again. 

    ```
    $ <copy>curl -X POST --data-binary @QBE1.json -H "Content-Type: application/json" http://localhost:8080/ords/janus/soda/latest/custom-actions/query/race_dv | json_pp</copy>
    ```

2. You need to modify the `updateRace.json` file to include the right eTag. Open the file and insert the current eTag value. Make sure to save before closing. 

    ```
    $ <copy>gedit updateRace.json</copy>
    ```

4. Now that the eTag is accurate, replace the target document with the contents in the file `updateRace.json`. 

    ```
    $ <copy>curl -i -X PUT --data-binary @updateRace.json -H "Content-Type: application/json" http://localhost:8080/ords/janus/soda/latest/race_dv/<INSERT ID HERE></copy>
    ```

5. The command returns HTTP error code 200, indicating a successful replace. 

    The update eTag appears in the response header as well. Note that the “_etag” value supplied in the content is used for “out of the box” optimistic locking, to prevent the well-known “lost update” problem that can occur with concurrent operations. During the replace by ID operation, the database checks that the eTag provided in the replacement document matches the latest eTag of the target duality view document. If the eTags do not match, which can occur if another concurrent operation updated the same document, an error is thrown. In case of such an error, you can reread the updated value (including the updated eTag), and retry the replace operation again, adjusting it (if desired) based on the updated value.

6. To verify that a replace using an eTag that is not the most recent fails, run the same command again. 

    ```
    $ <copy>curl -i -X POST --data-binary @updateRace.json -H "Content-Type: application/json" http://localhost:8080/ords/janus/soda/latest/race_dv/<INSERT ID HERE></copy>
    ```

    Because updateRace.json content has an "_etag" field value that has been obsoleted by the preceding successful replace, the command now outputs 400 (bad request). 


## Task 2: Update specific fields using merge patch

1. This operation uses `patch.json` with the following content: 

    ```
    {"name":"Blue Air Bahrain"}
    ```

    This patch document specifies that the “name” field should be set the “Blue Air Bahrain Grand Prix” in the target document. Although this patch document only specifies a single field value to change, in general the patch document can set, reset, or delete any number of fields in the target document.

2. Use the PATCH verb with "application/merge-patch+json" as the content type and the ID of the target document to update the entry. You should use the same ID from the last task.

    ```
    $ <copy>curl -i -X PATCH --data-binary @patch.json -H "Content-Type: application/merge-patch+json" http://localhost:8080/ords/janus/soda/latest/race_dv/<INSERT ID HERE></copy>
    ```

3. You can confirm the update with a fetch.

    ```
    $ <copy>curl -X GET -H "Content-Type: application/json" http://localhost:8080/ords/janus/soda/latest/race_dv/<INSERT ID HERE> | json_pp</copy>
    ```

## Task 3: Update specific fields using QBE

JSON merge patch can also be applied to one or more documents identified by a QBE.

1. This operation uses `patchWithQBE.json` with the following content: 

    ```
    {"$query" : {"raceId" : 201},
     "$merge" : {"name" : "Blue Air Bahrain Grand Prix"}}
    ```

    The QBE that identifies the set of target documents is under the “$query” field. The JSON merge patch document is under “$merge” field. In this example, the QBE only matches a single target document with “raceId” equal to 201. But in general, the QBE can match any number of documents. And, once again, the JSON merge patch document can set, reset, or delete any number of fields in the target documents.

2. Run this command to preform the patch:

    ```
    $ <copy>curl -i -X POST --data-binary @patchWithQBE.json -H "Content-Type: application/json" http://localhost:8080/ords/janus/soda/latest/custom-actions/update/race_dv</copy>
    ```

3. The command returns an HTML 200 indicating success and the return fields specifies 1 item has been updated. 


## Task 4: Re-parent sub-objects between two documents

In this task, you will switch Charles Leclerc's and George Russell's teams by updating the driver arrays in the Mercedes and Ferrari documents of the team_dv duality view. 

1. First you must find the IDs of each document. We will use QBE2.json with the following content: 

    ```
    {"name" : {"$in" : ["Mercedes", "Ferrari"]}}
    ```

2. Query the team_dv to find the documents' IDs. Then copy them down for each document.

    ```
    $ <copy>curl -X POST --data-binary @QBE2.json -H "Content-Type: application/json" http://localhost:8080/ords/janus/soda/latest/custom-actions/query/team_dv | json_pp</copy>
    ```

3. Now you must update the ID for the Mercedes team in the file `updateMercedes.json`. 

    ```
    $ <copy>gedit updateMercedes.json</copy>
    ```

5. Using the same step above, you must update the ID for the Ferrari team in the file `updateFerrari.json`. 

    ```
    $ <copy>gedit updateFerrari.json</copy>
    ```

    **NOTE:** You are not using eTags during this update. You could use eTags; however, after the first update call to change the Mercedes team, you would need to query again and get the eTag in order to update the Ferrari team, as its eTag has changed (one of its drivers has been removed). 

6. Run this command to update the Mercedes team, using the corresponding document ID: 

    ```
    $ <copy>curl -i -X PUT --data-binary @updateMercedes.json -H "Content-Type: application/json" http://localhost:8080/ords/janus/soda/latest/team_dv/<INSERT MERCEDES ID></copy>
    ```

7. Now do the same for the Ferrari team: 

    ```
    $ <copy>curl -i -X PUT --data-binary @updateFerrari.json -H "Content-Type: application/json" http://localhost:8080/ords/janus/soda/latest/team_dv/<INSERT FERRARI ID></copy>
    ```

8. To show the changes to Ferrari and Mercedes teams, query the team_dv duality view. 

    ```
    $ <copy>curl -X POST --data-binary @QBE2.json -H "Content-Type: application/json" http://localhost:8080/ords/janus/soda/latest/custom-actions/query/team_dv | json_pp</copy>
    ```

9. To see the changes in the drivers duality view as well, you can use file `QBE3.sql` which contains the following: 

    ```
    {"$or" : [{"name" : {"$like" : "George%"}}, {"name" : {"$like" : "Charles%"}}]}
    ```

    To see the changes, run: 

    ```
    $ <copy>curl -X POST --data-binary @QBE3.json -H "Content-Type: application/json" http://localhost:8080/ords/janus/soda/latest/custom-actions/query/driver_dv | json_pp</copy>
    ```

## Task 5: Update a non-updatable field

From the previous command, ID of the Charles Leclerc document in the driver duality view is FB03C2020400. The "team" field is non-updatable because the team table is marked with NOUPDATE annotation in the team_dv duality view definition.

1. Using `updateLeclerc.json`, you will attempt to set the team of Leclerc back to Ferrari. 

    ```
    $ <copy>curl -i -X PUT --data-binary @updateLeclerc.json -H "Content-Type: application/json" http://localhost:8080/ords/janus/soda/latest/driver_dv/<INSERT LECLERC ID></copy>
    ```

2. Because the team is not updatable through the driver_dv view, the command outputs a failure with HTTP 400. 



## Learn More

- [JSON Relational Duality Blog](https://blogs.oracle.com/database/post/json-relational-duality-app-dev)
- [23c Beta Docs - TO BE CHANGED](https://docs-stage.oracle.com/en/database/oracle/oracle-database/23/index.html)
- [Overview of SODA Filter Specifications](https://docs.oracle.com/en/database/oracle/simple-oracle-document-access/adsdi/overview-soda-filter-specifications-qbes.html)

## Acknowledgements

- **Author**- William Masdon, Product Manager, Database 
- **Last Updated By/Date** - William Masdon, Product Manager, Database, March 2023
