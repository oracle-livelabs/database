# Verify cache refresh

## Introduction

With READONLY cache groups, the Oracle database is the master of the data. The data cached in TimesTen is a read-only copy. Any changes (insert/update/delete) made to the data in Oracle are automatically captured and refreshed to the cached tables in TimesTen based on the defined refresh interval (2 seconds in these examples).

In this lab we will execute some DML statements on the tables in Oracle and observe those changes being automatically propagated to the cache tables in TimesTen.

Estimated Time: 5 minutes.

### Objectives

- Modify data in Oracle database
- Verify that the changes are refreshed to the cache

### Prerequisites

This lab assumes that you have:

- Completed all the previous labs in this workshop, in sequence.

## Task 1: Connect to the environment

**IMPORTANT:** This lab requires _two_ terminal sessions to the TimesTen host (tthost1).

If you do not already have an active terminal session, connect to the OCI compute instance and open a terminal session, as the user **oracle**. In that terminal session, connect to the TimesTen host (tthost1) using ssh. This session, or your existing session if there was one, will be refereed to as the **primary** session.

Connect to the OCI compute instance again (if required) and open a terminal session. In this second session, connect to the TimesTen host (tthost1) using ssh. This session will be refereed to as the **secondary** session.

## Task 2: Verify the refresh of INSERT operations

In your _primary_ SSH session, which is currently logged into the TimesTen host, connect to the TimesTen cache as the OE schema user.

```
[oracle@tthost1 livelab]$ ttIsql "DSN=sampledb;uid=oe;pwd=oe;OraclePWD=oe"

Copyright (c) 1996, 2022, Oracle and/or its affiliates. All rights reserved.
Type ? or "help" for help, type "exit" to quit ttIsql.

connect "DSN=sampledb;uid=oe;pwd=********;OraclePWD=********";
Connection successful: DSN=sampledb;UID=oe;DataStore=/tt/db/sampledb;DatabaseCharacterSet=AL32UTF8;ConnectionCharacterSet=AL32UTF8;LogFileSize=256;LogBufMB=256;PermSize=1024;TempSize=256;OracleNetServiceName=ORCLPDB1;
(Default setting AutoCommit=1)
Command>
```

In your secondary SSH session, which is already logged into the TimesTen host (tthost1), connect to the Oracle database as the OE schema user:

```
[oracle@tthost1 livelab]$ sqlplus oe/oe@orclpdb1

SQL*Plus: Release 19.0.0.0.0 - Production on Wed Jun 15 14:39:50 2022
Version 19.14.0.0.0

Copyright (c) 1982, 2021, Oracle.  All rights reserved.

Last Successful login time: Tue May 10 2022 14:18:58 +00:00

Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL>
```

In your _primary_ SSH session (ttIsql), check the rows in the OE.PROMOTIONS table in TimesTen:

```
Command> SELECT * FROM promotions ORDER BY promo_id;
< 1, everyday low price >
< 2, blowout sale >
2 rows found.
```

In your _secondary_ SSH session (sqlplus), check the rows in the OE.PROMOTIONS table in Oracle, then insert a new row and commit:

```
SQL> SELECT * FROM promotions ORDER BY promo_id;

  PROMO_ID PROMO_NAME
---------- --------------------
	 1 everyday low price
	 2 blowout sale

SQL> INSERT INTO promotions VALUES ( 3, 'christmas sale' );

1 row created.

SQL> commit;

Commit complete.

SQL> SELECT * FROM promotions ORDER BY promo_id;

  PROMO_ID PROMO_NAME
---------- --------------------
	 1 everyday low price
	 2 blowout sale
	 3 christmas sale
```

Wait for 2 seconds (the cache refresh interval) and then in your _primary_ SSH session (ttIsql), check the rows in the OE.PROMOTIONS table in TimesTen:

```
Command> SELECT * FROM promotions ORDER BY promo_id;
< 1, everyday low price >
< 2, blowout sale >
< 3, christmas sale >
3 rows found.
```

The inserted row has been captured and propagated to the cached table in TimesTen.

## Task 3: Verify the refresh of UPDATE operations

In your _secondary_ SSH session (sqlplus), update a row in the OE.PROMOTIONS table in Oracle and commit:

```
SQL> UPDATE promotions SET promo_name = 'easter sale' WHERE promo_id = 3;

1 row updated.

SQL> commit;

Commit complete.

SQL> SELECT * FROM promotions ORDER BY promo_id;

  PROMO_ID PROMO_NAME
---------- --------------------
	 1 everyday low price
	 2 blowout sale
	 3 easter sale
```

Wait for 2 seconds (the cache refresh interval) and then in your _primary_ SSH session (ttIsql), check the rows in the OE.PROMOTIONS table in TimesTen:

```
Command> SELECT * FROM promotions ORDER BY promo_id;
< 1, everyday low price >
< 2, blowout sale >
< 3, easter sale >
3 rows found.
```

The update to the row has been captured and propagated to the cached table in TimesTen.

## Task 4: Verify the refresh of DELETE operations

In your _secondary_ SSH session (sqlplus), delete a row in the OE.PROMOTIONS table in Oracle and commit:

```
SQL> DELETE FROM promotions WHERE promo_id =  3;

1 row deleted.

SQL> commit;

Commit complete.

SQL> SELECT * FROM promotions ORDER BY promo_id;

  PROMO_ID PROMO_NAME
---------- --------------------
	 1 everyday low price
	 2 blowout sale
```

Wait for 2 seconds (the cache refresh interval) and then in your _primary_ SSH session (ttIsql), check the rows in the OE.PROMOTIONS table in TimesTen:

```
Command> SELECT * FROM promotions ORDER BY promo_id;
< 1, everyday low price >
< 2, blowout sale >
2 rows found.
```

The row deletion has been captured and propagated to the cached table in TimesTen.

In your _secondary_ SSH session, quit out of SQL*Plus, disconnect from the TimesTen host and close the terminal session:

```
SQL> quit;
Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0
[oracle@tthost1 livelab]$ exit
[oracle@ttlivelabvm lab]$ exit
```

In your _primary_ SSH session, quit out of ttIsql for now:

```
Command> quit;
Disconnecting...
Done.
```

You can now *proceed to the next lab*. Keep your primary terminal session open for use in the next lab.

## Acknowledgements

* **Author** - Chris Jenkins, Senior Director, TimesTen Product Management
* **Contributors** -  Doug Hood & Jenny Bloom, TimesTen Product Management
* **Last Updated By/Date** - Chris Jenkins, July 2022

