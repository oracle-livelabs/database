# Full Transportable Export/Import

## Introduction

In this lab, you will migrate a non-CDB database (FTEX) running on Oracle Database 11.2.0.4 directly into a PDB (PDB2) running in a CDB (CDB2) on Oracle Database 19c. You will use Full Transportable Export/Import (FTEX) that is an extension to transportable tablespaces. 

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

* Create a new target PDB
* Prepare source database
* Migrate into target PDB

### Prerequisites

This lab assumes:

- You have completed Lab 1: Initialize Environment

## Task 1: Create a new target PDB

In any migration using transportable tablespaces, including FTEX, you must create an empty target database. In your case, it is a PDB, because you want to migrate directly into the multitenant architecture.

1. Use the yellow terminal. Log in to CDB2.

    ```
    <copy>
    . cdb2
    sqlplus / as sysdba
    </copy>
    ```
2. Create a new, empty PDB. 
    
    ```
    <copy>
    create pluggable database PDB2 admin user adm identified by adm;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create pluggable database PDB2 admin user adm identified by adm;

    Pluggable database created.
    ```
    </details>

3. Start the PDB and configure it to start automatically.

    ```
    <copy>
    alter pluggable database PDB2 open;
    alter pluggable database PDB2 save state;
    </copy>

    Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter pluggable database PDB2 open;

    Pluggable database altered.

    SQL> alter pluggable database PDB2 save state;

    Pluggable database altered.
    ```
    </details>

4. Create a directory object that Data Pump can use. Also, create a database link that can be used by Data Pump to import directly from the source database. The database link connects to the source database.
    ```
    <copy>
    alter session set container=PDB2;
    create or replace directory mydir as '/u02/oradata/CDB2/mydir';
    grant read, write on directory mydir to system;
    exit
    </copy>

    Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter session set container=PDB2;

    Session altered.

    SQL> create or replace directory mydir as '/u02/oradata/CDB2/mydir';

    Directory created.

    SQL> grant read, write on directory mydir to system;

    Grant succeeded.
    
    SQL> create public database link SOURCEDB connect to system identified by oracle using 'FTEX';

    Database link created.

    SQL> exit

    Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.19.0.0.0
    ```
    </details>

## Task 2: Prepare source database

You must prepare the source database, before you can move data. The tablespaces in the source database must be read-only; in most cases this means downtime. 

1. Log in to FTEX.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba   
    </copy>
    ```

2. Get a list of all tablespaces and data files. You must set all non-oracle tablespaces to *READ ONLY*. In your case, it is just the *USERS* tablespace.

    ```
    <copy>
    col tablespace_name format a20
    col file_name format a50
    select tablespace_name, file_name from dba_data_files order by 1, 2;
    alter tablespace USERS read only;
    exit
    </copy>

    Be sure to hit return
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> col tablespace_name format a20
    SQL> col file_name format a50
    SQL> select tablespace_name, file_name from dba_data_files order by 1, 2;

    TABLESPACE_NAME      FILE_NAME
    -------------------- --------------------------------------------------
    SYSAUX               /u02/oradata/FTEX/sysaux01.dbf
    SYSTEM               /u02/oradata/FTEX/system01.dbf
    UNDOTBS100           /u02/oradata/FTEX/undotbs100.dbf
    USERS                /u02/oradata/FTEX/users01.dbf

    SQL> alter tablespace USERS read only;

    Tablespace altered.

    SQL> exit

    Disconnected from Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
    With the Partitioning, OLAP, Data Mining and Real Application Testing options
    ```
    </details>

3. Examine the Data Pump export parameter file. 

    ```
    <copy>
    cat /home/oracle/IMP/ft-exp.par
    </copy>
    ```
    
    ``` text
    $ cat /home/oracle/IMP/ft-exp.par
    full=y
    transportable=always
    version=12
    metrics=y
    exclude=statistics
    exclude=tablespace:"in ('TEMP','UNDOTBS100')"
    exclude=directory:"in ('DATA_PUMP_DIR')"
    exclude=sys_user
    exclude=schema:"in ('OUTLN','DMSYS')"
    directory=data_pump_dir
    ```

    * `full=y` and `transportable=always` tells Data Pump to use FTEX.
    * You need `version`, because the source database is on Oracle Database 11.2.0.4 and the target database is a higher release.
    * `exclude=statistics` removes the statistics from the FTEX import. You can gather new statics after the migration.
    * The other `exclude` parameters remove objects that are already present in the target database.

4. Start the Data Pump metadata export.

    ```
    <copy>
    expdp system/oracle parfile=/home/oracle/IMP/ft-exp.par
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ expdp system/oracle parfile=/home/oracle/IMP/ft-exp.par

    Export: Release 11.2.0.4.0 - Production on Mon Jul 10 16:16:07 2023

    Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.

    Connected to: Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
    With the Partitioning, OLAP, Data Mining and Real Application Testing options
    Starting "SYSTEM"."SYS_EXPORT_FULL_01":  system/******** parfile=/home/oracle/IMP/ft-exp.par 
    Startup took 2 seconds
    Estimate in progress using BLOCKS method...
    Processing object type DATABASE_EXPORT/PLUGTS_FULL/FULL/PLUGTS_TABLESPACE
    Processing object type DATABASE_EXPORT/PLUGTS_FULL/PLUGTS_BLK
        Completed 1 PLUGTS_BLK objects in 0 seconds
    Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
        Estimated 1 TABLE_DATA objects in 1 seconds
    Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA
        Estimated 4 TABLE_DATA objects in 0 seconds
    Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
        Estimated 4 TABLE_DATA objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA
        Estimated 55 TABLE_DATA objects in 3 seconds
    Total estimation using BLOCKS method: 704 KB
    Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER
        Completed 1 MARKER objects in 1 seconds
    Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER
        Completed 1 MARKER objects in 0 seconds
    Processing object type DATABASE_EXPORT/PROFILE
        Completed 1 PROFILE objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/USER
        Completed 1 USER objects in 0 seconds
    Processing object type DATABASE_EXPORT/ROLE
        Completed 16 ROLE objects in 0 seconds
    Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT
        Completed 4 PROC_SYSTEM_GRANT objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/GRANT/SYSTEM_GRANT
        Completed 31 SYSTEM_GRANT objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/ROLE_GRANT
        Completed 43 ROLE_GRANT objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/DEFAULT_ROLE
        Completed 1 DEFAULT_ROLE objects in 0 seconds
    Processing object type DATABASE_EXPORT/RESOURCE_COST
        Completed 1 RESOURCE_COST objects in 0 seconds
    Processing object type DATABASE_EXPORT/TRUSTED_DB_LINK
        Completed 1 TRUSTED_DB_LINK objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/SEQUENCE/SEQUENCE
        Completed 17 SEQUENCE objects in 0 seconds
    Processing object type DATABASE_EXPORT/DIRECTORY/DIRECTORY
        Completed 2 DIRECTORY objects in 0 seconds
    Processing object type DATABASE_EXPORT/DIRECTORY/GRANT/OWNER_GRANT/OBJECT_GRANT
        Completed 2 OBJECT_GRANT objects in 0 seconds
    Processing object type DATABASE_EXPORT/CONTEXT
        Completed 3 CONTEXT objects in 1 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/PUBLIC_SYNONYM/SYNONYM
        Completed 6 SYNONYM objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/SYNONYM
        Completed 8 SYNONYM objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/TYPE/TYPE_SPEC
        Completed 9 TYPE objects in 0 seconds
    Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM
        Completed 3 PROCACT_SYSTEM objects in 0 seconds
    Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ
        Completed 17 PROCOBJ objects in 0 seconds
    Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM
        Completed 4 PROCACT_SYSTEM objects in 1 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/PROCACT_SCHEMA
        Completed 3 PROCACT_SCHEMA objects in 0 seconds
    Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE
        Completed 1 TABLE objects in 2 seconds
    Processing object type DATABASE_EXPORT/EARLY_POST_INSTANCE_IMPCALLOUT/MARKER
        Completed 1 MARKER objects in 0 seconds
    Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE
        Completed 4 TABLE objects in 6 seconds
    Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE
        Completed 4 TABLE objects in 6 seconds
    Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOU/MARKER
        Completed 1 MARKER objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE
        Completed 58 TABLE objects in 6 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/TABLE/PRE_TABLE_ACTION
        Completed 6 PRE_TABLE_ACTION objects in 1 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/TABLE/GRANT/OWNER_GRANT/OBJECT_GRANT
        Completed 18 OBJECT_GRANT objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/TABLE/COMMENT
        Completed 424 COMMENT objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/PACKAGE/PACKAGE_SPEC
        Completed 1 PACKAGE objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/FUNCTION/FUNCTION
        Completed 4 FUNCTION objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/PROCEDURE/PROCEDURE
        Completed 1 PROCEDURE objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/PACKAGE/COMPILE_PACKAGE/PACKAGE_SPEC/ALTER_PACKAGE_SPEC
        Completed 1 ALTER_PACKAGE_SPEC objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/FUNCTION/ALTER_FUNCTION
        Completed 4 ALTER_FUNCTION objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/PROCEDURE/ALTER_PROCEDURE
        Completed 1 ALTER_PROCEDURE objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/TABLE/INDEX/INDEX
        Completed 101 INDEX objects in 1 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/TABLE/CONSTRAINT/CONSTRAINT
        Completed 85 CONSTRAINT objects in 1 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/VIEW/VIEW
        Completed 12 VIEW objects in 1 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/VIEW/GRANT/OWNER_GRANT/OBJECT_GRANT
        Completed 3 OBJECT_GRANT objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/VIEW/COMMENT
        Completed 7 COMMENT objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/PACKAGE_BODIES/PACKAGE/PACKAGE_BODY
        Completed 1 PACKAGE_BODY objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/TABLE/CONSTRAINT/REF_CONSTRAINT
        Completed 36 REF_CONSTRAINT objects in 1 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/TABLE/POST_TABLE_ACTION
        Completed 3 POST_TABLE_ACTION objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TRIGGER
        Completed 2 TRIGGER objects in 0 seconds
    Processing object type DATABASE_EXPORT/END_PLUGTS_BLK
        Completed 1 PLUGTS_BLK objects in 0 seconds
    Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER
        Completed 1 MARKER objects in 0 seconds
    Processing object type DATABASE_EXPORT/SCHEMA/POST_SCHEMA/PROCACT_SCHEMA
        Completed 2 PROCACT_SCHEMA objects in 1 seconds
    Processing object type DATABASE_EXPORT/AUDIT
        Completed 29 AUDIT objects in 0 seconds
    Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER
        Completed 1 MARKER objects in 0 seconds
    . . exported "SYS"."KU$_USER_MAPPING_VIEW"               5.515 KB       7 rows
    . . exported "SYS"."DAM_CONFIG_PARAM$"                   6.367 KB      10 rows
    . . exported "SYS"."AUD$"                                    0 KB       0 rows
    . . exported "SYS"."DAM_CLEANUP_EVENTS$"                     0 KB       0 rows
    . . exported "SYS"."DAM_CLEANUP_JOBS$"                       0 KB       0 rows
    . . exported "SYSTEM"."SCHEDULER_PROGRAM_ARGS"           21.37 KB     154 rows
    . . exported "SYS"."AUDTAB$TBS$FOR_EXPORT"               5.859 KB       2 rows
    . . exported "SYS"."FGA_LOG$FOR_EXPORT"                      0 KB       0 rows
    . . exported "SYSTEM"."SCHEDULER_JOB_ARGS"                   0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_AUDIT_ATTRIBUTE"          6.328 KB       2 rows
    . . exported "SYSTEM"."REPCAT$_OBJECT_TYPES"             6.882 KB      28 rows
    . . exported "SYSTEM"."REPCAT$_RESOLUTION_METHOD"        5.835 KB      19 rows
    . . exported "SYSTEM"."REPCAT$_TEMPLATE_STATUS"          5.484 KB       3 rows
    . . exported "SYSTEM"."REPCAT$_TEMPLATE_TYPES"           6.289 KB       2 rows
    . . exported "SYSTEM"."TRACKING_TAB"                     5.437 KB       1 rows
    . . exported "SYSTEM"."DEF$_AQCALL"                          0 KB       0 rows
    . . exported "SYSTEM"."DEF$_AQERROR"                         0 KB       0 rows
    . . exported "SYSTEM"."DEF$_CALLDEST"                        0 KB       0 rows
    . . exported "SYSTEM"."DEF$_DEFAULTDEST"                     0 KB       0 rows
    . . exported "SYSTEM"."DEF$_DESTINATION"                     0 KB       0 rows
    . . exported "SYSTEM"."DEF$_ERROR"                           0 KB       0 rows
    . . exported "SYSTEM"."DEF$_LOB"                             0 KB       0 rows
    . . exported "SYSTEM"."DEF$_ORIGIN"                          0 KB       0 rows
    . . exported "SYSTEM"."DEF$_PROPAGATOR"                      0 KB       0 rows
    . . exported "SYSTEM"."DEF$_PUSHED_TRANSACTIONS"             0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_AUDIT_COLUMN"                 0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_COLUMN_GROUP"                 0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_CONFLICT"                     0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_DDL"                          0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_EXCEPTIONS"                   0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_EXTENSION"                    0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_FLAVORS"                      0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_FLAVOR_OBJECTS"               0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_GENERATED"                    0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_GROUPED_COLUMN"               0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_INSTANTIATION_DDL"            0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_KEY_COLUMNS"                  0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_OBJECT_PARMS"                 0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_PARAMETER_COLUMN"             0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_PRIORITY"                     0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_PRIORITY_GROUP"               0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_REFRESH_TEMPLATES"            0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_REPCAT"                       0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_REPCATLOG"                    0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_REPCOLUMN"                    0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_REPGROUP_PRIVS"               0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_REPOBJECT"                    0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_REPPROP"                      0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_REPSCHEMA"                    0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_RESOLUTION"                   0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_RESOLUTION_STATISTICS"        0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_RESOL_STATS_CONTROL"          0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_RUNTIME_PARMS"                0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_SITES_NEW"                    0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_SITE_OBJECTS"                 0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_SNAPGROUP"                    0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_TEMPLATE_OBJECTS"             0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_TEMPLATE_PARMS"               0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_TEMPLATE_REFGROUPS"           0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_TEMPLATE_SITES"               0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_TEMPLATE_TARGETS"             0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_USER_AUTHORIZATIONS"          0 KB       0 rows
    . . exported "SYSTEM"."REPCAT$_USER_PARM_VALUES"             0 KB       0 rows
    . . exported "SYSTEM"."SQLPLUS_PRODUCT_PROFILE"              0 KB       0 rows
        Completed 1 DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 1 seconds
        Completed 4 DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA objects in 0 seconds
        Completed 4 DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 0 seconds
        Completed 55 DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA objects in 0 seconds
    Master table "SYSTEM"."SYS_EXPORT_FULL_01" successfully loaded/unloaded
    ******************************************************************************
    Dump file set for SYSTEM.SYS_EXPORT_FULL_01 is:
    /u01/app/oracle/admin/FTEX/dpdump/expdat.dmp
    ******************************************************************************
    Datafiles required for transportable tablespace USERS:
    /u02/oradata/FTEX/users01.dbf
    Job "SYSTEM"."SYS_EXPORT_FULL_01" successfully completed at Mon Jul 10 16:16:52 2023 elapsed 0 00:00:43        
    ```
    </details>

    * Examine the Data Pump export log file.
    * Data Pump prints the paths to all the data files needed for the migration.

## Task 3: Migrate into target PDB

You can now move the data files to the target system and start the Data Pump import. 

1. Copy the data files to the target system. Use the list of data files from the query above. In your case, the target database is on the same host. You can just copy the data files.

    ```
    <copy>
    mkdir -p /u02/oradata/CDB2/pdb2
    cp /u02/oradata/FTEX/users01.dbf /u02/oradata/CDB2/pdb2
    </copy>

    Be sure to hit RETURN
    ```

2. Copy the dump file created by Data Pump during the export into the directory of the target database.

    ```
    <copy>
    cp /u01/app/oracle/admin/FTEX/dpdump/expdat.dmp /u02/oradata/CDB2/mydir
    </copy>
    ```

3. Examine the Data Pump import parameter file. 

    ```
    <copy>
    cat /home/oracle/IMP/ft-imp.par
    </copy>
    ```
    
    ``` text
    $ cat /home/oracle/IMP/ft-imp.par
    userid=system/oracle@pdb2
    metrics=y
    directory=mydir
    transport_datafiles='/u02/oradata/CDB2/pdb2/users01.dbf'
    ```

    * You must specify the full path to all data files on the target system using `transport_datafiles`.

3. Start the Data Pump import.

    ```
    <copy>
    . cdb2
    impdp parfile=/home/oracle/IMP/ft-imp.par
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ impdp parfile=/home/oracle/IMP/ft-imp.par

    Import: Release 19.0.0.0.0 - Production on Mon Jul 10 16:21:09 2023
    Version 19.18.0.0.0

    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    W-1 Startup took 2 seconds
    W-1 Master table "SYSTEM"."SYS_IMPORT_TRANSPORTABLE_01" successfully loaded/unloaded
    Starting "SYSTEM"."SYS_IMPORT_TRANSPORTABLE_01":  system/********@pdb2 parfile=/home/oracle/IMP/ft-imp.par 
    W-1 Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER
    W-1      Completed 1 MARKER objects in 2 seconds
    W-1 Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER
    W-1      Completed 1 MARKER objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/PLUGTS_FULL/PLUGTS_BLK
    W-1      Completed 1 PLUGTS_BLK objects in 1 seconds
    W-1 Processing object type DATABASE_EXPORT/PROFILE
    W-1      Completed 1 PROFILE objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/USER
    W-1      Completed 1 USER objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/ROLE
    ORA-31684: Object type ROLE:"SELECT_CATALOG_ROLE" already exists

    ORA-31684: Object type ROLE:"EXECUTE_CATALOG_ROLE" already exists

    ORA-31684: Object type ROLE:"DBFS_ROLE" already exists

    ORA-31684: Object type ROLE:"AQ_ADMINISTRATOR_ROLE" already exists

    ORA-31684: Object type ROLE:"AQ_USER_ROLE" already exists

    ORA-31684: Object type ROLE:"ADM_PARALLEL_EXECUTE_TASK" already exists

    ORA-31684: Object type ROLE:"GATHER_SYSTEM_STATISTICS" already exists

    ORA-31684: Object type ROLE:"RECOVERY_CATALOG_OWNER" already exists

    ORA-31684: Object type ROLE:"SCHEDULER_ADMIN" already exists

    ORA-31684: Object type ROLE:"HS_ADMIN_SELECT_ROLE" already exists

    ORA-31684: Object type ROLE:"HS_ADMIN_EXECUTE_ROLE" already exists

    ORA-31684: Object type ROLE:"HS_ADMIN_ROLE" already exists

    ORA-31684: Object type ROLE:"GLOBAL_AQ_USER_ROLE" already exists

    ORA-31684: Object type ROLE:"OEM_ADVISOR" already exists

    ORA-31684: Object type ROLE:"OEM_MONITOR" already exists

    W-1      Completed 15 ROLE objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT
    W-1      Completed 4 PROC_SYSTEM_GRANT objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/GRANT/SYSTEM_GRANT
    W-1      Completed 31 SYSTEM_GRANT objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/ROLE_GRANT
    W-1      Completed 41 ROLE_GRANT objects in 1 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/DEFAULT_ROLE
    W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/RESOURCE_COST
    W-1      Completed 1 RESOURCE_COST objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/TRUSTED_DB_LINK
    W-1      Completed 1 TRUSTED_DB_LINK objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/SEQUENCE/SEQUENCE
    W-1      Completed 15 SEQUENCE objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/DIRECTORY/DIRECTORY
    W-1      Completed 2 DIRECTORY objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/DIRECTORY/GRANT/OWNER_GRANT/OBJECT_GRANT
    W-1      Completed 2 OBJECT_GRANT objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/CONTEXT
    ORA-31684: Object type CONTEXT:"GLOBAL_AQCLNTDB_CTX" already exists

    ORA-31684: Object type CONTEXT:"DBFS_CONTEXT" already exists

    ORA-31684: Object type CONTEXT:"REGISTRY$CTX" already exists

    W-1      Completed 3 CONTEXT objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/PUBLIC_SYNONYM/SYNONYM
    W-1      Completed 1 SYNONYM objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/TYPE/TYPE_SPEC
    W-1      Completed 1 TYPE objects in 1 seconds
    W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM
    W-1      Completed 3 PROCACT_SYSTEM objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ
    W-1      Completed 17 PROCOBJ objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM
    ORA-39083: Object type PROCACT_SYSTEM failed to create with error:
    ORA-04042: procedure, function, package, or package body does not exist

    Failing sql is:
    BEGIN 
    SYS.DBMS_UTILITY.EXEC_DDL_STATEMENT('GRANT EXECUTE ON DBMS_DEFER_SYS TO "DBA"');COMMIT; END; 

    W-1      Completed 4 PROCACT_SYSTEM objects in 25 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/PROCACT_SCHEMA
    W-1      Completed 3 PROCACT_SCHEMA objects in 1 seconds
    W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE
    W-1      Completed 1 TABLE objects in 1 seconds
    W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    W-1 . . imported "SYS"."KU$_EXPORT_USER_MAP"                 5.515 KB       7 rows in 1 seconds using direct_path
    W-1 Processing object type DATABASE_EXPORT/EARLY_POST_INSTANCE_IMPCALLOUT/MARKER
    W-1      Completed 1 MARKER objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE
    W-1      Completed 4 TABLE objects in 1 seconds
    W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA
    W-1 . . imported "SYS"."AMGT$DP$DAM_CONFIG_PARAM$"           6.367 KB      10 rows in 0 seconds using direct_path
    W-1 . . imported "SYS"."AMGT$DP$AUD$"                            0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYS"."AMGT$DP$DAM_CLEANUP_EVENTS$"             0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYS"."AMGT$DP$DAM_CLEANUP_JOBS$"               0 KB       0 rows in 0 seconds using direct_path
    W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE
    W-1      Completed 2 TABLE objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    W-1 . . imported "SYS"."AMGT$DP$AUDTAB$TBS$FOR_EXPORT"       5.859 KB       2 rows in 0 seconds using direct_path
    W-1 . . imported "SYS"."AMGT$DP$FGA_LOG$FOR_EXPORT"              0 KB       0 rows in 0 seconds using direct_path
    W-1 Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOU/MARKER
    W-1      Completed 1 MARKER objects in 1 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE
    W-1      Completed 54 TABLE objects in 4 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/PRE_TABLE_ACTION
    W-1      Completed 6 PRE_TABLE_ACTION objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA
    W-1 . . imported "SYSTEM"."REPCAT$_AUDIT_ATTRIBUTE"          6.328 KB       2 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_OBJECT_TYPES"             6.882 KB      28 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_RESOLUTION_METHOD"        5.835 KB      19 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_TEMPLATE_STATUS"          5.484 KB       3 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_TEMPLATE_TYPES"           6.289 KB       2 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."TRACKING_TAB"                     5.437 KB       1 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."DEF$_AQCALL"                          0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."DEF$_AQERROR"                         0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."DEF$_CALLDEST"                        0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."DEF$_DEFAULTDEST"                     0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."DEF$_DESTINATION"                     0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."DEF$_ERROR"                           0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."DEF$_LOB"                             0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."DEF$_ORIGIN"                          0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."DEF$_PROPAGATOR"                      0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."DEF$_PUSHED_TRANSACTIONS"             0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_AUDIT_COLUMN"                 0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_COLUMN_GROUP"                 0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_CONFLICT"                     0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_DDL"                          0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_EXCEPTIONS"                   0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_EXTENSION"                    0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_FLAVORS"                      0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_FLAVOR_OBJECTS"               0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_GENERATED"                    0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_GROUPED_COLUMN"               0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_INSTANTIATION_DDL"            0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_KEY_COLUMNS"                  0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_OBJECT_PARMS"                 0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_PARAMETER_COLUMN"             0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_PRIORITY"                     0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_PRIORITY_GROUP"               0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_REFRESH_TEMPLATES"            0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_REPCAT"                       0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_REPCATLOG"                    0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_REPCOLUMN"                    0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_REPGROUP_PRIVS"               0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_REPOBJECT"                    0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_REPPROP"                      0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_REPSCHEMA"                    0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_RESOLUTION"                   0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_RESOLUTION_STATISTICS"        0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_RESOL_STATS_CONTROL"          0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_RUNTIME_PARMS"                0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_SITES_NEW"                    0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_SITE_OBJECTS"                 0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_SNAPGROUP"                    0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_TEMPLATE_OBJECTS"             0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_TEMPLATE_PARMS"               0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_TEMPLATE_REFGROUPS"           0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_TEMPLATE_SITES"               0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_TEMPLATE_TARGETS"             0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_USER_AUTHORIZATIONS"          0 KB       0 rows in 0 seconds using direct_path
    W-1 . . imported "SYSTEM"."REPCAT$_USER_PARM_VALUES"             0 KB       0 rows in 0 seconds using direct_path
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/GRANT/OWNER_GRANT/OBJECT_GRANT
    W-1      Completed 6 OBJECT_GRANT objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/COMMENT
    W-1      Completed 424 COMMENT objects in 1 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/PACKAGE/PACKAGE_SPEC
    W-1      Completed 1 PACKAGE objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/PROCEDURE/PROCEDURE
    W-1      Completed 1 PROCEDURE objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/PACKAGE/COMPILE_PACKAGE/PACKAGE_SPEC/ALTER_PACKAGE_SPEC
    W-1      Completed 1 ALTER_PACKAGE_SPEC objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/PROCEDURE/ALTER_PROCEDURE
    W-1      Completed 1 ALTER_PROCEDURE objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/INDEX/INDEX
    W-1      Completed 98 INDEX objects in 2 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/CONSTRAINT/CONSTRAINT
    W-1      Completed 85 CONSTRAINT objects in 1 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/VIEW/VIEW
    W-1      Completed 2 VIEW objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/PACKAGE_BODIES/PACKAGE/PACKAGE_BODY
    W-1      Completed 1 PACKAGE_BODY objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/CONSTRAINT/REF_CONSTRAINT
    W-1      Completed 36 REF_CONSTRAINT objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/POST_TABLE_ACTION
    W-1      Completed 3 POST_TABLE_ACTION objects in 1 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TRIGGER
    W-1      Completed 2 TRIGGER objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/END_PLUGTS_BLK
    W-1      Completed 1 PLUGTS_BLK objects in 1 seconds
    W-1 Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER
    W-1      Completed 1 MARKER objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/SCHEMA/POST_SCHEMA/PROCACT_SCHEMA
    W-1      Completed 2 PROCACT_SCHEMA objects in 0 seconds
    W-1 Processing object type DATABASE_EXPORT/AUDIT
    W-1      Completed 29 AUDIT objects in 1 seconds
    W-1 Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER
    W-1      Completed 1 MARKER objects in 1 seconds
    W-1      Completed 1 DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 1 seconds
    W-1      Completed 4 DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA objects in 0 seconds
    W-1      Completed 4 DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 301 seconds
    W-1      Completed 55 DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA objects in 306 seconds
    Job "SYSTEM"."SYS_IMPORT_TRANSPORTABLE_01" completed with 19 error(s) at Mon Jul 10 16:22:04 2023 elapsed 0 00:00:52
    ```
    </details>
    
4. Once Data Pump completes (usually 2-3 min), examine the log file. You will find some error messages. You can safely disregard these error messages:

    * Existing system roles
    ```
    ORA-31684: Object type ROLE:"..." already exists
    ```

    * Related to Oracle Text (fixed in later releases)
    ```
    ORA-31684: Object type CONTEXT:"GLOBAL_AQCLNTDB_CTX" already exists
    ORA-31684: Object type CONTEXT:"DBFS_CONTEXT" already exists
    ORA-31684: Object type CONTEXT:"REGISTRY$CTX" already exists
    ```

    * Related to replication (fixed in later releases)
    ```
    ORA-39083: Object type PROCACT_SYSTEM failed to create with error:
    ORA-04042: procedure, function, package, or package body does not exist
    Failing sql is:
    BEGIN
    SYS.DBMS_UTILITY.EXEC_DDL_STATEMENT('GRANT EXECUTE ON DBMS_DEFER_SYS TO "DBA"');COMMIT; END;
    ```

5. Users should now connect to the migrated database. Shut down the old source database.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba<<EOF
       shutdown immediate
    EOF
    </copy>
    ```

6. You can now connect to the migrated PDB.

    ```
    <copy>
    . cdb2
    sqlplus "system/oracle@PDB2"
    </copy>
    ```

7. Check the PDB.

    ```
    <copy>
    show con_id
    show con_name
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> show con_id

    CON_ID
    ------------------------------
    4

    SQL> show con_name

    CON_NAME
    ------------------------------
    PDB2
    ```
    </details>

You may now *proceed to the next lab*.

## Learn More

FTEX moves all objects and data necessary to create a complete copy of the database. You move:
* Data by copying the data files.
* Metadata by using Data Pump.

FTEX is easier than transportable tablespaces because Data Pump handles most of the manual steps. Further, it enables you to:
* Import directly into a higher release database.
* Import directly into the multitenant architecture.
* Import to a different platform and Endian format

You can combine FTEX with incremental backups to shorten the downtime during migration. See *Learn More* below and try it in the *Data Pump Cross-Platform Migration* lab. 

* Documentation, [Scenarios for Full Transportable Export/import](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/transporting-data.html#GUID-FA4AAD15-5305-45A9-9644-DB7D7DCD30D2)
* Techincal brief, [Full Transportable Export and Import](https://www.oracle.com/technetwork/database/enterprise-edition/full-transportable-wp-18c-4394831.pdf)
* Blog post series, [Minimal Downtime Migration with Full Transportable Export Import and Incremental Backups](https://dohdatabase.com/xtts/)
* YouTube playlist, [Cross-platform Transportable Tablespaces (XTTS)](https://www.youtube.com/watch?v=jte-W_6tJME&list=PLIUJ4jBaPQxwTEJJgtPrutbj19XumJg6m)

## Acknowledgements

* **Author** - Mike Dietrich, Database Product Management
* **Contributors** - Daniel Overby Hansen, Roy Swonger, Sanjay Rupprel, Cristian Speranta, Kay Malcolm
* **Last Updated By/Date** - Daniel Overby Hansen, July 2023
