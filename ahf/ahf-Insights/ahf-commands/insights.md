# AHF Insights Commands 

## Introduction

Welcome to the "AHF Insights Commands" lab.

The AHF Insights report pulls togther data from all of the AHF tools to build a free standing dynamic html report  
that provides a 'Birds Eye' view of the system configuration and detected problems.
Insights reports are included in many Automatic and Diagnostic Collections but can also be run on demand at any time.
With Insights you can view:-
- Detected Incidents
- High utilization/Waits for O/S and database resources 
- Your most recent compliance report data.
- Disk and Diagnostic destination Usage
- Much more as we can see in Lab 9


In this lab you will be guided through gathering an on-demand AHF Insights reports.

Estimated Lab Time: 5 Minutes

### Prerequisites
- You are connected to one of the DB System Nodes as described in Lab 1: Connect to your DB System
- You have performed the tasks to generate some incidents as described in Lab 2: Generate some Incidents in RAC Database


## Task 1:  Generate an AHF Insights report
1.  Generate an Insights report for the last hour
```
<copy>
ahf analysis create --type insights --last 1h
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

* **Authors** - Gareth Chapman
* **Contributors** - Troy Anthony, Bill Burton

* **Last Updated By/Date** - Bill Burton, July  2024
