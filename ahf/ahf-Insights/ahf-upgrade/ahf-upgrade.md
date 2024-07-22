# Upgrade Oracle Autonomous Health Framework (AHF)

## Introduction

In this lab, you will learn how to upgrade AHF after downloading **ahf_setup**  
You will need to complete this lab on both nodes of the RAC Database Cluster  

Estimated Time: 5 minutes

### Objectives

In this lab, you will:
* Download a new version of the AHF Distribution from OCI Object Storage
* Use this new distribution to Upgrade the AHF that came by default with Oracle Grid Infrastructure

### Prerequisites
You are connected to each of the DB System Nodes as described in **Lab 1: Connect to your DB System**

## Task 1: Download the new AHF installer from OCI Object Storage to each of the 2 nodes
1.	Ensure you are logged in as the root user
	If you are the **opc** user then you can simply **sudo su** to the root user.

	```
	[opc@myserver ~]$ <copy>sudo su - </copy>
	```

	As the root user download the new AHF Installer using **wget**

	```
	<copy>
	cd /tmp
	wget  https://objectstorage.us-ashburn-1.oraclecloud.com/p/djRqaAzUijQEgNQgTRk05DY9DI-DgHGfDJXbOdWgO2TCWCPx9AtHjBd1tx-5lUpQ/n/idhbogog2wy7/b/ocw24-livelabs/o/AHF-LINUX_v24.6.1.zip
	</copy>
	```
2.	Repeat on the second node


## Task 2: Unzip the AHF 24.6.1 distribution


1. Unzip the **ahf\_setup** installer script in the **/tmp** directory.

	```
	<copy>

	unzip /tmp/AHF-LINUX_v24.1.0.zip -d /tmp/ahf24.1.0

	</copy>
	```
	Command output:

	```
	Archive:  /tmp/AHF-LINUX_v24.1.0.zip
	inflating: /tmp/ahf24.6.1/ahf_setup  
	extracting: /tmp/ahf24.6.1/ahf_setup.dat  
	inflating: /tmp/ahf24.6.1/README.txt  
	inflating: /tmp/ahf24.6.1/oracle-tfa.pub
	```
2. Repeat on the second node

## Task 3: Upgrade to AHF 24.6.1 distribution

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

	AHF Version: 24.6.1 Build Date: change
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
	| lldbcs61            |  24.6.1.0.0 | change | UPGRADED       |
	'---------------------+-------------+-----------------------+----------------'
	| lldbcs62            |  24.2.0.0.0 | 240200020240228181054 | Not Upgraded   |
	'---------------------+-------------+-----------------------+----------------'
	Setting up AHF CLI and SDK
	AHF is successfully upgraded to latest version

	Moving /tmp/ahf_install_246100_53236_2024_07_11-03_45_55.log to /u01/app/oracle.ahf/data/lldbcs61/diag/ahf
	</pre>

7.	Repeat on the second node


## Task 4: Confirm AHF 24.6.1 is now running on both nodes 

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
	| lldbcs61                       | RUNNING       | 59190 | 5000 | 24.6.1.0.0 | change | COMPLETE         |
	'--------------------------------+---------------+-------+------+------------+-----------------------+------------------'
	| lldbcs62                       | RUNNING       | 63152 | 5000 | 24.6.1.0.0 | change | COMPLETE         |
	'--------------------------------+---------------+-------+------+------------+-----------------------+------------------'
	</pre>

	You should see TFA process running and at the same version on Both nodes  

## Learn More

* [Installing and Upgrading Oracle Autonomous Health Framework](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/install-upgrade-ahf.html#GUID-663F0836-A2A2-4EFB-B19E-EABF303739A9)
* [tfactl print](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/tfactl-print.html#GUID-D590CA18-27A9-4FE7-A921-A10587DD5C20)
* [Oracle Autonomous Health Framework Installation Command-Line Options](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/install-ahf.html#GUID-F57C15E1-B82A-42A1-B064-B6C86639799F)

## Acknowledgements
* **Authors** - Bill Burton, Troy Anthony
* **Contributors** - Nirmal Kumar, Robert Pastijn
* **Last Updated By/Date** - Bill Burton, July 2024
