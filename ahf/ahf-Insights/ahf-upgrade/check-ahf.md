# Check Oracle AHF Installation and Health

## Introduction

Welcome to the "AHF Installation and Health Check" lab.  In this lab you will learn how to check the location of AHF executables, data, and diagnostics.  
You will be guided to detemine these locations and review their contents. 
Once you know the geography of AHF you will check for running processes and Health.

Estimated Time: 5 minutes

### Objectives

In this lab, you will:
* Determine the location of the AHF install.proerties file
* Use this file to review the various code and data locations
* Check that the AHF processes are running
* Confirm the health of AHF on the System

### Prerequisites
- You are connected to one of the DB System Nodes as described in **Lab 1: Connect to your DB System**
- You are logged in as the **root user**

## Task 1: Determine the location of the AHF Installation
1.	Check the contents of the `/etc/oracle.ahf.loc` file 

	```
	<copy>
	cat /etc/oracle.ahf.loc
	</copy>
	```
	Command Output:
	`/u01/app/oracle.ahf` #TODO check this on env

2.	Use this location to check the contents of the AHF install.properties file

	```
	<copy>
	cat /u01/app/oracle.ahf/install.properties
	</copy>
	```
	Command Output:
	```
	# cat /u01/app/oracle.ahf/install.properties 
	AHF_HOME=/u01/app/oracle.ahf
	BUILD_VERSION=2402000
	BUILD_DATE=202402092108
	PREV_BUILD_VR=2401000
	INSTALL_TYPE=TYPICAL
	CRS_HOME=/u01/app/19.0.0.0/grid
	TFA_HOME=/u01/app/oracle.ahf/tfa
	ORACHK_HOME=/u01/app/oracle.ahf/orachk
	DATA_DIR=/u01/app/oracle.ahf/data
	AHF_DIR=/u01/app/oracle.ahf/ahf
	TFA_DATA_DIR=/u01/app/oracle.ahf/data/ahfdbcs61/tfa
	ORACHK_DATA_DIR=/u01/app/oracle.ahf/data/ahfdbcs61/orachk
	REPOSITORY=/u01/app/oracle.ahf/data/repository
	WORK_DIR=/u01/app/oracle.ahf/data/work
	DIAG_DIR=/u01/app/oracle.ahf/data/ahfdbcs61/diag
	TFA_DIAG_DIR=/u01/app/oracle.ahf/data/ahfdbcs61/diag/tfa
	ORACHK_DIAG_DIR=/u01/app/oracle.ahf/data/ahfdbcs61/diag/orachk
	COMMON_DATA_DIR=/u01/app/oracle.ahf/data/ahfdbcs61/common
	COMMON_DIR=/u01/app/oracle.ahf/common
	JLIB_DIR=/u01/app/oracle.ahf/common/jlib
	ACR_DIR=/u01/app/oracle.ahf/common/acr
	JAVA_HOME=/u01/app/oracle.ahf/jre
	PYTHON_HOME=/u01/app/oracle.ahf/common/venv
	AHF_EMAIL=
	INSTALL_USER=root
	ENV_TYPE=DBCS
	CVU_LOC=/u01/app/oracle.ahf/common/cvu
	PERL=/bin/perl
	SI_ENV=0
	DATABASE_CLIENT_DIR=/u01/app/19.0.0.0/grid
	```
	Interesting Entries:
	- All the AHF Code can be found under the **AHF\_HOME** location
	- All output from AHF tools can be found under the **DATA\_DIR** location which may not be under the **AHF\_HOME**
	- Each tool has it's own DATA location such as **TFA\_DATA\_DIR**
	- All tools write their diagnostics to **DIAG\_DIR**
	- Each tool has it's own DIAG location such as **ORACHK\_DIAG_DIR**
	- The **REPOSITORY** is the location that will be used for diagnotic collections

	Note: The AHF Command Line Interfaces `ahfctl`, `tfactl`, `orachk`, `ahf` are all linked 

## Task 2: Check the Availability of the AHF Command Line Interfaces
The AHF Command Line Interfaces `ahfctl`, `tfactl`, `orachk`, `ahf` are all linked to the `/usr/bin` directory.

1. Check that the "ahf" Command Line Interface is available in your PATH.

	```
	<copy>
	which ahf
	</copy>
	```
	Command output:  
	```
	/usr/bin/ahf
	```
2. Check that the "tfactl" Command Line Interface is available in your PATH.
	```
	<copy>
	which tfactl
	</copy>
	```
	
	Command output:  
	```
	/usr/bin/tfactl
	```
3. Check that the "ahfctl" Command Line Interface is available in your PATH.
	```
	<copy>
	which ahfctl
	</copy>
	```
	
	Command output:  
	```
	/usr/bin/ahfctl
	```
4. Check that the "orachk" Command Line Interface is available in your PATH.
	```
	<copy>
	which orachk
	</copy>
	```
	Command output:  
	```
	/usr/bin/orachk
	```

	If any of these are not available that means there was an Issue with AHF Installation that needs to be investigated


## Task 3: Check the Version, Status and Health of AHF

1.	Use the **ahf** CLI to check the software version

	```
	<copy>
	ahf software get-version --component all
	</copy>
	```

	Command output:
	```
	AHF version: 24.2.0
	Build Timestamp: FixMe
	TFA version: 24.2.0
	Compliance version: 24.2.0
	Compliance metadata version: FixMe
	```

2.	Use the **tfactl** CLI to check whether the TFA Daemon processes are running on all nodes.

	The process TFAMAin runs on each node of the cluster and these processes communicate to synchroinize monitoring and  
	diagnostic collection operations.  The Process also has a scheduler to run other tools such as **orachk**.  
	```
	<copy>
	tfactl print status
	</copy>
	```
	Command output:
	```
	.--------------------------------------------------------------------------------------------------.
	| Host      | Status of TFA | PID   | Port | Version    | Build ID              | Inventory Status |
	+-----------+---------------+-------+------+------------+-----------------------+------------------+
	| ahfdbcs61 | RUNNING       | 86200 | 5000 | 24.2.0.0.0 | FixMe                 | COMPLETE         |
	| ahfdbcs62 | RUNNING       | 91603 | 5000 | 24.2.0.0.0 | FixMe                 | COMPLETE         |
	'-----------+---------------+-------+------+------------+-----------------------+------------------'
	```
	You should see a line for each node in your cluster.  If that is the case then the TFAMain process is running and able to communicate.  
	If you do not see both all nodes then it is likely either TFAMain is not running on the other node(s) or there is something blocking  
	communications between the nodes on the public network. 

3.	Use the **ahfctl** CLI to check whether the TFA Daemon processes have any jobs in their scheduler

	By default AHF will schedule **orachk** jobs to run:-
	- Every day for critical compliance checks
	- Every week for a full compliance check
	
	```
	<copy>
	ahfctl statusahf -compliance
	</copy>
	```
	Command output:

	![](../ahf-upgrade/images/orachk_sched.png =60%x*)
	
	You can see above that **orachk** will be run each day for "tier 1" critical checks every day except Sunday, and 7 days reports will be retained.  
	The full run will happen every Sunday and 14 reports will be retained.

## Learn More

* [Running Unified AHF CLI Administration Commands](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/running-unified-ahf-cli-administration-commands.html#GUID-6C4F0AB9-73FC-47F1-96C7-DFD6225551E9)
* [tfactl Command Reference](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/tfactl-command-reference.html#GUID-B6E38316-6B47-4FD7-B6BF-C5EB03141F4C)
* [ahfctl Command Reference](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/ahfctl-command-reference.html#GUID-F339FF81-6180-47CC-B7D3-C1EF7D73AD83)
* [Compliance Framework (Oracle Orachk and Oracle Exachk) Command-Line Options](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/compliance-framework-command-line-options.html#GUID-BC213EC7-3668-4773-BD2E-03C5BC721332)

## Acknowledgements
* **Authors** - Bill Burton, Troy Anthony
* **Contributors** - Nirmal Kumar, Robert Pastijn
* **Last Updated By/Date** - Bill Burton, July 2024
