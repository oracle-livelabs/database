# Use Mongo API to interact with Oracle Database

## Introduction

With our JSON Collection created in the Oracle Database, we can use Mongo APIs to interact with the collection as if we were interacting with a Mongo Database. In this lab, we will download Mongo tools and then use a Mongo connection string -- which was configured as a part of the Oracle REST Data Service (ORDS) configuration -- to connect to the Oracle Database using Mongo Shell. From there, we can interact with Mongo tools or SQL Developer Web interchangeably to access our data.

Estimated Time: 10 minutes


### Objectives

In this lab, you will:

- Load more data through the Database API for MongoDB
- Use Mongo Shell to interact with Oracle Database

### Prerequisites

- Oracle Database 23ai, version 23.4 or above
- All previous labs successfully completed
- Mongo Shell installed on your machine


## Task 1: Interact with Oracle Database using Mongo API

1. First, you must set the URI to the Mongo API running in ORDS on your machine. Copy and paste in the username, password, and host for your database and schema user. If you are using the green button, those values will be as follows: hol23c, Welcome123, and localhost.

    ```
    $ <copy>export URI='mongodb://<user>:<password>@<host>:27017/<user>?authMechanism=PLAIN&authSource=$external&tls=true&retryWrites=false&loadBalanced=true'</copy>
    ```

    ```
    Example: <copy>export URI='mongodb://hol23c:Welcome123@localhost:27017/hol23c?authMechanism=PLAIN&authSource=$external&tls=true&retryWrites=false&loadBalanced=true'</copy>
    ```

    If you aren't using the green button environment and you have different values for those fields, you may need to escape some characters. Please click [this link](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/mongo-using-oracle-database-api-mongodb.html#ADBSA-GUID-44088366-81BF-4090-A5CF-09E56BB2ACAB) to learn how to escape characters in the URL. 

2. Before we connect to the Mongo Shell, let's populate our database using the Mongo Tools. You will use a document from Object Storage to seed the data in your **movie** collection.

    ```
    $ <copy>curl -s https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/moviestream_gold/o/movie/movies.json | mongoimport --collection movies --drop --tlsInsecure --uri $URI
    </copy>
    ```
    ![Populate the database](images/populate-mongo-db.png " ")

3. Now with the URI set and the Mongo tools installed and the data inserted, we can connect to Mongo Shell. Run the command below to connect.

    ```
    $ <copy>mongosh  --tlsAllowInvalidCertificates $URI</copy>
    ```
    ![Connect to the Mongo Shell](images/mongo-shell.png " ")

4. Within the Mongo Shell, you can begin running commands to interact with the data in your database as if you were using a Mongo Database. To show the **movie** collection we created and the count of documents we imported, run the following commands.

    ```
    hol23c> <copy>show collections</copy>
    hol23c> <copy>db.movies.countDocuments()
    </copy>
    ```
    ![Query result for count](images/mongo-count.png " ")

5. You can also query for specific documents. Run this query to find the document with title "Zootopia."

    ```
    hol23c> <copy>db.movies.find( {"title": "Zootopia"} )
    </copy>
    ```
    ![Query result for Zootopia](images/mongo-zootopia.png " ")

6. Now query for all movies made after 2020.

    ```
    hol23c> <copy>db.movies.find ( { "year": {"$gt": 2020} } )
    </copy>
    ```
    ![Query result for after 2020](images/mongo-2020.png " ")

    There's only one movie in our library that was released after 2020.

## Task 2: Interact interchangeably with Mongo API and SQL Developer Web

Let's take some time to demonstrate the interactivity between the Oracle and Mongo tools we have installed on our machine to see the different APIs working against the same data set.

1. Use the Mongo Shell to insert 2 documents to our movie collection.

    ```
    hol23c> <copy>db.movies.insertMany( [{
    "title": "Love Everywhere",
    "summary": "Plucky Brit falls in love with American actress",
    "year": 2023,
    "genre": "Romance"
    }
    ,
    {
    "title": "SuperAction Mars",
    "summary": "A modern day action thriller",
    "year": 2023,
    "genre": [
        "Action",
        "Sci-Fi"
    ],
    "cast": [
        "Arnold Schwarzenegger",
        "Tom Cruise"
    ]
    } ])
    </copy>
    ```
    ![Mongo inserts two docs](images/mongo-insert.png " ")

2. Now check for movies again that were released after 2020 and you will see these two movies popping up as well:

    ```
    hol23c> <copy>db.movies.find ( { "year": {"$gt": 2020} } )
    </copy>
    ```
    ![New result for after 2020](images/mongo-2020-new.png " ")

3. Oops. We made a mistake with SuperAction Mars, it has the wrong year. Let's quickly update what we just entered. 

    In mongosh, look at the movie again. This also helps us to ensure that we can use the filter to update exactly one document.

    ```
    <copy>db.movies.find({ "title": "SuperAction Mars" })
    </copy>
    ```

    ![Find SuperAction Mars in Mongo](images/mongo-find-superaction-mars.png " ")

    Ok, we are ready to update the single movie. (In real applications you would probably use "_id", the unique identifier of the document)

    ```
    <copy>db.movies.updateOne({ "title": "SuperAction Mars" },{$set: {"year": 2025}})
    </copy>
    ```
    Done. You can see that we had one matched document that we updated.

    ![Update SuperAction Mars in Mongo](images/mongo-update-superaction-mars.png " ")


4. Let's go back to the JSON IDE in Database Actions and see that we really updated the document in the Oracle database. When you have selected the collection **movies**, which is most likely the only one you are having, use the following filter to look at SuperAction Mars 

    ```
    <copy>{ "title": "SuperAction Mars" }
    </copy>
    ```

    Indeed, the record was properly updated. 

	![New result for after 2020 edit](./images/json-ide-find-superaction-mars-after-update.png)

You can proceed to the next module.

## Learn More

* [Oracle Database API for MongoDB](https://blogs.oracle.com/database/post/mongodb-api)

## Acknowledgements

* **Author** - William Masdon, Kaylien Phan, Hermann Baer
* **Contributors** -  David Start, Ranjan Priyadarshi
* **Last Updated By/Date** - Carmen Berdant, Technical Program Manager, August 2024