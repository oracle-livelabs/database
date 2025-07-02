# Plugin UPGR into CDB2

## Introduction

In this lab, you will convert a non-CDB database (UPGR) to a PDB in a CDB (CDB2). For learning purposes, you will first do the process manually. Then, using AutoUpgrade. This allows you to compare the two methods.

Estimated Time: 30 minutes

[](videohub:1_w2g72fta)

### Objectives

In this lab, you will:
* Prepare UPGR for PDB conversion
* Check compatibility
* Plug in and convert
* Plug in using AutoUpgrade (optional)

### Prerequisites

This lab assumes:

- You have completed Lab 4: AutoUpgrade

## Task 1: Prepare UPGR for PDB conversion

1. Use the yellow terminal. Switch to the UPGR database in the 19c environment.

    ```
    <copy>
    . upgr19
    sqlplus / as sysdba
    </copy>
    ```
2. Restart UPGR in *read only* mode.

    ```
    <copy>
    shutdown immediate
    startup open read only;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> shutdown immediate
    Database closed.
    Database dismounted.
    ORACLE instance shut down.
    SQL> startup open read only;
    ORACLE instance started.

    Total System Global Area 1002437880 bytes
    Fixed Size                  8932600 bytes
    Variable Size             297795584 bytes
    Database Buffers          687865856 bytes
    Redo Buffers                7843840 bytes
    Database mounted.
    Database opened.        
    ```
    </details>

3. Create the manifest file. A manifest file describes the layout of a database. It is in XML format.

    ```
    <copy>
    exec DBMS_PDB.DESCRIBE('/home/oracle/pdb1.xml');
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> exec DBMS_PDB.DESCRIBE('/home/oracle/pdb1.xml');

    PL/SQL procedure successfully completed.
    ```
    </details>

4. Perform a clean shutdown of the UPGR database.

    ```
    <copy>
    shutdown immediate
    exit
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> shutdown immediate
    Database closed.
    Database dismounted.
    ORACLE instance shut down.
    SQL> exit
    Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.18.0.0.0
    ```
    </details>

5. Examine the manifest file.

    ```
    <copy>
    more /home/oracle/pdb1.xml
    </copy>
    ```
    
    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat /home/oracle/pdb1.xml 
    <?xml version="1.0" encoding="UTF-8"?>
    <PDB>
    <xmlversion>1</xmlversion>
    <pdbname>UPGR</pdbname>
    <cid>0</cid>
    <byteorder>1</byteorder>
    <vsn>318767104</vsn>
    <vsns>
        <vsnnum>19.0.0.0.0</vsnnum>
        <cdbcompt>11.2.0.4.0</cdbcompt>
        <pdbcompt>11.2.0.4.0</pdbcompt>
        <vsnlibnum>0.0.0.0.24</vsnlibnum>
        <vsnsql>24</vsnsql>
        <vsnbsv>8.0.0.0.0</vsnbsv>
    </vsns>
    <dbid>72245725</dbid>
    <ncdb2pdb>1</ncdb2pdb>
    <cdbid>72245725</cdbid>
    <guid>FFD3B6CE6601159CE055000000000001</guid>
    <uscnbas>2290231</uscnbas>
    <uscnwrp>0</uscnwrp>
    <undoscn>7</undoscn>
    <rdba>4474136</rdba>
    <tablespace>
        <name>SYSTEM</name>
        <type>0</type>
        <tsn>0</tsn>
        <status>1</status>
        <issft>0</issft>
        <isnft>0</isnft>
        <encts>0</encts>
        <flags>0</flags>
        <bmunitsize>8</bmunitsize>
        <file>
        <path>/u02/oradata/UPGR/system01.dbf</path>
        <afn>1</afn>
        <rfn>1</rfn>
        <createscnbas>7</createscnbas>
        <createscnwrp>0</createscnwrp>
        <status>1</status>
        <fileblocks>285440</fileblocks>
        <blocksize>8192</blocksize>
        <vsn>186647552</vsn>
        <fdbid>72245725</fdbid>
        <fcpsb>2290230</fcpsb>
        <fcpsw>0</fcpsw>
        <frlsb>1</frlsb>
        <frlsw>0</frlsw>
        <frlt>935418589</frlt>
        <autoext>1</autoext>
        <maxsize>4194302</maxsize>
        <incsize>1280</incsize>
        <plugscn>0</plugscn>
        <plugafn>0</plugafn>
        <plugdbid>0</plugdbid>
        <dfflags>1</dfflags>
        </file>
    </tablespace>
    <tablespace>
        <name>SYSAUX</name>
        <type>0</type>
        <tsn>1</tsn>
        <status>1</status>
        <issft>0</issft>
        <isnft>0</isnft>
        <encts>0</encts>
        <flags>0</flags>
        <bmunitsize>8</bmunitsize>
        <file>
        <path>/u02/oradata/UPGR/sysaux01.dbf</path>
        <afn>2</afn>
        <rfn>2</rfn>
        <createscnbas>1831</createscnbas>
        <createscnwrp>0</createscnwrp>
        <status>1</status>
        <fileblocks>76800</fileblocks>
        <blocksize>8192</blocksize>
        <vsn>186647552</vsn>
        <fdbid>72245725</fdbid>
        <fcpsb>2290230</fcpsb>
        <fcpsw>0</fcpsw>
        <frlsb>1</frlsb>
        <frlsw>0</frlsw>
        <frlt>935418589</frlt>
        <autoext>1</autoext>
        <maxsize>4194302</maxsize>
        <incsize>1280</incsize>
        <plugscn>0</plugscn>
        <plugafn>0</plugafn>
        <plugdbid>0</plugdbid>
        <dfflags>1</dfflags>
        </file>
    </tablespace>
    <tablespace>
        <name>UNDOTBS1</name>
        <type>2</type>
        <tsn>2</tsn>
        <status>1</status>
        <issft>0</issft>
        <isnft>0</isnft>
        <encts>0</encts>
        <flags>0</flags>
        <bmunitsize>8</bmunitsize>
        <file>
        <path>/u02/oradata/UPGR/undotbs01.dbf</path>
        <afn>3</afn>
        <rfn>3</rfn>
        <createscnbas>2869</createscnbas>
        <createscnwrp>0</createscnwrp>
        <status>1</status>
        <fileblocks>64000</fileblocks>
        <blocksize>8192</blocksize>
        <vsn>186647552</vsn>
        <fdbid>72245725</fdbid>
        <fcpsb>2290230</fcpsb>
        <fcpsw>0</fcpsw>
        <frlsb>1</frlsb>
        <frlsw>0</frlsw>
        <frlt>935418589</frlt>
        <autoext>1</autoext>
        <maxsize>4194302</maxsize>
        <incsize>640</incsize>
        <plugscn>0</plugscn>
        <plugafn>0</plugafn>
        <plugdbid>0</plugdbid>
        <dfflags>1</dfflags>
        </file>
    </tablespace>
    <tablespace>
        <name>TEMP</name>
        <type>1</type>
        <tsn>3</tsn>
        <status>1</status>
        <issft>0</issft>
        <isnft>0</isnft>
        <encts>0</encts>
        <flags>0</flags>
        <bmunitsize>128</bmunitsize>
        <file>
        <path>/u02/oradata/UPGR/temp01.dbf</path>
        <afn>1</afn>
        <rfn>1</rfn>
        <createscnbas>3247</createscnbas>
        <createscnwrp>0</createscnwrp>
        <status>1</status>
        <fileblocks>15488</fileblocks>
        <blocksize>8192</blocksize>
        <vsn>186647552</vsn>
        <autoext>1</autoext>
        <maxsize>4194302</maxsize>
        <incsize>80</incsize>
        <plugscn>0</plugscn>
        <plugafn>0</plugafn>
        <plugdbid>0</plugdbid>
        <dfflags>1</dfflags>
        </file>
    </tablespace>
    <tablespace>
        <name>USERS</name>
        <type>0</type>
        <tsn>4</tsn>
        <status>1</status>
        <issft>0</issft>
        <isnft>0</isnft>
        <encts>0</encts>
        <flags>0</flags>
        <bmunitsize>8</bmunitsize>
        <file>
        <path>/u02/oradata/UPGR/users01.dbf</path>
        <afn>4</afn>
        <rfn>4</rfn>
        <createscnbas>16063</createscnbas>
        <createscnwrp>0</createscnwrp>
        <status>1</status>
        <fileblocks>640</fileblocks>
        <blocksize>8192</blocksize>
        <vsn>186647552</vsn>
        <fdbid>72245725</fdbid>
        <fcpsb>2290230</fcpsb>
        <fcpsw>0</fcpsw>
        <frlsb>1</frlsb>
        <frlsw>0</frlsw>
        <frlt>935418589</frlt>
        <autoext>1</autoext>
        <maxsize>4194302</maxsize>
        <incsize>160</incsize>
        <plugscn>0</plugscn>
        <plugafn>0</plugafn>
        <plugdbid>0</plugdbid>
        <dfflags>1</dfflags>
        </file>
    </tablespace>
    <tablespace>
        <name>TPCCTAB</name>
        <type>0</type>
        <tsn>5</tsn>
        <status>1</status>
        <issft>0</issft>
        <isnft>0</isnft>
        <encts>0</encts>
        <flags>0</flags>
        <bmunitsize>8</bmunitsize>
        <file>
        <path>/u02/oradata/UPGR/tpcctab01.dbf</path>
        <afn>5</afn>
        <rfn>5</rfn>
        <createscnbas>363745</createscnbas>
        <createscnwrp>0</createscnwrp>
        <status>1</status>
        <fileblocks>131072</fileblocks>
        <blocksize>8192</blocksize>
        <vsn>186647552</vsn>
        <fdbid>72245725</fdbid>
        <fcpsb>2290230</fcpsb>
        <fcpsw>0</fcpsw>
        <frlsb>1</frlsb>
        <frlsw>0</frlsw>
        <frlt>935418589</frlt>
        <autoext>1</autoext>
        <maxsize>4194302</maxsize>
        <incsize>1</incsize>
        <plugscn>0</plugscn>
        <plugafn>0</plugafn>
        <plugdbid>0</plugdbid>
        <dfflags>1</dfflags>
        </file>
    </tablespace>
    <recover>0</recover>
    <optional>
        <ncdb2pdb>1</ncdb2pdb>
        <csid>873</csid>
        <ncsid>2000</ncsid>
        <options>
        <option>CATALOG=19.0.0.0.0</option>
        <option>CATPROC=19.0.0.0.0</option>
        <option>OLS=19.0.0.0.0</option>
        <option>OWM=19.0.0.0.0</option>
        <option>XDB=19.0.0.0.0</option>
        </options>
        <olsoid>0</olsoid>
        <dv>0</dv>
        <APEX>NULL</APEX>
        <parameters>
        <parameter>processes=330</parameter>
        <parameter>sessions=520</parameter>
        <parameter>sga_target=1002438656</parameter>
        <parameter>db_block_size=8192</parameter>
        <parameter>compatible='11.2.0.4.0'</parameter>
        <parameter>_cursor_obsolete_threshold=1024</parameter>
        <parameter>open_cursors=300</parameter>
        <parameter>pga_aggregate_target=104857600</parameter>
        <parameter>deferred_segment_creation=FALSE</parameter>
        </parameters>
        <sqlpatches>
        <sqlpatch>19.18.0.0.0 Release_Update 2301111717 (RU): APPLY SUCCESS</sqlpatch>
        <sqlpatch>Interim patch 34786990/25032666 (OJVM RELEASE UPDATE: 19.18.0.0.230117 (34786990)): APPLY SUCCESS</sqlpatch>
        <sqlpatch>Interim patch 34861493/25121986 (RESYNC CATALOG FAILED IN ZDLRA CATALOG AFTER PROTECTED DATABASE PATCHED TO 19.17): APPLY SUCCESS</sqlpatch>
        <sqlpatch>Interim patch 34972375/25075164 (DATAPUMP BUNDLE PATCH 19.18.0.0.0): APPLY SUCCESS</sqlpatch>
        <sqlpatch>Interim patch 35160800/25179433 (GG IE FAILS WITH ORA-14400 AT SYSTEM.LOGMNRC_USER AFTER ORACLE DB UPGRADE TO 19.18DBRU): APPLY SUCCESS</sqlpatch>
        </sqlpatches>
        <tzvers>
        <tzver>primary version:40</tzver>
        <tzver>secondary version:0</tzver>
        </tzvers>
        <walletkey>0</walletkey>
        <services>
        <service>SYS$BACKGROUND,</service>
        <service>SYS$USERS,</service>
        <service>UPGRXDB,UPGRXDB</service>
        <service>UPGR,UPGR</service>
        </services>
        <opatches/>
        <hasclob>1</hasclob>
        <awr/>
        <hardvsnchk>0</hardvsnchk>
        <localundo>1</localundo>
        <apps/>
        <dbedition>8</dbedition>
        <dvopsctl>2</dvopsctl>
        <clnupsrcpal>1</clnupsrcpal>
    </optional>
    </PDB>
    ```
    </details>    

## Task 2: Check compatibility

1. Switch to CDB2.

    ```
    <copy>
    . cdb2
    sqlplus / as sysdba
    </copy>
    ```

1. Check whether you can plug in the UPGR database without problems. The check finds potential problems.

    ```
    <copy>
    set serveroutput on

    DECLARE
    compatible CONSTANT VARCHAR2(3) := CASE DBMS_PDB.CHECK_PLUG_COMPATIBILITY( pdb_descr_file => '/home/oracle/pdb1.xml', pdb_name => 'PDB1') WHEN TRUE THEN 'YES' ELSE 'NO'
    END;
    BEGIN
    DBMS_OUTPUT.PUT_LINE('Is the future PDB compatible? ==> ' || compatible);
    END;
    /
    </copy>
    ```
    
    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> set serveroutput on
    SQL> DECLARE
        compatible CONSTANT VARCHAR2(3) := CASE DBMS_PDB.CHECK_PLUG_COMPATIBILITY( pdb_descr_file => '/home/oracle/pdb1.xml', pdb_name => 'PDB1') WHEN TRUE THEN 'YES' ELSE 'NO'
        END;
        BEGIN
        DBMS_OUTPUT.PUT_LINE('Is the future PDB compatible? ==> ' || compatible);
        END;
        /  2    3    4    5    6    7  
    Is the future PDB compatible? ==> YES

    PL/SQL procedure successfully completed.
    ```
    </details>

    * Notice the check reports *YES*. This means there are no severe issues.
    * Often, on real databases, the check reports *NO*. This means that there are severe issues that interfere with the PDB conversion.

2. Get the details of the check.    

    ```
    <copy>
    set pagesize 100
    set linesize 200
    col type format a8
    col message format a100
    select type, message 
    from pdb_plug_in_violations 
    where status != 'RESOLVED' and name='PDB1'
    order by type, message;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> col type format a8
    SQL> col message format a70
    SQL> select type, message 
         from pdb_plug_in_violations 
         where status != 'RESOLVED' 
         order by type, message;
    TYPE	 MESSAGE
    -------- ----------------------------------------------------------------------
    WARNING  CDB parameter compatible mismatch: Previous '11.2.0.4.0' Current '19.0.0'
    WARNING  CDB parameter pga_aggregate_target mismatch: Previous 100M Current 200M
    WARNING  CDB parameter processes mismatch: Previous 330 Current 300
    WARNING  CDB parameter sessions mismatch: Previous 520 Current 472
    WARNING  CDB parameter sga_target mismatch: Previous 956M Current 1504M
    WARNING  Database option CATJAVA mismatch: PDB installed version NULL. CDB installed version 19.0.0.0.0.
    WARNING  Database option JAVAVM mismatch: PDB installed version NULL. CDB installed version 19.0.0.0.0.
    WARNING  Database option ORDIM mismatch: PDB installed version NULL. CDB installed version 19.0.0.0.0.
    WARNING  Database option XML mismatch: PDB installed version NULL. CDB installed version 19.0.0.0.0.
    WARNING  PDB plugged in is a non-CDB, requires noncdb_to_pdb.sql be run.

    10 rows selected.
    ```
    </details>

    * Notice there are only warnings. Some are fixed automatically on plug-in. Some, like the message about `noncdb_to_pdb.sql` requires manual intervention.

## Task 3: Plug in and convert

Still connected to CDB2 (the target CDB), you will now plug in UPGR and convert it to a PDB.

1. Plug in UPGR and rename it to PDB1.

    ```
    <copy>
    create pluggable database PDB1 using '/home/oracle/pdb1.xml' nocopy tempfile reuse;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> create pluggable database PDB1 using '/home/oracle/pdb1.xml' nocopy tempfile reuse;

    Pluggable database created.
    ```
    </details>

    * The database uses the manifest file to get the required information about the UPGR database.
    * The `nocopy` clause instructs the database to reuse the existing data files. This means that there is no non-CDB UPGR database anymore. In a real-world environment, you would have a backup of the data files or use the `copy` clause to take a copy of the data files before backup. Of course, the latter approach requires time to copy the data files and additional disk space.
    
2. Check the PDBs in the CDB.

    ```
    <copy>
    show pdbs
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> show pdbs

        CON_ID CON_NAME                       OPEN MODE  RESTRICTED
    ---------- ------------------------------ ---------- ----------
             2 PDB$SEED                       READ ONLY  NO
             3 PDB1                           MOUNTED
    ```
    </details>

    Notice PDB1 is closed (*OPEN MODE* is *MOUNTED*).

3. Open PDB1.

    ```
    <copy>
    alter pluggable database PDB1 open;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter pluggable database PDB1 open;

    Warning: PDB altered with errors.
    ```
    </details>

4. The PDB opens with errors. Check the errors.
    
    ```
    <copy>
    column message format a70
    column type format a9
    select type, message from PDB_PLUG_IN_VIOLATIONS
    where status<>'RESOLVED' and name='PDB1' 
    order by type, message;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> column message format a70
    SQL> column type format a9
    SQL> select type, message from PDB_PLUG_IN_VIOLATIONS
         where status<>'RESOLVED' and name='PDB1' 
         order by type, message;

         TYPE MESSAGE
    --------- ----------------------------------------------------------------------
        ERROR PDB plugged in is a non-CDB, requires noncdb_to_pdb.sql be run.
      WARNING CDB parameter compatible mismatch: Previous '11.2.0.4.0' Current '19.0.0'
      WARNING CDB parameter pga_aggregate_target mismatch: Previous 100M Current 200M
      WARNING CDB parameter processes mismatch: Previous 330 Current 300
      WARNING CDB parameter sessions mismatch: Previous 520 Current 472
      WARNING CDB parameter sga_target mismatch: Previous 956M Current 1504M
      WARNING Database option CATJAVA mismatch: PDB installed version NULL. CDB installed version 19.0.0.0.0.
      WARNING Database option JAVAVM mismatch: PDB installed version NULL. CDB installed version 19.0.0.0.0.
      WARNING Database option ORDIM mismatch: PDB installed version NULL. CDB installed version 19.0.0.0.0.
      WARNING Database option XML mismatch: PDB installed version NULL. CDB installed version 19.0.0.0.0.

    10 rows selected.     
    ```
    </details>

    * Notice the first row. This is an error and you must fix this before the PDB can open in *read write mode* and unrestricted. 
    * The reason is that you haven't executed `noncdb_to_pdb.sql` yet.

5. Fix the error about the missing `noncdb_to_pdb.sql` script. 

    ```
    <copy>
    alter session set container=PDB1;
    @?/rdbms/admin/noncdb_to_pdb.sql
    </copy>
     
    Be sure to hit RETURN
    ```

    * The script converts the database to a proper PDB. The conversion is irreversible.
    * In the lab, it usually takes 5-10 minutes.
    * The runtime depends mostly on the number of objects in the database.

6. When the script completes, restart the PDB.

    ```
    <copy>
    shutdown immediate
    startup
    </copy>
     
    Be sure to hit RETURN
    ```
    
    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> shutdown immediate
    Pluggable Database closed.
    SQL> startup
    Pluggable Database opened.
    ```
    </details>

    * Because you are connected to the PDB (`ALTER SESSION SET CONTAINER`), the `shutdown` and `startup` command restarts the PDB, not the entire CDB.

7. Check the status of the PDB.

    ```
    <copy>
    show pdbs
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> show pdbs

        CON_ID CON_NAME                       OPEN MODE  RESTRICTED
    ---------- ------------------------------ ---------- ----------
             3 PDB1                           READ WRITE NO
    ```
    </details>

    * PDB1 now opens in *read write* mode and unrestricted.
    * This means that the PDB has been fully converted and there are no errors.

8. Now, save the state so the PDB automatically starts when you restart the CDB.

    ```
    <copy>
    alter pluggable database PDB1 save state;
    </copy>
    ```
    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter pluggable database PDB1 save state;

    Pluggable database altered.
    ```
    </details>

9. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```
10. Try to connect directly to PDB1. 

    ```
    <copy>
    sqlplus system/oracle@pdb1
    </copy>
    ```
 
    * You are connecting via SQL*Net using a TNS alias. The alias connects to the PDB via its service name

11. Verify you are connected directly to the PDB.

    ```
    <copy>
    select sys_context('USERENV', 'CON_NAME') as PDB from dual;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select sys_context('USERENV', 'CON_NAME') as PDB from dual;

    PDB
    --------------------------------------------------------------------------------
    PDB1
    ```
    </details>
    
12. Exit SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```
## Task 4: Plug in using AutoUpgrade (optional)

Now that you know how to manually perform a PDB conversion, you can explore the easy option: AutoUpgrade. Using a different database (UP19), you will perform the same operation but this time using AutoUpgrade. Both the non-CDB and CDB is running on Oracle Database 19c. AutoUpgrade detects this and will skip the upgrade and proceed directly to the plug-in operation. 

1. Set the environment to UP19 and connect.

    ```
    <copy>
    . up19
    sqlplus / as sysdba
    </copy>

    Be sure to hit RETURN
    ```

2. Start the database.

    ```
    <copy>
    startup;
    exit
    </copy>

    Be sure to hit RETURN
    ```

2. Examine the below AutoUpgrade config file. 

    ```
    <copy>
    cat /home/oracle/scripts/lab9-up19.cfg
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat /home/oracle/scripts/lab9-up19.cfg
    global.autoupg_log_dir=/home/oracle/logs/lab9-up19
    upg1.source_home=/u01/app/oracle/product/19
    upg1.target_home=/u01/app/oracle/product/19
    upg1.sid=UP19
    upg1.target_pdb_name=UP19PDB
    upg1.target_cdb=CDB2
    upg1.target_pdb_copy_option=file_name_convert=none
    upg1.restoration=no
    ```
    </details>

    * `sid` specifies the database that you want to convert.
    * `target_pdb_name` instructs AutoUpgrade to rename the database to *UP19PDB*.
    * `target_cdb` specifies the existing CDB that you want to plug into.
    * By specifying `target_pdb_copy_option` you instruct AutoUpgrade to make a copy of the data files. `file_name_convert=none` instructs the database to use OMF.
    * `restoration` is needed because the database is in *NOARCHIVELOG* mode.


3. Start the PDB conversion. 

    ```
    <copy>
    java -jar $ORACLE_HOME/rdbms/admin/autoupgrade.jar -config /home/oracle/scripts/lab9-up19.cfg -mode deploy
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ java -jar $ORACLE_HOME/rdbms/admin/autoupgrade.jar -config /home/oracle/scripts/lab9-up19.cfg -mode deploy
    AutoUpgrade 23.2.230626 launched with default internal options
    Processing config file ...
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    1 Non-CDB(s) will be processed
    Type 'help' to list console commands
    upg> 
    ```
    </details>

4. You are now in the AutoUpgrade console. Use `lsj` command to monitor the conversion. The conversion should complete in 10-15 minutes.

    ```
    <copy>
    lsj -a 30
    </copy>
    ```

5. When AutoUpgrade reports *Job 100 completed* then the PDB conversion is done. 

6. Connect to the new PDB, *UP19PDB*.
    
    ```
    <copy>
    . cdb2
    sqlplus system/oracle@localhost/up19pdb
    </copy>
    ```

7. Ensure that the PDB is opened in *read-write* mode and unrestricted.

    ```
    <copy>
    col name format a20
    col open_mode format a15
    col restricted format a15
    select name, open_mode, restricted from v$pdbs;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> col name format a20
    SQL> col open_mode format a15
    SQL> col restricted format a15
    SQL> select name, open_mode, restricted from v$pdbs;

    NAME                 OPEN_MODE            RESTRICTED
    -------------------- -------------------- --------------------
    UP19PDB              READ WRITE           NO

    ```
    </details>

8. Exit from SQL*Plus.

    ```
    <copy>
    exit
    </copy>
    ```    

9. In this task, you did not check for plug-in compatibility using a manifest file (like you did in tasks 1 and 2). On a real database you should do that; it is best practice. When you need to check for plug-in compatibility, you can generate the manifest file without having the database in read-only mode.

You may now *proceed to the next lab*.

## Learn More

* Documentation, [Multitenant Architecture](https://docs.oracle.com/en/database/oracle/oracle-database/19/multi/introduction-to-the-multitenant-architecture.html#GUID-267F7D12-D33F-4AC9-AA45-E9CD671B6F22)
* Webinar, [Migrate to multitenant architecture, Migration method: Plug-in NoCopy](https://www.youtube.com/watch?v=7PNTJqbX5Ew&t=2070s)

## Acknowledgements
* **Author** - Mike Dietrich
* **Contributors** - Daniel Overby Hansen, Roy Swonger, Sanjay Rupprel, Cristian Speranta, Kay Malcolm
* **Last Updated By/Date** - Daniel Overby Hansen, August 2023
