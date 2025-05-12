# Restore Database

## Introduction
This lab shows you how to restore files and recover from failures.

Estimated Time: 20 minutes

### Objectives
-   Perform restore and recovery

### Prerequisites
This lab assumes you have:
-   An Oracle Cloud account
-   Completed all previous labs successfully


## Task 1: Perform Recovery
The recovery process begins when you either suspect or discover a failure. You can discover failures in many ways, including error messages, alerts, trace files, and health checks.

1. Start the SQL\*Plus prompt and connect as `sysdba` user;  
    ```
    $ <copy>./sqlplus / as sysdba</copy>
    ```

2. Open the PDB. In this lab, it is `pdb1`.
    ```
    SQL> <copy>alter pluggable database pdb1 open;</copy>
    ```
    Output:
    ```
    Pluggable database altered.
    ```

3. Switch to the PDB container.
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
    /opt/oracle/product/23.4.0/dbhome_1/dbs/octs.dbf
    ```

6. Close the PDB.
    ```
    SQL> <copy>alter pluggable database pdb1 close;</copy>
    ```
    Output:
    ```
    Pluggable database altered.
    ```

7. Obtain an operating system prompt.
    ```
    SQL> <copy>host;</copy>
    ```

8. Delete the data file belonging to `appuser``.`
    ```
    $ <copy>rm /opt/oracle/product/23.4.0/dbhome_1/dbs/octs.dbf</copy>
    ```

9. Return to SQL\*Plus prompt.
    ```
    $ <copy>exit</copy>

    SQL>
    ```

10. Open the PDB again. You can see that the PDB cannot be opened because of a missing file. Perform the rest of the steps in this task to fix this failure and open the PDB.
    ```
    SQL> <copy>alter pluggable database pdb1 open;</copy>
    ```
    Output:
    ```
    alter pluggable database pdb1 open
    *
    ERROR at line 1:
    ORA-01157: cannot identify/lock data file 16 - see DBWR trace file
    ORA-01110: data file 16:
    '/opt/oracle/product/23.4.0/dbhome_1/dbs/octs.dbf'
    Help: https://docs.oracle.com/error-help/db/ora-01157/f'
    ```

11. Exit the SQL\*Plus prompt.
    ```
    SQL> <copy>exit;</copy>
    ```

12. Start the RMAN prompt.
    ```
    $ <copy>./rman</copy>
    ```

13. Connect to the target Oracle Database.
    ```
    RMAN> <copy>connect target;</copy>
    ```
    Output:
    ```
    connected to target database: CDB1 (DBID=1701812036)
    ```


14. Shutdown the database.
    ```
    RMAN> <copy>shutdown immediate;</copy>
    ```
    Output:
    ```
    shutdown immediate;
    using target database control file instead of recovery catalog
    database closed
    database dismounted
    Oracle instance shut down
    ```

15. Mount the database.
    ```
   RMAN> <copy>startup mount;</copy>
    ```
    Output:
    ```
    startup mount;
    connected to target database (not started)
    Oracle instance started
    database mounted
    
    Total System Global Area   10013446704 bytes
    
    Fixed Size                     5370416 bytes
    Variable Size               2181038080 bytes
    Database Buffers            7818182656 bytes
    Redo Buffers                   8855552 bytes
    ```

16. Restore the database. In the following output, you can see that the datafile has been restored.
    ```
   RMAN> <copy>restore database;</copy>
    ```
    Output:
    ```
    Starting restore at 04-OCT-24
    allocated channel: ORA_DISK_1
    channel ORA_DISK_1: SID=2 device type=DISK
    
    skipping datafile 2; already restored to file /opt/oracle/oradata/CDB1/pdbseed/system01.dbf
    skipping datafile 4; already restored to file /opt/oracle/oradata/CDB1/pdbseed/sysaux01.dbf
    skipping datafile 9; already restored to file /opt/oracle/oradata/CDB1/pdbseed/undotbs01.dbf
    channel ORA_DISK_1: starting datafile backup set restore
    channel ORA_DISK_1: specifying datafile(s) to restore from backup set
    channel ORA_DISK_1: restoring datafile 00012 to /opt/oracle/oradata/CDB1/pdb1/system01.dbf
    channel ORA_DISK_1: restoring datafile 00013 to /opt/oracle/oradata/CDB1/pdb1/sysaux01.dbf
    channel ORA_DISK_1: restoring datafile 00014 to /opt/oracle/oradata/CDB1/pdb1/undotbs01.dbf
    channel ORA_DISK_1: restoring datafile 00015 to /opt/oracle/oradata/CDB1/pdb1/users01.dbf
    channel ORA_DISK_1: restoring datafile 00016 to /opt/oracle/product/23.4.0/dbhome_1/dbs/octs.dbf
    channel ORA_DISK_1: reading from backup piece /opt/oracle/recovery_area/CDB1/1CF500B83D440585E0634B0E4664AA19/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T132951_mhx73xwo_.bkp
    channel ORA_DISK_1: piece handle=/opt/oracle/recovery_area/CDB1/1CF500B83D440585E0634B0E4664AA19/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T132951_mhx73xwo_.bkp tag=TAG20241003T132951
    channel ORA_DISK_1: restored backup piece 1
    channel ORA_DISK_1: restore complete, elapsed time: 00:00:25
    channel ORA_DISK_1: starting datafile backup set restore
    channel ORA_DISK_1: specifying datafile(s) to restore from backup set
    channel ORA_DISK_1: restoring datafile 00001 to /opt/oracle/oradata/CDB1/system01.dbf
    channel ORA_DISK_1: restoring datafile 00003 to /opt/oracle/oradata/CDB1/sysaux01.dbf
    channel ORA_DISK_1: restoring datafile 00007 to /opt/oracle/oradata/CDB1/users01.dbf
    channel ORA_DISK_1: restoring datafile 00011 to /opt/oracle/oradata/CDB1/undotbs01.dbf
    channel ORA_DISK_1: reading from backup piece /opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T133717_mhx7jg87_.bkp
    channel ORA_DISK_1: piece handle=/opt/oracle/recovery_area/CDB1/backupset/2024_10_03/o1_mf_nnndf_TAG20241003T133717_mhx7jg87_.bkp tag=TAG20241003T133717
    channel ORA_DISK_1: restored backup piece 1
    channel ORA_DISK_1: restore complete, elapsed time: 00:00:35
    Finished restore at 04-OCT-24
    ```

17. Recover the database. In the following output, you can see the recovery completed successfully.
    ```
   RMAN> <copy>recover database;</copy>
    ```
    Output:
    ```
    Starting recover at 04-OCT-24
    using channel ORA_DISK_1
    applied offline range to datafile 00012
    offline range RECID=23 STAMP=1181398744
    applied offline range to datafile 00013
    offline range RECID=22 STAMP=1181398744
    applied offline range to datafile 00014
    offline range RECID=21 STAMP=1181398744
    applied offline range to datafile 00015
    offline range RECID=20 STAMP=1181398744
    applied offline range to datafile 00016
    offline range RECID=19 STAMP=1181398744
    
    starting media recovery
    
    archived log for thread 1 with sequence 307 is already on disk as file /opt/oracle/recovery_area/CDB1/archivelog/2024_10_03/o1_mf_1_307_mhx7kk9p_.arc
    archived log for thread 1 with sequence 308 is already on disk as file /opt/oracle/recovery_area/CDB1/archivelog/2024_10_03/o1_mf_1_308_mhy4yolg_.arc
    archived log for thread 1 with sequence 309 is already on disk as file /opt/oracle/recovery_area/CDB1/archivelog/2024_10_04/o1_mf_1_309_mhyhgjcc_.arc
    archived log for thread 1 with sequence 310 is already on disk as file /opt/oracle/recovery_area/CDB1/archivelog/2024_10_04/o1_mf_1_310_mhyxr7fn_.arc
    archived log file name=/opt/oracle/recovery_area/CDB1/archivelog/2024_10_03/o1_mf_1_307_mhx7kk9p_.arc thread=1 sequence=307
    archived log file name=/opt/oracle/recovery_area/CDB1/archivelog/2024_10_03/o1_mf_1_308_mhy4yolg_.arc thread=1 sequence=308
    media recovery complete, elapsed time: 00:00:20
    Finished recover at 04-OCT-24
    ```
18. Open the database.
    ```
    RMAN> <copy>alter database open;</copy>
    ```
    Output:
    ```
    alter database open;
    Statement processed
    ```

19. Exit the RMAN prompt.
    ```
    RMAN> <copy>exit;</copy>
    ```

20. Start the SQL\*Plus prompt and connect as `sysdba` user;
    ```
    $ <copy>./sqlplus / as sysdba</copy>
    ```

21. Open the PDB. You can see that the PDB can be opened now that the failure is fixed.
    ```
    SQL> <copy>alter pluggable database pdb1 open;</copy>
    ```
    Output:
    ```
    Pluggable database altered.
    ```

22. Switch to the PDB container.
    ```
    SQL> <copy>alter session set container = pdb1;</copy>
    ```
    Output:
    ```
    Session altered.
    ```

23. Query the `appuser.regions` table.
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

24. Exit the SQL\*Plus prompt.

    ```
    SQL> <copy>exit;</copy>
    ```


You may now **proceed to the next lab**.


## Acknowledgements
- **Author**: Suresh Mohan, Database User Assistance Development Team
- **Contributors**: Suresh Rajan, Manish Garodia, Subhash Chandra, Ramya P
- **Last Updated By & Date**: Suresh Mohan, October 2024

