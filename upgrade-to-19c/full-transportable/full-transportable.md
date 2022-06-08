# Upgrade using Full Transportable Database #

## Introduction ##

 In this lab, we will use the Full (Cross Platform) Transportable Database functionality to migrate an existing 12.2 (single-mode, non-CDB architecture) to a 19c Pluggable database.

 Estimated time: 15 minutes

### Objectives ###

- Create a new 19c PDB to act as target for the source database.
- Prepare the target 19c database for the transported Tablespaces
- Prepare the source database for the transportable tablespace step
- Execute the upgrade using Full Transportable Tablespaces
- Check the target (upgraded) database to see that all data has been migrated

### Prerequisites ###

- You have access to the Upgrade to a 19c Hands-on-Lab client image
- If you use the copy functionality in this lab, make sure you open the Lab instructions INSIDE the client image
    - When copied outside of the client image, additional *returns* can be placed between the lines, which makes the command fail
- A new 19c database has been created in this image
- All databases in the image are running

When in doubt or need to start the databases using the following steps:

1. Please log in as **oracle** user and execute the following command:

    ````
    $ <copy>. oraenv</copy>
    ````
2. Please enter the SID of the 19c database that you have created in the first lab. In this example, the SID is **`19C`**

    ````
    ORACLE_SID = [oracle] ? <copy>DB19C</copy>
    The Oracle base has been set to /u01/app/oracle
    ````
3. Now execute the command to start all databases listed in the `/etc/oratab` file:

    ````
    $ <copy>dbstart $ORACLE_HOME</copy>
    ````

    The output should be similar to this:
    ````
    Processing Database instance "DB112": log file /u01/app/oracle/product/11.2.0/dbhome_112/rdbms/log/startup.log
    Processing Database instance "DB121C": log file /u01/app/oracle/product/12.1.0/dbhome_121/rdbms/log/startup.log
    Processing Database instance "DB122": log file /u01/app/oracle/product/12.2.0/dbhome_122/rdbms/log/startup.log
    Processing Database instance "DB18C": log file /u01/app/oracle/product/18.1.0/dbhome_18c/rdbms/log/startup.log
    Processing Database instance "DB19C": log file /u01/app/oracle/product/19.3.0/dbhome_19c/rdbms/log/startup.log
    ````
## Task 1: Prepare the target 19c database ##

The FTTS functionality requires an existing database as a target. For this, we will log into the existing 19c instance and create a new Pluggable Database.

### Set the correct environment and log in using SQL*Plus ###

1. Please set the correct ORACLE\_HOME and ORACLE\_SID using oraenv:

    ````
    $ <copy>. oraenv</copy>
    ````

    Enter the SID for the 19c environment you already created in a previous lab:

    ````
    ORACLE_SID = [DB112] ? DB19C
    The Oracle base remains unchanged with value /u01/app/oracle
    ````

2. We can now log in to the 19c environment. After login, we will create a new pluggable database as target:

    ````
    $ <copy>sqlplus / as sysdba</copy>
    ````

### Create a new PDB called PDB19C02 ###

3. Please create a new PDB using the following command:

    ````
    SQL> <copy>create pluggable database PDB19C02 admin user admin identified by Welcome_123 file_name_convert=('pdbseed','PDB19C02');</copy>

    Pluggable database created.
    ````

    In the above example, we choose the location for the filenames by using the file_name_convert clause. Another option would have been setting the `PDB_FILE_NAME_CONVERT` init.ora parameter or have Oracle sort it out using Oracle Managed Files.

    The files for this PDB have been created in `/u01/oradata/DB19C/PDB19C02` due to our create pluggable database command.

4. After creating the new PDB, we need to start it so it can be used as a target for our migration:

    ````
    SQL> <copy>alter pluggable database PDB19C02 open;</copy>

    Pluggable database altered.
    ````

### Prepare the target PDB ###

The migration described in this lab requires a directory object for Datapump and a database link to the source database. We will use our `/home/oracle` as the temporary location for the Data Pump files.

5. As are already logged in, we change the session focus to our new PDB (or container):

    ````
    SQL> <copy>alter session set container=PDB19C02;</copy>

    Session altered.
    ````
6. Create a new directory object that will be used by the DataPump import command:

    ````
    SQL> <copy>create directory homedir as '/home/oracle';</copy>

    Directory created.
    ````
7. Grant rights to the system user:

    ````
    SQL> <copy>grant read, write on directory homedir to system;</copy>

    Grant succeeded.
    ````
8. Create the database link the we will use during the Transportable Tablespace step:

    ````
    SQL> <copy>create public database link SOURCEDB
        connect to system identified by Welcome_123
        using '//localhost:1521/DB122';</copy>

    Database link created.
    ````

9. We can check the database link to see if it works by querying a remote table:

    ````
    SQL> <copy>select instance_name from v$instance@sourcedb;</copy>

    INSTANCE_NAME
    ----------------
    DB122
    ````

    To be sure, make sure the user we need (and the contents of the source database) does not already exist in our target database. The user that exists in the source database (but should not exist in the target database) is the user PARKINGFINE and the table the schema contains is called PARKING_CITATIONS.

10. First, check to see if the user exists in the target environment:
    ````
    SQL> <copy>select table_name from dba_tables where owner='PARKINGFINE';</copy>
    ````
    The correct answer should be:

    ````
    no rows selected
    ````

11. The second check, to be sure, see if the table exists in the source database:
    ````
    SQL> <copy>select table_name from dba_tables@sourcedb where owner='PARKINGFINE';</copy>
    ````

    The correct response should be:

    ````
    TABLE_NAME
    --------------------------------------------------------------------------------
    PARKING_CITATIONS
    ````

 12. As a quick check, we determine how many records are in the remote table:

    ````
    SQL> <copy>select count(*) from PARKINGFINE.PARKING_CITATIONS@sourcedb;</copy>
    ````

    The correct response should be:

    ````
      COUNT(*)
    ----------
       9060183
    ````

    The table and user exist in the source 12.2 database. They do not exist in the (target) PDB to which we are connected.

 13. We can now exit SQL*Plus on the target system to continue with the preparation of the source system.

    ````
    SQL> <copy>exit</copy>
    ````

## Task 2: Prepare the Source database ##

 To run the full transportable operation, we'll have to take all data tablespaces into read-only mode – the same procedure as we would do for a regular transportable tablespace operation. Once the tablespace (in this case, just the USERS tablespace) is in read-only mode, we can copy the file(s) to the target location. In our example, we only have one tablespace (USERS) that contains user data. If you execute an FTTS in another environment, make sure you identify all tablespaces!

1. Connect to the source 12.2 environment and start SQL*Plus as sysdba:

    ````
    $ <copy>. oraenv</copy>
    ````
    ````
    ORACLE_SID = [DB19C] ? <copy>DB122</copy>
    The Oracle base remains unchanged with value /u01/app/oracle
    ````

2. We can now log in to the user sys as sysdba:

    ````
    $ <copy>sqlplus / as sysdba</copy>

    SQL*Plus: Release 12.2.0.1.0 Production on Fri Apr 3 12:06:17 2020

    Copyright (c) 1982, 2016, Oracle.  All rights reserved.

    Connected to:
    Oracle Database 12c Enterprise Edition Release 12.2.0.1.0 - 64bit Production
    ````

### Set tablespace to READ ONLY and determine datafiles ###

 Change the tablespace USERS (so basically all tablespaces that contain user data) to READ ONLY to prepare it for transportation to the target database. Remember, in this example, we only have data in the USERS tablespace. If you do this in another environment, determine all tablespaces applicable using dba_objects and dba_segments.

3. Set the tablespace to READ-ONLY

    ````
    SQL> <copy>alter tablespace USERS READ ONLY;</copy>

    Tablespace altered.
    ````

4. We can now determine the data files that we need to copy to the target environment as part of the Transportable Tablespaces. We will only transport those tablespaces that contain user data:

    ````
    SQL> <copy>select name from v$datafile where ts# in (select ts#
                                                         from v$tablespace
                                                         where name='USERS');</copy>
    ````

    The following should be the result:

    ````
    NAME
    --------------------------------------------------------------------------------
    /u01/oradata/DB122/users01.dbf
    ````

5. Now that we have put the source tablespace to READ ONLY and know which data files we need to copy, we can copy or move the files to the target location. In our example, we will copy the files, but we could also have moved the files.

    If you copy the files, you have a fall-back scenario if something goes wrong (by simply changing the source tablespace to READ WRITE again). The downside is that you need extra disk space to hold the copy of the data files.

    Please exit SQL*Plus and disconnect from the source database.
    ````
    SQL> <copy>exit</copy>
    ````

## Task 3: Copy datafiles and import into 19c target PDB ##

1. First, we copy the files to the location we will use for the 19c target PDB:

    ````
    $ <copy>cp /u01/oradata/DB122/users01.dbf /u01/oradata/DB19C/PDB19C02</copy>
    ````

Now we can import the metadata of the database and the data (already copied and ready in the data files for the tablespace USERS in the new location) by executing a Datapump command. The Datapump import will be run through the database link you created earlier – thus no need for a file-based export or a dump file.

Data Pump will take care of everything (currently except XDB and AWR) you need from the system tablespaces and move views, synonyms, triggers, etc., over to the target database (in our case: PDB19C02). Data Pump can do this beginning from Oracle 11.2.0.3 on the source side but will require an Oracle 12c database as a target. Data Pump will work cross-platform as well but might need RMAN to convert the files from big to little-endian or vice-versa.

2. First, we change our environment parameters back to 19c:

    ````
    $ <copy>. oraenv</copy>
    ````
    ````
    ORACLE_SID = [DB122] ? <copy>DB19C</copy>
    The Oracle base remains unchanged with value /u01/app/oracle
    ````

3. We can now start the actual import process.

    ````
    $ <copy>impdp system/Welcome_123@//localhost:1521/PDB19C02 network_link=sourcedb \
            full=y transportable=always metrics=y exclude=statistics logfile=homedir:db122ToPdb.log \
            logtime=all transport_datafiles='/u01/oradata/DB19C/PDB19C02/users01.dbf'</copy>
    ````

    A similar output should be visible:

    ````
    Import: Release 19.0.0.0.0 - Production on Fri Apr 3 12:09:40 2020
    Version 19.3.0.0.0

    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

    Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    03-APR-20 12:09:50.511: Starting "SYSTEM"."SYS_IMPORT_FULL_01":  system/********@//localhost:1521/PDB19C02 network_link=sourcedb full=y transportable=always metrics=y exclude=statistics logfile=homedir:db122ToPdb.log    logtime=all transport_datafiles=/u01/oradata/DB19C/PDB19C02/users01.dbf
    03-APR-20 12:09:52.170: W-1 Startup took 2 seconds
    03-APR-20 12:09:52.297: W-1 Estimate in progress using BLOCKS method...
    03-APR-20 12:09:57.870: W-1 Processing object type DATABASE_EXPORT/PLUGTS_FULL/FULL/PLUGTS_TABLESPACE
    03-APR-20 12:09:57.993: W-1      Completed 0 PLUGTS_TABLESPACE objects in 5 seconds
    03-APR-20 12:09:57.993: W-1 Processing object type DATABASE_EXPORT/PLUGTS_FULL/PLUGTS_BLK
    03-APR-20 12:10:00.343: W-1      Completed 1 PLUGTS_BLK objects in 3 seconds
    03-APR-20 12:10:00.343: W-1 Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
    03-APR-20 12:10:02.984: W-1      Estimated 1 TABLE_DATA objects in 4 seconds
    03-APR-20 12:10:02.984: W-1 Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA
    03-APR-20 12:10:03.636: W-1      Estimated 63 TABLE_DATA objects in 3 seconds
    (etc)

    03-APR-20 12:14:01.118: W-1      Completed 1 DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 0 seconds
    03-APR-20 12:14:01.120: W-1      Completed 51 DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA objects in 22 seconds
    03-APR-20 12:14:01.122: W-1      Completed 18 DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA objects in 25 seconds
    03-APR-20 12:14:01.124: W-1      Completed 7 DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA objects in 3 seconds
    03-APR-20 12:14:01.397: Job "SYSTEM"."SYS_IMPORT_FULL_01" completed with 6 error(s) at Fri Apr 3 12:14:01 2020 elapsed 0 00:04:15
    ````

    Usually, you will find errors when using FTTS:

    ````
    03-APR-20 12:11:15.770: ORA-39083: Object type PROCACT_SCHEMA failed to create with error:
    ORA-31625: Schema SPATIAL_CSW_ADMIN_USR is needed to import this object, but is unaccessible
    ORA-01435: user does not exist
    ````

    or

    ````    
    03-APR-20 12:11:44.837: ORA-39342: Internal error - failed to import internal objects tagged with ORDIM due to ORA-00955: name is already used by an existing object
    ````

    By checking the log file, you need to determine if the errors harm your environment. In our migration, the errors should only be regarding a few users that could not be created.

## Task 4: Check the new upgraded target ##

The Data Pump process should have migrated the most crucial user in the database (PARKINGFINE). We can check the target database to see if our table has been imported as it should:

1. Login to the target database

    ````
    $ <copy>sqlplus / as sysdba</copy>

    SQL*Plus: Release 19.0.0.0.0 - Production on Fri Apr 3 12:14:44 2020
    Version 19.3.0.0.0

    Copyright (c) 1982, 2019, Oracle.  All rights reserved.

    Connected to:
    Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.3.0.0.0
    ````
2. Change the session environment to the PDB (container):

    ````
    SQL> <copy>alter session set container=PDB19C02;</copy>

    Session altered.
    ````
3. Check if the table that is so important, exists in the target database:

    ````
    SQL> <copy>select table_name from dba_tables where owner='PARKINGFINE';</copy>
    ````

    The result should be this:
    ````
    TABLE_NAME
    --------------------------------------------------------------------------------
    PARKING_CITATIONS
    ````

4. We can also check the number of records in the table by executing the following command:

    ````
    SQL> <copy>select count(*) from PARKINGFINE.PARKING_CITATIONS;</copy>
    ````

    The result should be this:

    ````
      COUNT(*)
    ----------
       9060183
    ````

    The migration seems to be successful.

You may now **proceed to the next lab**.

## Acknowledgements ##

- **Author** - Robert Pastijn, Database Product Management, PTS EMEA - March 2020
- **Last update** - Robert Pastijn, Database Product Management, PTS EMEA - November 2021
