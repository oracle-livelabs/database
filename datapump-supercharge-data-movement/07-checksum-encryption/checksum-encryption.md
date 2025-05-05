# Checksum and Encryption

## Introduction

What happens to your data when you move it out of the database? If you need to ship data to a far-away data center, how can you ensure that nothing happens *in-flight*? It could be a simple network corruption or a malicious user altering data. In this lab, you will explore options to detect and avoid this.

Estimated Time: 10 Minutes

### Objectives

In this lab, you will:

* Find ways to detect dump file corruption
* Use encryption to protect your data

### Prerequisites

This lab assumes:

- You have completed Lab 3: Getting Started

## Task 1: Checksum

While you move a dump file from the source to the target host, it might get corrupted. Or even worse, a malicious user might tamper with the dump file. You can use checksums to verify the integrity of a dump file. This feature requires Oracle Database 21c or later.

1. Use the *yellow* terminal 🟨. Connect to the *CDB23* container database. This CDB runs Oracle Database 23ai.

    ```
    <copy>
    . cdb23
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. For this task, you use the *RED* PDB. Connect and prepare for Data Pump by creating a user and a directory.

    ```
    <copy>
    alter session set container=red;
    create directory dpdir as '/home/oracle/dpdir';
    grant datapump_exp_full_database, datapump_imp_full_database to dpuser identified by oracle;
    alter user dpuser default tablespace users;
    alter user dpuser quota unlimited on users;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter session set container=red;

    Session altered.

    SQL> create directory dpdir as '/home/oracle/dpdir';

    Directory created.

    SQL> grant datapump_exp_full_database, datapump_imp_full_database to dpuser identified by oracle;
    
    User created.
    
    SQL> alter user dpuser default tablespace users;

    User altered.

    SQL> alter user dpuser quota unlimited on users;

    User altered.
    ```
    </details> 

3. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

4. Examine a pre-created parameter file.

    ```
    <copy>
    cat /home/oracle/scripts/dp-07-checksum-export.par
    </copy>
    ```

    * You export the *F1* schema from the database.
    * Data Pump calculates a checksum at the end of the export and stores it in the dump file in an encrypted format because of `CHECKSUM=YES`. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    schemas=F1
    reuse_dumpfiles=yes
    directory=dpdir
    logfile=dp-07-checksum-export.log
    dumpfile=dp-07-checksum.dmp
    metrics=yes
    logtime=all
    checksum=yes
    ```
    </details> 

5. Start an export.

    ```
    <copy>
    . cdb23
    expdp dpuser/oracle@localhost/red parfile=/home/oracle/scripts/dp-07-checksum-export.par
    </copy>

    -- Be sure to hit RETURN
    ```

    * At the end of the log file, Data Pump informs you that it calculated the checksum and stored it in the dump file.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Export: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Tue Apr 29 09:36:53 2025
    Version 23.8.0.25.04
    
    Copyright (c) 1982, 2024, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    29-APR-25 09:36:57.258: Starting "DPUSER"."SYS_EXPORT_SCHEMA_01":  dpuser/********@localhost/red parfile=/home/oracle/scripts/dp-07-checksum-export.par
    29-APR-25 09:36:57.606: W-1 Startup on instance 1 took 0 seconds
    29-APR-25 09:37:00.287: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    29-APR-25 09:37:00.476: W-1 Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
    29-APR-25 09:37:00.514: W-1      Completed 22 INDEX_STATISTICS objects in 0 seconds
    29-APR-25 09:37:00.657: W-1 Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
    29-APR-25 09:37:00.665: W-1      Completed 15 TABLE_STATISTICS objects in 0 seconds
    29-APR-25 09:37:05.831: W-1      Completed 1 [internal] STATISTICS objects in 5 seconds
    29-APR-25 09:37:05.907: W-1 Processing object type SCHEMA_EXPORT/USER
    29-APR-25 09:37:05.918: W-1      Completed 1 USER objects in 0 seconds
    29-APR-25 09:37:05.945: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    29-APR-25 09:37:05.950: W-1      Completed 2 SYSTEM_GRANT objects in 0 seconds
    29-APR-25 09:37:06.056: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    29-APR-25 09:37:06.061: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    29-APR-25 09:37:06.098: W-1 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    29-APR-25 09:37:06.102: W-1      Completed 1 TABLESPACE_QUOTA objects in 0 seconds
    29-APR-25 09:37:06.429: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA/LOGREP
    29-APR-25 09:37:06.432: W-1      Completed 2 LOGREP objects in 0 seconds
    29-APR-25 09:37:12.099: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    29-APR-25 09:37:24.656: W-1      Completed 15 TABLE objects in 14 seconds
    29-APR-25 09:37:27.608: W-1 Processing object type SCHEMA_EXPORT/TABLE/INDEX/INDEX
    29-APR-25 09:37:27.613: W-1      Completed 1 INDEX objects in 1 seconds
    29-APR-25 09:37:29.240: W-1 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    29-APR-25 09:37:29.251: W-1      Completed 22 CONSTRAINT objects in 2 seconds
    29-APR-25 09:37:36.590: W-1 . . exported "F1"."STATTAB"                               34.2 KB     154 rows in 0 seconds using direct_path
    29-APR-25 09:37:36.621: W-1 . . exported "F1"."F1_CIRCUITS"                           17.6 KB      77 rows in 0 seconds using direct_path
    29-APR-25 09:37:36.655: W-1 . . exported "F1"."F1_CONSTRUCTORRESULTS"                225.4 KB   12465 rows in 0 seconds using direct_path
    29-APR-25 09:37:36.686: W-1 . . exported "F1"."F1_CONSTRUCTORS"                       23.1 KB     212 rows in 0 seconds using direct_path
    29-APR-25 09:37:36.721: W-1 . . exported "F1"."F1_CONSTRUCTORSTANDINGS"              344.3 KB   13231 rows in 0 seconds using direct_path
    29-APR-25 09:37:36.754: W-1 . . exported "F1"."F1_DRIVERS"                            88.1 KB     859 rows in 0 seconds using direct_path
    29-APR-25 09:37:36.798: W-1 . . exported "F1"."F1_DRIVERSTANDINGS"                   916.4 KB   34511 rows in 0 seconds using direct_path
    29-APR-25 09:37:36.941: W-1 . . exported "F1"."F1_LAPTIMES"                             17 MB  571047 rows in 0 seconds using direct_path
    29-APR-25 09:37:36.979: W-1 . . exported "F1"."F1_PITSTOPS"                            417 KB   10793 rows in 0 seconds using direct_path
    29-APR-25 09:37:37.015: W-1 . . exported "F1"."F1_QUALIFYING"                        419.2 KB   10174 rows in 1 seconds using direct_path
    29-APR-25 09:37:37.049: W-1 . . exported "F1"."F1_RACES"                             131.9 KB    1125 rows in 0 seconds using direct_path
    29-APR-25 09:37:37.094: W-1 . . exported "F1"."F1_RESULTS"                             1.4 MB   26439 rows in 0 seconds using direct_path
    29-APR-25 09:37:37.125: W-1 . . exported "F1"."F1_SEASONS"                            10.1 KB      75 rows in 0 seconds using direct_path
    29-APR-25 09:37:37.158: W-1 . . exported "F1"."F1_SPRINTRESULTS"                      30.3 KB     280 rows in 0 seconds using direct_path
    29-APR-25 09:37:37.188: W-1 . . exported "F1"."F1_STATUS"                              7.9 KB     139 rows in 0 seconds using direct_path
    29-APR-25 09:37:38.303: W-1      Completed 15 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 1 seconds
    29-APR-25 09:37:38.587: W-1 Master table "DPUSER"."SYS_EXPORT_SCHEMA_01" successfully loaded/unloaded
    29-APR-25 09:37:38.603: Generating checksums for dump file set
    29-APR-25 09:37:38.677: ******************************************************************************
    29-APR-25 09:37:38.678: Dump file set for DPUSER.SYS_EXPORT_SCHEMA_01 is:
    29-APR-25 09:37:38.678:   /home/oracle/dpdir/dp-07-checksum.dmp
    29-APR-25 09:37:38.685: Job "DPUSER"."SYS_EXPORT_SCHEMA_01" successfully completed at Tue Apr 29 09:37:38 2025 elapsed 0 00:00:44
    ```
    </details>     

6. Corrupt the dump file by overwriting some of the blocks with random data.

    ```
    <copy>
    dd if=/dev/urandom of=/home/oracle/dpdir/dp-07-checksum.dmp bs=1024 seek=10 count=100 conv=notrunc
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    100+0 records in
    100+0 records out
    102400 bytes (102 kB, 100 KiB) copied, 0.000711524 s, 144 MB/s
    ```
    </details>

7. Examine a pre-created parameter that will verify the integrity of the dump file.

    ```
    <copy>
    cat /home/oracle/scripts/dp-07-checksum-import.par
    </copy>
    ```

    * `VERIFY_ONLY=YES` instructs Data Pump to calculate the checksum of the dump file, and verify it with the value that was stored in the dump file on export.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    directory=dpdir
    logfile=dp-07-checksum-import.log
    dumpfile=dp-07-checksum.dmp
    metrics=yes
    logtime=all
    remap_schema=F1:LAB7CHECKSUM
    verify_only=yes
    ```
    </details> 

8. Verify the integrity using Data Pump.

    ```
    <copy>
    impdp dpuser/oracle@localhost/red parfile=/home/oracle/scripts/dp-07-checksum-import.par
    </copy>
    ```

    * After checking the dump file, Data Pump determines that there's a mismatch in the checksums.
    * Data Pump reports *dump file set is inconsistent*.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Tue Apr 29 09:42:19 2025
    Version 23.8.0.25.04
    
    Copyright (c) 1982, 2024, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    29-APR-25 09:42:21.369: W-1 Startup on instance 1 took 0 seconds
    29-APR-25 09:42:21.372: Verifying dump file checksums
    29-APR-25 09:42:21.871: W-1 Master table "DPUSER"."SYS_IMPORT_FULL_01" successfully loaded/unloaded
    29-APR-25 09:42:22.107: dump file set is complete
    29-APR-25 09:42:22.111: ORA-39412: file checksum error in dump file "/home/oracle/dpdir/dp-07-checksum.dmp"
    
    29-APR-25 09:42:22.112: dump file set is inconsistent
    29-APR-25 09:42:22.123: Job "DPUSER"."SYS_IMPORT_FULL_01" completed with 1 error(s) at Tue Apr 29 09:42:22 2025 elapsed 0 00:00:01
    ```
    </details> 

9. Now, it is recommended to re-transmit the dump file from the source to avoid corruption. But you can also force Data Pump to import the dump file anyway. Examine a pre-created dump file.

    ```
    <copy>
    cat /home/oracle/scripts/dp-07-checksum-import2.par
    </copy>
    ```

    * You must set `VERIFY_ONLY=NO`. If there is a checksum in the dump file, Data Pump automatically verifies the integrity.
    
    <details>
    <summary>*click to see the output*</summary>
    ``` text
    directory=dpdir
    logfile=dp-07-checksum-import.log
    dumpfile=dp-07-checksum.dmp
    metrics=yes
    logtime=all
    remap_schema=F1:LAB7CHECKSUM
    verify_checksum=no
    ```
    </details> 

10. Perform the import of the corruption dump file.

    ```
    <copy>
    impdp dpuser/oracle@localhost/red parfile=/home/oracle/scripts/dp-07-checksum-import2.par
    </copy>
    ```

    * As expected, Data Pump fails because of the corrupted dump file.
    * It's not possible to deduce from the error message that it is caused by a corrupt dump file. 
    * It's a good idea to always verify the integrity of a dump file on import.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Import: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Tue Apr 29 09:44:19 2025
    Version 23.8.0.25.04
    
    Copyright (c) 1982, 2024, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    
    29-APR-25 09:44:21.070: W-1 Startup on instance 1 took 1 seconds
    29-APR-25 09:44:21.073: Warning: dump file checksum verification is disabled
    29-APR-25 09:44:21.316: W-1 Master table "DPUSER"."SYS_IMPORT_FULL_01" successfully loaded/unloaded
    29-APR-25 09:44:21.615: Starting "DPUSER"."SYS_IMPORT_FULL_01":  dpuser/********@localhost/red parfile=/home/oracle/scripts/dp-07-checksum-import2.par
    29-APR-25 09:44:21.664: W-1 Processing object type SCHEMA_EXPORT/USER
    29-APR-25 09:44:21.714: ORA-39126: Worker unexpected fatal error in KUPW$WORKER.LOAD_METADATA [TABLE_DATA:"DPUSER"."SYS_IMPORT_FULL_01"]
    SELECT process_order, flags, xml_clob, NVL(dump_fileid, :1), NVL(dump_position, :2), dump_length, dump_allocation, NVL(value_n, 0), grantor, object_row, object_schema,     object_long_name, partition_name, subpartition_name, processing_status, processing_state, base_object_type, base_object_schema, orig_base_object_schema, base_object_name,     orig_base_object_name, base_process_order, parent_process_order, property, size_estimate, in_progress, original_object_schema, original_object_name, creation_level, object_path_seqno,     object_type, object_type_path, object_int_oid, metadata_io,option_tag FROM "DPUSER"."SYS_IMPORT_FULL_01" WHERE  process_order between :3 AND :4 AND duplicate = 0 AND processing_state     NOT IN (:5, :6, :7) ORDER BY process_order
    ORA-39183: internal error 0 occurred during decompression phase 2
    
    29-APR-25 09:44:21.714: ORA-06512: at "SYS.DBMS_SYS_ERROR", line 150
    ORA-06512: at "SYS.KUPW$WORKER", line 13998
    ORA-06512: at "SYS.DBMS_SYS_ERROR", line 150
    ORA-06512: at "SYS.KUPW$WORKER", line 6153
    ORA-06512: at "SYS.KUPF$FILE", line 9098
    ORA-06512: at "SYS.KUPF$FILE_INT", line 1117
    ORA-06512: at "SYS.KUPF$FILE", line 9085
    ORA-06512: at "SYS.KUPW$WORKER", line 5874
    
    (output truncated)
    
    29-APR-25 09:44:22.161: KUPW:09:44:22.154: 2: In procedure WRITE_ERROR_INFORMATION with ORA-39126: Worker unexpected fatal error in KUPW$WORKER.LOAD_METADATA [SELECT process_order,     flags, xml_clob, NVL(dump_fileid, :1), NVL(dump_position, :2), dump_length, dump_allocation, NVL(value_n, 0), grantor, object_row, object_schema, object_long_name, partition_name,     subpartition_name, processing_status, processing_state, base_object_type, base_object_schema, orig_base_object_schema, base_object_name, orig_base_object_name, base_process_order,     parent_process_order, property, size_estimate, in_progress, original_object_schema, original_object_name, creation_level, object_path_seqno, object_type, object_type_path,     object_int_oid, metadata_io,option_tag FROM "DPUSER"."SYS_IMPORT_FULL_01" WHERE  process_order between :3 AND :4 AND duplicate = 0 AND processing_state NOT IN (:5, :6, :7) ORDER BY     process_order]
    ORA-06512: at "SYS.DBMS_SYS_ERROR", line 140
    ORA-39183: internal error 0 occurred during decompression phase 2
    ORA-06512: at "SYS.KUPW$W
    29-APR-25 09:44:22.161: ORKER", line 6153
    ORA-06512: at "SYS.KUPF$FILE", line 9098
    ORA-06512: at "SYS.KUPF$FILE_INT", line 1117
    ORA-06512: at "SYS.KUPF$FILE", line 9085
    ORA-06512: at "SYS.KUPW$WORKER", line 5874
    
    29-APR-25 09:44:22.161: KUPW:09:44:22.154: 2: In procedure SEND_MSG. Fatal=0
    29-APR-25 09:44:22.161: --------------- End of Oracle Data Pump Trace Queue Dump ------------
    29-APR-25 09:44:22.168: Job "DPUSER"."SYS_IMPORT_FULL_01" stopped due to fatal error at Tue Apr 29 09:44:22 2025 elapsed 0 00:00:02
    ```
    </details>

## Task 2: Encryption

Data Pump stores the data in the dump files in a proprietary format. However, some data is easily readable.

1. Still in the *yellow* terminal 🟨. Export the *F1* schema again.

    ```
    <copy>
    . cdb23
    expdp dpuser/oracle@localhost/red parfile=/home/oracle/scripts/dp-07-checksum-export.par
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Export: Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems on Tue Apr 29 09:36:53 2025
    Version 23.8.0.25.04
    
    Copyright (c) 1982, 2024, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 23ai Enterprise Edition Release 23.0.0.0.0 - for Oracle Cloud and Engineered Systems
    29-APR-25 09:36:57.258: Starting "DPUSER"."SYS_EXPORT_SCHEMA_01":  dpuser/********@localhost/red parfile=/home/oracle/scripts/dp-07-checksum-export.par
    29-APR-25 09:36:57.606: W-1 Startup on instance 1 took 0 seconds
    29-APR-25 09:37:00.287: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    29-APR-25 09:37:00.476: W-1 Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
    29-APR-25 09:37:00.514: W-1      Completed 22 INDEX_STATISTICS objects in 0 seconds
    29-APR-25 09:37:00.657: W-1 Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
    29-APR-25 09:37:00.665: W-1      Completed 15 TABLE_STATISTICS objects in 0 seconds
    29-APR-25 09:37:05.831: W-1      Completed 1 [internal] STATISTICS objects in 5 seconds
    29-APR-25 09:37:05.907: W-1 Processing object type SCHEMA_EXPORT/USER
    29-APR-25 09:37:05.918: W-1      Completed 1 USER objects in 0 seconds
    29-APR-25 09:37:05.945: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    29-APR-25 09:37:05.950: W-1      Completed 2 SYSTEM_GRANT objects in 0 seconds
    29-APR-25 09:37:06.056: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    29-APR-25 09:37:06.061: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    29-APR-25 09:37:06.098: W-1 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    29-APR-25 09:37:06.102: W-1      Completed 1 TABLESPACE_QUOTA objects in 0 seconds
    29-APR-25 09:37:06.429: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA/LOGREP
    29-APR-25 09:37:06.432: W-1      Completed 2 LOGREP objects in 0 seconds
    29-APR-25 09:37:12.099: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
    29-APR-25 09:37:24.656: W-1      Completed 15 TABLE objects in 14 seconds
    29-APR-25 09:37:27.608: W-1 Processing object type SCHEMA_EXPORT/TABLE/INDEX/INDEX
    29-APR-25 09:37:27.613: W-1      Completed 1 INDEX objects in 1 seconds
    29-APR-25 09:37:29.240: W-1 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    29-APR-25 09:37:29.251: W-1      Completed 22 CONSTRAINT objects in 2 seconds
    29-APR-25 09:37:36.590: W-1 . . exported "F1"."STATTAB"                               34.2 KB     154 rows in 0 seconds using direct_path
    29-APR-25 09:37:36.621: W-1 . . exported "F1"."F1_CIRCUITS"                           17.6 KB      77 rows in 0 seconds using direct_path
    29-APR-25 09:37:36.655: W-1 . . exported "F1"."F1_CONSTRUCTORRESULTS"                225.4 KB   12465 rows in 0 seconds using direct_path
    29-APR-25 09:37:36.686: W-1 . . exported "F1"."F1_CONSTRUCTORS"                       23.1 KB     212 rows in 0 seconds using direct_path
    29-APR-25 09:37:36.721: W-1 . . exported "F1"."F1_CONSTRUCTORSTANDINGS"              344.3 KB   13231 rows in 0 seconds using direct_path
    29-APR-25 09:37:36.754: W-1 . . exported "F1"."F1_DRIVERS"                            88.1 KB     859 rows in 0 seconds using direct_path
    29-APR-25 09:37:36.798: W-1 . . exported "F1"."F1_DRIVERSTANDINGS"                   916.4 KB   34511 rows in 0 seconds using direct_path
    29-APR-25 09:37:36.941: W-1 . . exported "F1"."F1_LAPTIMES"                             17 MB  571047 rows in 0 seconds using direct_path
    29-APR-25 09:37:36.979: W-1 . . exported "F1"."F1_PITSTOPS"                            417 KB   10793 rows in 0 seconds using direct_path
    29-APR-25 09:37:37.015: W-1 . . exported "F1"."F1_QUALIFYING"                        419.2 KB   10174 rows in 1 seconds using direct_path
    29-APR-25 09:37:37.049: W-1 . . exported "F1"."F1_RACES"                             131.9 KB    1125 rows in 0 seconds using direct_path
    29-APR-25 09:37:37.094: W-1 . . exported "F1"."F1_RESULTS"                             1.4 MB   26439 rows in 0 seconds using direct_path
    29-APR-25 09:37:37.125: W-1 . . exported "F1"."F1_SEASONS"                            10.1 KB      75 rows in 0 seconds using direct_path
    29-APR-25 09:37:37.158: W-1 . . exported "F1"."F1_SPRINTRESULTS"                      30.3 KB     280 rows in 0 seconds using direct_path
    29-APR-25 09:37:37.188: W-1 . . exported "F1"."F1_STATUS"                              7.9 KB     139 rows in 0 seconds using direct_path
    29-APR-25 09:37:38.303: W-1      Completed 15 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 1 seconds
    29-APR-25 09:37:38.587: W-1 Master table "DPUSER"."SYS_EXPORT_SCHEMA_01" successfully loaded/unloaded
    29-APR-25 09:37:38.603: Generating checksums for dump file set
    29-APR-25 09:37:38.677: ******************************************************************************
    29-APR-25 09:37:38.678: Dump file set for DPUSER.SYS_EXPORT_SCHEMA_01 is:
    29-APR-25 09:37:38.678:   /home/oracle/dpdir/dp-07-checksum.dmp
    29-APR-25 09:37:38.685: Job "DPUSER"."SYS_EXPORT_SCHEMA_01" successfully completed at Tue Apr 29 09:37:38 2025 elapsed 0 00:00:44
    ```
    </details>     

2. The *F1* schema has a table with all the F1 drivers. See if you can find *Ayrton Senna* in the dump file.

    ```
    <copy>
    strings /home/oracle/dpdir/dp-07-checksum.dmp | grep -i -C2 "ayrton"
    </copy>
    ```

    * You can clearly read data in the dump file in clear text.
    * Your output might vary depending on which order Data Pump unloaded the rows.
    * Ayrton Senna da Silva was a Brazilian racing driver, who competed in Formula One from 1984 to 1994. He won 41 Grand Prixs across 11 seasons.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Australian*http://en.wikipedia.org/wiki/David_Brabham<
    senna
    Ayrton
    Sennaf
    	Brazilian)http://en.wikipedia.org/wiki/Ayrton_Senna<
    bernard
    Bernard    
    ```
    </details>

3. If you are moving sensitive data, you must protect your dump file. Data Pump can encrypt the dump file making it impossible to read the content unless you have the encryption password. Examine a pre-created parameter file.

    ```
    <copy>
    cat /home/oracle/scripts/dp-07-encrypt-export.par
    </copy>
    ```

    * You create an encrypted dump file using `ENCRYPTION_MODE=PASSWORD`. This requires a license for the Advanced Security Option.
    * For ease-of-use, the encryption password is stored in clear text in the parameter file. This is not good practice and you should avoid that.
    * If you remove `ENCRYPTION_PASSWORD` from the parameter file, Data Pump prompts for the password.
    * You can change the encryption algorithm using `ENCRYPTION_ALGORITHM`. 
    * The default is *AES256* in Oracle Database 23ai, and *AES128* in Oracle Database 19c and 21c.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    schemas=F1
    reuse_dumpfiles=yes
    directory=dpdir
    logfile=dp-07-encrypt-export.log
    dumpfile=dp-07-encrypt.dmp
    metrics=yes
    logtime=all
    encryption_mode=password
    encryption_password=Jdzn!LmKcQq3rq3rX6Eu  
    ```
    </details>    

4. Perform a new export and store the data in an encrypted format.

    ```
    <copy>
    . cdb23
    expdp dpuser/oracle@localhost/red parfile=/home/oracle/scripts/dp-07-encrypt-export.par
    </copy>

    -- Be sure to hit RETURN
    ```

5. Find *Ayrton Senna* in the dump file. 

    ```
    <copy>
    strings /home/oracle/dpdir/dp-07-encrypt.dmp | grep -i -C2 "ayrton"
    </copy>
    ```

    * The command returns nothing because the text (*Ayrton*) no longer appears in clear text.
    * The data in the dump file is now encrypted.

6. Encryption not only protects your data, but also ensures that no one can change the data while it is stored in the dump file. You get the best protection by encrypting your dump files. 

You may now *proceed to the next lab*.

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - William Beauregard, Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, May 2025