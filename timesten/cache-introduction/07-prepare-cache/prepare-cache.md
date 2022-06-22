# Prepare the TimesTen cache

## Introduction

In this lab we will create a TimesTen database and set it up to cache the required tables from the Oracle database.

Estimated Time: 10 minutes.

### Objectives

- Create a TimesTen database and prepare it to act as a cache
- Create the application schema users (APPUSER and OE)
- Create READONLY cache groups for the tables that we want to cache

These tasks are all accomplished using SQL statements, so they can be easily performed from application code if required.

### Prerequisites

This lab assumes that you have:

- Completed all the previous labs in this workshop, in sequence.

## Task 1: Connect to the environment

If you do not already have an active terminal session, connect to the OCI compute instance and open a terminal session, as the user **oracle**.

In that terminal session, connect to the TimesTen host (tthost1) using ssh.

## Task 2: Create the TimesTen database and prepare it for caching

A TimesTen database is implicitly created the first time the instance administrator user connects to it via its server DSN. In order to use the database as a cache we must set the Oracle cache admin username and password and also start the TimesTen Cache Agent.

The Cache Agent is a TimesTen daemon process that manages many of the cache related functions for a TimesTen database.

One of the most frequently used TimesTen utilities is the **ttIsql** utility. This is an interactive SQL utility that serves the same purpose for TimesTen as SQL*Plus does for Oracle Database.

Connect to the **sampledb** DSN using **ttIsql**:

```
[oracle@tthost1 livelab]$ ttIsql sampledb

Copyright (c) 1996, 2022, Oracle and/or its affiliates. All rights reserved.
Type ? or "help" for help, type "exit" to quit ttIsql.

connect "DSN=sampledb";
Connection successful: DSN=sampledb;UID=oracle;DataStore=/tt/db/sampledb;DatabaseCharacterSet=AL32UTF8;ConnectionCharacterSet=AL32UTF8;LogFileSize=256;LogBufMB=256;PermSize=1024;TempSize=256;OracleNetServiceName=ORCLPDB1;
(Default setting AutoCommit=1)
Command> call ttCacheUidPwdSet('ttcacheadm','ttcacheadm');
Command> call ttCacheStart;
```

We need to create application users for the **OE** and **APPUSER** schemas and grant them some necessary privileges:

```
Command> CREATE USER oe IDENTIFIED BY "oe";

User created.

Command> GRANT CREATE SESSION, CREATE CACHE GROUP, CREATE TABLE TO oe;
Command> CREATE USER appuser IDENTIFIED BY "appuser";

User created.

Command> GRANT CREATE SESSION, CREATE CACHE GROUP, CREATE TABLE TO appuser;
Command> quit;
Disconnecting...
Done.
```

## Task 3: Create the cache groups

A **cache group** is a SQL object that encapsulates a set of one or more tables that are related through primary key -> foreign key relationships. The (single) top level table is called the root table and the other tables sit below it in a hierarchical parent/child arrangement.

A cache instance consists of a single row from the root table and all the related rows from the subordinate tables down through the hierarchy within the cache group.

Cache operations act on cache groups not on individual tables, or on cache instances as opposed to individual rows.

Normal SQL operations, such as SELECT, INSERT, UPDATE and DELETE, operate directly on the cache tabls and the rows therein. 

Create the (multiple) cache groups for the **OE** schema tables. We will use a pre-prepared script to reduce the amount of typing or copying & pasting:

```
[oracle@tthost1 livelab]$ ttIsql "DSN=sampledb;UID=oe;PWD=oe;OraclePWD=oe"

Copyright (c) 1996, 2022, Oracle and/or its affiliates. All rights reserved.
Type ? or "help" for help, type "exit" to quit ttIsql.

connect "DSN=sampledb;UID=oe;PWD=********;OraclePWD=********";
Connection successful: DSN=sampledb;UID=oe;DataStore=/tt/db/sampledb;DatabaseCharacterSet=AL32UTF8;ConnectionCharacterSet=AL32UTF8;LogFileSize=256;LogBufMB=256;PermSize=1024;TempSize=256;OracleNetServiceName=ORCLPDB1;
(Default setting AutoCommit=1)
Command> @scripts/createCacheGroupsOE;
--
-- Put 'promotions' in its own cache group as it has
-- no child tables.
--

CREATE READONLY CACHE GROUP oe.cg_promotions
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
Display the cachegroups owned by the OE user:

```
Command> cachegroups oe.%;

Cache Group OE.CG_CUST_ORDERS:

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

Cache Group OE.CG_PROD_INVENTORY:

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

Cache Group OE.CG_PROMOTIONS:

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

Display the tables owned by the OE user. These are the tables that make up the cache groups:

```
Command> tables;
  OE.CUSTOMERS
  OE.INVENTORIES
  OE.ORDERS
  OE.ORDER_ITEMS
  OE.PRODUCT_DESCRIPTIONS
  OE.PRODUCT_INFORMATION
  OE.PROMOTIONS
7 tables found.
Command> select count(*) from customers;
< 0 >
1 row found.
Command> select count(*) from product_information;
< 0 >
1 row found.
Command> select count(*) from promotions;
< 0 >
1 row found.
```

The user OE has 3 cache groups, some containing single tables and others containing multiple tables. Presently all the tables are empty.

Create the cache group for the **APPUSER.VPN_USERS** table. This time you will type, or copy/paste, the commands:

```
[oracle@tthost1 livelab]$ ttIsql \
    "DSN=sampledb;UID=appuser;PWD=appuser;OraclePWD=appuser"

Copyright (c) 1996, 2022, Oracle and/or its affiliates. All rights reserved.
Type ? or "help" for help, type "exit" to quit ttIsql.

connect "DSN=sampledb;UID=appuser;PWD=********;OraclePWD=********";
Connection successful: DSN=sampledb;UID=appuser;DataStore=/tt/db/sampledb;DatabaseCharacterSet=AL32UTF8;ConnectionCharacterSet=AL32UTF8;LogFileSize=256;LogBufMB=256;PermSize=1024;TempSize=256;OracleNetServiceName=ORCLPDB1;
(Default setting AutoCommit=1)
Command> cachegroups appuser.%;

0 cache groups found.
Command> tables;
0 tables found.
Command> CREATE READONLY CACHE GROUP appuser.cg_vpn_users 
AUTOREFRESH MODE INCREMENTAL INTERVAL 2 SECONDS 
STATE PAUSED 
FROM 
vpn_users 
( vpn_id             NUMBER(5) NOT NULL
, vpn_nb             NUMBER(5) NOT NULL
, directory_nb       CHAR(10 BYTE) NOT NULL
, last_calling_party CHAR(10 BYTE) NOT NULL
, descr              CHAR(100 BYTE) NOT NULL
, PRIMARY KEY (vpn_id, vpn_nb)
);
```

Display the cachegroup and table:

```
Command> cachegroups appuser.%;

Cache Group APPUSER.CG_VPN_USERS:

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
Command> tables;
  APPUSER.VPN_USERS
1 table found.
Command> select count(*) from vpn_users;
< 0 >
1 row found.
Command> quit
Disconnecting...
Done.
```

The TimesTen mechanism that captures data changes that occur in the Oracle database and uses those changes to refresh the cached data is called **AUTOREFRESH**. Note that for all of the cache groups that we just created, the status of this mechanism is currently **Paused**.

```
...
Autorefresh State: Paused
...
```
In order to pre-populate the cache tables and activate the AUTOREFRESH mechanism we must now load the cache groups, which we will do in the next lab.

You can now *proceed to the next lab*. Keep your terminal session open for use in the next lab.

## Acknowledgements

* **Author** - Chris Jenkins, Senior Director, TimesTen Product Management
* **Contributors** -  Doug Hood & Jenny Bloom, TimesTen Product Management
* **Last Updated By/Date** - Chris Jenkins, July 2022

