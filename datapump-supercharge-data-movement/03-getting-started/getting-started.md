# Getting Started

## Introduction

In this lab, you will create the prerequisites for starting a job. Plus, start a simple Data Pump export/import.

Estimated Time: 10 Minutes

### Objectives

In this lab, you will:

* Create a user, a directory and other prerequisites
* Examine a Data Pump parameter file
* Start Data Pump

### Prerequisites

This lab assumes:

- You have completed Lab 1: Initialize Environment

## Task 1: Create prerequisites

A few things must be in place before you can start a Data Pump job.

1. Use the *yellow* terminal 🟨. Set the environment to *FTEX* and connect.

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. A user may always export from or import to their own schema. But to export from or import to other schemas or the entire database, you must have additional privileges. Find the Data Pump roles.

    ```
    <copy>
    select role from dba_roles where role like '%PUMP%';
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select role from dba_roles where role like '%PUMP%';
    
    ROLE
    --------------------------------------------------------------------------------
    DATAPUMP_EXP_FULL_DATABASE
    DATAPUMP_IMP_FULL_DATABASE
    ```
    </details> 

3. Get a list of those with the roles.

    ```
    <copy>
    col grantee format a20
    col granted_role format a30
    select grantee, granted_role from dba_role_privs where granted_role like '%PUMP%' order by 1, 2;
    </copy>

    -- Be sure to hit RETURN
    ```

    * *DBA* is a role, that's granted to the *SYSTEM* user.
    * Although *SYS* also has the Data Pump roles, you must **NEVER** use *SYS* to start Data Pump jobs. This may lead to unexpected behaviour.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> col grantee format a20
    SQL> col granted_role format a30
    SQL> select grantee, granted_role from dba_role_privs where granted_role like '%PUMP%' order by 1, 2;
    
    GRANTEE              GRANTED_ROLE
    -------------------- ------------------------------
    DBA                  DATAPUMP_EXP_FULL_DATABASE
    DBA                  DATAPUMP_IMP_FULL_DATABASE
    GSMADMIN_INTERNAL    DATAPUMP_EXP_FULL_DATABASE
    GSMADMIN_INTERNAL    DATAPUMP_IMP_FULL_DATABASE
    GSMUSER_ROLE         DATAPUMP_EXP_FULL_DATABASE
    SYS                  DATAPUMP_EXP_FULL_DATABASE
    SYS                  DATAPUMP_IMP_FULL_DATABASE
    
    7 rows selected.    
    ```
    </details> 
    
4. Create a user that you can use for Data Pump jobs.

    ```
    <copy>
    grant datapump_exp_full_database, datapump_imp_full_database to dpuser identified by oracle;
    alter user dpuser default tablespace users;
    alter user dpuser quota unlimited on users;
    </copy>

    -- Be sure to hit RETURN
    ```

    * The `GRANT ... IDENTIFIED BY` construct creates the user and grant privileges in one command.
    * The user doing the Data Pump job must have quota on a tablespace to store the control table.
    
    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> grant datapump_exp_full_database, datapump_imp_full_database to dpuser identified by oracle;
    
    Grant succeeded.

    SQL> alter user dpuser quota unlimited on users;
    
    User altered.
    
    SQL> alter user dpuser default tablespace users;
    
    User altered.
    ```
    </details> 

5. Data Pump needs a location where it can read from/write to files. You specify that using a directory object. Examine the built-in directory *DATA\_PUMP\_DIR*. 

    ```
    <copy>
    select directory_path from dba_directories where directory_name='DATA_PUMP_DIR';
    </copy>
    ```

    * Since Data Pump works on the server, the directory object refers to a location on the database server.
    * The directory path is not ideal; it defaults to a directory inside the Oracle home.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select directory_path from dba_directories where directory_name='DATA_PUMP_DIR';
    
    DIRECTORY_PATH
    --------------------------------------------------------------------------------
    /u01/app/oracle/product/19/rdbms/log/
    ```
    </details> 

6. Create your own directory object and create the directory in the file system too.

    ```
    <copy>
    create or replace directory dpdir as '/home/oracle/dpdir';
    host mkdir /home/oracle/dpdir
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create or replace directory dpdir as '/home/oracle/dpdir';
    
    Directory created.
    
    SQL> host mkdir /home/oracle/dpdir

    ```
    </details> 

7. Data Pump uses Advanced Queueing (AQ) to coordinate work between the control and worker processes. AQ uses the streams pool in the SGA. Check the current allocation.

    ```
    <copy>
    select bytes from v$sgainfo where name='Streams Pool Size';
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select bytes from v$sgainfo where name='Streams Pool Size';
    
         BYTES
    ----------
             0
    ```
    </details> 

8. Automatic Shared Memory Management (ASMM) automatically will automatically allocate memory to the streams pool when needed. However, it will resize the pool in small granules and it might affect the performance of the Data Pump job. Increase the streams pool immediately.

    ```
    <copy>
    alter system set streams_pool_size=128m scope=memory;
    select bytes from v$sgainfo where name='Streams Pool Size';
    </copy>

    -- Be sure to hit RETURN
    ```

    * Normally, 128M to 256M is enough. 
    * If you frequently run Data Pump jobs, you can use `SCOPE=BOTH` to persist the change.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter system set streams_pool_size=128m scope=memory;
    
    System altered.

    SQL> select bytes from v$sgainfo where name='Streams Pool Size';
    
         BYTES
    ----------
     134217728    
    ```
    </details>     


9. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

## Task 2: Parameter file

It often takes a number of parameters to start a Data Pump job. If you have many parameters or need to escape characters, it becomes very impractical to supply the parameters on the command line. Instead, you can use a parameter file.

1. Still connected to the *yellow* terminal 🟨. Find the command line parameter that toggles the use of a parameter file.

    ```
    <copy>
    expdp -help | grep -i -B1 "parameter file"
    </copy>
    ```

    * You can use `PARFILE` to reference a parameter file.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    expdp -help | grep -i -B1 "parameter file"
    PARFILE
    Specify parameter file name.
    ```
    </details>

2. A parameter file is just a text file. Each parameter is on a separate line and the parameter and value is separated by the equal sign (=). Examine this pre-created parameter file.


    ```
    <copy>
    cat /home/oracle/scripts/dp-03-export.par
    </copy>
    ```

    * `SCHEMAS` indicates a schema mode export.
    * Data Pump names files according to `DUMPFILE` and `LOGFILE` and stores those files in the directory specified by `DIRECTORY`.
    * `REUSE_DUMPFILES` allows Data Pump to overwrite existing dump files.
  
    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat /home/oracle/scripts/dp-03-export.par
    schemas=f1
    directory=dpdir
    dumpfile=f1.dmp
    logfile=f1-export.log
    reuse_dumpfiles=yes
    ```
    </details>    

## Task 3: Starting Data Pump

With a parameter file you can now start a Data Pump export and import a schema into another database.

1. Still connected to the *yellow* terminal 🟨. Export the schema *F1* from *FTEX* database.

    ```
    <copy>
    . ftex
    expdp dpuser/oracle parfile=/home/oracle/scripts/dp-03-export.par    
    </copy>

    -- Be sure to hit RETURN
    ```

    * To start an export, you use the `expdp` client.
    * Connect as the user you created in the previous lab.
    * Take the parameters from the parfile specified.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ expdp system/oracle parfile=/home/oracle/scripts/dp-03-export.par
    
    Export: Release 19.0.0.0.0 - Production on Fri Apr 25 12:13:35 2025
    Version 19.27.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Starting "SYSTEM"."SYS_EXPORT_SCHEMA_01":  system/******** parfile=/home/oracle/scripts/dp-03-export.par
    Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
    Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
    Processing object type SCHEMA_EXPORT/STATISTICS/MARKER
    Processing object type SCHEMA_EXPORT/USER
    Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    Processing object type SCHEMA_EXPORT/TABLE/TABLE
    Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    . . exported "F1"."F1_LAPTIMES"                          16.98 MB  571047 rows
    . . exported "F1"."F1_RESULTS"                           1.429 MB   26439 rows
    . . exported "F1"."F1_DRIVERSTANDINGS"                   916.2 KB   34511 rows
    . . exported "F1"."F1_QUALIFYING"                        419.0 KB   10174 rows
    . . exported "F1"."F1_PITSTOPS"                          416.8 KB   10793 rows
    . . exported "F1"."F1_CONSTRUCTORSTANDINGS"              344.1 KB   13231 rows
    . . exported "F1"."F1_CONSTRUCTORRESULTS"                225.2 KB   12465 rows
    . . exported "F1"."F1_RACES"                             131.4 KB    1125 rows
    . . exported "F1"."F1_DRIVERS"                           87.86 KB     859 rows
    . . exported "F1"."F1_SPRINTRESULTS"                     29.88 KB     280 rows
    . . exported "F1"."F1_CONSTRUCTORS"                      22.97 KB     212 rows
    . . exported "F1"."F1_CIRCUITS"                          17.42 KB      77 rows
    . . exported "F1"."F1_SEASONS"                           10.03 KB      75 rows
    . . exported "F1"."F1_STATUS"                            7.843 KB     139 rows
    Master table "SYSTEM"."SYS_EXPORT_SCHEMA_01" successfully loaded/unloaded
    ******************************************************************************
    Dump file set for SYSTEM.SYS_EXPORT_SCHEMA_01 is:
      /home/oracle/dpdir/f1.dmp
    Job "SYSTEM"."SYS_EXPORT_SCHEMA_01" successfully completed at Fri Apr 25 12:13:57 2025 elapsed 0 00:00:20
    ```
    </details>

2. Import into the *UPGR* database. Set the environment and connect

    ```
    <copy>
    . upgr
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

4. Create a user.

    ```
    <copy>
    grant datapump_exp_full_database, datapump_imp_full_database to dpuser identified by oracle;
    alter user dpuser default tablespace users;
    alter user dpuser quota unlimited on users;
    </copy>

    -- Be sure to hit RETURN
    ```
    
    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> grant datapump_exp_full_database, datapump_imp_full_database to dpuser identified by oracle;
    
    Grant succeeded.

    SQL> alter user dpuser quota unlimited on users;
    
    User altered.
    
    SQL> alter user dpuser default tablespace users;
    
    User altered.
    ```
    </details> 

5. Create a directory object.

    ```
    <copy>
    create or replace directory dpdir as '/home/oracle/dpdir';
    </copy>
    ```

    * The directory object points to the same directory as in the *FTEX* database. Thus, you avoid copying files from one directory to another.
    * If you had the source and target databases on different hosts, you would need to copy the dump files between the two directories.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create or replace directory dpdir as '/home/oracle/dpdir';
    
    Directory created.
    ```
    </details> 

6. Increase the streams pool.

    ```
    <copy>
    alter system set streams_pool_size=128m scope=memory;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter system set streams_pool_size=128m scope=memory;
    
    System altered.
    ```
    </details>     


7. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

8. Examine the pre-created parameter file that you can use for the import.

    ```
    <copy>
    cat /home/oracle/scripts/dp-03-import.par
    </copy>
    ```

    * The import parameter is much simpler than the export. 
    * Basically, you just tell Data Pump to import whatever it finds in the dump file.
  
    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat /home/oracle/scripts/dp-03-import.par
    directory=dpdir
    dumpfile=f1.dmp
    logfile=f1-import.log
    ```
    </details>    

9. Start the import into *UPGR* database.

    ```
    <copy>
    . upgr
    impdp dpuser/oracle parfile=/home/oracle/scripts/dp-03-import.par    
    </copy>

    -- Be sure to hit RETURN
    ```

    * To import, you use the *impdp* client. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ impdp dpuser/oracle parfile=/home/oracle/scripts/dp-03-import.par
    
    Import: Release 19.0.0.0.0 - Production on Fri Apr 25 12:38:36 2025
    Version 19.27.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Master table "DPUSER"."SYS_IMPORT_FULL_01" successfully loaded/unloaded
    Starting "DPUSER"."SYS_IMPORT_FULL_01":  dpuser/******** parfile=/home/oracle/scripts/dp-03-import.par
    Processing object type SCHEMA_EXPORT/USER
    Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    Processing object type SCHEMA_EXPORT/TABLE/TABLE
    Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    . . imported "F1"."F1_LAPTIMES"                          16.98 MB  571047 rows
    . . imported "F1"."F1_RESULTS"                           1.429 MB   26439 rows
    . . imported "F1"."F1_DRIVERSTANDINGS"                   916.2 KB   34511 rows
    . . imported "F1"."F1_QUALIFYING"                        419.0 KB   10174 rows
    . . imported "F1"."F1_PITSTOPS"                          416.8 KB   10793 rows
    . . imported "F1"."F1_CONSTRUCTORSTANDINGS"              344.1 KB   13231 rows
    . . imported "F1"."F1_CONSTRUCTORRESULTS"                225.2 KB   12465 rows
    . . imported "F1"."F1_RACES"                             131.4 KB    1125 rows
    . . imported "F1"."F1_DRIVERS"                           87.86 KB     859 rows
    . . imported "F1"."F1_SPRINTRESULTS"                     29.88 KB     280 rows
    . . imported "F1"."F1_CONSTRUCTORS"                      22.97 KB     212 rows
    . . imported "F1"."F1_CIRCUITS"                          17.42 KB      77 rows
    . . imported "F1"."F1_SEASONS"                           10.03 KB      75 rows
    . . imported "F1"."F1_STATUS"                            7.843 KB     139 rows
    Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
    Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
    Processing object type SCHEMA_EXPORT/STATISTICS/MARKER
    Job "DPUSER"."SYS_IMPORT_FULL_01" successfully completed at Fri Apr 25 12:38:56 2025 elapsed 0 00:00:18    
    ```
    </details> 
    
## Task 4: Starting a network mode import    

You just done an export/import via a dump file. Let's try to an import using *network mode*. This is a different approach that doesn't use a dump file. Instead, Data Pump fetches data and metadata directly from the source database via a database link. 

1. Still connected to the *yellow* terminal 🟨. Remove the dump file to proof that the import works over the database link.

    ```
    <copy>
    rm /home/oracle/dpdir/f1.dmp
    </copy>
    ```

2. Set the environment to the *UPGR* database and connect.

    ```
    <copy>
    . upgr
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

3. Create the database link pointing to the source database, *FTEX*. 
    
    ```
    <copy>
    connect dpuser/oracle
    create database link ftexlink connect to dpuser identified by oracle using 'localhost/ftex';
    </copy>

    -- Be sure to hit RETURN
    ```

    * You must create the database link in the schema that does the import. In this task, it is *dpuser*. 
    * The user, *dpuser*, must have appropriate privileges to export in the source database. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> connect dpuser/oracle
    
    Connected.
    
    SQL> create database link ftexlink connect to system identified by oracle using 'localhost/ftex';
    
    Database link created.
    ```
    </details> 

4. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```

5. Examine the parameter file.

    ```
    <copy>
    cat /home/oracle/scripts/dp-03-import-network.par
    </copy>
    ```

    * The parameter looks similar to the export parameter file.
    * Notice the `NETWORK_LINK` parameter. It instructs Data Pump to import over a database link without a dump file.
    * Also, notice the `REMAP_SCHEMA` parameter. Since you just imported the schema *F1* into *UPGR*, you can't import it again. But you can tell Data Pump to rename the schema on import to *F2*. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    cat /home/oracle/scripts/dp-03-import-network.par
    schemas=f1
    directory=dpdir
    logfile=f1-import.log
    network_link=ftexlink
    remap_schema=f1:f2
    ```
    </details> 

6. Start the import.

    ```
    <copy>
    . upgr
    impdp dpuser/oracle parfile=/home/oracle/scripts/dp-03-import-network.par
    </copy>

    -- Be sure to hit RETURN
    ```

    * The environment is set to the target database, *UPGR*, and you use the import client, *impdp*. 
    * Notice how Data Pump remaps the schema *F1* to *F2*. 
    * When doing network imports, you don't have to export on the source database. The import implicitly performs the export.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ impdp dpuser/oracle parfile=/home/oracle/scripts/dp-03-import-network.par
    
    Import: Release 19.0.0.0.0 - Production on Fri Apr 25 13:11:09 2025
    Version 19.27.0.0.0
    
    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
    
    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Starting "DPUSER"."SYS_IMPORT_SCHEMA_01":  dpuser/******** parfile=/home/oracle/scripts/dp-03-import-network.par
    Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
    Processing object type SCHEMA_EXPORT/USER
    Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
    Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
    Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
    Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
    Processing object type SCHEMA_EXPORT/TABLE/TABLE
    . . imported "F2"."F1_LAPTIMES"                          571047 rows
    . . imported "F2"."F1_DRIVERSTANDINGS"                    34511 rows
    . . imported "F2"."F1_RESULTS"                            26439 rows
    . . imported "F2"."F1_PITSTOPS"                           10793 rows
    . . imported "F2"."F1_QUALIFYING"                         10174 rows
    . . imported "F2"."F1_CONSTRUCTORSTANDINGS"               13231 rows
    . . imported "F2"."F1_CONSTRUCTORRESULTS"                 12465 rows
    . . imported "F2"."F1_RACES"                               1125 rows
    . . imported "F2"."F1_DRIVERS"                              859 rows
    . . imported "F2"."F1_CIRCUITS"                              77 rows
    . . imported "F2"."F1_CONSTRUCTORS"                         212 rows
    . . imported "F2"."F1_SEASONS"                               75 rows
    . . imported "F2"."F1_SPRINTRESULTS"                        280 rows
    . . imported "F2"."F1_STATUS"                               139 rows
    Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
    Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
    Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
    Processing object type SCHEMA_EXPORT/STATISTICS/MARKER
    Job "DPUSER"."SYS_IMPORT_SCHEMA_01" successfully completed at Fri Apr 25 13:11:34 2025 elapsed 0 00:00:24
    ```
    </details> 

You may now *proceed to the next lab*.

## Additional information

The network mode import is simpler than using dump files. You need to call Data Pump only once. However, there are certain restrictions in a network mode import that can severely impact performance. Especially around parallel jobs and LOBs you might find that a network mode import is much slower. In such cases, use dump files instead.

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - William Beauregard, Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, May 2025