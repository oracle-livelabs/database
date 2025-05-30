# Work with JSON Collections and MongoDB API

## Introduction

Oracle is a relational database, meaning it typically stores data in rows and columns of tables and JSON can be stored as a column value. For this lab though, we first focus on the Document Store API SODA (Simple Oracle Document Access) which allows us to store JSON data in a so-called collection. A JSON collection stores JSON documents alongside some metadata like the time of creation or update. Collections offer operations like inserts, deletes, index creation or queries.

To create a collection all you have to specify is the collection's name. Unlike a relational table, you do not have to provide any schema information. So, let's create a collection for the products we want to sell in the store.

We'll then install MongoDB Shell and Command Line Database Tools to enable Mongo APIs. These will interact with our JSON collection. 

Estimated Time: 35 minutes

### Objectives

In this lab, you will:

* Create Collection using Database Actions|JSON
* Insert First Document using Database Actions|JSON
* Find JSON documents in a collection using Database Actions|JSON
* Learn about JSON and Constraints

Then:
* Install MongoDB Shell and MongoDB Command Line Database Tools on your local machine
* Alternatively, you can install MongoDB Compass (GUI)
* Set up your PATH to point to the MongoDB Shell and MongoDB Command Line Database Tools executable
* Load more data through the Database API for MongoDB
* Use MongoDB Shell to interact with Oracle Database

### Prerequisites

- An Oracle Autonomous Database 23ai available for the LiveLab.

## Task 1: Create Collection

1. Click in the *Database Actions* dropdown list and select **View all database actions**

	![DB Actions](images/dbaction1.png)


2. Below you can find the Database Actions homepage.

	![Homepage Database Actions](./images/homepage-dbactions.png)


3. On the homepage, click the JSON tile under Development.

	![Homepage Development JSON](./images/homepage-json.png)

4. To create a collection, click **Create Collection**.
	A tour of this section may automatically begin when the page loads. You can click `next` to continue through the tour and return to this page.

	![JSON Create Collection](./images/json-create-collection.png)

5. In the field **Collection Name**, provide the name **movies**. Then click **Create**.

	Note that the collection name is case-sensitive. You must enter products in all lower-case, don't use MOVIES or Movies.

	![New Collection: movies](./images/collection-name.png)

6. A notification pops up that displays **movies** collections has been created.

	![New collection notification](./images/popup.png)

9. Click the refresh button to verify the **movies** collection has been created.

	![Refresh button](./images/refresh-collection.png)

## Task 2: Insert Documents

1. Double click **movies** collection to show the **JSON-movies** worksheet. Click the *New JSON Document* button.

	![new document button](./images/new-json-doc.png)

3. A **New JSON Document** panel displays. Copy the following JSON object, paste it in the worksheet and click **Create**.

	```
	<copy>
	{
		"_id": 100,
		"type":"movie",
		"title": "Coming to America",
		"format": "DVD",
		"condition": "acceptable",
		"price": 5,
		"comment": "DVD in excellent condition, cover is blurred",
		"starring": ["Eddie Murphy", "Arsenio Hall", "James Earl Jones", "John Amos"],
		"year": 1988,
		"decade": "80s"
	}
	</copy>
	```

	![add new document](./images/json-object.png)

4. A notification pops up that says A New Document is created and the new document is shown in the bottom section of the JSON workshop.

	![new document confirmation popup](./images/popup-json-doc.png)

5. Let's repeat this with the following documents:

	Click the *New JSON Document* button, copy the following JSON objects one by one, paste it into the worksheet and click **Create**.

    ```
	<copy>
	{
		"_id": 101,
		"title": "The Thing",
		"type": "movie",
		"format": "DVD",
		"condition": "like new",
		"price": 9.50,
		"comment": "still sealed",
		"starring": [
			"Kurt Russel",
			"Wilford Brimley",
			"Keith David"
		],
		"year": 1982,
		"decade": "80s"
	}
	</copy>
	```

	```
	<copy>
	{
		"_id": 102,
		"title": "Aliens",
		"type": "movie",
		" format ": "VHS",
		"condition": "unknown, cassette looks ok",
		"price": 2.50,
		"starring": [
			"Sigourney Weaver",
			"Michael Bien",
			"Carrie Henn"
		],
		"year": 1986,
		"decade": "80s"
	}
	</copy>
	```


## Task 3: Find JSON documents in a collection

Documents can be selected based on filter conditions - we call them 'Queries By Example' or 'QBE' for short. A QBE is a JSON document itself and it contains the fields and filter conditions that a JSON document in the collection must satisfy, in order to be selected. QBEs are used with SODA (only); you can use SQL functions as an alternative.

The simplest form of a QBE just contains a key-value pair. Any selected document in the collection must have the same key with the same value. More complex QBEs can contain multiple filter conditions or operators like 'negation' or 'and', etc.

The following are examples of QBEs. You can copy them into the corresponding window (see screenshot) and execute them. In a real application, those QBE-expressions would be issued directly from the programming language - the SODA drivers have APIs for common application programming languages: Python, etc.

Now let's issue some simple queries on the **movies** collection we just created.

1. Copy and paste the following queries into the worksheet and click the *Run Query* button to run a query.

2.  Lookup by one value:

	Here, it displays the document whose id value is 101.

	```
	<copy>
	{"_id":101}
	</copy>
	```
	![QBE doc with id 101](./images/qbe-one-value.png)
	![QBE id 101 results](./images/qbe-one-value-result.png)

3.	Find all DVDs:

	Running the query will display two documents with format DVD.

	```
	<copy>
	{"format":"DVD"}
	</copy>
	```
	![QBE DVD results](./images/qbe-dvd-result.png)

4.	Find all non-movies:

	This query displays the documents that are not of type - movies, which is currently nothing.

	```
	<copy>
	{"type":{"$ne":"movie"}}
	</copy>
	```
	![QBE for "not movies" result](./images/qbe-not-movies-result.png)

5.	Find documents whose condition value contains "new", which means just document (with id) 101.

	```
	<copy>
	{"condition":{"$like":"%new%"}}
	</copy>
	```
	![QBE condition is new result](./images/qbe-new-result.png)

6. Find bargains of all products costing 5 and choose only DVD format documents:

	This query displays the document id 100, as this document has a price less than 5 and is the format DVD.

	```
	<copy>
	{"$and":[{"price":{"$lte":5}}, {"format":"DVD"}]}
	</copy>
	```
	![QBE price less than 5 and not type = book ](./images/qbe-lte5-dvd-result.png)

## Task 4: JSON and Constraints

JSON data is "schema flexible", you can add whatever data you like to a JSON document. But sometimes you will wish to impose some required structure on that data. That can be done through SQL by creating indexes and/or constraints on the JSON collection.

An index will aid fast access to an item (for example speeding up access via the "title" field), but can also be used to impose uniqueness (a unique index or primary key constraint) or to enforce particular datatypes (by triggering an error if the datatype is not what is expected).

More generally, constraints can be used to check the data being entered for various aspects.

1.  Let's add a check - or 'constraint' to check our data entry. We will do this using SQL Developer Web. Click the navigation menu on the top left and select **SQL** under Development.

	![SQL navigation](./images/development-sql.png)

2. We want to ensure that our JSON data satisfies minimal data quality, so we will create a constraint to enforce a couple of mandatory fields and their data types. **Enforcing a JSON schema is new functionality in Oracle Database 23ai.**

	To quickly recap what the documents look like, let's look at the first JSON document quickly. (Don't worry, we will have a closer look into the SQL world with JSON later):
	```
	<copy>
	select json_serialize(data pretty) from movies fetch first 1 rows only;
	</copy>
	```
	![Single document in SQL](./images/show-single-json-in-sql.png)

    Now copy and paste the query below in the worksheet and click the *Run query* button to run the SQL query to alter the **movie** table and add constraints.

    ```
    <copy>alter table "movies" add constraint movies_json_schema
    check (data is json validate '{   "type": "object",
        "properties": {
            "_id": { "type": "number" },
            "title": { "type": "string"},
            "type": {"type" : "string"},
            "price": {"type" : "number"},
    "starring": {
    "type": "array",
    "minItems": 0,
    "items": {
    "type": "string"
    }
    }
        },
        "required": ["_id", "title", "type", "price"]
    }'
    );</copy>
    ```
	![Create movies constraint in SQL](./images/create-movies-constraint.png)

3. Add another constraint so that the price cannot be a negative number.

	```
	<copy>
	alter table "movies" add constraint no_negative_price
    check (
            JSON_EXISTS(data, '$?(@.price.number() >= 0)')
          );
	</copy>
	```
	![add constraint](./images/sql-constraint-2.png)

	JSON_Exists is a SQL/JSON function that checks that a SQL/JSON path expression selects at least one value in the JSON data. The selected value(s) are not extracted – only their existence is checked. Here, *$?(@.price.number() >= 0)* is a standard, SQL/JSON path expressions. You'll learn more about SQJ/JSON functions later in this lab.

4. Once the **movies** table is altered, navigate back to JSON workshop. Click the navigation menu on the top left and select **JSON** under Development.

	![JSON navigation](./images/development-json.png)

5. Validate that the following documents cannot get inserted, since fields are missing or are of wrong type.

	Click the *New JSON Document* icon, copy and paste the following query in the worksheet and click *Create*.

	This throws the error "Unable to add new JSON document" since the following document has missing fields and incorrect data types.

	```
	<copy>
    {
    "_id": "upc9800432" ,
    "title": "Love Everywhere",
    "summary": "Plucky Brit falls in love with American actress",
    "year": 2023,
    "genre": "Romance",
    "starring": "tbd"
    }
	</copy>
	```
	![create a not-allowed item](./images/create-wrong-type.png)
	![constraint error message](./images/wrong-type.png)

6. The following document now satisfies all the constraints: the "id" is a unique number, "starring" is an array, it has all required fields, and the price is a positive number.

	```
	<copy>
	{
    "_id": 99999 ,
    "title": "Love Everywhere",
    "type": "movie",
    "price": 10,
    "summary": "Plucky Brit falls in love with American actress",
    "year": 2023,
    "genre": "Romance",
    "starring": ["tbd"]
    }
	</copy>
	```
	![create allowed item](./images/create-right-type.png)
	![doc successfully created](./images/json-doc-created.png)

7. Now that was quite cumbersome to figure out the mistakes manually. But there's a better way: you can ask the database for the problems with your payload. Navigating back to the SQL page, you can enter this command to see the errors with your JSON payload. **JSON schema is new functionality in Oracle Database 23ai.**

    ```
    <copy>
    with x as
    (
    SELECT DBMS_JSON_SCHEMA.validate_report(
        JSON('{ "_id": "upc9800432" ,
                "title": "Love Everywhere",
                "summary": "Plucky Brit falls in love with American actress",
                "year": 2023,
                "genre": "Romance",
                "starring" :"tbd" }'), json_schema  )
    AS REPORT
    from user_JSON_SCHEMA_COLUMNS where table_name = 'movies')
    select json_serialize(report pretty) from x
    /
    </copy>
    ```
	The output shows you all the violations in detail, so that it is easier to address the issues.

	![SQL to find JSON doc problem](./images/sql-shows-schema-error.png)

8. You may also check the JSON Schema definition in your data dictionary. **JSON schema is new functionality in Oracle Database 23ai.**
In the SQL tool, run:

    ```
    <copy>
    select constraint_name, json_serialize(json_schema) from user_JSON_SCHEMA_COLUMNS where table_name = 'movies';
    </copy>
    ```
	![SQL for data dictionary](./images/sql-data-dict.png)


	_Click on a table cell then the eye icon to view the full value._

	![SQL for data dictionary result](./images/json-schema-result.png)

## Install MongoDB Shell and MongoDB Command Line Database Tools

This section walks you through the installation of the MongoDB Shell and MongoDB Command Line Database Tools on your own machine. Instructions are provided for Mac OS X and Windows machines. Installation on a Linux machine will be similar to the Mac instructions, but obviously will require a different download file.

**NOTE**: MongoDB Shell and MongoDB Command Line Database Tools are tools provided by MongoDB Inc. Oracle is not associated with MongoDB Inc, and has no control over the software. These instructions are provided simply to help you learn about MongoDB Shell and MongoDB Command Line Database Tools. Links may change without notice.

Check the official MongoDB download website for latest versions and instructions, e.g.:

https://www.mongodb.com/try/download/shell

https://www.mongodb.com/try/download/database-tools

https://www.mongodb.com/try/download/compass

### Objectives

In this section, you will:

* Install MongoDB Shell and MongoDB Command Line Database Tools on your local machine
* Alternatively, you can install MongoDB Compass (GUI)
* Set up your PATH to point to the MongoDB Shell and MongoDB Command Line Database Tools executable

### Prerequisites

- A Mac OS X machine (Intel or Apple hardware) or a Windows PC.
- Access to the command prompt / terminal

## Task 1: (Mac only) Determine the type of hardware

1. If you know already whether your Mac uses Intel or Apple Silicon you can skip this step. Otherwise:

    Click on the Apple menu in the top left-hand corner of your screen and go to "About this Mac". 

    !["about this mac" menu item](../json-install-mongo/images/about-this-mac.png " ")

    That will open a "details" panel. Intel Mac will show a line with *Processor:* and the name of an Intel processor. Apple Silicon Macs will show a line saying *Chip* and a line such as "Apple M1 Pro".

    ![processor details](../json-install-mongo/images/about-mac-details.png " ")

## Task 2: Open a command prompt or terminal window

1. On a Mac:

    Open the Launchpad icon in the Dock (or press Command-space) and start typing "terminal" in the search box. Press enter to start terminal.

    ![open terminal in launchpad](../json-install-mongo/images/terminal.png " ")

2.  On a Windows PC:

    Press "Run" (Windows-R) and type "cmd.exe". Press enter or click "OK".

    ![open command prompt](../json-install-mongo/images/cmd-exe.png " ")

3.  Create and enter a suitable directory. We'll create a directory 'mongosh' under the default home directory, but you can choose to create it elsewhere. For **Mac or Windows**, enter the following commands:

    ```
    <copy>
    mkdir mongosh
    cd mongosh
    </copy>
    ```

## Task 3: Download and expand the installer files

On both Mac and Windows, you can use the built-in 'curl' command to access a URL and download a file from it. The URL to use will vary according to the machine involved.

**Note:** If you encounter any issues with the download or the version listed here, then please visit https://www.mongodb.com/try/download/shell or https://www.mongodb.com/try/download/database-tools to download the most recent shell for your operating system.

Copy **ONE** of the following *curl* commands and paste it to the command or terminal window:

1. For **Mac with Intel processor**:

    Download MongoDB Shell:

    ```bash
    <copy>
    curl https://downloads.mongodb.com/compass/mongosh-2.3.0-darwin-x64.zip -o mongosh.zip
    </copy>
    ```

    Download Command Line Database Tools:

    ```bash
    <copy>
    curl https://fastdl.mongodb.org/tools/db/mongodb-database-tools-macos-x86_64-100.10.0.zip -o mongodbtools.zip
    </copy>
    ```

2. For **Mac with Apple chip**:

    Download MongoDB Shell:

    ```bash
    <copy>
    curl https://downloads.mongodb.com/compass/mongosh-2.3.0-darwin-arm64.zip -o mongosh.zip
    </copy>
    ```

    Download Command Line Database Tools:

    ```bash
    <copy>
    curl https://fastdl.mongodb.org/tools/db/mongodb-database-tools-macos-arm64-100.10.0.zip -o mongodbtools.zip
    </copy>
    ```

3. For **Windows**:

    Download MongoDB Shell:

    ```bash
    <copy>
    curl https://downloads.mongodb.com/compass/mongosh-2.3.0-win32-x64.zip -o mongosh.zip
    </copy>
    ```

    Download Command Line Database Tools:

    ```bash
    <copy>
    curl https://fastdl.mongodb.org/tools/db/mongodb-database-tools-windows-x86_64-100.10.0.zip -o mongodbtools.zip
    </copy>
    ```

4. The previous step will have downloaded a zip file called mongosh.zip and mongodbtools.zip, which we need to expand.

    On **Mac or Windows**, run the following command:

    ```bash
    <copy>
    mkdir -p mongosh | tar -xvf mongosh.zip -C mongosh --strip-components=1
    </copy>
    ```

    ```bash
    <copy>
    mkdir -p mongodbtools | tar -xvf mongodbtools.zip -C mongosh --strip-components=1
    </copy>
    ```

    **Notes**: tar is a built-in command in Windows 11 and recent Windows 10 builds. If for any reason it is not available, you will need to expand the zip file using Windows Explorer. On Mac, you could use the command 'unzip mongosh.zip' to the same effect.

## Task 4: Set the PATH to include the mongosh executable

1. On **Mac** (Intel or Apple silicon) run the following command to set your path variable to include the location of the **mongosh** executable. Y

    ```bash
    <copy>
    export PATH=[path to]/mongosh/bin:[path to]/mongodbtools/bin:$PATH
    </copy>
    ```

    If that fails, you'll have to set your path manually to include the 'bin' directory from the files you just downloaded. If you close and reopen your terminal window, you will need to re-run this command. Alternatively, you can always navigate to the directory where you have extracted the software and run the shell with the relative path.

2. On **Windows** you can use the following command, assuming you created the 'mongosh' directory in your home directory. If you created it elsewhere, you'll need to edit the path command appropriately.

    ```
    <copy>
    set path=%cd%\[path to]\mongosh\bin\:%cd%\[path to]\mongodbtools\bin\:%PATH%
    </copy>
    ```

3. Keep the command or terminal window open for later use. If you close it and need to reopen it, you will need to set the PATH again according to the instructions above.

Mongo Shell is now set up on your PC or Mac.

## Task 5: Alternatively, you can install MongoDB Compass, the GUI for MongoDB

1. Identify the appropriate MongoDB Compass download for your local machine on https://www.mongodb.com/try/download/compass, download and install it. MongoDB Compass offers you both a graphical user interface, as well as a built-in MongoDB shell.

This step is optional, so it is not described in more detail here, although the installation itself is intuitive and self-describing.

## Use Mongo API to interact with Oracle Database

With our JSON Collection created in the Oracle Database, we can use Mongo APIs to interact with the collection as if we were interacting with a Mongo Database. In this section, we will download Mongo tools and then use a Mongo connection string -- which was configured as a part of the Oracle REST Data Service (ORDS) configuration -- to connect to the Oracle Database using Mongo Shell. From there, we can interact with Mongo tools or SQL Developer Web interchangeably to access our data.

### Objectives

In this section, you will:

* Load more data through the Database API for MongoDB
* Use MongoDB Shell to interact with Oracle Database

## Task 1: Interact with Oracle Database using Mongo API

1. First, you must set the URI to the Mongo API running in ORDS on your machine. You can find the URI in the Autonomous Database console in the *Tool Configuration* tab.

    ![Copy Mongo URI](../json-mongo/images/copy-mongo-uri.png " ")

    The MongoDB API URI looks like this:

    ```bash
    <copy>
    mongodb://[user:password@][ADB Instance name].adb.[region].oraclecloudapps.com:27017/[user]?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true
    </copy>
    ```

    Let's create an environment variable called *URI* which contains the MongoDB URI including the user and password information.

    ```bash
    $ <copy>
    export URI='[user:password@][ADB Instance name].adb.[region].oraclecloudapps.com:27017/[user]?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true'
    </copy>
    ```

    Example:

    ```
    export URI='mongodb://admin:*redacted*@ATP3834*redacted*.adb.us-ashburn-1.oraclecloudapps.com:27017/admin?authMechanism=PLAIN&authSource=$external&tls=true&retryWrites=false&loadBalanced=true'
    ```

    > **_NOTE:_** Please make sure you replace both the user and password. Also, keep in mind that the **[user]** tag needs to be updated in two places.

    <if type="sandbox">

    In your LiveLabs Sandbox environment, the user is `admin`. You can find the password for the user on the **View Login Info** 

    ![ADB Admin password in the LiveLabs Sandbox](../json-mongo/images/adb-admin-password.png " ")


    </if>


   You might need to escape some characters as well.



    | Special Character |   !   |   #   |   $   |   %   |   &   |   '   |   (   |   )   |   *   |   +   |
    | ----------------- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
    | Replace with      |  %21  |  %23  |  %24  |  %25  |  %26  |  %27  |  %28  |  %29  |  %2A  |  %2B  |
    {: title="Special characters and their replacements 1"}

    | Special Character |   ,   |   /   |   :   |   ;   |   =   |   ?   |   @   |   [   |   ]   |
    | ----------------- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
    | Replace with      |  %2C  |  %2F  |  %3A  |  %3B  |  %3D  |  %3F  |  %40  |  %5B  |  %5D  |
    {: title="Special characters and their replacements 2"}

     Please check [this link](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/mongo-using-oracle-database-api-mongodb.html#GUID-44088366-81BF-4090-A5CF-09E56BB2ACAB) to learn more about Using MongoDB API in the Oracle Database.


2. Before we connect to the MongoDB Shell, let's populate our database using the MongoDB Command Line Database Tools. You will use a document from Object Storage to seed the data in your **movie** collection.

    ```
    $ <copy>curl -s https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/moviestream_gold/o/movie/movies.json | mongoimport --collection movies --drop --uri $URI
    </copy>
    ```
    ![Populate the database](../json-mongo/images/populate-mongo-db.png " ")

3. Now with the URI set, we can connect to MongoDB Shell. Run the command below to connect.

    ```
    $ <copy>mongosh $URI</copy>
    ```
    ![Connect to the Mongo Shell](../json-mongo/images/mongo-shell.png " ")

4. Within the MongoDB Shell, you can begin running commands to interact with the data in your database as if you were using a Mongo Database. To show the **movie** collection we created and the count of documents we imported, run the following commands.

    ```
    admin> <copy>show collections</copy>
    admin> <copy>db.movies.countDocuments()
    </copy>
    ```
    ![Query result for count](../json-mongo/images/mongo-count.png " ")

5. You can also query for specific documents. Run this query to find the document with title "Zootopia."

    ```
    admin> <copy>db.movies.find( {"title": "Zootopia"} )
    </copy>
    ```
    ![Query result for Zootopia](../json-mongo/images/mongo-zootopia.png " ")

6. Now query for all movies made after 2020.

    ```
    admin> <copy>db.movies.find ( { "year": {"$gt": 2020} } )
    </copy>
    ```
    ![Query result for after 2020](../json-mongo/images/mongo-2020.png " ")

    There's only one movie in our library that was released after 2020.

## Task 2: Interact interchangeably with MongoDB API and SQL Developer Web

Let's take some time to demonstrate the interactivity between the Oracle and MongoDB tools we have installed on our machine to see the different APIs working against the same data set.

1. Use the MongoDB Shell to insert 2 documents to our movie collection.

    ```
    admin> <copy>db.movies.insertMany( [{
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
    ![Mongo inserts two docs](../json-mongo/images/mongo-insert.png " ")

2. Now check for movies again that were released after 2020 and you will see these two movies popping up as well:

    ```
    admin> <copy>db.movies.find ( { "year": {"$gt": 2020} } )
    </copy>
    ```
    ![New result for after 2020](../json-mongo/images/mongo-2020-new.png " ")

3. Oops. We made a mistake with SuperAction Mars, it has the wrong year. Let's quickly update what we just entered. 

    In mongosh, look at the movie again. This also helps us to ensure that we can use the filter to update exactly one document.

    ```
    <copy>db.movies.find({ "title": "SuperAction Mars" })
    </copy>
    ```

    ![Find SuperAction Mars in Mongo](../json-mongo/images/mongo-find-superaction-mars.png " ")

    Ok, we are ready to update the single movie. (In real applications you would probably use "_id", the unique identifier of the document)

    ```
    <copy>db.movies.updateOne({ "title": "SuperAction Mars" },{$set: {"year": 2025}})
    </copy>
    ```
    Done. You can see that we had one matched document that we updated.

    ![Update SuperAction Mars in Mongo](../json-mongo/images/mongo-update-superaction-mars.png " ")


4. Let's go back to the JSON IDE in Database Actions and see that we really updated the document in the Oracle database. When you have selected the collection **movies**, which is most likely the only one you are having, use the following filter to look at SuperAction Mars 

    ```
    <copy>{ "title": "SuperAction Mars" }
    </copy>
    ```

    Indeed, the record was properly updated.

	![New result for after 2020 edit](../json-mongo/images/json-ide-find-superaction-mars-after-update.png)

You can proceed to the next module.

## Learn More

* [Oracle Database API for MongoDB](https://blogs.oracle.com/database/post/mongodb-api)

## Acknowledgements

* **Authors** - William Masdon, Kaylien Phan, Hermann Baer, Roger Ford
* **Contributors** -  David Start, Ranjan Priyadarshi, Kamryn Vinson
- **Last Updated By/Date** - Hermann Baer, February 2025
