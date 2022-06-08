
# Explore Automatic Deletion of Flashback Logs

## Introduction

The fast recovery area is critical for databases because it stores backups, online redo logs, archived redo logs, and flashback logs. Because many databases can use the fast recovery area at the same time, the databases are impacted when the fast recovery area becomes full.

When you enable `FLASHBACK` mode on your database instance, Oracle copies images of each altered block in every data file into flashback logs stored in the flash recovery area. Starting in Oracle Database 19c, the management of space in the fast recovery area is simplified. Oracle Database monitors flashback logs in the fast recovery area and automatically deletes those that are beyond the retention period. You can set the retention period by configuring the `DB_FLASHBACK_RETENTION_TARGET` initialization parameter. By default, this parameter is set to 1 day (1440 minutes). The database retains at least 60 minutes of flashback data even if you specify a value less than 60.

When you reduce the retention period, flashback logs that are dated beyond the retention period are deleted immediately. In scenarios where a sudden workload spike causes many flashback logs to be created, the workload is monitored for a few days before flashback logs that are beyond the retention period are deleted. This avoids the overhead of recreating the flashback logs, if another peak workload occurs soon after. The `COMPATIBLE` initialization parameter must be set to 19.0.0 or higher for flashback logs to be automatically deleted.

In this lab, you enable `FLASHBACK` mode on CDB1 and set the flashback retention period to 70 minutes. You monitor the logs coming in for 70 minutes and then decrease the flashback retention period to 60 minutes and observe the changes to the logs. Use the `workshop-installed` compute instance.

Estimated Time: 85 minutes


### Objectives

In this lab, you will:

- Prepare your environment
- Set the flashback retention period to 70 minutes and enable `FLASHBACK` mode on CDB1
- Increase the fast recovery area (FRA) size to 100GB
- Generate flashback logs
- Decrease the flashback retention period to 60 minutes and observe the changes to the flashback logs
- Reset your environment

### Prerequisites

This lab assumes you have:
- Obtained and signed in to your `workshop-installed` compute instance.


## Task 1: Prepare your environment

> **NOTE:** Unless otherwise stated, all passwords will be `Ora4U_1234`. When copying and pasting a command that includes a password, please replace the word `password` with `Ora4U_1234`. This only applies to instances created through OCI Resource Manager with our provided terraform scripts.

To prepare your environment, review important initialization parameters, enable `ARCHIVELOG` mode on CDB1, and open PDB1. It's important that CDB1 and PDB1 are open before you enable `FLASHBACK` mode in Task 2.

1. Open a terminal window on the desktop. Let's call this terminal 1.

2. Set the Oracle environment variables. At the prompt, enter **CDB1**.

    ```
    $ <copy>. oraenv</copy>
    CDB1
    ```

3. Connect to CDB1 as the `SYS` user.

    ```
    $ <copy>sqlplus / as sysdba</copy>
    ```

4. View the current settings for the `db_recovery_file_dest` and `db_recovery_file_dest_size` initialization parameters. The first parameter defines the location of the fast recovery area. The second specifies the disk quota, or maximum space to use for flash recovery area files for the database.

    ```
    SQL> <copy>SHOW PARAMETER db_recovery_file_dest;</copy>

    NAME                                 TYPE	       VALUE
    ------------------------------------ ----------- ------------------------------
    db_recovery_file_dest                string      /u01/app/oracle/recovery_area
    db_recovery_file_dest_size           big integer 50G
    ```

5. Verify that the `COMPATIBLE` initialization parameter value is set to 19.0.0 or higher. The results indicate that the value is 19.0.0.

    ```
    SQL> <copy>SHOW PARAMETER COMPATIBLE;</copy>

    NAME                                 TYPE        VALUE
    ------------------------------------ ----------- -----------------------------
    compatible                           string      19.0.0
    noncdb_compatible                    boolean     FALSE
    ```

6. Find out if `ARCHIVELOG` mode is enabled on CDB1. The query result indicates that it is not enabled.

    ```
    SQL> <copy>SELECT log_mode from v$database;</copy>

    LOG_MODE
    ------------
    NOARCHIVELOG
    ```

7. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT</copy>
    ```

8. Run the `enable_ARCHIVELOG.sh` shell script to enable `ARCHIVELOG` mode on CDB1. At the prompt, enter **CDB1**.

    ```
    $ <copy>$HOME/labs/19cnf/enable_ARCHIVELOG.sh</copy>
    CDB1
    ```

9. Connect to CDB1.

    ```
    $ <copy>sqlplus / as sysdba</copy>
    ```

10. Open PDB1.

    ```
    SQL> <copy>ALTER PLUGGABLE DATABASE PDB1 OPEN;</copy>

    Pluggable database altered.
    ```



## Task 2: Set the flashback retention period to 70 minutes and enable `FLASHBACK` mode on CDB1

When you set the flashback period to 70 minutes, it means that 70 minutes is the upper limit on how far back in time the database may be flashed back.

1. Discover whether `FLASHBACK` mode is enabled. The query result indicates that it is not enabled.

    ```
    SQL> <copy>SELECT flashback_on FROM v$database;</copy>

    FLASHBACK_ON
    ------------------
    NO
    ```



2. View the default flashback retention period set on CDB1. The results indicate that the default is 1440 minutes, which is 1 day.

    ```
    SQL> <copy>SHOW PARAMETER DB_FLASHBACK_RETENTION_TARGET;</copy>

    NAME                             TYPE        VALUE
    -------------------------------- ----------- ------------------
    db_flashback_retention_target    integer     1440
    ```


3. Set the flashback retention period to 70 minutes.

    ```
    SQL> <copy>ALTER SYSTEM SET DB_FLASHBACK_RETENTION_TARGET=70 SCOPE=BOTH;</copy>

    System altered.
    ```

4. Enable `FLASHBACK` mode.

    ```
    SQL> <copy>ALTER DATABASE FLASHBACK ON;</copy>

    Database altered.
    ```

5. Verify that `FLASHBACK` mode is now on by querying the `v$database` view.

    ```
    SQL> <copy>SELECT flashback_on FROM v$database;</copy>

    FLASHBACK_ON
    ------------------
    YES
    ```

6. Verify that the flashback retention period is set to 70 minutes by querying the `db_flashback_retention_target` initialization parameter.

    ```
    SQL> <copy>SHOW PARAMETER db_flashback_retention_target;</copy>

    NAME                             TYPE        VALUE
    -------------------------------- ----------- ------------------
    db_flashback_retention_target    integer     70
    ```


## Task 3: Increase the fast recovery area size (FRA) to 100GB

Increase the fast recovery area size to 100GB to provide enough space for the flashback logs.

1. Set the fast recovery area size to 100GB by configuring the `db_recovery_file_dest_size` initialization parameter.

    ```
    SQL> <copy>ALTER SYSTEM SET db_recovery_file_dest_size=100G;</copy>

    System altered.
    ```

2. Query the `v$recovery_file_dest` view to monitor the space availability in the flash recovery area. Your values may be different than those shown below.

    ```
    SQL> <copy>select
    name,
    to_char(space_limit, '999,999,999,999') as space_limit,
    to_char(space_limit - space_used + space_reclaimable,
   '999,999,999,999') as space_available,
    round((space_used - space_reclaimable)/space_limit * 100, 1) as pct_full
    from
    v$recovery_file_dest;</copy>

    NAME                           SPACE_LIMIT      SPACE_AVAILABLE  PCT_FULL
    -----------------------------  ---------------- ---------------- ----------
    /u01/app/oracle/recovery_area  107,374,182,400  103,730,937,856  36.6
    ```

3. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT</copy>
    ```

4. Change to the `flashback` directory.

    ```
    $ <copy>cd /u01/app/oracle/recovery_area/CDB1/flashback</copy>
    ```

5. List the files in the `flashback` directory.

    ```
    $ <copy>ls -ltr</copy>

    total 409616
    -rw-r-----. 1 oracle oinstall 209723392 Jul 23 19:24 o1_mf_jhp5v3ps_.flb
    -rw-r-----. 1 oracle oinstall 209723392 Jul 23 19:24 o1_mf_jhp5v1jz_.flb
    ```


## Task 4: Generate flashback logs

Activity must happen on the database for the database to generate flashback logs. To generate activity, you can run the `workload.sh` script in another terminal window. This script runs for about 70 minutes. You will see many SQL commands in the output.

1. Double-click the **Terminal** icon on the desktop to open another terminal window. Let's call this terminal 2.

2. In terminal 2, run the `workload.sh` shell script to generate some flashback logs. Keep the terminal window open and continue to the next step.

    ```
    $ <copy>$HOME/labs/19cnf/workload.sh</copy>
    ```

3. Wait 70 minutes. Every now and again, in terminal 1, refresh the list of files in the `flashback` directory to view the accumulating log files. In this example, the first log is at 19:31 and the last log is at 20:39, which is within 70 minutes.

    ```
    $ <copy>ls -ltr</copy>

    total 16986532
    -rw-r-----. 1 oracle oinstall 209723392 Jul 23 19:31 o1_mf_jhp5v1jz_.flb
    -rw-r-----. 1 oracle oinstall 209723392 Jul 23 19:54 o1_mf_jhp5v3ps_.flb
    -rw-r-----. 1 oracle oinstall 209723392 Jul 23 19:54 o1_mf_jhp68vtw_.flb
    -rw-r-----. 1 oracle oinstall 209723392 Jul 23 19:54 o1_mf_jhp7mm15_.flb
    -rw-r-----. 1 oracle oinstall 209723392 Jul 23 19:54 o1_mf_jhp7mq40_.flb
    -rw-r-----. 1 oracle oinstall 209723392 Jul 23 19:54 o1_mf_jhp7myc0_.flb
    -rw-r-----. 1 oracle oinstall 209723392 Jul 23 19:55 o1_mf_jhp7n2b1_.flb
    -rw-r-----. 1 oracle oinstall 209723392 Jul 23 19:55 o1_mf_jhp7nh9z_.flb
    -rw-r-----. 1 oracle oinstall 209723392 Jul 23 19:55 o1_mf_jhp7nzos_.flb
    -rw-r-----. 1 oracle oinstall 224043008 Jul 23 19:55 o1_mf_jhp7odok_.flb
    -rw-r-----. 1 oracle oinstall 251871232 Jul 23 19:56 o1_mf_jhp7osq8_.flb
    -rw-r-----. 1 oracle oinstall 288407552 Jul 23 19:56 o1_mf_jhp7phyl_.flb
    -rw-r-----. 1 oracle oinstall 313163776 Jul 23 19:57 o1_mf_jhp7q138_.flb
    -rw-r-----. 1 oracle oinstall 354869248 Jul 23 19:58 o1_mf_jhp7qqmr_.flb
    -rw-r-----. 1 oracle oinstall 373309440 Jul 23 19:59 o1_mf_jhp7rgf0_.flb
    -rw-r-----. 1 oracle oinstall 406568960 Jul 23 20:00 o1_mf_jhp7t999_.flb
    -rw-r-----. 1 oracle oinstall 435585024 Jul 23 20:01 o1_mf_jhp7wk19_.flb
    -rw-r-----. 1 oracle oinstall 468090880 Jul 23 20:10 o1_mf_jhp7zc6r_.flb
    -rw-r-----. 1 oracle oinstall 496328704 Jul 23 20:12 o1_mf_jhp81rjj_.flb
    -rw-r-----. 1 oracle oinstall 449732608 Jul 23 20:14 o1_mf_jhp8kc2r_.flb
    -rw-r-----. 1 oracle oinstall 476061696 Jul 23 20:15 o1_mf_jhp8npc0_.flb
    -rw-r-----. 1 oracle oinstall 493371392 Jul 23 20:17 o1_mf_jhp8rby1_.flb
    -rw-r-----. 1 oracle oinstall 514662400 Jul 23 20:19 o1_mf_jhp8vsh8_.flb
    -rw-r-----. 1 oracle oinstall 536797184 Jul 23 20:21 o1_mf_jhp8yxr8_.flb
    -rw-r-----. 1 oracle oinstall 561537024 Jul 23 20:22 o1_mf_jhp920gk_.flb
    -rw-r-----. 1 oracle oinstall 575512576 Jul 23 20:24 o1_mf_jhp9600k_.flb
    -rw-r-----. 1 oracle oinstall 599228416 Jul 23 20:24 o1_mf_jhp992oz_.flb
    -rw-r-----. 1 oracle oinstall 633700352 Jul 23 20:25 o1_mf_jhp9cx0c_.flb
    -rw-r-----. 1 oracle oinstall 662503424 Jul 23 20:26 o1_mf_jhp9dbmz_.flb
    -rw-r-----. 1 oracle oinstall 698908672 Jul 23 20:27 o1_mf_jhp9fgs1_.flb
    -rw-r-----. 1 oracle oinstall 737828864 Jul 23 20:28 o1_mf_jhp9h9op_.flb
    -rw-r-----. 1 oracle oinstall 775241728 Jul 23 20:30 o1_mf_jhp9jrnp_.flb
    -rw-r-----. 1 oracle oinstall 796229632 Jul 23 20:33 o1_mf_jhp9mrth_.flb
    -rw-r-----. 1 oracle oinstall 819183616 Jul 23 20:35 o1_mf_jhp9qsq8_.flb
    -rw-r-----. 1 oracle oinstall 841007104 Jul 23 20:38 o1_mf_jhp9w45h_.flb
    -rw-r-----. 1 oracle oinstall 870170624 Jul 23 20:38 o1_mf_jhpb6fd7_.flb
    -rw-r-----. 1 oracle oinstall 852779008 Jul 23 20:39 o1_mf_jhpb1c6w_.flb
    ...
    ```


## Task 5: Decrease the flashback retention period to 60 minutes and observe the changes to the flashback logs

From this point on, you can work in terminal 1. Keep terminal 2 open to continue running the `workload.sh` script.

1. In terminal 1, connect to CDB1 as the `SYS` user.

    ```
    $ <copy>sqlplus / as sysdba</copy>
    ```

2. Set the `DB_FLASHBACK_RETENTION_TARGET` initialization parameter equal to 60 minutes.

    ```
    SQL> <copy>ALTER SYSTEM SET DB_FLASHBACK_RETENTION_TARGET=60;</copy>

    System altered.
    ```

3. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT</copy>
    ```


4. List the flashback logs again. Notice that logs generated over 60 minutes ago have automatically been deleted. In this example, the first log is at 19:54 and the last log is at 20:46, which is within 60 minutes. The logs dated beyond the 60 minute mark are automatically deleted.

    ```
    $ <copy>ls -ltr /u01/app/oracle/recovery_area/CDB1/flashback</copy>

    total 18511296
    -rw-r-----. 1 oracle oinstall 209723392 Jul 23 19:54 o1_mf_jhp5v3ps_.flb
    -rw-r-----. 1 oracle oinstall 209723392 Jul 23 19:54 o1_mf_jhp68vtw_.flb
    -rw-r-----. 1 oracle oinstall 209723392 Jul 23 19:54 o1_mf_jhp7mm15_.flb
    -rw-r-----. 1 oracle oinstall 209723392 Jul 23 19:54 o1_mf_jhp7mq40_.flb
    -rw-r-----. 1 oracle oinstall 209723392 Jul 23 19:54 o1_mf_jhp7myc0_.flb
    -rw-r-----. 1 oracle oinstall 209723392 Jul 23 19:55 o1_mf_jhp7n2b1_.flb
    -rw-r-----. 1 oracle oinstall 209723392 Jul 23 19:55 o1_mf_jhp7nh9z_.flb
    -rw-r-----. 1 oracle oinstall 209723392 Jul 23 19:55 o1_mf_jhp7nzos_.flb
    -rw-r-----. 1 oracle oinstall 224043008 Jul 23 19:55 o1_mf_jhp7odok_.flb
    -rw-r-----. 1 oracle oinstall 251871232 Jul 23 19:56 o1_mf_jhp7osq8_.flb
    -rw-r-----. 1 oracle oinstall 288407552 Jul 23 19:56 o1_mf_jhp7phyl_.flb
    -rw-r-----. 1 oracle oinstall 313163776 Jul 23 19:57 o1_mf_jhp7q138_.flb
    -rw-r-----. 1 oracle oinstall 354869248 Jul 23 19:58 o1_mf_jhp7qqmr_.flb
    -rw-r-----. 1 oracle oinstall 373309440 Jul 23 19:59 o1_mf_jhp7rgf0_.flb
    -rw-r-----. 1 oracle oinstall 406568960 Jul 23 20:00 o1_mf_jhp7t999_.flb
    -rw-r-----. 1 oracle oinstall 435585024 Jul 23 20:01 o1_mf_jhp7wk19_.flb
    -rw-r-----. 1 oracle oinstall 468090880 Jul 23 20:10 o1_mf_jhp7zc6r_.flb
    -rw-r-----. 1 oracle oinstall 496328704 Jul 23 20:12 o1_mf_jhp81rjj_.flb
    -rw-r-----. 1 oracle oinstall 449732608 Jul 23 20:14 o1_mf_jhp8kc2r_.flb
    -rw-r-----. 1 oracle oinstall 476061696 Jul 23 20:15 o1_mf_jhp8npc0_.flb
    -rw-r-----. 1 oracle oinstall 493371392 Jul 23 20:17 o1_mf_jhp8rby1_.flb
    -rw-r-----. 1 oracle oinstall 514662400 Jul 23 20:19 o1_mf_jhp8vsh8_.flb
    -rw-r-----. 1 oracle oinstall 536797184 Jul 23 20:21 o1_mf_jhp8yxr8_.flb
    -rw-r-----. 1 oracle oinstall 561537024 Jul 23 20:22 o1_mf_jhp920gk_.flb
    -rw-r-----. 1 oracle oinstall 575512576 Jul 23 20:24 o1_mf_jhp9600k_.flb
    -rw-r-----. 1 oracle oinstall 599228416 Jul 23 20:24 o1_mf_jhp992oz_.flb
    -rw-r-----. 1 oracle oinstall 633700352 Jul 23 20:25 o1_mf_jhp9cx0c_.flb
    -rw-r-----. 1 oracle oinstall 662503424 Jul 23 20:26 o1_mf_jhp9dbmz_.flb
    -rw-r-----. 1 oracle oinstall 698908672 Jul 23 20:27 o1_mf_jhp9fgs1_.flb
    -rw-r-----. 1 oracle oinstall 737828864 Jul 23 20:28 o1_mf_jhp9h9op_.flb
    -rw-r-----. 1 oracle oinstall 775241728 Jul 23 20:30 o1_mf_jhp9jrnp_.flb
    -rw-r-----. 1 oracle oinstall 796229632 Jul 23 20:33 o1_mf_jhp9mrth_.flb
    -rw-r-----. 1 oracle oinstall 819183616 Jul 23 20:35 o1_mf_jhp9qsq8_.flb
    -rw-r-----. 1 oracle oinstall 841007104 Jul 23 20:38 o1_mf_jhp9w45h_.flb
    -rw-r-----. 1 oracle oinstall 852779008 Jul 23 20:41 o1_mf_jhpb1c6w_.flb
    -rw-r-----. 1 oracle oinstall 870170624 Jul 23 20:44 o1_mf_jhpb6fd7_.flb
    -rw-r-----. 1 oracle oinstall 890109952 Jul 23 20:44 o1_mf_jhpbl1v7_.flb
    -rw-r-----. 1 oracle oinstall 880967680 Jul 23 20:46 o1_mf_jhp5v1jz_.flb
    ```



## Task 6: Reset your environment

If you are done with the lab, but the `workshop.sh` script is still running, do steps 1 and 2 to stop the shell script.

1. In terminal 1, obtain the process id for the `workload.sh` script. In the example below, 12129 is the process ID number for the script. Your number is most likely different.

    ```
    $ <copy>pgrep -lf workload</copy>

    12129 workload.sh
    ```

2. Stop the process. In the command below, replace `<pid>` with your process ID number. In terminal 2, you should see "Killed" as the output.

    ```
    $ <copy>kill -9 <pid></copy>
    ```

3. Connect to CDB1 as the `SYS` user.

    ```
    $ <copy>sqlplus / as sysdba</copy>
    ```

4. Disable flashback mode.

    ```
    SQL> <copy>ALTER DATABASE FLASHBACK OFF;</copy>

    Database altered.
    ```

5. Exit SQL*Plus.

    ```
    SQL> <copy>EXIT</copy>
    ```

6. Disable `ARCHIVELOG` mode on CDB1 by running the `disable_ARCHIVELOG.sh` shell script. At the prompt, enter **CDB1**.

    ```
    $ <copy>$HOME/labs/19cnf/disable_ARCHIVELOG.sh</copy>
    CDB1
    ```

7. Rebuild PDB1 with sample data by running the `recreate_PDB1_in_CDB1.sh` shell script.

    ```
    $ <copy>$HOME/labs/19cnf/recreate_PDB1_in_CDB1.sh</copy>
    ```

8. Run the following command in both terminal windows to close them.

    ```
    $ <copy>exit</copy>
    ```

## Learn More

- [Using Flashback Database (Oracle Database 19c)](https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/using-flasback-database-restore-points.html#GUID-4E96DB60-3616-4680-866A-F38A6049053A)
- [`DB_FLASHBACK_RETENTION_TARGET` (Database Reference)](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DB_FLASHBACK_RETENTION_TARGET.html#GUID-33F44036-F1BB-4CBF-8AF3-486415E58F2B)
- [Clear Flashback Logs Periodically for Increased Fast Recovery Area Size Predictability](https://docs.oracle.com/en/database/oracle/oracle-database/19/newft/new-features.html#GUID-4DE9FA4A-BA27-434A-A68E-0B58D8FD686B)
- [Performing Flashback and Database Point-in-Time Recovery](https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/rman-performing-flashback-dbpitr.html#GUID-5463669A-DC89-4FF4-ACCE-136A72DF687B)


## Acknowledgements

- **Author** - Dominique Jeunot, Consulting User Assistance Developer
- **Contributor** - Jody Glover, Principal User Assistance Developer
- **Last Updated By/Date** - Matthew McDaniel, Austin Specialists Hub, September 21 2021
