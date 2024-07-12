# AHF Insights Commands 

## Introduction
Welcome to the "AHF Insights Commands" lab.

In this lab you will be guided through running commands to generate AHF Insights reports.

Estimated Lab Time: 5 Minutes

### Prerequisites
- You are connected to one of the DB System Nodes as described in Lab 1: Connect to your DB System
- You have performed the tasks to generate some incidents as described in Lab 5: Generate Database and Clusterware Incidents for AHF to Detect and take Action on


## Task 1:  Generate an AHF Insights report
1.  Generate an Insights report for the past four hours
```
<copy>
ahf analysis create --type insights --last 4h
</copy>
```
Command Output:
```
Starting analysis and collecting data for insights
Collecting data for AHF Insights (This may take a few minutes per node)
AHF Insights report is being generated for the last 4h
From Date: &lt;time_stamp&gt; - To Date: &lt;time_stamp&gt;
Report is generated at : <location>
```


You may now *proceed to the next lab*.  

## Acknowledgements
* **Authors** - Troy Anthony, Bill Burton
* **Contributors** - 
* **Last Updated By/Date** - Bill Burton, July  2024
