# Dynamic caching

## Introduction

In this lab, you will learn the difference between static and dynamic cache groups.

**Estimated Lab Time:** 5 minutes

So far, the cache groups that you have been working with are what are known as static cache groups. With static cache groups, you pre-load the cache group with the data that you wish to cache and then the TimesTen autorefresh mechanism ensures that any inserts, updates or deletes that occur on Oracle are captured and propagated to the cache to refresh the cached tables.

Static cache groups are optimal when the data set that needs to be cached is well defined and will fit into the memory allocated to the TimesTen cache. Sometimes, however, the data set may be so large that you cannot afford to allocate enough memory to cache it all and it may not be possible to predict in advance which rows the application will access in any given time period. In such cases using a dynamic cache group may be a better option.

With a dynamic cache group, data is automatically faulted into the cache on a ‘cache miss’. Once in the cache the data remains there and is able to satisfy future read requests. The data in the cache is maintained in sync with Oracle using the TimesTen autorefresh mechanism. To avoid the cache memory completely filling up over time as new data is faulted in, TimesTen provides a choice of two ageing mechanisms (LRU and lifetime) which can be used to automatically discard ‘old’ data from the cache.

Only certain kinds of queries qualify for dynamic load; typically the query must include a full key equality condition on either a primary or foreign key on one of the cache group tables. If the result of executing the query in TimesTen is ‘no rows found’ then instead of returning this answer to the application TimesTen first tries to execute the same query in Oracle. If that query returns something in Oracle, then the rows making up the cache instance (the parent row and all related child rows down through the hierarchy) are retrieved and inserted into the cache tables in TimesTen. Then the query is executed against the cache and the answer is returned to the application.

As a result, a cache miss is significantly more expensive than a cache hit since the rows have to be fetched from Oracle and inserted into TimesTen. Therefore dynamic caching only brings performance benefits if there is considerable reuse of rows once they have been faulted into the cache.

### Objectives

- Create a dynamic readonly cache group.
- Run some queries that trigger cache misses and cache hits.
- Observe the behaviour and how it differs from a static cache group.

### Prerequisites

This lab assumes that you have:

- Completed all the previous labs in this workshop, in sequence.

## Task 1: Connect to the environment

If you do not already have an active terminal session, connect to the OCI compute instance and open a terminal session, as the user **oracle**. In that terminal session, connect to the TimesTen host (tthost1) using ssh.

## Task 2: Create a DYNAMIC READONLY cache group

Use ttIsql to connect to the cache as the APPUSER user:

```
<copy>
ttIsql "DSN=sampledb;UID=appuser;PWD=appuser;OraclePWD=appuser"
</copy>
```

```
Copyright (c) 1996, 2022, Oracle and/or its affiliates. All rights reserved.
Type ? or "help" for help, type "exit" to quit ttIsql.

connect "DSN=sampledb;UID=appuser;PWD=********;OraclePWD=********";
Connection successful: DSN=sampledb;UID=appuser;DataStore=/tt/db/sampledb;DatabaseCharacterSet=AL32UTF8;ConnectionCharacterSet=AL32UTF8;LogFileSize=256;LogBufMB=256;PermSize=1024;TempSize=256;OracleNetServiceName=ORCLPDB1;
(Default setting AutoCommit=1)
Command> 
```
Create a dynamic readonly cache group encompassing the **PARENT** and **CHILD** tables, which are related through a foreign key:

```
<copy>
CREATE DYNAMIC READONLY CACHE GROUP appuser.cg_parent_child 
AUTOREFRESH MODE INCREMENTAL INTERVAL 2 SECONDS 
STATE ON 
FROM 
parent 
( parent_id          NUMBER(8) NOT NULL
, parent_c1          VARCHAR2(20 BYTE)
, PRIMARY KEY (parent_id)
),
child 
( child_id           NUMBER(8) NOT NULL
, parent_id          NUMBER(8) NOT NULL
, child_c1           VARCHAR2(20 BYTE)
, PRIMARY KEY (child_id)
, FOREIGN KEY (parent_id)
  REFERENCES appuser.parent (parent_id)
) 
AGING LRU ON;
</copy>
```

Display information about the cache group:

```
<copy>
cachegroups cg_parent_child;
</copy>
```

```
Cache Group APPUSER.CG_PARENT_CHILD:

  Cache Group Type: Read Only (Dynamic)
  Autorefresh: Yes
  Autorefresh Mode: Incremental
  Autorefresh State: On
  Autorefresh Interval: 2 Seconds
  Autorefresh Status: ok
  Aging: LRU on

  Root Table: APPUSER.PARENT
  Table Type: Read Only


  Child Table: APPUSER.CHILD
  Table Type: Read Only
```

Note that in this case the Autorefresh state is immediately set to _on_.

```
Autorefresh State: On
```

This is because you do not need to perform an initial load for a dynamic cache group (though it is possible to do so).

Check the state of the tables:

```
<copy>
select count(*) from appuser.parent;
</copy>
```

```
< 0 >
1 row found.
```

```
<copy>
select count(*) from appuser.child;
</copy>
```

```
< 0 >
1 row found.
```

There is no data in the cached tables.

## Task 3: Run some queries and observe the behaviour

First, run a query that references the root table's (PARENT table) primary key:

```
<copy>
select * from parent where parent_id = 4;
</copy>
```

```
< 4, Parent row 4 >
1 row found.
```

Even though the table was empty, the query returns a result! Now examine the contents of both tables again:

```
<copy>
select * from parent;
</copy>
```

```
< 4, Parent row 4 >
1 row found.
```

```
<copy>
select * from child;
</copy>
```

```
< 4, 4, P4,C4 >
< 5, 4, P4,C5 >
< 6, 4, P4,C6 >
3 rows found.
```

Observe that the row that was queried now exists in the PARENT table and the three related rows also exist in the CHILD table. TimesTen performed a dynamic load operation for the cache instance. 

Now that these rows now exist in the cache they will satisfy future read requests. If any of these rows are modified in Oracle, the TimesTen autorefresh mechanism will capture the changes and propagate them to the cache.

Let’s try something a little more sophisticated. Query a row in the CHILD table with a join back to the PARENT table:

```
<copy>
select p.parent_id, p.parent_c1, c.child_c1 from parent p, child c where c.child_id = 2 and p.parent_id = c.parent_id;
</copy>
```

```
< 1, Parent row 1, P1,C2 >
1 row found.
```

Now check again to see the contents of both tables.

```
<copy>
select * from parent;
</copy>
```

```
< 1, Parent row 1 >
< 4, Parent row 4 >
2 rows found.
```

```
<copy>
select * from child;
</copy>
```

```
< 1, 1, P1,C1 >
< 2, 1, P1,C2 >
< 4, 4, P4,C4 >
< 5, 4, P4,C5 >
< 6, 4, P4,C6 >
5 rows found.
```

Here you queried against a specific child_id value and joined back to the parent table. TimesTen figured things out and dynamically loaded all the expected cache instances. Dynamic caching can be very useful for appropriate use cases.

Disconnect from the cache.

```
<copy>
quit
</copy>
```

```
Rolling back active transaction...
Disconnecting...
Done.
```

You can now *proceed to the next lab*. Keep your primary terminal session open for use in the next lab.

## Acknowledgements

* **Author** - Chris Jenkins, Senior Director, TimesTen Product Management
* **Contributors** -  Doug Hood & Jenny Bloom, TimesTen Product Management
* **Last Updated By/Date** - Chris Jenkins, July 2022

