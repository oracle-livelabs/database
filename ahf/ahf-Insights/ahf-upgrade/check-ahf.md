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
	- All the AHF Code can be found under the **AHF_HOME** location
	- All output from AHF tools can be found under the **DATA_DIR** location which may not be under the **AHF_HOME**
	- Each tool has it's own DATA location such as **TFA_DATA_DIR**
	- All tools write their diagnostics to **DIAG_DIR**
	- Each tool has it's own DIAG location such as **ORACHK_DIAG_DIR**
	- The **REPOSITORY** is the location that will be used for diagnotic collections

	Note: The AHF Command Line Interfaces `ahfctl`, `tfactl`, `orachk`, `ahf` are all linked 

## Task 2: Check the Availability of the AHF Command Line Interfaces
The AHF Command Line Interfaces `ahfctl`, `tfactl`, `orachk`, `ahf` are all linked to the `/usr/bin` directory.

1. Check that the AHF Command Line Interface commands are available in your PATH.

	```
	<copy>
	which ahf
	</copy>
	```
	Command output:
	`/usr/bin/ahf`

	```
	<copy>
	which tfactl
	</copy>
	```
	Command output:
	`/usr/bin/tfactl`

	```
	<copy>
	which ahfctl
	</copy>
	```
	Command output:
	`/usr/bin/ahfctl`

		```
	<copy>
	which orachk
	</copy>
	```
	Command output:
	`/usr/bin/orachk`

	If any of these are not available that means there was an Issue with AHF Installation that needs to be investigated


## Task 3: Upgrade to AHF 24.6.0 distribution

1.	Use the `ahf` CLI to check the software version

	```
	<copy>
	ahf software get-version --component all
	</copy>
	```

	Command output:

	

## Task 4: TODO 


## Learn More

* [Installing and Upgrading Oracle Autonomous Health Framework](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/install-upgrade-ahf.html#GUID-663F0836-A2A2-4EFB-B19E-EABF303739A9)
* [tfactl print](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/tfactl-print.html#GUID-D590CA18-27A9-4FE7-A921-A10587DD5C20)
* [Oracle Autonomous Health Framework Installation Command-Line Options](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/install-ahf.html#GUID-F57C15E1-B82A-42A1-B064-B6C86639799F)

## Acknowledgements
* **Authors** - Bill Burton, Troy Anthony
* **Contributors** - Nirmal Kumar, Robert Pastijn
* **Last Updated By/Date** - Bill Burton, July 2024
