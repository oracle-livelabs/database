# AWR Compare Periods

## Introduction

In this lab, you will run the same workload that you ran before the upgrade. Then you can compare the performance of the database - before and after upgrade - by creating AWR diff reports. 

Those reports give you a first indication of issues you may see (or performance improvements). It is important to compare periods that have roughly the same load and duration.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

* Generate load
* Create an AWR Diff report

### Prerequisites

This lab assumes:

- You have completed Lab 4: AutoUpgrade

## Task 1: Generate load

Use HammerDB to create a workload. 

1. Use the yellow terminal. Set the environment to the upgraded UPGR database. Now, since you upgraded the database, the environment needs to be set to an Oracle Database 19c home.

	```
	<copy>
    . upgr19
    sqlplus / as sysdba
	</copy>
	```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    $ sqlplus / as sysdba

    SQL*Plus: Release 19.0.0.0.0 - Production on Thu Jul 6 21:09:27 2023
    Version 19.18.0.0.0

    Copyright (c) 1982, 2022, Oracle.  All rights reserved.

    Connected to:
    Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
    Version 19.18.0.0.0

    SQL> 
    ```
    </details>

2. Create an AWR snapshot. Take note of the snapshot ID (e.g., 130). You need it later on. 

	```
    <copy>
    @/home/oracle/scripts/snap-lab-05-before.sql
    </copy>
	```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> @/home/oracle/scripts/snap-lab-05-before.sql
    -------------------------------------------
    - AWR Snapshot with Snap-ID: 130 created. -
    -------------------------------------------
    ```
    </details>

3. Don't exit the terminal. Keep SQL*Plus open.

4. Start HammerDB. On the desktop, double-click on the *HammerDB*.
    ![Double-click on the HammerDB icon](./images/05-awr-compare-hammerdb-icon.png " ")

5. In the benchmark list, expand *Oracle* / *TPROC-C*

    ![Open the Driver Script setup with a Click](./images/05-awr-compare-expand-list.png " ")   

6. Expand *Driver Script*.

    ![Open the Driver Script setup with a Click](./images/05-awr-compare-expand-driver-script.png " ")

7. Double-click on *Load*.

    ![Double-Click on the Load option](./images/05-awr-compare-load-driver.png " ")

8. This populates the *Script Editor* tab with the driver script. Ignore any error messages.

9. Click *Run* in the list. Start the load by clicking on the Run icon.
    
    ![Start the TPC-C Load by clicking on the Run icon](./images/05-awr-compare-run.png " ")

10. Click on the Graph / Transaction Counter icon in the top menu icon bar. 
    ![Click on the Graph Transaction Counter icon](./images/05-awr-compare-transact-counter.png " ")

11. It will take a few seconds; then you will see the performance charts and the transactions-per-minute (tpm). The load run usually takes 2-3 minutes to complete.
    ![see the performance charts and the transactions-per-minute](./images/05-awr-compare-transact-viewer.png " ")

12. Exit HammerDB.

13. Create another AWR snapshot. Take note of the snapshot ID (e.g., 131). You need it later on. 

    ```
    <copy>
    @/home/oracle/scripts/snap-lab-05-after.sql
    </copy>
    ```

    <details>
    <summary>*click to see the output*</summary>
    ``` text
    SQL> @/home/oracle/scripts/snap-lab-05-after.sql
    ------------------------------------------
    - AWR Snapshot with Snap-ID: 131 created. -
    ------------------------------------------
    ```
    </details>

## Task 2: Create an AWR Diff report

In the AWR Diff Report, you will compare a snapshot period **before** upgrade to a similar snapshot period **after** upgrade.

1. Call the AWR Diff script awrddrpt.sql:

	```
	<copy>
	@?/rdbms/admin/awrddrpt.sql
	</copy>
	```
   When prompted for:
    * *report_type*, hit RETURN.
    * *num_days*, type *2*, hit RETURN.
    * *begin_snap* (first pair), type the first *Snap Id* from lab 2, hit RETURN. If you can't remember, check the file `/home/oracle/scripts/snap-lab-02-before.log`.
    * *end_snap* (first pair), type the last *Snap Id* from lab 2, hit RETURN. If you can't remember, check the file `/home/oracle/scripts/snap-lab-02-after.log`.
    * *num_days*, type *2*, hit RETURN.
    * *begin_snap* (second pair), type the first *Snap Id* from this lab, hit RETURN. If you can't remember, check the file `/home/oracle/scripts/snap-lab-05-before.log`.
    * *end_snap* (second pair), type the last *Snap Id* from this lab, hit RETURN. If you can't remember, check the file `/home/oracle/scripts/snap-lab-05-after.log`.
    * *report_name*, hit RETURN.

2. Wait until the HTML output has been generated, then exit SQL*Plus.

	```
	<copy>
	exit
	</copy>
	```

9. Open the AWR diff report in Firefox.

	```
	<copy>
	firefox awrdiff*.html &
	</copy>
	```
	![AWR Diff Report](./images/05-awr-compare-diff-report.png " ")

10. Examine the AWR diff report. 
   * Compare items such as Wait Events etc. Watch out for significant divergence between the two runs, for instance, the different redo sizes per run. 
   * Browse through the SQL statistics and see if you find remarkable differences between the two runs. 
   * Overall, you will not see any significant differences. The purpose of this lab exercise is to recognize and remember how easily AWR Diff Reports can be generated when you have comparable workloads.

You may now *proceed to the next lab*.

## Learn More

Performance degradation of the database occurs when your database was performing optimally in the past, but over time has gradually degraded to a point where it becomes noticeable to the users. AWR Compare Periods report enables you to compare database performance over time.

An AWR Compare Periods report, shows the difference between two periods in time (or two AWR reports, which equates to four snapshots). Using AWR Compare Periods reports helps you to identify detailed performance attributes and configuration settings that differ between two time periods: before upgrade and after upgrade.

* [Comparing Database Performance Over Time](https://docs.oracle.com/en/database/oracle/oracle-database/19/tgdba/comparing-database-performance-over-time.html#GUID-BEDBF986-1A69-459A-90F5-350B8A407516)
* Webinar, [Performance Stability Perscription #2: Compare AWR](https://www.youtube.com/watch?v=qCt1_Fc3JRs&t=4282s)


## Acknowledgements
* **Author** - Mike Dietrich, Database Product Management
* **Contributors** - Daniel Overby Hansen, Roy Swonger, Sanjay Rupprel, Cristian Speranta, Kay Malcolm
* **Last Updated By/Date** - Daniel Overby Hansen, July 2023
