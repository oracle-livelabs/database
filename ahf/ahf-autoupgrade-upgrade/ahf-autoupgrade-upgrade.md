# Upgrade Oracle Autonomous Health Framework (AHF)

## Introduction

In this lab, you will learn how to upgrade AHF on the fly without manually downloading **ahf_setup**.

Estimated Time: 30 minutes

Oracle Trace File Analyzer scheduler automatically upgrades AHF if it finds a new version of AHF either at software stage location or at Rest Endpoints (Object Store).

Oracle Trace File Analyzer scheduler is scheduled to run on a weekly time interval to check if a new version of AHF is present at the AHF software stage or at Rest Endpoints (Object Store). If a new version of AHF is found, then the Oracle Trace File Analyzer scheduler will automatically upgrade AHF to the latest version without changing any of the saved configurations.

If a new version of AHF is not found either at the software stage location or at Rest Endpoints (Object Store), then download AHF from MOS to software stage, and then upgrade.

>**Note:** The scope of this workshop is limited to upgrading AHF from the software stage location.

### Objectives

In this lab, you will:
* Upgrade AHF from Software Stage location

### Prerequisites

* You need AHF installed user privileges or **root** access to run the **getupgrade**, **setupgrade**, **unsetupgrade**, and **upgrade** commands.
* **openssl** is needed for all platforms to support **autoupgrade**. If **openssl** is not present, then **autoupgrade** exits gracefully.
* AHF version 21.4.3. You can only upgrade AHF from 21.4.3 to 22.1.1 so uninstall if you have any older versions of AHF.

## Task 1: Uninstall the current AHF installation and install AHF 21.4.3

1. Check if AHF is already installed.

	```
	<copy>
	tfactl status
	</copy>
	```
	Command output:

	```
	.-------------------------------------------------------------------------------------------------------------.
	| Host                 | Status of TFA | PID   | Port  | Version    | Build ID             | Inventory Status |
	+----------------------+---------------+-------+-------+------------+----------------------+------------------+
	| ll46863-instance-ahf | RUNNING       | 14895 | 22303 | 22.1.0.0.0 | 22100020220529214423 | COMPLETE         |
	'----------------------+---------------+-------+-------+------------+----------------------+------------------'
	```

2. Uninstall the current AHF installation.

	```
	<copy>
	ahfctl uninstall -deleterepo -silent
	</copy>
	```
	Command output:

	```
	Starting AHF Uninstall
	AHF will be uninstalled on:
	ll46863-instance-ahf

	Stopping AHF service on local node ll46863-instance-ahf...
	Stopping TFA Support Tools...

	Removed /etc/systemd/system/multi-user.target.wants/oracle-tfa.service.
	Removed /etc/systemd/system/graphical.target.wants/oracle-tfa.service.

	Stopping orachk scheduler ...
	Removing orachk cache discovery....
	No orachk cache discovery found.

	Unable to send message to TFA

	Removed orachk from inittab

	Deleting selinux context entries
	Removing AHF setup on ll46863-instance-ahf:
	Removing /etc/rc.d/rc0.d/K17init.tfa
	Removing /etc/rc.d/rc1.d/K17init.tfa
	Removing /etc/rc.d/rc2.d/K17init.tfa
	Removing /etc/rc.d/rc4.d/K17init.tfa
	Removing /etc/rc.d/rc6.d/K17init.tfa
	Removing /etc/init.d/init.tfa...
	Removing /etc/systemd/system/oracle-tfa.service...
	Removing /opt/oracle.ahf/rpms
	Removing /opt/oracle.ahf/jre
	Removing /opt/oracle.ahf/common
	Removing /opt/oracle.ahf/bin
	Removing /opt/oracle.ahf/python
	Removing /opt/oracle.ahf/analyzer
	Removing /opt/oracle.ahf/tfa
	Removing /opt/oracle.ahf/chm
	Removing /opt/oracle.ahf/orachk
	Removing /opt/oracle.ahf/ahf
	Removing /opt/oracle.ahf/data/ll46863-instance-ahf
	Removing /opt/oracle.ahf/install.properties
	Removing /opt/oracle.ahf/data/repository
	Removing /opt/oracle.ahf/data
	Removing /sys/fs/cgroup/cpu/oratfagroup/
	```

3. Unzip the **ahf\_setup** installer script, **/home/opc/Downloads/AHF-LINUX\_v21.4.3.zip** in the **/tmp** directory.

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
4. Install AHF 21.4.3.

	```
	<copy>
	/tmp/ahf21.4.3/ahf_setup
	</copy>
	```

	Command output:

	<pre>
	AHF Installer for Platform Linux Architecture x86_64
	AHF Installation Log : /tmp/ahf_install_214300_61521_2022_07_06-14_51_09.log
	Starting Autonomous Health Framework (AHF) Installation
	AHF Version: 21.4.3 Build Date: 202204300235
	Default AHF Location : /opt/oracle.ahf
	Do you want to install AHF at [/opt/oracle.ahf] ? [Y]|N : <font color=#f80000><i><b>Y</i></b></font>
	AHF Location : /opt/oracle.ahf
	AHF Data Directory stores diagnostic collections and metadata.
	AHF Data Directory requires at least 5GB (Recommended 10GB) of free space.
	Please Enter AHF Data Directory : <font color=#f80000><i><b>/opt/oracle.ahf</i></b></font>
	AHF Data Directory : /opt/oracle.ahf/data
	Do you want to add AHF Notification Email IDs ? [Y]|N : <font color=#f80000><i><b>N</i></b></font>
	Extracting AHF to /opt/oracle.ahf
	Configuring TFA Services
	Discovering Nodes and Oracle Resources
	Successfully generated certificates.
	Starting TFA Services
	Created symlink /etc/systemd/system/multi-user.target.wants/oracle-tfa.service → /etc/systemd/system/oracle-tfa.service.
	Created symlink /etc/systemd/system/graphical.target.wants/oracle-tfa.service → /etc/systemd/system/oracle-tfa.service.

	.------------------------------------------------------------------------------------------.
	| Host                 | Status of TFA | PID   | Port  | Version    | Build ID             |
	+----------------------+---------------+-------+-------+------------+----------------------+
	| ll46863-instance-ahf | RUNNING       | 63300 | 32273 | 21.4.3.0.0 | 21430020220430023517 |
	'----------------------+---------------+-------+-------+------------+----------------------'

	Running TFA Inventory...

	Adding default users to TFA Access list...

	.------------------------------------------------------------------.
	|                   Summary of AHF Configuration                   |
	+-----------------+------------------------------------------------+
	| Parameter       | Value                                          |
	+-----------------+------------------------------------------------+
	| AHF Location    | /opt/oracle.ahf                                |
	| TFA Location    | /opt/oracle.ahf/tfa                            |
	| Orachk Location | /opt/oracle.ahf/orachk                         |
	| Data Directory  | /opt/oracle.ahf/data                           |
	| Repository      | /opt/oracle.ahf/data/repository                |
	| Diag Directory  | /opt/oracle.ahf/data/ll46863-instance-ahf/diag |
	'-----------------+------------------------------------------------'

	Starting orachk scheduler from AHF ...
	AHF binaries are available in /opt/oracle.ahf/bin
	AHF is successfully installed
	Do you want AHF to store your My Oracle Support Credentials for Automatic Upload ? Y|[N] : <font color=#f80000><i><b>N</i></b></font>
	Moving /tmp/ahf_install_214300_61521_2022_07_06-14_51_09.log to /opt/oracle.ahf/data/ll46863-instance-ahf/diag/ahf/
	</pre>

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

3. Copy the **AHF-LINUX_22.1.1.zip** file from **/home/opc/Downloads** and paste it into the **/opt/oracle.ahf** directory.

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
	 total 277720
	 drwxr-xr-x. 5 root root        43 Apr 30 09:35 ahf
	 -rw-r--r--. 1 root root 284378255 Jul  6 15:20 AHF-LINUX_v22.1.1.zip
	 drwxr-x--x. 2 root root         6 Jul  6 14:51 analyzer
	 drwxr-xr-x. 2 root root        60 Jul  6 14:53 bin
	 drwxr-x--x. 3 root root        17 Jul  6 14:51 chm
	 drwxr-xr-x. 7 root root        64 Apr 30 09:35 common
	 drwxr-xr-x. 5 root root        64 Jul  6 14:51 data
	 -rw-r--r--. 1 root root       984 Jul  6 14:51 install.properties
	 drwxr-x--x. 6 root root       198 Apr 30 09:35 jre
	 drwxr-xr-x. 7 root root       251 Jul  6 14:51 orachk
	 drwxr-xr-x. 6 root root       226 Mar 15 12:00 python
	 drwx------. 2 root root        57 Apr 30 09:35 rpms
	 drwxr-x--x. 9 root root       209 Jul  6 14:51 tfa
	 ```

5. Run the upgrade command and specify the **-nomos** command option to upgrade without MOS configuration.

	```
	<copy>
	ahfctl upgrade -nomos
	</copy>
	```
	Command output:

	```
	/opt/oracle.ahf/AHF-LINUX_v22.1.1.zip successfully extracted at /opt/oracle.ahf
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
	total 44
	-rw-r--r--. 1 root root   801 Jul  6 15:25 ahf_auto_upgrade_console_78122.log
	-rw-r--r--. 1 root root  9219 Jul  6 15:25 ahfctl.log
	-rw-------. 1 root root 26693 Jul  6 14:54 ahf_install_214300_61521_2022_07_06-14_51_09.log
	```

	```
	<copy>
	vi /opt/oracle.ahf/data/$HOSTNAME/diag/ahf/ahf_auto_upgrade*
	</copy>
	```
	Command output:

	```
	Wed Jul  6 15:25:00 GMT 2022

	AHF Installer for Platform Linux Architecture x86_64

	AHF Installation Log : /tmp/ahf_install_221100_78142_2022_07_06-15_25_00.log

	Starting Autonomous Health Framework (AHF) Installation

	AHF Version: 22.1.1 Build Date: 202205161959

	AHF is already installed at /opt/oracle.ahf

	Installed AHF Version: 21.4.3 Build Date: 202204300235

	Upgrading /opt/oracle.ahf

	Shutting down AHF Services
	Removing orachk cache discovery....
	No orachk cache discovery found.

	Successfully copied Daemon Store to Remote Nodes

	Removed orachk from inittab

	Stopping orachk scheduler ...
	Stopped orachk
	Nothing to do !
	Stopping TFA from the Command Line
	Nothing to do !
	Please wait while TFA stops
	Please wait while TFA stops
	TFA-00002 Oracle Trace File Analyzer (TFA) is not running
	TFA Stopped Successfully
	Successfully stopped TFA..
	Telemetry adapter is not running

	Starting AHF Services
	Starting TFA..
	Waiting up to 100 seconds for TFA to be started..
	. . . . .
	. . . . .
	Successfully started TFA Process..
	. . . . .
	TFA Started and listening for commands

	Adding default users to TFA Access list...

	Oracle Trace File Analyzer (TFA) is already running

	INFO: Starting orachk scheduler in background. Details for the process can be found at /opt/oracle.ahf/data/ll46863-instance-ahf/diag/orachk/compliance_start_060722_152803.log

	AHF is successfully upgraded to latest version

	.----------------------------------------------------------------------------.
	| Host                 | TFA Version | TFA Build ID         | Upgrade Status |
	+----------------------+-------------+----------------------+----------------+
	| ll46863-instance-ahf |  22.1.1.0.0 | 22110020220516195917 | UPGRADED       |
	'----------------------+-------------+----------------------+----------------'

	Moving /tmp/ahf_install_221100_78142_2022_07_06-15_25_00.log to /opt/oracle.ahf/data/ll46863-instance-ahf/diag/ahf/
	```

7. Run the **tfactl status** command to check the run status of Oracle Trace File Analyzer.

	```
	<copy>
	tfactl status
	</copy>
	```
	Command output:

	```
	.-------------------------------------------------------------------------------------------------------------.
	| Host                 | Status of TFA | PID   | Port  | Version    | Build ID             | Inventory Status |
	+----------------------+---------------+-------+-------+------------+----------------------+------------------+
	| ll46863-instance-ahf | RUNNING       | 83199 | 20707 | 22.1.1.0.0 | 22110020220516195917 | COMPLETE         |
	'----------------------+---------------+-------+-------+------------+----------------------+------------------'
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
	refreshConfig() completed successfully.
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
	autoupgrade.fstype : [not set]
	autoupgrade.tmp_loc : [not set]
	autoupgrade.remove_installer : [not set]
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
	Successfully synced AHF configuration
	refreshConfig() completed successfully.
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
* **Last Updated By/Date** - Nirmal Kumar, July 2022
