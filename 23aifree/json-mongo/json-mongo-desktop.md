# Use Mongo API to interact with Oracle Database

## Introduction

With our JSON Collection created in the Oracle Database, we can use Mongo APIs to interact with the collection as if we were interacting with a Mongo Database. In this lab, we will download Mongo tools and then use a Mongo connection string -- which was configured as a part of the Oracle REST Data Service (ORDS) configuration -- to connect to the Oracle Database using Mongo Shell. From there, we can interact with Mongo tools or SQL Developer Web interchangeably to access our data.

Estimated Time: 10 minutes
 
Watch the video below for a quick walk through of the lab.
[Watch the video](videohub:1_pypv5ivy)

### Objectives

In this lab, you will:

- Install Mongo Shell and Mongo Database Tools
- Load more data through the Database API for MongoDB
- Use Mongo Shell to interact with Oracle Database

### Prerequisites

- Oracle Database 23ai Free Developer Release
- All previous labs successfully completed


## Task 1: Download Mongo Shell and Mongo Database Tools

This lab has you download software from the YUM repo at repo.mongodb.org. This software is free. If you agree to their terms of use please continue on with this portion of the lab.

1. Open your terminal window.

    _If you closed your terminal window from the previous labs, please see steps in Lab 1 to reconnect to the host._

    Run the following commands to download and install Mongo Shell and Mongo Database Tools.

    ```
    $ <copy>echo '65.8.161.52 downloads.mongodb.com' | sudo tee -a /etc/hosts</copy>
    $ <copy>echo '18.65.185.55 repo.mongodb.org' | sudo tee -a /etc/hosts</copy> 
    $ <copy>sudo dnf install -y https://repo.mongodb.org/yum/redhat/8/mongodb-org/6.0/x86_64/RPMS/mongodb-mongosh-1.8.0.x86_64.rpm</copy>
    $ <copy>sudo dnf install -y https://repo.mongodb.org/yum/redhat/8/mongodb-org/6.0/x86_64/RPMS/mongodb-database-tools-100.7.0.x86_64.rpm</copy>
    ```
    Your screen will look similar to this after running the commands.
 	![End of mongo install](./images/mongo-install.png)

## Task 2: Interact with Oracle Database using Mongo API

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

5. Now query for all movies made after 2020.

    ```
    hol23c> <copy>db.movies.find ( { "year": {"$gt": 2020} } )
    </copy>
    ```
    ![Query result for after 2020](images/mongo-2020.png " ")

    There's only one movie in our library that was released after 2020.

## Task 3: Interact interchangeably with Mongo API and SQL Developer Web

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

3. Return to the browser window that contains SQL Developer Web. We will query for the same movies using the JSON tool. Navigate to the JSON tool using the menu in the top left corner of the webpage if you are not there already.
	![Homepage Development JSON](./images/development-json.png)

4. Let's edit the entries in SQL Developer Web and see the changes in Mongo Shell. First, double click on the document referencing the movie "SuperAction Mars," or click the "Edit Document" icon next to it. In the dialog page, change the year to 2025 and then save the document. Seems Tom Cruise is busy and won't have enough time to finish the movie before then.

    ```
    <copy>{ "title": "SuperAction Mars" }
    </copy>
    ```

	![Find SuperAction Mars](./images/find-superaction-mars.png)
	![Edit SuperAction Mars](./images/edit-superaction-mars.png)

5. Finally, return the to Terminal window and using the Mongo Shell instance running, query for movies released after 2020 again. You will see the updated information for the "SuperAction Mars" movie.

    ```
    hol23c> <copy>db.movies.find ( { "year": {"$gt": 2020} } )
    </copy>
    ```
	![New result for after 2020 edit](./images/mongo-2020-edited.png)

## Learn More

* [Oracle Database API for MongoDB](https://blogs.oracle.com/database/post/mongodb-api)

## Acknowledgements

* **Author** - William Masdon, Kaylien Phan, Hermann Baer
* **Contributors** -  David Start, Ranjan Priyadarshi
* **Last Updated By/Date** - William Masdon, Database Product Manager, April 2023