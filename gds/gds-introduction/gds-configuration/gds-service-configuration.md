# Oracle GDS Configuration

Once databases are ready to configure with GDS as per previous lab "Database updates for enabling GDS", now its time to configure Oracle GDS for Global services using GDSCTL.

*Estimated Time*:  30 minutes

### Objectives

In this lab, you will:

* Use GDSCTL to configure DBs and GSMs for creating Global services to use by Application.
* Test database connection(s) using global service(s) to verify the GSM configuration.

### Prerequisites

This lab assumes you have:
* A Free Tier, Paid or LiveLabs Oracle Cloud account
* You have completed:
    * Lab: Validate workshop environment
    * Lab: GDS Installation
    * Lab: Database updates to enable GDS

## 
## Task 1: Check the podman container status and connect to gsm1 container

1. Run the below command on terminal window that is logged in as **oracle** user.

```
<copy>
sudo podman ps -a
</copy>
```

![podman containers](images/gds-podman-containers.png " ")

2. From a terminal connect to **GSM1**.

```
<copy>
sudo podman exec -i -t gsm1 /bin/bash
# View the list of hosts and its ip address used in GDS configuration:
cat /etc/hosts
</copy>
```

![podman containers](images/gsm-etc-hosts.png " ")

## Task 2: Configure GDS with Databases, create global service and validation

1. Run the steps as below to configure the GDS for this live lab env:

```
<copy>
gdsctl
set gsm -gsm gsm1
# Check connectivity to primary catalog
connect gsmcatuser/Oracle_23ai@catalog.example.com:1521/CAT1PDB;

# Check connectivity to primary Data DB
connect gsmuser/Oracle_23ai@primary.example.com:1521/ORCLPDB1;

# Check connectivity to standBy Data DB
connect gsmuser/Oracle_23ai@standby.example.com:1521/ORCLPDB1;

# Re-connect to primary catalog since all gdsctl steps must be run using catalog database
connect gsmcatuser/Oracle_23ai@catalog.example.com:1521/CAT1PDB;

configure -driver oci
configure -show

# Create gdscatalog
create gdscatalog -database "(DESCRIPTION=(CONNECT_TIMEOUT=90)(RETRY_COUNT=50)(RETRY_DELAY=3)(TRANSPORT_CONNECT_TIMEOUT=3)(ADDRESS_LIST=(LOAD_BALANCE=ON)(ADDRESS=(PROTOCOL=TCP)(HOST=catalog.example.com)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=CAT1PDB)))" -user gsmcatuser/Oracle_23ai -region region1 -configname gds01 -autovncr off

# Add gsm1
add gsm -gsm gsm1 -catalog "(DESCRIPTION=(CONNECT_TIMEOUT=90)(RETRY_COUNT=50)(RETRY_DELAY=3)(TRANSPORT_CONNECT_TIMEOUT=3)(ADDRESS_LIST=(LOAD_BALANCE=ON)(ADDRESS=(PROTOCOL=TCP)(HOST=catalog.example.com)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=CAT1PDB)))" -region region1 -pwd Oracle_23ai

configure -save_config
start gsm

# For catalog
add invitednode 10.0.20.102
# For primary
add invitednode 10.0.20.103
# For standBy
add invitednode 10.0.20.104

# Verify the list of datbase hosts used in this GDS configuration 
config vncr
#verify that above three ip addresses are listed in the result.
config gsm
# You may have to exit & return to gdsctl before running the next command
exit
gdsctl
status gsm
validate
# expected output "Total errors: 0. Total warnings:4"
config

# 23ai onwards, use add database instead of add brokerconfig for the Primary Database
add database -connect 10.0.20.103:1521/PORCLCDB -region region1 -gdspool dbpoolora -pwd Oracle_23ai -savename

# 23ai onwards, use add database instead of modify database for the StandBy Database to add in brokerconfig
add database -connect 10.0.20.104:1521/SORCLCDB -region region1 -gdspool dbpoolora -pwd Oracle_23ai -savename

# Add Read-Write Service for the Primary Database
add service -gdspool dbpoolora -service gds01_rw_srvc_1 -preferred_all -role primary -pdbname ORCLPDB1
# start Read-Write Service
start service -service gds01_rw_srvc_1

# Add Read-only Service for the Standby Database
add service -gdspool dbpoolora -service gds01_ro_srvc_1 -preferred_all -role physical_standby -pdbname ORCLPDB1
# Start Read-Only Service
start service -service gds01_ro_srvc_1
</copy>
```

2. Verify the GDS configuration from GDSCTL

```
<copy>
status gsm
</copy>
```

![gdsctl status gsm](images/gdsctl_status_gsm.png " ")

```
<copy>
databases
</copy>
```

![gdsctl databases](images/gdsctl_databases.png " ")

```
<copy>
status service
# or 
services
</copy>
```

![gdsctl status service or services](images/gdsctl_status_service_or_services.png " ")

```
<copy>
validate
</copy>
```

![gdsctl validate](images/gdsctl_validate.png " ")

```
<copy>
config
</copy>
```

![gdsctl config](images/gdsctl_config.png " ")

The gdsctl command list can be viewed from gdsctl as below:

```
<copy>
help
</copy>
```

For more details about a specific command, use the format as "gdsctl commandName -help".


## Task 3: Verify Database connections using GDS services

1. Connect READ-WRITE global service using gsm1

```nohighlighting
<copy>
sudo podman exec -i -t gsm1 /bin/bash
# Connect to the global service using sqlplus. Global service connections can be used by the application.
sqlplus gsmuser/Oracle_23ai@gsm1.example.com:1522/gds01_rw_srvc_1.dbpoolora.gds01;
# To exit from gsm1 container and return to opc@oraclegdshost
exit
exit
</copy>
```

2. Connect READ-ONLY global service using gsm1

```nohighlighting
<copy>
sudo podman exec -i -t gsm1 /bin/bash
# Connect to the global service using sqlplus. Global service connections can be used by the application.
sqlplus gsmuser/Oracle_23ai@gsm1.example.com:1522/gds01_ro_srvc_1.dbpoolora.gds01;
# To exit from gsm1 container and return to opc@oraclegdshost
exit
exit
</copy>
```

3. Connect a local service on the catalog DB using gsm1

```nohighlighting
<copy>
sudo podman exec -i -t gsm1 /bin/bash
# Connect to the catalog's local service. Similarly, from any of the podman container gsm services using gsm(s) host can be connected.
sqlplus gsmcatuser/Oracle_23ai@gsm1.example.com:1522/GDS\$CATALOG.gds01;
exit
exit
</copy>
```

Note: Similarly, gsm services can be connected from any of the podman containers e.g. from appclient podman container.

## Task 4: Add gsm2 to GDS configuration (Optional)

If you have already installed GDS on gsm2 container (as described in the Task 5 of Lab "GDS Install"), you can add gsm2 to this GDS configuration.

```nohighlighting
<copy>
# Connect to the gsm2 podman container:
sudo podman exec -i -t gsm2 /bin/bash
gdsctl
set gsm -gsm gsm2
add gsm -gsm gsm2 -catalog "(DESCRIPTION=(CONNECT_TIMEOUT=90)(RETRY_COUNT=50)(RETRY_DELAY=3)(TRANSPORT_CONNECT_TIMEOUT=3)(ADDRESS_LIST=(LOAD_BALANCE=ON)(ADDRESS=(PROTOCOL=TCP)(HOST=catalog.example.com)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=CAT1PDB)))" -region region1 -pwd Oracle_23ai
configure -save_config
start gsm
# To see GDS configuration with both gsm1 and gsm2, check it as below:
config gsm
config
exit
</copy>
```

![ggdsctl config after adding gsm2](images/gdsctl_config_after_adding_gsm2.png " ")

This completes GDS configuration tasks and its verification by database connection(s) created using Global service(s).

You may now **proceed to the next lab**.

## Acknowledgements
* **Author** - Ajay Joshi, Distributed Database Product Management
* **Contributors** - Ravi Sharma, Vibhor Sharma, Jyoti Verma, Param Saini, Distributed Database Product Management
* **Last Updated By/Date** - Ajay Joshi, February 2025