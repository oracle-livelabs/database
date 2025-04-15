# Prepare M5 Script

## Introduction

In this lab, you take a first look at the M5 script. The script is available for download from My Oracle Support. It combines existing functionality in Oracle Database to deliver the best migration experience.

Estimated Time: 5 Minutes

[Next-Level Platform Migration with Cross-Platform Transportable Tablespaces - lab 4](youtube:fgyDy-QcV_o?start=766)

![Configure M5 script](./images/prepare-m5-overview.png " ")

### Objectives

In this lab, you will:

* Extract M5 script
* Configure M5 script

## Task 1: Extract and configure M5 script

In this lab, the source and target database are on the same host. Both hosts access the same directory with the M5 script via a shared NFS drive.

1. Use the *yellow* terminal 🟨. Go to *M5* directory and get the M5 migration script. The directory acts as your script base. You have created the directory already in a previous exercise when you created the database directory. Instead of downloading from My Oracle Support, you copy the script to the script base.

    ```
    <copy>
    cd /home/oracle/m5
    cp /home/oracle/scripts/DBMIG.zip .
    </copy>
    
    --Be sure to hit RETURN
    ```

2. Extract the zip file, set permissions, and examine the contents.

    ```
    <copy>
    unzip DBMIG.zip
    chmod 755 * 
    ll
    </copy>
    
    --Be sure to hit RETURN
    ```

    * *cmd* contains configuration files and generated scripts.
    * *log* contains log and trace files. 
    * *dbmig\_driver\_m5.sh* is the migration driver script.
    * *impdp.sh* is a driver script for the final part, the Data Pump transportable import.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ unzip DBMIG.zip
    Archive:  DBMIG.zip
      inflating: cmd/dbmig_driver.properties
      inflating: dbmig_driver_m5.sh
      inflating: impdp.sh
     extracting: log/rman_mig_bkp.log
    
    $ chmod 755 *
    
    $ ll
    total 56
    drwxr-xr-x. 2 oracle oinstall    37 Jun 21 07:55 cmd
    -rw-r--r--. 1 oracle oinstall 35267 Apr 26 10:40 dbmig_driver_m5.sh
    -rw-r--r--. 1 oracle oinstall  9263 Jun 21 07:55 DBMIG.zip
    -rw-rw-r--. 1 oracle oinstall  4394 Apr 16 17:54 impdp.sh
    drwxr-xr-x. 2 oracle oinstall    30 Jun 21 07:55 log
    drwxr-xr-x. 2 oracle oinstall     6 Jun 20 12:28 m5dir
    $
    ```
    </details>

3. Examine the properties file, which contains the details of your migration. It's stored in the *cmd* directory. In this lab, the properties file has already been filled with the details of your database.

    ```
    <copy>
    cd cmd
    more dbmig_driver.properties
    </copy>

    -- Be sure to hit RETURN
    ```

    * Scroll between the pages with *SPACE*. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cd cmd
    $ more dbmig_driver.properties

    ############################################################
    #Source database properties
    #my_M5_prop_version=2
    # -
    # - ORACLE_HOME     Path to Oracle Home
    # - ORACLE_SID      SID of the source database
    # - SRC_SCAN        Connect string to source database via SCAN.
    #                   If no SCAN, specify source database network name.
    #                   Enclose in single quotes
    #                      Example: '@myhost-scan/db1'
    #                      Example: '@localhost/pdb1'
    # - MIG_PDB         Accepted values: 0, 1
    #                      Choose 0 if source is non-CDB
    #                      Choose 1 if source is a PDB
    # - PDB_NAME        If source is a PDB, specify PDB name.
    #                   Else leave blank
    #                      Example: PDB1
    # - BKP_FROM_STDBY  Accepted values: 0, 1
    #                      Choose 0 to back up from primary database,
    #                      or if Data Guard is not in use.
    #                      Choose 1 to back up from standby database.
    ############################################################
    export ORACLE_HOME=/u01/app/oracle/product/19
    export PATH=$PATH:$ORACLE_HOME/bin
    export ORACLE_SID=FTEX
    export SRC_SCAN='@localhost/ftex'
    export MIG_PDB=0
    export PDB_NAME=
    export BKP_FROM_STDBY=0
    ############################################################
    #Source Data Pump settings
    # - SOURCE_DPDMP    Directory path of the directory DATA_PUMP_DIR
    #                      Example: /u01/app/oracle/m5/data_pump_dir
    # - SOURCE_DPIR     Data Pump Directory, typically DATA_PUMP_DIR
    # - SYSTEM_USR      Username for Data Pump export.
    #                   Do not use SYS AS SYSDBA
    #                      Example: SYSTEM
    # - DP_TRACE        Data Pump trace level.
    #                   Use 0 to disable trace.
    #                   Use 3FF0300 to full transportable tracing
    #                   See MOS Doc ID 286496.1 for details.
    # - DP_PARALLEL     Data Pump parallel setting.
    #                   Accepted values: 1 to 999
    #                      Example: 16
    ############################################################
    export SOURCE_DPDMP=/home/oracle/m5/m5dir
    export SOURCE_DPDIR=M5DIR
    export SYSTEM_USR=FTEXUSER
    export DP_TRACE=0
    export DP_PARALLEL=1
    export DP_ENC_PROMPT=N
    ############################################################
    #Source RMAN settings
    # - BKP_DEST_TYPE   Accepted values: DISK, SBT_TAPE
    #                      Choose DISK to backup up to local storage
    #                      Choose SBT_TAPE to use ZDLRA
    # - BKP_DEST_PARM   If BKP_DEST_TYPE=DISK, enter location for backup:
    #                      Example: /u01/app/oracle/m5/rman
    #                   If BKP_DEST_TYPE=SBT_TAPE, enter channel configuration:
    #                      Example: "'%d_%U' PARMS \"SBT_LIBRARY=<oracle_home>/lib/libra.so,SBT_PARMS=(RA_WALLET='location=file:<oracle_home>/dbs/zdlra credential_alias=<zdlra-connect-string>')\""
    # - CAT_CRED        If you use RMAN catalog or ZDLRA, specify connect string to catalog database
    #                      Example: <scan-name>:<port>/<service>
    # - SECTION_SIZE    Section size used in RMAN backups
    # - CHN             Number of RMAN channels allocated
    ############################################################
    export BKP_DEST_TYPE=DISK
    export BKP_DEST_PARM=/home/oracle/m5/rman
    export CAT_CRED=
    export SECTION_SIZE=64G
    export CHN=4
    ############################################################
    #Destination host settings
    #If specified, the script transfers the RMAN backups and
    #Data Pump dump file to the destination via over SSH.
    #SSH equivalence is required.
    # - DEST_SERVER     Network name of the destination server.
    #                   Leave blank if you manually transfer
    #                   backups and dump files
    # - DEST_USER       User for SSH connection
    #                      Example: oracle
    # - DEST_WORKDIR    The script working directory on destination
    #                      Example: /u01/app/oracle/m5
    # - DEST_DPDMP      The directory path used by DATA_PUMP_DIR
    #                   in destination database
    #                      Example: /u01/app/oracle/m5/data_pump_dir
    ############################################################
    export DEST_SERVER=
    export DEST_USER=
    export DEST_WORKDIR=
    export DEST_DPDMP=
    
    ############################################################
    #Advanced settings
    #Normally, you don't need to edit this section
    ############################################################
    export WORKDIR=$PWD
    export LOG_DIR=${WORKDIR}/log
    export CMD_DIR=${WORKDIR}/cmd
    export PATH=$PATH:$ORACLE_HOME/bin
    export DT=`date +%y%m%d%H%M%S`
    export CMD_MKDIR=`which mkdir`
    export CMD_TOUCH=`which touch`
    export CMD_CAT=`which cat`
    export CMD_RM=`which rm`
    export CMD_AWK=`which awk`
    export CMD_SCP=`which scp`
    export CMD_CUT=`which cut`
    export CMD_PLATFORM=`uname`
    if [[ "$CMD_PLATFORM" = "Linux" ]]; then
        export CMD_GREP="/usr/bin/grep"
    else
        if [[ "$CMD_PLATFORM" = "AIX" ]]; then
          export CMD_GREP="/usr/bin/grep"
        else
          if [[ "$CMD_PLATFORM" = "HPUX" ]]; then
            export CMD_GREP="/usr/bin/grep"
          else
            export CMD_GREP=`which ggrep`
          fi
        fi
    fi
    export my_M5_prop_version=2
    $
    ```
    </details>

4. Set the environment to the source database and connect. 

    ```
    <copy>
    . ftex
    sqlplus / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

5. Generate a list of tablespaces to migrate. The M5 script uses full transportable export/import, so you must migrate all tablespaces. 

    ```
    <copy>
    select
       tablespace_name
    from
       dba_tablespaces
    where
       contents='PERMANENT'
       and tablespace_name not in ('SYSTEM','SYSAUX');
    </copy>
    ```

    * Full transportable export/import moves all tablespaces except for the system tablespaces.
    * UNDO and TEMP tablespaces are never migrated. New UNDO and TEMP tablespaces are created in the target database.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> select
       tablespace_name
    from
       dba_tablespaces
    where
       contents='PERMANENT'
       and tablespace_name not in ('SYSTEM','SYSAUX');
       
    TABLESPACE_NAME
    ------------------------------
    USERS
    ```
    </details>

6. Exit SQL*Plus. 

    ```
    <copy>
    exit
    </copy>
    ```

7. Create a comma-separated list of tablespaces and save it in a file. The M5 script uses the list.

    ```
    <copy>
    echo "USERS" > /home/oracle/m5/cmd/dbmig_ts_list.txt
    </copy>
    ```

You may now *proceed to the next lab*.

## Further reading 

* My Oracle Support, [M5 Cross Endian Platform Migration using Full Transportable Data Pump Export/Import and RMAN Incremental Backups (Doc ID 2999157.1)](https://support.oracle.com/epmos/faces/DocumentDisplay?id=2999157.1)

* Oracle recommends using a shared NFS drive to share the M5 script and corresponding files, logs, and backups between the source and target hosts. If a shared NFS drive is not possible, you must copy the directory from source to target after each backup.

## Acknowledgments

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Mike Dietrich, Klaus Gronau, Alex Zaballa
* **Last Updated By/Date** - Daniel Overby Hansen, August 2024
