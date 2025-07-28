# Work with your Mongo collections interchangeably through Mongo APIs and Oracle JSON and SQL

## Introduction

This lab will use JSON and SQL in Database Actions. It shows how we can swap between a document-centric model (MongoDB and Oracle's JSON tool in Database Actions), and a relational model using Oracle's SQL tool in Database Actions. We will also have a closer look into how MongoDB collections are stored in Oracle Database, using Oracle's native JSON datatype which is stored in Oracle's binary JSON format, OSON.

Estimated Time: 20 minutes

Watch the video below for a quick walk through of the workshop.
[Watch the video](videohub:1_swkxobmu)

### Objectives

In this lab, you will:

* Use Mongo and Oracle tools interchangeably
* Experience some of the new MongoDB API capabilities with Oracle Database 23ai

### Prerequisites

* Oracle Database 23ai Free Developer Release
* ORDS started with MongoDB API enabled
* Password of database user hol23c known

## Task 1: Interact interchangeably with Mongo API and SQL Worksheet

_If you closed your terminal window from the previous labs, you need to re-open a terminal window and restart ORDS. Please see Lab 1 for instructions_

Let's take some time to demonstrate the interactivity between the Oracle and Mongo tools we have installed on our machine.

1. Use the Mongo Shell in your terminal to insert 2 documents to our movie collection (if you do not remember how to connect, then check out Lab 2, Task 2 again).

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

3. Open a browser window to access SQL Worksheet in Database Actions.

	```
    <copy>http://localhost:8080/ords/hol23c/_sdw</copy>
    ```

	![Open Browser](./images/open-browser.png)

4. Sign in with the username and password our workshop user hol23c. Replace the `<new_password>` with the one you entered in Lab 1: Setup User.

    ```
    username: hol23c
    password: <new_password>
    ```

	![User Sign In](./images/ords-sign-in.png)

5. We will query for the same movies using the JSON tool. Navigate to the JSON tool using the menu in the top left corner of the webpage if you are not there already. This interface is using Oracle SODA (Simple Oracle Document Access) to modify the collections within Oracle. Using SODA is an alternative to using MongoDB APIs to work with your collections. You can work with these two document store interfaces interchangeably against the same collections without impacting the data or any application using these interfaces.

	![Homepage Development JSON](./images/homepage-json.png)

6. Let's edit one of the newly added movies in SQL Worksheet and see the changes in Mongo Shell. 

    Select our newly added movie **SuperAction Mars** and change the planned release year. Seems Arnold Schwarzenegger is busy with Fubar, so he won't have time for it before 2025. You can do this using the QBE capabilities of the JSON UI. Copy the following into the QBE window:
    ```
    <copy>
    {"title": "SuperAction Mars"}
    </copy>
    ```
    Now let's change the collection:
    - First, double click on the document referencing the movie "SuperAction Mars," or click the "Edit Document" icon next to it. 
    - In the dialog page, change the year to 2025 and then save the document in the Oracle Database.

	![Find SuperAction Mars](./images/find-superaction-mars.png)
	![Edit SuperAction Mars](./images/edit-superaction-mars.png)

7. Return to your terminal window and query for movies released after 2020 again using the Mongo Shell. You will see the updated information for the "SuperAction Mars" movie. 

    ```
    hol23c> <copy>db.movies.find ( { "year": {"$gt": 2020} } )
    </copy>
    ```
	![New result for after 2020 edit](./images/mongo-2020-edited.png)

The data is stored in a **single** location - the Oracle database - and transactionally protected with Oracle's read consistency. You will never see uncommitted data or have to rely on any write concern setting or which replica you are working again. Forget about settings like "write concern", you will always be consistent and ACID compliant.

## Task 2: Use Mongo Compass to build an aggregation pipeline

With Oracle MongoDB API in the newest ORDS and Oracle Database 23ai, the compatibility of Oracle MongoDB API and MongoDB have significantly increased. The most notable enhancement is the support for Aggregation Pipelines. 

The following lab will focus on aggregation pipelines, illustrate its functionality and give a view under the hood of how you use the power of Oracle's database JSON processing capabilities to speed up MongoDB requests.

1. Let's install Mongo Compass to use Mongo's UI for creating an aggregation pipeline. This step is optional, you can decide to do the following exercises in Mongo Shell. While the workshop will focus on Compass, it will provide the code for command line as well.

    Execute the following commands in a terminal window if you want to install Mongo Compass:

    ```
    <copy>echo "65.8.49.92 downloads.mongodb.com" | sudo tee -a /etc/hosts
    wget https://downloads.mongodb.com/compass/mongodb-compass-1.35.0.x86_64.rpm
    sudo yum -y install mongodb-compass-1.35.0.x86_64.rpm
    </copy>
    ```

	![Installation of Mongo Compass](./images/mongo-compass-install.png)

2. Start Mongo Compass and connect with your MongoDB connect string. 

    Just start Mongo Compass from the command line:

    ```
    $ <copy>mongodb-compass</copy>
    ```
    The connect string is in the form of the following, with your username and password, shown also with our example user hol23c and its password.
    ```
    $ mongodb://<user>:<password>@<host>:27017/<user>?authMechanism=PLAIN&authSource=$external&tls=true&retryWrites=false&loadBalanced=true</copy>
    ```
    If you are using Oracle's green button noVNC environment and have used our suggested password Welcome123, then you can simply copy the following example string:
    ```
    <copy>mongodb://hol23c:Welcome123@localhost:27017/hol23c?authMechanism=PLAIN&authSource=$external&tls=true&retryWrites=false&loadBalanced=true</copy>
    ```

	![New Connection in Mongo Compass](./images/compass-connect.png)

    Before you connect you need to enable Mongo Compass to connect without a valid, externally verified Certificate. The option is under the advanced connection options.

	![Advanced connection options in Mongo Compass](./images/compass-tls.png)

    **Note**: Note that we need to use the option to allow tls communication with invalid Certificates. This is because the ORDS setup in this lab is a simple local install without CA certificate registration. The communication is nevertheless encrypted and safe.

3. Build your first aggregation pipeline using Mongo Compass

    After successful connection, choose the "database" that stores your collection. 
    
    Choose "database" (schema) **hol23c** or the user you chose at the beginning when working with Mongo shell. Select the collection **movies** in "database" (schema) hol23c or your user.

    ![Mongo Compass - collection movies](./images/mongo-collection-movies.png)

    Go to the aggregation screen in Compass. We're now starting to build an **aggregation pipeline**. Select the green 'Add Stage' button at the bottom

    ![Mongo Compass - initial aggregation screen](./images/mongo-agg-init.png)

    - Select the **$group** expression.

        ![Mongo Compass - build first stage](./images/mongo-agg-stage1.png)

        Modify the code block for this stage either by typing what you see in the screenshot or by copying the following code block in the window below your selection of **$group**:
        ```
        <copy>
        {
            _id: "$year",
            "cnt_movies": {
                $count: {}}
        }        
        </copy>
        ```
        If you typed it correctly, you will see a sample partial output on the right side pane

        ![Mongo Compass - first stage code](./images/mongo-agg-stage1b.png)

    - We are now building our **second stage**. We want to sort our results by the number of movies released in a given year in descending order. Select the **$sort** expression.

        ![Mongo Compass - build second stage](./images/mongo-agg-stage2.png)

        Modify the code block for this stage either by typing what you see in the screenshot or by copying the following code block under the code window below the **sort** selection:
        ```
        <copy>
        { "cnt_movies"": -1 
        } 
        </copy>
        ```
        ![Mongo Compass - second stage code](./images/mongo-agg-stage2b.png)

    - Last but not least, we only want to return the top ten years. We nned to add another stage using the **$limit** expression. Please select this expression and enter the number 10 to only get the top 10:

        ![Mongo Compass - build third stage](./images/mongo-agg-stage3.png)

    - You can now run your aggregation pipeline and see the results within Mongo Compass. Press the green **'Run'** button:

        ![Mongo Compass - run aggregation](./images/mongo-agg-output.png)

4.  Oracle is mapping the aggregation pipeline stages into Oracle SQL to formulate the equivalent operation using SQL and SQL/JSON. For the example aggregation pipeline we just built we can see the execution plan by pressing the 'Explain' button and traversing down to the 'winningPlan' attribute:

    ![Mongo Compass - sql stmt](./images/mongo-agg-sql.png)

    You can also see the execution plan in this information:

    ![Mongo Compass - execution plan](./images/mongo-agg-exec-plan.png)


    While this is a rather simple SQL statement, this is the point where Oracle uses the power of its SQL engine and the Oracle Optimizer to find the most optimal execution plan for processing the request.

## Task 3: Run the aggregation pipeline in mongoshell

To run the same aggregation pipeline in mongoshell, copy the following code snippet:
```
<copy>
        db.movies.aggregate( 
            [ { $group: 
                { "_id": "$year" , 
                "cnt_movies": 
                    { $count: {} }
                }
            }, 
            { $sort: 
                { "cnt_movies": -1 } 
            }, 
            { $limit: 10}
            ]);
</copy>
    ```
![Mongoshell - agg pipeline](./images/mongosh-agg.png)

You can also see the SQL statement and execution plan in mongoshell:
```
<copy>
        db.movies.aggregate( 
            [ { $group: 
                { "_id": "$year" , 
                "cnt_movies": 
                    { $count: {} }
                }
            }, 
            { $sort: 
                { "cnt_movies": -1 } 
            }, 
            { $limit: 10}
            ]).explain();
</copy>
```
![Mongoshell - execution plan](./images/mongosh-agg-explain.png)
    
## Task 4: Using analytical SQL with your collections in two minutes

Last but not least, we are going to briefly use SQL to analyze our movies collection with SQL/JSON. While your documents are stored in native binary JSON format, the data is readily accessible via SQL/JSON.

1. Let's execute the aggregation pipeline we built in the previous exercise in SQL. Navigate to the SQL worksheet in Database Actions.
    
    ![Database Actions - SQL worksheet](./images/dbactions-menu-sql.png)

    You can now run the exact same statement using SQL. We are using the simple dot notation for this.
    ```
    <copy>
    select m.data.year, count(*) cnt_movies
    from movies m 
    group by m.data.year 
    order by count(*) desc 
    fetch first 10 rows only;
    </copy>
    ```

2. Let's do a slightly more complex SQL Analysis.

    Having transparent SQL access to the data makes it very easy to leverage the full power of SQL in addition to the full transparency of MongoDB APIs. For example, if you want to analyze the percentage of revenue the release year of a movie has on the overall revenue generated you can just use the analytic function RATIO TO REPORT.

    ```
    <copy>
    with revenue as
    (select   m.data.year, 
             round(sum(m.data.gross)/1000000) as millions
    from     movies m 
    where    m.data.gross is not null 
    group by m.data.year
    )
    select year, millions, 
            round((ratio_to_report(millions) over ())*100,2) pct_revenue
    from revenue
    order by millions desc;
    </copy>
    ```
    
    ![Database Actions - Analytical SQL](./images/dbactions-analytical-sql.png)

**Stepping into SQL for more complex analysis on top of your JSON documents is the perfect way to augment and enhance the value of your data. This, together with the compatibility with MongoDB API allows you to get more value from your data.**


There's more to cover for the Oracle Database API for MongoDB or the unified access of your collections with MongoDB API and SQL/JSON that goes beyond this introductory lab. Stay tuned for more and check out the link below to learn more.
## Learn More

* [Oracle Database API for MongoDB](https://blogs.oracle.com/database/post/mongodb-api)
* [Oracle Database API for MongoDB - Documentation](https://docs.oracle.com/en/database/oracle/mongodb-api/index.html)
* [Oracle Database API for MongoDB - YouTube](https://www.youtube.com/watch?v=EVDn4b6u628&ab_channel=Oracle)
* [SQL, JSON, and MongoDB API: Unify worlds with Oracle Database 23ai Free](https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=3635)

## Acknowledgements

- **Author** - Hermann Baer
- **Contributors** - Beda Hammerschmidt, Josh Spiegel
- **Last Updated By/Date** - Hermann Baer, May 2023
