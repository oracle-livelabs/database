# Use Data Recovery Advisor to repair failures

## Introduction
This lab shows you how to repair failures using Data Recovery Advisor.

Estimated Time: 20 minutes

### About Data Recovery Advisor
The Data Recovery Advisor is an Oracle Database feature that automatically diagnoses data failures, determines and presents appropriate repair options, and performs repairs if requested by the user. By providing a centralized tool for automated data repair, Data Recovery Advisor improves the manageability and reliability of an Oracle Database.

>**Note:** Data Recovery Advisor can only be used to diagnose and repair failures in multitenant container databases (CDBs). It is not supported for pluggable databases (PDBs).

The Recovery Manager (RMAN) provides a command-line interface to the Data Recovery Advisor. You can use the following RMAN commands to diagnose and repair data failures for the Oracle Database, including for Oracle Real Application Clusters (RAC) Databases:

- `LIST FAILURE`: Use this command to view problem statements for failures and the effect of these failures on database operations. A failure number identifies each failure.

- `ADVISE FAILURE`: Use this command to view repair options, including both automated and manual repair options.

- `REPAIR FAILURE`: Use this command to automatically repair failures listed by the most recent `ADVISE FAILURE` command.

### Objectives
- Perform Oracle advised recovery

### Prerequisites
- A Free Tier, Paid or LiveLabs Oracle Cloud account.
- You have completed:
    - Lab: Prepare setup (_Free-Tier_ and _Paid Tenants_ only)
    - Lab: Initialize environment
    - Lab: Configure recovery settings
    - Lab: Configure backup settings
    - Lab: Perform and schedule backups


## Task 1: Perform Oracle advised recovery
The recovery process begins when you either suspect or discover a failure. You can discover failures in many ways, including error messages, alerts, trace files, and health checks. You can then use Data Recovery Advisor to gain information and advice about failures and repair them automatically.

In this task, you perform failure recovery using the following steps.

1. Start the SQL\*Plus prompt and connect as `sysdba` user;  
    ```
    $ <copy>./sqlplus / as sysdba</copy>
    ```
    Output:
    ```
    SQL*Plus: Release 21.0.0.0.0 - Production on Thu Dec 16 08:02:07 2021
    Version 21.3.0.0.0

    Copyright (c) 1982, 2021, Oracle.  All rights reserved.

    Connected to:
    Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
    Version 21.3.0.0.0
    ```

2. Use the following command to open the pluggable database. In this lab, `pdb1` is the pluggable database.
    ```
    SQL> <copy>alter pluggable database pdb1 open;</copy>
    ```
    Output:
    ```
    Pluggable database altered.
    ```

3. Use the following command to switch to the pluggable database container.
    ```
    SQL> <copy>alter session set container = pdb1;</copy>
    ```
    Output:
    ```
    Session altered.
    ```

4. Query the `appuser.regions` table.
    ```
    SQL> <copy>select * from appuser.regions;</copy>
    ```
    Output:
    ```
            ID NAME
    ---------- --------------------
             1 America
             2 Europe
             3 Asia
    ```

5. Query `v$datafile` view to determine the file name of the datafile that belongs to `appuser`. The `appuser.regions` table belonging to `appuser` user is stored in the `octs` tablespace.
    ```
    SQL> <copy>select name from v$datafile;</copy>
    ```
    Output:
    ```
    NAME
    --------------------------------------------------------------------------------
    /opt/oracle/oradata/CDB1/pdb1/system01.dbf
    /opt/oracle/oradata/CDB1/pdb1/sysaux01.dbf
    /opt/oracle/oradata/CDB1/pdb1/undotbs01.dbf
    /opt/oracle/oradata/CDB1/pdb1/users01.dbf
    /opt/oracle/homes/OraDB21Home1/dbs/octs.dbf
    ```

6. Use the following command to close the pluggable database.
    ```
    SQL> <copy>alter pluggable database pdb1 close;</copy>
    ```
    Output:
    ```
    Pluggable database altered.
    ```

7. Use the following command to obtain an operating system prompt.
    ```
    SQL> <copy>host;</copy>
    ```

8. Use the following Linux command to delete the data file belonging to `appuser``.`
    ```
    $ <copy>rm /opt/oracle/homes/OraDB21Home1/dbs/octs.dbf</copy>
    ```

9. Use the exit command to return to SQL\*Plus prompt.
    ```
    $ <copy>exit</copy>

    SQL>
    ```

10. Use the following command to open the pluggable database. You can see that the pluggable database cannot open because of a missing file. Perform the following steps to fix this failure and open the pluggable database.
    ```
    SQL> <copy>alter pluggable database pdb1 open;</copy>
    ```
    Output:
    ```
    alter pluggable database pdb1 open
    *
    ERROR at line 1:
    ORA-01157: cannot identify/lock data file 13 - see DBWR trace file
    ORA-01110: data file 13:
    '/opt/oracle/homes/OraDB21Home1/dbs/octs.dbf'
    ```

11. Exit the SQL\*Plus prompt.
    ```
    SQL> <copy>exit;</copy>
    ```

12. Start the RMAN prompt.
    ```
    $ <copy>./rman</copy>
    ```
    Output:
    ```
    Recovery Manager: Release 21.0.0.0.0 - Production on Thu Dec 16 08:05:11 2021
    Version 21.3.0.0.0

    Copyright (c) 1982, 2021, Oracle and/or its affiliates.  All rights reserved.
    ```

13. Use the following command to connect to the target Oracle Database.
    ```
    RMAN> <copy>connect target;</copy>
    ```
    Output:
    ```
    connected to target database: CDB1 (DBID=1016703368)
    ```

14. Use the following command to list all the failures known to the Data Recovery Advisor. In the following output, you can see that one failure with failure id 342 is listed.
    ```
    RMAN> <copy>list failure;</copy>
    ```
    Output:
    ```
    using target database control file instead of recovery catalog
    Database Role: PRIMARY

    List of Database Failures
    =========================

    Failure ID Priority Status    Time Detected Summary
    ---------- -------- --------- ------------- -------
    342        HIGH     OPEN      16-DEC-21     One or more non-system datafiles are missing
    ```

15. Use the following command to determine repair options, both automatic and manual. In the following output, you can see that one failure with failure id 342 is listed with summary and restore options.
    ```
    RMAN> <copy>advise failure;</copy>
    ```
    Output:
    ```
    Database Role: PRIMARY

    List of Database Failures
    =========================

    Failure ID Priority Status    Time Detected Summary
    ---------- -------- --------- ------------- -------
    342        HIGH     OPEN      16-DEC-21     One or more non-system datafiles are missing

    analyzing automatic repair options; this may take some time
    allocated channel: ORA_DISK_1
    channel ORA_DISK_1: SID=278 device type=DISK
    analyzing automatic repair options complete

    Mandatory Manual Actions
    ========================
    no manual actions available

    Optional Manual Actions
    =======================
    1. If file /opt/oracle/homes/OraDB21Home1/dbs/octs.dbf was unintentionally renamed or moved, restore it

    Automated Repair Options
    ========================
    Option Repair Description
    ------ ------------------
    1      Restore and recover datafile 13  
      Strategy: The repair includes complete media recovery with no data loss
      Repair script: /opt/oracle/diag/rdbms/orcl/orcl/hm/reco_4206624240.hm
    ```

16. Use the following command to correct the problems. In the following output, you can see that the failure is repaired and the datafile is recovered.
    ```
    RMAN> <copy>repair failure;</copy>
    ```
    Output:
    ```
    Strategy: The repair includes complete media recovery with no data loss
    Repair script: /opt/oracle/diag/rdbms/orcl/orcl/hm/reco_4206624240.hm

    contents of repair script:
       # restore and recover datafile
       sql 'pdb1' 'alter database datafile 13 offline';
       restore ( datafile 13 );
       recover datafile 13;
       sql 'pdb1' 'alter database datafile 13 online';

    Do you really want to execute the above repair (enter YES or NO)? YES
    executing repair script

    sql statement: alter database datafile 13 offline

    Starting restore at 16-DEC-21
    using channel ORA_DISK_1

    channel ORA_DISK_1: starting datafile backup set restore
    channel ORA_DISK_1: specifying datafile(s) to restore from backup set
    channel ORA_DISK_1: restoring datafile 00013 to /opt/oracle/homes/OraDB21Home1/dbs/octs.dbf
    channel ORA_DISK_1: reading from backup piece /opt/oracle/recovery_area/CDB1/D33E529B0AE432F7E053F5586864ED09/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T075421_jvow6k4f_.bkp
    channel ORA_DISK_1: piece handle=/opt/oracle/recovery_area/CDB1/D33E529B0AE432F7E053F5586864ED09/backupset/2021_12_16/o1_mf_nnndf_TAG20211216T075421_jvow6k4f_.bkp tag=TAG20211216T075421
    channel ORA_DISK_1: restored backup piece 1
    channel ORA_DISK_1: restore complete, elapsed time: 00:00:07
    Finished restore at 16-DEC-21

    Starting recover at 16-DEC-21
    using channel ORA_DISK_1

    starting media recovery
    media recovery complete, elapsed time: 00:00:00

    Finished recover at 16-DEC-21

    sql statement: alter database datafile 13 online
    repair failure complete
    ```

17. Use the following command to list all the failures known to the Data Recovery Advisor. In the following output, you can see no failures listed.
    ```
    RMAN> <copy>list failure;</copy>
    ```
    Output:
    ```
    Database Role: PRIMARY

    no failures found that match specification
    ```

18. Exit the RMAN prompt.
    ```
    RMAN> <copy>exit;</copy>
    ```

19. Start the SQL\*Plus prompt and connect as `sysdba` user;
    ```
    $ <copy>./sqlplus / as sysdba</copy>
    ```
    Output:
    ```
    SQL*Plus: Release 21.0.0.0.0 - Production on Thu Dec 16 08:06:14 2021
    Version 21.3.0.0.0

    Copyright (c) 1982, 2021, Oracle.  All rights reserved.

    Connected to:
    Oracle Database 21c Enterprise Edition Release 21.0.0.0.0 - Production
    Version 21.3.0.0.0
    ```

20. Use the following command to open the pluggable database. You can see that the pluggable database can open now as the failure is fixed.
    ```
    SQL> <copy>alter pluggable database pdb1 open;</copy>
    ```
    Output:
    ```
    Pluggable database altered.
    ```

21. Use the following command to switch to the pluggable database container.
    ```
    SQL> <copy>alter session set container = pdb1;</copy>
    ```
    Output:
    ```
    Session altered.
    ```

22. Query the `appuser.regions` table.
    ```
    SQL> <copy>select * from appuser.regions;</copy>
    ```
    Output:
    ```
            ID NAME
    ---------- --------------------
             1 America
             2 Europe
             3 Asia
    ```

23. Exit the SQL\*Plus prompt.
    ```
    SQL> <copy>exit;</copy>
    ```

You may now **proceed to the next lab**.


## Acknowledgements
- **Author**: Suresh Mohan, Database User Assistance Development Team
- **Contributors**: Suresh Rajan, Manish Garodia, Subhash Chandra, Ramya P
- **Last Updated By & Date**: Suresh Mohan, June 2022
