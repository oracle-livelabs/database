# AWR Compare Periods Report

## Introduction

In this lab, you will create AWR diff reports. Those reports give you a first indication about issues you may see (or performance improvements). It is important to compare periods which have roughly the same load and duration.

Estimated Time: 30 minutes

![performance prescription](./images/performance_prescription_02.png " ")

Watch the video below for a quick walk through of the lab.
[Watch the video](youtube:2oOpQs8MCME)

### Comparing Database Performance Over Time

Performance degradation of the database occurs when your database was performing optimally in the past, but over time has gradually degraded to a point where it becomes noticeable to the users. AWR Compare Periods report enables you to compare database performance over time.

An AWR Compare Periods report, shows the difference between two periods in time (or two AWR reports, which equates to four snapshots). Using AWR Compare Periods reports helps you to identify detailed performance attributes and configuration settings that differ between two time periods: before upgrade and after upgrade.

### Objectives

In this lab, you will:

* Generate Load
* Create an AWR Diff report

### Prerequisites

This lab assumes you have:

- An Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup 
    - Lab: Environment Setup
    - Lab: Initialize Environment

## Task 1: Generate load

1.  Open an xterm or reuse the previous one. Now, since the database has been upgraded, the environment needs to be switched to 19c:
	```
	<copy>
    . upgr19
    cd /home/oracle/scripts
    sqlplus / as sysdba
	</copy>
	```
   ![switch to 19c](./images/upgrade_19c_29.png " ")

2. At first, create an AWR snapshot BEFORE load, then another one AFTER load.

	```
	<copy>
	@snap.sql
	</copy>
	```

3. Please NOTE down the snapshot number. It may be different than in the screenshot below.
   ![NOTE down the snapshot number](./images/upgrade_19c_30.png " ")

4. At this point you need to generate a comparable workload again. Start HammerDB a second time and repeat the steps from the "Generate Load lab" again.
   ![generate load](./images/hammerdb02.png " ")

5. Once finished, create another AWR snapshot.

	```
	<copy>
	@snap.sql
	</copy>
	```

6. Please NOTE down the snapshot number of the second snapshot. It may be different than the one in the screenshot below.
   ![NOTE down the snapshot number](./images/upgrade_19c_31.png " ")

## Task 2: AWR diff report

In the AWR Diff Report you will compare a snapshot period BEFORE upgrade to a snapshot period AFTER upgrade.

1. Call the AWR Diff script awrddrpt.sql:

	```
	<copy>
	@?/rdbms/admin/awrddrpt.sql
	</copy>
	```
	![Call the AWR Diff script](./images/upgrade_19c_32-2.png " ")


2. Click **RETURN**
   ![](./images/upgrade_19c_32.png " ")
   ![](./images/upgrade_19c_33-2.png " ")

    ```
    Instances in this Workload Repository schema

    DB Id      InstNum	DB Name      Instance	  Host
    ---------- -------- ------------- --------- -----------------
    * 72245725	     1	UPGR	        UPGR	    localhost.lo

    Database Id and Instance Number for the First Pair of Snapshots
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Using	72245725 for Database Id for the first pair of snapshots
    Using	       1 for Instance Number for the first pair of snapshots

    Specify the number of days of snapshots to choose from
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Entering the number of days (n) will result in the most recent
    (n) days of snapshots being listed.  Pressing  without
    specifying a number lists all completed snapshots.

    Enter value for num_days:
    ```

3. Type: **2** and click **RETURN**
   ![Type 2 and click RETURN](./images/upgrade_19c_34.png " ")

4. Now you need to define the first snapshot interval – therefore, **fill in the snapshot ID's you noted down during the first HammerDB run**.

    ```
    Enter value for num_days: 2

    Listing the last 2 days of Completed Snapshots
    Instance     DB Name	  Snap Id	Snap Started	Snap Level
    ------------ ------------ ---------- ------------------ ----------

    UPGR	     UPGR		110  20 Feb 2020 22:12	  1
                      111  20 Feb 2020 22:39	  1
                      112  20 Feb 2020 22:40	  1
                      113  21 Feb 2020 00:05	  1
                      114  21 Feb 2020 00:15	  1


    Specify the First Pair of Begin and End Snapshot Ids
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Enter value for begin_snap:
    ```

5. Type: 150. (Your actual snapshot ID may be different – please check your notes!) Hit RETURN.
   ![Type 150 Hit RETURN](./images/upgrade_19c_35.png " ")
   ![view](./images/upgrade_19c_36.png " ")


6. Type: **2** and hit **RETURN**
   ![ Type 2 and hit RETURN](./images/upgrade_19c_37.png " ")

    Type: 175 (Your actual snapshot ID may be different – please check your notes!)
	![](./images/upgrade_19c_38.png " ")

7. Hit **RETURN**
   ![hit RETURN](./images/upgrade_19c_41.png " ")

8.  Enter awrdiff and hit RETURN. Wait until the HTML output has been generated

	```
	<copy>
	exit
	</copy>
	```

9. Start Mozilla Firefox with the awrdiff report.


	```
	<copy>
	firefox /home/oracle/scripts/awrdiff*.html &
	</copy>
	```
	![Start Mozilla Firefox with the awrdiff](./images/upgrade_19c_39.png " ")
	![view report](./images/upgrade_19c_40.png " ")

10. Compare items such as Wait Events etc. Watch out for significant divergence between the two runs, for instance the different redo sizes per run. Also, browse through the SQL statistics and see if you find remarkable differences between the two runs. Overall, you will not see any significant differences. The purpose of this lab exercise is for you to simply recognize and remember how easy AWR Diff Reports can be generated when you have comparable workloads in your testing environments.

You may now *proceed to the next lab*.

## Learn More

* [Comparing Database Performance Over Time](https://docs.oracle.com/en/database/oracle/oracle-database/19/tgdba/comparing-database-performance-over-time.html#GUID-BEDBF986-1A69-459A-90F5-350B8A407516)

## Acknowledgements
* **Author** - Mike Dietrich, Database Product Management
* **Contributors** -  Roy Swonger, Sanjay Rupprel, Cristian Speranta, Kay Malcolm
* **Last Updated By/Date** - Mike Dietrich, July 2021
