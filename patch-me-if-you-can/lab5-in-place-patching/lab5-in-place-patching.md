## Lab 5 - In-Place Patching
The benefit of the out-of-place patching method is not only that the previous home is preserved for a potential fallback but it only allows much shorter downtime. In order to see the difference you could patch now the 19.18.0 source home in-place.

**Task 1 - Checks for in-place patching**
Please switch to the other tab titled "19.18.0 Home",

Set the environment for the UP19 database. It is currently shutdown since it needs to be shutdown while we patch.
```
. up19
```

Then enter the patch directory for the Release Update 19.19.0:
```
cd /home/oracle/stage/ru/35042068
```

Start running the patching conflict check:
`$ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -ph ./`

You will receive a very long output listing several thousands of bug numbers fixed by the RU. We cut the output off here:
```
$ $ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -ph ./
Oracle Interim Patch Installer version 12.2.0.1.37
Copyright (c) 2023, Oracle Corporation.  All rights reserved.

PREREQ session

Oracle Home       : /u01/app/oracle/product/19
Central Inventory : /u01/app/oraInventory
   from           : /u01/app/oracle/product/19/oraInst.loc
OPatch version    : 12.2.0.1.37
OUI version       : 12.2.0.7.0
Log file location : /u01/app/oracle/product/19/cfgtoollogs/opatch/opatch2023-06-27_00-24-18AM_1.log

Invoking prereq "checkconflictagainstohwithdetail"

ZOP-47: The patch(es) has supersets with other patches installed in the Oracle Home (or) among themselves.

Prereq "checkConflictAgainstOHWithDetail" failed.

The details are:
Reason - 
Superset Patch 35042068 has 
Subset Patch 34765931 which has overlay patches [34810252,34861493,35213579,34871935,35246710,34557500,35156936,34879016,34783802,33973908,34793099,31222103,32727143,34974052,35160800,34972375,34340632,35162446] and these overlay patches conflict with Superset Patch
Subset Patch 34765931 which has overlay patches [34810252,34861493,35213579,34871935,35246710,34557500,35156936,34879016,34783802,33973908,34793099,31222103,32727143,34974052,35160800,34972375,34340632,35162446] and these overlay patches conflict with Superset Patch
```

Part of the output is the following paragraph:
  ```
- Please rollback the relevant overlay patches of the subset patches which are conflicting and apply the superset patch
Summary of Conflict Analysis:

There are no patches that can be applied now.

Following patches have conflicts. Please contact Oracle Support and get the merged patch of the patches : 
34340632, 34972375, 35042068, 35213579
```

Why do you need to rollback anything?
The reason is that Release Updates wiill be merged automatically. But in this case the 19.18.0 home has additional patches applied. And those need to be rolled back at first.

**Task 2 - Patch rollback**
Do you want to go this route? Really?

If not, you have our full sympathy - and we'd ask you to continue straight to the next lab for cleanup and final checks.

In case you'd like to learn about the complexities of in-place patching instead, then continue in the current lab.

Then you need to check at first which patches need to be rolled back.

These are the patches opatch told you needing rollback:
```
Following patches will be rolled back from Oracle Home on application of the patches in the given list : 
34879016, 34871935, 34810252, 34793099, 34783802, 33973908
```

- 34879016
- 34871935
- 34810252
- 34793099
- 34783802
- 33973908

Now you can follow the opatch advice and just rollback the entire list of patches. Just make sure you remove the spaces between "comma" and "patchnumber":
`$ORACLE_HOME/OPatch/opatch nrollback -id 34879016,34871935,34810252,34793099,34783802,33973908`

And this works as you can see in the output below:
```
$ $ORACLE_HOME/OPatch/opatch nrollback -id 34879016,34871935,34810252,34793099,34783802,33973908
Oracle Interim Patch Installer version 12.2.0.1.37
Copyright (c) 2023, Oracle Corporation.  All rights reserved.


Oracle Home       : /u01/app/oracle/product/19
Central Inventory : /u01/app/oraInventory
   from           : /u01/app/oracle/product/19/oraInst.loc
OPatch version    : 12.2.0.1.37
OUI version       : 12.2.0.7.0
Log file location : /u01/app/oracle/product/19/cfgtoollogs/opatch/opatch2023-06-27_08-32-47AM_1.log


Patches will be rolled back in the following order: 
   34879016   34871935   34810252   34793099   34783802   33973908
The following patch(es) will be rolled back: 34879016  34871935  34810252  34793099  34783802  33973908  

Please shutdown Oracle instances running out of this ORACLE_HOME on the local system.
(Oracle Home = '/u01/app/oracle/product/19')


Is the local system ready for patching? [y|n]
y
User Responded with: Y

Rolling back patch 34879016...

RollbackSession rolling back interim patch '34879016' from OH '/u01/app/oracle/product/19'

Patching component oracle.rdbms, 19.0.0.0.0...
RollbackSession removing interim patch '34879016' from inventory

Rolling back patch 34871935...

RollbackSession rolling back interim patch '34871935' from OH '/u01/app/oracle/product/19'

Patching component oracle.rdbms, 19.0.0.0.0...
RollbackSession removing interim patch '34871935' from inventory

Rolling back patch 34810252...

RollbackSession rolling back interim patch '34810252' from OH '/u01/app/oracle/product/19'

Patching component oracle.rdbms, 19.0.0.0.0...
RollbackSession removing interim patch '34810252' from inventory

Rolling back patch 34793099...

RollbackSession rolling back interim patch '34793099' from OH '/u01/app/oracle/product/19'

Patching component oracle.rdbms, 19.0.0.0.0...
RollbackSession removing interim patch '34793099' from inventory

Rolling back patch 34783802...

RollbackSession rolling back interim patch '34783802' from OH '/u01/app/oracle/product/19'

Patching component oracle.rdbms, 19.0.0.0.0...
RollbackSession removing interim patch '34783802' from inventory

Rolling back patch 33973908...

RollbackSession rolling back interim patch '33973908' from OH '/u01/app/oracle/product/19'

Patching component oracle.rdbms, 19.0.0.0.0...
RollbackSession removing interim patch '33973908' from inventory
Log file location: /u01/app/oracle/product/19/cfgtoollogs/opatch/opatch2023-06-27_08-32-47AM_1.log

OPatch succeeded.
```

**Task 3 - More rollback is required**
Unfortunately, we are not done yet with rollback activities.

When you check again:
`$ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -ph ./`

you will see that there are still conflicts.
```
Following patches have conflicts. Please contact Oracle Support and get the merged patch of the patches : 
34340632, 34972375, 35042068, 35213579
```

Now this message is even more misleading since the third of the patches listed isn't even in the Oracle Home. You would find out if you'd try to remove it. We skip this part and rather run an opatch lsinventory which tells us what is installed right now.
`$ $ORACLE_HOME/OPatch/opatch lspatches`

```
$ $ORACLE_HOME/OPatch/opatch lspatches
35246710;HIGH DIRECT PATH READ AFTER 19.18 DBRU PATCHING
35213579;MERGE ON DATABASE RU 19.18.0.0.0 OF 35037877 35046819
35162446;NEED BEHAVIOR CHANGE TO BE SWITCHED OFF
35160800;GG IE FAILS WITH ORA-14400 AT SYSTEM.LOGMNRC_USER AFTER ORACLE DB UPGRADE TO 19.18DBRU
35156936;ORA-7445 [KFFBNEW()+351]  AFTER CONVERT TO ASM FLEX DISKGROUP
34974052;DIRECT NFS CONNECTION RESET MESSAGES
34861493;RESYNC CATALOG FAILED IN ZDLRA CATALOG AFTER PROTECTED DATABASE PATCHED TO 19.17
34557500;CTWR CAUSED MULTIPLE INSTANCES IN HUNG STATE ON THE RAC STANDBY DATABASE
34340632;AQAH  SMART MONITORING &amp; RESILIENCY IN QUEUE KGL MEMORY USAGE
32727143;TRANSACTION-LEVEL CONTENT ISOLATION FOR TRANSACTION-DURATION GLOBAL TEMPORARY TABLES
31222103;STRESS RAC ATPD FAN EVENTS ARE NOT GETTING PROCESSED WITH 21C GI AND 19.4 DB
34972375;DATAPUMP BUNDLE PATCH 19.18.0.0.0
34786990;OJVM RELEASE UPDATE: 19.18.0.0.230117 (34786990)
34765931;Database Release Update : 19.18.0.0.230117 (34765931)
29585399;OCW RELEASE UPDATE 19.3.0.0.0 (29585399)
```

Now I can tell you that the Data Pump Bundle Patch must be removed since it is a huge collection of one-off fixes. And the MRP installed into the 19.18.0 home must be removed as well. It doesn't identifiy itself as MRP but lists the one-off patches instead. You need to remove all of them as well before you can proceed.
```
$ORACLE_HOME/OPatch/opatch nrollback -id 34340632,34972375,35213579
```

Once they are removed, the conflict check passes, and you can continue.

**Task 4 - Apply RU 19.19.0**
You see, it is a lot of extra work to patch in-place. So far, you did only cleanup. But now, finally, you can start applying the patches. You will start with the Release Update 19.19.0
```
cd /home/oracle/stage/ru/35042068
```
```
$ORACLE_HOME/OPatch/opatch apply
```

**Task 5 - Apply the OJVM 19.19.0 Bundle Patch**
Now you need to apply the OJVM Bundle Patch on top.
```
cd /home/oracle/stage/ojvm/35050341/
```
```
$ORACLE_HOME/OPatch/opatch apply
```


**Task 6 - Apply the Data Pump Bundle Patch 19.19.0**
Next step is to apply the Data Pump Bundle Patch for 19.19.0. You could do this online while the database is up and running. But since we want all patches to be in place when we execute `datapatch` later on, it is best to apply it right now.
```
cd /home/oracle/stage/dpbp/35261302/
```
```
$ORACLE_HOME/OPatch/opatch apply
```

**Task 7 - Apply the MRP1 for 19.19.0**
Now you see a significant difference to the other processes. Since MRPs are a conjunction of one-off patches, you will use `opatch napply` now.
```
cd /home/oracle/stage/mrp/35333937
```
```
$ $ORACLE_HOME/OPatch/opatch napply /home/oracle/stage/mrp/35333937 -verbose
```


**Task 8 - Start the database and invoke datapatch**
As your home has now received all patches, you need to startup the UP19 database and apply all SQL and PL/SQL changes to it with datapatch:
```
sqlplus / as sysdba
startup
alter pluggable database all open;
exit
```
This is a non-CDB so you won't the "ALTER PLUGGABLE DATABASE" command. Still, we use this as a standard command since it will not harm but in case of having PDBs, it will ensure that your PDBs get started.

```
$ORACLE_HOME/OPatch/datapatch -verbose
```

This is the output you will likely see:
```
$ $ORACLE_HOME/OPatch/datapatch -verbose
SQL Patching tool version 19.19.0.0.0 Production on Tue Jun 27 10:09:17 2023
Copyright (c) 2012, 2023, Oracle.  All rights reserved.

Log file for this invocation: /u01/app/oracle/cfgtoollogs/sqlpatch/sqlpatch_20277_2023_06_27_10_09_17/sqlpatch_invocation.log

Connecting to database...OK
Gathering database info...done
Bootstrapping registry and package to current versions...done
Determining current state...done

Current state of interim SQL patches:
Interim patch 33192694 (OJVM RELEASE UPDATE: 19.13.0.0.211019 (33192694)):
  Binary registry: Not installed
  SQL registry: Not installed
Interim patch 33561310 (OJVM RELEASE UPDATE: 19.14.0.0.220118 (33561310)):
  Binary registry: Not installed
  SQL registry: Rolled back successfully on 20-JUL-22 09.16.52.848607 PM
Interim patch 34086870 (OJVM RELEASE UPDATE: 19.16.0.0.220719 (34086870)):
  Binary registry: Not installed
  SQL registry: Rolled back successfully on 26-JAN-23 10.10.34.728972 PM
Interim patch 34411846 (OJVM RELEASE UPDATE: 19.17.0.0.221018 (34411846)):
  Binary registry: Not installed
  SQL registry: Not installed
Interim patch 34734035 (MERGE ON DATABASE RU 19.17.0.0.0 OF 34650250 34660465 24338134 25143018 26565187):
  Binary registry: Not installed
  SQL registry: Not installed
Interim patch 34786990 (OJVM RELEASE UPDATE: 19.18.0.0.230117 (34786990)):
  Binary registry: Not installed
  SQL registry: Applied successfully on 26-JAN-23 10.10.35.917858 PM
Interim patch 34861493 (RESYNC CATALOG FAILED IN ZDLRA CATALOG AFTER PROTECTED DATABASE PATCHED TO 19.17):
  Binary registry: Not installed
  SQL registry: Applied successfully on 22-MAY-23 12.21.27.534479 PM
Interim patch 34972375 (DATAPUMP BUNDLE PATCH 19.18.0.0.0):
  Binary registry: Not installed
  SQL registry: Applied successfully on 26-JAN-23 10.10.36.894411 PM
Interim patch 35050341 (OJVM RELEASE UPDATE: 19.19.0.0.230418 (35050341)):
  Binary registry: Installed
  SQL registry: Not installed
Interim patch 35160800 (GG IE FAILS WITH ORA-14400 AT SYSTEM.LOGMNRC_USER AFTER ORACLE DB UPGRADE TO 19.18DBRU):
  Binary registry: Not installed
  SQL registry: Applied successfully on 22-MAY-23 12.21.27.542160 PM
Interim patch 35261302 (DATAPUMP BUNDLE PATCH 19.19.0.0.0):
  Binary registry: Installed
  SQL registry: Not installed

Current state of release update SQL patches:
  Binary registry:
    19.19.0.0.0 Release_Update 230322020406: Installed
  SQL registry:
    Applied 19.18.0.0.0 Release_Update 230111171738 successfully on 26-JAN-23 10.10.35.913910 PM

Adding patches to installation queue and performing prereq checks...done
Installation queue:
  The following interim patches will be rolled back:
    34786990 (OJVM RELEASE UPDATE: 19.18.0.0.230117 (34786990))
    34861493 (RESYNC CATALOG FAILED IN ZDLRA CATALOG AFTER PROTECTED DATABASE PATCHED TO 19.17)
    34972375 (DATAPUMP BUNDLE PATCH 19.18.0.0.0)
    35160800 (GG IE FAILS WITH ORA-14400 AT SYSTEM.LOGMNRC_USER AFTER ORACLE DB UPGRADE TO 19.18DBRU)
  Patch 35042068 (Database Release Update : 19.19.0.0.230418 (35042068)):
    Apply from 19.18.0.0.0 Release_Update 230111171738 to 19.19.0.0.0 Release_Update 230322020406
  The following interim patches will be applied:
    35050341 (OJVM RELEASE UPDATE: 19.19.0.0.230418 (35050341))
    35261302 (DATAPUMP BUNDLE PATCH 19.19.0.0.0)

Installing patches...
Patch installation complete.  Total patches installed: 7

Validating logfiles...done
Patch 34786990 rollback: SUCCESS
  logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/34786990/25032666/34786990_rollback_UP19_2023Jun27_10_10_15.log (no errors)
Patch 34861493 rollback: SUCCESS
  logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/34861493/25121986/34861493_rollback_UP19_2023Jun27_10_11_06.log (no errors)
Patch 34972375 rollback: SUCCESS
  logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/34972375/25075164/34972375_rollback_UP19_2023Jun27_10_11_10.log (no errors)
Patch 35160800 rollback: SUCCESS
  logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/35160800/25179433/35160800_rollback_UP19_2023Jun27_10_11_10.log (no errors)
Patch 35042068 apply: SUCCESS
  logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/35042068/25183678/35042068_apply_UP19_2023Jun27_10_11_12.log (no errors)
Patch 35050341 apply: SUCCESS
  logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/35050341/25148755/35050341_apply_UP19_2023Jun27_10_11_06.log (no errors)
Patch 35261302 apply: SUCCESS
  logfile: /u01/app/oracle/cfgtoollogs/sqlpatch/35261302/25192070/35261302_apply_UP19_2023Jun27_10_12_00.log (no errors)
SQL Patching tool complete on Tue Jun 27 10:12:55 2023
```


**Task 9 - Inventory Check and Summary**
Now you see **why out-of-place patching is far superior** over in-place patching. While you prepared a new home fully unattended before, in contrast you've had to do all the manual work now all by yourself. 
In addition, the downtime was factors higher. 
And finally, in the case of the CDB2, AutoUpgrade had done the entire job for you. In the in-place patching exercise it was all on you.

Now finally, check the inventory:
```
$ORACLE_HOME/OPatch/opatch lspatches
```

Output will be:
```
$ $ORACLE_HOME/OPatch/opatch lspatches
35225526;FRA E18POD EPM | ORA-00942  TABLE OR VIEW DOES NOT EXIST WHEN RUNNING SELECT QUERY
35116995;19.X DATAPATCH FAILS WITH ORA-01422 ,ORA-20004  NO FILE FOUND IN SCRIPT RDBMS/ADMIN/NOTHING.SQL
35037877;EM CODE IS BROKEN IN 19.18
35012562;OR EXPANSION IS NOT PICKED UP IN QUERY WITH CONTAINS OPERATOR AFTER UPGRADE TO 19C
34340632;AQAH  SMART MONITORING &amp; RESILIENCY IN QUEUE KGL MEMORY USAGE
35261302;DATAPUMP BUNDLE PATCH 19.19.0.0.0
35050341;OJVM RELEASE UPDATE: 19.19.0.0.230418 (35050341)
35042068;Database Release Update : 19.19.0.0.230418 (35042068)
29585399;OCW RELEASE UPDATE 19.3.0.0.0 (29585399)

OPatch succeeded.
```

You are done with in-place patching and can continue to the next lab.