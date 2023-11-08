# Learn about dynamic caching

## Introduction

In this lab, you will learn the differences between static and dynamic cache groups.

**Estimated Lab Time:** 15 minutes

The previous labs use static cache groups. With static cache groups, you pre-load the cache group with the data that you wish to cache and then the TimesTen autorefresh mechanism ensures that any inserts, updates or deletes that occur on Oracle are captured and propagated to the cache to refresh the cached tables.

Static cache groups are optimal when the data set that needs to be cached is well defined and will fit into the memory allocated to the TimesTen cache. Sometimes, however, the data set may be so large that you cannot afford to allocate enough memory to cache it all and it may not be possible to predict in advance which rows the application will access in any given time period. In such cases, using a dynamic cache group may be a better option.

With a dynamic cache group, data is automatically brought into the cache on a ‘cache miss’ (when the application requests data that exists in Oracle but is not currently present in the cache). Once in the cache, the data remains there and is able to satisfy future read requests. The data in the cache is maintained in sync with Oracle using the TimesTen autorefresh mechanism. To avoid the cache memory completely filling up over time as new data is faulted in, TimesTen provides a choice of two aging mechanisms (LRU and lifetime) which can be used to automatically discard ‘old’ data from the cache.

Only certain kinds of queries qualify for dynamic load; typically the query must include a full key equality condition on either a primary or foreign key on one of the cache group tables. If the result of executing the query in TimesTen is ‘no rows found’ then, instead of returning this answer to the application, TimesTen first tries to execute the same query in Oracle. If that query returns something in Oracle, then the rows making up the cache instance (the parent row and all related child rows down through the hierarchy) are retrieved and inserted into the cache tables in TimesTen. Then the query is re-executed against the cache and the answer is returned to the application.

As a result, a cache miss is significantly more expensive than a cache hit since the rows have to be fetched from Oracle and inserted into TimesTen. Therefore dynamic caching only brings performance benefits if there is considerable reuse of rows once they have been faulted into the cache.

### Objectives

- Create a DYNAMIC READONLY cache group.
- Run some queries that trigger cache misses and cache hits.
- Observe the behavior and how it differs from a static cache group.

### Prerequisites

This lab assumes that you:

- Have completed all the previous labs in this workshop, in sequence.
- Have an open terminal session in the workshop compute instance, either via NoVNC or SSH, and that session is logged into the TimesTen host (tthost1).

## Task 1: Create a DYNAMIC READONLY cache group

1. Use ttIsql to connect to the cache as the TTCACHEADM user:

```
<copy>
ttIsql "dsn=sampledb;uid=ttcacheadm;pwd=ttcacheadm;OraclePWD=ttcacheadm"
</copy>
```

```
Copyright (c) 1996, 2023, Oracle and/or its affiliates. All rights reserved.
Type ? or "help" for help, type "exit" to quit ttIsql.

connect "dsn=sampledb;uid=ttcacheadm;pwd=********;OraclePWD=********";
Connection successful: DSN=sampledb;UID=ttcacheadm;DataStore=/tt/db/sampledb;DatabaseCharacterSet=AL32UTF8;ConnectionCharacterSet=AL32UTF8;LogFileSize=256;LogBufMB=256;PermSize=1024;TempSize=256;OracleNetServiceName=ORCLPDB1;
(Default setting AutoCommit=1)
Command> 
```
2. Create a _dynamic_ readonly cache group encompassing the **PARENT** and **CHILD** tables, which are related through a foreign key:

```
<copy>
CREATE DYNAMIC READONLY CACHE GROUP ttcacheadm.cg_parent_child 
AUTOREFRESH MODE INCREMENTAL INTERVAL 2 SECONDS  
FROM 
appuser.parent 
( parent_id          NUMBER(8) NOT NULL
, parent_c1          VARCHAR2(20 BYTE)
, PRIMARY KEY (parent_id)
),
appuser.child 
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

3. Display information about the cache group:

```
<copy>
cachegroups cg_parent_child;
</copy>
```

```
Cache Group TTCACHEADM.CG_PARENT_CHILD:

  Cache Group Type: Read Only (Dynamic)
  Autorefresh: Yes
  Autorefresh Mode: Incremental
  Autorefresh State: Paused
  Autorefresh Interval: 2 Seconds
  Autorefresh Status: ok
  Aging: LRU on

  Root Table: APPUSER.PARENT
  Table Type: Read Only


  Child Table: APPUSER.CHILD
  Table Type: Read Only
```

Note the Autorefresh state is _Paused_. 

```
Autorefresh State: Paused
```

Unlike static cache group, you do not need to perform an initial load for a dynamic cache group (though it is possible to do so).  The Autofresh state is changed immediately from _Paused_ to _On_ after the first on-demand dynamic load operation.

4. Disconnect from the cache as TTCACHEADM user.

```
<copy>
quit
</copy>
```

```
Disconnecting...
Done.
```


## Task 2: Run some queries and observe the behavior

1. Use ttIsql to connect to the cache as the APPUSER user:
```
<copy>
ttIsql "dsn=sampledb;uid=appuser;pwd=appuser;OraclePwd=appuser"
</copy>
```
```
Copyright (c) 1996, 2023, Oracle and/or its affiliates. All rights reserved.
Type ? or "help" for help, type "exit" to quit ttIsql.

connect "dsn=sampledb;uid=appuser;pwd=********;OraclePwd=********";
Connection successful: DSN=sampledb;UID=appuser;DataStore=/tt/db/sampledb;DatabaseCharacterSet=AL32UTF8;ConnectionCharacterSet=AL32UTF8;LogFileSize=256;LogBufMB=256;PermSize=1024;TempSize=256;OracleNetServiceName=ORCLPDB1;
(Default setting AutoCommit=1)
Command> 
```

2. Check the state of the tables:

```
<copy>
select count(*) from parent;
</copy>
```

```
< 0 >
1 row found.
```

```
<copy>
select count(*) from child;
</copy>
```

```
< 0 >
1 row found.
```

There is no data in the cached tables.

3. Run a query that references the root table's (PARENT table) primary key:

```
<copy>
select * from parent where parent_id = 4;
</copy>
```

```
< 4, Parent row 4 >
1 row found.
```

Even though the table was empty, the query returns a result!

```
<copy>
cachegroups ttcacheadm.cg_parent_child;
</copy>
```
```
Cache Group TTCACHEADM.CG_PARENT_CHILD:

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

1 cache group found.

```
Note that the Autorefresh State is now set to _On_ because a background dynamic load operation happened on execution of the above select statement.

4. Next, examine the contents of both tables again:

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

Now that these rows exist in the cache, they will satisfy future read requests. If any of these rows are modified in Oracle, the TimesTen autorefresh mechanism will capture the changes and propagate them to the cache.

Let’s try something a little more sophisticated. 

5. Query a row in the CHILD table with a join back to the PARENT table:

```
<copy>
select p.parent_id, p.parent_c1, c.child_c1 from parent p, child c where c.child_id = 2 and p.parent_id = c.parent_id;
</copy>
```

```
< 1, Parent row 1, P1,C2 >
1 row found.
```

4. Now check again to see the contents of both tables.

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

Here you queried against a specific *child_id* value and joined back to the parent table. TimesTen dynamically loaded all the expected cache instances. Dynamic caching can be very useful for specific use cases.

5. Disconnect from the cache.

```
<copy>
quit
</copy>
```

```
Disconnecting...
Done.
```

You can now **proceed to the next lab**. 

Keep your primary session open for use in the next lab.

## Acknowledgements

* **Author** - Chris Jenkins, Senior Director, TimesTen Product Management
* **Contributors** -  Doug Hood & Jenny Bloom, TimesTen Product Management
* **Last Updated By/Date** - Jenny Bloom, October 2023

