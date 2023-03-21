# Using Mongo Shell with Autonomous Database

## Introduction

In this lab, we are going to connect to the Autonomous Database we provisioned in Lab 2. We start by installing the Mongo Shell tool in Oracle Cloud Shell, then use it to connect to Autonomous Database.


Estimated Time: 15 minutes

### Objectives

In this lab, you will:

* Startup Cloud Shell
* Download __mongosh__ to Cloud Shell
* Attach __mongosh__ to your Autonomous JSON Database
* Create a collection
* Add some simple documents to that collection

### Prerequisites

* Have provisioned an Autonomous JSON Database instance and saved the URLs for Database API for MongoDB.
* Have provisioned a Compute Node and installed the MongoDB Shell

You will need the following information, saved from previous labs:

* The URLs for the MongoDB API
* The IP address of your Compute Node

## Task 1: Start Cloud Shell

Cloud Shell is a Linux command prompt provided for your user. You can upload files to it and run commands from it.

1. Go to the main Oracle Cloud page (you may need to close any Service Console or Database Actions tabs that you have open). Click on the square icon with ">" in it at the top right.

	![open console](./images/open-console.png)

2. The console will open at the bottom of your screen. You should see a Linux command prompt. If you wish, you can expand the console window to fill your browser screen by clicking on the diagonal double-arrow. You can resize the font if needed using your browser's normal zoom operation (e.g. CMD-+ on a Mac)

	![cloud shell](./images/cloud-shell.png)

## Task 2: Install the Mongo Shell tool

1. In a new browser tab, open the following link: [https://www.mongodb.com/try/download/shell](https://www.mongodb.com/try/download/shell) 
(note: this page belongs to MongoDB and may change - Oracle Corporation is not responsible for the page or any programs downloaded from it).

	In the Available Downloads box, leave the Version as it is and change Platform to __Linux Tarball 64-bit__. Click the __Copy Link__ button

	![Mongo Shell download](./images/mongosh-download.png)

2. Go back to the cloud shell, and type "wget" and a space, followed by the link you just copied

	![wget mongosh](./images/wget-mongosh.png)

3. This will download a compressed tar file which you will need to unzip. Do that with "tar xvf " followed by the name of the downloaded file. In my case, this would be "tar xvf mongosh-1.2.3-linux-x64.tgz" but it may change with newer versions.

	![unzip the tar file](./images/unzip.png)

4. Finally set the PATH variable so it includes the mongosh executable.

	The PATH variable must include the 'bin' directory, which you can see in the output from the unzip command.

    You can set the PATH variable manually, or use the following shell magic to set it up automatically, and add it to the .bashrc startup file
    for the next time you log in to the Cloud Shell. Make sure to cut and paste this carefully, do not try to retype it, as a mistake here may damage your 
    .bashrc file:

    ```
	<copy>
    echo export PATH=$(dirname `find $HOME -type f -name mongosh`):\$PATH >> .bashrc && . .bashrc
	</copy>
	```

## Task 3: Edit the connection URL

1. Find the URL you saved earlier and edit it in a text editor

	* Change the [user:password@] to admin:YourPassword@ at the start of the URL. Substitute the password you chose earlier for the YourPassword.
	* Change the [user] string in the middle to admin

   	For example, let's say your password is "Password123", and your original connection string is mongodb://[user:password@]MACHINE-JSONDB.oraclecloudapps.com:27017/[user]?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true

	You would change it to 

	```
	<copy>
	mongodb://admin:Password123@MACHINE-JSONDB.oraclecloudapps.com:27017/admin?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true
    </copy>
	```

	Make sure you've changed both strings, and have not left any square brackets in there.

	**IMPORTANT NOTE:** If your password contains any special characters in the set / : ? # [ ] @, you will need to escape them as follows:

	| Character | Escape Sequence |
	| :---:     | :---: |
	| /	 | %25 |
	| :	 | %3A |
	| #	 | %23 |
	| [	 | %5B |
	| ]  | %5D |
	| @	 | %40 |

	So if your password was **P@ssword#123** you would encode it as **P%40ssword%23123**.

## Task 4: Connect MongoDB shell to Autonomous Database

1. In the ssh shell prompt, enter "mongosh" followed by a space followed the edited URL from the previous task in **single-quotes**.

	![mongosh login](./images/mongosh-login.png)

	If all goes well you will see an "admin>" prompt. If not, check your URL carefully:

	* Is it enclosed in single quotes?
	* Is your password correct, with any special characters quoted as above?
	* Did you leave any [ square brackets ] in the URL where they should have been removed?
	* Do you have the : sign between the user and password, and the @ sign after the password? 
	* Is the whole command on a single line with no line breaks?

## Task 5: Create, populate and search a collection

You should now be in Mongo Shell. This is a command-line utility to interact with MongoDB databases (and, by extension, any other database which implements the MongoDB API). Other tools are available such as the graphical Compass tool, but we will stick with the command line to avoid the complexities of installing a GUI-based tool.

1.  Create a collection.

	Copy the following into mongosh and press the enter key.

	```
	<copy>
	db.createCollection('emp')
    </copy>
	```
    ![create collection](./images/create-collection.png)

	That will have created a new document collection called "emp". If you wish, you can type "show collections" to confirm it has been created.

2.	Add some employee documents to the collection.

	Copy the following into mongosh, pressing the enter key after each:

	```
	<copy>
	db.emp.insertOne(
  		{ "name":"Blake", "job": "Intern", "salary":30000 }
	)
	</copy>
	```

	That created a single employee record document. Now we'll create another two. Notice that the second one has an email address, which the first doesn't. With JSON we can change the schema at will.

	```
	<copy>
	db.emp.insertOne(
		{ "name":"Smith", "job": "Programmer", "salary": 60000, "email" : "smith@example.com" }
	)
	</copy>
	```

	```
	<copy>
	db.emp.insertOne(
		{ "name":"Miller", "job": "Programmer", "salary": 70000 }
	)	
	</copy>
	```
3.	Do some searches against the data we just inserted

	Queries in MongoDB (and most JSON databases) use '**Query By Example**' or **QBE**. For a simple QBE, you provide a JSON document fragment, and the system returns all documents that contain that fragment. For example:

	```
	<copy>
 	db.emp.find({"name":"Miller"})
	</copy>
	```

	will return all documents which have a name field of "Miller". Try it now.

	Note: MongoDB Shell allows a "relaxed" JSON syntax where the key name strings don't need to be quoted. So you could use **{name:"Miller"}** 
	instead of **{"name":"Miller"}**. We will use that syntax in some of the following examples.

	A more advanced QBE will use special match operators. For example, **$gt** means "greater than". So:

	```
	<copy>
	db.emp.find({"salary":{"$gt":50000}}) 
	<copy>
	```

	will find all documents where the salary field is numeric, and contains a value greater than 50,000.

    ![QBE to find salary greater than 50000](./images/find-salary.png)

4.	Projection

	In the QBEs used so far, the database has returned the entire document involved. Not a problem here where the documents are short, but we may only want specific parts of the documents. Doing that is called "projection" and is similar to a SELECT clause in a SQL statement. Let's say we want just the name and salary info for our programmers. To get that we specify a second argument to the **find** command, which is a JSON document specifying the parts of the document to return:

	```
	<copy>
	db.emp.find({ job:"Programmer" }, { name:1, salary:1 })
	<copy>
	```

	![projection](./images/projection.png " ")

5.	Updates

	We can use the updateOne or updateMany commands to make changes to one, or a number, of documents. They both take a first argument which is a QBE specifying which documents to update, and a second argument which is the changes to be made to the document. For example, the following will add an email address to our "Miller" employer.

	```
	<copy>
	db.emp.updateOne({name:"Miller"}, {$set: {email:"miller@example.com"}})
	<copy>
	```
	
	When you've run that, you should see confirmation that one record has been found, and one modified. You can check the modification has worked with:

	```
	<copy>
	db.emp.find({name:"Miller"})
	<copy>
	```
	
	![qbe update](./images/qbe-update.png " ")

That's all we're going to cover in MongoDB Shell, but there are some important points to remember:

* This will work just as well with GUI tools such as Atlas, or from your own programs using MongoDB libraries
* All the data is held in Oracle Autonomous Database, and can be accessed from any SQL-based program just as easily as from MongoDB programs.

In the next lab we'll cover Autonomous Database tools, including JSON Workshop and SQL.

## Acknowledgements

- **Author** - Roger Ford, Principal Product Manager
- **Contributors** - Kamryn Vinson, Andres Quintana
- **Last Updated By/Date** - Roger Ford, March 2022
