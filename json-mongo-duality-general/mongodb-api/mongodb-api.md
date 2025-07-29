# MongoDB Plug-and-Play - Full MongoDB compatibility to work with JSON Collections and Duality Views

## Introduction

JSON collections - JSON Collection Tables and JSON Collection Views like Duality Views - store JSON documents alongside some metadata , making them fully MongoDB compatible out-of-the box. Through the MongoDB API, part of Oracle REST Data Services (ORDS), you can use any MongoDB tool, utility, or SDK to work with these collections.

We'll then install MongoDB Shell and Command Line Database Tools to enable Mongo APIs. These will interact with our JSON collection. 

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

* Install MongoDB Shell and MongoDB Command Line Database Tools on your local machine
* Alternatively, you can install MongoDB Compass (GUI)
* Set up your PATH to point to the MongoDB Shell and MongoDB Command Line Database Tools executable
* Load more data through the Database API for MongoDB
* Use MongoDB Shell to interact with Oracle Database

### Prerequisites

- An Oracle Autonomous Database 23ai or any Oracle Database 23ai. Note that if you don't use Oracle Autonomous Database, you have to manually install and configure Oracle Rest Data Services (ORDS) to use the MongoDB API used in this lab.
- You have successfully completed Lab 2, JSON Collections, and Lab 3, Duality Views. We will rely on the JSON Collections and Duality Views that were created in these labs in this module.

## Task 1: Install MongoDB Shell and MongoDB Command Line Database Tools

This section walks you through the installation of the MongoDB Shell and MongoDB Command Line Database Tools on your own machine. Instructions are provided for Mac OS X and Windows machines. Installation on a Linux machine will be similar to the Mac instructions, but obviously will require a different download file.

**NOTE**: MongoDB Shell and MongoDB Command Line Database Tools are tools provided by MongoDB Inc. Oracle is not associated with MongoDB Inc, and has no control over the software. These instructions are provided simply to help you learn about MongoDB Shell and MongoDB Command Line Database Tools. Links may change without notice.

Check the official MongoDB download website for latest versions and instructions, e.g.:

https://www.mongodb.com/try/download/shell

https://www.mongodb.com/try/download/database-tools

https://www.mongodb.com/try/download/compass

### Objectives

In this section, you will:

* Install MongoDB Shell and MongoDB Command Line Database Tools on your local machine
* Optionally, you can install MongoDB Compass (GUI)
* Set up your PATH to point to the MongoDB Shell and MongoDB Command Line Database Tools executable

### Prerequisites

- A Mac OS X machine (Intel or Apple hardware) or a Windows PC.
- Access to the command prompt / terminal

### 1: (Mac only) Determine the type of hardware

1. If you know already whether your Mac uses Intel or Apple Silicon you can skip this step. Otherwise:

    Click on the Apple menu in the top left-hand corner of your screen and go to "About this Mac". 

    !["about this mac" menu item](./images/about-this-mac.png " ")

    That will open a "details" panel. Intel Mac will show a line with *Processor:* and the name of an Intel processor. Apple Silicon Macs will show a line saying *Chip* and a line such as "Apple M1 Pro".

    ![processor details](./images/about-mac-details.png " ")

### 2: Open a command prompt or terminal window

1. On a Mac:

    Open the Launchpad icon in the Dock (or press Command-space) and start typing "terminal" in the search box. Press enter to start terminal.

    ![open terminal in launchpad](./images/terminal.png " ")

2.  On a Windows PC:

    Press "Run" (Windows-R) and type "cmd.exe". Press enter or click "OK".

    ![open command prompt](./images/cmd-exe.png " ")

3.  Create and enter a suitable directory. We'll create a directory 'mongosh' under the default home directory, but you can choose to create it elsewhere. For **Mac or Windows**, enter the following commands:

    ```
    <copy>
    mkdir mongosh
    cd mongosh
    </copy>
    ```

### 3: Download and expand the installer files

On both Mac and Windows, you can use the built-in 'curl' command to access a URL and download a file from it. The URL to use will vary according to the machine involved.

**Note: If you encounter any issues with the download or the version listed here, then please visit https://www.mongodb.com/try/download/shell or https://www.mongodb.com/try/download/database-tools to download the most recent shell for your operating system. All subssequent instructions continue to be the same.**

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

### 4: Set the PATH to include the mongosh executable

1. On **Mac** (Intel or Apple silicon) run the following command to set your path variable to include the location of the **mongosh** and **mongoimport** executable.

    ```bash
    <copy>
    export PATH=[path to]/mongosh/bin:[path to]/mongodbtools/bin:$PATH
    </copy>
    ```

    If that fails, you'll have to set your path manually to include the 'bin' directories from the zip files you just downloaded. If you close and reopen your terminal window, you will need to re-run this command. Alternatively, you can always navigate to the directory where you have extracted the software and run the shell with the relative path.

2. On **Windows** you can use the following command, assuming you created the 'mongosh' directory in your home directory. If you created it elsewhere, you'll need to edit the path command appropriately.

    ```
    <copy>
    set path=[path to]\mongosh\bin\:[path to]\mongodbtools\bin\:%PATH%
    </copy>
    ```

3. Keep the command or terminal window open for later use. If you close it and need to reopen it, you will need to set the PATH again according to the instructions above.

Mongo Shell is now set up on your PC or Mac.

### 5: Alternatively, you can install MongoDB Compass, the GUI for MongoDB

1. Identify the appropriate MongoDB Compass download for your local machine on https://www.mongodb.com/try/download/compass, download and install it. MongoDB Compass offers you both a graphical user interface, as well as a built-in MongoDB shell.

This step is optional, so it is not described in more detail here, although the installation itself is intuitive and self-describing.

## Task 2: Use Mongo API to interact with Oracle Database

With our JSON Collection and Duality Views created in the Oracle Database, we can use Mongo APIs to interact with these collections as if we were interacting with a Mongo Database. In this section, we will use native Mongo tools and connect to the Oracle database with a Mongo connection string -- which was configured as a part of the Oracle REST Data Service (ORDS) configuration. From there, we can interact with Mongo tools or SQL Developer Web interchangeably to access our data.

### Objectives

In this section, you will:

* Explore all MongoDB compatible JSON Collections - JSON Collection Tables and Duality Views - in your database
* Load data into both JSON Collections and Duality Views using MongoDB tools and utilities
* Use MongoDB Shell to interact with your JSON Collections and experience DML operations and what it means for JSON Collections and Duality Views

### Explore your JSON Collections

1. Add a JSON Collection View

    Oracle allows you to define read-only JSON Collection Views. JSON Collection Views can become arbitrarily complex, and the only requirement is to have a single-column SELECT list, returning a JSON Object. The common use case is to expose some relational reference data to the MongoDB tool that is a shared enterprise-wide. 
    
    We are quickly creating such a JSON Collection View on a V$ View using **SQL worksheet in Database Actions or your preferred SQL client tool**:

    ```
    <copy>
    create or replace json collection view myversion as
    select json {*} from v$version;

    select json_serialize(data pretty) from myversion;
    </copy>
    ```
    ![JSON Collection View](./images/json-collection-view.png " ")

    **Note**: It is not necessary to have an '_id' field in a JSON Collection View, although it is normally recommended to define such a field. JSON Collection Views are read only.In our simple example with a collection with one document we omit this column.


2. JSON Collections, both tables and views, are automatically compatible with any MongoDB tool, utility, and SDK. You can identify such objects in the database with the **\*\_JSON_COLLECTIONS** family of views. 

    ```
    <copy>
    select * from user_json_collections;
    </copy>
    ```
    ![JSON Collections](./images/json-collections.png " ")

    You'll see that we have our JSON Collection Table movies, three Duality Views, and our newly created (read-only) JSON Collection View. All of these collections can be queried and modified using MongoDB tools.

    Let us look at those with MongoDB tools now.

### Interact with native JSON Collections in the Oracle Database using Mongo API

1. First, you must set the URI to the Mongo API running in ORDS on your machine. You can find the URI in the Autonomous Database console in the *Tool Configuration* tab.

    ![Copy Mongo URI](./images/copy-mongo-uri.png " ")

    The MongoDB API URI looks like this:

    ```bash
    <copy>
    mongodb://[user:password@][ADB Instance name].adb.[region].oraclecloudapps.com:27017/[user]?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true
    </copy>
    ```

    Let's create an environment variable called *URI* which contains the MongoDB URI including the user and password information.

    On Mac or Linux, issue the following command in your shell to set the environment variable. If you close the shell, you need to set this variable again.

    ```bash
    $ <copy>
    export URI='[user:password@][ADB Instance name].adb.[region].oraclecloudapps.com:27017/[user]?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true'
    </copy>
    ```

    Example:

    ```
    export URI='mongodb://admin:*redacted*@ATP3834*redacted*.adb.us-ashburn-1.oraclecloudapps.com:27017/admin?authMechanism=PLAIN&authSource=$external&tls=true&retryWrites=false&loadBalanced=true'
    ```

    On Windows systems, issue the following command in your shell to set the environment variable. If you close the shell, you need to set this variable again.

    ```bash
    $ <copy>
    set URI="[user:password@][ADB Instance name].adb.[region].oraclecloudapps.com:27017/[user]?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true"
    </copy>
    ```

    > **_NOTE:_** Please make sure you replace both the user and password. Also, keep in mind that the **[user]** tag needs to be updated in two places.

    <if type="sandbox">

    In your LiveLabs Sandbox environment, the user is `admin`. You can find the password for the user on the **View Login Info** 

    ![ADB Admin password in the LiveLabs Sandbox](./images/adb-admin-password.png " ")


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


2. Let's use the first MongoDB utility - mongoimport - to populate our database with data exported from a MongoDB in ndjson format. You will use a document from Object Storage to seed the data in your **movie** collection.

    On Linux and Mac systems, issue the following command in your shell to use mongoimport and your URI the environment variable. If you closed the shell, you need to set the URI variable again or specify the connect string directly in the command.

    ```
    $ <copy>curl -s https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/moviestream_gold/o/movie/movies.json | mongoimport --collection movies --drop --uri $URI
    </copy>
    ```

    On Windows systems, issue the following command in your shell to use mongoimport and your URI the environment variable. If you closed the shell, you need to set the URI variable again or specify the connect string directly in the command.

    ```
    $ <copy>curl -s https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/moviestream_gold/o/movie/movies.json | mongoimport --collection movies --drop --uri %URI%
    </copy>
    ```
    ![Populate the database](./images/populate-mongo-db.png " ")

3. Now with the URI set, we can connect to MongoDB Shell. Run the command below to connect.

    On Mac and Linux systems:

    ```
    $ <copy>mongosh $URI</copy>
    ```
    
    On Windows systems:

    ```
    $ <copy>mongosh %URI%</copy>
    ```
    ![Connect to the Mongo Shell](./images/mongo-shell.png " ")

4. Within the MongoDB Shell, you can begin running commands to interact with the data in your database as if you were using a Mongo Database. Let us first examine the JSON collections we have:

    ```
    admin> <copy>show collections</copy>
    </copy>
    ```
    ![Available JSON collections](./images/mongo-collections.png " ")

    If you ran Lab 2 and Lab 3 as suggested, you will see the same JSON Collections we had seen in the database earlier in this section.


5. To show the **movie** collection we created and the count of documents we imported, run the following commands.

    ```
    admin> <copy>db.movies.countDocuments()
    </copy>
    ```
    ![Query result for count](./images/mongo-count.png " ")

5. You can also query for specific documents. Run this query to find the document with title "Zootopia."

    ```
    admin> <copy>db.movies.find( {"title": "Zootopia"} )
    </copy>
    ```
    ![Query result for Zootopia](./images/mongo-zootopia.png " ")

6. Now query for all movies made after 2020.

    ```
    admin> <copy>db.movies.find ( { "year": {"$gt": 2020} } )
    </copy>
    ```
    ![Query result for after 2020](./images/mongo-2020.png " ")

    There's only one movie in our library that was released after 2020.

7. You can do the same for your JSON Collection Views, both the read-only View and our Duality Views

    ```
    admin> <copy>db.MYVERSION.findOne()
    </copy>
    ```
    ![JSON Collection View](./images/mongo-myversion.png " ")

    ```
    admin> <copy>db.SCHEDULEV.findOne()
    </copy>
    ```
    ![JSON Collection View](./images/mongo-schedulev.png " ")

8. If you happen to have installed Mongo Compass, this is how the Duality View would look like in MongoDB's GUI:

    ![JSON Duality View in Compass](./images/mongo-compass.png " ")

    We have briefly glanced at all our JSON Collections using mongosh. Let's now actually work with the data.


## Task 3: Interact interchangeably with MongoDB API and SQL Developer Web

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
    ![Mongo inserts two docs](./images/mongo-insert.png " ")

2. Now check for movies again that were released after 2020 and you will see these two movies popping up as well:

    ```
    admin> <copy>db.movies.find ( { "year": {"$gt": 2020} } )
    </copy>
    ```
    ![New result for after 2020](./images/mongo-2020-new.png " ")

3. Oops. We made a mistake with SuperAction Mars, it has the wrong year. Let's quickly update what we just entered. 

    In mongosh, look at the movie again. This also helps us to ensure that we can use the filter to update exactly one document.

    ```
    <copy>db.movies.find({ "title": "SuperAction Mars" })
    </copy>
    ```

    ![Find SuperAction Mars in Mongo](./images/mongo-find-superaction-mars.png " ")

    Ok, we are ready to update the single movie. (In real applications you would probably use "_id", the unique identifier of the document)

    ```
    <copy>db.movies.updateOne({ "title": "SuperAction Mars" },{$set: {"year": 2025}})
    </copy>
    ```
    Done. You can see that we had one matched document that we updated.

    ![Update SuperAction Mars in Mongo](./images/mongo-update-superaction-mars.png " ")


4. Let's go back to the JSON IDE in Database Actions and see that we really updated the document in the Oracle database. When you have selected the collection **movies**, which is most likely the only one you are having, use the following filter to look at SuperAction Mars 

    ```
    <copy>{ "title": "SuperAction Mars" }
    </copy>
    ```

    Indeed, the record was properly updated.

	![New result for after 2020 edit](./images/json-ide-find-superaction-mars-after-update.png)

5. We are now updating a shared nested JSON Object in our JSON Duality View. Unlike JSON Collections where data is duplicated in any document that shares the same content, we update the content of our Duality View in ONE place, and all JSON Collections (Duality Views) that share the JSON Object will be magically and automatically updated, too.

    Look at the speaker collection. 

    ```
    <copy>db.SPEAKERV.find()
    </copy>
    ```
	![Speakers](./images/speakers.png)

    There is a speaker named *Beda*, who will be replaced with *Julian*. Unfortunately Beda is busy and is currently not available as speaker.
    ```
    <copy>db.SPEAKERV.updateOne({_id:1}, {$set: {name: "Julian"}})
    db.SPEAKERV.find({ _id: 1})
    </copy>
    ```
	![Speakers](./images/update-speaker.png)

    With the groundbreaking architecture of JSON Duality Views and the denormalized storage of shared data, we not only updated the **SPEAKERV** collection, but also automatically updated the schedule of all attendess, represented through collection **SCHEDULEV**.

    ```
    <copy>db.SCHEDULEV.find()
    </copy>
    ```
	![Schedules](./images/schedules.png)

That was a quick run-through of using JSON Collections with the MongoDB compatible API in Oracle Database. There is obviously more to this - as always - but we hope that it helped you to get started and interested in Oracle's comprehensive JSON capabilities.

## Learn More

* [JSON Relational Duality: The Revolutionary Convergence of Document, Object, and Relational Models](https://blogs.oracle.com/database/post/json-relational-duality-app-dev)
* [JSON Duality View documentation](https://docs.oracle.com/en/database/oracle/oracle-database/23/jsnvu/overview-json-relational-duality-views.html#)
* [Oracle Database API for MongoDB](https://blogs.oracle.com/database/post/mongodb-api)

## Acknowledgements

* **Authors** - Hermann Baer
* **Contributors** -  Beda Hammerschmidt
- **Last Updated By/Date** - Hermann Baer, April 2025
