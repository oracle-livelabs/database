# Work with JSON collections

## Introduction

With our JSON Collection created in the Oracle Database, we can use Mongo APIs to interact with the collection as if we were interacting with a Mongo Database. In this lab, we will download Mongo tools and then use a Mongo connection string -- which was configured as a part of the Oracle REST Data Service (ORDS) configuation -- to connect to the Oracle Database using Mongo Shell. From there, we can interact with Mongo tools or SQL Developer Web interchangeably to access our data. 

Estimated Time: 10 minutes


### Objectives

In this lab, you will:

- Install Mongo Shell and Mongo Database Tools
- Load more data through the Database API for MongoDB
- Use Mongo Shell to interact with Oracle Database

### Prerequisites

- Oracle Database 23c Free Developer Release
- All previous labs successfully completed


## Task 1: Download Mongo Shell and Mongo Database Tools

PUT IN DISCLAIMER ABOUT DOWNLOADED MONGO TOOLS

1. Open a new terminal window.
	![Open new terminal](./images/new-terminal.png)

    Run the following commands to download and install Mongo Shell and Mongo Database Tools.

    ```
    $ <copy>echo "18.67.17.0 repo.mongodb.org" | sudo tee -a /etc/hosts</copy>
    $ <copy>sudo yum install -y https://repo.mongodb.org/yum/redhat/8/mongodb-org/6.0/x86_64/RPMS/mongodb-mongosh-1.8.0.x86_64.rpm</copy>
    $ <copy>sudo yum install -y https://repo.mongodb.org/yum/redhat/8/mongodb-org/6.0/x86_64/RPMS/mongodb-database-tools-100.7.0.x86_64.rpm</copy>
    ```
    Your screen will look similar to this after running the commands.
 	![End of mongo install](./images/mongo-install.png)

## Task 2: Interact with Oracle Database using Mongo API

1. First, you must set the URI to the Mongo API running in ORDS on your machine. Copy and paste in the username, password, and host for your database and schema user. If you are using the green button, those values will be as follows: hol23c, welcome123, and localhost.

    ```
    $ <copy>export URI='mongodb://<user>:<password>@<host>:27017/<user>?authMechanism=PLAIN&authSource=$external&tls=true&retryWrites=false&loadBalanced=true'</copy>
    ```

    ```
    Example URI: <copy>'mongodb://hol23c:welcome123@localhost:27017/hol23c?authMechanism=PLAIN&authSource=$external&tls=true&retryWrites=false&loadBalanced=true'</copy>
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

* **Author** - William Masdon, Kaylien Phan, Hermann Baer
* **Contributors** -  David Start, Ranjan Priyadarshi
* **Last Updated By/Date** - William Masdon, Database Product Manager, April 2023