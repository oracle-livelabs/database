# Install Oracle Autonomous Health Framework (AHF)

## Introduction

In this lab, you will learn how to install AHF either as **root** or as a non-root user. You will also learn how to run AHF on SELinux-enabled systems.

Estimated Time: 30 minutes

### Objectives

In this lab, you will:
* (Recommended) Install AHF on Linux or UNIX as **root** user in daemon mode
* Install AHF on Linux or UNIX as a non-root user in non-daemon mode
* Run AHF on SELinux-enabled systems

### Prerequisites

This lab assumes you have:
* Oracle recommends installing AHF as the **root** user. For this workshop, run the **sudo su** command to gain **root** access.
* Perl version 5.10 or later installed.

## Task 1: Install AHF on Linux or UNIX as root User in Daemon Mode

To obtain the fullest capabilities of Oracle Autonomous Health Framework, install it as **root**.

Oracle Autonomous Health Framework maintains Access Control Lists (ACLs) to determine which users are allowed access. By default, the **Grid home** owner and **Oracle home** owners have access to their respective diagnostics. No other users can perform diagnostic collections.

If Oracle Autonomous Health Framework is already installed, then reinstalling performs an upgrade to the existing location.

1. Download and copy the **AHF-LINUX_<*version*>.zip** file to the **/tmp/ahf22.1.0** folder on the required machine, and then unzip it.

    ```
    unzip /home/opc/Downloads/AHF-LINUX_v22.1.0.zip -d /tmp/ahf22.1.0
    Archive:  /home/opc/Downloads/AHF-LINUX_v22.1.0.zip
      inflating: /tmp/ahf22.1.0/ahf_setup
      extracting: /tmp/ahf22.1.0/ahf_setup.dat
      inflating: /tmp/ahf22.1.0/README.txt
      inflating: /tmp/ahf22.1.0/oracle-tfa.pub
    </copy>
    ```

2. To ensure that the environment has been set correctly, enter the following commands:

    ```
    <copy>umask
    env | more
    </copy>
    ```

3. Verify that the **umask** command displays a value of **22**, **022**, or **0022**.

    ```
    <copy>umask
    0022
    </copy>
    ```

4. To install AHF as **root**, run the **ahf_setup** script:

    ```
    <copy>/tmp/ahf22.1.0/ahf_setup</copy>
    ```
    **Local installation:**

    ```
    <copy>
    ahf_setup
    AHF Installer for Platform Linux Architecture x86_64
    AHF Installation Log : /tmp/ahf_install_221000_103911_2022_02_02-13_38_15.log
    Starting Autonomous Health Framework (AHF) Installation
    AHF Version: 22.1.0 Build Date: 202201302324
    Default AHF Location : /opt/oracle.ahf
    Do you want to install AHF at [/opt/oracle.ahf] ? [Y]|N :
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
    | den02mwa | RUNNING       | 105916 | 59452 | 22.1.0.0.0 | 22100020220130232427 |
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
    </copy>
    ```
    If you plan to run only Oracle ORAchk or Oracle EXAchk and do not want to run any Oracle Trace File Analyzer processes, then use the install options **-extract -notfasetup**.

    ```
    <copy>
    ahf_setup -extract -notfasetup

    AHF Installer for Platform Linux Architecture x86_64
    AHF Installation Log : /tmp/ahf_install_221000_98374_2022_02_02-13_33_27.log
    Starting Autonomous Health Framework (AHF) Installation
    AHF Version: 22.1.0 Build Date: 202201302324
    Default AHF Location : /opt/oracle.ahf
    Do you want to install AHF at [/opt/oracle.ahf] ? [Y]|N :
    AHF Location : /opt/oracle.ahf
    AHF Data Directory : /opt/oracle.ahf/data
    Extracting AHF to /opt/oracle.ahf
    AHF is deployed at /opt/oracle.ahf
    ORAchk is available at /opt/oracle.ahf/bin/orachk
    AHF binaries are available in /opt/oracle.ahf/bin
    AHF is successfully installed
    Moving /tmp/ahf_install_221000_98374_2022_02_02-13_33_27.log to /opt/oracle.ahf/data/den02mwa/diag/ahf/
    </copy>
    ```

	  The installation prompts you to do a local or cluster installation.

	  Whether the installation is local or cluster-wide, the installer script configures Oracle Autonomous Health Framework for automatic startup. The implementation of auto-start is platform-dependent. Linux uses **init**, or an **init** replacement, such as **upstart** or **systemd** and Microsoft Windows uses a Windows service.

	  The installer prompts you to specify one or more email addresses of the recipients who can receive diagnostic notifications. Oracle Autonomous Health Framework notifies the recipients with the results of Oracle ORAchk and Oracle EXAchk compliance checking, or when Oracle Autonomous Health Framework detects significant faults.

	 **Cluster-wide Installation:**

	 **Note:** In this workshop, you can only install AHF on a local node.

## Task 2: Enable or Disable Oracle ORAchk or Oracle EXAchk Daemon to Start Automatically

Installing Oracle Autonomous Health Framework as **root** on Linux or Solaris automatically sets up and runs the Oracle ORAchk or Oracle EXAchk daemon.

The daemon restarts at 1 am every day to discover environment changes. The daemon runs a full local Oracle ORAchk check once every week at 3 am, and a partial run of the most impactful checks at 2 am every day through the **oratier1** or **exatier1** profiles. The daemon automatically purges the **oratier1** or **exatier1** profile run that runs daily, after a week. The daemon also automatically purges the full local run after 2 weeks. You can change the daemon settings after enabling **autostart**.

1. To disable auto start:

    ```
    <copy>
    orachk -autostop (or) ahfctl compliance -autostop
    Removing orachk cache discovery....
    Successfully completed orachk cache discovery removal.
    Successfully copied Daemon Store to Remote Nodes
    Removed orachk from inittab
    </copy>
    ```

2. To enable auto start:

    ```
    <copy>
    orachk -autostart (or) ahfctl compliance –autostart
    .
    .
    Successfully copied Daemon Store to Remote Nodes
    .  .  .
    orachk is using TFA Scheduler. TFA PID: 11552
    Daemon log file location is : /opt/oracle.ahf/data/den00pkf/orachk/user_root/output/orachk_daemon.log
    </copy>
    ```

## Task 3: Install AHF on Linux or UNIX as Non-root User in Non-Daemon Mode

If you are unable to install as **root**, then install Oracle Autonomous Health Framework as a non-root user, for example, **opc**.

**Note:**
- Perl version 5.10 or later is required to install Oracle Autonomous Health Framework.
- You cannot perform the cluster-wide installation as a non-root user.

Oracle Autonomous Health Framework has reduced capabilities when you install it as a non-root user in non-daemon mode. Therefore, you cannot complete the following tasks:
- Automate diagnostic collections
- Collect diagnostics from remote hosts
- Collect files that are not readable by the Oracle Home owner, for example, **/var/log/messages**, or certain Oracle Grid Infrastructure logs

1. To install as the **Oracle home** owner (**opc** user), use the **–ahf_loc** option, and optionally specify the **-notfasetup** option to prevent the running of any Oracle Trace File Analyzer processes.

    ```
    <copy>
    /tmp/ahf22.1.0/ahf_setup -ahf_loc /ahf -notfasetup

    AHF Installer for Platform Linux Architecture x86_64
    AHF Installation Log : /tmp/ahf_install_221000_540223_2022_06_06-20_36_32.log
    Starting Autonomous Health Framework (AHF) Installation
    AHF Version: 22.1.0 Build Date: 202205292144
    AHF Location : /ahf/oracle.ahf
    AHF Data Directory : /ahf/oracle.ahf/data
    Extracting AHF to /ahf/oracle.ahf
    AHF is deployed at /ahf/oracle.ahf
    ORAchk is available at /ahf/oracle.ahf/bin/orachk
    AHF binaries are available in /ahf/oracle.ahf/bin
    AHF is successfully installed
    Moving /tmp/ahf_install_221000_540223_2022_06_06-20_36_32.log to /ahf/oracle.ahf/data/ahf2/diag/ahf/
    </copy>
    ```

    The installer script throws an error if you install AHF as the **root** user.

    ```
    <copy>
    /tmp/ahf22.1.0/ahf_setup -ahf_loc /ahf -notfasetup -extract
    AHF Installer for Platform Linux Architecture x86_64
    AHF Installation Log : /tmp/ahf_install_221000_539881_2022_06_06-20_36_05.log
    Starting Autonomous Health Framework (AHF) Installation
    AHF Version: 22.1.0 Build Date: 202205292144
    AHF Location : /ahf/oracle.ahf
    [ERROR] : AHF-00014: AHF Location /ahf/oracle.ahf is not owned by root in directory hierarchy
    </copy>
    ```


	For more information, run **ahf_setup -h**.

## Task 4: Run AHF on SELinux-Enabled Systems

SELinux runs in one of three modes:
- **Disabled:** The kernel uses only DAC rules for access control. SELinux does not enforce any security policy because no policy is loaded into the kernel.
- **Permissive:** The kernel does not enforce security policy rules but SELinux sends denial messages to a log file. This allows you to see what actions would have been denied if SELinux were running in enforcing mode. This mode is intended to used for diagnosing the behavior of SELinux.
- **Enforcing:** The kernel denies access to users and programs unless permitted by SELinux security policy rules. All denial messages are logged as AVC (Access Vector Cache) denials. This is the default mode that enforces SELinux security policy.

You can enable or disable SELinux. When enabled, SELinux can run either in **enforcing** or **permissive** mode.

1. To configure default SELinux mode, edit the configuration file for SELinux, **/etc/selinux/config**, and set the value of the **SELINUX** directive to **disabled**, **enforcing**, or **permissive**.

    ```
    <copy>
    # This file controls the state of SELinux on the system.
    # SELINUX= can take one of these three values:
    #     enforcing - SELinux security policy is enforced.
    #     permissive - SELinux prints warnings instead of enforcing.
    #     disabled - No SELinux policy is loaded.
    SELINUX=enforcing
    # SELINUXTYPE= can take one of three two values:
    #     targeted - Targeted processes are protected,
    #     minimum - Modification of targeted policy. Only selected processes are protected.
    #     mls - Multi Level Security protection.
    SELINUXTYPE=targeted
    </copy>
    ```
Setting the value of the SELINUX directive in the configuration file persists across reboots.

2. To check the status of SELinux:    

    ```
    <copy>
    /usr/sbin/getenforce
    Permissive
    </copy>
    ```
The **getenforce** command returns **Enforcing**, **Permissive**, or **Disabled**.

3. To check the status of SELinux and the policy being used:

    ```
    <copy>
    /usr/sbin/sestatus
    SELinux status: enabled
    SELinuxfs mount: /sys/fs/selinux
    SELinux root directory: /etc/selinux
    Loaded policy name: targeted
    Current mode: permissive
    Mode from config file: permissive
    Policy MLS status: enabled
    Policy deny_unknown status: allowed
    Memory protection checking: actual (secure)
    Max kernel policy version: 31
    </copy>
    ```

4. To unload the SELinux policy:

    ```
    <copy>
    ahfctl unloadpolicy
    Please wait while the policy is being removed, it might take couple of minutes.
    Successfully removed Contexts and Policy
    </copy>
    ```

5. To switch from **Enforcing** to **Permissive** mode:

    ```
    <copy>
    /usr/sbin/setenforce 0
    </copy>
    ```

6. To switch from **Permissive** to **Enforcing** mode:

    ```
    <copy>
    /usr/sbin/setenforce 1
    </copy>
    ```

**Install AHF in Permissive or Enforcing Mode:**

AHF installer loads the policy and sets relevant contexts.

1. To install AHF:

    ```
    <copy>
    ahf_setup
    AHF Installer for Platform Linux Architecture x86_64
    AHF Installation Log : /tmp/ahf_install_221000_2193173_2022_02_23-22_35_59.log
    Starting Autonomous Health Framework (AHF) Installation
    AHF Version: 22.1.0 Build Date: 202202230349
    Default AHF Location : /opt/oracle.ahf
    Do you want to install AHF at [/opt/oracle.ahf] ? [Y]|N
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
    Created symlink /etc/systemd/system/multi-user.target.wants/oracle-tfa.service → /etc/systemd/system/oracle-tfa.service.
    Created symlink /etc/systemd/system/graphical.target.wants/oracle-tfa.service → /etc/systemd/system/oracle-tfa.service.
    .------------------------------------------------------------------------------------.
    | Host         | Status of TFA | PID     | Port  | Version    | Build ID             |
    +--------------+---------------+---------+-------+------------+----------------------+
    | phoenix78312 | RUNNING       | 2194746 | 36707 | 22.1.0.0.0 | 22100020220223034920 |
    '--------------+---------------+---------+-------+------------+----------------------'
    Running TFA Inventory...
    Adding default users to TFA Access list...
    .----------------------------------------------------------.
    |               Summary of AHF Configuration               |
    +-----------------+----------------------------------------+
    | Parameter       | Value                                  |
    +-----------------+----------------------------------------+
    | AHF Location    | /opt/oracle.ahf                        |
    | TFA Location    | /opt/oracle.ahf/tfa                    |
    | Orachk Location | /opt/oracle.ahf/orachk                 |
    | Data Directory  | /opt/oracle.ahf/data                   |
    | Repository      | /opt/oracle.ahf/data/repository        |
    | Diag Directory  | /opt/oracle.ahf/data/phoenix78312/diag |
    '-----------------+----------------------------------------'

    Starting orachk scheduler from AHF ...
    AHF binaries are available in /opt/oracle.ahf/bin
    AHF is successfully installed
    Do you want AHF to store your My Oracle Support Credentials for Automatic Upload ? Y|[N] :
    Moving /tmp/ahf_install_221000_2193173_2022_02_23-22_35_59.log to /opt/oracle.ahf/data/phoenix78312/diag/ahf/
    </copy>
    ```
2. To check if the policy is loaded successfully:

    ```
    <copy>
    /usr/sbin/semodule -l | grep inittfa-policy
    </copy>
    ```

**Install AHF in Disabled Mode**

In Disabled mode, AHF does not load the SELinux policy.

**Note:** Do not use this option. When you try to install AHF in Disabled mode, you have to restart the machine. This is not possible in this lab environment.

1. To check the status of SELinux and the policy being used:

    ```
    <copy>
    /usr/sbin/sestatus
    SELinux status: disabled
    </copy>
    ```
2. To check if the policy is loaded:

    ```
    <copy>
    ahfctl loadpolicy
    Checking if policy exists
    SELinux is not enabled on this system
    </copy>
    ```

3. To install AHF:

    ```
    <copy>
    ahf_setup
    AHF Installer for Platform Linux Architecture x86_64
    AHF Installation Log : /tmp/ahf_install_221000_16953_2022_02_23-14_43_58.log
    Starting Autonomous Health Framework (AHF) Installation
    AHF Version: 22.1.0 Build Date: 202202230349
    Default AHF Location : /opt/oracle.ah
    Do you want to install AHF at [/opt/oracle.ahf] ? [Y]|N :
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
    .------------------------------------------------------------------------------.
    | Host     | Status of TFA | PID   | Port  | Version    | Build ID             |
    +----------+---------------+-------+-------+------------+----------------------+
    | den02lpa | RUNNING       | 18320 | 15889 | 22.1.0.0.0 | 22100020220223034920 |
    '----------+---------------+-------+-------+------------+----------------------'
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
    | Diag Directory  | /opt/oracle.ahf/data/den02lpa/diag |
    '-----------------+------------------------------------'
    Starting orachk scheduler from AHF ...
    AHF binaries are available in /opt/oracle.ahf/bin
    AHF is successfully installed
    Do you want AHF to store your My Oracle Support Credentials for Automatic Upload ? Y|[N] :
    Moving /tmp/ahf_install_221000_16953_2022_02_23-14_43_58.log to /opt/oracle.ahf/data/den02lpa/diag/ahf/
    </copy>
    ```

After installing AHF if you switch the mode to Permissive or Enforcing, then SELinux starts blocking the AHF processes. Reboot the system for the switch in mode to take effect.

1. To run AHF, load the SELinux policy:

    ```
    <copy>
    ahfctl loadpolicy
    Checking if policy exists
    Please wait while the policy is being loaded, it might take couple of minutes.
    Successfully loaded SELinux policy
    Restarting TFA...
    </copy>
    ```

2. To check if the policy is loaded successfully:

    ```
    <copy>
    /usr/sbin/semodule -l | grep inittfa-policy
    </copy>	 
    ```

## Learn More

* [Installing and Upgrading Oracle Autonomous Health Framework](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/install-upgrade-ahf.html#GUID-663F0836-A2A2-4EFB-B19E-EABF303739A9)
* [ahfctl setupgrade](https://docs-uat.us.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/ahfctl-setupgrade.html#GUID-0AA4D7BE-781D-4345-BC77-A38AF10826BB)
* [ahfctl unsetupgrade](https://docs-uat.us.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/ahfctl-unsetupgrade.html#GUID-7757592D-7E68-44EB-9ED0-14731146CFF6)
* [ahfctl getupgrade](https://docs-uat.us.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/ahfctl-getupgrade.html#GUID-436F6822-FA11-4BE7-B28A-B8F0D9C01F97)
* [ahfctl upgrade](https://docs-uat.us.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/ahfctl-upgrade.html#GUID-7EB170D6-DC9F-4EE3-9DD8-B5374B856179)
* [Oracle Autonomous Health Framework Installation Command-Line Options](https://docs.oracle.com/en/engineered-systems/health-diagnostics/autonomous-health-framework/ahfug/install-ahf.html#GUID-F57C15E1-B82A-42A1-B064-B6C86639799F)

## Acknowledgements
* **Author** - Nirmal Kumar
* **Contributors** -  Sarahi Partida, Robert Pastijn, Girdhari Ghantiyala, Anuradha Chepuri
* **Last Updated By/Date** - Nirmal Kumar, June 2022
