# Connect to Autonomous Database with Mongo Shell

## Introduction

In this lab, we are going to connect to the Autonomous Database we provisioned in Lab 2, from the MongoDB shell tool that we installed onto our local machine in Lab 1.

Estimated Time: 15 minutes

Watch the video below for a quick walk-through of the lab.
[Connect to Autonomous Database with Mongo Shell](videohub:1_0dg383er)

### Objectives

In this lab, you will:

* Attach __mongosh__ to your Autonomous JSON Database
* Create a collection
* Add some simple documents to that collection

### Prerequisites

* Have provisioned an Autonomous JSON Database instance and saved the URLs for Database API for MongoDB.
* Have installed the MongoDB Shell

You will need the following information, saved from previous labs:

* The URL for the MongoDB API

## Task 1: Locate or Open Terminal or Command Prompt

1.  If your terminal or command prompt window is still open from Lab 1, navigate to it.

2.	If you closed the window, then repeat the instructions from Lab 1 to open a terminal or command prompt, change directory to the 'mongosh' directory you created then, and set the PATH variable again according to the instructions there.

## Task 2: Edit the connection URL

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

	**IMPORTANT NOTE:** if your password contains any special characters in the set / : ? # [ ] @, you will need to escape them as follows:

	| Character | Escape Sequence |
	| :---:     | :---: |
	| /	 | %25 |
	| :	 | %3A |
	| #	 | %23 |
	| [	 | %5B |
	| ]  | %5D |
	| @	 | %40 |

	So if your password was **P@ssword#123** you would encode it as **P%40ssword%23123**.

## Task 3: Connect MongoDB shell to Autonomous Database

1. In the terminal or command prompt, enter "mongosh" followed by a space followed the edited URL from the previous task in **single-quotes** on a **Mac** or **Double-quotes** on **Windows**.

	![mongo shell login](./images/mongosh-login.png)

	If all goes well you will see an "admin>" prompt. If not, check your URL carefully:

	* Is it enclosed in single quotes (Mac) or double quotes (Windows)?
	* Is your password correct, with any special characters quoted as above?
	* Did you leave any [ square brackets ] in the URL where they should have been removed?
	* Do you have the : sign between the user and password, and the @ sign after the password? 
	* Is the whole command on a single line with no line breaks?

## Task 4: Create, populate and search a collection

You should now be in Mongo Shell. This is a command-line utility to interact with MongoDB databases (and, by extension, any other database which implements the MongoDB API). Other tools are available such as the graphical Compass tool, but we will stick with the command line to avoid the complexities of installing a GUI-based tool.

1.  Create a collection.

	Copy the following into mongosh and press the enter key.

	```
	<copy>
	db.createCollection('emp')
    </copy>
	```
    ![Create a collection](./images/create-collection.png)

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
	db.emp.insertMany([
		{ "name":"Smith", "job": "Programmer", "salary": 60000, "email" : "smith@example.com" },
		{ "name":"Miller", "job": "Programmer", "salary": 70000 }
	]
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

	will find all documents where the salary field is numeric and contains a value greater than 50,000.

    ![QBE to find salary greater than 50000](./images/find-salary.png)

4.	Projection

	In the QBEs used so far, the database has returned the entire document involved. Not a problem here where the documents are short, but we may only want specific parts of the documents. Doing that is called "projection" and is similar to a SELECT clause in a SQL statement. Let's say we want just the name and salary info for our programmers. To get that we specify a second argument to the **find** command, which is a JSON document specifying the parts of the document to return:

	```
	<copy>
	db.emp.find({ job:"Programmer" }, { name:1, salary:1 })
	<copy>
	```

	![Projection example](./images/projection.png " ")

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
	
	![QBE update](./images/qbe-update.png " ")

That's all we're going to cover in MongoDB Shell, but there are some important points to remember:

* This will work just as well with GUI tools such as Atlas, or from your own programs using MongoDB libraries
* All the data is held in Oracle Autonomous Database, and can be accessed from any SQL-based programs just as easily as from MongoDB programs.

In the next lab we'll cover Autonomous Database tools, including JSON Workshop and SQL.

You may now proceed to the next lab.

## Learn More

* [Oracle Database API for MongoDB](https://blogs.oracle.com/database/post/mongodb-api)
* [Simple example to test your MongoDB connection using a node.js application](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/mongo-using-oracle-database-api-mongodb.html#GUID-935C72EB-5ECF-4663-9BCA-860708EFAE2A__SUBSTEPS_BQL_R2Y_BRB)

## Acknowledgements

- **Author** - Roger Ford, Principal Product Manager
- **Contributors** - Kamryn Vinson, Andres Quintana
- **Last Updated By/Date** - Hermann Baer, April 2024
