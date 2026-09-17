# Upgrade PDB Using Unplug-Plug

## Introduction

In this lab, you will upgrade a single PDB using an unplug-plug upgrade. You unplug the PDB from the 19c CDB, plug it into a 26ai CDB, and perform the upgrade. Unplug-plug upgrades are faster than full CDB upgrades because you only need to upgrade the PDB, not the full CDB. You will copy the data files during plug-in. This takes longer but provides a better rollback option. 

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

* Upgrade a PDB
* Plug in to an existing 26ai CDB
* Copy the data files

### Prerequisites

None.

## Task 1: Prepare for Upgrade

You can plug it into an existing 26ai CDB on the same machine. AutoUpgrade handles the entire process. You start by checking the source database for upgrade readiness.

1. Use the *yellow* 🟨 terminal. Set the environment to *CDB19* and connect. 

    ``` bash
    <copy>
    . cdb19
    sql / as sysdba
    </copy>

    # Be sure to press RETURN
    ```

2. Switch to the *ORANGE* PDB and check the `COMPATIBLE` parameter.

    ``` bash
    <copy>
    alter session set container=ORANGE;
    select value from v$parameter where name='compatible';
    </copy>

    # Be sure to press RETURN
    ```

    * The `COMPATIBLE` parameter is set to `19.0.0`. 
    * You will learn more about this parameter in a later lab.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
        VALUE
    _________
    19.0.0
    ```

    </details>

3. Exit SQLcl.

    ``` bash
    <copy>
    exit
    </copy>
    ```    

4. For this lab, you use a precreated config file. Examine the precreated config file.

    ``` bash
    <copy>
    cat /home/oracle/scripts/upg-unplug-plug-orange.cfg
    </copy>
    ```

    * `sid` and `target_cdb` specify the SID of the source and target CDB. respectively.
    * `pdbs` is a comma-separated list of PDBs to upgrade.
    * `target_pdb_copy_option` instructs AutoUpgrade to copy the data files during plug-in. Because this environment uses Oracle Managed Files (OMF), the configuration specifies `file_name_convert=none`. 
    
    <details>
    <summary>*click to see the output*</summary>

    ``` text
    global.global_log_dir=/home/oracle/logs/upg-unplug-plug-orange
    upg1.source_home=/u01/app/oracle/product/19
    upg1.target_home=/u01/app/oracle/product/26
    upg1.sid=CDB19
    upg1.target_cdb=CDB26
    upg1.pdbs=ORANGE
    upg1.target_pdb_copy_option.ORANGE=file_name_convert=none
    ```

    </details>

5. Start AutoUpgrade in *analyze* mode. The check usually completes very quickly. Wait for it to complete.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-unplug-plug-orange.cfg -mode analyze
    </copy>
    ```

    * You can use the `lsj` command to get details.

6. When AutoUpgrade completes, it displays the path to the summary report. Check the summary report.

    ``` bash
    <copy>
    cat /home/oracle/logs/upg-unplug-plug-orange/cfgtoollogs/upgrade/auto/status/status.log
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
    [Log Directory] /home/oracle/logs/upg-unplug-plug-orange/CDB19/100/prechecks
    [Detail]        /home/oracle/logs/upg-unplug-plug-orange/CDB19/100/prechecks/cdb19_preupgrade.log
                    Check passed and no manual intervention needed
    ------------------------------------------
    ```

    </details>

## Task 2: Unplug, Plug In, and Upgrade

During your maintenance window, start AutoUpgrade to perform the upgrade.

1. Use the *yellow* 🟨 terminal. Start AutoUpgrade in *deploy* mode.

    ``` bash
    <copy>
    java -jar autoupgrade.jar -config /home/oracle/scripts/upg-unplug-plug-orange.cfg -mode deploy
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    Processing config file ...
    +--------------------------------+
    | Starting AutoUpgrade execution |
    +--------------------------------+
    1 PDB(s) will be processed
    Type 'help' to list console commands
    upg>
    ```

    </details>

2. Monitor the upgrade. Use the `status` command.

    ``` bash
    <copy>
    status -job 101 -a 10
    </copy>
    ```

    * AutoUpgrade now unplugs the PDB from *CDB19*. 
    * When plugging the PDB into *CDB26*, AutoUpgrade instructs the CDB to copy the data files.
    * This preserves the original data files for rollback.
    * Finally, it upgrades the PDB. 

3. Leave the upgrade running. Do not exit AutoUpgrade. 

4. You will return to this upgrade in a later lab.

You may now [*proceed to the next lab*](#next).

## Learn More

Upgrading a single PDB using an unplug-plug upgrade is faster than performing a full CDB upgrade. However, you cannot use Flashback Database for rollback, and this approach also has implications for Data Guard. You can reuse the data files for a faster upgrade or copy them to provide better rollback options. AutoUpgrade supports both methods.

* Webinar, [Move to Oracle Database 23ai – Everything you need to know about Oracle Multitenant – Part 2](https://www.youtube.com/watch?v=Sm75OIWagkE&t=3185s)
* Slides, [Move to Oracle Database 23ai – Everything you need to know about Oracle Multitenant – Part 2](https://dohdatabase.com/wp-content/uploads/2024/06/vc20_multitenant_part2-1.pdf)
* Blog post, [Upgrade Oracle Database 19c PDB to 26ai](https://dohdatabase.com/2026/02/17/upgrade-oracle-database-19c-pdb-to-26ai/)


## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Rodrigo Jorge, Alex Zaballa, Mike Dietrich, Alejandro Diaz
* **Last Updated By/Date** - Daniel Overby Hansen, August 2026