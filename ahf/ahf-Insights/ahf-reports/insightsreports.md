
# AHF Insights Review

## Introduction

This lab will show you how to use AHF Insights reports to help diagnose problems.

Estimated Lab Time: 40 Minutes

### Objectives
- Get a bird's eye view of your database system from diagnostic perspective
- Troubleshoot problems on your database system
- Leverage AHF Insights to resolve identified problems

### Prerequisites
- System which allows downloading files using *wget* command
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

    Paste the following URL in to your browser of choice to download to you local system

    ```
    <copy>
    https://objectstorage.us-ashburn-1.oraclecloud.com/p/1fl26UQZiAjg7vCEP9K0kMJ3bhpdc-cQTWKYl9g08VJMCXZr0pi46xQgUxfe2VBx/n/idhbogog2wy7/b/ocw24-livelabs/o/node1_insights_2024_07_10_23_30_54_system_topology.zip
    </copy>
    ```
2. Navigate to the Download location for you browser

3.  Extract AHF Insights report zip file.

![](./images/Task-1-point-2.png " ")

4.  Open index.html file on a browser.

## Task 2:  Review parts of AHF Insights report

![](./images/Task-1-point-1.png " ")

1.  Top right corner (*highlighted above*) indicates AHF Version, System Type and Time Range of AHF Insights report collection.
2.  First row (*highlighted above*) shows topology of the system from where AHF Insights report was generated.
3.  Second row (*highlighted above*) shows insights available from the system from various dimensions of diagnostics.

## Task 3:  Review *Cluster Section* in System Topology

1.  On Home tab click on the *Cluster Section*

![](./images/Task-3-point-1.png " ")

2.  *Cluster Summary* sub tab gives you high level details regarding the cluster.

![](./images/Task-3-point-2.png " ")

3.  Click copy icon (*highlighted above*) to copy the panel data in text format to your clipboard.
4.  You can post it in your notepad / any other application.

![](./images/Task-3-point-4.png " ")

5.  *Cluster Resources* sub tab gives you details of clusterware managed resources and their state.
    - Note : You can *Expand* each resource to check details and can also make use of *Expand All* switch to view/hide them all

![](./images/Task-3-point-5.png " ")

6.  *ASM Details* sub tab gives you ASM Instance and Disk group details.

![](./images/Task-3-point-6.png " ")

    

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

    Paste the following URL in to your browser of choice to download to you local system

    ```
    <copy>
    https://objectstorage.us-ashburn-1.oraclecloud.com/p/JHSkKXru-WkrhAJj668oXGDLHGncTtuK1_EF40kilttwxMPHg6pDuGXe1CPujYDe/n/idhbogog2wy7/b/ocw24-livelabs/o/node1_insights_2024_05_02_20_44_11_insights.zip
    </copy>
    ```
2.  Navigate to the Download location for you browser

3.  Extract AHF Insights report zip file.

![](./images/Task-8-point-2.png " ")

4.  Open index.html file on a browser.

## Task 9:  Review *Timeline Section* in Insights

1.  Click on Home tab (*highlighted*) and open timeline section (*highlighted*).
    - Note : Provides you distribution of events that happened across the nodes at different levels of the stack. Moreover these events are also categorized by event type, host and databases.

![](./images/Task-9-point-1.png " ")

2.  Click and drag a section on the chart to zoom into the selected time-frame.

![](./images/Task-9-point-2.png " ")

3.  Double click on the chart to reset the zoom to default period.

![](./images/Task-9-point-3.png " ")

4.  Click on the legend *ERROR* item to disable / enable the events belonging to *ERROR* category.

![](./images/Task-9-point-4.png " ")

5.  Select different timeline views from top right corner of the tab (*highlighted*).

![](./images/Task-9-point-5.png " ")

6.  Scroll down to view the events happening in the cluster in a chronological fashion.

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

1.  Click on Home tab (*highlighted*) and open Operating System Issues section (*highlighted*).
    - Note : Provides you information regarding operating system issues observed on your system during the period of Insights report.

![](./images/Task-10-point-1.png " ")

2.  By default you will land into Report sub tab (*highlighted*), if there are OS issues observed.
    - Note : Report sub tab shows you an overall OS issue summary on the first accordion and all the constituent issues observed as individual accordions.

![](./images/Task-10-point-2.png " ")

3.  Click on Summary accordion to open it.

![](./images/Task-10-point-3.png " ")

4.  Observe : High level timeline, with OS findings and event detected on the system at the bottom. The graph allows you to zoom into specific areas of interest.

![](./images/Task-10-point-4-1.png " ")

![](./images/Task-10-point-4-2.png " ")

5.  Scroll down and click on High Swap Activity (*highlighted*) accordion, to observe the swap activity issue observed on the system.

![](./images/Task-10-point-5.png " ")

6.  Scroll down and you would be able to view high level contextual statistics regarding the issue as well as a tabular format of OS snapshots during the time of issue.

![](./images/Task-10-point-6.png " ")

7.  Click on the arrow before Timestamp (*highlighted*) to view further metrics during a given snapshot.

![](./images/Task-10-point-7.png " ")

8.  Scroll to top, Click on Configuration sub tab.
    - Note : Provides you high level configuration details for CPU, Memory, Network and IO.

![](./images/Task-10-point-8.png " ")

9.  Click on Metric sub tab to view raw, issue annotated operating system metrics.
    - Note : Metrics are categorized into following sections, System Overview - Showcases major metrics one would always want to know about from operating system for issue triage, next category of metrics are based on areas which as CPU, Memory, Local IO, Process, Network, Process Aggregation.
    - Note : Red / Green color markings near the sub tab indicates whether a given area has any anomalies or not. Red - Anomalies, Green - No Anomalies.

![](./images/Task-10-point-9.png " ")

10. Observe : By default Node selection would be set to Cluster-wide (*highlighted*), which showcases metrics from all nodes together on the chart with different colors.

![](./images/Task-10-point-10.png " ")

11. Observe : Click and drag an area of interest on any chart, all charts would synchronize to that selection which provides easy mechanism to compare same time frames. 

![](./images/Task-10-point-11-1.png " ")

![](./images/Task-10-point-11-2.png " ")

12. Use legend to select / de-select node metrics.
    - Note : X mark on the legend indicates that there are metrics which have anomalies on the given charts.

![](./images/Task-10-point-12.png " ")

13. Observe : Once you drag the area around the spike in Blocked Process Count chart (*highlighted*), you will observe shaded region on it as well as other charts which have anomalies in the same period like Available Memory Low, Huge Page Utilization and Swap In Rate.

![](./images/Task-10-point-13-1.png " ")

![](./images/Task-10-point-13-2.png " ")

14. Click on CPU sub tab (*highlighted*) to view CPU Metrics.

![](./images/Task-10-point-14.png " ")

15. Click on Memory sub tab (*highlighted*) to view Memory Metrics.

![](./images/Task-10-point-15.png " ")

16. Click on Local IO sub tab (*highlighted*) to view Local IO Metrics.
    - Note : Local IO has two sub tabs, System IO which provide high level IO Read, IO Write and IO Rate, whereas Disk sub tab allows you to select a given node and view all disk related metrics on that given node.

![](./images/Task-10-point-16.png " ")

17. Click on Disk sub tab (*highlighted*), select a node to view all disk metrics.

![](./images/Task-10-point-17-1.png " ")

![](./images/Task-10-point-17-2.png " ")

18. To view a specific disk double click on the disk name on the legend.

![](./images/Task-10-point-18.png " ")

19. Click on Process sub tab (*highlighted*) to view Process metrics.

![](./images/Task-10-point-19.png " ")

20. Click on Network sub tab (*highlighted*) to view Network metrics.

![](./images/Task-10-point-20.png " ")

21. Network metrics are categorized under Aggregated NICS metrics, NICS - Provides Host Level NIC metrics, IP, UDP and TCP.

![](./images/Task-10-point-21.png " ")

22. Click on Process Aggregation sub tab (*highlighted*) and select node (*highlighted*) to view how a group of processes, belonging to a given category are behaving.

![](./images/Task-10-point-22-1.png " ")

![](./images/Task-10-point-22-2.png " ")

23. Observe : The column name indicates the metric name and the categories of chart underneath indicates group of processes. i.e. Clusterware, ASM, Apex, Database SIDs, Others.
    - Note : Same charting features for zooming in, panning etc would apply.

![](./images/Task-10-point-23.png " ")

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

5.  Click on the legend *PASS* item to disable / enable the checks belonging to *PASS* category.
    - Note : You will observe the difference in the chart and at the bottom you will see PASS checks will appear when the PASS legend is enabled and will disappear when the PASS legend is disabled.

![](./images/Task-11-point-5-passDisabled.png " ")

![](./images/Task-11-point-5-passEnabled.png " ")

6.  Change the filters to slice and dice the best practice check information.

![](./images/Task-11-point-6-1.png " ")

![](./images/Task-11-point-6-2.png " ")

7.  Click on Jump To Section (*highlighted*) to move to a specific category.

![](./images/Task-11-point-7.png " ")

8.  Expand the check row by clicking on the arrow (*highlighted*) before the check status, to view additional what are the benefit / impact of the check on your system and details regarding the target and their corresponding status.

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

3.  Observe : Exadata Database Machine and Exadata Storage Server Supported Versions (Doc ID 888828.1) link provides details on the benefits of moving to the higher versions and the fixes that are available in them.

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

2.  Search box at the top (*highlighted*) allows you to filter the table details based on your input.

![](./images/Task-15-point-2.png " ")

3.  Enable switch Show RPM differences (*highlighted*) to quickly figure out which rpms are inconsistent across nodes.

![](./images/Task-15-point-3.png " ")

## Task 16:  Review *Database Parameters Section* in Insights

1.  Click on Home tab (*highlighted*) and open Database Parameters section (*highlighted*).
    - Note : Provides you list of database parameters along with their values.

![](./images/Task-16-point-1.png " ")

2.  By default you will land into Normal sub tab which provides details regarding regular database parameters.

![](./images/Task-16-point-2.png " ")

3.  Search box at the top (*highlighted*) allows you to filter the table details based on your input.

![](./images/Task-16-point-3.png " ")

4.  Click on Hidden sub tab (*highlighted*) to view list of hidden / underscore database parameters.

![](./images/Task-16-point-4.png " ")

## Task 17:  Review *Kernel Parameters Section* in Insights

1.  Click on Home tab (*highlighted*) and open Kernel Parameters section (*highlighted*).
    - Note : Provides you list of kernel parameters along with their values.

![](./images/Task-17-point-1.png " ")

2.  Search box at the top (*highlighted*) allows you to filter the table details based on your input.

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

5.  Expand patch row by clicking arrow (*highlighted*) in front of the applied date to view the constituent of the patch.

![](./images/Task-18-point-5.png " ")

6.  Search box at the top (*highlighted*) allows you to filter the table details based on your input once clicked outside the search box.
    - Note : Helps you to search whether a given patch is applied on the system or not.

![](./images/Task-18-point-6.png " ")

7.  Click on Components sub tab to view all the components and their respective version details.

![](./images/Task-18-point-7.png " ")

8.  Search box at the top (*highlighted*) allows you to filter the table details based on your input once clicked outside the search box.

![](./images/Task-18-point-8.png " ")

## Task 19:  Review *Space Analysis Section* in Insights

1.  Click on Home tab (*highlighted*) and open Space Analysis section (*highlighted*).
    - Note : Provides you details of disk space utilization and diagnostic space utilization on the system.

![](./images/Task-19-point-1.png " ")

2.  By default Disk Utilization sub tab (*highlighted*) is selected which allows you to view the file system utilization across all nodes of the cluster for an easy comparative view.

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

2.  Observe : Left hand side navigation (*highlighted*) allows you view summary of performance issues observed during the period of Insights collection. Moreover it also provides you a mechanism to slice and dice performance anomaly information by hosts, databases, instances and individual performance problems.

![](./images/Task-20-point-2.png " ")

3.  Observe : The graph provides you a view of events happening across the nodes of the cluster, along with a gantt chart of performance issues observed. There are different targets for which anomalies are observed that are showcased on the legend. At the bottom you will find a table summarizing Host and Instance problem summary with details of the problem and targets they are affecting.

![](./images/Task-20-point-3-1.png " ")

![](./images/Task-20-point-3-2.png " ")

![](./images/Task-20-point-3-3.png " ")

4.  Double clicking on range issue over gantt chart allows you to drill down into the specific problem and provides you details regarding corresponding metrics that were observed with anomalous readings.

![](./images/Task-20-point-4-1.png " ")

![](./images/Task-20-point-4-2.png " ")

5. The table at the bottom indicates the description of the problem, it's cause and corresponding action to be taken.

![](./images/Task-20-point-5.png " ")


## Task 21:  Review *Detected Problem Section* in Insights

1.  Click on Home tab (*highlighted*) and open Detected Problem section (*highlighted*).
    - Note : Provides you details of problems that have been observed on the system with it's reason, cause and evidences. Moreover it would also provide problem resolution steps.

![](./images/Task-21-point-1.png " ")

2.  Observe : Detected Problems panel indicate the list of problems observed in chronological order.

![](./images/Task-21-point-2.png " ")

3.  Click on show button (*highlighted*) to view further details for this problem and steps to resolve it.

![](./images/Task-21-point-3.png " ")

4.  New tab with the problem name would open up, which would contain all the problem details.

![](./images/Task-21-point-4.png " ")

5. Observe : the evidence area, you can get all supporting details of an evidence by clicking the arrow (*highlighted*).

![](./images/Task-21-point-5.png " ")

6. Observe : the resolution steps area, you will get guided steps to resolve the issue.

![](./images/Task-21-point-6.png " ")

You may now [proceed to the next lab](#next).
## Acknowledgements
* **Authors** - Troy Anthony, Bill Burton, Arjun Upadhyay
* **Contributors** - Arlet Diaz
* **Last Updated By/Date** - Bill Burton, July  2024
