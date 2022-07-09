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

* Oracle recommends installing AHF as the **root** user. For this workshop, run the **sudo su** command to gain **root** access.
* Perl version 5.10 or later installed.

## Task 1: Open a terminal window

1. Click the LiveLabs URL.
2. Click **Start**.
3. Click **Run on LiveLabs**.
4. If prompted, then enter login credentials.
5. Click **Start**.
6. Click **Run on LiveLabs**.
7. Choose a date and time to run the workshop or you choose to start the workshop now.
8. Select the **I consent to receive emails from LiveLabs for my reservation** checkbox.
9. Click **Submit Reservation**.

    **My Reservations** page is displayed with the status of your reservation. You will also receive an email detailing the status of your reservation. Once the setup is done, My Reservations page is displayed with the **Status**, and the links to **Launch Workshop**, view **Details**, and **Remove** the workshop. You will also receive an email announcing that your workshop is ready.
10. Click **Launch Workshop**.

    You will be redirected to your workshop.
11. Click **View Login info**.

    **Reservation Information** dialog is displayed.
12. Copy the **Remote Desktop URL**, open a browser, and paste the link in the address bar.

    (or)

    Click **Lauch Remote Desktop**.
13. Click **Activities** at the upper-left corner, and then click the **Terminal** icon.

    >**Note:** When you log in to the terminal, you will be logging in as the **opc** user.

14. Click **Activities**, and then click the **LiveLabs** icon to view the technical content.

## Task 2: Install AHF on Linux or UNIX as root user in daemon mode

To obtain the fullest capabilities of Oracle Autonomous Health Framework (AHF), install it as **root**.

If Oracle Autonomous Health Framework is already installed, then reinstalling performs an upgrade to the existing location.

1. Switch to **root** user.

    ```
    <copy>
    sudo su
    </copy>
    ```
2. Unzip the **AHF-LINUX_<*version*>.zip** file to the **/tmp/ahf22.1.0** directory.

    ```
    <copy>
    unzip /home/opc/Downloads/AHF-LINUX_v22.1.0.zip -d /tmp/ahf22.1.0
    </copy>
    ```
    Command output:

    ```
    Archive:  /home/opc/Downloads/AHF-LINUX_v22.1.0.zip
    inflating: /tmp/ahf22.1.0/ahf_setup
    extracting: /tmp/ahf22.1.0/ahf_setup.dat
    inflating: /tmp/ahf22.1.0/README.txt
    inflating: /tmp/ahf22.1.0/oracle-tfa.pub
    ```

3. Run the **ahf_setup** script.

    ```
    <copy>/tmp/ahf22.1.0/ahf_setup</copy>
    ```

    Command output:

    <pre>
    AHF Installer for Platform Linux Architecture x86_64
    AHF Installation Log : /tmp/ahf_install_221000_12928_2022_07_06-13_24_29.log
    Starting Autonomous Health Framework (AHF) Installation
    AHF Version: 22.1.0 Build Date: 202205292144
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
    | ll46863-instance-ahf | RUNNING       | 14895 | 22303 | 22.1.0.0.0 | 22100020220529214423 |
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
    Moving /tmp/ahf_install_221000_12928_2022_07_06-13_24_29.log to /opt/oracle.ahf/data/ll46863-instance-ahf/diag/ahf/
    </pre>

## Task 3: Enable or disable Oracle ORAchk or Oracle EXAchk daemon to start automatically

Installing Oracle Autonomous Health Framework as **root** on Linux or Solaris automatically sets up and runs the Oracle ORAchk or Oracle EXAchk daemon.

The daemon restarts at 1 am every day to discover environment changes. The daemon runs a full local Oracle ORAchk check once every week at 3 am, and a partial run of the most impactful checks at 2 am every day through the **oratier1** or **exatier1** profiles. The daemon automatically purges the **oratier1** or **exatier1** profile run that runs daily, after a week. The daemon also automatically purges the full local run after 2 weeks. You can change the daemon settings after enabling **autostart**.

1. To disable auto start:

    ```
    <copy>
    ahfctl compliance -autostop
    </copy>
    ```

    Command output:

    ```
    Removing orachk cache discovery....
    No orachk cache discovery found.
    Successfully copied Daemon Store to Remote Nodes
    Removed orachk from inittab
    ```

2. To enable auto start:

    ```
    <copy>
    ahfctl compliance -autostart
    </copy>
    ```

    Command output:

    ```
    .  
    .  
    Successfully copied Daemon Store to Remote Nodes

    .  .  .  

    orachk is using TFA Scheduler. TFA PID: 14895
    Daemon log file location is : /opt/oracle.ahf/data/ll46863-instance-ahf/orachk/user_root/output/orachk_daemon.log
    ```

## Task 4: Install AHF on Linux or UNIX as non-root user in non-daemon mode

Install Oracle Autonomous Health Framework as a non-root user, for example, **opc**.

>**Note:**
- Perl version 5.10 or later is required to install Oracle Autonomous Health Framework.
- You cannot perform cluster-wide installation as a non-root user.

Oracle Autonomous Health Framework has reduced capabilities when you install it as a non-root user in non-daemon mode. Therefore, you cannot complete the following tasks:
- Automate diagnostic collections
- Collect diagnostics from remote hosts
- Collect files that are not readable by the Oracle Home owner, for example, **/var/log/messages**, or certain Oracle Grid Infrastructure logs

1. If you are logged in as **root**, then log out by running the **exit** command at the command prompt.
2. To install as **Oracle home** owner (**opc** user), use the **–ahf_loc** option, and optionally specify the **-notfasetup** option to prevent running any of the Oracle Trace File Analyzer processes.

    ```
    <copy>
    /tmp/ahf22.1.0/ahf_setup -ahf_loc /ahf -notfasetup
    </copy>
    ```
    Command output:

    ```
    AHF Installer for Platform Linux Architecture x86_64
    AHF Installation Log : /tmp/ahf_install_221000_30040_2022_07_06-13_51_45.log
    Starting Autonomous Health Framework (AHF) Installation
    AHF Version: 22.1.0 Build Date: 202205292144
    AHF Location : /ahf/oracle.ahf
    AHF Data Directory : /ahf/oracle.ahf/data
    Extracting AHF to /ahf/oracle.ahf
    AHF is deployed at /ahf/oracle.ahf
    ORAchk is available at /ahf/oracle.ahf/bin/orachk
    AHF binaries are available in /ahf/oracle.ahf/bin
    AHF is successfully installed
    Moving /tmp/ahf_install_221000_30040_2022_07_06-13_51_45.log to /ahf/oracle.ahf/data/ll46863-instance-ahf/diag/ahf/
    ```

    The installer script will throw an error as follows if you install AHF as the **root** user.

    ```
    [ERROR] : AHF-00014: AHF Location /ahf/oracle.ahf is not owned by root in directory hierarchy
    ```
For more information, run **ahf_setup -h**.

## Task 5: Run AHF on SELinux-enabled systems

SELinux runs in one of three modes:
- **Disabled:** The kernel uses only DAC rules for access control. SELinux does not enforce any security policy because no policy is loaded into the kernel.
- **Permissive:** The kernel does not enforce security policy rules but SELinux sends denial messages to a log file. This allows you to see what actions would have been denied if SELinux were running in enforcing mode. This mode is intended to used for diagnosing the behavior of SELinux.
- **Enforcing:** The kernel denies access to users and programs unless permitted by SELinux security policy rules. All denial messages are logged as AVC (Access Vector Cache) denials. This is the default mode that enforces SELinux security policy.

You can enable or disable SELinux. When enabled, SELinux can run either in **enforcing** or **permissive** mode.

To configure default SELinux mode, edit the configuration file for SELinux, **sudo vi /etc/selinux/config**, and set the value of the **SELINUX** directive to **disabled**, **enforcing**, or **permissive**.

```
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=enforcing
# SELINUXTYPE= can take one of these three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected.
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
```
Setting the value of the SELINUX directive in the configuration file persists across reboots.

>**Note:**
* SELinux is already setup in **Enforcing** mode. DO NOT change the mode and just proceed further with installing AHF.
* If you have performed [Task 4: Install AHF on Linux or UNIX as non-root user in non-daemon mode](#Task4:InstallAHFonLinuxorUNIXasnonrootuserinnondaemonmode), first uninstall AHF, and then proceed with the following steps.
* Install AHF as the **root** user.

1. To switch to **root** user:

    ```
    <copy>
    sudo su
    </copy>
    ```

2. To check the status of SELinux:    

    ```
    <copy>
    /usr/sbin/getenforce
    </copy>
    ```
    Command output:

    ```
    Enforcing
    ```

    The **getenforce** command returns **Enforcing**, **Permissive**, or **Disabled**.

3. To check the status of SELinux and the policy being used:

    ```
    <copy>
    /usr/sbin/sestatus
    </copy>
    ```
    Command output:

    ```
    SELinux status: enabled
    SELinuxfs mount: /sys/fs/selinux
    SELinux root directory: /etc/selinux
    Loaded policy name: targeted
    Current mode: enforcing
    Mode from config file: enforcing
    Policy MLS status: enabled
    Policy deny_unknown status: allowed
    Memory protection checking: actual (secure)
    Max kernel policy version: 31
    ```

4. To install AHF:

    ```
    <copy>
    /tmp/ahf22.1.0/ahf_setup
    </copy>
    ```

    >**Note:** AHF installer loads the policy and sets relevant contexts.

    Command output:

    Since you have already installed AHF, the installer script exits gracefully with a message, **AHF is already installed at /opt/oracle.ahf** as shown below.

    ```
    AHF Installer for Platform Linux Architecture x86_64
    AHF Installation Log : /tmp/ahf_install_221000_33802_2022_07_06-14_00_20.log
    Starting Autonomous Health Framework (AHF) Installation
    AHF Version: 22.1.0 Build Date: 202205292144
    AHF is already installed at /opt/oracle.ahf
    Installed AHF Version: 22.1.0 Build Date: 202205292144
    AHF is already running latest version. No need to upgrade.
    ```

    To install AHF, first uninstall, and then install it afresh.

    To uninstall, run **ahfctl uninstall -deleterepo -silent**

5. To check if the policy is loaded successfully:

    ```
    <copy>
    /usr/sbin/semodule -l | grep inittfa-policy
    </copy>
    ```
    Command output:
    ```
    inittfa-policy
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
