# Work with JSON collections

## Introduction

Oracle is a relational database, meaning it typically stores data in rows and columns of tables and JSON can be stored as a column value. For this lab though, we first focus on the Document Store API SODA (Simple Oracle Document Access) which allows us to store JSON data in a so-called collection. A JSON collection stores JSON documents alongside some metadata like the time of creation or update. Collections offer operations like inserts, deletes, index creation or queries.

To create a collection all you have to specify is the collection's name. Unlike a relational table, you do not have to provide any schema information. So, let's create a collection for the products we want to sell in the store.

Estimated Time: 20 minutes


### Objectives

In this lab, you will:

* Create Collection
* Insert First Document
* Find JSON documents in a collection
* Learn about JSON and Constraints

### Prerequisites

- Oracle Database 23c Free Developer Release
- All previous labs successfully completed

## Task 1: Create Collection

1. Open a browser window to SQL Developer Web.

	```
    <copy>http://localhost:8080/ords/hol23c/_sdw</copy>
    ```

	![Open Browser](./images/open-browser.png)

2. Sign in with the username and password of the schema with ORDS enabled. If you are using the green button, this user has already been created for you. Replace the `<new_password>` with the one you entered in Lab 1: Setup User.

    ```
    username: hol23c
    password: <new_password>
    ```

	![User Sign In](./images/ords-sign-in.png)

4. On the homepage, click the JSON tile under Development. You can ignore the guided tours when they pop up. 

	![Homepage Development JSON](./images/homepage-json.png)

5. To create a collection, click **Create Collection**.
	A tour of this section may automatically begin when the page loads. You can click `next` to continue through the tour and return to this page.

	![JSON Create Collection](./images/json-create-collection.png)

6. In the field **Collection Name**, provide the name **movies**. MAKE SURE you check the **MongoDB Compatible** box then click **Create**.
	Note that the collection name is case-sensitive. You must enter products in all lower-case, don't use MOVIES or Movies.

	![New Collection: movies](./images/collection-name.png)

7. A notification pops up that displays **movies** collections has been created.

	![New collection notification](./images/popup.png)

8. Click the refresh button to verify the **movies** collection has been created.

	![Refresh button](./images/refresh-collection.png)

## Task 2: Insert Documents

1. Double click **movies** collection to show the **JSON-movies** worksheet.

	![products worksheet](./images/click-movies.png)

2. Click the *New JSON Document* button.

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

2. We want to ensure that our JSON data satisfies minimal data quality, so we will create a constraint to enforce a couple of mandatory fields and their data types. **Enforcing a JSON schema is new functionality in Oracle Database 23c.**

	To quickly recap what the documents look like, let's look at the first JSON document quickly. (Don't worry, we will have a closer look into the SQL world with JSON later):
	```
	<copy>
	select json_serialize(data pretty) from movies fetch first 1 rows only;
	</copy>
	```
	![Single document in SQL](./images/show-single-json-in-sql.png)

    Now copy and paste the query below in the worksheet and click the *Run query* button to run the SQL query to alter the **movie** table and add constraints.

    ```
    <copy>alter table movies add constraint movies_json_schema
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
	alter table movies add constraint no_negative_price
    check (
            JSON_EXISTS(data, '$?(@.price.number() >= 0)')
          );
	</copy>
	```
	![add constraint](./images/sql-constraint-2.png)

	JSON_Exists is a SQL/JSON function that checks that a SQL/JSON path expression selects at least one value in the JSON data. The selected value(s) are not extracted – only their existence is checked. Here, *$?(@.price.number() >= 0)* is a standard, SQL/JSON path expressions. You'll learn more about SQJ/JSON functions later in this lab.

4. Once the **movie** table is altered, navigate back to JSON workshop. Click the navigation menu on the top left and select **JSON** under Development.

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

7. Now that was quite cumbersome to figure out the mistakes manually. But there's a better way: you can ask the database for the problems with your payload. Navigating back to the SQL page, you can enter this command to see the errors with your JSON payload. **JSON schema is new functionality in Oracle Database 23c.**

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
    from user_JSON_SCHEMA_COLUMNS where table_name = 'MOVIES')
    select json_serialize(report pretty) from x
    /
    </copy>
    ```
	The output shows you all the violations in detail, so that it is easier to address the issues.

	![SQL to find JSON doc problem](./images/sql-shows-schema-error.png)

8. You may also check the JSON Schema definition in your data dictionary. **JSON schema is new functionality in Oracle Database 23c.**
In the SQL tool, run:

    ```
    <copy>
    select constraint_name, json_serialize(json_schema) from user_JSON_SCHEMA_COLUMNS where table_name = 'MOVIES';
    </copy>
    ```
	![SQL for data dictionary](./images/sql-data-dict.png)


	_Click on a table cell then the eye icon to view the full value._

You may now proceed to the next lab.

## Learn More

* [Oracle Database API for MongoDB](https://blogs.oracle.com/database/post/mongodb-api)

## Acknowledgements

* **Author** - William Masdon, Kaylien Phan, Hermann Baer
* **Contributors** -  David Start, Ranjan Priyadarshi
* **Last Updated By/Date** - William Masdon, Database Product Manager, April 2023