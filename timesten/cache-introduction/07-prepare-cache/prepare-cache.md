# Prepare the TimesTen cache

## Introduction

In this lab, you create a TimesTen database and set it up to cache the required tables from the Oracle database.

**Estimated Lab Time:** 10 minutes

### Objectives

- Create a TimesTen database and prepare it to act as a cache.
- Create the APPUSER and OE application schema users.
- Create READONLY cache groups for the tables that you want to cache.

These tasks are all accomplished using SQL statements, so they can be easily performed from application code if required.

### Prerequisites

This lab assumes that you:

- Have completed all the previous labs in this workshop, in sequence.
- Have an open terminal session in the workshop compute instance, either via NoVNC or SSH, and that session is logged into the TimesTen host (tthost1).

### Useful definitions and concepts for TimesTen Cache

- A **cache group** is a SQL object that encapsulates a set of one or more tables that are related through primary key -> foreign key relationships. The (single) top-level table is called the root table and the other tables sit below it in a hierarchical parent/child arrangement.

- A **cache instance** consists of a single row from the root table and all the related rows from the subordinate tables down through the table hierarchy within the cache group.

- Cache operations act on cache groups not on individual tables, or on cache instances as opposed to individual rows.

- Normal SQL operations, such as SELECT, INSERT, UPDATE and DELETE, operate directly on the cache tables and the rows therein. For this lab where READONLY cache groups are deployed, only SELECT operations are applicable to read from the cache tables.


## Task 1: Create the TimesTen database and prepare it for caching

A TimesTen database is implicitly created the first time the instance administrator user connects to it via its server DSN. In order to use the database as a cache, you must set the Oracle cache admin username and password and start the TimesTen cache agent.

The cache agent is a TimesTen daemon process that manages many of the cache-related functions for a TimesTen database.

One of the most frequently used TimesTen utilities is the **ttIsql** utility. This is an interactive SQL utility that serves the same purpose for TimesTen as SQL*Plus does for Oracle Database.

1. Connect to the **sampledb** DSN using **ttIsql**:

```
<copy>
ttIsql sampledb
</copy>
```

```

Copyright (c) 1996, 2022, Oracle and/or its affiliates. All rights reserved.
Type ? or "help" for help, type "exit" to quit ttIsql.

connect "DSN=sampledb";
Connection successful: DSN=sampledb;UID=oracle;DataStore=/tt/db/sampledb;DatabaseCharacterSet=AL32UTF8;ConnectionCharacterSet=AL32UTF8;LogFileSize=256;LogBufMB=256;PermSize=1024;TempSize=256;OracleNetServiceName=ORCLPDB1;
(Default setting AutoCommit=1)
```

2. Create a cache administrator username and password in TimesTen and grant the necessary privileges to manage cache groups:

```
<copy>
CREATE USER ttcacheadm IDENTIFIED BY ttcacheadm;
</copy>
```
```
User created.
```
```
<copy>
GRANT CREATE SESSION, CACHE_MANAGER, CREATE ANY TABLE, CREATE ANY INDEX, ALTER ANY TABLE, SELECT ANY TABLE TO ttcacheadm;
</copy>
```
The password for the cache admin user for TimesTen can be different than the one in Oracle. For simplicity, the same password is used for this user in TimesTen and Oracle.

3. Create the application users for the **OE** and **APPUSER** schemas and grant them some necessary privileges:

```
<copy>
CREATE USER oe IDENTIFIED BY "oe";
</copy>
```

```
User created.
```

```
<copy>
GRANT CREATE SESSION TO oe;
</copy>
```

```
<copy>
CREATE USER appuser IDENTIFIED BY "appuser";
</copy>
```

```
User created.
```

```
<copy>
GRANT CREATE SESSION TO appuser;
</copy>
```
```
<copy>
quit
</copy>
```

```
Disconnecting...
Done.
```
4. Connect as user, ttcacheadm, to start up cache agent.


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
```

5. Set the Oracle cache administrator username and password:

```
<copy>
call ttCacheUidPwdSet('ttcacheadm','ttcacheadm');
</copy>
```
The credentials are stored, encrypted, in the TimesTen database.

6. Start the TimesTen cache agent for the cache database:

```
<copy>
call ttCacheStart;
</copy>
```


## Task 2: Create the cache groups

Create the (multiple) cache groups for the **OE** schema tables. To reduce typing and copy/pasting, this lab uses a pre-prepared script to create the cache groups.

1. Run the script to create the cache groups with tables owned by OE:

```
<copy>
@scripts/createCacheGroupsOE;
</copy>
```

```
--
-- Put 'promotions' in its own cache group as it has
-- no child tables.
--

CREATE READONLY CACHE GROUP ttcacheadm.cg_promotions
    AUTOREFRESH MODE INCREMENTAL INTERVAL 2 SECONDS
    STATE PAUSED
FROM
oe.promotions 
( promo_id   NUMBER(6)
, promo_name VARCHAR2(20)
, PRIMARY KEY (promo_id)
);


…

--
-- Create an index explicitly for the omitted FK
-- in case queries rely on it.
--

CREATE INDEX oe.order_items_fk
  ON oe.order_items (product_id);

```

2. Display the created cache groups, note the cache groups are owned by TTCACHEADM user but the cache tables are owned by OE user:

```
<copy>
cachegroups;
</copy>
```

```
Cache Group TTCACHEADM.CG_CUST_ORDERS:

  Cache Group Type: Read Only
  Autorefresh: Yes
  Autorefresh Mode: Incremental
  Autorefresh State: Paused
  Autorefresh Interval: 2 Seconds
  Autorefresh Status: ok
  Aging: No aging defined

  Root Table: OE.CUSTOMERS
  Table Type: Read Only


  Child Table: OE.ORDERS
  Table Type: Read Only


  Child Table: OE.ORDER_ITEMS
  Table Type: Read Only

Cache Group TTCACHEADM.CG_PROD_INVENTORY:

  Cache Group Type: Read Only
  Autorefresh: Yes
  Autorefresh Mode: Incremental
  Autorefresh State: Paused
  Autorefresh Interval: 2 Seconds
  Autorefresh Status: ok
  Aging: No aging defined

  Root Table: OE.PRODUCT_INFORMATION
  Table Type: Read Only


  Child Table: OE.PRODUCT_DESCRIPTIONS
  Table Type: Read Only


  Child Table: OE.INVENTORIES
  Table Type: Read Only

Cache Group TTCACHEADM.CG_PROMOTIONS:

  Cache Group Type: Read Only
  Autorefresh: Yes
  Autorefresh Mode: Incremental
  Autorefresh State: Paused
  Autorefresh Interval: 2 Seconds
  Autorefresh Status: ok
  Aging: No aging defined

  Root Table: OE.PROMOTIONS
  Table Type: Read Only

3 cache groups found.
```
There are 3 cache groups for tables owned by OE user.

3. Display the tables owned by the OE user. These are the tables that make up the cache groups:
```
<copy>
alltables oe.%;
</copy>
```

```
  OE.CUSTOMERS
  OE.INVENTORIES
  OE.ORDERS
  OE.ORDER_ITEMS
  OE.PRODUCT_DESCRIPTIONS
  OE.PRODUCT_INFORMATION
  OE.PROMOTIONS
7 tables found.
```
```
<copy>
select count(*) from oe.customers;
</copy>
```

```
< 0 >
1 row found.
```

```
<copy>
select count(*) from oe.product_information;
</copy>
```

```
< 0 >
1 row found.
```

```
<copy>
select count(*) from oe.promotions;
</copy>
```

```
< 0 >
1 row found.
```
Currently, all the tables are empty.

Create the cache group for the **APPUSER.VPN\_USERS** table. This time you will type, or copy/paste, the individual commands.

4. Create the cache group with table owned by APPUSER.

```
<copy>
CREATE READONLY CACHE GROUP ttcacheadm.cg_vpn_users 
AUTOREFRESH MODE INCREMENTAL INTERVAL 2 SECONDS 
STATE PAUSED 
FROM 
appuser.vpn_users 
( vpn_id             NUMBER(5) NOT NULL
, vpn_nb             NUMBER(5) NOT NULL
, directory_nb       CHAR(10 BYTE) NOT NULL
, last_calling_party CHAR(10 BYTE) NOT NULL
, descr              CHAR(100 BYTE) NOT NULL
, PRIMARY KEY (vpn_id, vpn_nb)
);
</copy>
```

5. Display the cachegroup and table:

```
<copy>
cachegroups cg_vpn_users;
</copy>
```

```
Cache Group TTCACHEADM.CG_VPN_USERS:

  Cache Group Type: Read Only
  Autorefresh: Yes
  Autorefresh Mode: Incremental
  Autorefresh State: Paused
  Autorefresh Interval: 2 Seconds
  Autorefresh Status: ok
  Aging: No aging defined

  Root Table: APPUSER.VPN_USERS
  Table Type: Read Only

1 cache group found.
```
```
<copy>
alltables appuser.%;
</copy>
```

```
  APPUSER.VPN_USERS
1 table found.
```

```
<copy>
select count(*) from appuser.vpn_users;
</copy>
```

```
< 0 >
1 row found.
```
6. Exit from ttIsql:

```
<copy>
quit
</copy>
```
```
Disconnecting...
Done.
```

The TimesTen mechanism that captures data changes that occur in the Oracle database and uses those changes to refresh the cached data is called **AUTOREFRESH**. Note that, in the output above, the state of this mechanism is currently **Paused** for all of the cache groups that you just created.

```
Autorefresh State: Paused
```
In order to pre-populate the cache tables and activate the AUTOREFRESH mechanism you must load the cache groups.

You can now **proceed to the next lab**. 

Keep your terminal session to tthost1 open for use in the next lab.

## AcknowledgeEments

* **Author** - Chris Jenkins, Senior Director, TimesTen Product Management
* **Contributors** -  Doug Hood & Jenny Bloom, TimesTen Product Management
* **Last Updated By/Date** - Jenny Bloom, October 2023

