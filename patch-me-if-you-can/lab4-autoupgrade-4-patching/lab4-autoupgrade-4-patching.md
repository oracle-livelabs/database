# Lab 4 - Using AutoUpgrade for Patching
In this lab exercise you will patch the CDB2 database from 19.18.0 to 19.19.0 with just two commands.

A simple config file for AutoUpgrade is provided already for your convenience:
  ```
    <copy>
     cat /home/oracle/scripts/CDB2_patch.cfg
    </copy>
  ```
  

This is the config file:
```
global.autoupg_log_dir=/home/oracle/logs
upg1.source_home=/u01/app/oracle/product/19
upg1.target_home=/u01/app/oracle/product/1919
upg1.sid=CDB2
upg1.log_dir=/home/oracle/logs
upg1.restoration=no
upg1.timezone_upg=yes
[CDB2] root@hol:/u01/app/oracle/product/1919
```
### Step 1: Update AutoUpgrade

Copy a more recent version of AutoUpgrade into your 19.19.0 home:

  ```
    <copy>
     yes | cp /home/oracle/stage/autoupgrade.jar $ORACLE_HOME/rdbms/admin/autoupgrade.jar 
    </copy>
  ```

### Step 2: Check AutoUpgrade Version

Then check the version:

  ```
    <copy>
     java -jar  $ORACLE_HOME/rdbms/admin/autoupgrade.jar -version
    </copy>
  ```


```
build.version 23.1.230224
build.date 2023/02/24 14:53:24 -0500
build.hash a1e2990e
build.hash_date 2023/02/24 14:44:39 -0500
build.supported_target_versions 12.2,18,19,21
build.type production
build.label (HEAD, tag: v23.1, origin/stable_devel, stable_devel)
```

### Step 3: Analyze with AutoUpgrade

Now you will do an analyze run at first. 

  ```
    <copy>
     java -jar  $ORACLE_HOME/rdbms/admin/autoupgrade.jar -config /home/oracle/scripts/CDB2_patch.cfg -mode analyze
    </copy>
  ```

It will complete within within less than half a minute.

<details>
 <summary>*click here to see the full output*</summary>

  ``` text
$ java -jar  $ORACLE_HOME/rdbms/admin/autoupgrade.jar -config /home/oracle/scripts/CDB2_patch.cfg -mode analyze
AutoUpgrade is not fully tested on OpenJDK 64-Bit Server VM, Oracle recommends to use Java HotSpot(TM)
AutoUpgrade 23.1.230224 launched with default internal options
Processing config file ...
+--------------------------------+
| Starting AutoUpgrade execution |
+--------------------------------+
1 CDB(s) plus 1 PDB(s) will be analyzed
Type 'help' to list console commands
upg> Job 100 completed
------------------- Final Summary --------------------
Number of databases            [ 1 ]

Jobs finished                  [1]
Jobs failed                    [0]

Please check the summary report at:
/home/oracle/logs/cfgtoollogs/upgrade/auto/status/status.html
/home/oracle/logs/cfgtoollogs/upgrade/auto/status/status.log
  ```
</details>

### Step 4: AutoUpgrade Log File

Check the logfile for any additional tasks. See the last line:

  ```
    <copy>
     cat /home/oracle/logs/cfgtoollogs/upgrade/auto/status/status.log
    </copy>
  ```

No additional tasks needed. You can progress.

<details>
 <summary>*click here to see the full status log output*</summary>

  ``` text
$ cat /home/oracle/logs/cfgtoollogs/upgrade/auto/status/status.log
==========================================
          Autoupgrade Summary Report
==========================================
[Date]           Tue Jun 27 00:05:41 CEST 2023
[Number of Jobs] 1
==========================================
[Job ID] 100
==========================================
[DB Name]                CDB2
[Version Before Upgrade] 19.18.0.0.0
[Version After Upgrade]  19.19.0.0.0
------------------------------------------
[Stage Name]    PRECHECKS
[Status]        SUCCESS
[Start Time]    2023-06-27 00:05:23
[Duration]       
[Log Directory] /home/oracle/logs/CDB2/100/prechecks
[Detail]        /home/oracle/logs/CDB2/100/prechecks/cdb2_preupgrade.log
                Check passed and no manual intervention needed
------------------------------------------
  ```
</details>

```

```
### Step 5: AutoUpgrade Deploy

You can start AutoUpgrade now in deploy mode.
It will lift the database into the new home and execute all necessary tasks.

  ```
    <copy>
     java -jar  $ORACLE_HOME/rdbms/admin/autoupgrade.jar -config /home/oracle/scripts/CDB2_patch.cfg -mode deploy
    </copy>
  ```

### Step 6: AutoUpgrade Progress
You can monitor it in the job interface easily with a refresh interval:
  ```
    <copy>
     lsj -a 10
    </copy>
  ```

It will do an automatic refresh from now on.

```
upg> lsj -a 10
upg> +----+-------+---------+---------+-------+----------+-------+-------+
|Job#|DB_NAME|    STAGE|OPERATION| STATUS|START_TIME|UPDATED|MESSAGE|
+----+-------+---------+---------+-------+----------+-------+-------+
| 101|   CDB2|PREFIXUPS|EXECUTING|RUNNING|  00:09:52|90s ago|       |
+----+-------+---------+---------+-------+----------+-------+-------+
Total jobs 1

The command lsj is running every 10 seconds. PRESS ENTER TO EXIT
```

You may now *proceed to the next lab*