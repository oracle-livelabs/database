# Test Migration

## Introduction

In this lab, you will test the migration. A major advantage of the M5 script is that you can do a test migration. Using the restored data files on the target system, you can perform a test migration. After that, you can flashback the data files and resume the backup/restore cycle. 

In other words, you are using the production system and the production data for a test. This is extremely useful. 

This is an optional lab. You can skip it and move directly to lab 8. 

Estimated Time: 15 Minutes.

### Objectives

In this optional lab, you will:

* Test the last part of the migration
* Flashback database
* Resume the backup/restore cycle

## Task 1: Perform test migration

This part does require a short outage of the source database. You will test the migration by performing the final steps of the migration. However, at the end you flash back the target database and resume the backup/restore cycle.

1. Outage starts on the source database.

2. Set the environment to the source database and start the test backup. When you start the driver script with `L1F`, it performs not only the test backup, but it also sets the tablespaces in *read-only* mode and starts a Data Pump full transportable export. 

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

3. Connect to the source database.

    ```
    <copy>
    sqlplus / as sysdba
    </copy>
    ```

4. Stop the outage by setting the tablespaces back to read-write mode.

    ```
    <copy>
    alter tablespace users read write;
    </copy>
    ```

5. Exit SQL*Plus. 
    
    ```
    <copy>
    exit
    </copy>
    ```

6. Restore the test backup.

    ```
    <copy>
    cd cmd
    export L1FSCRIPT=$(ls -tr restore_L1F* | tail -1) 
    . cdb23
    cd /home/oracle/m5
    rman target "sys/oracle@'localhost/violet'" cmdfile=/home/oracle/m5/cmd/$L1FSCRIPT    
    </copy>

    -- Be sure to hit RETURN
    ```

7. Perform the Data Pump transportable import. In the next lab, the instructions will describe in detail what happens. However, for now just start the import directly.

    ```
    <copy>
    cd /home/oracle/m5/log
    export L1FLOGFILE=$(ls -tr restore_L1F*log | tail -1)
    cd /home/oracle/m5/m5dir
    export DMPFILE=$(ls -tr exp_FTEX*dmp | tail -1)
    cd ..
    . cdb23
    ./impdp.sh $DMPFILE log/$L1FLOGFILE run-readonly N
    </copy>

    -- Be sure to hit RETURN
    ```

    * The import runs for a few minutes. 





    
    
    
    
    
    
    
    
    
    
    
    
    You may now *proceed to the next lab*.


If you have a standby database, you can perform the test backup there and avoid outage on the primary database.

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, July 2024
