# Switchover and Failover tests while using Global services

Once global service(s) created along with Data guard configuration as per previous lab, now it’s time to run Switchover and Failover tests. Application continuity is expected with zero data loss during Switchover and Failover tests for connections using Global services.

Estimated Time: 20 minutes

### Objectives

In this lab, you will:

* Use DGMGRL to run and verify Switchover and Failover tests.
* Verify "insert record" script runs continuously with zero data loss during Switchover and Failover tests.

### Prerequisites

This lab assumes you have:

* A Free Tier, Paid or LiveLabs Oracle Cloud account
* You have completed:
    * Lab: Validate workshop environment
    * Lab: GDS Installation
    * Lab: Database updates to enable GDS
    * Lab: GDS Configuration using GDSCTL
    * Lab: Prepare a sample Schema and Test Global Service

## 

## Task 1: Prior to perform Switchover from primary to standby, make sure insert_records.sh is running from appclient container

1. From the appclient container, start the test (if not running already, in a different terminal window):

```
<copy>
#from another terminal window
sudo podman exec -i -t appclient /bin/bash
su - oracle
#run the script
./insert_records.sh
</copy>
```

## Task 2: Perform Switchover from primary to standby cdb (sorclcdb)

1. From another terminal window, connect to the primary container to perform Switchover to standby

```
<copy>
sudo podman exec -it primary /bin/bash
dgmgrl
connect sys/Oracle_23ai@primary.example.com:1521/porclcdb
show configuration
switchover to sorclcdb
</copy>
```

2. From appclient container, verify that when Switchover from primary to standby gets started, connection errors occurs:

![Switchover_from_primary_to_standby_started](./images/Switchover_from_primary_to_standby_started.png " ")

    Wait for Switchover completion. It may complete soon but sometimes it may take up to 3 minutes in this liveLab environment. You can monitor from appclient terminal that records started inserting again using new primary which is sorclpdb. After Failover completion, note that HOST_NAME is "standby" as expected.

3. From appclient container, verify Switchover from primary to standby is completed and you see records getting inserted again using new primary cdb (sorclpdb) belongs to standby container:

![Switchover_from_primary_to_standby_completed](./images/Switchover_from_primary_to_standby_completed.png " ")

Look at the value of ID prior to start Switchover and after Switchover completion. ID doesn't skip!. This confirms that Switchover happened with zero data loss.

4. Verify Switchover to standbydb (sorclcdb) is completed.

![verify_Switchover_to_standby_completed](./images/verify_Switchover_to_standby_completed.png " ")

5. Similarly, you can verify from standby container (optional):

```
<copy>
sudo podman exec -it standby /bin/bash
dgmgrl
connect sys/Oracle_23ai@standby.example.com:1521/sorclcdb
show configuration
</copy>
```

![standby_show_configuration_after_Switchover_to_sorclcdb](./images/standby_show_configuration_after_Switchover_to_sorclcdb.png " ")


## Task 3: Perform Failover to current standby database which is primary cdb (porclcdb)

1. Keep the insert script running from the appclient container or it can be started again:

```
<copy>
sudo podman exec -i -t appclient /bin/bash
#run the script
./insert_records.sh
</copy>
```

2. From the another terminal window, connect to primary container (if not already) and perform Failover to current standby CDB (porclcdb):

```
<copy>
sudo podman exec -it primary /bin/bash
dgmgrl
connect sys/Oracle_23ai@primary.example.com:1521/porclcdb
show configuration
failover to PORCLCDB
</copy>
```

3. From the appclient container, verify that "insert\_records.sh" is running during Failover to porclpdb. Prior to Failover completion, note that HOST_NAME is "standby"


![Failover_to_porclcdb_started_when_sorclcdb_is_primary](./images/Failover_to_porclcdb_started_when_sorclcdb_is_primary.png " ")


4. Wait for Failover completion. It may complete soon but sometimes it may take up to 3 minutes in this liveLab environment. You can monitor from appclient terminal that records started inserting again using new primary which is sorclpdb. After Failover completion, note that HOST_NAME is "primary" as expected.

![Failover_to_porclcdb_completed_now_porclcdb_is_primary](./images/Failover_to_porclcdb_completed_now_porclcdb_is_primary.png " ")

5. After Failover completes, confirm from primary container that porclcdb becomes primary again:

```
<copy>
sudo podman exec -it primary /bin/bash
dgmgrl
connect sys/Oracle_23ai@primary.example.com:1521/porclcdb
show configuration
</copy>
```

![dgmgrl_configuration_after_Failover_completion](./images/dgmgrl_configuration_after_Failover_completion.png " ")

Application continues to run from primary.

6. Note that though "insert\_records" application is running while connecting to HOST_NAME "primary" but an error is shown that "The standby database must be reinstated.".
To reinstate standby, you can start the standby database and verify as below:

```
<copy>
sudo podman exec -it standby /bin/bash
sqlplus / as sysdba
startup
show pdbs
</copy>
```

![startup_standby_after_Failover_completed_confirm_read_only](./images/startup_standby_after_Failover_completed_confirm_read_only.png " ")

"OPEN\_MODE" is now "READ ONLY" and this step confirms that "standby" database is in the desired state.

7. Verify from primary container as below:

```
<copy>
sudo podman exec -it primary /bin/bash
dgmgrl
connect sys/Oracle_23ai@primary.example.com:1521/porclcdb
show configuration
</copy>
```

![after_Failover_to_porclcdb_it_becomes_primary_again](./images/after_Failover_to_porclcdb_it_becomes_primary_again.png " ")

This step confirms that "insert\_records" test is running with zero data loss during Switchover or Failover.
Similarly, any other application using global service connections can be verified with zero data loss during Switchover or Failover.

This Completes the GDS introduction LiveLabs.

## Acknowledgements
* **Author** - Ajay Joshi, Distributed Database Product Management
* **Contributors** - Ravi Sharma, Vibhor Sharma, Jyoti Verma, Param Saini, Distributed Database Product Management
* **Last Updated By/Date** - Ajay Joshi, February 2025