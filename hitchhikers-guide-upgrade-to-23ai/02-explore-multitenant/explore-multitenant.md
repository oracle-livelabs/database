# Explore Multitenant Architecture

## Introduction

In this lab, you will familiarize yourself with the multitenant architecture.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

* Understand the concept of containers
* Connect to a CDB and PDBs
* See how multitenant database works

### Prerequisites

This lab assumes:

- You have completed Lab 1: Initialize Environment

This is an optional lab. You can skip it if you are already familiar with multitenant architecture.

## Task 1: Connect to a CDB and a PDB

You connect to the CDB, find a list of PDBs and connect to them using different means.

1. Set the environment to *CDB23* and connect.

    ```
    <copy>
    . cdb23
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Get a list of PDBs.

    ```
    <copy>
    show pdbs
    </copy>
    ```

    * There are three user-created PDBs, *RED*, *BLUE*, *GREEN*. 
    * *PDB$SEED* is an special container used to create new PDBs.
    * *RED* is open in *READ WRITE* mode and *unrestricted*. This is an open PDB that users can connect to.
    * *BLUE* and *GREEN* are in *MOUNTED* mode. These are closed PDBs that users can't connect to.
    * Sometimes you see a PDB open in *READ WRITE* mode but *restricted*. This means that the PDB is open, but only someone with *SYSDBA* privilege can connect. Often, there is a problem with the PDB that you must fix before normal users can connect.
    * Rarely, you see a PDB in *UPGRADE* or *DOWNGRADE* mode. These are special modes used for upgrades and downgrades and very special maintenance operations.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    CON_ID CON_NAME OPENMODE   RESTRICTED
    ______ ________ __________ __________
    2      PDB$SEED READ ONLY  NO
    3      RED      READ WRITE NO
    4      BLUE     MOUNTED    
    6      GREEN    MOUNTED
    ```
    </details>

3. Start the PDB called *BLUE*.

    ```
    <copy>
    alter pluggable database blue open;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter pluggable database blue open;

    Pluggable database BLUE altered.
    ```
    </details>

4. Get a list of PDBs in a different way.

    ```
    <copy>
    select con_id, name, open_mode, restricted from v$pdbs;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    CON_ID CON_NAME OPENMODE   RESTRICTED
    ______ ________ __________ __________
    2      PDB$SEED READ ONLY  NO
    3      RED      READ WRITE NO
    4      BLUE     READ WRITE NO
    6      GREEN    MOUNTED
    ```
    </details>

5. Get a list of containers.

    ```
    <copy>
    select con_id, name, open_mode, restricted from v$containers;
    </copy>
    ```

    * By selecting from `v$containers` instead of `v$pdbs` you can see information about the root container (*CDB$ROOT*) as well.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    CON_ID CON_NAME OPENMODE   RESTRICTED
    ______ ________ __________ __________
    1      CDB$ROOT READ WRITE NO
    2      PDB$SEED READ ONLY  NO
    3      RED      READ WRITE NO
    4      BLUE     READ WRITE NO
    6      GREEN    MOUNTED
    ```
    </details>

6. See which PDBs open automatically when the CDB starts.

    ```
    <copy>
    select con_name, state from dba_pdb_saved_states;
    </copy>
    ```

    * Only *RED* opens together with the CDB.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    CON_NAME    STATE
    ___________ ________
    RED         OPEN
    ```
    </details>

7. Set *BLUE* to auto-start. Ensure the current state is as desired and save state.

    ```
    <copy>
    select open_mode from v$pdbs where name='BLUE';
    alter pluggable database BLUE save state;
    select state from dba_pdb_saved_states where con_name='BLUE';
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select open_mode from v$pdbs where name='BLUE';

    OPEN_MODE
    _____________
    READ WRITE

    SQL> alter pluggable database BLUE save state;

    Pluggable database BLUE altered.

    SQL> select state from dba_pdb_saved_states where con_name='BLUE';

    STATE
    ________
    OPEN
    ```
    </details>

8. *GREEN* is currently closed. Open it and save state.

    ```
    <copy>
    alter pluggable database GREEN open;
    alter pluggable database GREEN save state;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter pluggable database GREEN open;

    Pluggable database GREEN altered.

    SQL> alter pluggable database GREEN save state;

    Pluggable database GREEN altered.
    ```
    </details>

9. Exit SQLcl.

    ```
    <copy>
    exit
    </copy>
    ```

10. The CDB automatically creates services for each PDB. Get a list of services.

    ```
    <copy>
    lsnrctl status
    </copy>
    ```

    * Notice how a service has been created for the PDBs.

    <details>
    <summary>*click to see the output (output may vary)*</summary>
    ``` text
    LSNRCTL for Linux: Version 23.0.0.0.0 - Production on 23-MAY-2024 13:11:02

    Copyright (c) 1991, 2024, Oracle.  All rights reserved.

    Connecting to (ADDRESS=(PROTOCOL=tcp)(HOST=)(PORT=1521))
    STATUS of the LISTENER
    ------------------------
    Alias                     LISTENER
    Version                   TNSLSNR for Linux: Version 23.0.0.0.0 - Production
    Start Date                23-MAY-2024 13:09:53
    Uptime                    0 days 0 hr. 1 min. 8 sec
    Trace Level               off
    Security                  ON: Local OS Authentication
    SNMP                      OFF
    Listener Log File         /u01/app/oracle/diag/tnslsnr/holserv1/listener/alert/log.xml
    Listening Endpoints Summary...
      (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=holserv1.livelabs.oraclevcn.com)(PORT=1521)))
    Services Summary...
    .
    .
    .
    Service "CDB23" has 1 instance(s).
      Instance "CDB23", status READY, has 1 handler(s) for this service...
    Service "CDB23XDB" has 1 instance(s).
      Instance "CDB23", status READY, has 1 handler(s) for this service...
    Service "blue" has 1 instance(s).
      Instance "CDB23", status READY, has 1 handler(s) for this service...
    Service "green" has 1 instance(s).
      Instance "CDB23", status READY, has 1 handler(s) for this service...
    Service "red" has 1 instance(s).
      Instance "CDB23", status READY, has 1 handler(s) for this service...
    The command completed successfully
    ```
    </details>

11. Connect to a PDB via a service.

    ```
    <copy>
    sqlplus system/oracle@localhost/red
    </copy>
    ```

12. Verify you are connected to *RED*.

    ```
    <copy>
    select sys_context('USERENV', 'CON_NAME') from dual;
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SYS_CONTEXT('USERENV','CON_NAME')
    ____________________________________
    RED
    ```
    </details>

13. Switch to *GREEN* using the `ALTER SESSION` command and verify the outcome.

    ```
    <copy>
    alter session set container=green;
    show con_name
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter session set container=green;

    Session altered.

    SQL> show con_name

    CON_NAME
    ------------------------------
    GREEN
    ```
    </details>

## Task 2: Check Parameters

You check initialization parameters and set some in the CDB. Also, find a list of PDBs and connect to them using different means.

1. Switch back to the root container.

    ```
    <copy>
    alter session set container=cdb$root;
    </copy>
    ```


1. Get a list of non-default parameters in the pluggable databases.

    ```
    <copy>
    select con_id, name, value
    from v$system_parameter
    where isdefault = 'FALSE' and con_id != 0
    order by 1, 2;
    </copy>
    ```

    * Notice only a few parameters are set in the PDBs.
    * All others rely on the value from *CDB$ROOT* (`con_id=0`).
    * Notice how each PDB has an undo tablespaces. This is a consequence of using *local undo* which is the default and strongly recommended. Local undo enables many key features in Multitenant, like hot cloning.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
       CON_ID NAME               VALUE
    _________ __________________ ___________
            2 sga_target         0
            2 undo_tablespace
            3 sga_target         0
            3 undo_tablespace    UNDOTBS1
            4 sga_target         0
            4 undo_tablespace    UNDOTBS1
            6 sga_target         0
            6 undo_tablespace    UNDOTBS1

    8 rows selected.
    ```
    </details>

2. Connect to the *RED* and raise *sga_target* to 500M. This set a minimum allocation for *RED*.

    ```
    <copy>
    alter session set container=RED;
    alter system set sga_target=500M scope=both;
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> alter session set container=RED;

    Session altered.

    SQL> alter system set sga_target=500M scope=both;

    System altered.
    ```
    </details>

3. Check the value using the same query.

    ```
    <copy>
    select con_id, name, value
    from v$system_parameter
    where isdefault='FALSE' and con_id != 0
    order by 1, 2;
    </copy>
    ```

    * Notice how only *con_id* shows up in the list. Inside a PDB, you can't see information from the CDB or other PDBs.
    * *sga_target* now has a minimum value of 500M.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
       CON_ID NAME               VALUE
    _________ __________________ ____________
            3 sga_target         524288000
            3 undo_tablespace    UNDOTBS1
    ```
    </details>

## Task 3: Check Views

You check DBA and CDB views.

1. Connect back to the root container. Generate a list of tablespaces in the root container.

    ```
    <copy>
    alter session set container=CDB$ROOT;
    select tablespace_name from dba_tablespaces;
    </copy>

    -- Be sure to hit RETURN
    ```

    * Notice you are using a DBA view.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    TABLESPACE_NAME
    __________________
    SYSTEM
    SYSAUX
    UNDOTBS1
    TEMP
    USERS
    ```
    </details>

2. Generate a list of all tablespaces in all containers.

    ```
    <copy>
    select t.con_id, c.name, t.tablespace_name
    from cdb_tablespaces t, v$containers c
    where t.con_id=c.con_id
    order by 1, 3;
    </copy>
    ```

    * You have to join on `v$containers` to translate the container ID to its name.
    * Notice you are using a CDB view.
    * CDB views are similar to DBA views, but they show the result from the entire CDB.
    * For each DBA view there is a similar CDB view.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
       CON_ID NAME        TABLESPACE_NAME
    _________ ___________ __________________
            1 CDB$ROOT    SYSAUX
            1 CDB$ROOT    SYSTEM
            1 CDB$ROOT    TEMP
            1 CDB$ROOT    UNDOTBS1
            1 CDB$ROOT    USERS
            3 RED         SYSAUX
            3 RED         SYSTEM
            3 RED         TEMP
            3 RED         UNDOTBS1
            4 BLUE        SYSAUX
            4 BLUE        SYSTEM
            4 BLUE        TEMP
            4 BLUE        UNDOTBS1
            6 GREEN       SYSAUX
            6 GREEN       SYSTEM
            6 GREEN       TEMP
            6 GREEN       UNDOTBS1

    17 rows selected.
    ```
    </details>

2. By default, the CDB does not show information about *PDB$SEED*. Generate the same list but include information about the seed container.

    ```
    <copy>
    alter system set "_exclude_seed_cdb_view"=false;
    select t.con_id, c.name, t.tablespace_name
    from cdb_tablespaces t, v$containers c
    where t.con_id=c.con_id
    order by 1, 3;
    </copy>

    -- Be sure to hit RETURN
    ```

    * Records from PDB$SEED is now included (`con_id=2`).

    <details>
    <summary>*click to see the output*</summary>
    ``` text
       CON_ID NAME        TABLESPACE_NAME
    _________ ___________ __________________
            1 CDB$ROOT    SYSAUX
            1 CDB$ROOT    SYSTEM
            1 CDB$ROOT    TEMP
            1 CDB$ROOT    UNDOTBS1
            1 CDB$ROOT    USERS
            2 PDB$SEED    SYSAUX
            2 PDB$SEED    SYSTEM
            2 PDB$SEED    TEMP
            2 PDB$SEED    UNDOTBS1
            3 RED         SYSAUX
            3 RED         SYSTEM
            3 RED         TEMP
            3 RED         UNDOTBS1
            4 BLUE        SYSAUX
            4 BLUE        SYSTEM
            4 BLUE        TEMP
            4 BLUE        UNDOTBS1
            6 GREEN       SYSAUX
            6 GREEN       SYSTEM
            6 GREEN       TEMP
            6 GREEN       UNDOTBS1

    21 rows selected.
    ```
    </details>

3. Multitenant architecture isolates each PDB. One PDB knows nothing about the CDB or other PDBs. Connect to a PDB and verify it.

    ```
    <copy>
    alter session set container=GREEN;
    select t.con_id, c.name, t.tablespace_name
    from cdb_tablespaces t, v$containers c
    where t.con_id=c.con_id
    order by 1, 3;
    </copy>

    -- Be sure to hit RETURN
    ```

    * Notice how the same query now returns fewer rows. Only the rows from the PDB.
    * Only container ID 6 is shown. All other containers are hidden.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
       CON_ID NAME        TABLESPACE_NAME
    _________ ___________ __________________
            6 GREEN       SYSAUX
            6 GREEN       SYSTEM
            6 GREEN       TEMP
            6 GREEN       UNDOTBS1

    4 rows selected.
    ```
    </details>

3. Exit SQLcl.

    ```
    <copy>
    exit
    </copy>
    ```

## Task 4: Run Scripts

You want to run a script in a CDB including all PDBs.

1. The Oracle home contains a program that can execute scripts in a CDB. Explore the options of *catcon.pl*.

    ```
    <copy>
    $ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl --help
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    Usage: catcon  [-h, --help]
                   [-u, --usr username
                     [{/password | -w, --usr_pwd_env_var env-var-name}]]
                   [-U, --int_usr username
                     [{/password | -W, --int_usr_pwd_env_var env-var-name]]
                   [-d, --script_dir directory]
                   [-l, --log_dir directory]
                   [{-c, --incl_con | -C, --excl_con} container]
                   [-p, --catcon_instances degree-of-parallelism]
                   [-z, --ez_conn EZConnect-strings]
                   [-e, --echo]
                   [-s, --spool]
                   [-E, --error_logging
                     { ON | errorlogging-table-other-than-SPERRORLOG } ]
                   [-F, --app_con Application-Root]
                   [-V, --ignore_errors errors-to-ignore ]
                   [-I, --no_set_errlog_ident]
                   [-g, --diag]
                   [-v, --verbose]
                   [-f, --ignore_unavailable_pdbs]
                   [--fail_on_unopenable_pdbs]
                   [-r, --reverse]
                   [-R, --recover]
                   [-m, --pdb_seed_mode pdb-mode]
                   [--force_pdb_mode pdb-mode]
                   [--all_instances]
                   [--upgrade]
                   [--ezconn_to_pdb pdb-name]
                   [--sqlplus_dir directory]
                   [--dflt_app_module app-module]
                   [-n]
                   [--kill_kgl_x_blocker]
                   [--ddl_lock_timeout time-in-sec]
                   [--app_action_no_arg]
                   -b, --log_file_base log-file-name-base
                   --
                   { sqlplus-script [arguments] | --x<SQL-statement> } ...

    (output truncated)
    ```
    </details>

2. Recompile invalid objects in all containers using *utlrp.sql*.

    ```
    <copy>
    $ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl \
       -d $ORACLE_HOME/rdbms/admin \
       -l /tmp \
       -b utlrp_result \
       -n 2 \
       utlrp.sql
    </copy>
    ```

    * `-d` specifies the location of the script to execute
    * `-l` specifies the logging directory
    * `-b` specifies the base name of the log files
    * `-n` specifies the number of parallel executions
    * `utlrp.sql` is the script to execute

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    catcon::set_log_file_base_path: ALL catcon-related output will be written to [/tmp/utlrp_result_catcon_203841.lst]

    catcon::set_log_file_base_path: catcon: See [/tmp/utlrp_result*.log] files for output generated by scripts

    catcon::set_log_file_base_path: catcon: See [/tmp/utlrp_result_*.lst] files for spool files, if any

    catcon.pl: completed successfully
    ```
    </details>

You may now *proceed to the next lab*.

## Learn More

* Documentation, [Multitenant Administrator's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/multi/introduction-to-the-multitenant-architecture.html#GUID-5C3D6692-B935-46CB-BF5B-B10D7640003C)
* Webinar, [Move to Oracle Database 23ai – Everything you need to know about Oracle Multitenant – Part 1](https://youtu.be/k0wCWbp-htU)

## Acknowledgements
* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Alex Zaballa, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, June 2024
