# Upgrade Oracle Autonomous Health Framework (AHF)

## Introduction

In this lab, you will learn how to upgrade AHF on the fly without manually downloading **ahf_setup**.

Estimated Time: 30 minutes

Oracle Trace File Analyzer scheduler automatically upgrades AHF if it finds a new version of AHF either at software stage location or at Rest Endpoints (Object Store).

Oracle Trace File Analyzer scheduler is scheduled to run on a weekly time interval to check if a new version of AHF is present at the AHF software stage or at Rest Endpoints (Object Store). If a new version of AHF is found, then the Oracle Trace File Analyzer scheduler will automatically upgrade AHF to the latest version without changing any of the saved configurations.

If a new version of AHF is not found either at the software stage location or at Rest Endpoints (Object Store), then download AHF from MOS to software stage, and then upgrade.

### Objectives

In this lab, you will:
* Upgrade AHF from Software Stage location

>**Note:** The scope of this workshop is limited to upgrading AHF from the software stage locatoin and on the local file system.

### Prerequisites

* You need AHF installed user privileges or **root** access to run **getupgrade**, **setupgrade**, **unsetupgrade**, and **upgrade** commands.
* **openssl** is needed for all platforms to support **autoupgrade**. If **openssl** is not present, then **autoupgrade** exits gracefully.
* AHF version 21.4.3. You can only upgrade AHF from 21.4.3 to 22.1.1 so uninstall if you have any older versions of AHF.

### Operating Systems Supported to Upgrade AHF Automatically

Automatic upgrade is supported on:
- Linux
- Solaris
- AIX

Autoupgrade is NOT supported on:
- HP-UX
- Microsoft Windows
- Standalone installations (except Exadata dom0)

Autoupgrade of AHF by non-root users is supported only if the existing installation was done by the same user and the installation type is typical (full). For example, if user "X" has installed AHF, then autoupgrade cannot be performed by user "Y".

>**Note:** If the upgrade output is not displayed, wait for 3-5 minutes and then check the **/opt/oracle.ahf/data/*hostname*/diag/ahf/ahf\_install\_*date*>.log** file.

## Task 1: Uninstall the current AHF installation and install AHF 21.4.3

1. Check if AHF is already installed:

	```
	<copy>
	tfactl status
	</copy>
	```
	Command output:

	```
	.----------------------------------------------------------------------------------.
	| Host       | Status of TFA | PID     | Port  | Version    | Build ID             |
	+------------+---------------+---------+-------+------------+----------------------+
	| den02mwa	 | RUNNING       | 1039258 | 39435 | 22.1.0.0 | 21360020220202214733 |
	'------------+---------------+---------+-------+------------+----------------------'
	```

2. Uninstall the current AHF installation:

	```
	<copy>
	ahfctl uninstall -deleterepo -silent
	</copy>
	```
	Command output:

	```
	Starting AHF Uninstall
	AHF will be uninstalled on: ahf2

	Stopping AHF service on local node ahf2...
	Sleeping for 10 seconds...

	Stopping TFA Support Tools...

	Removing AHF setup on ahf2:
	Removing /ahf/oracle.ahf/rpms
	Removing /ahf/oracle.ahf/jre
	Removing /ahf/oracle.ahf/common
	Removing /ahf/oracle.ahf/bin
	Removing /ahf/oracle.ahf/python
	Removing /ahf/oracle.ahf/analyzer
	Removing /ahf/oracle.ahf/tfa
	Removing /ahf/oracle.ahf/chm
	Removing /ahf/oracle.ahf/orachk
	Removing /ahf/oracle.ahf/ahf
	Removing /ahf/oracle.ahf/data/ahf2
	Removing /ahf/oracle.ahf/install.properties
	Removing /ahf/oracle.ahf/data/repository
	Removing /ahf/oracle.ahf/data
	```

3. Unzip the **ahf\_setup** installer script, **/home/opc/Downloads/AHF-LINUX\_v21.4.3.zip** in the **/tmp** directory:

	```
	<copy>
	unzip /home/opc/Downloads/AHF-LINUX_v21.4.3.zip -d /tmp/ahf21.4.3
	</copy>
	```
	Command output:

	```
	Archive:  /home/opc/Downloads/AHF-LINUX_v21.4.3.zip
	inflating: /tmp/ahf21.4.3/ahf_setup
	extracting: /tmp/ahf21.4.3/ahf_setup.dat
	inflating: /tmp/ahf21.4.3/README.txt
	inflating: /tmp/ahf21.4.3/oracle-tfa.pub
	```
4. Install AHF 21.4.3:

	```
	<copy>
	/tmp/ahf21.4.3/ahf_setup
	</copy>
	```

	Command output:

	```
	AHF Installer for Platform Linux Architecture x86_64
	AHF Installation Log : /tmp/ahf_install_221000_103911_2022_02_02-13_38_15.log
	Starting Autonomous Health Framework (AHF) Installation
	AHF Version: 21.4.3 Build Date: 202201302324
	Default AHF Location : /opt/oracle.ahf
	Do you want to install AHF at [/opt/oracle.ahf] ? [Y]|N : Y
	AHF Location : /opt/oracle.ahf
	AHF Data Directory stores diagnostic collections and metadata.
	AHF Data Directory requires at least 5GB (Recommended 10GB) of free space.
	Please Enter AHF Data Directory : /opt/oracle.ahf
	AHF Data Directory : /opt/oracle.ahf/data
	Do you want to add AHF Notification Email IDs ? [Y]|N : N
	Extracting AHF to /opt/oracle.ahf
	Configuring TFA Services
	Discovering Nodes and Oracle Resources
	Successfully generated certificates.
	Starting TFA Services
	Created symlink from /etc/systemd/system/multi-user.target.wants/oracle-tfa.service to /etc/systemd/system/oracle-tfa.service.
	Created symlink from /etc/systemd/system/graphical.target.wants/oracle-tfa.service to /etc/systemd/system/oracle-tfa.service.

	.-------------------------------------------------------------------------------.
	| Host     | Status of TFA | PID    | Port  | Version    | Build ID             |
	+----------+---------------+--------+-------+------------+----------------------+
	| den02mwa | RUNNING       | 105916 | 59452 | 21.4.3.0.0 | 22100020220130232427 |
	'----------+---------------+--------+-------+------------+----------------------'

	Running TFA Inventory...
	Adding default users to TFA Access list...

	.------------------------------------------------------.
	|             Summary of AHF Configuration             |
	+-----------------+------------------------------------+
	| Parameter       | Value                              |
	+-----------------+------------------------------------+
	| AHF Location    | /opt/oracle.ahf                    |
	| TFA Location    | /opt/oracle.ahf/tfa                |
	| Orachk Location | /opt/oracle.ahf/orachk             |
	| Data Directory  | /opt/oracle.ahf/data               |
	| Repository      | /opt/oracle.ahf/data/repository    |
	| Diag Directory  | /opt/oracle.ahf/data/den02mwa/diag |
	'-----------------+------------------------------------'

	Starting orachk scheduler from AHF ...
	AHF binaries are available in /opt/oracle.ahf/bin
	AHF is successfully installed

	Do you want AHF to store your My Oracle Support Credentials for Automatic Upload ? Y|[N] : N
	Moving /tmp/ahf_install_221000_103911_2022_02_02-13_38_15.log to /opt/oracle.ahf/data/den02mwa/diag/ahf/
	```

## Task 2: Upgrade AHF from the software stage location

1. Configure the software storage location where the new version of AHF zip file exists.

	```
	<copy>
	ahfctl setupgrade -swstage /opt/oracle.ahf -autoupgrade on
	</copy>
	```
	Command output:
	```
	AHF autoupgrade parameters successfully updated
	Successfully synced AHF configuration
	refreshConfig() completed successfully.
	```

2. Verify the configuration.

	```
	<copy>
	ahfctl getupgrade
	</copy>
	```
	Command output:

	```
	autoupgrade : on
	autoupgrade.swstage : /opt/oracle.ahf
	autoupgrade.frequency : [not set]
	autoupgrade.servicename : [not set]
	```

3. Copy the **AHF-LINUX_22.1.1.zip** file from **/home/opc/Downloads** and paste in to the **/opt/oracle.ahf** directory.

	```
	<copy>
	cp -rf /home/opc/Downloads/AHF-LINUX_v22.1.1.zip /opt/oracle.ahf
	</copy>
	```

4. Validate if the AHF zip file is copied to the **/opt/oracle.ahf** directory.

	```
	 <copy>
	 ls -l /opt/oracle.ahf
	 </copy>
	 ```
	 Command output:

	 ```
	 total 410272
	 drwxr-xr-x 6 root root      4096 Jan 24 21:46 ahf
	 -rwxrwxrwx 1 root root 420064080 Jan 29 14:15 AHF-LINUX_v22.1.1.zip
	 drwxr-x--x 2 root root      4096 Jan 26 11:10 analyzer
	 drwxr-xr-x 2 root root      4096 Jan 26 11:11 bin
	 drwxr-x--x 3 root root      4096 Jan 26 11:10 chm
	 drwxr-xr-x 7 root root      4096 Jan 24 21:46 common
	 drwxr-xr-x 5 root root      4096 Jan 26 11:10 data
	 -rw-r--r-- 1 root root       941 Jan 26 11:10 install.properties
	 drwxr-x--x 6 root root      4096 Jan 24 21:46 jre
	 drwxr-xr-x 7 root root      4096 Jan 26 11:10 orachk
	 drwxr-xr-x 6 root root      4096 Jan 10 20:28 python
	 drwx------ 2 root root      4096 Jan 24 21:46 rpms
	 drwxr-x--x 9 root root      4096 Jan 29 11:23 tfa
	 ```

5. Run the upgrade command and specify the **-nomos** command option to upgrade without MOS configuration.

	```
	<copy>
	ahfctl upgrade -nomos
	</copy>
	```
	Command output:

	```
	/opt/oracle.ahf/AHF-LINUX_v22.2.0.zip successfully extracted at /opt/oracle.ahf
	AHF software signature has been validated successfully
	```

6. Validate if the upgrade is done correctly and check the upgrade logs after 4 minutes.

	```
	<copy>
	ls -l /opt/oracle.ahf/data/$HOSTNAME/diag/ahf
	</copy>
	```
	Command output:

	```
	total 80
	-rw-r--r-- 1 root root  1988 Jun 29 20:52 ahf_auto_upgrade_console_24810.log
	-rw-r--r-- 1 root root  12884 Jun 29 20:52 ahfctl.log
	-rw------- 1 root root  26303 Jun 27 09:05 ahf_install_222000_29562_2022_06_27-09_03_56.log
	-rw-r--r-- 1 root root 125123 Jun 29 22:09 tfactl.log
	```

	```
	<copy>
	vi /opt/oracle.ahf/data/$HOSTNAME/diag/ahf/ahf_auto_upgrade*
	</copy>
	```
	Command output:

	```
	Sat Jan 29 22:51:47 UTC 2022
	AHF Installer for Platform Linux Architecture x86_64
	AHF Installation Log : /tmp/ahf_install_221000_23212_2022_01_29-22_51_47.log
	Starting Autonomous Health Framework (AHF) Installation
	AHF Version: 22.1.1 Build Date: 202201272149
	AHF is already installed at /opt/oracle.ahf
	Installed AHF Version: 21.4.3 Build Date: 202201152118
	Upgrading /opt/oracle.ahf
	Shutting down AHF Services
	Stopped OSWatcher
	Nothing to do !
	Stopping TFA from the Command Line
	Nothing to do !
	Please wait while TFA stops
	Please wait while TFA stops
	TFA-00002 Oracle Trace File Analyzer (TFA) is not running
	TFA Stopped Successfully
	Successfully stopped TFA..

	Starting AHF Services
	Starting TFA..
	Waiting up to 100 seconds for TFA to be started..
	. . . . .
	. . . . .
	. . . . .
	. . . . .
	. . . . .
	. . . . .
	. . . . .
	Successfully started TFA Process..
	. . . . .
	TFA Started and listening for commands
	No new directories were added to TFA
	Directory /scratch/u01/app/grid_base/crsdata/den02kad/trace/chad was already added to TFA Directories.

	INFO: Starting orachk scheduler in background. Details for the process can be found at /opt/oracle.ahf/data/den02kad/diag/orachk/compliance_start_290122_225349.log

	AHF is successfully upgraded to latest version

	.----------------------------------------------------------------.
	| Host     | TFA Version | TFA Build ID         | Upgrade Status |
	+----------+-------------+----------------------+----------------+
	| den02kad |  22.1.1.0.0 | 22100020220127214932 | UPGRADED       |
	'----------+-------------+----------------------+----------------'

	Moving /tmp/ahf_install_221000_23212_2022_01_29-22_51_47.log to /opt/oracle.ahf/data/den02kad/diag/ahf/
	```

7. Run the **tfactl status** command to check the run status of Oracle Trace File Analyzer.

	```
	<copy>
	tfactl status
	</copy>
	```
	Command output:

	```
	.------------------------------------------------------------------------------------------------.
	| Host     | Status of TFA | PID   | Port | Version    | Build ID             | Inventory Status |
	+----------+---------------+-------+------+------------+----------------------+------------------+
	| den02kad | RUNNING       | 28379 | 5000 | 22.1.1.0.0 | 22100020220127214932 | COMPLETE         |
	'----------+---------------+-------+------+------------+----------------------+------------------'
	```

## Task 3: Unset upgrade configuration

Run the **ahfctl unsetupgrade** command to unset a specific upgrade parameter or all of the upgrade parameters.

1. To unset upgrade configuration:

	```
	<copy>
	ahfctl unsetupgrade -all
	</copy>
	```
	Command output:
	```
	AHF upgrade parameters successfully removed
	Successfully synced AHF configuration
	```

2. To verify if all the parameters are unset:

	```
	<copy>
	ahfctl getupgrade -all
	</copy>
	```
	Command output:
	```
	autoupgrade : [not set]
	autoupgrade.swstage : [not set]
	autoupgrade.frequency : [not set]
	autoupgrade.servicename : [not set]
	```

## Task 4: Disable automatic upgrade

You can disable **autoupgrade** if you want to upgrade AHF manually.

1. To disable autoupgrade:

	```
	<copy>
	ahfctl unsetupgrade -autoupgrade
	</copy>
	```

	Command output:

	```
	Autoupgrade flag successfully removed

	```

## Learn More

* [Installing and Upgrading Oracle Autonomous Health Framework](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/install-upgrade-ahf.html#GUID-663F0836-A2A2-4EFB-B19E-EABF303739A9)
* [ahfctl setupgrade](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/ahfctl-setupgrade.html#GUID-0AA4D7BE-781D-4345-BC77-A38AF10826BB)
* [ahfctl unsetupgrade](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/ahfctl-unsetupgrade.html#GUID-7757592D-7E68-44EB-9ED0-14731146CFF6)
* [ahfctl getupgrade](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/ahfctl-getupgrade.html#GUID-436F6822-FA11-4BE7-B28A-B8F0D9C01F97)
* [ahfctl upgrade](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/ahfctl-upgrade.html#GUID-7EB170D6-DC9F-4EE3-9DD8-B5374B856179)
* [Oracle Autonomous Health Framework Installation Command-Line Options](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/install-ahf.html#GUID-F57C15E1-B82A-42A1-B064-B6C86639799F)

## Acknowledgements
* **Author** - Nirmal Kumar
* **Contributors** -  Sarahi Partida, Robert Pastijn, Girdhari Ghantiyala, Anuradha Chepuri
* **Last Updated By/Date** - Nirmal Kumar, June 2022
