# Generate AWR Snapshot

## Introduction

In this lab, you will execute an application workload using HammerDB on the *UPGR* database. You will capture workload information that you can use later on to compare pre-upgrade performance to post-upgrade performance.

Estimated Time: 15 Minutes

[Hitchhiker's Guide Lab 3](youtube:lwvdaM4v4tQ?start=1290)

### Objectives

In this lab, you will:

* Generate an AWR snapshot
* Prepare workload
* Start workload
* Generate another AWR snapshot

### Prerequisites

This lab assumes:

* You have completed Lab 1: Initialize Environment

## Task 1: Generate an AWR snapshot

1. Use the *yellow* terminal 🟨. Set the environment to the *UPGR* database and connect.

    ``` sql
    <copy>
    . upgr
    sql / as sysdba
    </copy>

    -- Be sure to hit RETURN
    ```

2. Use the script to generate an AWR snapshot. Take note of the snapshot ID (e.g.: 113). You need it later on.

    ``` sql
    <copy>
    @/home/oracle/scripts/upg-03-awr-snapshot-snap-before.sql
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> @/home/oracle/scripts/upg-03-awr-snapshot-snap-before.sql
    -------------------------------------------
    - AWR Snapshot with Snap-ID: 113 created. -
    -------------------------------------------
    ```

    </details>

    Your snapshot ID might differ from the one in the sample output.

3. Don’t exit the terminal. Keep SQLcl open.

4. Start HammerDB using the desktop shortcut.

    ![Start HammerDB using desktop icon](./images/awr-snapshot-hammerdb-icon.png " ")

## Task 2: Prepare workload

1. In the benchmark list, expand *Oracle* / *TPROC-C*

    ![Open the Driver Script setup with a Click](./images/awr-snapshot-expand-list.png " ")

2. Expand *Driver Script*.

    ![Open the Driver Script setup with a Click](./images/awr-snapshot-expand-driver-script.png " ")

3. **Double-click** on *Load*.

    ![Double-Click on the Load option](./images/awr-snapshot-load-driver.png " ")

4. This populates the *Script Editor* tab with the driver script. Ignore any error messages.

5. Expand *Virtual Users* and **double-click** on *Create*. This creates three virtual users (users 2-4) for the workload. HammerDB creates an additional user for monitoring.

    ![view the 3 Virtual Users being started](./images/awr-snapshot-create-virtual-users.png " ")

## Task 3: Capture workload from cursor cache

Start capturing workload information from the cursor cache into a SQL tuning set.

1. Back in the *yellow* terminal 🟨, run the capture script. The script polls the cursor cache every 10 seconds for three minutes. **Leave the script running and immediately proceed to the next step.** Do not press CTRL+C.

    ``` sql
    <copy>
    @/home/oracle/scripts/upg-03-capture_cc.sql
    </copy>

    -- Be sure to hit RETURN
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> @/home/oracle/scripts/upg-03-capture_cc.sql
    Dropping SQL Tuning Set, if exists

    PL/SQL procedure successfully completed.

    Creating SQL Tuning Set

    PL/SQL procedure successfully completed.

    Now polling the cursor cache for 180 seconds every 10 seconds ...
    You get control back in 180 seconds.
    Do not press CTRL+C
    ```

    </details>

## Task 4: Start workload

Use HammerDB to start a workload. 

1. Return to HammerDB.

2. Click *Run* in the list. Start the load by clicking on the Run icon.

    ![Start the TPC-C Load by clicking on the Run icon](./images/awr-snapshot-start-load.png " ")

3. Click on the Graph / Transaction Counter icon in the top menu icon bar.

    ![Click on the Graph Transaction Counter icon](./images/awr-snapshot-transact-counter.png " ")

4. It will take a few seconds; then you will see the performance charts and the transactions-per-minute (tpm). The load run usually takes 2-3 minutes to complete.

    ![see the performance charts and the transactions-per-minute](./images/awr-snapshot-transact-viewer.png " ")

5. Exit HammerDB.

6. Back in the *yellow* terminal 🟨, the script `upg-03-capture_cc.sql` should be done by now. Examine the output. It lists how many statements it captured from the cursor cache and into the SQL Tuning Set.

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> @/home/oracle/scripts/upg-03-capture_cc.sql
    Dropping SQL Tuning Set, if exists

    PL/SQL procedure successfully completed.

    Creating SQL Tuning Set

    PL/SQL procedure successfully completed.

    Now polling the cursor cache for 180 seconds every 10 seconds ...
    You get control back in 180 seconds.
    Do not press CTRL+C

    There are now 43 SQL Statements in this STS.

    PL/SQL procedure successfully completed.
    ```

    </details>

## Task 5: Generate another AWR snapshot

1. Still in the *yellow* terminal 🟨, create another AWR snapshot. Take note of the snapshot ID (e.g.: 117). You need it later on.

    ``` sql
    <copy>
    @/home/oracle/scripts/upg-03-awr-snapshot-snap-after.sql
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>

    ``` text
    SQL> @/home/oracle/scripts/upg-03-awr-snapshot-snap-after.sql
    -------------------------------------------
    - AWR Snapshot with Snap-ID: 117 created. -
    -------------------------------------------
    ```

    </details>

    Your snapshot ID might differ from the one in the sample output.

2. Exit from SQLcl.

    ``` sql
    <copy>
    exit
    </copy>
    ```

You may now [*proceed to the next lab*](#next).

## Learn More

The Automatic Workload Repository (AWR) collects, processes, and maintains performance statistics for problem detection and self-tuning purposes. This data is both in memory and stored in the database. You can display the gathered data as both reports and views.

Snapshots are sets of historical data for specific periods that are used for performance comparisons by ADDM. By default, Oracle Database automatically generates snapshots of the performance data once every hour and retains the statistics in the workload repository for 8 days. You can also manually create snapshots. In this lab, we will manually create snapshots.

* [HammerDB](https://www.hammerdb.com/)
* Documentation, [Managing AWR Snapshots](https://docs.oracle.com/en/database/oracle/oracle-database/19/tgdba/gathering-database-statistics.html#GUID-144711F9-85AE-4281-B548-3E01280F9A56)
* Webinar, [Performance Stability Prescription #1: Collect SQL Tuning Sets](https://www.youtube.com/watch?v=qCt1_Fc3JRs&t=3969s)

## Acknowledgements

* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Alex Zaballa, Mike Dietrich
* **Last Updated By/Date** - Rodrigo Jorge, August 2025
