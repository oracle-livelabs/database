# Cross Shard Query

## Introduction

In a sharded database, a database client connects to the shard using a connection string with a sharding key value. If a sharding key is specified then all requests submitted in that session will be routed to the shard corresponding to the key value. They are referred to as Single Shard Queries (SSQ).

If the sharding key cannot be provided as part of database connection string, then a session will have to be established on the coordinator database (catadb). All the queries submitted from such sessions can in principle touch data on any set of shard databases. They are referred to as Cross Shard Queries (CSQ). 

At a high level the coordinator rewrites each incoming query, Q, into a distributive form composed of two queries, CQ and SQ, where SQ (Shard Query) is the portion of Q that executes on each participating shard and CQ (Coordinator Query) is the portion that executes on the coordinator shard. 

Estimated Lab Time: 20 minutes.

### Objectives

In this lab, you will perform the following steps:
- Run Cross Shard Query from the demo sharded tables.

### Prerequisites

This lab assumes you have already completed the following:
- Sharded Database Deployment
- Create Demo App Schema
- Custom Demo Data Loading

## Task 1: Prepare the sample rows
1. Login to the catalog database host, switch to oracle user, and make sure you are in the cata environment.

    ```
    $ ssh -i labkey opc@152.67.196.50
    Last login: Sun Nov 29 01:26:28 2020 from 59.66.120.23
    -bash: warning: setlocale: LC_CTYPE: cannot change locale (UTF-8): No such file or  directory 
    [opc@cata ~]$ sudo su - oracle
    Last login: Sun Nov 29 02:49:51 GMT 2020 on pts/0  
    [oracle@cata ~]$ . ./cata.sh 
    [oracle@cata ~]$ 
    ```

   

2. Use sqlplus connect as `app_schema` user.

    ```
    [oracle@cata ~]$ <copy>sqlplus app_schema/app_schema@catapdb</copy>
     
    SQL*Plus: Release 19.0.0.0.0 - Production on Mon Nov 30 09:23:44 2020
    Version 19.14.0.0.0
     
    Copyright (c) 1982, 2020, Oracle.  All rights reserved.
     
    Last Successful login time: Mon Nov 30 2020 09:23:02 +00:00
     
    Connected to:
    Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.14.0.0.0
     
    SQL> 
    ```

   

3. Insert some sample rows into the tables, and commit.  
    ```
    SQL> INSERT INTO Customers (CustId, FirstName, LastName, CustProfile, Class, Geo, Passwd) VALUES ('scott.tiger@x.bogus', 'Scott', 'Tiger', NULL, 'free', 'west', hextora ('7d1b00f'));
    
    1 row created.
    
    SQL> INSERT INTO Customers (CustId, FirstName, LastName, CustProfile, Class, Geo, Passwd) VALUES ('may.parker@x.bogus', 'May', 'Parker', NULL, 'Gold', 'east', hextora   ('8d1c00e'));
    
    1 row created.
    
    SQL> commit;
    
    Commit complete.
    
    SQL> 
    ```

   
## Task 2: Cross Shard Query
1. Now, let’s run a Cross Shard Query which does a SELECT with ORDER BY query accessing multiple shards but not all shards.   
	 ```
    SQL> set termout on
    SQL> set linesize 120 pagesize 200
    SQL> set echo on
    SQL> column firstname format a20
    SQL> column lastname format a20
    SQL> explain plan for SELECT FirstName,LastName, geo, class FROM Customers WHERE CustId   in ('scott.Tiger@x.bogus', 'may.parker@x.bogus') AND class != 'free' ORDER BY geo,  class;
    
    Explained.
    
    SQL> set echo off
    SQL> select * from table(dbms_xplan.display());
    
    PLAN_TABLE_OUTPUT
    ---------------------------------------------------------------------------------------   --------------------------------
    Plan hash value: 1622328711
    
    ---------------------------------------------------------------------------------------   ---------------
    | Id  | Operation	  | Name	      | Rows  | Bytes | Cost (%CPU)| Time     | Inst     IN-OUT|
    ---------------------------------------------------------------------------------------   ---------------
    |   0 | SELECT STATEMENT  |		      |     1 |    77 |     3  (34)| 00:00:01 |          |      |
    |   1 |  SORT ORDER BY	  |		      |     1 |    77 |     3  (34)| 00:00:01 |          |      |
    |   2 |   VIEW		  | VW_SHARD_5B3ACD5D |     1 |    77 |     2	(0)| 00:00:01  |        |      |
    |   3 |    SHARD ITERATOR |		      |       |       | 	   |	      |        |        |
    |   4 |     REMOTE	  |		      |       |       | 	   |	      | ORA_S~ | R->S |
    ---------------------------------------------------------------------------------------   ---------------
    
    Remote SQL Information (identified by operation id):
    ----------------------------------------------------
    
       4 - EXPLAIN PLAN INTO PLAN_TABLE@! FOR SELECT
           "A1"."FIRSTNAME","A1"."LASTNAME","A1"."GEO","A1"."CLASS" FROM "CUSTOMERS" "A1"  WHERE
           ("A1"."CUSTID"='may.parker@x.bogus' OR "A1"."CUSTID"='scott.tiger@x.bogus') AND
           "A1"."CLASS"<>'free' /* coord_sql_id=dqhthgpwkpank */  (accessing
           'ORA_SHARD_POOL@ORA_MULTI_TARGET' )
           
    21 rows selected.
    
       SQL> SELECT FirstName,LastName, geo, class FROM Customers WHERE CustId in ('scott   tiger@x.bogus', 'may.parker@x.bogus') AND class != 'free' ORDER BY geo, class;
    
       FIRSTNAME	     LASTNAME		  GEO	   CLASS
    
    -------------------- -------------------- -------- ----------
    
       May		     Parker		  east	   Gold
    
       SQL> 
	 ```

   



​    

2. Let’s run a CSQ query which joins sharded and duplicated table (join on non sharding key) to get the fast moving products (qty sold > 10). The output that you will observe will be different (due to data load randomization).

    ```
    SQL> set echo on
    SQL> column name format a40
    SQL> explain plan for SELECT name, SUM(qty) qtysold FROM lineitems l, products p WHERE l.productid = p.productid GROUP BY name HAVING sum(qty) > 10 ORDER BY qtysold desc;
    
    Explained.
    
    SQL> set echo off
    SQL> select * from table(dbms_xplan.display());
    
    PLAN_TABLE_OUTPUT
    --- ------------------------------------------------------------------------------------   --------------------------------
    Plan hash value: 2044377012
     
    --- ------------------------------------------------------------------------------------   ----------------
    | Id  | Operation	   | Name	       | Rows  | Bytes | Cost (%CPU)| Time     | Inst	   IN-OUT|
    --- ------------------------------------------------------------------------------------   ----------------
    |   0 | SELECT STATEMENT   |		       |     1 |    79 |     4	(50)| 00:00:01 |  |      |
    |   1 |  SORT ORDER BY	   |		       |     1 |    79 |     4	(50)| 00:00:01 |  |      |
    |*  2 |   HASH GROUP BY    |		       |     1 |    79 |     4	(50)| 00:00:01 |  |      |
    |   3 |    VIEW 	   | VW_SHARD_372F2D25 |     1 |    79 |     4	(50)| 00:00:01 |  |      |
    |   4 |     SHARD ITERATOR |		       |       |       |	    |	       |	|      |
    |   5 |      REMOTE	   |		       |       |       |	    |	       | ORA_S~ | R->S |
    --- ------------------------------------------------------------------------------------   ----------------
     
    Predicate Information (identified by operation id):
    ---------------------------------------------------
     
       2 - filter(SUM("ITEM_1")>10)
     
    Remote SQL Information (identified by operation id):
    ----------------------------------------------------
     
       5 - EXPLAIN PLAN INTO PLAN_TABLE@! FOR SELECT SUM("A2"."QTY"),"A1"."NAME" FROM   "LINEITEMS"
           "A2","PRODUCTS" "A1" WHERE "A2"."PRODUCTID"="A1"."PRODUCTID" GROUP BY "A1"   "NAME" /*
           coord_sql_id=g415vyfr9rg2a */  (accessing 'ORA_SHARD_POOL@ORA_MULTI_TARGET' )
     
     
    25 rows selected.
     
    SQL> SQL> SELECT name, SUM(qty) qtysold FROM lineitems l, products p WHERE l.productid = p.productid GROUP BY name HAVING sum(qty) > 10 ORDER BY qtysold desc;
     
    NAME					    QTYSOLD
    --- ------------------------------------- ----------
    Engine block				       5068
    Distributor				       4935
    Battery 				       4907
    Thermostat				       4889
    Fastener				       4841
    ......
    ......
    Starter solenoid			       2170
    Brake lining				       2167
    Gear ring				       2163
    Carburetor parts			       2162
    Valve cover				       2161
    Exhaust flange gasket			       2137
     
    469 rows selected.
     
    SQL> 
    ```

   

3. Let’s run a CSQ query which runs an IN subquery to get orders that includes product with `price > 900000`.

    ```
    SQL> set echo on
    SQL> column name format a20
    SQL> explain plan for SELECT COUNT(orderid) FROM orders o WHERE orderid IN (SELECT  orderid FROM lineitems l, products p WHERE l.productid = p.productid AND o.custid = l custid AND p.lastprice > 900000);
     
    Explained.
     
    SQL> set echo off
    SQL> select * from table(dbms_xplan.display());
     
    PLAN_TABLE_OUTPUT
    --- ------------------------------------------------------------------------------------   --------------------------------
    Plan hash value: 2403723386
     
    --- ------------------------------------------------------------------------------------   ---------------
    | Id  | Operation	  | Name	      | Rows  | Bytes | Cost (%CPU)| Time     | Inst     IN-OUT|
    --- ------------------------------------------------------------------------------------   ---------------
    |   0 | SELECT STATEMENT  |		      |     1 |    13 |     2	(0)| 00:00:01 |         |      |
    |   1 |  SORT AGGREGATE   |		      |     1 |    13 | 	   |	      |        |        |
    |   2 |   VIEW		  | VW_SHARD_72AE2D8F |     1 |    13 |     2	(0)| 00:00:01  |        |      |
    |   3 |    SHARD ITERATOR |		      |       |       | 	   |	      |        |        |
    |   4 |     REMOTE	  |		      |       |       | 	   |	      | ORA_S~ | R->S |
    --- ------------------------------------------------------------------------------------   ---------------
     
    Remote SQL Information (identified by operation id):
    ----------------------------------------------------
     
       4 - EXPLAIN PLAN INTO PLAN_TABLE@! FOR SELECT COUNT(*) FROM "ORDERS" "A1" WHERE
           "A1"."ORDERID"=ANY (SELECT "A3"."ORDERID" FROM "LINEITEMS" "A3","PRODUCTS" "A2" WHERE
           "A3"."PRODUCTID"="A2"."PRODUCTID" AND "A1"."CUSTID"="A3"."CUSTID" AND "A2"   "LASTPRICE">900000)
           /* coord_sql_id=dttjqfaq1z93t */  (accessing 'ORA_SHARD_POOL@ORA_MULTI_TARGET' )
     
     
    20 rows selected.
     
    SQL> SELECT COUNT(orderid) FROM orders o WHERE orderid IN (SELECT orderid FROM   lineitems l, products p WHERE l.productid = p.productid AND o.custid = l.custid AND p  lastprice > 900000);
     
    COUNT(ORDERID)
    --------------
    	 32366
     
    SQL> 
    ```

   

4. Let’s run a CSQ query that calculates customer distribution based on the number of orders placed. Please wait several minutes for the results return.

    ```
    SQL> set echo off
    SQL> select * from table(dbms_xplan.display());
     
    PLAN_TABLE_OUTPUT
    --- ------------------------------------------------------------------------------------   --------------------------------
    Plan hash value: 313106859
     
    --- ------------------------------------------------------------------------------------   ------------------
    | Id  | Operation	     | Name		 | Rows  | Bytes | Cost (%CPU)| Time	 | Inst     IN-OUT|
    --- ------------------------------------------------------------------------------------   ------------------
    |   0 | SELECT STATEMENT     |			 |     1 |    13 |     5  (20)| 00:00:01 |	   	 |
    |   1 |  SORT ORDER BY	     |			 |     1 |    13 |     5  (20)| 00:00:01 |	   	 |
    |   2 |   HASH GROUP BY      |			 |     1 |    13 |     5  (20)| 00:00:01 |	   	 |
    |   3 |    VIEW 	     |			 |     1 |    13 |     5  (20)| 00:00:01 |	  |	 |
    |   4 |     HASH GROUP BY    |			 |     1 |    45 |     5  (20)| 00:00:01 |	   	 |
    |   5 |      VIEW	     | VW_SHARD_28C476E6 |     1 |    45 |     5  (20)| 00:00:01  	  |	 |
    |   6 |       SHARD ITERATOR |			 |	 |	 |	      | 	 |	  |	 |
    |   7 |        REMOTE	     |			 |	 |	 |	      | 	 | ORA_S~ | R->S |
    --- ------------------------------------------------------------------------------------   ------------------
     
    Remote SQL Information (identified by operation id):
    ----------------------------------------------------
     
       7 - EXPLAIN PLAN INTO PLAN_TABLE@! FOR SELECT COUNT("A1"."ORDERID"),"A2"."CUSTID"   FROM
           "CUSTOMERS" "A2","ORDERS" "A1" WHERE "A2"."CUSTID"="A1"."CUSTID"(+) AND
           "A1"."ORDERDATE"(+)>=CAST(SYSDATE@!-4 AS TIMESTAMP) AND "A1"."ORDERDATE"(+)<=CAS   (SYSDATE@! AS
           TIMESTAMP) GROUP BY "A2"."CUSTID" /* coord_sql_id=92fs7p19a7pfy */  (accessing
           'ORA_SHARD_POOL@ORA_MULTI_TARGET' )
     
     
    Note
    -----
       - dynamic statistics used: dynamic sampling (level=2)
     
    28 rows selected.
     
    SQL> SELECT ordercount, COUNT(*) as custdist
        FROM (SELECT c.custid, COUNT(orderid) ordercount
        	   FROM customers c LEFT OUTER JOIN orders o
        	   ON c.custid = o.custid AND
        	   orderdate BETWEEN sysdate-4 AND sysdate GROUP BY c.custid)
        GROUP BY ordercount
        ORDER BY custdist desc, ordercount desc;  2    3    4    5    6    7  
     
    ORDERCOUNT   CUSTDIST
    --- ------- ----------
    	 1     132307
    	 2	51814
    	 3	22105
    	 4	10204
    	 5	 5082
    ......
    ......
    	66	    1
    	65	    1
    	63	    1
    	59	    1
     
    96 rows selected.
     
    SQL> 	 
    ```

   

5. Exit the sqlplus.

    ```
    SQL> exit
    Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.14.0.0.0
    [oracle@cata ~]$ 
    ```

   
You may now [proceed to the next lab](#next).

## Acknowledgements
* **Author** - Minqiao Wang, DB Product Management, Dec 2020 
* **Last Updated By/Date** - Minqiao Wang, Jun 2021

