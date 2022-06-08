# Decrease the Transportable Tablespace (TTS) Import and Export Time

## Introduction

In Oracle Database 19c, both Oracle Data Pump Import and Oracle Data Pump Export utilities have new parameters that decrease the time it takes to do imports and exports of a transportable tablespace (TTS).

When Oracle Data Pump Import runs in transportable tablespace mode, the metadata from another database is loaded by using either a database link (specified with the `NETWORK_LINK` parameter), or by specifying a dump file that has metadata. The actual data files are typically copied over to the target system. The `TRANSPORTABLE` parameter specifies whether the transportable option should be used during a table mode import (specified with the `TABLES` parameter), or a full mode import (specified with the `FULL` parameter). Oracle Database 19c introduces two new values for this parameter,  `KEEP_READ_ONLY` and `NO_BITMAP_REBUILD`, which help to decrease the time it takes during a transportable tablespace (TTS) import operation.

- `KEEP_READ_ONLY`: Setting this value lets you import tablespace files mounted on two different databases. The database doesn't automatically rebuild tablespace bitmaps to reclaim space during import, making the import process faster at the expense of regaining free space within the tablespace data files.

- `NO_BITMAP_REBUILD`: Setting this value causes the transportable data files header bitmaps to not be rebuilt during the import. Not reclaiming unused data segments reduces the time of the import operation. You can rebuild bitmaps at a later time by using the procedure `dbms_space_admin.tablespace_rebuild_bitmaps`.

To export in transportable tablespace mode with Oracle Data Pump Export, your tablespaces need to be in read-only mode. Starting in Oracle Database 19c, Oracle Data Pump Export has a new parameter, `TTS_CLOSURE_CHECK`, that can decrease export time. When `TTS_CLOSURE_CHECK` is set to `TEST_MODE`, you can keep your tablespaces in READ WRITE mode during the export and obtain timing requirements for the export operation. Keep in mind that `TEST_MODE` is for testing purposes only and the resulting dump file is unavailable for import. Setting the `TTS_CLOSURE_CHECK` to `OFF` skips the closure check and is another way to decrease export time. A closure check is unnecessary when the DBA knows that the transportable set is self-contained.

In this lab, you try the time-saving parameters when performing two import and two export operations using Oracle Data Pump Import and Oracle Data Pump Export respectively. During the import operations, you set the `TRANSPORTABLE` parameter to `KEEP_READ_ONLY` and then to `NO_BITMAP_REBUILD`. During the export operations, you set the `TTS_CLOSURE_CHECK` parameter to `TEST _MODE` and then to `OFF`. Use the `workshop-installed` compute instance.


Estimated Time: 25 minutes

Watch the video below for a quick walk through of the lab.

[](youtube:oK9hiZIXXC0)

### Objectives

In this lab, you will:

- Prepare your environment
- Export the `TEST` tablespace from `PDB1` in transportable tablespace mode
- Copy PDB1's data files to PDB2's target directory and create the `HR` user in PDB2
- Import PDB1's `TEST` tablespace into PDB2 while keeping the imported tablespace in read-only mode
- Import PDB1's `TEST` tablespace into PDB2 without rebuilding header bitmaps in the data file
- Export the `TEST` tablespace from `PDB1` with the `TTS_CLOSURE_CHECK` parameter set to `TEST_MODE` to get a timing estimation of the TTS export operation
- Export the `TEST` tablespace from `PDB1` with the `TTS_CLOSURE_CHECK` parameter set to `OFF` to skip the closure check
- Verify that you can import the `TEST` tablespace from PDB1 into PDB2
- Reset your environment


### Prerequisites

This lab assumes you have:
- Obtained and signed in to your `workshop-installed` compute instance.

## Task 1: Prepare your environment

> **NOTE:** Unless otherwise stated, all passwords will be `Ora4U_1234`. When copying and pasting a command that includes a password, please replace the word `password` with `Ora4U_1234`. This only applies to instances created through OCI Resource Manager with our provided terraform scripts.

In this lab, you require two PDBs. The `workshop-installed` compute instance comes with a container database (CDB1) that has one PDB already created called PDB1. In this task, you add another PDB to CDB1 called PDB2. You also create a tablespace called `TEST` in PDB1 and make sure that there is no tablespace by that name in PDB2.

1. Open a terminal window on the desktop.

2. Set the Oracle environment variables. At the prompt, enter **CDB1**.

    ```
    <copy>. oraenv</copy>
    CDB1
    ```

3. Run the `cleanup_PDBs_in_CDB1.sh` shell script to recreate PDB1 and remove other PDBs in CDB1 if they exist. You can ignore any error messages.

    ```
    $ <copy>$HOME/labs/19cnf/cleanup_PDBs_in_CDB1.sh</copy>
    ```


4. Run the `recreate_PDB2_in_CDB1.sh` shell script to create PDB2 in CDB1. You can ignore any error messages.

    ```
    $ <copy>$HOME/labs/19cnf/recreate_PDB2_in_CDB1.sh</copy>
    ```

5. Run the `create_drop_TBS.sh` shell script.

    The first part of this script connects to PDB1 and creates a `TEST` tablespace, adds an `HR.TABTEST` table to that tablespace and populates it, and then defines an Oracle Data Pump dump file directory called `dp_pdb1` as `/tmp`. The second part of the script connects to PDB2 and deletes the `TEST` tablespace. You can ignore any error messages.

    ```
    $ <copy>$HOME/labs/19cnf/create_drop_TBS.sh</copy>
    ```

6. Connect to PDB1 in CDB1 as the `SYS` user.

    ```
    $ <copy>sqlplus system/password@PDB1</copy>
    ```

7. View the content of the `HR.TABTEST` table.

    ```
    SQL> <copy>SELECT * FROM HR.TABTEST;</copy>

    LABEL
    ----------------------------------------------
    DATA FROM system.tabtest ON TABLESPACE test
    ```

8. Connect to PDB2 in CDB1 as the `SYS` user.

    ```
    $ <copy>CONNECT system/password@PDB2</copy>
    Connected.
    ```

9. Verify that the `TEST` tablespace does not exist in `PDB2`. The results show that it does not exist.

    ```
    SQL> <copy>SELECT tablespace_name FROM dba_tablespaces;</copy>

    TABLESPACE_NAME
    ------------------------------
    SYSTEM
    SYSAUX
    UNDOTBS1
    TEMP
    USERS
    ```

10. If the `TEST` tablespace does exist, run the following command to drop it.

    ```
    SQL> <copy>DROP TABLESPACE test INCLUDING CONTENTS AND DATAFILES;</copy>

    Tablespace dropped.
    ```

## Task 2: Export the `TEST` tablespace from `PDB1` in transportable tablespace mode

1. Connect to PDB1 in CDB1 as the `SYS` user.

    ```
    $ <copy>CONNECT system/password@PDB1</copy>
    Connected.
    ```

2. Make the `TEST` tablespace read-only.

    ```
    SQL> <copy>ALTER TABLESPACE TEST READ ONLY;</copy>

    Tablespace altered.
    ```

3. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT</copy>
    ```

4. Run the following Oracle Data Pump Export command (`expdp`) to export the `TEST` tablespace from `PDB1` in transportable tablespace mode. A dump file is created in `/tmp/PDB1.dmp`. Please note the use of `password`.

    ```
    $ <copy>expdp \"sys/password@PDB1 as sysdba\" \
      DIRECTORY=dp_pdb1 \
      DUMPFILE=PDB1.dmp \
      TRANSPORT_TABLESPACES=test \
      TRANSPORT_FULL_CHECK=YES \
      LOGFILE=tts.log \
      REUSE_DUMPFILES=YES</copy>

    Export: Release 19.0.0.0.0 - Production on Thu Aug 26 14:23:59 2021
    Version 19.12.0.0.0

    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Starting "SYS"."SYS_EXPORT_TRANSPORTABLE_01":  "sys/********@PDB1 AS SYSDBA" DIRECTORY=dp_pdb1 DUMPFILE=PDB1.dmp TRANSPORT_TABLESPACES=test TRANSPORT_FULL_CHECK=YES LOGFILE=tts.log REUSE_DUMPFILES=YES
    Processing object type TRANSPORTABLE_EXPORT/STATISTICS/TABLE_STATISTICS
    Processing object type TRANSPORTABLE_EXPORT/STATISTICS/MARKER
    Processing object type TRANSPORTABLE_EXPORT/PLUGTS_BLK
    Processing object type TRANSPORTABLE_EXPORT/POST_INSTANCE/PLUGTS_BLK
    Processing object type TRANSPORTABLE_EXPORT/TABLE
    Master table "SYS"."SYS_EXPORT_TRANSPORTABLE_01" successfully loaded/unloaded
    ******************************************************************************
    Dump file set for SYS.SYS_EXPORT_TRANSPORTABLE_01 is:
      /tmp/PDB1.dmp
    ******************************************************************************
    Datafiles required for transportable tablespace TEST:
      /u01/app/oracle/oradata/CDB1/PDB1/test01.dbf
    Job "SYS"."SYS_EXPORT_TRANSPORTABLE_01" successfully completed at Thu Aug 26 14:24:35 2021 elapsed 0 00:00:33
    ```


## Task 3: Copy PDB1's data files to PDB2's target directory and create the HR user in PDB2

1. Connect to PDB2 as the `SYS` user.

    ```
    $ <copy>sqlplus system/password@PDB2</copy>
    ```

2. Create a target directory in PDB2 called `dp_pdb2` equal to `/tmp`. Later on during the import operations, Oracle Data Pump Import uses this directory.

    ```
    SQL> <copy>CREATE DIRECTORY dp_pdb2 AS '/tmp';</copy>

    Directory created.
    ```

3. Create an `HR` user in PDB2. You need to pre-create the users that have objects in the transportable tablespace.

    ```
    SQL> <copy>CREATE USER hr IDENTIFIED BY password;</copy>

    User created.
    ```

4. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT</copy>
    ```

5. Copy the data files from the `TEST` tablespace of PDB1 to PDB2's target directory.

    ```
    $ <copy>cp /u01/app/oracle/oradata/CDB1/PDB1/test01.dbf  /u01/app/oracle/oradata/CDB1/PDB2</copy>
    ```


## Task 4: Import PDB1's `TEST` tablespace into `PDB2` while keeping the imported tablespace in read-only mode

1. Run the Oracle Data Pump Import utility, `impdp`, to import PDB1's `TEST` tablespace into `PDB2`. Set the `TRANSPORTABLE` parameter equal to `KEEP_READ_ONLY`. The `DIRECTORY` parameter specifies the location in which the import job can find the dump file set. Please note the use of `password`.

    *The `KEEP_READ_ONLY` value for the `TRANSPORTABLE` parameter is a new feature!*

    ```
    $ <copy>impdp \'sys/password@PDB2 as sysdba\' \
      DIRECTORY=dp_pdb2 \
      DUMPFILE=PDB1.dmp \
      TRANSPORT_DATAFILES='/u01/app/oracle/oradata/CDB1/PDB2/test01.dbf' \
      TRANSPORTABLE=KEEP_READ_ONLY</copy>

    Import: Release 19.0.0.0.0 - Production on Thu Aug 26 14:30:05 2021
    Version 19.12.0.0.0
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Master table "SYS"."SYS_IMPORT_TRANSPORTABLE_01" successfully loaded/unloaded
    Starting "SYS"."SYS_IMPORT_TRANSPORTABLE_01":  "sys/********@PDB2 AS SYSDBA" DIRECTORY=dp_pdb2 DUMPFILE=PDB1.dmp TRANSPORT_DATAFILES=/u01/app/oracle/oradata/CDB1/PDB2/test01.dbf TRANSPORTABLE=KEEP_READ_ONLY
    Processing object type TRANSPORTABLE_EXPORT/PLUGTS_BLK
    Processing object type TRANSPORTABLE_EXPORT/TABLE
    Processing object type TRANSPORTABLE_EXPORT/STATISTICS/TABLE_STATISTICS
    Processing object type TRANSPORTABLE_EXPORT/STATISTICS/MARKER
    Processing object type TRANSPORTABLE_EXPORT/POST_INSTANCE/PLUGTS_BLK
    Job "SYS"."SYS_IMPORT_TRANSPORTABLE_01" successfully completed at Thu Aug 26 14:30:31 2021 elapsed 0 00:00:22
    ```

2. Connect to PDB2.

    ```
    $ <copy>sqlplus system/password@PDB2</copy>
    ```

3. Verify that the `TEST` tablespace is still in read-only mode after the import.

    ```
    SQL> <copy>SELECT status FROM dba_tablespaces WHERE  tablespace_name='TEST';</copy>

    STATUS
    --------
    READ ONLY
    ```

## Task 5: Import PDB1's `TEST` tablespace into PDB2 without rebuilding header bitmaps in the data file

1. Still connected to PDB2, drop the `TEST` tablespace that you previously imported into PDB2.

    ```
    SQL> <copy>DROP TABLESPACE test INCLUDING CONTENTS AND DATAFILES;</copy>

    Tablespace dropped.
    ```

2. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT</copy>
    ```

3. Because you already exported the `TEST` tablespace in the first part of this lab, you can reuse the `/tmp/PDB1.dmp` dump file. Copy the data files of the `TEST` tablespace of PDB1 to the target directory of PDB2.

    ```
    $ <copy>cp /u01/app/oracle/oradata/CDB1/PDB1/test01.dbf  /u01/app/oracle/oradata/CDB1/PDB2</copy>
    ```

4. Run the following Oracle Data Dump Import command to import PDB1's `TEST` tablespace into PDB2 without rebuilding the bitmap. Set the `TRANSPORTABLE` parameter equal to `NO_BITMAP_REBUILD`. Please note the use of `password`.

    *The `NO_BITMAP_REBUILD` value for the `TRANSPORTABLE` parameter is a new feature!*

    ```
    $ <copy>impdp \'sys/password@PDB2 as sysdba\' \
    DIRECTORY=dp_pdb2 \
    DUMPFILE=PDB1.dmp \
    TRANSPORT_DATAFILES='/u01/app/oracle/oradata/CDB1/PDB2/test01.dbf' \
    TRANSPORTABLE=NO_BITMAP_REBUILD</copy>

    Import: Release 19.0.0.0.0 - Production on Thu Aug 26 14:33:57 2021
    Version 19.12.0.0.0

    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Master table "SYS"."SYS_IMPORT_TRANSPORTABLE_01" successfully loaded/unloaded
    Starting "SYS"."SYS_IMPORT_TRANSPORTABLE_01":  "sys/********@PDB2 AS SYSDBA" DIRECTORY=dp_pdb2 DUMPFILE=PDB1.dmp TRANSPORT_DATAFILES=/u01/app/oracle/oradata/CDB1/PDB2/test01.dbf TRANSPORTABLE=NO_BITMAP_REBUILD
    Processing object type TRANSPORTABLE_EXPORT/PLUGTS_BLK
    Processing object type TRANSPORTABLE_EXPORT/TABLE
    Processing object type TRANSPORTABLE_EXPORT/STATISTICS/TABLE_STATISTICS
    Processing object type TRANSPORTABLE_EXPORT/STATISTICS/MARKER
    Processing object type TRANSPORTABLE_EXPORT/POST_INSTANCE/PLUGTS_BLK
    Job "SYS"."SYS_IMPORT_TRANSPORTABLE_01" successfully completed at Thu Aug 26 14:34:03 2021 elapsed 0 00:00:05
    ```

5. Connect to PDB2 as the `SYS` user.

    ```
    $ <copy>sqlplus sys/password@PDB2 AS SYSDBA</copy>
    ```

6. Verify that the `TEST` tablespace is in `READ ONLY` mode after the import.

    ```
    SQL> <copy>SELECT status FROM dba_tablespaces WHERE  tablespace_name='TEST';</copy>

    STATUS
    ----------
    READ ONLY
    ```

7. Question: Can you set the tablespace to `READ WRITE` even though the bitmaps are not rebuilt? Try doing so with the following command.

    ```
    SQL> <copy>ALTER TABLESPACE test READ WRITE;</copy>

    Tablespace altered.
    ```

    Answer: The result indicates that you can set the tablespace to `READ WRITE`.

8. Rebuild the bitmaps by using the `DBMS_SPACE_ADMIN.TABLESPACE_REBUILD_BITMAPS` procedure.

    ```
    SQL> <copy>exec DBMS_SPACE_ADMIN.TABLESPACE_REBUILD_BITMAPS('TEST')</copy>

    PL/SQL procedure successfully completed.
    ```

9. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT</copy>
    ```

## Task 6: Export the `TEST` tablespace from `PDB1` with the `TTS_CLOSURE_CHECK` parameter set to `TEST_MODE` to get a timing estimation of the TTS export operation

1. Execute the `create_drop_TBS.sh` shell script. You can ignore the error messages.

    ```
    $ <copy>$HOME/labs/19cnf/create_drop_TBS.sh</copy>
    ```

2. Run the Oracle Data Pump Export transportable operation with the `TTS_CLOSURE_CHECK` parameter set to `TEST_MODE` mode. Please note the use of `password`.

    *The `TEST_MODE` value for the `TTS_CLOSURE_CHECK` parameter is a new feature!*

    ```
    $ <copy>expdp \"sys/password@PDB1 as sysdba\" \
      DIRECTORY=dp_pdb1 \
      dumpfile=PDB1.dmp \
      TRANSPORT_TABLESPACES=test \
      TRANSPORT_FULL_CHECK=YES \
      TTS_CLOSURE_CHECK=TEST_MODE \
      LOGFILE=tts.log \
      REUSE_DUMPFILES=YES</copy>

    Export: Release 19.0.0.0.0 - Production on Thu Aug 26 14:37:17 2021
    Version 19.12.0.0.0

    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Starting "SYS"."SYS_EXPORT_TRANSPORTABLE_01":  "sys/********@PDB1 AS SYSDBA" DIRECTORY=dp_pdb1 dumpfile=PDB1.dmp TRANSPORT_TABLESPACES=test TRANSPORT_FULL_CHECK=YES TTS_CLOSURE_CHECK=TEST_MODE LOGFILE=tts.log REUSE_DUMPFILES=YES
    Processing object type TRANSPORTABLE_EXPORT/STATISTICS/TABLE_STATISTICS
    Processing object type TRANSPORTABLE_EXPORT/STATISTICS/MARKER
    Processing object type TRANSPORTABLE_EXPORT/PLUGTS_BLK
    Processing object type TRANSPORTABLE_EXPORT/POST_INSTANCE/PLUGTS_BLK
    Processing object type TRANSPORTABLE_EXPORT/TABLE
    Master table "SYS"."SYS_EXPORT_TRANSPORTABLE_01" successfully loaded/unloaded
    ******************************************************************************
    Dump file set for SYS.SYS_EXPORT_TRANSPORTABLE_01 is:
      /tmp/PDB1.dmp
    Dump file set is unusable. TEST_MODE requested.
    ******************************************************************************
    Datafiles required for transportable tablespace TEST:
      /u01/app/oracle/oradata/CDB1/PDB1/test01.dbf
    Job "SYS"."SYS_EXPORT_TRANSPORTABLE_01" successfully completed at Thu Aug 26 14:37:46 2021 elapsed 0 00:00:28
    ```

3. Question: Can you use the dump file to import the `TEST` tablespace into PDB2? Try running the following Oracle Data Pump Import command to find out. Please note the use of `password`.

    ```
    $ <copy>impdp \"sys/password@PDB2 as sysdba\" \
      DIRECTORY=dp_pdb2 \
      dumpfile=PDB1.dmp \
      TRANSPORT_DATAFILES='/u02/app/oracle/oradata/CDB1/PDB2/test01.dbf' \
      LOGFILE=tts.log</copy>

    Import: Release 19.0.0.0.0 - Production on Thu Aug 26 14:39:48 2021
    Version 19.12.0.0.0

    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    ORA-39001: invalid argument value
    ORA-39000: bad dump file specification
    ORA-39398: Cannot load data. Data Pump dump file "/tmp/PDB1.dmp" was created in TEST_MODE.
    ```

    Answer: The output indicates that the resulting export dump file is not available for use by the Oracle Data Pump Import utility.

## Task 7: Export the `TEST` tablespace from `PDB1` with the `TTS_CLOSURE_CHECK` parameter set to `OFF` to skip the closure check

1. Try running the Oracle Data Pump Export transportable operation again with the `TTS_CLOSURE_CHECK` parameter set to `OFF`. This setting skips the closure check. Of course you are sure that the transportable tablespace set is contained! Please note the use of `password`.

    *The `OFF` value for the `TTS_CLOSURE_CHECK` parameter is a new feature!*

    ```
    $ <copy>expdp \"sys/password@PDB1 as sysdba\" \
    DIRECTORY= dp_pdb1 \
    dumpfile=PDB1.dmp \
    TRANSPORT_TABLESPACES=test \
    TTS_CLOSURE_CHECK=OFF \
    LOGFILE=tts.log \
    REUSE_DUMPFILES=YES</copy>

    Export: Release 19.0.0.0.0 - Production on Thu Aug 26 14:42:52 2021
    Version 19.12.0.0.0

    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Starting "SYS"."SYS_EXPORT_TRANSPORTABLE_01":  "sys/********@PDB1 AS SYSDBA" DIRECTORY=dp_pdb1 dumpfile=PDB1.dmp TRANSPORT_TABLESPACES=test TTS_CLOSURE_CHECK=OFF LOGFILE=tts.log REUSE_DUMPFILES=YES
    Processing object type TRANSPORTABLE_EXPORT/STATISTICS/TABLE_STATISTICS
    Processing object type TRANSPORTABLE_EXPORT/STATISTICS/MARKER
    ORA-39123: Data Pump transportable tablespace job aborted
    ORA-39185: The transportable tablespace failure list is

    ORA-29335: tablespace 'TEST' is not read only
    Job "SYS"."SYS_EXPORT_TRANSPORTABLE_01" stopped due to fatal error at Thu Aug 26 14:42:57 2021 elapsed 0 00:00:05
    ```

    Notice that the export operation fails because the `TEST` tablespace is not read-only.

2. Question: When the `TTS_CLOSURE_CHECK` parameter is set to a value other than `TEST_MODE`, can you export the tablespace in `READ WRITE` mode?

    Answer: No, only `TEST_MODE` allows you to test the export operation timing. If you use other values such as `ON`, `OFF`, or `FULL`, the tablespace must be set to `READ ONLY` before you do the export.

3. Connect to PDB1 as the `SYS` user.

    ```
    $ <copy>sqlplus system/password@PDB1</copy>
    ```

4. Set the `TEST` tablespace to be read-only.

    ```
    SQL> <copy>ALTER TABLESPACE test READ ONLY;</copy>

    Tablespace altered.
    ```

5. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT</copy>
    ```

6. Export the tablespace again with the `TTS_CLOSURE_CHECK` parameter set to `OFF`. Please note the use of `password`.

    ```
    $ <copy>expdp \"sys/password@PDB1 as sysdba\" \
    DIRECTORY= dp_pdb1 \
    dumpfile=PDB1.dmp \
    TRANSPORT_TABLESPACES=test \
    TTS_CLOSURE_CHECK=OFF \
    LOGFILE=tts.log \
    REUSE_DUMPFILES=YES</copy>

    Export: Release 19.0.0.0.0 - Production on Thu Aug 26 14:45:02 2021
    Version 19.12.0.0.0

    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Starting "SYS"."SYS_EXPORT_TRANSPORTABLE_01":  "sys/********@PDB1 AS SYSDBA" DIRECTORY=dp_pdb1 dumpfile=PDB1.dmp TRANSPORT_TABLESPACES=test TTS_CLOSURE_CHECK=OFF LOGFILE=tts.log REUSE_DUMPFILES=YES
    Processing object type TRANSPORTABLE_EXPORT/STATISTICS/TABLE_STATISTICS
    Processing object type TRANSPORTABLE_EXPORT/STATISTICS/MARKER
    Processing object type TRANSPORTABLE_EXPORT/PLUGTS_BLK
    Processing object type TRANSPORTABLE_EXPORT/POST_INSTANCE/PLUGTS_BLK
    Processing object type TRANSPORTABLE_EXPORT/TABLE
    Master table "SYS"."SYS_EXPORT_TRANSPORTABLE_01" successfully loaded/unloaded
    ******************************************************************************
    Dump file set for SYS.SYS_EXPORT_TRANSPORTABLE_01 is:
      /tmp/PDB1.dmp
    ******************************************************************************
    Datafiles required for transportable tablespace TEST:
      /u01/app/oracle/oradata/CDB1/PDB1/test01.dbf
    Job "SYS"."SYS_EXPORT_TRANSPORTABLE_01" successfully completed at Thu Aug 26 14:45:19 2021 elapsed 0 00:00:16
    ```

    Notice that the export operation succeeded because you changed the `TEST` tablespace to be read-only.

## Task 8: Verify that you can import the `TEST` tablespace from PDB1 into PDB2

1. Copy the data files for PDB1's `TEST` tablespace to PDB2's target directory.

    ```
    $ <copy>cp /u01/app/oracle/oradata/CDB1/PDB1/test01.dbf  /u01/app/oracle/oradata/CDB1/PDB2</copy>
    ```

2. Run Oracle Data Pump Import to import the `TEST` tablespace. Please note the use of `password`.

    ```
    $ <copy>impdp \'sys/password@PDB2 as sysdba\' \
      DIRECTORY=dp_pdb2 \
      DUMPFILE=PDB1.dmp \
      TRANSPORT_DATAFILES='/u01/app/oracle/oradata/CDB1/PDB2/test01.dbf'</copy>

    Import: Release 19.0.0.0.0 - Production on Thu Aug 26 14:47:00 2021
    Version 19.12.0.0.0

    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Master table "SYS"."SYS_IMPORT_TRANSPORTABLE_01" successfully loaded/unloaded
    Starting "SYS"."SYS_IMPORT_TRANSPORTABLE_01":  "sys/********@PDB2 AS SYSDBA" DIRECTORY=dp_pdb2 DUMPFILE=PDB1.dmp TRANSPORT_DATAFILES=/u01/app/oracle/oradata/CDB1/PDB2/test01.dbf
    Processing object type TRANSPORTABLE_EXPORT/PLUGTS_BLK
    Processing object type TRANSPORTABLE_EXPORT/TABLE
    Processing object type TRANSPORTABLE_EXPORT/STATISTICS/TABLE_STATISTICS
    Processing object type TRANSPORTABLE_EXPORT/STATISTICS/MARKER
    Processing object type TRANSPORTABLE_EXPORT/POST_INSTANCE/PLUGTS_BLK
    Job "SYS"."SYS_IMPORT_TRANSPORTABLE_01" successfully completed at Thu Aug 26 14:47:05 2021 elapsed 0 00:00:05
    ```

    The output verifies that you can import the `TEST` tablespace from PDB1 into PDB2.

3. Connect to PDB2 as the `SYS` user.

    ```
    $ <copy>sqlplus system/password@PDB2</copy>
    ```

4. Run the following query to verify that the `TEST` tablespace is still in read-only mode.

    ```
    SQL> <copy>SELECT status FROM dba_tablespaces WHERE  tablespace_name='TEST';</copy>

    STATUS
    ----------
    READ ONLY
    ```

5. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT</copy>
    ```

## Task 9: Reset your environment

1. Run the `cleanup_PDBs_in_CDB1.sh` shell script to recreate PDB1 and remove other PDBs in CDB1. You can ignore any error messages.

    ```
    $ <copy>$HOME/labs/19cnf/cleanup_PDBs_in_CDB1.sh</copy>
    ```

2. Close the terminal window.

    ```
    $ <copy>exit</copy>
    ```


## Learn More

- [Oracle Data Pump Export](https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/oracle-data-pump-export-utility.html#GUID-5F7380CE-A619-4042-8D13-1F7DDE429991)
- [Oracle Data Pump Import](https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/datapump-import-utility.html#GUID-D11E340E-14C6-43B8-AB09-6335F0C1F71B)


## Acknowledgements

- **Author**: Dominique Jeunot's, Consulting User Assistance Developer
- **Contributor** - Jody Glover, Consulting User Assistance Developer, Database Development
- **Last Updated By**: Blake Hendricks, Solutions Engineer, September 22 2021
