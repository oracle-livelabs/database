# Introduction

## About this Workshop

Welcome to the Navigating Oracle Database Troubleshooting with Oracle Autonomous Health Framework(AHF) and AHF Insights Workshop!  
This workshop covers the basics of AHF with a guide to where AHF is on your database system, and a taster of the tools it contains. Keep in mind that this is not the complete list of tools, but is just a sample of what AHF can do.

In this workshop you will work on a livelabs sandbox 2-node Oracle Real Application Clusters database in the Oracle Cloud.  
Oracle Cloud Infrastructure offers 2-node RAC DB systems on virtual machines.

For more about Virtual DB systems, click [here](https://docs.cloud.oracle.com/en-us/iaas/Content/Database/Concepts/overview.htm).

You will then download AHF Insights reports to your local system and take a tour on how Insights can help determine your database systems issues.

Estimated Workshop Time:  85 minutes


## About Oracle Autonomous Health Framework (AHF)

Oracle Autonomous Health Framework (AHF) is deployed automatically across various Systems, and all new versions can be downloaded from My Oracle Support(MOS).  
AHF is avilable for all major platforms supported by Oracle Database 19c and above. It is deployed as part of Grid Infrastructure and Oracle Database.

![AHF Deployment](./images/ahfdistro-op.png =40%x*)

AHF is also deployed on all Database Cloud Systems automatically

![AHF Deployment](./images/ahfdistro-cloud.png =40%x*)

The Oracle Autonomous Health Framework product contains a number of integrated proactive and reactive tools that try to help maintain 24x7 availability of cloud and on-premise systems by ensuring compliance to best practice,  monitoring, notifying customers of issues seen and generating diagnostic collections when problems do occur.  AHF goes from telling you how to avoid issues with best practice checking to speeding up logging Support Requests after detecting an issue and gathering the required diagnostics.

![AHF Deployment](./images/ahftools.png =40%x*)

Best Practice Compliance checking is achieved with  Orachk/EXAchk. Cluster and Single System Health Monitoring gathers Operating System level statistics for all the processes on each node and has an analyzer that can be used to determine  possible O/S and or process issues. Database Anomaly detection through Cluster Heath Advisor monitors Database statistics and matches current performance metrics against a model to determine when a database might be about to get in to trouble or already is performing more slowly than is expected. TFA Monitors various sources for detected problems and gathers diagnostics for those problems.  TFA will gather logs, traces, Operating system and Database Cluster Health data as well as compliance data that DBA’s and Support can use to determine the cause of a problem. TFA optionally also sends event details to subscribers for onward notification to Operations and Customers.
Insights brings all that collected data into a dynamic web page that can be viewed in any normal Browser.

![AHF Deployment](./images/ahfflow.png =40%x*)

## About Oracle Autonomous Health Framework Command Line Interface 
As the AHF product evolved various tools that already had their own command line interface were pulled in the AHF.  
There is an ongoing project to pull all of these tools under the single 'ahf' command line interface but as this is not complete you will find throughout this lab that you are asked to use tool specific command line interfaces in a number of cases:-
- `tfactl` - for the Trace File analyzer Collector tool
- `orachk` - for the Orachk tool (best practice compliance)
- `ahfctl` - for some AHF level configuration
- `ahf`    - Where commands are new or have migrated from the above.

## Workshop Objectives
- Connect to a DB System
- Find your way around AHF and check out the AHF DBA Command Line Tools
- Use AHF to detect and triage Incidents
- Gather and Use AHF Insights reports to help determine root cause and resolution for Issues
- Optionally Upgrade AHF to the latest version

## Learn more

### Download AHF from My Oracle Support (MOS)

[Download AHF](https://support.oracle.com/epmos/faces/DocContentDisplay?id=2550798.1)

### Product Documentation

[AHF User Guide](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/)

### Learn how to resolve the following problems with AHF
- [ORA-00600](https://blogs.oracle.com/database/post/ora-00600)
- [ORA-04031](https://blogs.oracle.com/database/post/ora-04031)
- [ORA-04030](https://blogs.oracle.com/database/post/ora-04030)
- [ORA-07445](https://blogs.oracle.com/database/post/ora-07445)
- [Oracle Database Performance Tuning](https://blogs.oracle.com/database/post/database-performance-tuning)  

You may now *proceed to the first lab*.


## Acknowledgements

- **Authors/Contributors** - Troy Anthony, Bill Burton, Gareth Chapman
- **Last Updated By/Date** - Bill Burton, July 2024
