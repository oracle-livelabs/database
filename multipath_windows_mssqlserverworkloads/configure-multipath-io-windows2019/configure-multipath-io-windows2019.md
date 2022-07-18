# Configure Multipath-IO (MPIO) on Windows Server 2019

## Introduction

This lab demonstrates how to Configure Multipath-IO (MPIO) on Windows Server 2019.

Estimated Time:  30 min

### Objectives
In this lab, you will learn to:
* Configure Multipath-IO (MPIO) on Windows Server 2019

### Prerequisites

This lab assumes you have:
- A Free or LiveLabs Oracle Cloud account
- IAM policies to create resources in the compartment
- Required Subnets are available in VCN

##  Task 1: Configure Multipath-IO (MPIO) on Windows Server 2019

1. RDP to the Windows host using the OPC user credentials.

2. From the taskbar, click **search button** and search for Server Manager and click on Server Manager.

  ![Windows Command Search](./images/windows-command-search.png "Windows Command Search")

3. once open the Server Manager, click on **Add roles and features**

  ![Windows Server Manager Add Role](./images/windows-servermanager-add.png "Windows Server Manager Add Role")

4. The Add Roles and Features Wizard look like the following image. Click on **next**

  ![Windows Server Manager wizard](./images/windows-servermanager-begin.png "Windows Server Manager wizard")

5. Choose the Installation Type **Role-based or feature-based Installation**, click on **next**

  ![Windows Server Manager wizard installation type](./images/windows-servermanager-installtype.png "Windows Server Manager wizard installation type")

6. Choose the Server Selection Type **Select a server from the server pool**, click on **next**

  ![Windows Server Manager wizard Server Selection](./images/windows-servermanager-serverselection.png "Windows Server Manager wizard Server Selection")

7. In **Server Role**, we need not select any role. Click on **Next**.

  ![Windows Server Manager wizard Server Selection](./images/windows-servermanger-serverrole.png "Windows Server Manager wizard Server Selection")

8. In **Features** section, select **Multipath I/O**, and click on **Next**.

  ![Windows Server Manager wizard Server features](./images/windows-servermanger-features.png "Windows Server Manager wizard Server features")

9. In **Confirmation**, click on **Install**.

  ![Windows Server Manager wizard Server confirmation](./images/windows-servermanger-confirmation.png "Windows Server Manager wizard Server confirmation")

10. The results will show as shown in the following image, and the installation required a restart to finish the installation. Click on **close**. 

  ![Windows Server Manager MPIO installation](./images/windows-servermanger-mpio-installation.png "Windows Server Manager MPIO installation")

11. Restart the Windows server from start menu. 

  ![Windows Server restart](./images/server-restart.png "Windows Server restart")

12. After successful restart, login to the server, and you can see **Multipath I/O** installed successfully.

  ![Multipath I/O Success](./images/windows-servermanger-mpio-verify.png "Multipath I/O Success")

  You may now **Proceed to the next lab.**

## Learn More
- You can find more information about Launching a Windows Instance [here](https://docs.oracle.com/en-us/iaas/Content/GSG/Tasks/launchinginstanceWindows.htm)


## Acknowledgements
* **Author** - Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering
* **Contributors** -  Jitender Singh, Senior Cloud Engineer, NA Cloud Engineering
* **Last Updated By/Date** - Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering, July 2022