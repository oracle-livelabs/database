
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
1.  Download AHF Insights report zip file.

    ```
    wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/1fl26UQZiAjg7vCEP9K0kMJ3bhpdc-cQTWKYl9g08VJMCXZr0pi46xQgUxfe2VBx/n/idhbogog2wy7/b/ocw24-livelabs/o/node1_insights_2024_07_10_23_30_54_system_topology.zip
    ```

2.  Extract AHF Insights report zip file.

![](./images/Task-1-point-2.png " ")

3.  Open index.html file on a browser.

## Task 2:  Review parts of AHF Insights report

![](./images/Task-1-Point-1.png " ")

1.  Top right corner (*highlighted above*) indicates AHF Version, System Type and Time Range of AHF Insights report collection.
2.  First row (*highlighted above*) shows topology of the system from where AHF Insights report was generated.
3.  Second row (*highlighted above*) shows insights available from the system from various dimensions of diagnostics.

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
4.  Click on Show button (*highlighted above*) to get additional details for Instance, Tablespace and PDB.
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

1.  Click on Home tab (*highlighted*) and open Fabric Switches section (*highlighted*).
    - Note : Provides you high level configuration details regarding fabric switches.

![](./images/Task-7-point-1.png " ")

## Task 8:  Download AHF Insights report to review Insights

1.  Download AHF Insights report zip file.

    ```
    wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/JHSkKXru-WkrhAJj668oXGDLHGncTtuK1_EF40kilttwxMPHg6pDuGXe1CPujYDe/n/idhbogog2wy7/b/ocw24-livelabs/o/node1_insights_2024_05_02_20_44_11_insights.zip
    ```

2.  Extract AHF Insights report zip file.

![](./images/Task-8-point-2.png " ")

3.  Open index.html file on a browser.

## Task 9:  Review *Timeline Section* in Insights

1.  Click on Home tab (*highlighted*) and open timeline section (*highlighted*).
    - Note : Provides you distribution of events that happened across the nodes at different levels of the stack. Moreover these events are also categorized by event type, host and databases.

![](./images/Task-9-point-1.png " ")

2.  Click and drag a section on the chart to zoom into the selected timeframe.

![](./images/Task-9-point-2.png " ")

3.  Double click on the chart to reset the zoom to default period.

![](./images/Task-9-point-3.png " ")

4.  Click on the legend *ERROR* item to disable / enable the events beloning to *ERROR* category.

![](./images/Task-9-point-4.png " ")

5.  Select different timeline views from top right corner of the tab (*highlighted*).

![](./images/Task-9-point-5.png " ")

6.  Scroll down to view the events hapenning in the cluster in a chronological fashion.

![](./images/Task-9-point-6.png " ")

7.  Change the filters to slice and dice the event information.
    - Note : When you change the time selection by clicking and dragging the chart the start and end time in filters change and vice versa.

![](./images/Task-9-point-7.png " ")

8.  Expand the event row by clicking on the arrow (*highlighted*) before the timestamp, to view additional details regarding the event.

![](./images/Task-9-point-8.png " ")

9.  Click copy icon (*highlighted*) to copy the panel data in text format to your clipboard.

![](./images/Task-9-point-9.png " ")

10.  You can post it in your notepad / any other application.

![](./images/Task-9-point-10.png " ")

## Task 10:  Review *Operating System Issues Section* in Insights

1.  TODO
2.  TODO

## Task 11:  Review *Best Practice Issues Section* in Insights

1.  Click on Home tab (*highlighted*) and open Best Practice Issues section (*highlighted*).
    - Note : Provides you information regarding best practice (compliance) violations on your system.

![](./images/Task-11-point-1.png " ")

2.  Observe : High level information regarding the best practice data collection.

![](./images/Task-11-point-2.png " ")

3.  Observe : Chart showcasing health score and check status distribution (*highlighted*).

![](./images/Task-11-point-3.png " ")

4.  Observe : Chart showcasing check status distribution across components and various sections (*highlighted*).

![](./images/Task-11-point-4.png " ")

5.  Click on the legend *PASS* item to disable / enable the checks beloning to *PASS* category.
    - Note : You will observe the difference in the chart and at the bottom you will see PASS checks will appear when the PASS legend is enabled and will disappear when the PASS legend is disabled.

![](./images/Task-11-point-5-passDisabled.png " ")

![](./images/Task-11-point-5-passEnabled.png " ")

6.  Change the filters to slice and dice the best practice check information.

![](./images/Task-11-point-6-1.png " ")

![](./images/Task-11-point-6-2.png " ")

7.  Click on Jump To Section (*highlighted*) to move to a specific cateogry.

![](./images/Task-11-point-7.png " ")

8.  Expand the check row by clicking on the arrow (*highlighted*) before the check status, to view additional what are the benifit / impact of the check on your system and details regarding the target and their corresponding status.

![](./images/Task-11-point-8.png " ")

9.  Expand the target row by clicking on the arrow (*highlighted*) before the target name, to view additional output of the check execution on the system for the given node.

![](./images/Task-11-point-9-1.png " ")

![](./images/Task-11-point-9-2.png " ")

## Task 12:  Review *System Change Section* in Insights

1.  Click on Home tab (*highlighted*) and open System Change section (*highlighted*).
    - Note : Provides you a timeline regarding changes observed on your system in the last 30 days from the following areas : Database Parameter, ASM Parameter, OS Packages, Oracle Software.

![](./images/Task-12-point-1.png " ")

2.  Change the time filters to narrow down changes from the time period of interest.

![](./images/Task-12-point-2-1.png " ")

![](./images/Task-12-point-2-2.png " ")

3.  Select the change categories of interest by select values in System Change Type dropdown (*highlighted*).

![](./images/Task-12-point-3.png " ")

4.  Observe : Every change entry gives information regarding targets on which the change was observed.

## Task 13:  Review *Recommended Software Section* in Insights

1.  Click on Home tab (*highlighted*) and open Recommended Software section (*highlighted*).
    - Note : Provides you details regarding oracle software found on the system and whether there is a recommendation to move to a higher version.

![](./images/Task-13-point-1.png " ")

2.  Found Versions marked in RED color indicate there is a need to move to higher version as suggested in the Recommended Version column.

![](./images/Task-13-point-2.png " ")

3.  Observe : Exadata Database Machine and Exadata Storage Server Supported Versions (Doc ID 888828.1) link provides details on the benifits of moving to the higher versions and the fixes that are available in them.

## Task 14:  Review *Database Server Section* in Insights

1.  Click on Home tab (*highlighted*) and open Database Server section (*highlighted*).
    - Note : Provides you metrics and alerts coming from Management Server, which includes Hardware , Software and ADR alerts.

![](./images/Task-14-point-1.png " ")

2.  Observe : By default you land on the metrics sub tab.

![](./images/Task-14-point-2.png " ")

3.  Select the node of choice from the drop down (*highlighted*) to view relevant metrics.

![](./images/Task-14-point-3.png " ")

4.  Click on the Alerts sub tab to view various stateless alerts coming from management server and their corresponding action.

![](./images/Task-14-point-4.png " ")

5.  Click on the the graph tab (*highlighted*) to view those alerts in graphical fashion.

![](./images/Task-14-point-5.png " ")

6.  Disable switch for show open alerts (*highlighted*) to view cleared alerts as well.

![](./images/Task-14-point-6.png " ")

## Task 15:  Review *RPM List Section* in Insights

1.  Click on Home tab (*highlighted*) and open RPM List section (*highlighted*).
    - Note : Provides you list of RPMs present on nodes of the cluster along with their version release and arch details.

![](./images/Task-15-point-1.png " ")

2.  Search box at the top (*highlighted*) allows you to filter the table deatils based on your input.

![](./images/Task-15-point-2.png " ")

3.  Enable switch Show RPM differences (*highlighted*) to quickly fiure out which rpms are inconsistent across nodes.

## Task 16:  Review *Database Parameters Section* in Insights

1.  Click on Home tab (*highlighted*) and open Database Parameters section (*highlighted*).
    - Note : Provides you list of database parameters along with their values.

![](./images/Task-16-point-1.png " ")

2.  By default you will land into Normal sub tab which provides details regarding regular database parameters.

![](./images/Task-16-point-2.png " ")

3.  Search box at the top (*highlighted*) allows you to filter the table deatils based on your input.

![](./images/Task-16-point-3.png " ")

4.  Click on Hidden sub tab (*highlighted*) to view list of hidden / underscore database parameters.

![](./images/Task-16-point-4.png " ")

## Task 17:  Review *Kernel Parameters Section* in Insights

1.  Click on Home tab (*highlighted*) and open Kernel Parameters section (*highlighted*).
    - Note : Provides you list of kernel parameters along with their values.

![](./images/Task-17-point-1.png " ")

2.  Search box at the top (*highlighted*) allows you to filter the table deatils based on your input.

![](./images/Task-17-point-2.png " ")

## Task 18:  Review *Patch Information Section* in Insights

1.  Click on Home tab (*highlighted*) and open Patch Information section (*highlighted*).
    - Note : Provides you details of patches applied on each node for a given home along with their constituent contents.

![](./images/Task-18-point-1.png " ")

2.  Observe: Home dropdown (*highlighted*) will allow you to select a given home for exploring patch information.

![](./images/Task-18-point-2.png " ")

3.  Observe: Host dropdown (*highlighted*) will allow you to select a given host for exploring patch information.

![](./images/Task-18-point-3.png " ")

4.  By default Patches sub tab (*highlighted*) is selected which allows you to view the patch timeline in graphical and tabular format.
    - Note : Hovering on the graph data points shows you what patch was applied at a given time.

![](./images/Task-18-point-4.png " ")

5.  Exapnd patch row by clicking arrow (*highlighted*) infornt of the applied date to view the constituent of the patch.

![](./images/Task-18-point-5.png " ")

6.  Search box at the top (*highlighted*) allows you to filter the table deatils based on your input once clicked outside the search box.
    - Note : Helps you to search whether a given patch is applied on the system or not.

![](./images/Task-18-point-6.png " ")

7.  Click on Components sub tab to view all the components and their respective version details.

![](./images/Task-18-point-7.png " ")

8.  Search box at the top (*highlighted*) allows you to filter the table deatils based on your input once clicked outside the search box.

![](./images/Task-18-point-8.png " ")

## Task 19:  Review *Space Analysis Section* in Insights

1.  Click on Home tab (*highlighted*) and open Space Analysis section (*highlighted*).
    - Note : Provides you details of disk space utilization and diagnostic space utilization on the system.

![](./images/Task-19-point-1.png " ")

2.  By default Disk Utilization sub tab (*highlighted*) is selected which allows you to view the file system utilization across all nodes of the cluster for an easy comparitive view.

![](./images/Task-19-point-2.png " ")

3.  Observe: Table at the bottom (*highlighted*) provides additional information regarding which mount has Grid Home or Database Homes.

![](./images/Task-19-point-3.png " ")

4.  Observe: The usage column is color coded, green indicating normal usage, orange cautioning warning level usage and red cautioning danger level usage.

![](./images/Task-19-point-4.png " ")

5.  Click on Diagnostic Space Usage sub tab to view space usage under the diagnostic destination on each node.
    - Note : Helps in identifying which directory is consuming lot of space under diag destination.

![](./images/Task-19-point-5.png " ")

6.  By hovering over the graph you would be able to observe space usage over a given directory.

![](./images/Task-19-point-6.png " ")

7.  Table at the bottom allows you to explore the directories in a hierarchial fashion.

![](./images/Task-19-point-7.png " ")

8.  Enable switch for Expand All (*highlighted*) to view the expanded form of the hierarchial directory structure.

![](./images/Task-19-point-8.png " ")

## Task 20:  Review *Database Anomalies Advisor Section* in Insights

1.  Click on Home tab (*highlighted*) and open Database Anomalies Advisor section (*highlighted*).
    - Note : Provides you details of database & clusterware performance anomalies identified by Cluster Health Advisor.

![](./images/Task-20-point-1.png " ")

2.  Observe : Left hand side navigation allows you view summary of performance issues observed during the period of Insights collection. Moreover it also provides you a mechanism to slice and dice performance anomaly information by hosts, databases, instances and individual performance problems.

![](./images/Task-20-point-2.png " ")

3.  Observe : The graph provides you a view of events hapenning across the nodes of the cluster, along with a gantt chart of performance issues observed. There are different targets for which anomalies are observed that are showcased o the legend.

![](./images/Task-20-point-3.png " ")

4.  Double clicking on range issue over gantt chart allows you to drill down into the specific problem and provides you details regarding corresponding metrics that were oberved with anomalous readings.

![](./images/Task-20-point-4-1.png " ")

![](./images/Task-20-point-4-2.png " ")

5. The table at the bottom indicates the description of the problem, it's cause and corresponding action to be taken.

![](./images/Task-20-point-5.png " ")


## Acknowledgements
* **Authors** - Troy Anthony, Bill Burton
* **Contributors** - 
* **Last Updated By/Date** - Bill Burton, July  2024
