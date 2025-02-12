# Database updates for enabling GDS

Database(s) needs to be GDS enabled before configuring GDS using GDSCTL. In this lab, we'll run the shell scripts which has the SQL commands for database configurations.
*Estimated Time*:  15 minutes

### Objectives

In this lab, you will:

* Configure each Database for commands to be run using sysdba.
* Verify Database are ready, so that we can start GDS configuration using GDSCTL in the next lab.
### Prerequisites
This lab assumes you have:
* A Free Tier, Paid or LiveLabs Oracle Cloud account
* You have completed:
    * Lab: Validate workshop environment
    * Lab: GDS Installation

##
## Task 1: Connect to Podman instance of Catalog Primary DB

1. Apply Database Configuration for Catalog which will be used in "create gdscatalog.." at the later stage from gsm1 to apply GDS configuration steps.

You will run "configure_catalog.sh" which mainly:
*   Unlocks GSMCATUSER on both CDB and PDB of the catalog database.
*   Enables ARCHIVELOG, FLASHBACK, and FORCE LOGGING if not enabled.
*   Restarts database in READ WRITE mode.

```
<copy>
sudo podman exec -it catalog /bin/bash
# View the contents of "configure_catalog.sh". This file doesn't need any updates for this LiveLab task.
cat configure_catalog.sh

# Run the script
./configure_catalog.sh
exit
</copy>
```

## Task 2: Connect to Podman instance of Primary Database for Application

1. Prepare Primary Database for the application. This primary database will be used in "add database" at later stage from gsm1 to apply GDS configuration steps.

You will run "configure_primary.sh" which mainly:
*   Unlocks GSMUSER on both CDB and PDB of the primary database.
*   Unlocks GSMROOTUSER on CDB only of the primary database.
*   Enables ARCHIVELOG, FLASHBACK, and FORCE LOGGING if not enabled.
*   Restarts database in READ WRITE mode.

```
<copy>
sudo podman exec -it primary /bin/bash
# View the contents of "configure_primary.sh". This file doesn't need updates for this LiveLab task.
cat configure_primary.sh

# Run the script
./configure_primary.sh
exit
</copy>
```

## Task 3: Connection to Podman instance of StandBy Database for Application Data

1. Though no updates needed at this time for the standby database, you can still verify its PDB is in READ ONLY mode.

```nohighlighting
<copy>
sudo podman exec -it standby /bin/bash
# Login as sysDBA and Verify that PDBs are in READ ONLY OPEN MODE 
sqlplus / as sysdba;
show pdbs;
select open_mode from v$database;
# To exit from standby container and return to opc@oraclegdshost
exit
exit
</copy>
```

![standby-verify](./images/standby-verify.png " ")

This completes database tasks.

Note: Review the contents of each of the database scripts to get familiar with the necessary steps needed prior to GDSCTL configuration steps.

Since You have installed GSM already, now you can perform the next Lab **GDS Configuration using GDSCTL**

You may now **proceed to the next lab**

## Acknowledgements
* **Author** - Ajay Joshi, Distributed Database Product Management
* **Contributors** - Ravi Sharma, Vibhor Sharma, Jyoti Verma, Param Saini, Distributed Database Product Management
* **Last Updated By/Date** - Ajay Joshi, February 2025