# Creating multi-value JSON indexes and aggregation pipelines using MongoDB Shell (mongosh)

## Introduction

In Oracle Database 23ai, indexes can be created natively from within any MongoDB tool or using any MongoDB API. Oracle creates such indexes as Multi-value any-type indexes that do not require users to specify a data type upfront. These indexes will be picked up by both MongoDB and SQL queries over the same data. 

Oracle Database 23ai furthermore supports aggregation pipelines; they are transparently converted into SQL and executed directly. In this lab, we will create a native JSON collection called SALES and we will create indexes and aggregation pipelines directly from MongoDB Shell.

MongoDB added recently a new operator $sql to their aggregation pipeline framework not too long ago, so we at Oracle figured, hey, we have SQL, too. But unlike MongoDB, Oracle is doing SQL for quite some time, so Oracle supports that operator and offers its customers the world of Oracle's powerful SQL within the realms of the MongoDB API. The examples below will also show how $sql can be used in Oracle Database 23ai.


Estimated Time: 10 minutes

### Objectives

In this lab, you will:

- Create a native JSON collection called SALES
- Create and drop indexes on the SALES collection
- Create aggregation pipelines
- Validate the newly created collection table



### Prerequisites

- Oracle Database 23ai
- MongoDB shell installed

## Task !: Create a native JSON collection called **SALES**

1. From within mongosh, execute the following statement:

    ```
    <copy>db.createCollection('SALES');
    </copy>
    ```

## Task 2: Populate the SALES collections with data

1. Execute the following code in mongosh:

    ```
    <copy>db.SALES.insertMany([
	{ "_id" : 1, "item" : "Espresso", "price" : 5, "size": "Short", "quantity" : 22, "date" : ISODate("2024-01-15T08:00:00Z") },
	{ "_id" : 2, "item" : "Cappuccino", "price" : 6, "size": "Short","quantity" : 12, "date" : ISODate("2024-01-16T09:00:00Z") },
	{ "_id" : 3, "item" : "Latte", "price" : 10, "size": "Grande","quantity" : 25, "date" : ISODate("2024-01-16T09:05:00Z") },
	{ "_id" : 4, "item" : "Mocha", "price" : 8,"size": "Tall", "quantity" : 11, "date" : ISODate("2024-02-17T08:00:00Z") },
	{ "_id" : 5, "item" : "Americano", "price" : 1, "size": "Grande","quantity" : 12, "date" : ISODate("2024-02-18T21:06:00Z") },
	{ "_id" : 6, "item" : "Cortado", "price" : 7, "size": "Tall","quantity" : 20, "date" : ISODate("2024-02-20T10:07:00Z") },
	{ "_id" : 7, "item" : "Macchiato", "price" : 9,"size": "Tall", "quantity" : 30, "date" : ISODate("2024-02-21T10:08:00Z") },
	{ "_id" : 8, "item" : "Turkish Coffee", "price" : 20, "size": "Grande","quantity" : 21, "date" : ISODate("2024-02-22T14:09:00Z") },
	{ "_id" : 9, "item" : "Iced Coffee", "price" : 15, "size": "Grande","quantity" : 17, "date" : ISODate("2024-02-23T14:09:00Z") },
	{ "_id" : 10, "item" : "Dirty Chai", "price" : 12, "size": "Tall","quantity" : 15, "date" : ISODate("2024-02-25T14:09:00Z") },
	{ "_id" : 11, "item" : "Decaf", "price" : 4, "size": "Normal", "quantity" : 2, "date" : ISODate("2024-01-16T11:01:00Z") },
	{ "_id" : 12, "item" : "Finlandia", "price" : 50, "size": "Grande","quantity" : 7, "date" : ISODate("2024-05-16T10:00:00Z") }
    ]);
    </copy>
    ```

## Task 3: Create indexes on SALES

1. The following example creates an ascending index on the field size:

    ```
    <copy>
    db.SALES.createIndex({size:1});
    </copy>
    ```
2. Drop the index

    ```
    <copy>
    db.SALES.dropIndex("size_1");
    </copy>
    ```
3. The following example creates a compound index called sales_ndx on the item field (in ascending order) and the quantity field (in descending order)

    ```
    <copy>
    db.SALES.createIndex({item:1, quantity:-1},{name:"sales_ndx"});
    </copy>
    ```
4. Drop the index

    ```
    <copy>
    db.SALES.dropIndex("sales_ndx");
    </copy>
    ```
5. The following example creates a unique index called sales_uniq_ndx on the item field (in ascending order)

    ```
    <copy>
    db.SALES.createIndex({item:1}, {name:"sales_uniq_ndx", unique: true});
    </copy>
    ```
6. Check that the index is actually created using $sql:

    ```
    <copy>
    db.aggregate([{ $sql: "select index_name from user_indexes where index_type <> 'LOB' and table_name = 'SALES'" }] );
    </copy>
    ```
7. Check if the index is used in mongosh:

    ```
    <copy>
   db.SALES.find({size:3}).explain();
    </copy>
    ```

8. Drop the index

    ```
    <copy>
    db.SALES.dropIndex("sales_uniq_ndx");
    </copy>
    ```

## Task 4: Create aggregation pipelines

1. Calculate the total price of all items

    ```
    <copy>
    db.SALES.aggregate([{$group:{_id:null,"total_price": {$sum:"$price"}}}]);
    </copy>
    ```

2. Using SQL, calculate the quantity of all items

    ```
    <copy>
    db.SALES.aggregate([
    {$sql: 'select sum(f.data.quantity) from SALES f'}
    ]);
    </copy>
    ```

3. Using SQL, calculate the average price of the items

    ```
    <copy>db.SALES.aggregate([
    {$sql: 'select avg(f.data.price) from SALES f'}
    ]);
    </copy>
    ```

4. For every size, list the total quantity available

    ```
    <copy>db.SALES.aggregate([
    {
        $group: {
         _id: '$size',
        totalQty: { $sum: '$quantity' },
        },
     },
    ]);
    </copy>
    ```
* Examples for analytical functions are for example at: https://blogs.oracle.com/database/post/proper-sql-comes-to-mongodb-applications-with-oracle


## Learn More

* [Proper SQL comes to MongoDB applications..with the Oracle Database!](https://blogs.oracle.com/database/post/proper-sql-comes-to-mongodb-applications-with-oracle)

## Acknowledgements

* **Author** - Julian Dontcheff, Hermann Baer
* **Contributors** -  David Start, Ranjan Priyadarshi
* **Last Updated By/Date** - Hermann Baer, February 2025