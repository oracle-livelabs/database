# Final Backup and Restore

## Introduction

It's time to complete the migration. You've done all the preparations, but now it's time for an outage while you migrate the database. When the maintenance window begins you perform a final backup and restore use Data Pump to do a full transportable export/import.

Estimated Time: 20 Minutes.

### Objectives

In this lab, you will:

* Perform final backup and restore
* Data Pump export and import

## Task 1: Final backup / restore

The outage starts now. In a real migration, you would shut down the applications using the database. Although, there is an outage, you can still query the source database. The tablespaces are read-only, so you can't add or change data, but you can query it. 

1. Start the final backup. When you start the driver script with `L1F`, it performs not only the final backup, but it also sets the tablespaces in *read-only* mode and starts a Data Pump full transportable export. 

    ```
    <copy>
    . ftex
    cd /home/oracle/m5
    ./dbmig_driver_m5.sh L1F
    </copy>

    -- Be sure to hit RETURN
    ```

    * You start the driver script with the argument *L1F*.
    * When prompted for *system password, enter *ftexuser*. The password of the user you created earlier in the lab. 
    * Before starting the backup, the script sets the tablespaces read-only. 
    * After the backup, the script starts Data Pump to perform a full transportable export. 
    * Notice how Data Pump lists at names of the data files needed for the migration in the end of the output. 
    * In addition, it lists the names of the Data Pump dump files. 

2. Restore the backup.

    ```
    <copy>
    cd cmd
    export L1FSCRIPT=$(ls -tr restore_L1F* | tail -1) 
    cd /home/oracle/m5
    . cdb23
    rman target "sys/oracle@'localhost/violet'" cmdfile=/home/oracle/m5/cmd/$L1FSCRIPT
    </copy>

    -- Be sure to hit RETURN
    ```

    * Restoring the final backup is just like the other restore operations. 
    * The only difference is that the tablespaces are set read-only so the SCN of the data files matches the SCN at which you run the Data Pump transportable export.

## Task 2: Data Pump import

1. Examine the import driver script. For the Data Pump transportable import you use the import driver script `impdp.sh`. It's located in the script base folder. Normally, you need to fill in information about your target database, but in this lab it is done for you.

    ```
    <copy>
    head -22 impdp.sh
    </copy>
    ```

    * You find information about the target database as environment variables. 
    * Also, there are certain variables controlling the use of Data Pump.
    * Since you are importing into Oracle Database 23ai, you can utilize parallel import. This significantly speeds up the import. 
    
2. Start the import driver script.

    ```
    <copy>
    ./impdp.sh
    </copy>
    ```

    * You need to add additional information on the command line.
    * `expdp_dumpfile` is the name of the dump file created by the full transportable export.
    * `rman_last_restore_log` is the relative path to the log file from the final restore.
    * The third parameter controls the *run mode*. 
        * *test* just generates the Data Pump parameter file for the import.
        * *run* generates the parameter file and starts the import.
        * Adding *readonly* triggers the use of the Data Pump parameter `TRANSPORTABLE=KEEP_READ_ONLY` which is useful for testing.
    * `encryption_pwd_prompt` - set to *N* because *FTEX* is not encrypted.

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ ./impdp.sh
    Please call this script using the syntax ./impdp.sh
    Example: # sh impdp.sh <expdp_dumpfile> <rman_last_restore_log> [run|test|run-readonly|test-readonly] <encryption_pwd_prompt[Y|N]>
    ```
    </details>

3. Collect the information for the import driver script.

    ```
    <copy>
    cd m5dir
    export DMPFILE=$(ls -tr exp_FTEX*dmp | tail -1)
    cd ../log
    export L1FLOGFILE=$(ls -tr restore_L1F*log | tail -1)
    cd ..
    echo $DMPFILE
    echo $L1FLOGFILE
    </copy>

    -- Be sure to hit RETURN
    ```

4. Start the import driver script in *test* mode. 

    ```
    <copy>
    . cdb23
    ./impdp.sh $DMPFILE log/$L1FLOGFILE test N
    </copy>

    -- Be sure to hit RETURN
    ```

    * This step simply generates the Data Pump import parameter file. 

5. Examine the Data Pump parameter file.

    ```
    <copy>
    cat $(ls -tr imp_CDB23*xtts.par | tail -1)
    </copy>
    ```

    * If you need to make any changes to the Data Pump parameter file, you must edit the import driver script, *impdp.sh*, and make the changes there. 

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ cat $(ls -tr imp_CDB23*xtts.par | tail -1)
    userid='system@localhost/violet'
    dumpfile=exp_FTEX_240621100752.dmp
    directory=M5DIR
    LOGTIME=ALL
    TRACE=0
    PARALLEL=4
    LOGFILE=imp_CDB23_240621101933_xtts.log
    METRICS=YES
    ENCRYPTION_PWD_PROMPT=NO
    TRANSPORT_DATAFILES=
    '/u01/app/oracle/oradata/CDB23/1677972AFD1B4805E065000000000001/datafile/o1_mf_users_m7bhc8p0_.dbf'        ```
    </details>

6. Since you verified the contents of the Data Pump parameter file, you can now start the real export. Re-use the `impdp.sh` command line but switch to *run* mode. 

    ```
    <copy>
    ./impdp.sh $DMPFILE log/$L1FLOGFILE run N
    </copy>
    ```

    * The import runs for a few minutes. 

7. Examine the Data Pump log file for any critical issues. A FTEX import usually produces a few errors or warnings, especially when going to a higher release and into a different architecture.

    * The roles `EM_EXPRESS_ALL`, `EM_EXPRESS_BASIC` and `DATAPATCH_ROLE` do not exist in Oracle Database 23ai causing the grants to fail.
    * The same applies to the `ORACLE_OCM` user.
    * An error related to traditional auditing that is desupported in Oracle Database 23ai.
    * This log file doesn't contain any critical issues.

You may now *proceed to the next lab*.

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, July 2024
