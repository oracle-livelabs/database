# Working effectively with JSON

## Introduction

JSON, short for JavaScript Object Notation, has become the de-facto standard data interchange format and is a very popular for storing data. Oracle's Converged Database has supported JSON for many years, adding functionality with each release on top of an already impressive base. Oracle Database 23c Free - Developer Release is no exception.

You already got a glimpse of JSON in `processOrder()`, part of the `business_logic` module. This function is called with a string argument. The string is made up of a series of key-value pairs, each separated by a semi-colon each. The input parameter was subsequently translated to a JSON object and used in an insert statement showcasing the `json_table` function.

> **Note:** You could have stored the JSON document in a JSON column in the table directly, but then you wouldn't have seen how easy it is to convert JSON to a relational format

In this lab you will learn about an alternative way of working with JSON, based on the document object model.

Estimated Lab Time: 10 minutes

### Objectives

In this lab, you will:

- Understand how to work with JSON using the document model (Simple Oracle Document Access (SODA))
- Create SODA collections
- Add documents to a collection
- Search for a specific document in a collection
- Modify a document and save it back to the collection
- Delete a document from a collection
- Drop the collection

### Prerequisites

This lab assumes you have:

- An Oracle Database 23c Free - Developer Release environment available to use
- Created the `emily` account as per Lab 1

## Task 1: Create a database session

Connect to the pre-created Pluggable Database (PDB) `freepdb1` using the same credentials you supplied in Lab 1

```bash
<copy>sqlplus emily/yourNewPasswordGoesHere@localhost/freepdb1</copy>
```

## Task 2: Understand the Simple Oracle Document Access model

In this part of the lab, you will learn how to interact with JSON using the Simple Oracle Document Access (SODA) model. The SODA API allows you to work with the database without ever having to resort to SQL's DML (Data Manipulation Language) and DDL (Data Definition Language) commands. Instead you follow the same approach you would when using specialised document databases while at the same time enjoying all the benefits of Oracle's Converged Database.

The SODA API is based around the following concepts:

- **SODADatabase**: The top-level object for SODA operations. This is acquired from an Oracle Database connection. A SODA database is an abstraction, allowing access to SODA collections in that SODA database, which then allow access to documents in those collections. A SODA database is analogous to an Oracle Database user or schema.
- **SODACollection**: Represents a collection of SODA documents. By default, collections allow JSON documents to be stored, and they add a default set of metadata to each document. This is recommended for most users.
- **SODADocument**: Represents a document. Typically, the document content will be JSON. The document has properties including the content, a key, timestamps, and the media type. By default, document keys are automatically generated

The code for this lab is very comprehensive. Rather than displaying just parts of it you will create the entire model in this step, followed by the call specification. The various steps in the next task discuss the relevant functions of the module in detail.

1. Begin this lab by creating the `SODA_API_LAB` JavaScript module:

    ```js
    <copy>
    create or replace mle module soda_api_lab 
    language javascript as

    /** 
     * Drop a collection in preparation of cleaning up
     * @param {string} collectionName the name of the collection to be dropped
     */
    export function dropCollection(collectionName) {

        validateString(collectionName, "collectionName");

        // verify if the collection to be dropped exists in the first place
        const col = soda.openCollection(collectionName);
        if (col === null) {
            throw `The collection (${collectionName}) you asked to be dropped does not exist`;
        }

        // drop the collection to complete this lab. In other scenarios
        // this might be a dangerous operation because the collection and
        // all its documents are removed permanently
        col.drop();
    }

    /**
     * Delete a document from a collection
     * @param {string} collectionName the name of the collection
     * @param {number} empno the employee ID
     * @throws error in case the document could not be deleted
     */
    export function deleteDocument(collectionName, empno) {

        validateString(collectionName, "collectionName");
        validateNumber(empno, "empno");
        
        // open the collection
        const col = createCollection(collectionName);

        // find the document 
        const result = col.find().filter({ "empno": empno }).remove();
        if ( result.count === 0) {
            throw `could not delete employee record (empno: ${empno})`;
        }
    }

    /** 
     * Update the salary of an employee identified by empno
     * @param {string} collectionName the name of the collection
     * @param {number} empno the employee ID
     * @param {number} newSal the new salary
     * @throws will throw an error if no employee is found
     */
    export function updateEmpSalary(collectionName, empno, newSal) {

        validateString(collectionName, "collectionName");
        validateNumber(empno, "empno");
        validateNumber(newSal, "newSal");

        const col = createCollection(collectionName);

        try {
            const docCursor = col.find().filter({ "empno": empno }).getCursor();
            let doc;
            while ((doc = docCursor.getNext())) {

                let emp = doc.getContent();
                emp.sal = newSal;
                col.find().key(doc.key).replaceOne(emp);
            }

        } catch (err) {
            throw `error updating salary for empno ${empno}: ${err}`;
        }
    }

    /** 
     * Search for a particular employee name
     * @param {string} collectionName the name of the collection
     * @returns {object} a list of documents matching a given ename
     * @throws will throw an error if no employee is found
     */
    export function findEmpByEname(collectionName, ename) {

        validateString(collectionName, "collectionName");
        validateString(ename, "ename");

        const col = createCollection(collectionName);
        let employees = [];

        try {
            const docCursor = col.find().filter({ "ename": ename }).getCursor();
            let doc;
            while ((doc = docCursor.getNext())) {
                employees.push(doc.getContent());
            }

        } catch (err) {
            throw `no employee found in ${collectionName} with ename ${ename}`;
        }

        return employees;
    }

    /** 
     * Add documents to the collection
     * @param {string} collectionName the name of the collection
     */
    export function addDocumentToCollection(collectionName) {

        validateString(collectionName, "collectionName");

        const col = createCollection(collectionName);

        // define a JSON document
        let doc = {
            "empno": 7839,
            "ename": "KING",
            "job": "PRESIDENT",
            "mgr": "",
            "hiredate": "1981-11-17",
            "sal": 5000,
            "comm": 0,
            "deptno": 10
        };

        // insert the document into the collection
        col.insertOne(doc);

        // insert another one
        doc = {
            "empno": 7566,
            "ename": "JONES",
            "job": "MANAGER",
            "mgr": 7839,
            "hiredate": "1981-04-02",
            "sal": 2975,
            "comm": 0,
            "deptno": 20
        };

        col.insertOne(doc);
    }

    /**
     * validate a string argument passed to a function
     * @param {string} str the string to validate
     * @throws will throw an error if the string is undefined or zero-length or an invalid argument is passed
     */
    function validateString(str, variable) {

        // perform input validation to avoid an error later
        if (typeof variable === 'undefined' || variable.length === 0) {
            throw `invalid arguments passed to validateString()`;
        }

        if (typeof str === 'undefined' || str.length === 0) {
            throw `must provide a valid value for ${variable}`;
        }
    }

    /**
     * validate a number argument passed to a function
     * @param {number} num the number to validate
     * @throws will throw an error if the number isNaN or an invalid arguments is passed
     */
    function validateNumber(num, variable) {

        // perform input validation to avoid an error later
        if (isNaN(num)) {
            throw `${num} is not a number`
        }    

        // perform input validation to avoid an error later
        if (typeof variable === 'undefined' || variable.length === 0) {
            throw `invalid arguments passed to validateNumber()`;
        }
    }

    /**
     * create a collection if it does not exist or open it
     * @param {string} collectionName the name of the collection to create or open
     * @returns {SodaCollection} the SODA collection
     */
    export function createCollection(collectionName) {

        validateString(collectionName, "collectionName");

        // create the collection. In case a collection with the same name
        // exists already it will be opened - in any case the operation should
        // complete successfully
        const col = soda.createCollection(collectionName);

        return col;
    }
    /
    </copy>
    ```

2. Create the corresponding call specifications next

    ```sql
    <copy>
    create or replace package soda_demo_pkg authid current_user as

    procedure drop_collection(p_collection_name varchar2)
    as mle module soda_api_lab
    signature 'dropCollection(string)';

    procedure update_emp_salary(
        p_collection_name varchar2,
        p_empno number,
        p_new_sal number
    )
    as mle module soda_api_lab
    signature 'updateEmpSalary(string,number,number)';

    function find_emp_by_ename(
        p_collection_name varchar2,
        p_ename varchar2
    ) return JSON
    as mle module soda_api_lab
    signature 'findEmpByEname(string,string)';

    procedure addDocumentToCollection(p_collection_name varchar2)
    as mle module soda_api_lab
    signature 'addDocumentToCollection(string)';

    procedure delete_document(
        p_collection_name varchar2,
        p_empno number)
    as mle module soda_api_lab
    signature 'deleteDocument(string,number)';

    procedure create_collection(
        p_collection_name varchar2
    ) 
    as mle module soda_api_lab
    signature 'createCollection(string)';

    end soda_demo_pkg;
    /
    </copy>
    ```

## Task 3: Interact with JSON using the SODA API

Simple Oracle Document Access (SODA) is a set of NoSQL-style APIs that let you create and store collections of documents (in particular JSON) in Oracle Database, retrieve them, and query them, without needing to know SQL or how the documents are stored in the database.

SODA APIs exist for different programming languages and include support for MLE JavaScript. SODA APIs are document-centric. You can use any SODA implementation to perform create, read, update, and delete (CRUD) operations on documents of nearly any kind. You can also use any SODA implementation to query the content of JSON documents using pattern-matching: query-by-example (QBE). CRUD operations can be driven by document keys or by QBEs.

The previous lab (concerning the JavaScript SQL driver) introduced a major difference between the client-side `node-oracledb` driver and the one found in the database. Rather than having to get a handle to the default database connection and writing additional code, a number of variables have been injected into the global scope. This approach is used throughout this lab.

1. Create a SODA Collection using variables defined in the global scope

    A SODA Collection is a container for JSON documents. Before any documents can be stored, a collection must be created first.

    ```js
    /**
     * create a collection if it does not exist or open it
     * @param {string} collectionName the name of the collection to create or open
     * @returns {SodaCollection} the SODA collection
     */
    export function createCollection(collectionName) {

        // ensure that collectionName is a valid string
        validateString(collectionName, "collectionName");

        // create the collection. In case a collection with the same name
        // exists already it will be opened - in any case the operation should
        // complete successfully
        const col = soda.createCollection(collectionName);

        return col;
    }
    ```

    Any code using the SODA API typically starts by creating or opening a collection. `createCollection()` is a generic function in this module used to access a given connection in later examples. Having a standard function for accessing a collection helps with code reusability.

    Create a collection by calling the corresponding call-specification. Pick a suitable name like `myCollection` and stick with it throughout this lab.

    ```sql
    <copy>
    begin
        soda_demo_pkg.create_collection('myCollection');
    end;
    /
    </copy>
    ```

    The procedure should complete successfully. After the prompt is returned a new SODA collection will have been created. Under the covers Oracle will create a table named `myCollection` containing the JSON document and some metadata.

2. Add documents to a collection

    Collections serve as a container for JSON documents. In this step you will add a new document to the collection. The code performing this operation is shown here.

    ```js
    /** 
    * Add documents to the collection
    * @param {string} collectionName the name of the collection
    */
    export function addDocumentToCollection(collectionName) {

        validateString(collectionName, "collectionName");

        // reuse the function discussed previously to access the collection
        const col = createCollection(collectionName);

        // define a JSON document
        let doc = {
            "empno": 7839,
            "ename": "KING",
            "job": "PRESIDENT",
            "mgr": "",
            "hiredate": "1981-11-17",
            "sal": 5000,
            "comm": 0,
            "deptno": 10
        };

        // insert the document into the collection
        col.insertOne(doc);

        // insert another one
        doc = {
            "empno": 7566,
            "ename": "JONES",
            "job": "MANAGER",
            "mgr": 7839,
            "hiredate": "1981-04-02",
            "sal": 2975,
            "comm": 0,
            "deptno": 20
        };

        col.insertOne(doc);
    }
    ```

    Execute the corresponding call specification to insert 2 documents into the collection you just created.

    ```sql
    <copy>
    select
        count(*) row_count_before
    from
        "myCollection";
    
    begin
        soda_demo_pkg.addDocumentToCollection('myCollection');
        commit;
    end;
    /

    select
        count(*) row_count_after
    from
        "myCollection";
    </copy>
    ```

    This function inserts 2 documents to a collection as shown in the output:

    ```
    SQL> select
      2      count(*) row_count_before
      3  from
      4      "myCollection";

    ROW_COUNT_BEFORE
    ----------------
                   0

    SQL> begin
      2      soda_demo_pkg.addDocumentToCollection('myCollection');
      3      commit;
      4  end;
      5  /

    PL/SQL procedure successfully completed.

    SQL> select
      2      count(*) row_count_after
      3  from
      4      "myCollection";

    ROW_COUNT_AFTER
    ---------------
                  2
    ```

3. Search for a specific document in the collection

    The SODA API provides filter functions to be used with QBE operators. This example demonstrates how to find a document (or set of documents) in a collection using a QBE.

    ```js
    /** 
     * Search for a particular employee name
     * @param {string} collectionName the name of the collection
     * @returns {object} a list of documents matching a given ename
     * @throws will throw an error if no employee is found
     */
    export function findEmpByEname(collectionName, ename) {

        validateString(collectionName, "collectionName");
        validateString(ename, "ename");

        const col = createCollection(collectionName);
        let employees = [];

        try {
            const docCursor = col.find().filter({ "ename": ename }).getCursor();
            let doc;
            while ((doc = docCursor.getNext())) {
                employees.push(doc.getContent());
            }

        } catch (err) {
            throw `no employee found in ${collectionName} with ename ${ename}`;
        }

        return employees;
    }
    ```

    The function returns an array of employees matching the search criteria, the employee's name. In our scenario there aren't any duplicate `enames` stored in the collection, the function can therefore return an array with a maximum of 1 item. In case there aren't any hits an empty array is returned instead.

    Let's try and find an employee using the following example:

    ```sql
    <copy>
    col result for a30
    select
        json_serialize(
            soda_demo_pkg.find_emp_by_ename('myCollection', 'JONES')
            pretty) as result;
    </copy>
    ```

    The query should return exactly 1 element:

    ```
    SQL> select
      2      json_serialize(
      3          soda_demo_pkg.find_emp_by_ename('myCollection', 'JONES')
      4          pretty) as result;

    RESULT
    ------------------------------
    [
        {
            "empno" : 7566,
            "ename" : "JONES",
            "job" : "MANAGER",
            "mgr" : 7839,
            "hiredate" : "1981-04-02",
            "sal" : 2975,
            "comm" : 0,
            "deptno" : 20
        }
    ]
    ```

4. Modify a document in a collection

    There are times when you have to modify a document in a collection. The SODA API offers a simple and convenient way to do so. The following function can be used to update an employee's salary.

    ```js
    /** 
     * Update the salary of an employee identified by empno
     * @param {string} collectionName the name of the collection
     * @param {number} empno the employee ID
     * @param {number} newSal the new salary
     * @throws will throw an error if no employee is found
     */
    export function updateEmpSalary(collectionName, empno, newSal) {

        validateString(collectionName, "collectionName");
        validateNumber(empno, "empno");
        validateNumber(newSal, "newSal");

        const col = createCollection(collectionName);

        try {
            const docCursor = col.find().filter({ "empno": empno }).getCursor();
            let doc;
            while ((doc = docCursor.getNext())) {

                let emp = doc.getContent();
                emp.sal = newSal;
                col.find().key(doc.key).replaceOne(emp);
            }

        } catch (err) {
            throw `error updating salary for empno ${empno}: ${err}`;
        }
    }
    ```

    In this step you will update JONES's salary to 3500 monetary units (JONES's `empno` is 7566). To see the effect a query is run before and after the update.

    ```sql
    <copy>
    select 
        c.data.sal 
    from 
        "myCollection" c 
    where 
        json_exists(c.data, '$?(@.empno == 7566)');

    begin
        soda_demo_pkg.update_emp_salary('myCollection', 7566, 3500);
    end;
    /

    select 
        c.data.sal 
    from 
        "myCollection" c 
    where 
        json_exists(c.data, '$?(@.empno == 7566)');
    </copy>
    ```

    You should see the following output when executing the code:

    ```
    SQL> select
      2      c.data.sal
      3  from
      4      "myCollection" c
      5  where
      6      json_exists(c.data, '$?(@.empno == 7566)');
  
    SAL
    --------------------------------------------------------------------------------
    2975

    SQL> begin
      2      soda_demo_pkg.update_emp_salary('myCollection', 7566, 3500);
      3  end;
      4  /

    PL/SQL procedure successfully completed.

    SQL> select
      2      c.data.sal
      3  from
      4      "myCollection" c
      5  where
      6      json_exists(c.data, '$?(@.empno == 7566)');

    SAL
    --------------------------------------------------------------------------------
    3500
    ```

    As you can see the update completed successfully.

5. Delete a document from a collection

    Just like records in relational tables sometimes you have to delete documents from a collection. This example demonstrates how to do so.

    ```js
    /**
     * Delete a document from a collection
     * @param {string} collectionName the name of the collection
     * @param {number} empno the employee ID
     * @throws error in case the document could not be deleted
     */
    export function deleteDocument(collectionName, empno) {

        validateString(collectionName, "collectionName");
        validateNumber(empno, "empno");
        
        // open the collection
        const col = createCollection(collectionName);

        // find the document 
        const result = col.find().filter({ "empno": empno }).remove();
        if ( result.count === 0) {
            throw `could not delete employee record (empno: ${empno})`;
        }
    }
    ```

    You can test the deletion of a document using the following code snippet:

    ```sql
    <copy>
    select 
        count(*) number_of_employees_before
    from 
        "myCollection" c;

    begin
        soda_demo_pkg.delete_document('myCollection', 7566);
    end;
    /

    select 
        count(*) number_of_employees_after
    from 
        "myCollection" c;
    </copy>
    ```

    You should see that a document has been deleted:

    ```
    SQL> select
      2      count(*) number_of_employees_before
      3  from
      4      "myCollection" c;

    NUMBER_OF_EMPLOYEES_BEFORE
    --------------------------
                            2

    SQL> begin
      2      soda_demo_pkg.delete_document('myCollection', 7566);
      3  end;
      4  /

    PL/SQL procedure successfully completed.

    SQL> select
      2      count(*) number_of_employees_after
      3  from
      4      "myCollection" c;

    NUMBER_OF_EMPLOYEES_AFTER
    -------------------------
                            1
    ```

6. Clean up by dropping the collection

    Dropping a collection is like dropping a table in the relational world- it can be potentially dangerous! Only drop a collection if you are absolutely sure you don't need it anymore. Here is the except from the JavaScript module demonstrating how to drop a collection:

    ```js
    /** 
     * Drop a collection in preparation of cleaning up
     * @param {string} collectionName the name of the collection to be dropped
     */
    export function dropCollection(collectionName) {

        validateString(collectionName, "collectionName");

        // verify if the collection to be dropped exists in the first place
        const col = soda.openCollection(collectionName);
        if (col === null) {
            throw `The collection (${collectionName}) you asked to be dropped does not exist`;
        }

        // drop the collection to complete this lab. In other scenarios
        // this might be a dangerous operation since the collection and
        // all its documents are removed permanently
        col.drop();
    }
    ```

    Let's clean up after this lab by dropping the collection:

    ```sql
    <copy>
    begin
        commit;
        soda_demo_pkg.drop_collection('myCollection');
    end;
    /
    </copy>
    ```

    You should see that the PL/SQL procedure has been completed successfully. The underlying table has been dropped, too.

You many now proceed to the next lab.

## Learn More

- [JavaScript Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/mlejs/soda-collections-in-mle-js.html#GUID-58C2BBD9-837D-41CD-A9EF-4EA062F1E1E2) describes the SODA API in more detail
- [Simple Oracle Document Access (SODA) landing page](https://docs.oracle.com/en/database/oracle/simple-oracle-document-access/)

## Acknowledgements

- **Author** - Martin Bach, Senior Principal Product Manager, ST & Database Development
- **Contributors** -  Lucas Braun, Sarah Hirschfeld
- **Last Updated By/Date** - Martin Bach 02-MAY-2023
