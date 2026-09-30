# Verify automatic cache refresh

## Introduction

With READONLY cache groups, the Oracle database is authoritative for the cached data. The corresponding data in TimesTen is a read-only copy. TimesTen automatically captures any changes (insert/update/delete) made to the data in Oracle. TimesTen refreshes these changes to the cached tables based on the defined refresh interval (2 seconds in these examples).

In this lab you execute DML statements on the tables in Oracle and observe those changes being automatically propagated to the corresponding tables cached in TimesTen.

**Estimated Lab Time:** 10 minutes

### Objectives

- Modify data in the Oracle database.
- Verify that the changes are refreshed to the cache.

### Prerequisites

This lab assumes that you:

- Have completed all the previous labs in this workshop, in sequence.
- Have an open terminal session in the workshop compute instance, either via NoVNC or SSH, and that session is logged into the TimesTen host (tthost1).

## Task 1: Open a second terminal session

**IMPORTANT:** This lab requires _two_ terminal sessions to the TimesTen host (tthost1).

Your existing terminal session to tthost1 will be referred to as the **primary** session.

Open a _second_ terminal session, as the user **oracle**, in the workshop compute instance, either via NoVNC or SSH. In that terminal session, connect to the TimesTen host (tthost1) using ssh. This session will be referred to as the **secondary** session.

### Opening a new terminal session using SSH

 If you are using **SSH**, then you can just create a second SSH session, as the **oracle** user, to the workshop compute instance and then in that session **ssh** into **tthost1**.
 
### Opening a new terminal session using the NoVNC desktop

 If you are using the **NoVNC desktop**, then there are several ways to open an additional terminal window:
 
 - Click on **Activities** in the linux Menu bar, _right_ click on the **Terminal** icon in the list that appears and choose **New Window**.
 
 - If you already have at least one terminal window open, click on the **Terminal** item in the Linux menu bar and choose **New window**.

 - _Double_ click the **Terminal** icon on the linux desktop.  

 - Once you have a new window, in that window **ssh** into **tthost1**.

**IMPORTANT:** When you open a new terminal window it often exactly overlays the exitsing terminal window, and it may appear that a new window has not been opened. If you move the visible terminal window you will find that a new window has indeed been created and that you now have two terminal windows.
 

## Task 2: Verify the refresh of INSERT operations

1. In your _primary_ session connect to the TimesTen cache as the OE schema user:

```
<copy>
ttIsql "DSN=sampledb;uid=oe;pwd=oe;OraclePWD=oe"
</copy>
```

```
Copyright (c) 1996, 2022, Oracle and/or its affiliates. All rights reserved.
Type ? or "help" for help, type "exit" to quit ttIsql.

connect "DSN=sampledb;uid=oe;pwd=********;OraclePWD=********";
Connection successful: DSN=sampledb;UID=oe;DataStore=/tt/db/sampledb;DatabaseCharacterSet=AL32UTF8;ConnectionCharacterSet=AL32UTF8;LogFileSize=256;LogBufMB=256;PermSize=1024;TempSize=256;OracleNetServiceName=ORCLPDB1;
(Default setting AutoCommit=1)
Command>
```

2. In your _secondary_ session, connect to the Oracle database as the OE schema user:

```
<copy>
sqlplus oe/oe@orclpdb1
</copy>
```

```
SQL*Plus: Release 19.0.0.0.0 - Production on Wed Oct 11 21:56:56 2023
Version 19.19.0.0.0

Copyright (c) 1982, 2022, Oracle.  All rights reserved.

Last Successful login time: Mon Jan 09 2023 11:30:47 +00:00

Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL>
```

3. In your _primary_ session (**ttIsql**), check the rows in the OE.PROMOTIONS table in TimesTen:

```
<copy>
SELECT * FROM promotions ORDER BY promo_id;
</copy>
```

```
< 1, everyday low price >
< 2, blowout sale >
2 rows found.
```

4. In your _secondary_ session (**sqlplus**), check the rows in the OE.PROMOTIONS table in Oracle, then insert a new row and commit:

```
<copy>
SELECT * FROM promotions ORDER BY promo_id;
</copy>
```

```
  PROMO_ID PROMO_NAME
---------- --------------------
	 1 everyday low price
	 2 blowout sale
```

```
<copy>
INSERT INTO promotions VALUES ( 3, 'christmas sale' );
</copy>
```

```
1 row created.
```

```
<copy>
commit;
</copy>
```

```
Commit complete.
```

```
<copy>
SELECT * FROM promotions ORDER BY promo_id;
</copy>
```

```
  PROMO_ID PROMO_NAME
---------- --------------------
	 1 everyday low price
	 2 blowout sale
	 3 christmas sale
```

5. Wait for 2 seconds (the cache refresh interval) and then in your _primary_ session (**ttIsql**), check the rows in the OE.PROMOTIONS table in TimesTen:

```
<copy>
SELECT * FROM promotions ORDER BY promo_id;
</copy>
```

```
< 1, everyday low price >
< 2, blowout sale >
< 3, christmas sale >
3 rows found.
```

The inserted row has been captured and propagated to the cached table in TimesTen.

## Task 3: Verify the refresh of UPDATE operations

1. In your _secondary_ session (**sqlplus**), update a row in the OE.PROMOTIONS table in Oracle and commit:

```
<copy>
UPDATE promotions SET promo_name = 'easter sale' WHERE promo_id = 3;
</copy>
```

```
1 row updated.
```

```
<copy>
commit;
</copy>
```

```
Commit complete.
```

2. Wait for 2 seconds (the cache refresh interval) and then in your _primary_ session (**ttIsql**), check the rows in the OE.PROMOTIONS table in TimesTen:

```
<copy>
SELECT * FROM promotions ORDER BY promo_id;
</copy>
```

```
< 1, everyday low price >
< 2, blowout sale >
< 3, easter sale >
3 rows found.
```

The update to the row has been captured and propagated to the cached table in TimesTen.

## Task 4: Verify the refresh of DELETE operations

1. In your _secondary_ session (**sqlplus**), delete a row in the OE.PROMOTIONS table in Oracle and commit:

```
<copy>
DELETE FROM promotions WHERE promo_id =  3;
</copy>
```

```
1 row deleted.
```

```
<copy>
commit;
</copy>
```

```
Commit complete.
```

```
<copy>
SELECT * FROM promotions ORDER BY promo_id;
</copy>
```

```
  PROMO_ID PROMO_NAME
---------- --------------------
	 1 everyday low price
	 2 blowout sale
```

2. Wait for 2 seconds (the cache refresh interval) and then in your _primary_ session (**ttIsql**), check the rows in the OE.PROMOTIONS table in TimesTen:

```
<copy>
SELECT * FROM promotions ORDER BY promo_id;
</copy>
```

```
< 1, everyday low price >
< 2, blowout sale >
2 rows found.
```

The row deletion has been captured and propagated to the cached table in TimesTen.

3. In your _secondary_ session (**sqlplus**), exit from SQL*Plus, disconnect from the TimesTen host and close the terminal session:

```
<copy>
quit;
</copy>
```

```
Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0
```

```
<copy>
exit
</copy>
```

```
<copy>
exit
</copy>
```

4. In your _primary_ session (**ttIsql**), exit from ttIsql:

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

