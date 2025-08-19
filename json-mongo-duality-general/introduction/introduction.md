# Introduction

## About this Workshop

In this workshop, you will experience Oracle's JSON capabilities using both relational and document-store APIs. You will be learn all variants of how to leverage JSON in the Oracle database, starting from the native JSON datatype over JSON Collections and JSON Duality Views - the latest groundbreaking JSON-related functionality, to the Oracle Database API for MongoDB that provides full MongoDB compatibility in a plug-and-play fashion

This lab is organized into different topics, each topic consists of multiple steps. After completing this workshop a user has a very good understanding of what JSON features are available in Oracle Database and when to use them. You will work against the same data using both with SQL and using the MongoDB API and will experience yourself why Oracle database is better suited for JSON Development than Mongo database.

### Objective

This workshop is not a 'cookbook' or 'design guideline' on how to work with JSON data - the purpose is to illustrate various JSON features that the Oracle Database offers. That said, you likely find that many examples are applicable to your business needs!

You can complete all Oracle-related parts of the workshop using your web browser. There is no need to install any extra software other than MongoDB Shell and MongoDB Command Line Database Tools when you're prompted to do so. (Optionally, you can install MongoDB Compass, too). When writing a real application, you would call many of the functionalities from a programming language like Java, JavaScript(nodeJS) or Python.

Estimated Time:  60 minutes

Watch this quick video to know why JSON in Oracle Autonomous Database is awesome.

[](youtube:yiGFO139ftg)


### About JSON

Before we get started let's take a brief look at JSON (you may skip this step if you're already familiar with it)

#### What is JSON?

JSON is a human-readable, self-describing format to represent data in a hierarchical format. This is best illustrated by an example - a JSON object with information about a person:

```
{
	"id":100,
	"firstName":"John",
	"lastName":"Smith",
	"age":25,
	"address":{
		"street":"21 2nd Street","city":"New York",
		"state":"NY","postalCode":"10021",	 
		"isBusiness":false	
	},	
	"phoneNumbers":[		
		{"type":"home","number":"212 555-1234"},	
		{"type":"mobile","number":"646 555-4567"}
	],
	"bankruptcies":null,
	"lastUpdated":"2019-05-13T13:03:35+0000"
}
```

Objects consist of key-value pairs: the key "id" has the value 100. Keys are always strings (identified by double quotes). Scalar values can be numeric (like 100), strings ("John"), Boolean (true, false) or null. The ordering of key-value pairs in an object is not relevant but keys have to be unique per object. Keys can also point to a non-scalar value, namely another object (like address) or array (phoneNumbers). A JSON array is an ordered list of values. You can think of objects and arrays both being containers with values; in an object, the key identifies the value whereas in an array it is the position that identifies the value.

No problem, if this does not make much sense yet, you'll get more comfortable with JSON very soon - it is really easy!

One thing to keep in mind is that JSON needs no upfront definition of keys or data types. You can easily modify the shape (schema) of your data.


#### Why is JSON so popular for application development?

Schema-flexibility is a big reason why JSON makes a lot of sense for application development. Especially in the initial phase, an application is quite dynamic, new fields are needed, interfaces get changed, etc. Maintaining a relational schema is hard if application changes often need a change in the underlying tables and existing data needs to be modified to fit into the new schema. JSON makes this much easier as new documents may look different than old ones (for example have additional fields).

JSON also avoids the normalization of a business object into multiple tables. Look at the example above with a customer having multiple phone numbers. How would we store the phone numbers relationally? In separate columns (thus limiting the total amount of phone numbers per person) or in a separate table so that we need to join multiple tables if we want to retrieve a business object? In reality, most business objects get normalized into many more than two tables so an application developer has to deal with the complexity of inserting into many tables when adding a new object and joining the tables back on queries - the SQL to do that can get quite complex. JSON on the other hand allows us to map an entire business object into one JSON document. Every insert or query now only affects one value in the database - no joins are needed.

Now you know what JSON is and also why so many people love it. Enough theory for now - time to code!

### Objectives

In this workshop, you will: 
*	Use the native JSON datatype within a relational table
*   Work with JSON Collections, a native MongoDB-compatible document storage
*   Experience the groundbreaking new functionality of JSON Relational Duality Views, marrying the benefits of relational and JSON
*	Use the MongoDB API to query or manipulate JSON Collections and Duality Views in the Oracle Database
*	Use SQL interchangeably to MongoDB API to query, generate and process JSON data

### Prerequisites

- Autonomous Database 23ai, free or paid

**Please Note:**: While this workshop is using Autonomous Database, all commands and features related to JSON enhancement are also available on any other Oracle Database 23ai (Version 23.4 or higher) release. This includes the 23ai Free release as well as 23ai running on Oracle Database Base Service or Oracle Engineered Systems.

You may now proceed to the next lab.

## Learn More

* [Overview of JSON](https://docs.oracle.com/en/database/oracle/oracle-database/23/adjsn/json-data.html#GUID-B2D82ED4-B007-4019-8B53-9D0CDA81C4FA)
* [JSON Datatype Support in Oracle Database](https://blogs.oracle.com/database/post/json-datatype-support-in-oracle-21c)
* [From MongoDB to Oracle: Seamlessly manage your collections with JSON Collection Tables](https://medium.com/oracledevs/from-mongodb-to-oracle-seamlessly-manage-your-collections-with-json-collection-tables-85ff1f4ce231)
* [JSON Relational Duality: The Revolutionary Convergence of Document, Object, and Relational Models](https://blogs.oracle.com/database/post/json-relational-duality-app-dev)
* [Installing Database API for MongoDB for any Oracle Database ](https://blogs.oracle.com/database/post/installing-database-api-for-mongodb-for-any-oracle-database)

## Acknowledgements

* **Author** - Hermann Baer
* **Contributors** -  Beda Hammerschmidt
* **Last Updated By/Date** - Hermann Baer, April 2025