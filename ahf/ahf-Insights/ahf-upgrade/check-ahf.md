# Check Oracle AHF Installation and Health

## Introduction

Welcome to the "AHF Installation Health Check" lab.  
In this lab you will learn how to check the location of AHF executables, data, and diagnostics.   
You will be guided to determine these locations and review their contents.  

Estimated Time: 5 minutes

### Objectives

In this lab, you will:

* Connect to one RAC instance with IP address from 'Get Started with LiveLabs' Lab
* Determine the location of the AHF install.properties file
* Use this file to review the various code and data locations
* Check that the AHF processes are running
* Confirm the health of AHF on the System 

### Prerequisites
- You are connected to one of the DB System Nodes as described in **Get Started with LiveLabs**
- You are logged in as the **root user**

## Task 1: Connect to a Database system node and determine the location of the AHF Installation

1. 	If you are not already connected to one of you Database System nodes. 
	Using one of your Public IP addresses, enter the command below to login as the *opc* user and verify connection to your nodes.

    ```
    <copy>
    ssh -i id_rsa_livelabs opc@<Your Node IP Address>
    </copy>
    ```

   When prompted, answer **yes** to continue connecting.

>Note: You only need to connect to one Node for Labs 1 to 5 in this workshop

2.  If you are not the **root** user then change to the **root** user from the **opc** user
     
     ```
     <copy>
      sudo su - 
      </copy>
     ```

3.	Determine the location of AHF software.

	AHF writes it's Software base location to */etc/oracle.ahf.loc* on Linux and Unix systems.

	Check the contents of the `/etc/oracle.ahf.loc` file 
	```
	<copy>
	cat /etc/oracle.ahf.loc
	</copy>
	```
	Example Command Output:
	<pre>
	/u01/app/oracle.ahf
	</pre> 

4.	Use this location to check the contents of the AHF install.properties file

	```
	<copy>
	cat /u01/app/oracle.ahf/install.properties
	</copy>
	```
	Example Command Output:
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

>	Note: The AHF Command Line Interfaces `ahfctl`, `tfactl`, `orachk`, `ahf` are all linked to the `/usr/bin` directory so should be in your users PATH.


## Task 2: Check the Version, Status and Health of AHF


1.	Use the **tfactl** CLI to check whether the TFA Daemon processes are running on all nodes, and view the current version.

	The process TFAMAin runs on each node of the cluster and these processes communicate to synchroinize monitoring and  
	diagnostic collection operations.  The Process also has a scheduler to run other tools such as **orachk**.  
	```
	<copy>
	tfactl print status
	</copy>
	```
	Example Command output:
	<pre>
	.--------------------------------------------------------------------------------------------------.
	| Host      | Status of TFA | PID   | Port | Version    | Build ID              | Inventory Status |
	+-----------+---------------+-------+------+------------+-----------------------+------------------+
	| lldbcs61  | RUNNING       | 86200 | 5000 | 24.4.1.0.0 | 240410020240513161331 | COMPLETE         |
	| lldbcs62  | RUNNING       | 91603 | 5000 | 24.4.1.0.0 | 240410020240513161331 | COMPLETE         |
	'-----------+---------------+-------+------+------------+-----------------------+------------------'
	</pre>
	You should see a line for each node in your cluster.  If that is the case then the TFAMain process is running and able to communicate.  
	If you do not see both all nodes then it is likely either TFAMain is not running on the other node(s) or there is something blocking  
	communications between the nodes on the public network. 

2.	Use the **tfactl** CLI to check whether the TFA Daemon process is watching the CRS, ASM and Database alert logs for issues.
	
	```
	<copy>
	tfactl print scanfiles
	</copy>
	```
	Example Command output:
	<pre>
	/var/log/messages
	/u01/app/oracle/diag/rdbms/racximwm_8wz_bom/racXIMWM1/trace/alert_racXIMWM1.log
	/u01/app/grid/diag/crs/lvracdb-s01-2024-08-08-1452081/crs/trace/alert.log
	/u01/app/grid/crsdata/lvracdb-s01-2024-08-08-1452081/acfs/event.log.0
	/u01/app/grid/diag/asm/+asm/+ASM1/trace/alert_+ASM1.log
	/u01/app/grid/crsdata/lvracdb-s01-2024-08-08-1452081/acfs/acfs.log.0
	/u01/app/grid/diag/apx/+apx/+APX1/trace/alert_+APX1.log
	</pre>

3.	Use the **ahfctl** CLI to check whether the TFA Daemon processes have any jobs in their scheduler

	By default AHF will schedule **orachk** jobs to run:-
	- Every day for critical compliance checks
	- Every week for a full compliance check
	
	```
	<copy>
	ahfctl statusahf -compliance
	</copy>
	```
	Example Command output:

	![](../ahf-upgrade/images/orachk_sched.png =60%x*)
	
	You can see above that **orachk** will be run each day for `tier 1` critical checks every day except Sunday, and 7 days reports will be retained.  
	The full run will happen every Sunday and 14 reports will be retained.

You may now [proceed to the next lab](#next).

## Learn More

* [Running Unified AHF CLI Administration Commands](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/running-unified-ahf-cli-administration-commands.html#GUID-6C4F0AB9-73FC-47F1-96C7-DFD6225551E9)
* [Oracle Autonomous Health Framework Installation Command-Line Options](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/install-ahf.html#GUID-F57C15E1-B82A-42A1-B064-B6C86639799F)
* [tfactl Command Reference](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/tfactl-command-reference.html#GUID-B6E38316-6B47-4FD7-B6BF-C5EB03141F4C)
* [ahfctl Command Reference](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/ahfctl-command-reference.html#GUID-F339FF81-6180-47CC-B7D3-C1EF7D73AD83)
* [Compliance Framework (Oracle Orachk and Oracle Exachk) Command-Line Options](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/compliance-framework-command-line-options.html#GUID-BC213EC7-3668-4773-BD2E-03C5BC721332)
* [Installing and Upgrading Oracle Autonomous Health Framework](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/install-upgrade-ahf.html#GUID-663F0836-A2A2-4EFB-B19E-EABF303739A9)


## Acknowledgements
* **Authors** - Bill Burton
* **Contributors** - Nirmal Kumar, Troy Anthony
* **Last Updated By/Date** - Bill Burton, August 2024
