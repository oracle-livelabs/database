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
* Upgrade AHF from REST endpoints (Object Store)
* Upgrade AHF from MOS

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

### Upgrading AHF on Local File System, ACFS, and NFS
You can upgrade AHF on the local file system, Oracle Advanced Cluster File System (Oracle ACFS), and Network File System (NFS).

>**Note**
* The scope of this workshop is limited to upgrading AHF on the local file system because enabling ACFS and configuring the NFS path location is not possible in this environment.
* If the upgrade output is not displayed, wait for 3-5 minutes and then check the **/opt/oracle.ahf/data/*hostname*/diag/ahf/ahf\_install\_*date*>.log** file.

## Task 1: Uninstall an Older Version of AHF and Install AHF 21.4.3

1. To check if AHF is already installed:

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
	| iaddbfan38 | RUNNING       | 1039258 | 39435 | 21.3.6.0.0 | 21360020220202214733 |
	'------------+---------------+---------+-------+------------+----------------------'
	```

2. To uninstall AHF:

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

3. To unzip the **ahf\_setup** installer script, **/home/opc/Downloads/AHF-LINUX\_v21.4.3.zip** in the **/tmp** directory:

	```
	<copy>
	ls -l  /home/opc/Downloads/AHF-LINUX_v21.4.3.zip
	</copy>
	```
	Command output:

	```
	-rw-r--r--. 1 root root 373987699 May 31 02:03 /home/opc/Downloads/AHF-LINUX_v21.4.3.zip
	```

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
4. To install AHF 21.4.3:

	```
	<copy>
	/tmp/ahf21.4.3/ahf_setup
	</copy>
	```

## Task 2: Upgrade AHF from Software Stage Location

1. Ensure that you have an older version of AHF (preferably 21.4.3) installed.

2. Configure the software storage location where the new version of AHF zip file exists.

	```
	<copy>
	ahfctl setupgrade -swstage /opt/oracle.ahf -autoupgrade on
	</copy>
	```
	Command output:
	```
	AHF autoupgrade parameters successfully updated
	Successfully synced AHF configuration
	```

3. Verify the configuration.

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

4. Validate if a newer AHF zip file is located in the software stage location.

	```
	 <copy>
	 ls -l
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

	 ```
	 <copy>
	 pwd
	 </copy>
	 ```
	 Command output:

	 ```
	 /opt/oracle.ahf
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
	echo $?
	```

6. Validate if the upgrade is done correctly and check the upgrade logs after 4 minutes.

	```
	Sat Jan 29 22:51:47 UTC 2022
	AHF Installer for Platform Linux Architecture x86_64
	AHF Installation Log : /tmp/ahf_install_221000_23212_2022_01_29-22_51_47.log
	Starting Autonomous Health Framework (AHF) Installation
	AHF Version: 22.1.0 Build Date: 202201272149
	AHF is already installed at /opt/oracle.ahf
	Installed AHF Version: 21.3.6 Build Date: 202201152118
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
	| den02kad |  22.1.0.0.0 | 22100020220127214932 | UPGRADED       |
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
	| den02kad | RUNNING       | 28379 | 5000 | 22.1.0.0.0 | 22100020220127214932 | COMPLETE         |
	'----------+---------------+-------+------+------------+----------------------+------------------'
	```

## Task 3: Upgrade AHF from REST Endpoints (Object Store)

>**Note** You can skip the following steps if you have already configured the REST Endpoint (Object Store) or if you do not have a REST Endpoint.

1. Configure REST endpoints (Object Store).

	```
	<copy>
	ahfctl setupload -name test_ep -type https
	</copy>
	```
	Command output:

	```
	Enter test_ep.https.user :  testuser@oracle.com
	Enter test_ep.https.password :
	Enter test_ep.https.url : https://swiftobjectstorage.r1.oracleiaas.com/v1/dbaasimage/CDCJH
	Successfully synced AHF configuration
	Upload configuration set for: test_ep
	type: https

	test_ep.https.password: ******

	test_ep.https.url: https://swiftobjectstorage.r1.oracleiaas.com/v1/dbaasimage/CDCJH
	```

2. Validate the configured upload parameters.

	```
	<copy>
	ahfctl checkupload -name test_ep
	</copy>
	```
	Command output:

	```
	Upload configuration check for: test_ep.
	Parameters are configured correctly to upload.
	```

3. Configure the name of the REST download service.

	```
	<copy>
	ahfctl setupgrade -servicename test_ep
	</copy>
	```
	Command output:

	```
	AHF autoupgrade parameters successfully updated
	Successfully synced AHF configuration
	```

4. Run the upgrade command and specify the **-nomos** command option to upgrade without MOS configuration.

	```
	<copy>
	ahfctl upgrade -nomos
	</copy>
	```
	Command output:

	```
	Upload configuration check for: test_ep.

	Parameters are configured correctly to upload.
	AHF-LINUX_v22.2.0.zip successfully downloaded at /opt/oracle.ahf
	/opt/oracle.ahf/AHF-LINUX_v22.2.0.zip successfully extracted at /opt/oracle.ahf
	AHF software signature has been validated successfully
	AHF is already running latest version. No need to upgrade.
	```

>**Note:** To run the upgrade, **test\_ep** upload configuration must contain the **AHF-LINUX\_v22.2.0.zip** file. To check if this file exists in the object storage, run the **curl get** command.

## Task 4: Download AHF Installer Zip File from MOS

If a new version of AHF is not found either at the software stage location or at Rest Endpoints (Object Store), then download AHF from MOS to software stage, and then upgrade.

1. Set all autoupgrade parameters with valid inputs:

	```
	<copy>
	ahfctl setupgrade -all
	</copy>
	```
	Command output:

	```
	Enter autoupgrade flag <on/off> : on
	Enter software stage location : /opt/oracle.ahf
	Enter auto upgrade frequency : 5
	AHF autoupgrade parameters successfully updated
	Successfully synced AHF configuration
	```
2. Run the **ahfctl upgrade** command:

	```
	<copy>
	ahfctl upgrade
	</copy>
	```
	Command output:

	```
	AHF-LINUX_v21.1.0.zip successfully downloaded at /opt/oracle.ahf /opt/oracle.ahf/AHF-LINUX_v21.1.0.zip successfully extracted at /opt/oracle.ahf AHF software signature has been validated successfully
	```
## Task 5: Troubleshoot AHF Download from MOS

**Description:** AHF download from MOS fails with the following error:

```
ahfctl upgrade
An error has occurred while downloading AHF from MOS. Please try again!
```
**Action:** Check the **<Diag_Directory>/tfa/tfa_main.trc** file for more information and troubleshooting tips.

To enable debug:

```
<copy>
tfactl set tracelevel=MAIN:DEBUG
</copy>
```

## Task 6: Unset Upgrade Configuration

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

## Task 7: Disable Automatic upgrade

You can disable **autoupgrade** if you want to upgrade AHF manually.

To disable autoupgrade:

```
<copy>ahfctl setupgrade -autoupgrade off</copy>
```
(or)

```
<copy>ahfctl unsetupgrade -autoupgrade</copy>
```

## Task 8: Upgrade AHF on Local File System

If the stage location is a local file system and if the AHF installer zip file exists in the stage location, then after upgrading, the installer removes the AHF installer zip file and all the extracted items from the stage location.

1. Configure the auto upgrade parameters.

	```
	<copy>
	ahfctl setupgrade -all
	</copy>
	```

	Command output:

	```
	Enter autoupgrade flag <on/off> : on
	Enter software stage location : /opt/local
	Enter auto upgrade frequency : 30
	AHF autoupgrade parameters successfully updated
	Successfully synced AHF configuration
	refreshConfig() completed successfully.
	```

2. Check if the AHF installer zip file exists in the stage location.

	```
	<copy>
	ls /opt/local
	</copy>
	```

	Command output:

	```
	AHF-LINUX_v22.1.1.zip
	```

	>**Note:** Oracle Trace File Analyzer scheduler calls **ahfctl upgrade -nomos** at a given frequency, in this example, auto-upgrade will happen every 30 days at 3 AM. You can also initiate automatic upgrade from the command-line using the **ahfctl upgrade** command.

3. Run the upgrade command.

	```
	<copy>
	ahfctl upgrade
	</copy>
	```

	Command output:
	```
	AHF Installer for Platform Linux Architecture x86_64
	AHF Installation Log : /tmp/ahf_install_221000_139332_2022_03_09-02_09_42.log
	Starting Autonomous Health Framework (AHF) Installation
	AHF Version: 22.1.0 Build Date: 202203081742
	AHF is already installed at /opt/oracle.ahf
	Installed AHF Version: 22.1.0 Build Date: 202203081714
	Upgrading /opt/oracle.ahf
	Shutting down AHF Services
	Nothing to do !
	Shutting down TFA
	Removed symlink /etc/systemd/system/multi-user.target.wants/oracle-tfa.service.
	Removed symlink /etc/systemd/system/graphical.target.wants/oracle-tfa.service.
	Successfully shutdown TFA..
	Starting AHF Services
	Starting TFA..
	Waiting up to 100 seconds for TFA to be started..
	. . . . .
	Successfully started TFA Process..
	. . . . .
	TFA Started and listening for commands
	No new directories were added to TFA
	Directory /u01/app/grid/crsdata/scao05adm07/trace/chad was already added to TFA Directories.
	INFO: Starting exachk scheduler in background. Details for the process can be found at /u01/app/grid/oracle.ahf/data/scao05adm07/diag/exachk/compliance_start_090322_021151.log
	AHF is successfully upgraded to latest version
	.-------------------------------------------------------------------.
	| Host        | TFA Version | TFA Build ID         | Upgrade Status |
	+-------------+-------------+----------------------+----------------+
	| scao05adm07 |  22.1.0.0.0 | 22100020220308174218 | UPGRADED       |
	| scao05adm08 |  22.1.0.0.0 | 22100020220308171448 | UPGRADED       |
	'-------------+-------------+----------------------+----------------'
	Moving /tmp/ahf_install_221000_139332_2022_03_09-02_09_42.log to /u01/app/grid/oracle.ahf/data/scao05adm07/diag/ahf/
	Please upgrade AHF on the below mentioned nodes as well using ahfctl upgrade
	scao05adm08
	```

4. Validate if AHF installer zip and the extracted files are removed from the stage location.

	```
	<copy>
	ls -lart /opt/local
	</copy>
	```
	Command output:

	```
	drwxr-xr-x   2 root     root           2 Mar  9 02:32 .
	drwxr-xr-x  25 root     sys           28 Mar  9 02:32 ..
	```
## Task 9: Upgrade AHF on Oracle Advanced Cluster File System (Oracle ACFS)

>**Note** The scope of this workshop is limited to upgrading AHF on the local file system because enabling ACFS and configuring the NFS path location is not possible in this environment.

If the stage location is ACFS and if the AHF installer zip file exists in the stage location, then after upgrading, the installer removes the AHF installer zip file and retains all the extracted binaries in the stage location so that the other nodes can consume them.

1. Configure the auto upgrade parameters.

	```
	<copy>
	ahfctl setupgrade -all
	</copy>
	```
	Command output:

	```
	Enter autoupgrade flag <on/off> : on
	Enter software stage location : /acfs01
	Enter auto upgrade frequency : 30
	AHF autoupgrade parameters successfully updated
	Successfully synced AHF configuration
	refreshConfig() completed successfully.
	```

2. Check if the AHF installer zip file exists in the stage location.

	```
	<copy>
	ls -lart /acfs01
	</copy>
	```

	Command output:

	```
	total 387862
	-rw-r--r--+  1 root root       1520 Apr 30  2020 README.txt
	-rw-r--r--+  1 root root        625 Nov  1 15:15 oracle-tfa.pub
	-rw-r--r--+  1 root root        384 Jan  4 22:45 ahf_setup.dat
	-rwxr-xr-x+  1 root root  392587026 Mar  9 01:55 ahf_setup
	```

3. Run the upgrade command.

	```
	<copy>
	ahfctl upgrade
	</copy>
	```

	Command output:

	```
	AHF Installer for Platform Linux Architecture x86_64
	AHF Installation Log : /tmp/ahf_install_221000_139332_2022_03_09-02_09_42.log
	Starting Autonomous Health Framework (AHF) Installation
	AHF Version: 22.1.0 Build Date: 202203081742
	AHF is already installed at /opt/oracle.ahf
	Installed AHF Version: 22.1.0 Build Date: 202203081714
	Upgrading /opt/oracle.ahf
	Shutting down AHF Services
	Nothing to do !
	Shutting down TFA
	Removed symlink /etc/systemd/system/multi-user.target.wants/oracle-tfa.service.
	Removed symlink /etc/systemd/system/graphical.target.wants/oracle-tfa.service.
	Successfully shutdown TFA..
	Starting AHF Services
	Starting TFA..
	Waiting up to 100 seconds for TFA to be started..
	. . . . .
	Successfully started TFA Process..
	. . . . .
	TFA Started and listening for commands
	No new directories were added to TFA
	Directory /u01/app/grid/crsdata/scao05adm07/trace/chad was already added to TFA Directories.
	INFO: Starting exachk scheduler in background. Details for the process can be found at /u01/app/grid/oracle.ahf/data/scao05adm07/diag/exachk/compliance_start_090322_021151.log
	AHF is successfully upgraded to latest version
	.-------------------------------------------------------------------.
	| Host        | TFA Version | TFA Build ID         | Upgrade Status |
	+-------------+-------------+----------------------+----------------+
	| scao05adm07 |  22.1.0.0.0 | 22100020220308174218 | UPGRADED       |
	| scao05adm08 |  22.1.0.0.0 | 22100020220308171448 | UPGRADED       |
	'-------------+-------------+----------------------+----------------'
	Moving /tmp/ahf_install_221000_139332_2022_03_09-02_09_42.log to /u01/app/grid/oracle.ahf/data/scao05adm07/diag/ahf/
	Please upgrade AHF on the below mentioned nodes as well using ahfctl upgrade
	scao05adm08
	```

4. Validate the AHF installer zip is removed and the extracted binaries are retained.

	```
	<copy>
	ls -lart /acfs01
	</copy>
	```
	Command output:

	```
	-rw-r--r--+  1 root root       1520 Apr 30  2020 README.txt
	-rw-r--r--+  1 root root        625 Nov  1 15:15 oracle-tfa.pub
	-rw-r--r--+  1 root root        384 Jan  4 22:45 ahf_setup.dat
	-rwxr-xr-x+  1 root root  392587026 Mar  9 01:55 ahf_setup
	```
## Task 10: Upgrade AHF on Network File System (NFS)

>**Note** The scope of this workshop is limited to upgrading AHF on the local file system because enabling ACFS and configuring the NFS path location is not possible in this environment.

- If the stage location is NFS and if the AHF installer zip file exists in the stage location, then the installer asks the user to extract it.
- If the stage location has AHF binaries in the extracted form, then after upgrading, the installer retains the extracted AHF binaries as is.
- If the stage location has AHF installer zip file, then after upgrading, the installer removes the AHF installer zip file.

1. Configure the auto upgrade parameters.

	```
	<copy>
	ahfctl setupgrade -all
	</copy>
	```
	Command output:

	```
	Enter autoupgrade flag <on/off> : on
	Enter software stage location : /export/sheisey_R/ahf_stage
	Stage location /export/sheisey_R/ahf_stage file system type is NFS. User needs to unzip AHF zip placed at NFS file system.
	Enter auto upgrade frequency : 30
	AHF autoupgrade parameters successfully updated
	Successfully synced AHF configuration
	refreshConfig() completed successfully.
	```

2. Check if the AHF installer zip file or AHF binaries in the extracted form exists in the stage location.

	```
	<copy>
	ls -lart /export/sheisey_R/ahf_stage
	</copy>
	```
	Command output:

	```
	-rw-r--r--    1 root root  389105013 Feb  3 06:08 AHF-LINUX_v22.1.0.zip
	-rw-r--r--+  1 root root       1520 Apr 30  2020 README.txt
	-rw-r--r--+  1 root root        625 Nov  1 15:15 oracle-tfa.pub
	-rw-r--r--+  1 root root        384 Jan  4 22:45 ahf_setup.dat
	-rwxr-xr-x+  1 root root  392587026 Mar  9 01:55 ahf_setup
	```

3. Run the upgrade command.

	```
	<copy>
	ahfctl upgrade
	</copy>
	```
	Command output:

	```
	AHF Installer for Platform Linux Architecture x86_64
	AHF Installation Log : /tmp/ahf_install_221000_139332_2022_03_09-02_09_42.log
	Starting Autonomous Health Framework (AHF) Installation
	AHF Version: 22.1.0 Build Date: 202203081742
	AHF is already installed at /opt/oracle.ahf
	Installed AHF Version: 22.1.0 Build Date: 202203081714
	Upgrading /opt/oracle.ahf
	Shutting down AHF Services
	Nothing to do !
	Shutting down TFA
	Removed symlink /etc/systemd/system/multi-user.target.wants/oracle-tfa.service.
	Removed symlink /etc/systemd/system/graphical.target.wants/oracle-tfa.service.
	Successfully shutdown TFA..
	Starting AHF Services
	Starting TFA..
	Waiting up to 100 seconds for TFA to be started..
	. . . . .
	Successfully started TFA Process..
	. . . . .
	TFA Started and listening for commands
	No new directories were added to TFA
	Directory /u01/app/grid/crsdata/scao05adm07/trace/chad was already added to TFA Directories.
	INFO: Starting exachk scheduler in background. Details for the process can be found at /u01/app/grid/oracle.ahf/data/scao05adm07/diag/exachk/compliance_start_090322_021151.log
	AHF is successfully upgraded to latest version
	.-------------------------------------------------------------------.
	| Host        | TFA Version | TFA Build ID         | Upgrade Status |
	+-------------+-------------+----------------------+----------------+
	| scao05adm07 |  22.1.0.0.0 | 22100020220308174218 | UPGRADED       |
	| scao05adm08 |  22.1.0.0.0 | 22100020220308171448 | UPGRADED       |
	'-------------+-------------+----------------------+----------------'
	Moving /tmp/ahf_install_221000_139332_2022_03_09-02_09_42.log to /u01/app/grid/oracle.ahf/data/scao05adm07/diag/ahf/
	Please upgrade AHF on the below mentioned nodes as well using ahfctl upgrade
	scao05adm08
	```

4. Validate if the AHF installer zip is removed and the extracted binaries are retained.

	```
	<copy>
	ls -lart /export/sheisey_R/ahf_stage
	</copy>
	```
	Command output:

	```
	-rw-r--r--+  1 root root       1520 Apr 30  2020 README.txt
	-rw-r--r--+  1 root root        625 Nov  1 15:15 oracle-tfa.pub
	-rw-r--r--+  1 root root        384 Jan  4 22:45 ahf_setup.dat
	-rwxr-xr-x+  1 root root  392587026 Mar  9 01:55 ahf_setup
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
