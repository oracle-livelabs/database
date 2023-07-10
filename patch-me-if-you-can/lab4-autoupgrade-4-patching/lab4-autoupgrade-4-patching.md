# Lab 4: Using AutoUpgrade for Patching

## Introduction 
In this lab exercise you will patch the CDB2 database from 19.18.0 to 19.19.0 with just two commands.

![Process flow lab 4](./images/lab4-process-flow.png " ")

Estimated Time: 5 minutes (runs unattended for 20 minutes)

### Objectives

Autoupgrade for patching

### Prerequisites

This lab assumes you have:

- Connected to the lab
- Activate the tab __19.19.0 Home__
![switch to 1919 tab](./images/19-19-home.png " ")



## Task 1: Update AutoUpgrade

Copy a more recent version of AutoUpgrade into your 19.19.0 home:

  ```
    <copy>
     cp -f /home/oracle/stage/autoupgrade.jar $ORACLE_HOME/rdbms/admin/autoupgrade.jar 
    </copy>
  ```
![copy newer version of autoupgrade.jar](./images/cpy-new-autoupgrade-jar.png " ")

## Task 2: Check AutoUpgrade Version

Then check the version:

  ```
    <copy>
     java -jar  $ORACLE_HOME/rdbms/admin/autoupgrade.jar -version
    </copy>
  ```
![autoupgrade version](./images/autoupgrade-version.png " ")


## Tak 3: Preconfigured AutoUpgrade Config File

A simple config file for AutoUpgrade is provided already for your convenience:
  ```
    <copy>
     cat /home/oracle/scripts/CDB2_patch.cfg
    </copy>
  ```
![autoupgrade config file](./images/1919-autoupgrade-cfg.png " ")

## Task 4: Analyze with AutoUpgrade

Now you will do an analysis run first. 

  ```
    <copy>
     java -jar  $ORACLE_HOME/rdbms/admin/autoupgrade.jar -config /home/oracle/scripts/CDB2_patch.cfg -mode analyze
    </copy>
  ```



Don't get confused when it displays something like
![confusion](./images/confusion-screen.png " ")

Autoupgrade is not awaiting any input from you. Just lean back - it will complete within less than half a minute.


<details>
 <summary>*click here to see the full output*</summary>

 ![autoupgrade analyze output](./images/autoupgrade-analyze.png " ")
</details>

## Task 5: AutoUpgrade Log File

Check the logfile for any additional tasks. See the last line:

  ```
    <copy>
     cat /home/oracle/logs/cfgtoollogs/upgrade/auto/status/status.log
    </copy>
  ```



<details>

 <summary>*click here to see the full status log output*</summary>

![confusion](./images/autoupgrade-status-log.png " ")
</details>

No additional tasks are needed. You can progress.


## Task 6: AutoUpgrade Deploy

You can start AutoUpgrade now in deploy mode.
It will lift the database into the new 19.19 home and execute all necessary tasks.

  ```
    <copy>
     java -jar  $ORACLE_HOME/rdbms/admin/autoupgrade.jar -config /home/oracle/scripts/CDB2_patch.cfg -mode deploy
    </copy>
  ```
![autoupgrade deploy](./images/autoupgrade-deploy.png " ")

Again you see the autoupgrade command prompt
![autoupgrade deploy](./images/autoupgrade-command-prompt.png " ")

and this time you can use it to monitor  the autoupgrade progress.

## Task 7: AutoUpgrade Progress
You can monitor it in the job interface easily with a refresh interval:
  ```
    <copy>
     lsj -a 10
    </copy>
  ```

It will do an automatic refresh from now on.


![autoupgrade refresh](./images/autoupgrade-status-refresh.png " ")

__As this job will run for about 30 minutes, you may now *proceed to the next lab*__.

Once the job is finished you'll see an output similar to:
![autoupgrade refresh](./images/autoupgrade-status-finish.png " ")



## Acknowledgments
* **Author** - Mike Dietrich 
* **Contributors** Klaus Gronau, Daniel Overby Hansen  
* **Last Updated By/Date** - Klaus Gronau, June 2023