# The Extreme Flexibility of JSON Duality Views

## Introduction

This lab walks you through the steps to work with SQL data and JSON documents in the Oracle 23c database. This is looking at the true duality of the views. 

Regardless of which one you choose to work with, the underlying result in the database is the same, with SQL access and JSON document access to all data. Developers now get the flexibility and data access benefits of the JSON document model as well as the storage efficiency and power of the relational model.

Estimated Time: 5 minutes

### Objectives

In this lab, you will:
* Insert, update, and delete on the Duality Views and SQL base tables

### Prerequisites (Optional)

This lab assumes you have:
* An Oracle account
* A noVNC instance with 23c and SQL Developer installed
* All previous labs successfully completed


## Task 1: Inserting into SQL tables and duality views
1. We mentioned how the underlying base tables get populated when you add an entry into the JSON duality view. Let's see it in action.

    ```
    <copy>
    INSERT INTO race_dv VALUES ('{"raceId" : 204,
                                "name"   : "Miami Grand Prix",
                                "laps"   : 57,
                                "date"   : "2022-05-08T00:00:00",
                                "podium" : {}}');
    </copy>
    ```

    In the last lab, you saw how the duality view was populated, but here we will select from the underlying base SQL table for races.
    ```
    <copy>
    SELECT * FROM race;
    </copy>
    ```

2. Now, let's also see the instant population of the JSON table when we insert something into the underlying base table.
    ```
    <copy>
    INSERT INTO race 
    VALUES(205, 'Japanese Grand Prix', 53, TO_DATE('2022-10-08','YYYY-MM-DD'), '{}');
    </copy>
    ```

    Though this insert was into the race table, when you select from race\_dv again, you can see the duality view is also populated.

    ```
    <copy>
    SELECT json_serialize(data PRETTY)
    FROM race_dv WHERE json_value(data, '$.raceId') = 205;
    </copy>
    ```



## Task 2: Update and replace a document by ID

1. In the last lab, you were able to replace a document with the OBJECT\_ID through the duality view. You are able to get the same functionality with the SQL table.

    ```
    <copy>

    UPDATE race
    SET name = 'Miami Grand Prix',

    podium = '{"winner":{"name":"Charles Leclerc","time":"01:37:33.584"},
    "firstRunnerUp":{"name":"Carlos Sainz Jr","time":"01:37:39.182"},
    "secondRunnerUp":{"name":"Lewis Hamilton","time":"01:37:43.259"}}'
    WHERE race_id = 204;

    INSERT INTO driver_race_map
    VALUES(3, 201, 103, 1);

    INSERT INTO driver_race_map
    VALUES(4, 201, 104, 2);

    INSERT INTO driver_race_map
    VALUES(9, 201, 106, 3);

    INSERT INTO driver_race_map
    VALUES(10, 201, 105, 4);

    COMMIT;

    </copy>
    ```

    And you can see the JSON output again.

    ```
    <copy>
    SELECT json_serialize(data PRETTY)
    FROM race_dv WHERE json_value(data, '$.raceId') = 204;
    </copy>
    ```

    <!-- ```
    <copy>
    SELECT * FROM race where race_id = 204;
    </copy>
    ``` -->
<!-- need to make sure the data is updated for this one -->

2. When you update the JSON, you can check out the changes in the SQL table as well.

    ```
    <copy>
    UPDATE race_dv
      SET data = ('{_metadata : {"etag" : "2E8DC09543DD25DC7D588FB9734D962B"},
                    "raceId" : 205,
                    "name"   : "Japanese Grand Prix",
                    "laps"   : 57,
                    "date"   : "2022-03-20T00:00:00",
                    "podium" :
                      {"winner"         : {"name" : "Max Verstappen",
                                           "time" : "03:01:44.004"},
                       "firstRunnerUp"  : {"name" : "Sergio Perez",
                                           "time" : "03:02:11.070"},
                       "secondRunnerUp" : {"name" : "Charles Leclerc",
                                           "time" : "03:02:15.767"}},
                    "result" : [ {"driverRaceMapId" : 3,
                                  "position"        : 1,
                                  "driverId"        : 103,
                                  "name"            : "Max Verstappen"},
                                 {"driverRaceMapId" : 4,
                                  "position"        : 2,
                                  "driverId"        : 104,
                                  "name"            : "Sergio Perez"},
                                 {"driverRaceMapId" : 9,
                                  "position"        : 3,
                                  "driverId"        : 106,
                                  "name"            : "Charles Leclerc"}')
        WHERE OBJECT_ID = 'FB03C2030200';

    COMMIT;
    </copy>
    ```

    ```
    <copy>
    SELECT * FROM race where race_id = 205;
    </copy>
    ```




## Task 3: Delete by predicate

1. We're going to delete a couple entries, but we want to see the current state of these tables first.


    ```
    <copy>
    SELECT json_serialize(data PRETTY) FROM race_dv;
    SELECT json_serialize(data PRETTY) FROM driver_dv;

    SELECT * FROM race;
    SELECT * FROM driver;
    </copy>
    ```

    Delete the race document for Japanese GP. The underlying rows are deleted from the race and driver\_race\_map tables. 
    
    Note that we have to delete the rows of the race from the driver\_race\_map first, as they are foreign child entries of the race entries in the race table. It will throw an error if you try to run the second command first.

    ```
    <copy>
   
    DELETE FROM driver_race_map where race_id = 204;
    DELETE FROM race where race_id = 204;

    COMMIT;
    </copy>
    ```

    Select from the tables again and you'll see they're gone from the duality view as well as the base SQL table.


    ```
    <copy>
    SELECT json_serialize(data PRETTY) FROM race_dv;
    SELECT json_serialize(data PRETTY) FROM driver_dv;

    SELECT * FROM race;
    SELECT * FROM driver;
    </copy>
    ```

2. Lastly, we'll delete with JSON and view the tables again.


    ```
    <copy>
    DELETE FROM race_dv dv WHERE dv.data.raceId = 205;

    SELECT json_serialize(data PRETTY) FROM race_dv;
    SELECT json_serialize(data PRETTY) FROM driver_dv;

    COMMIT;

    </copy>
    ```
    

## Learn More

* [JSON Relational Duality: The Revolutionary Convergence of Document, Object, and Relational Models](https://blogs.oracle.com/database/post/json-relational-duality-app-dev)
* [JSON Duality View documentation](http://docs.oracle.com)


## Acknowledgements
* **Author** - Kaylien Phan, Product Manager, Database Product Management
* **Last Updated By/Date** - Kaylien Phan, Database Product Management, March 2023
