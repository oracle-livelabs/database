# AHF Incident Diagnostic Collections 

## Introduction
Welcome to the "AHF Incident Diagnostic Collections" lab.  In this lab you will learn about AHF diagnostic collections and then be guided through  
viewing and generating AHF Diagnostic Collections.  First we will check that AHF knows about the Incidents you generated in the previous labs   
and then learn how to check diagnostic collections for those Incidents.

Estimated Lab Time: 10 Minutes

### Prerequisites
- You are connected to one of the DB System Nodes as described in Lab 1: Connect to your DB System
- You have performed the tasks to generate some incidents as described in Lab 5: Generate Database and Clusterware Incidents for AHF to detect and take action on.

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
* Manual, based on a specific incident type Support Request Driven Collection (SRDC)
* Manual, based on a looking for issues in a time range (Problem Chooser)
* Manual, based on a time range and component (CRS, RDBMS,...) 
> Note: Bypassing problem chooser and using long collection times for multiple components can lead to very large collections.


## Task 1: Learn about Automatic Diagnostic Collections
![Automatic Diagnostic Collections](./images/auto_collections.png =40%x*)

AHF monitors various system logs to determine if critical errors are being generated.  
If one of the monitored errors is seen then it will prepare to start an automatic diagnostic collection.  
AHF determines what needs to be collected for the specific Incident and gather that data for all nodes if required.  
All collections are copied back to the initiating node ready for analysis or upload to Oracle Support.

## Task 2: Review Automatic Diagnostic Collection for Lab 5 Incidents

1.  Use the `tfactl get` command to check auto collection was enabled (ON).
    ```
    <copy>
    tfactl get autodiagcollect
    </copy>
    ```
    Command Output:
    <pre>
    .-------------------------------------------------.
    |                 lldbcs61                        |
    +-----------------------------------------+-------+
    | Configuration Parameter                 | Value |
    +-----------------------------------------+-------+
    | Auto Diagcollection ( autodiagcollect ) | ON    |
    '-----------------------------------------+-------'
    </pre>
2. Use the `tfactl print collections` command to confirm that AHF completed an auto collection for the 2 Incidents you generated in Lab 5.
    ```
    <copy>
    tfactl print collections -json -pretty -status completed
    </copy>
    ```
    Command Output:
    <pre>
    [
        {
            "CollectionId": "20240715172659lldbcs61",
            "InitiatedNode": "lldbcs61",
            "CollectionType": "Auto Collection",
            "RequestUser": "oracle",
            "NodeList": "[lldbcs61, lldbcs62]",
            "StartTime": "2024-07-15T16:57:14.000+0000",
            "EndTime": "2024-07-15T17:32:41.000+0000",
            "ComponentList": "[rdbms, cvu, os, compliance, tns, chmos, asm, asmproxy, asmio, cha, afd]",
            "UploadStatus": "FAILED",
            "CollectionStatus": "COMPLETED",
            "Events": [
                {
                    "Name": ".*ORA-0403(0|1).*",
                    "Time": "2024-07-15T17:27:14.000+0000",
                    "SourceFile": "/u01/app/oracle/diag/rdbms/raccvxfe_d3w_lhr/racCVXFE1/trace/alert_racCVXFE1.log"
                },
                {
                    "Name": ".*ORA-00600.*",
                    "Time": "2024-07-15T17:26:53.000+0000",
                    "SourceFile": "/u01/app/oracle/diag/rdbms/raccvxfe_d3w_lhr/racCVXFE1/trace/alert_racCVXFE1.log"
                }
            ],
            "NodeCollection": [
                {
                    "Host": "lldbcs61",
                    "Tag": "/u01/app/oracle.ahf/data/repository/auto_srdcCompositeMon_Jul_15_17_27_14_UTC_2024_node_lldbcs61/",
                    "ZipFileName": "/u01/app/oracle.ahf/data/repository/auto_srdcCompositeMon_Jul_15_17_27_14_UTC_2024_node_lldbcs61/lldbcs61.tfa_srdc_autosrdc_Mon_Jul_15_17_32_46_UTC_2024.zip",
                    "ZipFileSize": "20320",
                    "CollectionTime": "410",
                    "CheckSum": "bbfc92de15cf04c19875cf4bb1eda025c9749cdb1118d05c8f30c330b87e2189",
                    "checksum_algo": "sha256",
                    "UploadStatus": "FAILED"
                },
                {
                    "Host": "lldbcs62",
                    "Tag": "/u01/app/oracle.ahf/data/repository/auto_srdcCompositeMon_Jul_15_17_27_14_UTC_2024_node_lldbcs61/",
                    "ZipFileName": "/u01/app/oracle.ahf/data/repository/auto_srdcCompositeMon_Jul_15_17_27_14_UTC_2024_node_lldbcs61/lldbcs62.tfa_srdc_autosrdc_Mon_Jul_15_17_32_46_UTC_2024.zip",
                    "ZipFileSize": "21200",
                    "CollectionTime": "420",
                    "CheckSum": "bbfc92de15cf04c19875cf4bb1eda025bbfc92de15cf04c219875cf4bb1eda02",
                    "checksum_algo": "sha256",
                    "UploadStatus": "FAILED"
                }

            ]
        }
    ]
    </pre>
    You can see from the above that this Collection is an *Auto Collection* generated for the *oracle user* as the errors were found in the alert log for a database  
    owned by the *oracle user*. 
    The collection was due to 2 Events in the alert log for the database instance **racCVXFE1** one ORA-00600 and one ORA-04031.  
    Within the collection itself you can see the exact events.
    This collection was a clusterwide collection as we have files from both nodes that are copied back to a common directory on the initiating node.
    >Note: Please ignore the "UploadStatus": "FAILED" as this is only valid when the collection is to be uploaded after completion.

3.  Review the Contents of the Automatic Diagnostic Collection.  

    All of the collection files and logs are copied back to the Inititating node in a directory under that directory.
    We can now go to that directory and see what files were collected.  
    Use the "Tag" in your print collections to determine the correct location. 
    
    >"Tag": "/u01/app/oracle.ahf/data/repository/auto_srdcCompositeMon_Jul_15_17_27_14_UTC_2024_node_lldbcs61/"

    <pre>
    cd /u01/app/oracle.ahf/data/repository/auto_srdcCompositeMon_Jul_15_17_27_14_UTC_2024_node_lldbcs61
    </pre>
    
    Now use the `ls` command to see the files.
    ```
    <copy>
    ls -al
    </copy>
    ```
    Command Output:
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
    <pre>>
    unzip -l lldbcs61.tfa_srdc_autosrdc_Mon_Jul_15_17_32_46_UTC_2024.zip
    </pre>
    > Note: You would be uploading the *.zip* files to Oracle Support when you have to raise a Support Request for the Incidents  


## Task 4: Understand Manual Diagnostic Collections for a specific incident type
![Manual Diagnostic Collections](./images/manual_collect.png =40%x*)
AHF has manual collections for :-
- When customers do not want Automatic Collections enabled.
- Incidents AHF does not detect automatically such as install or some performance issues.

Manual collections are more configurable (through CLI opstions) allowing addition of certain components and uploads to remove endpoints such as My Oracle Support.  
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


## Task 5: Understand Manual Diagnostic Collections with the problem chooser
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


## Task 6:  Generate a manual collection using problem chooser
1.  Simply run the `tfactl diagcollect` command and let the problem chhoser guide you.
```
<copy>
tfactl diagcollect
</copy>

Command Output:


2.  Generate Incidents 
## Task 2:  TODO 

1.  TODO


2.  TODO




You may now *proceed to the next lab*.  

## Acknowledgements
* **Authors** -  Bill Burton
* **Contributors** - Troy Anthony, Gareth Chapman
* **Last Updated By/Date** - Bill Burton, July  2024
