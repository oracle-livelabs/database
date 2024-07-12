# AHF Common Commands 

## Introduction
Welcome to the "Try out some commonly used AHF commands" lab.

In this lab you will be guided through various common AHF tasks.

Estimated Lab Time: 20 Minutes

### Prerequisites
- You are connected to one of the DB System Nodes as described in Lab 1: Connect to your DB System
- You have performed the tasks to generate some incidents as described in Lab 5: Generate Database and Clusterware Incidents for AHF to Detect and take Action on


## Task 1: Common post installation configuration tasks

1. Configure notification of compliance results and critical event notification:
    ```
    <copy>
    ahfctl set ahfNotificationAddress=some.body@example.com
    </copy>
    ```

2. Configure MOS (My Oracle Support) upload:
    ```
    <copy>
    ahfctl setupload –name mos_config –type https –url https://transport.oracle.com/upload/issue -proxy www-proxy.acme.com:80 -user john.doe@acme.com -password
    </copy>
    ```

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
    ```
    <copy>
    ahfctl getresourcelimit
    </copy>
    ```

2. Check TFA service status
    ```
    <copy>
    systemctl status oracle-tfa
    </copy>
    ```

## Task 3: Proactively run health checks

1. Change critical checks to run at 8am every Monday and Thursday:
    ```
    <copy>
    ahfctl compliance –id exachk.autostart_client_exatier1 –set “AUTORUN_SCHEDULE=* 8 * * 1,4”
    </copy>
    ```

2. Run compliance checks on-demand for only the Database Administrator (DBA) Checks.
    ```
    <copy>
    ahfctl compliance -profile dba
    </copy>
    ```

## Task 4: Generate or find already existing diagnostics when there is a problem

1. Check if any diagnostic collections were generated in the last 2 days:
    ```
    <copy>
    tfactl print collections –last 2 d
    </copy>
    ```

2. Configure automatic problem notification:
    ```
    <copy>
    ahfctl set ahfNotificationAddress=some.body@example.com
    </copy>
    ```

3. Generate a diagnostic collection for ORA-04031:
    ```
    <copy>
    tfactl diagcollect –srdc ORA-04031
    </copy>
    ```
    - When prompted for the time of the ORA-04031, leave it blank and press return
    - When prompted for the Database name enter:
        ```
        <copy>
        racUXBVI1
        </copy>
        ```

4. Generate a diagnostic collection using the Smart Problem Classification
   ```
    <copy>
    tfactl diagcollect
    </copy>
    ```
    - When prompted, choose any of the identified events and follow the instructions.


You may now *proceed to the next lab*.  

## Acknowledgements
* **Authors** - Troy Anthony, Bill Burton
* **Contributors** - 
* **Last Updated By/Date** - Bill Burton, July  2024
