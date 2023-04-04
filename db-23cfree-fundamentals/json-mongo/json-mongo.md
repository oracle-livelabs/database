# Work with JSON collections

## Introduction

Oracle is a relational database, meaning it typically stores data in rows and columns of tables and JSON can be stored as a column value. For this lab though, we first focus on the Document Store API SODA (Simple Oracle Document Access) which allows us to store JSON data in a so-called collection. A JSON collection stores JSON documents alongside some metadata like the time of creation or update. Collections offer operations like inserts, deletes, index creation or queries.

To create a collection all you have to specify is the collection's name. Unlike a relational table, you do not have to provide any schema information. So, let's create a collection for the products we want to sell in the store.

Estimated Time: 15 minutes


### Objectives

In this lab, you will:

* Create Collection
* Insert First Document
* Find JSON documents in a collection
* Learn about JSON and Constraints
* Load more data through the Database API for MongoDB

### Prerequisites

* Have provisioned an Autonomous JSON Database instance and logged into the JSON
* Be working with a Mac OS/X (Intel Silicon) machine, a Linux x86 machine or a Windows PC


## Task 1: Download Mongo Shell and Mongo Database Tools

PUT IN DISCLAIMER ABOUT DOWNLOADED MONGO TOOLS

1. In a terminal window, run the following commands to download and install Mongo Shell and Mongo Database Tools.  

    ```
    $ <copy>sudo yum install https://repo.mongodb.org/yum/redhat/9/mongodb-org/6.0/x86_64/RPMS/mongodb-mongosh-1.8.0.x86_64.rpm</copy>
    $ <copy>mkdir -p /home/oracle/json-mongo</copy>
    $ <copy>cd /home/oracle/json-mongo</copy>
    $ <copy>wget https://fastdl.mongodb.org/tools/db/mongodb-database-tools-rhel80-x86_64-100.7.0.rpm</copy>
    $ <copy>sudo yum install -y mongodb-database-tools-rhel80-x86_64-100.7.0.rpm</copy>
    ```


## Task 2: Interact with Oracle Database using Mongo API
    
1. First, you must set the URI to the Mongo API running in ORDS on your machine. Copy and paste in the username, password, and host for your database and schema user. If you are using the green button, those values will be as follows: jason, welcome123, and localhost. 

    ```
    $ <copy>export URI='mongodb://<user>:<password>@<host>:27017/<user>?authMechanism=PLAIN&authSource=$external&tls=true&retryWrites=false&loadBalanced=true'</copy>
    ```

    ```
    Example URI: <copy>'mongodb://jason:welcome123@localhost:27017/jason?authMechanism=PLAIN&authSource=$external&tls=true&retryWrites=false&loadBalanced=true'</copy>
    ```

2. Before we connect to the Mongo Shell, let's populate our database using the Mongo Tools. You will use a document from Object Storage to seed the data in your **movie** collection. 

    ```
    $ <copy>curl -s https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/moviestream_gold/o/movie/movies.json | mongoimport --collection movies --drop --tlsInsecure --uri $URI 
    </copy>
    ```

3. Now with the URI set and the Mongo tools installed and the data inserted, we can connect to Mongo Shell. Run the command below to connect. 

    ```
    $ <copy>mongosh  --tlsAllowInvalidCertificates $URI</copy>
    ```

4. Within the Mongo Shell, you can begin running commands to interact with the data in your database as if you were using a Mongo Database. To show the **movie** collection we created and the count of documents we imported, run the following commands. 

    ```
    jason> <copy>show collections</copy>
    jason> <copy>db.movies.countDocuments()
    </copy>
    ```

5. You can also query for specific documents. Run this query to find the document with title "Zootopia."

    ```
    jason> <copy>db.movies.find( {"title": "Zootopia"} )
    </copy>
    ```

5. Now query for all movies made after 2020.

    ```
    jason> <copy>db.movies.find ( { "year": {"$gt": 2020} } )
    </copy>
    ```


## Task 3: Interact interchangeably with Mongo API and SQL Developer Web

Let's take some time to demonstrate the interactivity between the Oracle and Mongo tools we have installed on our machine. 

1. Use the Mongo Shell to insert 2 documents to our movie collection.

    ```
    jason> <copy>db.movies.insertMany( [{
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

2. Now check for movies again that were released after 2020 and you will see these two movies popping up as well: 

    ```
    jason> <copy>db.movies.find ( { "year": {"$gt": 2020} } )
    </copy>
    ```

3. Return to the browser window that contains SQL Developer Web. We will query for the same movies using the JSON tool. Navigate to the JSON tool using the menu in the top left corner of the webpage if you are not there already. 

	![New collection notification](./images/popup.png)

4. Let's edit the entries in SQL Developer Web and see the changes in Mongo Shell. First, double click on the document referencing the movie "SuperAction Mars." In the dialog page, change the year to 2025 and then save the document. 

	![Refresh button](./images/refreshed.png)

5. Finally, return the to Terminal window and using the Mongo Shell instance running, query for movies released after 2020 again. You will see the updated information for the "SuperAction Mars" movie. 

    ```
    jason> <copy>db.movies.find ( { "year": {"$gt": 2020} } )
    </copy>
    ```


## Learn More

* [Oracle Database API for MongoDB](https://blogs.oracle.com/database/post/mongodb-api)

## Acknowledgements

- **Author**- William Masdon, Product Manager, Database 
- **Last Updated By/Date** - William Masdon, Product Manager, Database, March 2023