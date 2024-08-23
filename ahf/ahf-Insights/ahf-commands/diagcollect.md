
# AHF Incident Diagnostic Collections 

## Introduction
Welcome to the "AHF Incident Diagnostic Collections" lab.  In this lab you will learn about AHF diagnostic collections and then be guided through viewing and generating AHF Diagnostic Collections.  
First we will check that AHF knows about the Incidents you generated in the previous labs and then learn how to check diagnostic collections for those Incidents.

Estimated Lab Time: 10 Minutes

### Prerequisites
- You are connected to one of the DB System Nodes as described in Lab 1: Connect to your DB System
- You have performed the tasks to generate some incidents as described in Lab 2: Generate Database and Clusterware Incidents for AHF to detect and take action on.

### Objectives

In this lab, you will:
* Understand the different types of AHF Diagnostic collections.
* Determine if AHF has detected Incidents and has already taken Diagnostic Collections Automatically
* Take manual collections for any type of Incident 
* Review Collection contents
* Confirm the health of AHF on the System

### About AHF Diagnostic Collection Options
AHF has 4 basic types of Incident Diagnostic Collections:-
* Automatic, based on a limited set of detected Incidents.
    * Internal Errors, Node and Instance Evictions, hangs
* Manual, based on a specific incident type: Support Request Driven Collection (SRDC)
* Manual, based on a looking for issues in a time range (Problem Chooser)
* Manual, based on a time range and component (CRS, RDBMS,...) 
> Note: Bypassing problem chooser and using long collection times for multiple components can lead to very large collections.


## Task 1: Learn about Automatic Diagnostic Collections
![Automatic Diagnostic Collections](./images/auto_collections.png =40%x*)

AHF monitors various system logs to determine if critical errors are being generated.  
If one of the monitored errors is seen then it will prepare to start an automatic diagnostic collection.  
AHF determines what needs to be collected for the specific Incident and gather that data for all nodes if required.  
All collections are copied back to the initiating node ready for analysis or upload to Oracle Support.

## Task 2: Review Automatic Diagnostic Collection for Lab 2 Incidents

1.  Use the `tfactl get` command to check auto collection was enabled (ON).
    ```
    <copy>
    tfactl get autodiagcollect
    </copy>
    ```
    Example Command Output:
    <pre>
    .-------------------------------------------------.
    |                 lldbcs61                        |
    +-----------------------------------------+-------+
    | Configuration Parameter                 | Value |
    +-----------------------------------------+-------+
    | Auto Diagcollection ( autodiagcollect ) | ON    |
    '-----------------------------------------+-------'
    </pre>
2. Use the `tfactl print collections` command to confirm that AHF completed an auto collection for the 2 Incidents you generated in Lab 2.
    ```
    <copy>
    tfactl print collections -status completed
    </copy>
    ```
    Example Command Output: 

    ![TFA Print Collections](./images/tfa-print-collections-1.png =130%x*)

    You can see from the above that this Collection is an *Auto Collection* generated due to error found in the alert log for a database. 
    The collection was due to 2 Events in the alert log for the database instance **racQYFVZ1** one ORA-00600 and one ORA-04031.  
    This collection was a clusterwide collection (you can see both nodes in the node list) with files from both nodes that are copied back to a common directory on the initiating node.


3.  Review the Contents of the Automatic Diagnostic Collection.  

    All of the collection files and logs are copied back to the Inititating node in a directory under that directory.
    We can now go to that directory and see what files were collected.  
    Use the "Tag" location (*highlighted*) from your print collections to determine the correct location. 
    
    ![TFA Print Collections Showing TAG ](./images/tfa-print-collections-2.png =130%x*)
    > Save time and use the copy below then simply hit tab for directory name completion

    ```
    <copy>
    cd /u01/app/oracle.ahf/data/repository/auto_srdcComposite
    </copy>
    ```
    
    Now use the `ls` command to see the files.
    ```
    <copy>
    ls -al
    </copy>
    ```
    Example Command Output:
    <pre>
    drwx------ 2 oracle oinstall     4096 Jul 15 17:33 .
    drwxr-xr-t 4 root   root         4096 Jul 15 17:39 ..
    -rw-r--r-- 1 oracle oinstall     3568 Jul 15 17:39 diagcollect_20240715172659_lldbcs61.log
    -rw-r--r-- 1 oracle oinstall     2214 Jul 15 17:33 diagcollect_20240715172659_lldbcs62.log
    -rw-r--r-- 1 oracle oinstall     1928 Jul 15 17:39 diagcollect_console_20240715172659_lldbcs61.log
    -rw-r--r-- 1 oracle oinstall        0 Jul 15 17:33 insightcollect_20240715172659_lldbcs62.log
    -rw-r--r-- 1 oracle oinstall 20355710 Jul 15 17:39 lldbcs61.tfa_srdc_autosrdc_Mon_Jul_15_17_32_46_UTC_2024.zip
    -rw-r--r-- 1 oracle oinstall    10157 Jul 15 17:32 lldbcs61.tfa_srdc_autosrdc_Mon_Jul_15_17_32_46_UTC_2024.zip.json
    -rw-r--r-- 1 oracle oinstall     2167 Jul 15 17:39 lldbcs61.tfa_srdc_autosrdc_Mon_Jul_15_17_32_46_UTC_2024.zip.txt
    -rw-r--r-- 1 oracle oinstall  7618260 Jul 15 17:33 lldbcs62.tfa_srdc_autosrdc_Mon_Jul_15_17_32_46_UTC_2024.zip
    -rw-r--r-- 1 oracle oinstall     2240 Jul 15 17:33 lldbcs62.tfa_srdc_autosrdc_Mon_Jul_15_17_32_46_UTC_2024.zip.txt
    </pre>
    The diagcollect log is the top level log for the collection from each node.
    The digcollect_console is the reduced log that is equivalent to what you would see on the console had this been a manual collection.  
    There is a zip collection from each node and files that describe the collection is **txt** and **json** format. 
    > Note: The **txt** and **json** files are also in the collection zip files that you supply to Oracle Support and help in Support Request automation.

4. Check the contents of the Automatic Diagnostic Collection.

    You can quickly review all the files collected/generated in the node using the `unzip -l` command
    <pre>
    unzip -l lldbcs61.tfa_srdc_autosrdc_Mon_Jul_15_17_32_46_UTC_2024.zip
    </pre>
    > Note: You would be uploading the *.zip* files to Oracle Support when you have to raise a Support Request for the Incidents  


## Task 3: Understand Manual Diagnostic Collections for a specific incident type
![Manual Diagnostic Collections](./images/manual_collect.png =40%x*)
AHF has manual collections for :-
- When customers do not want Automatic Collections enabled.
- Incidents AHF does not detect automatically such as install or some performance issues.

Manual collections are more configurable (through CLI options) allowing addition of certain components and uploads to remove endpoints such as My Oracle Support.  
Manual collections still work cross nodes and bring back all collected data to the originating node. 
They also in most cases gather an AHF Insights report but we will talk about those in a later Lab.  

![SRDC Diagnostic Collections](./images/srdc_collect.png =40%x*)
Previously when raising a Support request with Oracle Support you would have been guided to a set of instructions to gather diagnostics   
for you specific problem.  The list of actions could be long and complicated which meant that often required data was missed. The list of  
actions were known as **Support Request Driven Collections(SRDC)**.  AHF has taken the list of actions and integrated in to a single command for   
the incident type.   
> These Support Request Driven Collections are generated using the `tfactl diagcollect -srdc` command as shown.

![SRDC Diagnostic Collections](./images/srdc_dbperf.png =40%x*)
In the slide above you can see the comparison of collecting performance diagnostics through a command list and running the `tfactl diagcollect -srdc dbperf` command.


## Task 4: Understand Manual Diagnostic Collections with the problem chooser
![Problem Choose Diagnostic Collections](./images/problem_choose.png =40%x*)

Before the problem chooser, running a default AHF diagnostic Collection would mean that default collection collection would be taken.  
This would mean gathering diagnostics from every diagnostic location that AHF had detected on a system for many possible Oracle products.  
Collections could be very large and take a long time to gather unless you knew exactly how to filter what was collected by providing specific  
components to collect such as 'CRS' or 'ASM'.

The problem Chooser take the options you provide on the command line such as time range and try to find any issues AHF has detected.
You will be prompted to choose:-
* Whether one of those options is what you want.
* To choose a category of problem rather than a detected problem.
* Try a different time 
* Carry on with a default collection but after you type in the problem this collection is for.

> Remember we are trying to ensure we collect the minimum required to diagnose the problem.
> If you choose the last option we have to collect everything in the hope we get what you want.


## Task 5:  Generate a manual collection using problem chooser
1.  Simply run the `tfactl diagcollect` command and let the problem chooser guide you.
```
<copy>
tfactl diagcollect
</copy>
```
Example Command Output:
<pre>
AHF has detected following events from 2024-08-08 16:23:07.000 to 2024-08-08 20:23:07.000
All events are displayed in UTC time zone

Choose an event to perform a diagnostic collection:
1  . 2024-08-08 16:27:56.000 [RDBMS.racximwm_8wz_bom.racXIMWM1] Reconfiguration started (old inc 0, new inc 4)
2  . 2024-08-08 18:23:20.000 [RDBMS.racximwm_8wz_bom.racXIMWM1] ORA-00600: internal error code, arguments: [kgb], [livelabs1], [17], [...
3  . 2024-08-08 18:23:31.000 [RDBMS.racximwm_8wz_bom.racXIMWM1] ORA-04031: unable to allocate 90342 bytes of shared memory (,,,)
4  . Display Problem Categories
5  . Enter a different event time
X  . Exit
Choose the option [1-5]:2
</pre>

You can at this point choose one of the detected events to generate a collection for or you can choose a 'problem category' if we did not detect the event or issue you want.

You will select **ORA-00600** which will do a manual collection for the ORA-00600 
> Note: This is equivalent to running the ORA-00600 SRDC collection directly.

> Note: It can take a few minutes to complete the collection so now might be a good time to read on and then come back to this at the end if you have time. 


Example Command Output:

<pre>
Database Name racximwm_8wz_bom was specified however this database has a Database Unique Name of racXIMWM_8wz_bom.
 Database Unique Name racXIMWM_8wz_bom set for racximwm_8wz_bom.


Components included in this collection: OS DATABASE ASM

Preparing to execute support diagnostic scripts.

Collecting data for local node(s).

TFA is using system timezone for collection, All times shown in UTC.
Scanning files from 2024-08-08 17:53:20 UTC to 2024-08-08 18:53:20 UTC

Collection Id : 20240808202440lvracdb-s01-2024-08-08-1452081

Detailed Logging at : /u01/app/oracle.ahf/data/repository/srdc_internalerror_collection_Thu_Aug_08_20_24_43_UTC_2024_node_local/diagcollect_20240808202440_lvracdb-s01-2024-08-08-1452081.log

Waiting up to 120 seconds for collection to start
2024/08/08 20:24:52 UTC : NOTE : Any file or directory name containing the string .com will be renamed to replace .com with dotcom
2024/08/08 20:24:52 UTC : Collection Name : tfa_srdc_internalerror_Thu_Aug_08_20_24_42_UTC_2024.zip
2024/08/08 20:24:53 UTC : Scanning of files for Collection in progress...
2024/08/08 20:24:53 UTC : Collecting Additional Diagnostic Information...
2024/08/08 20:25:28 UTC : Getting list of files satisfying time range [08/08/2024 17:53:20, 08/08/2024 18:53:20]
2024/08/08 20:25:36 UTC : Executing TFA rdahcve with timeout of 600 seconds...
2024/08/08 20:25:55 UTC : Collecting ADR incident files...
2024/08/08 20:33:16 UTC : Executing IPS Incident Package Collection(s)...
2024/08/08 20:33:23 UTC : No ADR Incidents for racximwm_8wz_bom covering period "2024-08-08 17:53:20" to "2024-08-08 18:53:20" were generated, IPS Pack will not be collected.
2024/08/08 20:33:23 UTC : Executing SQL Script db_feature_usage.sql on racximwm_8wz_bom with timeout of 600 seconds...
2024/08/08 20:33:23 UTC : Executing Collection for ASM with timeout of 1800 seconds...
2024/08/08 20:34:05 UTC : Executing Collection for AFD with timeout of 1860 seconds...
2024/08/08 20:34:09 UTC : Executing Collection for OS with timeout of 1920 seconds...
2024/08/08 20:34:18 UTC : Completed Collection of Additional Diagnostic Information...
2024/08/08 20:34:24 UTC : Completed Local Collection
2024/08/08 20:34:24 UTC : Not Redacting this Collection ...
2024/08/08 20:34:24 UTC : Collection completed on host: lvracdb-s01-2024-08-08-1452081 
2024/08/08 20:34:24 UTC : Completed collection of zip files.

.----------------------------------------------------------.
|                    Collection Summary                    |
+--------------------------------+-----------+------+------+
| Host                           | Status    | Size | Time |
+--------------------------------+-----------+------+------+
| lvracdb-s01-2024-08-08-1452081 | Completed | 13MB | 572s |
'--------------------------------+-----------+------+------'

Logs are being collected to: /u01/app/oracle.ahf/data/repository/srdc_internalerror_collection_Thu_Aug_08_20_24_43_UTC_2024_node_local
/u01/app/oracle.ahf/data/repository/srdc_internalerror_collection_Thu_Aug_08_20_24_43_UTC_2024_node_local/lvracdb-s01-2024-08-08-1452081.tfa_srdc_internalerror_Thu_Aug_08_20_24_42_UTC_2024.zip
</pre>

If you had selected 'Display Problem Categories' You would have been able to choose from one of the below categories to make your collection

<pre>
Problem Categories:
1  . ACFS
2  . ASM Configuration
3  . ASM Errors/Other
4  . ASM Instance Crash
5  . CRS Client
6  . CRS Errors/Other
7  . Clusterware Installation
8  . Clusterware Patching
9  . Clusterware Startup
10 . Clusterware Upgrade
11 . Database Corruption
12 . Database Errors/Other
13 . Database Install
14 . Database Instance Eviction/Crash
15 . Database Internal Error
16 . Database Memory
17 . Database Patching
18 . Database Performance
19 . Database RMAN
20 . Database Recovery
21 . Database Storage (ASM)
22 . Database Streams/AQ
23 . Database Upgrade
24 . Dataguard
25 . Exadata Cell Issues
26 . GoldenGate
27 . Node Eviction/Reboot
28 . Problem not listed, provide problem description
X  . Exit
Select the category of your problem [1-28]:
</pre>

When you choose one of these categories we may request further details and then will run the specific Support Request Driven Collection for that category.

You may now [proceed to the next lab](#next).  

## Acknowledgements
* **Authors** -  Bill Burton
* **Contributors** - Troy Anthony, Gareth Chapman
* **Last Updated By/Date** - Bill Burton, July  2024
