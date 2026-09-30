# Load Oracle data into the cache

## Introduction

In this lab, you will load data from the Oracle tables into the TimesTen cache tables. This action will also activate the AUTOREFRESH mechanism which will periodically refresh the cache with any changes that have occurred in the Oracle database.

**Estimated Lab Time:** 6 minutes

### Objectives

- Load cache groups for APPUSER and OE cache tables.

This task is accomplished using SQL statements, so can be easily performed from application code if required.

### Prerequisites

This lab assumes that you:

- Have completed all the previous labs in this workshop, in sequence.
- Have an open terminal session in the workshop compute instance, either via NoVNC or SSH, and that session is logged into the TimesTen host (tthost1).

## Task 1: Load the APPUSER cache group

As you saw in the previous lab, when a READONLY cache group is first created its tables are empty and the AUTOREFRESH mechanism is in a paused state.

Loading the cache group populates the cache tables with the data from the Oracle database and also activates the AUTOREFRESH mechanism. The load occurs in such a manner that if any changes occur to the data in the Oracle database while the load is in progress, those changes will be captured. The captured changes are then autorefreshed to TimesTen once the load is completed.

Load the CG\_VPN\_USERS cache group (1 million rows) and then examine the cache group and table.

1. Connect to the cache as the user **ttcacheadm**:

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

2. Load the cache group:

```
<copy>
LOAD CACHE GROUP cg_vpn_users COMMIT EVERY 1024 ROWS;
</copy>
```

```
1000000 cache instances affected.
```

3. Display the cache group details:

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
  Autorefresh State: On
  Autorefresh Interval: 2 Seconds
  Autorefresh Status: ok
  Aging: No aging defined

  Root Table: APPUSER.VPN_USERS
  Table Type: Read Only

1 cache group found.
```

Note that the state of autorefresh has now changed to  **On**.

4. Check the row count of the cache table:

```
<copy>
select count(*) from appuser.vpn_users;
</copy>
```

```
< 1000000 >
1 row found.
```

5. Update optimizer statistics on appuser.vpn_users table:

```
<copy>
statsupdate appuser.vpn_users;
</copy>
```


## Task 2: Load the OE cache groups

Now do the same for the cache groups on the OE cache tables.

1. Load the CG\_PROMOTIONS cache group:

```
<copy>
LOAD CACHE GROUP cg_promotions COMMIT EVERY 1024 ROWS;
</copy>
```

```
2 cache instances affected.
```

2. Load the CG\_PROD\_INVENTORY cache group:

```
<copy>
LOAD CACHE GROUP cg_prod_inventory COMMIT EVERY 1024 ROWS;
</copy>
```

```
288 cache instances affected.
```

3. Load the CG\_CUST\_ORDERS cache group:

```
<copy>
LOAD CACHE GROUP cg_cust_orders COMMIT EVERY 1024 ROWS;
</copy>
```

```
319 cache instances affected.
```

5. Update optimizer statistics for all the tables in the OE schema:

```
<copy>
statsupdate oe.customers;
statsupdate oe.inventories;
statsupdate oe.orders;
statsupdate oe.order_items;
statsupdate oe.product_descriptions;
statsupdate oe.product_information;
statsupdate oe.promotions;
</copy>
```

6. Check the row count for oe.CUSTOMERS table:

```
<copy>
select count(*) from oe.customers;
</copy>
```

```
< 319 >
1 row found.
```

7. Check the row count for oe.INVENTORIES table:

```
<copy>
select count(*) from oe.inventories;
</copy>
```

```
< 1112 >
1 row found.
```

8. Check the row count for oe.ORDERS table:

```
<copy>
select count(*) from oe.orders;
</copy>
```

```
< 105 >
1 row found.
```

9. Check the row count for oe.ORDER\_ITEMS table:

```
<copy>
select count(*) from oe.order_items;
</copy>
```

```
< 665 >
1 row found.
```

10. Check the row count for oe.PRODUCT\_DESCRIPTIONS table:

```
<copy>
select count(*) from oe.product_descriptions;
</copy>
```

```
< 8639 >
1 row found.
```

11. Check the row count for oe.PRODUCT\_INFORMATION table:

```
<copy>
select count(*) from oe.product_information;
</copy>
```

```
< 288 >
1 row found.
```

12. Check the row count for oe.PROMOTIONS table:

```
<copy>
select count(*) from oe.promotions;
</copy>
```

```
< 2 >
1 row found.
```

13. Exit from ttIsql:

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

Keep your terminal session to tthost1 open for use in the next lab.

## Acknowledgements

* **Author** - Chris Jenkins, Senior Director, TimesTen Product Management
* **Contributors** -  Doug Hood & Jenny Bloom, TimesTen Product Management
* **Last Updated By/Date** - Jenny Bloom, October 2023

