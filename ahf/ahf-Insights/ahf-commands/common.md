# AHF Common Commands 

## Introduction

Welcome to the "Try out some commonly used AHF commands" lab.

In this lab you will be guided through various common AHF tasks.

Estimated Lab Time: 5 Minutes

### Prerequisites
- You are connected to one of the DB System Nodes as described in Lab 1: Connect to your DB System
- You have performed the tasks to generate some incidents as described in Lab 3: Generate Database and Clusterware Incidents for AHF to Detect and take Action on


## Task 1: Common post installation configuration tasks

>Note: These commands are provided for reference and *should not be* attempted in the lab.

1. Configure notification of compliance results and critical event notification:

    After configuring and email address for notifications you will receive Orachk/Exachk reports to that address and notification of any  
    automatic diagnostic collections that are completed.
    ```
    ahfctl set ahfNotificationAddress=some.body@example.com
    ```
    >Note: You may also need to set up smtp server depending on your system configuration

2. Configure MOS (My Oracle Support) upload:

    Once you have configured an upload name for MOS upload you can use that to upload a manual diagnostic collection to a specific SR
    ```
    ahfctl setupload –name mos_config –type https –url https://transport.oracle.com/upload/issue -proxy www-proxy.acme.com:80 -user john.doe@acme.com -password
    ```
    > You could now add the **-upload mos_config -sr <mysrnumber>** to a `tfactl diagcollect` command to upload the collection directly upon completion.
    

3. Configure Auto Upgrade:
    As noted in Lab 2 you can set a software stage directory where AHF will look for new versions to upgrade to.
    ```
    ahfctl setupgrade –swstage /mysharedlocation/ahf_upgrade –autoupgrade on –frequency 30 –upgradetime 00:15
    ```

4. Configure storage cells for diagnostic collections and compliance checks. 
> Note: This will only work on Exadata Systems which is not available in this Live Labs set up.
    ```
    tfactl cell configure
    ```

## Task 2: Check resource limits

1. Check AHF resource limits

    On Linux systems AHF can restrict the CPU and Memory usage of the TFAMain process and it's children using `cgroups`  
    You can check the limits using:-
    ```
    <copy>
    ahfctl getresourcelimit
    </copy>
    ```

## Task 3: Proactively run health checks

1. Change critical checks to run at 8am every Monday and Thursday:
    As previously noted AHF sets up some default compliance run schedules.
    You can change these with `ahfctl compliance`
    ```
    <copy>
    ahfctl compliance –id exachk.autostart_client_exatier1 –set “AUTORUN_SCHEDULE=* 8 * * 1,4”
    </copy>
    ```

2. Run compliance checks on-demand for only the Database Administrator (DBA) Checks.
    Compliance can also be run on demand with `ahfctl compliance`

> Note: This command can take a number of minutes to run so you might want to come back to these given time at the end.

    ```
    <copy>
    ahfctl compliance -profile dba
    </copy>
    ```

## Task 4: Check out some of the AHF DBA tools

When a problem occurs in one of your normally stable database systems the first question you ask is 'What has changed ?'.
AHF keeps track of changes and Events on the system and provides a simple command line interface to view those.
The Insights report will bring all this information in to a dynamic html report which can easily be viewed to help with problem diagnosis.

1. See what has changed in the system in the last hour
    ```
    <copy>
    tfactl changes -last 1h
    </copy>
    ```
    Command Output:
    <pre>
    Generating System Changes From 07/22/2024 21:09:52.809 To 07/22/2024 22:09:52.813

    Snapshot Timestamp for Changes:2024-07-22 22:09:52.000000
    Duration for Changes: 1 Hours

    Change Records for host: lldbcs61 
    =================================
    [2024-07-22 21:12:50.000000]: [ raclzhlm_dhh_bom: racLZHLM1]: Database Parameter optimizer_use_sql_plan_baselines Changed From FALSE To TRUE
    [2024-07-22 21:15:01.000000]: [ raclzhlm_dhh_bom: racLZHLM1]: Database Parameter optimizer_use_sql_plan_baselines Changed From TRUE To FALSE
    [2024-07-22 21:19:10.000000]: [ raclzhlm_dhh_bom: racLZHLM1]: Database Parameter parallel_threads_per_cpu Changed From 2 To 4

    Change Records for host: lldbcs62 
    =================================
    No Changes Found
    </pre>

2. Check the values for some database init parameters across your databases
    ```
    <copy>
    tfactl param -parameter pga
    </copy>
    ```
    Command Output:
    <pre>
    .----------------------------------------------------------------------------------------------.
    | Database Parameters                                                                          |
    +------------------+--------------------------------+-----------+----------------------+-------+
    | DATABASE         | HOST                           | INSTANCE  | PARAM                | VALUE |
    +------------------+--------------------------------+-----------+----------------------+-------+
    | raclzhlm_dhh_bom | lldbcs62                       | racLZHLM2 | pga_aggregate_limit  | 6912M |
    | raclzhlm_dhh_bom | lldbcs62                       | racLZHLM2 | pga_aggregate_target | 3456M |
    | raclzhlm_dhh_bom | lldbcs61                       | racLZHLM1 | pga_aggregate_target | 3456M |
    | raclzhlm_dhh_bom | lldbcs61                       | racLZHLM1 | pga_aggregate_limit  | 6912M |
    '------------------+--------------------------------+-----------+----------------------+-------'
    </pre>
    >Note: The parameter option can take a partial string but AHF only knows about parameters that are set at Database startup or are changed from default.

You may now *proceed to the next lab*.  

## Acknowledgements
* **Authors** - Bill Burton
* **Contributors** - Troy Anthony, Gareth Chapman
* **Last Updated By/Date** - Bill Burton, July  2024
