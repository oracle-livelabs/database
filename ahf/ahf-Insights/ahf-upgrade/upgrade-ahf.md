# Check Oracle AHF Installation and Health

## Introduction

Welcome to the "AHF Upgrade" lab.  
In this lab you will learn how to upgrade AHF to the latest version and learn how to set up Auto Upgrade which helps with maintaining AHF across a fleet.


Estimated Time: 10 minutes

### Objectives

In this lab, you will:
* Upgrade AHF to the latest version
* Confirm the health of AHF on the System
* Learn how to set up AHF Auto Upgrade 

### Prerequisites
- You are connected to one of the DB System Nodes as described in **Get Started with LiveLabs**
- You are logged in as the **root user**


## Task 1: Upgrade Oracle Autonomous Health Framework (AHF)
You will now learn how to upgrade AHF after downloading *ahf_setup*  
You must complete on both nodes of the RAC Database Cluster.
>Note: To save time you can do all the steps in parallel on each node.


1.	Download the new AHF installer from OCI Object Storage on one node.

	As the root user download the new AHF Installer using **wget**
	```
	<copy>
	cd /tmp
	wget  https://idhbogog2wy7.objectstorage.us-ashburn-1.oci.customer-oci.com/p/5jfe6rB_g_6MNkhfEW87-2IelklkLAJ6jyBTIJqo525D9GEGzDXXTbkvPy0ujbZ9/n/idhbogog2wy7/b/ocw24-livelabs/o/AHF-LINUX_v24.6.1.zip
	</copy>
	```

2. Unzip the AHF 24.6.1 installer in to the **/tmp** directory.

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

3.	Upgrade to AHF 24.6.1 distribution using the **ahf_setup** self extracting installer

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

	Installed AHF Version: 24.4.1 Build Date: 202402281810 202405131613

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
	| lldbcs62            |  24.4.1.0.0 | 240410020240513161331 | Not Upgraded   |
	'---------------------+-------------+-----------------------+----------------'
	Setting up AHF CLI and SDK
	AHF is successfully upgraded to latest version

	Moving /tmp/ahf_install_246100_53236_2024_07_11-03_45_55.log to /u01/app/oracle.ahf/data/lldbcs61/diag/ahf
	</pre>

Repeat Step 1 to 3 on the second node, if you were not doing these steps in parallel.

4.	Confirm AHF 24.6.1 is now running on both nodes.

	Run the **tfactl print status** command on either node to check the run status of AHF Oracle Trace File Analyzer processes.

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

## Task 2: Learn how to set AHF to Auto Upgrade from a software stage location
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
