# Operational Property Graphs Example with SQL/PGQ in 23c

## Introduction

In this lab you will query the newly create graph (that is, `bank_graph`) in SQL paragraphs.

Estimated Time: 15 minutes.

Watch the video below for a quick walk through of the lab.

<!-- update video link. Previous iteration: [](youtube:XnE1yw2k5IU) -->

### Objectives
Learn how to:
- Use SQL to query, analyze, and visualize a graph.

### Prerequisites
This lab assumes:
- The graph user and graph bank_graph exists
- You're in SQL Developer and have logged into the database


### Tables are
| Name | Null? | Type |
| ------- |:--------:| --------------:|
| ID | NOT NULL | NUMBER|
| NAME |  | VARCHAR2(4000) |
| BALANCE |  | NUMBER |
{: title="BANK_ACCOUNTS"}

| Name | Null? | Type |
| ------- |:--------:| --------------:|
| TXN_ID | NOT NULL | NUMBER|
| SRC\_ACCT\_ID |  | NUMBER |
| DST\_ACCT\_ID |  | NUMBER |
| DESCRIPTION |  | VARCHAR2(4000) |
| AMOUNT |  | NUMBER |
{: title="BANK_TRANSFERS"}
## Task 1 : Define a graph view on these tables
​
1. Go back to your SQL Developer window and click on the tab named hol23c\_freepdb1, not the CreateKeys.sql tab.
​

    <!-- ​REPLACE SCREENSHOT BELOW AND DELETE THIS COMMENT  -->
    ![Open hol23c tab](images/sql-hol23-tab.png)
​
​
2. Use the following SQL statement to create a property graph called BANK\_GRAPH using the BANK\_ACCOUNTS table as the vertices and the BANK_TRANSFERS table as edges. 
    ```
    <copy>
    CREATE PROPERTY GRAPH BANK_GRAPH 
    VERTEX TABLES (
        BANK_ACCOUNTS
        KEY (ID)
        PROPERTIES (ID, Name, Balance) 
    )
    EDGE TABLES (
        BANK_TRANSFERS 
        KEY (TXN_ID) 
        SOURCE KEY (src_acct_id) REFERENCES BANK_ACCOUNTS(ID)
        DESTINATION KEY (dst_acct_id) REFERENCES BANK_ACCOUNTS(ID)
        PROPERTIES (src_acct_id, dst_acct_id, amount)
    );
    </copy>
    ```
    <!-- ​REPLACE SCREENSHOT BELOW AND DELETE THIS COMMENT  -->
    ![Create graph using Accounts and Transfers table](images/create-graph.png)
​
​
3. You can check the metadata views to list the graph, its elements, their labels, and their properties. 
​
    First we will be listing the graphs, but there is only one property graph we have created, so BANK\_GRAPH will be the only entry.
    ```
    <copy>
    SELECT * FROM user_property_graphs;
    </copy>
    ```
​
    <!-- ​REPLACE SCREENSHOT BELOW AND DELETE THIS COMMENT  -->
    ![Listing bank graph](images/bank-graph.png)
​
4. This query shows the DDL for the BANK\_GRAPH graph. 
​
    ```
    <copy>
    SELECT dbms_metadata.get_ddl('PROPERTY_GRAPH', 'BANK_GRAPH') from dual;
    </copy>
    ```

    <!-- ​REPLACE SCREENSHOT BELOW AND DELETE THIS COMMENT  -->
    ![DDL bank graph](images/ddl-bankgraph.png)
​
5. Here you can look at the elements of the BANK\_GRAPH graph (i.e. its vertices and edges).
    ```
    <copy>
    SELECT * FROM user_pg_elements WHERE graph_name='BANK_GRAPH';
    </copy>
    ```
​
    <!-- ​REPLACE SCREENSHOT BELOW AND DELETE THIS COMMENT  -->
    ![Elements of bank graph](images/elements-bank-transfers.png)
​
6. Get the properties associated with the labels.
    ```
    <copy>
    SELECT * FROM user_pg_label_properties WHERE graph_name='BANK_GRAPH';
    </copy>
    ```
​
    <!-- ​REPLACE SCREENSHOT BELOW AND DELETE THIS COMMENT  -->
    ![Properties for labels](images/property-labels.png)

​
## Task 2 : Query the bank_graph
​
In this task we will be running queries using SQL/PGQ that will involve the GRAPH\_TABLE operator, the MATCH clause, and the COLUMNS clause. The GRAPH\_TABLE operator enables you to query the property graph by specifying a graph pattern to look for and return the results as a set of columns. The MATCH clause will let you specify the graph patterns, and the COLUMN clause will contain the query output columns. Everything else is standard SQL.
​
A common query in analyzing money flows is to see if there are a sequence of transfers that connect one source account to a destination account. We'll be demonstrating that sequence of transfers in standard SQL.
​
1. Let's start by finding the top 10 accounts which have the most incoming transfers. 
    ```
    <copy>
    SELECT acct_id, COUNT(1) AS Num_Transfers 
    FROM graph_table ( BANK_GRAPH 
        MATCH (src) - [IS BANK_TRANSFERS] -> (dst) 
        COLUMNS ( dst.id AS acct_id )
    ) GROUP BY acct_id ORDER BY Num_Transfers DESC FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```
    <!-- ​REPLACE SCREENSHOT BELOW AND DELETE THIS COMMENT  -->
    ![Most incoming transfers accounts](images/incoming-transfers.png)
​
    We see that accounts **934** and **387** are the high ones on the list. 
    
2.  Then, let's find the top 10 accounts in the middle of a 2-hop chain of transfers.
    ```
    <copy>
    SELECT acct_id, COUNT(1) AS Num_In_Middle 
    FROM graph_table ( BANK_GRAPH 
        MATCH (src) - [IS BANK_TRANSFERS] -> (via) - [IS BANK_TRANSFERS] -> (dst) 
        COLUMNS ( via.id AS acct_id )
    ) GROUP BY acct_id ORDER BY Num_In_Middle DESC FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```
    <!-- ​REPLACE SCREENSHOT BELOW AND DELETE THIS COMMENT  -->
    ![Top 10 accounts](images/top-ten-accounts.png)
​
3. Next, let's list accounts that received a transfer from account 387 in 1, 2, or 3 hops.
    ```
    <copy>
    SELECT account_id1, account_id2 
    FROM graph_table(BANK_GRAPH
        MATCH (v1)-[IS BANK_TRANSFERS]->{1,3}(v2) 
        WHERE v1.id = 387 
        COLUMNS (v1.id AS account_id1, v2.id AS account_id2)
    );
    </copy>
    ```
    <!-- ​REPLACE SCREENSHOT BELOW  AND DELETE THIS COMMENT -->
    ![Accounts that received a transfer](images/transfer-accounts.png)
​
4. Check if there are any 3-hop (triangles) transfers that start and end at the same account.
    ```
    <copy>
    SELECT acct_id, COUNT(1) AS Num_Triangles 
    FROM graph_table (BANK_GRAPH 
        MATCH (src) - []->{3} (src) 
        COLUMNS (src.id AS acct_id) 
    ) GROUP BY acct_id ORDER BY Num_Triangles DESC;
    </copy>
    ```
    <!-- ​REPLACE SCREENSHOT BELOW AND DELETE THIS COMMENT  -->
    ![3hop triangle transfers](images/triangles-transfer.png) 
​
5. We can use the same query but modify the number of hops to check if there are any 4-hop transfers that start and end at the same account. 
​
    ```
    <copy>
    SELECT acct_id, COUNT(1) AS Num_4hop_Chains 
    FROM graph_table (BANK_GRAPH 
        MATCH (src) - []->{4} (src) 
        COLUMNS (src.id AS acct_id) 
    ) GROUP BY acct_id ORDER BY Num_4hop_Chains DESC;
    </copy>
    ```
​
    <!-- ​REPLACE SCREENSHOT BELOW AND DELETE THIS COMMENT -->
    ![4hop transfers](images/four-hop-transfer.png)
​
6. Here, we are check if there are any 5-hop transfers that start and end at the same account by just changing the number of hops to 5. 
    ```
    <copy>
   SELECT acct_id, COUNT(1) AS Num_5hop_Chains 
    FROM graph_table (BANK_GRAPH 
        MATCH (src) - []->{5} (src) 
        COLUMNS (src.id AS acct_id) 
    ) GROUP BY acct_id ORDER BY Num_5hop_Chains DESC;
    </copy>
    ```

    <!-- ​REPLACE SCREENSHOT BELOW AND DELETE THIS COMMENT  -->
    ![5hop transfers](images/five-hop-transfer.png)
    
7.  List some (any 10) accounts which had a 3 to 5 hop circular payment chain. 
    ```
    <copy>
    SELECT DISTINCT(account_id) 
    FROM GRAPH_TABLE(BANK_GRAPH
       MATCH (v1)-[IS BANK_TRANSFERS]->{3,5}(v1)
        COLUMNS (v1.id AS account_id)  
    ) FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```
​
    <!-- ​REPLACE SCREENSHOT BELOW AND DELETE THIS COMMENT  -->
    ![How many accounts transferred money](images/money-transfer-accounts.png)
​
8.  Let's list the top 10 accounts by number of 3 to 5 hops that have circular payment chains in descending order. 
    ```
    <copy>
    SELECT DISTINCT(account_id), COUNT(1) AS Num_Cycles 
    FROM graph_table(BANK_GRAPH
        MATCH (v1)-[IS BANK_TRANSFERS]->{3, 5}(v1) 
        COLUMNS (v1.id AS account_id) 
    ) GROUP BY account_id ORDER BY Num_Cycles DESC FETCH FIRST 10 ROWS ONLY;
    </copy>
    ```
    As you can see, though we are looking for longer lengths on the chain, there is no additional lines of code that need to be written. In here we see that accounts **135**, **934** and **387** are the ones involved in most of the 3 to 5 hops circular payment chains. 
​
    <!-- ​REPLACE SCREENSHOT BELOW AND DELETE THIS COMMENT  -->
    ![Account queries](images/query-accounts.png)
​
​
9. Now, let's insert some more data into BANK\_TRANSFERS. We will see that when rows are inserted in to the BANK\_TRANSFERS table, the BANK_GRAPH is updated with corresponding edges.
    ```
    <copy>
    INSERT INTO bank_transfers VALUES (5002, 39, 934, null, 1000);
    INSERT INTO bank_transfers VALUES (5003, 39, 135, null, 1000);
    INSERT INTO bank_transfers VALUES (5004, 40, 135, null, 1000);
    INSERT INTO bank_transfers VALUES (5005, 41, 135, null, 1000);
    INSERT INTO bank_transfers VALUES (5006, 38, 135, null, 1000);
    INSERT INTO bank_transfers VALUES (5007, 37, 135, null, 1000);
    </copy>
    ```
    <!-- **ADD SCREENSHOT** 
        ![](images/)
    -->
​
10. Re-run the top 10 query to see if there are any changes to the top 10 after adding new values in BANK\_TRANSFER.
    ```
    <copy>
    SELECT acct_id, count(1) AS Num_Transfers 
    FROM GRAPH_TABLE ( bank_graph 
    MATCH (src) - [is BANK_TRANSFERS] -> (dst) 
    COLUMNS ( dst.id as acct_id )
    ) GROUP BY acct_id ORDER BY Num_Transfers DESC fetch first 10 rows only;
    </copy>
    ```
    <!-- **ADD SCREENSHOT** 
        ![](images/)
    -->
​
    Notice how accounts **135**, and **934** are now ahead of **387**.
​
11. Let's insert more transfers which create 3 more circular payment chains. We will be adding transfers from accounts **599**, **982**, and **407** into account **39**.
    ```
    <copy>
    INSERT INTO bank_transfers VALUES (5008, 559, 39, null, 1000);
    INSERT INTO bank_transfers VALUES (5009, 982, 39, null, 1000);
    INSERT INTO bank_transfers VALUES (5010, 407, 39, null, 1000);
    </copy>
    ```
    <!-- **ADD SCREENSHOT** 
        ![](images/)
    -->
​
12. Now let's re-run the following query since we've added more circular payment chains.
    ```
    <copy>
    SELECT count(1) Num_4Hop_Cycles 
    FROM graph_table(bank_graph 
    MATCH (s)-[]->{4}(s) 
    WHERE s.id = 39
    COLUMNS (1 as dummy) );
    </copy>
    ```
    <!-- **ADD SCREENSHOT** 
        ![](images/)
    -->
​
    Notice how we now have five 4-hop circular payment chains becasue the edges of BANK\_GRAPH were updated when additional transfers were added to BANK\_TRANSFERS. 
​
13. Let's delete the new inserted rows.
    ```
    <copy>
    DELETE FROM bank_transfers 
    WHERE txn_id IN (5002, 5003, 5004, 5005, 5006, 5007, 5008, 5009, 5010);
    </copy>
    ```
    <!-- **ADD SCREENSHOT** 
        ![](images/)
    -->

14. You have now completed this lab.

## Learn More
* [Oracle Property Graph](https://docs.oracle.com/en/database/oracle/property-graph/index.html)
* [SQL Property Graph syntax in Oracle Database 23c Free - Developer Release](https://docs.oracle.com/en/database/oracle/property-graph/23.1/spgdg/sql-ddl-statements-property-graphs.html#GUID-6EEB2B99-C84E-449E-92DE-89A5BBB5C96E)

## Acknowledgements

- **Author** - Kaylien Phan, Thea Lazarova, William Masdon
- **Contributors** - Melliyal Annamalai, Jayant Sharma, Ramu Murakami Gutierrez, Rahul Tasker
- **Last Updated By/Date** - Kaylien Phan, Thea Lazarova
