# AHF Insights Review

## Introduction

This lab will show you how to use AHF Insights reports to help diagnose problems.

Estimated Lab Time: 20 Minutes

### Objectives
- Get a bird's eye view of your database system from diagnostic perspective
- Troubleshoot problems on your database system
- Leverage AHF Insights to resolve identified problems

### Prerequisites
- System which allows downloading file using *wget* command
- Browser which can render html and javascript


### About AHF Insights

AHF Insights provides a bird's eye view of the entire database system from a diagnostic perspective.
It provides users ability to capture relevant diagnostic dimensions which are critical while troubleshooting an issue, identifying root cause and resolving them. 

Diagnostic dimensions include : 
- Database system configurations
- Variety of events observed throughout the system
- Oracle best practices violations
- Past system changes
- Software recommendations
- Management Server metrics and alerts
- Observed operating system issues
- Database issues
- Space Usage
- Patch Information
- Problems that have been detected on the system

## Task 1:  Download AHF Insights report to review System Topology
1.  Download AHF Insights report zip file

    ```
    wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/sO6Bn1uNTY_zfuv7a8D_ydrmTxKueUkifDPiua2w0S1N0hr9K1ALNEshbcK3rp16/n/idhbogog2wy7/b/ocw24-livelabs/o/2_node_database_anomalies.zip
    ```

2.  Extract AHF Insights report zip file - IMAGE
3.  Open index.html file on a browser - IMAGE

## Task 2:  Review parts of AHF Insights report

![](./images/Task-1-Point-1.png " ")

1.  Top right corner (*highlighted*) indicates AHF Version, System Type and Time Range of AHF Insights report collection.
2.  First row (*highlighted*) shows topology of the system from where AHF Insights report was generated.
3.  Second row (*highlighted*) shows insights available from the system from various dimensions of diagnostics.

## Task 3:  Review *Cluster Section* in System Topology

1.  On Home tab click on the *Cluster Section*

![](./images/Task-3-Point-1.png " ")

2.  *Cluster Summary* sub tab gives you high level details regarding the cluster.

![](./images/Task-3-Point-2.png " ")

3.  Click copy icon (*highlighted above*) to copy the panel data in text format to your clipboard.
4.  You can post it in your notepad / any other application.

![](./images/Task-3-Point-4.png " ")

5.  *Cluster Resources* sub tab gives you details of clusterware managed resources and their state.
    - Note : You can *Expand* each resource to check details and can also make use of *Expand All* switch to view/hide them all

![](./images/Task-3-Point-5.png " ")

6.  *ASM Details* sub tab gives you ASM Instance and Disk group details.

![](./images/Task-3-Point-6.png " ")

    

## Task 4:  Review *Database Section* in System Topology

1.  Click on Home tab (*highlighted*) and open database section (*highlighted*).
    - Note : Provides you high level details regarding databases.

![](./images/Task-4-point-1.png " ")

2.  Click copy icon (*highlighted*) to copy the panel data in text format to your clipboard.

![](./images/Task-4-point-2.png " ")

3.  You can post it in your notepad / any other application.
4.  Click on Show button (*highlighted above*) to get additional Instance, Tablespace and PDB  details.
5.  Observe : The timestamp at which snapshot was taken is available at the bottom right corner (*highlighted above*).

## Task 5:  Review *Database Servers Section* in System Topology

1.  Click on Home tab (*highlighted*) and open Database Servers section (*highlighted*).
    - Note : Provides you high level configuration details regarding database servers.

![](./images/Task-5-point-1.png " ")

2.  Click copy icon (*highlighted*) to copy the panel data in text format to your clipboard.

![](./images/Task-5-point-2.png " ")

3.  You can post it in your notepad / any other application.

![](./images/Task-5-point-3.png " ")


## Task 6:  Review *Storage Servers Section* in System Topology

1.  Click on Home tab (*highlighted*) and open Storage Servers section (*highlighted*).
    - Note : Provides you high level configuration details regarding storage servers.

![](./images/Task-6-point-1.png " ")

2.  Click copy icon (*highlighted*) to copy the panel data in text format to your clipboard.

![](./images/Task-6-point-2.png " ")

3.  You can post it in your notepad / any other application.

![](./images/Task-6-point-3.png " ")

## Task 7:  Review *Fabric Switches Section* in System Topology

1.  Click on Home tab (*highlighted*) and open Fabric Switches section (*highlighted*). - IMAGE
    - Note : Provides you high level configuration details regarding fabric switches.

![](./images/Task-7-point-1.png " ")

## Task 8:  Download AHF Insights report to review Insights

1.  Download AHF Insights report zip file

    ```
    wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/sO6Bn1uNTY_zfuv7a8D_ydrmTxKueUkifDPiua2w0S1N0hr9K1ALNEshbcK3rp16/n/idhbogog2wy7/b/ocw24-livelabs/o/2_node_database_anomalies.zip
    ```

2.  Extract AHF Insights report zip file - IMAGE
3.  Open index.html file on a browser - IMAGE

## Task 9:  Review *Timeline Section* in Insights

1.  Click on Home tab (*highlighted*) and open timeline section (*highlighted*). - IMAGE
    - Note : Provides you distribution of events that happened across the nodes at different levels of the stack. Moreover these events are also categorized by event type, host and databases.
2.  Click and drag a section on the chart to zoom into the selected timeframe. - IMAGE
3.  Double click on the chart to reset the zoom to default period. - IMAGE
4.  Click on the legend *ERROR* item to disable / enable the events beloning to *ERROR* category. - IMAGE
5.  Select different timeline views from top right corner of the tab (*highlighted*). - IMAGE
6.  Scroll down to view the events hapenning in the cluster in a chronological fashion. - IMAGE
7.  Change the filters to slice and dice the event information. - IMAGE
    - Note : When you change the time selection by clicking and dragging the chart the start and end time in filters change and vice versa.
8.  Expand the event row by clicking on the arrow (*highlighted*) before the timestamp, to view additional details regarding the event. - IMAGE
9.  Click copy icon (*highlighted*) to copy the panel data in text format to your clipboard. - IMAGE
10.  You can post it in your notepad / any other application. - IMAGE
11.  Click on Show button (*highlighted*) to get additional Instance, Tablespace and PDB  details. - IMAGE
12.  Observe : The timestamp at which snapshot was taken is available at the bottom right corner (*highlighted*).

## Task 10:  Review *Operating System Issues Section* in Insights

1.  TODO
2.  TODO

## Task 11:  Review *Best Practice Issues Section* in Insights

1.  Click on Home tab (*highlighted*) and open Best Practice Issues section (*highlighted*). - IMAGE
    - Note : Provides you information regarding best practice (compliance) violations on your system.
2.  Observe : High level information regarding the best practice data collection. - IMAGE
3.  Observe : Chart showcasing health score and check status distribution (*highlighted*). - IMAGE
4.  Observe : Chart showcasing check status distribution across components and various sections (*highlighted*). - IMAGE
5.  Click on the legend *PASS* item to disable / enable the checks beloning to *PASS* category. - IMAGE
    - Note : You will observe the difference in the chart and at the bottom you will see PASS checks will appear when the PASS legend is enabled and will disappear when the PASS legend is disabled.
6.  Change the filters to slice and dice the best practice check information. - IMAGE
7.  Click on Jump To Section (*highlighted*) to move to a specific cateogry. - IMAGE
8.  Expand the check row by clicking on the arrow (*highlighted*) before the check status, to view additional what are the benifit / impact of the check on your system and details regarding the target and their corresponding status. - IMAGE
9.  Expand the target row by clicking on the arrow (*highlighted*) before the target name, to view additionaloutput of the check execution on the system for the given node. - IMAGE

## Task 12:  Review *System Change Section* in Insights

1.  Click on Home tab (*highlighted*) and open System Change section (*highlighted*). - IMAGE
    - Note : Provides you a timeline regarding changes observed on your system in the last 30 days from the following areas : Database Parameter, ASM Parameter, OS Packages, Oracle Software.
2.  Change the time filters to narrow down changes from the time period of interest. - IMAGE
3.  Select the change categories of interest by select values in System Change Type dropdown (*highlighted*). - IMAGE
4.  Observe : Every change entry gives information regarding targets on which the change was observed. - IMAGE

## Task 9:  Review *Recommended Software Section* in Insights

1.  TODO
2.  TODO

## Task 9:  Review *Database Server Section* in Insights

1.  TODO
2.  TODO

## Task 9:  Review *RPM List Section* in Insights

1.  TODO
2.  TODO

## Task 9:  Review *Database Parameters Section* in Insights

1.  TODO
2.  TODO

## Task 9:  Review *Kernel Parameters Section* in Insights

1.  TODO
2.  TODO

## Task 9:  Review *Patch Information Section* in Insights

1.  TODO
2.  TODO

## Task 9:  Review *Space Analysis Section* in Insights

1.  TODO
2.  TODO

## Task 9:  Review *Database Anomalies Advisor Section* in Insights

1.  TODO
2.  TODO

## Task 9:  Review *Patch Information Section* in Insights

1.  TODO
2.  TODO

```
wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/sO6Bn1uNTY_zfuv7a8D_ydrmTxKueUkifDPiua2w0S1N0hr9K1ALNEshbcK3rp16/n/idhbogog2wy7/b/ocw24-livelabs/o/2_node_database_anomalies.zip
```

```
wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/prOzBTYBnuuqgzr8Vtimkok6gdruMRbAJcGbwULurrL5VqeUB_GSEAwv3UyFIP_x/n/idhbogog2wy7/b/ocw24-livelabs/o/2_node_space_usage.zip
```
```
wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/163cLvTyGHDkr3WuHhw9eAYfAKDYSRaXLELFfbht6syQO_5bfniYYfYIY3-qo42e/n/idhbogog2wy7/b/ocw24-livelabs/o/2_node_with_event_timeline.zip
```
```
wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/-1Rev5YesCjolSIva291SB6r9HDl6LDPHiQHAIclsQ99-Ebc9KeTK-Jm0JOwFP3n/n/idhbogog2wy7/b/ocw24-livelabs/o/2_node_with_node_eviction.zip
```

```
wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/IpJkXiZtW35Od2ECPpKgjzCd_mUEwhYKpfw-8dNH2Y2WlCnBC4K3Z5ZhCwI4oXIH/n/idhbogog2wy7/b/ocw24-livelabs/o/8_node_configuration_and_best_practice.zip
```

```
wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/qd-ZOeKs0EMpBCWK5MMmx41NOyH7bxOyx1vBGOZGnlIL_7u66blEMwNOzQvk8g_U/n/idhbogog2wy7/b/ocw24-livelabs/o/insights_with_os_issues.zip
```

You may now *proceed to the next lab*.  

## Acknowledgements
* **Authors** - Troy Anthony, Bill Burton
* **Contributors** - 
* **Last Updated By/Date** - Bill Burton, July  2024
