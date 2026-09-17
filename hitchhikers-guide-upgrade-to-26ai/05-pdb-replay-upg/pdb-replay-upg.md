# Upgrade PDB Using Replay Upgrade

## Introduction

In this lab, you will upgrade a single PDB using *Replay Upgrade*. You unplug the PDB from the 19c CDB and plug it into a 26ai CDB. When you open the PDB, the database automatically upgrades itself. This is a method originally developed for Oracle Autonomous AI Database and is now available in Oracle AI Database.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

* Upgrade a PDB
* Plug it into an existing 26ai CDB
* Upgrade using Replay Upgrade

### Prerequisites

None.

## Task 1: Prepare for Upgrade

1. Use the *blue* 🟦 terminal. You start by assessing the upgrade readiness of the *TERRACOTTA* PDB. Examine the pre-created config file.

    ``` bash
    <copy>
    cat /home/oracle/scripts/upg-replay-upg-terracotta.cfg
    </copy>
    ```

    * You only use AutoUpgrade only for the pre-upgrade analysis and fixups. 
    * `sid` and `target_cdb` specify the SID of the source and target CDB.
    * `pdbs` is the PDB to upgrade, or a comma-separated list of PDBs.
    
    <details>
    <summary>*click to see the output*</summary>

    ``` text
    global.global_log_dir=/home/oracle/logs/upg-replay-upg-terracotta
    upg1.source_home=/u01/app/oracle/product/19
    upg1.target_home=/u01/app/oracle/product/26
    upg1.sid=CDB19
    upg1.pdbs=TERRACOTTA
    upg1.target_cdb=CDB26
    ```

    </details>

2. Start AutoUpgrade in *analyze* mode. The check usually completes very quickly. Wait for it to complete.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-replay-upg-terracotta.cfg -mode analyze
    </copy>
    ```

    * You can use the `lsj` command to get details.

3. When AutoUpgrade completes, it displays the path to the summary report. Check the summary report.

    ``` bash
    <copy>
    cat /home/oracle/logs/upg-replay-upg-terracotta/cfgtoollogs/upgrade/auto/status/status.log
    </copy>
    ```

    * The report states *Check passed and no manual intervention needed*.
    * Oracle recommends that you examine the detailed preupgrade report, but to save time in this lab, you skip it.


    <details>
    <summary>*click to see the output*</summary>

    ``` text
    ==========================================
              Autoupgrade Summary Report
    ==========================================
    [Date]           Wed Aug 12 05:06:33 GMT 2026
    [Number of Jobs] 1
    ==========================================
    [Job ID] 100
    ==========================================
    [DB Name]                cdb19
    [Version Before Upgrade] 19.31.0.0.0
    [Version After Upgrade]  23.26.3.0.0
    ------------------------------------------
    [Stage Name]    PRECHECKS
    [Status]        SUCCESS
    [Start Time]    2026-08-12 05:06:19
    [Duration]      0:00:14
    [Log Directory] /home/oracle/logs/upg-replay-upg-terracotta/CDB19/100/prechecks
    [Detail]        /home/oracle/logs/upg-replay-upg-terracotta/CDB19/100/prechecks/cdb19_preupgrade.log
                    Check passed and no manual intervention needed
    ------------------------------------------
    ```

    </details>

## Task 2: Upgrade and Convert

During your maintenance window, you perform the upgrade.

1. Still in the *blue* 🟦 terminal. Now, you start the pre-upgrade fixups. This prepares the database for the upgrade. 

    * **In the interest of time, you skip this step in the lab.**
    * The command is shown only for learning purposes.

    ``` bash
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-replay-upg-terracotta.cfg -mode fixups
    ```

    * Do not execute the command.

2. Set the environment to the source CDB, *CDB19*, and connect.

    ``` bash
    <copy>
    . cdb19
    sql / as sysdba
    </copy>
    ```

3. Unplug the *TERRACOTTA* PDB and remove it.

    ``` bash
    <copy>
    alter pluggable database terracotta close;
    alter pluggable database terracotta unplug into '/home/oracle/scripts/terracotta.xml';
    drop pluggable database terracotta keep datafiles;     
    </copy>

    # Be sure to press RETURN
    ```

    * First, you close the PDB.
    * Next, you unplug the PDB and generate a manifest file. The manifest file is an overview of the PDB, its data files, and additional information.
    * Finally, you remove the PDB from the source CDB.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> alter pluggable database terracotta close;

    Pluggable database TERRACOTTA altered.

    SQL> alter pluggable database terracotta unplug into '/home/oracle/scripts/terracotta.xml';

    Pluggable database TERRACOTTA altered.

    SQL> drop pluggable database terracotta keep datafiles;

    Pluggable database TERRACOTTA dropped.    
    ```

    </details>

4. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```
5. Now set the environment to the target CDB, *CDB26*, and connect.

    ``` bash
    <copy>
    . cdb26
    sql / as sysdba
    </copy>
    ```
6. Plug in the *TERRACOTTA* PDB.

    ``` bash
    <copy>
    create pluggable database terracotta using '/home/oracle/scripts/terracotta.xml' NOCOPY;
    </copy>
    ```

    * The target CDB now reads the manifest file and plugs the *TERRACOTTA* PDB into the CDB.
    * It reuses the data files in their current location because the `NOCOPY` clause is specified. 
    * You can copy or move the data files by modifying the `CREATE PLUGGABLE DATABASE` statement accordingly.
    
    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> create pluggable database terracotta using '/home/oracle/scripts/terracotta.xml NOCOPY';

    Pluggable database TERRACOTTA created.
    ```

    </details>

7. Ensure Replay Upgrade is enabled.

    ``` bash
    <copy>
    select property_name, property_value 
    from   database_properties 
    where  property_name like '%ON_OPEN';
    </copy>
    ```

    * `UPGRADE_PDB_ON_OPEN` is true, so Replay Upgrade is turned on.
    * There is also a property called `CONVERT_NONCDB_ON_OPEN`. This controls whether non-CDB databases are automatically converted instead of manually calling the `noncdb_to_pdb.sql` script. 
    
    <details>
    <summary>*click to see the output*</summary>

    ``` text
    PROPERTY_NAME             PROPERTY_VALUE
    _________________________ _________________
    CONVERT_NONCDB_ON_OPEN    true
    UPGRADE_PDB_ON_OPEN       true
    ```

    </details>

8. Open the PDB.

    ``` bash
    <copy>
    set timing on
    alter pluggable database terracotta open;
    </copy>
    ```

    * The `open` command triggers the Replay Upgrade.
    * Although it appears the command is hanging, it is not.
    * Behind the scenes, the database is upgrading the PDB.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> alter pluggable database terracotta open;
    
    
    ```

    </details>

9. Leave the upgrade running. Do not exit. 

10. You return to this upgrade in a later lab.

You may now [*proceed to the next lab*](#next).

## Learn More

Upgrading a single PDB using Replay Upgrade is a convenient method. Originally developed for Oracle Autonomous AI Database, it fits very well in uniform environments where PDBs are similar. However, the upgrade offers fewer customization options than AutoUpgrade and the logging is less extensive.

* Webinar, [Move to Oracle Database 23ai – Everything you need to know about Oracle Multitenant – Part 2](https://www.youtube.com/watch?v=Sm75OIWagkE&t=4469s)
* Slides, [Move to Oracle Database 23ai – Everything you need to know about Oracle Multitenant – Part 2](https://dohdatabase.com/wp-content/uploads/2024/06/vc20_multitenant_part2-1.pdf)

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Alex Zaballa, Mike Dietrich, Alejandro Diaz
* **Last Updated By/Date** - Daniel Overby Hansen, August 2026