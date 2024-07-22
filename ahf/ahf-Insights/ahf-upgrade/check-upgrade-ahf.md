# Check Oracle AHF Installation and Health

## Introduction

Welcome to the "AHF Installation, Health Check and Upgrade" lab.  
In this lab you will learn how to check the location of AHF executables, data, and diagnostics.   
You will be guided to determine these locations and review their contents.  
Finally you will upgrade AHF to the latest version and learn how to set up Auto Upgrade which helps with maintaining AHF across a fleet.


Estimated Time: 5 minutes

### Objectives

In this lab, you will:
* Determine the location of the AHF install.proerties file
* Use this file to review the various code and data locations
* Check that the AHF processes are running
* Upgrade AHF to the latest version
* Confirm the health of AHF on the System
* Set up AHF Auto Upgrade 

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
	<pre>
	/u01/app/oracle.ahf
	</pre> 

2.	Use this location to check the contents of the AHF install.properties file
	```
	<copy>
	cat /u01/app/oracle.ahf/install.properties
	</copy>
	```
	Command Output:
	<pre> 
	AHF_HOME=/u01/app/oracle.ahf
	BUILD_VERSION=2402000
	BUILD_DATE=202402281810
	PREV_BUILD_VR=2401000
	INSTALL_TYPE=TYPICAL
	CRS_HOME=/u01/app/19.0.0.0/grid
	TFA_HOME=/u01/app/oracle.ahf/tfa
	ORACHK_HOME=/u01/app/oracle.ahf/orachk
	DATA_DIR=/u01/app/oracle.ahf/data
	AHF_DIR=/u01/app/oracle.ahf/ahf
	TFA_DATA_DIR=/u01/app/oracle.ahf/data/lldbcs61/tfa
	ORACHK_DATA_DIR=/u01/app/oracle.ahf/data/ahfdbcs61/orachk
	REPOSITORY=/u01/app/oracle.ahf/data/repository
	WORK_DIR=/u01/app/oracle.ahf/data/work
	DIAG_DIR=/u01/app/oracle.ahf/data/lldbcs61/diag
	TFA_DIAG_DIR=/u01/app/oracle.ahf/data/lldbcs61/diag/tfa
	ORACHK_DIAG_DIR=/u01/app/oracle.ahf/data/lldbcs61/diag/orachk
	COMMON_DATA_DIR=/u01/app/oracle.ahf/data/lldbcs61/common
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
	DATABASE_CLIENT_DIR=/u01/app/19.0.0.0/grid
	</pre>
	Interesting Entries:
	- All the AHF Code can be found under the **AHF\_HOME** location
	- All output from AHF tools can be found under the **DATA\_DIR** location which may not be under the **AHF\_HOME**
	- Each tool has it's own DATA location such as **TFA\_DATA\_DIR**
	- All tools write their diagnostics to **DIAG\_DIR**
	- Each tool has it's own DIAG location such as **ORACHK\_DIAG_DIR**
	- The **REPOSITORY** is the location that will be used for diagnotic collections


## Task 2: Check the Availability of the AHF Command Line Interfaces
The AHF Command Line Interfaces `ahfctl`, `tfactl`, `orachk`, `ahf` are all linked to the `/usr/bin` directory.

1. Check that the "ahf" Command Line Interface is available in your PATH.

	```
	<copy>
	which ahf
	</copy>
	```
	Command output:  
	<pre>
	/usr/bin/ahf
	</pre>
2. Check that the "tfactl" Command Line Interface is available in your PATH.
	```
	<copy>
	which tfactl
	</copy>
	```
	
	Command output:  
	<pre>
	/usr/bin/tfactl
	</pre>
3. Check that the "ahfctl" Command Line Interface is available in your PATH.
	```
	<copy>
	which ahfctl
	</copy>
	```
	
	Command output:  
	<pre>
	/usr/bin/ahfctl
	</pre>
4. Check that the "orachk" Command Line Interface is available in your PATH.
	```
	<copy>
	which orachk
	</copy>
	```
	Command output:  
	<pre>
	/usr/bin/orachk
	</pre>

	If any of these are not available that means there was an Issue with AHF Installation that needs to be investigated


## Task 3: Check the Version, Status and Health of AHF

1.	Use the **ahf** CLI to check the software version

	```
	<copy>
	ahf software get-version --component all
	</copy>
	```

	Command output:
	<pre>
	AHF version: 24.2.0
	Build Timestamp: 20240228181054
	TFA version: 24.2.0
	Compliance version: 24.2.0
	Compliance metadata version: 20240228
	</pre>

2.	Use the **tfactl** CLI to check whether the TFA Daemon processes are running on all nodes.

	The process TFAMAin runs on each node of the cluster and these processes communicate to synchroinize monitoring and  
	diagnostic collection operations.  The Process also has a scheduler to run other tools such as **orachk**.  
	```
	<copy>
	tfactl print status
	</copy>
	```
	Command output:
	<pre>
	.--------------------------------------------------------------------------------------------------.
	| Host      | Status of TFA | PID   | Port | Version    | Build ID              | Inventory Status |
	+-----------+---------------+-------+------+------------+-----------------------+------------------+
	| lldbcs61  | RUNNING       | 86200 | 5000 | 24.2.0.0.0 | 240200020240228181054 | COMPLETE         |
	| lldbcs62  | RUNNING       | 91603 | 5000 | 24.2.0.0.0 | 240200020240228181054 | COMPLETE         |
	'-----------+---------------+-------+------+------------+-----------------------+------------------'
	</pre>
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
	
	You can see above that **orachk** will be run each day for `tier 1` critical checks every day except Sunday, and 7 days reports will be retained.  
	The full run will happen every Sunday and 14 reports will be retained.

## Task 4: Upgrade Oracle Autonomous Health Framework (AHF)

	You will now learn how to upgrade AHF after downloading **ahf_setup** which you need to complete on both nodes of the RAC Database Cluster.
	To save time you can do all of the Task 4a to 4d steps in parallel on the 2 nodes.

## Task 4a: Download the new AHF installer from OCI Object Storage to each of the 2 nodes
1.	As the root user download the new AHF Installer using **wget**
	```
	<copy>
	cd /tmp
	wget  https://objectstorage.us-ashburn-1.oraclecloud.com/p/djRqaAzUijQEgNQgTRk05DY9DI-DgHGfDJXbOdWgO2TCWCPx9AtHjBd1tx-5lUpQ/n/idhbogog2wy7/b/ocw24-livelabs/o/AHF-LINUX_v24.6.1.zip
	</copy>
	```
2.	Repeat on the second node


## Task 4b: Unzip the AHF 24.6.1 distribution


1. Unzip the **ahf\_setup** installer script in the **/tmp** directory.

	```
	<copy>
	unzip /tmp/AHF-LINUX_v24.6.1.zip -d /tmp/ahf24.6.1
	</copy>
	```
	Command output:
	<pre>
	Archive:  /tmp/AHF-LINUX_v24.6.1.zip
	inflating: /tmp/ahf24.6.1/ahf_setup  
	extracting: /tmp/ahf24.6.1/ahf_setup.dat  
	inflating: /tmp/ahf24.6.1/README.txt  
	inflating: /tmp/ahf24.6.1/oracle-tfa.pub
	</pre>
2. Repeat on the second node

## Task 4c: Upgrade to AHF 24.6.1 distribution

1.	Execute the **ahf_setup** self extracting installer

	```
	<copy>

	/tmp/ahf24.6.1/ahf_setup -local -silent

	</copy>
	```

	Command output:
	<pre>
	AHF Installer for Platform Linux Architecture x86_64
	AHF Installation Log : /tmp/ahf_install_246000_53236_2024_07_11-03_45_55.log
	Starting Autonomous Health Framework (AHF) Installation

	AHF Version: 24.6.1 Build Date: 2406100202407161727
	AHF is already installed at /u01/app/oracle.ahf
	Installed AHF Version: 24.2.0 Build Date: 202402281810
	Upgrading /u01/app/oracle.ahf
	Shutting down AHF Services
	Upgrading AHF Services
	Started retype of index schema
	Starting AHF Services
	No new directories were added to TFA

	Directory /u01/app/grid/crsdata/lldbcs61/trace/chad was already added to TFA Directories.
	.----------------------------------------------------------------------------.
	| Host                | TFA Version | TFA Build ID          | Upgrade Status |
	+---------------------+-------------+-----------------------+----------------+
	| lldbcs61            |  24.6.1.0.0 | 240610020240716172701 | UPGRADED       |
	'---------------------+-------------+-----------------------+----------------'
	| lldbcs62            |  24.2.0.0.0 | 240200020240228181054 | Not Upgraded   |
	'---------------------+-------------+-----------------------+----------------'
	Setting up AHF CLI and SDK
	AHF is successfully upgraded to latest version

	Moving /tmp/ahf_install_246100_53236_2024_07_11-03_45_55.log to /u01/app/oracle.ahf/data/lldbcs61/diag/ahf
	</pre>

7.	Repeat on the second node


## Task 4d: Confirm AHF 24.6.1 is now running on both nodes 

1. 	Run the **tfactl print status** command on either node to check the run status of AHF Oracle Trace File Analyzer processes.

	```
	<copy>
	tfactl print status
	</copy>
	```
	Command output:
	<pre>
	.-----------------------------------------------------------------------------------------------------------------------.
	| Host                           | Status of TFA | PID   | Port | Version    | Build ID              | Inventory Status |
	+--------------------------------+---------------+-------+------+------------+-----------------------+------------------+
	| lldbcs61                       | RUNNING       | 59190 | 5000 | 24.6.1.0.0 | 240610020240716172701 | COMPLETE         |
	'--------------------------------+---------------+-------+------+------------+-----------------------+------------------'
	| lldbcs62                       | RUNNING       | 63152 | 5000 | 24.6.1.0.0 | 240610020240716172701 | COMPLETE         |
	'--------------------------------+---------------+-------+------+------------+-----------------------+------------------'
	</pre>

	You should see TFA processes running and at the same version on Both nodes  

## Task 5: Set AHF to Auto Upgrade from a software stage location
You can set AHF to update from a software stage location which is particularluy useful when you have a large fleet to maintain.
Simply set AHF to check a location periodically for a new version and when you have completed pre-production testing for a new AHF you can place the  
new installer zip file in the staging location and AHF will be upgraded across your fleet.

1. Configure the software storage location where the new version of AHF zip file will be placed.

	```
	<copy>
	ahfctl setupgrade -swstage /u01/app/oracle.ahf -autoupgrade on
	</copy>
	```
	Command output:
	<pre>
	AHF autoupgrade parameters successfully updated
	Successfully synced AHF configuration
	refreshConfig() completed successfully.
	</pre>

2. Verify the configuration.

	```
	<copy>
	ahfctl getupgrade
	</copy>
	```
	Command output:
	<pre>
	autoupgrade : on
	autoupgrade.swstage : /opt/oracle.ahf
	autoupgrade.frequency : [not set]
	autoupgrade.servicename : [not set]
	</pre>


## Learn More

* [Running Unified AHF CLI Administration Commands](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/running-unified-ahf-cli-administration-commands.html#GUID-6C4F0AB9-73FC-47F1-96C7-DFD6225551E9)
* [Oracle Autonomous Health Framework Installation Command-Line Options](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/install-ahf.html#GUID-F57C15E1-B82A-42A1-B064-B6C86639799F)
* [tfactl Command Reference](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/tfactl-command-reference.html#GUID-B6E38316-6B47-4FD7-B6BF-C5EB03141F4C)
* [ahfctl Command Reference](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/ahfctl-command-reference.html#GUID-F339FF81-6180-47CC-B7D3-C1EF7D73AD83)
* [Compliance Framework (Oracle Orachk and Oracle Exachk) Command-Line Options](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/compliance-framework-command-line-options.html#GUID-BC213EC7-3668-4773-BD2E-03C5BC721332)
* [Installing and Upgrading Oracle Autonomous Health Framework](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/install-upgrade-ahf.html#GUID-663F0836-A2A2-4EFB-B19E-EABF303739A9)


## Acknowledgements
* **Authors** - Bill Burton, Troy Anthony
* **Contributors** - Nirmal Kumar, Robert Pastijn
* **Last Updated By/Date** - Bill Burton, July 2024
