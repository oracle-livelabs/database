# AHF Common Commands 

## Introduction

Welcome to the "Try out some commonly used AHF commands" lab.

In this lab you will be guided through various common AHF tasks.

Estimated Lab Time: 5 Minutes

### Prerequisites
- You are connected to one of the DB System Nodes as described in Lab 1: Connect to your DB System
- You have performed the tasks to generate some incidents as described in Lab 5: Generate Database and Clusterware Incidents for AHF to Detect and take Action on


## Task 1: Common post installation configuration tasks

1. Configure notification of compliance results and critical event notification:

    After configuring and email address for notifications you will receive Orachk/Exachk reports to that address and notification of any  
    automatic diagnostic collections that are completed.
    ```
    <copy>
    ahfctl set ahfNotificationAddress=some.body@example.com
    </copy>
    ```
    >Note: You may also need to set up smtp server 

2. Configure MOS (My Oracle Support) upload:

    Once you have configured an upload name for MOS upload you can use that to upload a manual diagnostic collection to a specific SR
    ```
    <copy>
    ahfctl setupload –name mos_config –type https –url https://transport.oracle.com/upload/issue -proxy www-proxy.acme.com:80 -user john.doe@acme.com -password
    </copy>
    ```
    > You can now add the **-upload mos_config -sr <mysrnumber>** to a `tfactl diagcollect` command to upload the collection directly upon completion.
    

3. Configure Auto Upgrade:
    ```
    <copy>
    ahfctl setupgrade –swstage /mysharedlocation/ahf_upgrade –autoupgrade on –frequency 30 –upgradetime 00:15
    </copy>
    ```

4. Configure storage cells for diagnostic collections and compliance checks
    ```
    <copy>
    tfactl cell configure
    </copy>
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
    ```
    <copy>
    ahfctl compliance -profile dba
    </copy>
    ```

You may now *proceed to the next lab*.  

## Acknowledgements
* **Authors** - Bill Burton
* **Contributors** - Troy Anthony, Gareth Chapman
* **Last Updated By/Date** - Bill Burton, July  2024
