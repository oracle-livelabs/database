# Database Request Routing to Shard

## Introduction
In Oracle Sharding, database query and DML requests are routed to the shards in two main ways, depending on whether a sharding key is supplied with the request.

You can connect directly to the shards to execute queries and DML by providing a sharding key with the database request. Direct routing is the preferred way of accessing shards to achieve better performance, among other benefits.

Queries that need data from multiple shards, and queries that do not specify a sharding key, cannot be routed directly by the application. Those queries require a proxy to route requests between the application and the shards. Proxy routing is handled by the shard catalog query coordinator.

*Estimated Lab Time:* 20 minutes.

Watch the video below for a quick walk through of the lab.
[Database Request Rout to Shard](videohub:1_yxecewxc)

### Objectives

In this lab, you will perform the following steps:
- Routing Queries and DMLs Directly to Shards
- Routing Queries and DMLs by Proxy
- Multi-Shard Queries.

### Prerequisites
This lab assumes you have:
- An Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment
    - Lab: Oracle Shard Database Deployment
    - Lab: Setup a Non-Sharded Application.
    - Lab: Migrate Application to Sharded Database

## Task 1: Routing Queries and DMLs Directly to Shards

1. Login to the catalog host, switch to oracle user.

    ```
    $ <copy>ssh -i labkey opc@xxx.xxx.xxx.xxx</copy>
    Last login: Mon Nov 30 03:06:29 2020 from 202.45.129.206
    -bash: warning: setlocale: LC_CTYPE: cannot change locale (UTF-8): No such file or directory
    [opc@cata ~]$ <copy>sudo su - oracle</copy>
    Last login: Mon Nov 30 03:06:34 GMT 2020 on pts/0
    [oracle@cata ~]$
    ```



3. For single-shard queries, direct routing to a shard with a given sharding_key.

    ```
    [oracle@cata ~]$ <copy>sqlplus app_schema/app_schema@'(description=(address=(protocol=tcp)(host=cata)(port=1522))(connect_data=(service_name=oltp_rw_srvc.orasdb.oradbcloud)(region=region1)(SHARDING_KEY=tom.edwards@y.bogus)))'</copy>

    SQL*Plus: Release 19.0.0.0.0 - Production on Mon Nov 30 04:24:10 2020
    Version 19.3.0.0.0

    Copyright (c) 1982, 2019, Oracle.  All rights reserved.

    Last Successful login time: Mon Nov 30 2020 03:19:10 +00:00

    Connected to:
    Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.14.0.0.0

    SQL>
    ```



4. Insert a record and commit.

    ```
    SQL> <copy>INSERT INTO Customers (CustId, FirstName, LastName, CustProfile, Class, Geo, Passwd) VALUES ('tom.edwards@y.bogus', 'Tom', 'Edwards', NULL, 'Gold', 'east', hextoraw('8d1c00e'));</copy>

    1 row created.

    SQL> <copy>commit;</copy>

    Commit complete.

    SQL>
    ```



5. Check current connected shard database.

    ```
    SQL> <copy>select db_unique_name from v$database;</copy>

    DB_UNIQUE_NAME
    ------------------------------
    shd1

    SQL>
    ```



6. Select from the customer table. You can see there is one record which you just insert in the table.

    ```
    SQL> <copy>select * from customers where custid like '%y.bogus';</copy>

    CUSTID
    ------------------------------------------------------------
    FIRSTNAME
    ------------------------------------------------------------
    LASTNAME						     CLASS	GEO
    ------------------------------------------------------------ ---------- --------
    CUSTPROFILE
    --------------------------------------------------------------------------------
    PASSWD
    --------------------------------------------------------------------------------
    tom.edwards@y.bogus
    Tom
    Edwards 						     Gold	east

    CUSTID
    ------------------------------------------------------------
    FIRSTNAME
    ------------------------------------------------------------
    LASTNAME						     CLASS	GEO
    ------------------------------------------------------------ ---------- --------
    CUSTPROFILE
    --------------------------------------------------------------------------------
    PASSWD
    --------------------------------------------------------------------------------

    08D1C00E


    SQL>
    ```



7. Exit from the sqlplus.

    ```
    SQL> <copy>exit</copy>
    Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.14.0.0.0
    [oracle@cata ~]$
    ```



8. Connect to a shard with another shard key.

    ```
    [oracle@cata ~]$ <copy>sqlplus app_schema/app_schema@'(description=(address=(protocol=tcp)(host=cata)(port=1522))(connect_data=(service_name=oltp_rw_srvc.orasdb.oradbcloud)(region=region1)(SHARDING_KEY=james.parker@y.bogus)))'</copy>

    SQL*Plus: Release 19.0.0.0.0 - Production on Mon Nov 30 04:36:45 2020
    Version 19.3.0.0.0

    Copyright (c) 1982, 2019, Oracle.  All rights reserved.

    Last Successful login time: Mon Nov 30 2020 02:54:14 +00:00

    Connected to:
    Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.14.0.0.0

    SQL>
    ```



9. Insert another record and commit.

    ```
    SQL> <copy>INSERT INTO Customers (CustId, FirstName, LastName, CustProfile, Class, Geo, Passwd) VALUES ('james.parker@y.bogus', 'James', 'Parker', NULL, 'Gold', 'west', hextoraw('9a3b00c'));</copy>

    1 row created.

    SQL> <copy>commit;</copy>

    Commit complete.

    SQL>
    ```



10. Check current connected shard database.

    ```
    SQL> <copy>select db_unique_name from v$database;</copy>

    DB_UNIQUE_NAME
    ------------------------------
    shd2

    SQL>
    ```



11. Select from the table. You can see there is only one record in the shard2 database.

    ```
    SQL> <copy>select * from customers where custid like '%y.bogus';</copy>

    CUSTID
    ------------------------------------------------------------
    FIRSTNAME
    ------------------------------------------------------------
    LASTNAME						     CLASS	GEO
    ------------------------------------------------------------ ---------- --------
    CUSTPROFILE
    --------------------------------------------------------------------------------
    PASSWD
    --------------------------------------------------------------------------------
    james.parker@y.bogus
    James
    Parker							     Gold	west

    CUSTID
    ------------------------------------------------------------
    FIRSTNAME
    ------------------------------------------------------------
    LASTNAME						     CLASS	GEO
    ------------------------------------------------------------ ---------- --------
    CUSTPROFILE
    --------------------------------------------------------------------------------
    PASSWD
    --------------------------------------------------------------------------------

    09A3B00C


    SQL>
    ```



12. Exit from the sqlplus.

    ```
    SQL> <copy>exit</copy>
    Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.14.0.0.0
    [oracle@cata ~]$
    ```


## Task 2: Routing Queries and DMLs by Proxy

1. Connect to the shardcatalog (coordinator database) using the GDS$CATALOG service (from catalog or any shard host):

    ```
    [oracle@cata ~]$ <copy>sqlplus app_schema/app_schema@cata:1522/GDS\$CATALOG.oradbcloud</copy>

    SQL*Plus: Release 19.0.0.0.0 - Production on Mon Nov 30 04:49:23 2020
    Version 19.3.0.0.0

    Copyright (c) 1982, 2019, Oracle.  All rights reserved.

    Last Successful login time: Mon Nov 30 2020 04:49:02 +00:00

    Connected to:
    Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.14.0.0.0

    SQL>
    ```



2. Select records from customers table. You can see all the records are selected.

    ```
    SQL> <copy>select custid from customers where custid like '%y.bogus';</copy>

    CUSTID
    ------------------------------------------------------------
    tom.edwards@y.bogus
    james.parker@y.bogus

    SQL>
    ```



3. Check current connected database.

    ```
    SQL> <copy>select db_unique_name from v$database;</copy>

    DB_UNIQUE_NAME
    ------------------------------
    cata

    SQL>
    ```



4. Exit from the sqlplus

    ```

    SQL> <copy>exit</copy>
    Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.14.0.0.0
    [oracle@cata ~]$
    ```




## Task 3:  Multi-Shard Query

A multi-shard query is a query that must scan data from more than one shard, and the processing on each shard is independent of any other shard.

A multi-shard query maps to more than one shard and the coordinator might need to do some processing before sending the result to the client. The inline query block is mapped to every shard just as a remote mapped query block. The coordinator performs further aggregation and `GROUP BY` on top of the result set from all shards. The unit of execution on every shard is the inline query block.

1. Use sqlplus connect to catalog database as `app_schema` user.

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



2. Let’s run a multi-shard query which joins sharded and duplicated table (join on non sharding key) to get the fast moving products (qty sold > 10). The output that you will observe will be different (due to data load randomization).

    ```
    SQL> <copy>set echo on</copy>
    SQL> <copy>column name format a40</copy>
    SQL> <copy>explain plan for SELECT name, SUM(qty) qtysold FROM lineitems l, products p WHERE l.productid = p.productid GROUP BY name HAVING sum(qty) > 10 ORDER BY qtysold desc;</copy>

    Explained.

    SQL> <copy>set echo off</copy>
    SQL> <copy>select * from table(dbms_xplan.display());</copy>

    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------
    Plan hash value: 2044377012

    --------------------------------------------------------------------------------------------------------
    | Id  | Operation	   | Name	       | Rows  | Bytes | Cost (%CPU)| Time     | Inst	|IN-OUT|
    --------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT   |		       |     1 |    79 |     4	(50)| 00:00:01 |	|      |
    |   1 |  SORT ORDER BY	   |		       |     1 |    79 |     4	(50)| 00:00:01 |	|      |
    |*  2 |   HASH GROUP BY    |		       |     1 |    79 |     4	(50)| 00:00:01 |	|      |
    |   3 |    VIEW 	   | VW_SHARD_372F2D25 |     1 |    79 |     4	(50)| 00:00:01 |	|      |
    |   4 |     SHARD ITERATOR |		       |       |       |	    |	       |	|      |
    |   5 |      REMOTE	   |		       |       |       |	    |	       | ORA_S~ | R->S |
    --------------------------------------------------------------------------------------------------------

    Predicate Information (identified by operation id):
    ---------------------------------------------------

       2 - filter(SUM("ITEM_1")>10)

    Remote SQL Information (identified by operation id):
    ----------------------------------------------------

       5 - EXPLAIN PLAN INTO PLAN_TABLE@! FOR SELECT SUM("A2"."QTY"),"A1"."NAME" FROM "LINEITEMS"
           "A2","PRODUCTS" "A1" WHERE "A2"."PRODUCTID"="A1"."PRODUCTID" GROUP BY "A1"."NAME" /*
           coord_sql_id=g415vyfr9rg2a */  (accessing 'ORA_SHARD_POOL@ORA_MULTI_TARGET' )


    25 rows selected.

    SQL> <copy>SELECT name, SUM(qty) qtysold FROM lineitems l, products p WHERE l.productid = p.productid GROUP BY name HAVING sum(qty) > 10 ORDER BY qtysold desc;</copy>

    NAME					    QTYSOLD
    ---------------------------------------- ----------
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



5. Let’s run a multi-shard query which runs an IN subquery to get orders that includes product with `price > 900000`.

    ```
    SQL> <copy>set echo on</copy>
    SQL> <copy>column name format a20</copy>
    SQL> <copy>explain plan for SELECT COUNT(orderid) FROM orders o WHERE orderid IN (SELECT orderid FROM lineitems l, products p WHERE l.productid = p.productid AND o.custid = l.custid AND p.lastprice > 900000);</copy>

    Explained.

    SQL> <copy>set echo off</copy>
    SQL> <copy>select * from table(dbms_xplan.display());</copy>

    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------
    Plan hash value: 2403723386

    -------------------------------------------------------------------------------------------------------
    | Id  | Operation	  | Name	      | Rows  | Bytes | Cost (%CPU)| Time     | Inst   |IN-OUT|
    -------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT  |		      |     1 |    13 |     2	(0)| 00:00:01 |        |      |
    |   1 |  SORT AGGREGATE   |		      |     1 |    13 | 	   |	      |        |      |
    |   2 |   VIEW		  | VW_SHARD_72AE2D8F |     1 |    13 |     2	(0)| 00:00:01 |        |      |
    |   3 |    SHARD ITERATOR |		      |       |       | 	   |	      |        |      |
    |   4 |     REMOTE	  |		      |       |       | 	   |	      | ORA_S~ | R->S |
    -------------------------------------------------------------------------------------------------------

    Remote SQL Information (identified by operation id):
    ----------------------------------------------------

       4 - EXPLAIN PLAN INTO PLAN_TABLE@! FOR SELECT COUNT(*) FROM "ORDERS" "A1" WHERE
           "A1"."ORDERID"=ANY (SELECT "A3"."ORDERID" FROM "LINEITEMS" "A3","PRODUCTS" "A2" WHERE
           "A3"."PRODUCTID"="A2"."PRODUCTID" AND "A1"."CUSTID"="A3"."CUSTID" AND "A2"."LASTPRICE">900000)
           /* coord_sql_id=dttjqfaq1z93t */  (accessing 'ORA_SHARD_POOL@ORA_MULTI_TARGET' )


    20 rows selected.

    SQL> <copy>SELECT COUNT(orderid) FROM orders o WHERE orderid IN (SELECT orderid FROM lineitems l, products p WHERE l.productid = p.productid AND o.custid = l.custid AND p.lastprice > 900000);</copy>

    COUNT(ORDERID)
    --------------
    	 32366

    SQL>
    ```



4. Let’s run a multi-shard query that calculates customer distribution based on the number of orders placed. Please wait several minutes for the results return.

    ```
    SQL> <copy>set echo off</copy>
    SQL> <copy>column name format a40</copy>
    SQL> <copy>explain plan for SELECT ordercount, COUNT(*) as custdist
        FROM (SELECT c.custid, COUNT(orderid) ordercount
        	   FROM customers c LEFT OUTER JOIN orders o
        	   ON c.custid = o.custid AND
        	   orderdate BETWEEN sysdate-4 AND sysdate GROUP BY c.custid)
        GROUP BY ordercount
        ORDER BY custdist desc, ordercount desc;</copy>  2    3    4    5    6    7  

    Explained.

    SQL> <copy>select * from table(dbms_xplan.display());</copy>

    PLAN_TABLE_OUTPUT
    ------------------------------------------------------------------------------------------------------------------------
    Plan hash value: 313106859

    ----------------------------------------------------------------------------------------------------------
    | Id  | Operation	     | Name		 | Rows  | Bytes | Cost (%CPU)| Time	 | Inst   |IN-OUT|
    ----------------------------------------------------------------------------------------------------------
    |   0 | SELECT STATEMENT     |			 |     1 |    13 |     5  (20)| 00:00:01 |	  |	 |
    |   1 |  SORT ORDER BY	     |			 |     1 |    13 |     5  (20)| 00:00:01 |	  |	 |
    |   2 |   HASH GROUP BY      |			 |     1 |    13 |     5  (20)| 00:00:01 |	  |	 |
    |   3 |    VIEW 	     |			 |     1 |    13 |     5  (20)| 00:00:01 |	  |	 |
    |   4 |     HASH GROUP BY    |			 |     1 |    45 |     5  (20)| 00:00:01 |	  |	 |
    |   5 |      VIEW	     | VW_SHARD_28C476E6 |     1 |    45 |     5  (20)| 00:00:01 |	  |	 |
    |   6 |       SHARD ITERATOR |			 |	 |	 |	      | 	 |	  |	 |
    |   7 |        REMOTE	     |			 |	 |	 |	      | 	 | ORA_S~ | R->S |
    ----------------------------------------------------------------------------------------------------------

    Remote SQL Information (identified by operation id):
    ----------------------------------------------------

       7 - EXPLAIN PLAN INTO PLAN_TABLE@! FOR SELECT COUNT("A1"."ORDERID"),"A2"."CUSTID" FROM
           "CUSTOMERS" "A2","ORDERS" "A1" WHERE "A2"."CUSTID"="A1"."CUSTID"(+) AND
           "A1"."ORDERDATE"(+)>=CAST(SYSDATE@!-4 AS TIMESTAMP) AND "A1"."ORDERDATE"(+)<=CAST(SYSDATE@! AS
           TIMESTAMP) GROUP BY "A2"."CUSTID" /* coord_sql_id=92fs7p19a7pfy */  (accessing
           'ORA_SHARD_POOL@ORA_MULTI_TARGET' )


    Note
    -----
       - dynamic statistics used: dynamic sampling (level=2)

    28 rows selected.

    SQL> <copy>SELECT ordercount, COUNT(*) as custdist
        FROM (SELECT c.custid, COUNT(orderid) ordercount
        	   FROM customers c LEFT OUTER JOIN orders o
        	   ON c.custid = o.custid AND
        	   orderdate BETWEEN sysdate-4 AND sysdate GROUP BY c.custid)
        GROUP BY ordercount
        ORDER BY custdist desc, ordercount desc;</copy>  2    3    4    5    6    7  

    ORDERCOUNT   CUSTDIST
    ---------- ----------
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



7. Exit the sqlplus.

    ```
    SQL> <copy>exit</copy>
    Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.14.0.0.0
    [oracle@cata ~]$
    ```



You may now proceed to the next lab.


## Acknowledgements
* **Author** - Minqiao Wang, DB Product Management, Dec 2020
* **Last Updated By/Date** - Andres Quintana, April 2022
