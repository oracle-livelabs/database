# Setup Windows bastion host and Windows AD Domain Services

## Introduction

This lab walks you through creating a Windows bastion host and setting up the Active Directory Domain Services in a Compute Instance. It involves creating the Windows bastion host and Windows server in a Compute Instance and installing and configuring the Microsoft Active Directory Domain Services.

Estimated Time:  1 Hour 30 min

### Objectives
In this lab, you will learn to :
* Setup the Windows bastion host
* Setup the Windows Active Directory Domain Services in Compute Instance

### Prerequisites  

This lab assumes you have:
- A Free or LiveLabs Oracle Cloud account
- IAM policies to create resources in the compartment
- Required Subnets are available in VCN

##  Task 1: Create the Bastion host in Public Subnet

1. Open the navigation menu, click **Compute**, and then click **Instances**.

  ![OCI Compute Instance](./images/create-instance-oci.png "OCI Compute Instance")

2. Compute will show the page below. The Compute service helps you provision VMs and bare metal Instances to meet your compute and application requirements. Navigate to **Instances**, and then click on **Create Instance**.

  ![OCI Compute Instance create Instance](./images/create-instance.png "OCI Compute Instance create Instance")

3. Choose the Instance name and compartment where the Compute Instance needs to create and select the desired Availability Domain.

  ![OCI Compute instance name](./images/create-instance-name.png "OCI Compute instance name")

4. Click on **Change image** to select the edition of Windows image build and Click on **Change Shape** to choose the Shape of the Instance.

  ![OCI Compute instance shape select](./images/create-instance-shape.png "OCI Compute instance shape select")

5. Choose the compartment where the Compute Instance should reside and then choose the public subnet as shown below. Click on assign a public IPv4 address to connect from the public internet.

  ![OCI Compute Instance VCN](./images/create-instance-comp.png "OCI Compute Instance VCN")

6. Choose the default values and click on the **Create** Instance.

  ![OCI create Compute Instance](./images/create-instance-bootvolume.png "OCI create Compute Instance")

7. The Compute Instance will be in a provisioning state shown in the below image.

  ![OCI create Compute Instance](./images/create-instance-provisioning.png "OCI create Compute Instance")

8. Once the Compute Instance is provisioned successfully, the Instance state will be running state.

  ![OCI Compute Instance status](./images/create-instance-running.png "OCI Compute Instance status")

9. You can connect to the newly created Instance via Remote Desktop using the **opc** username and the initial password shown in the console; the user must change the password at the next logon. The Compute Instance must allow RDP TCP port **3389** in the security list.

  ![OCI Compute Instance RDP username](./images/create-instance-userdetails.png "OCI Compute Instance RDP username")

  You may now **proceed to the next Task**.

##  Task 2: Create the Windows Domain Controller in Private Subnet

1. Open the navigation menu, click on **Compute**, and then click **Instances**.

  ![OCI Compute Instance](./images/create-instance-oci.png "OCI Compute Instance")

2. Navigate to **Instances**, and then click on **Create Instance**.

  ![OCI Compute Instance create Instance](./images/create-instance.png "OCI Compute Instance create instance")

3. Choose the Instance name and compartment where the Compute Instance needs to be created and select the desired Availability Domain.

  ![OCI Compute Instance name](./images/create-instance-name-msdc.png "OCI Compute Instance name")

4. Click on **Change image** to select the required Windows image and click on **Change shape** to select the instance shape.

  ![OCI Compute Instance shape select](./images/create-instance-shape.png "OCI Compute Instance shape select")

5. Choose the compartment where the Compute Instance resides, then choose the private subnet as shown below. Since we have chosen a private subnet, the public IP address is selected as Do not assign a public IPv4 address automatically.

  ![OCI Compute Instance VCN](./images/create-instance-comp-msdc.png "OCI Compute Instance VCN")

6. Choose the default values and click on Create Instance.

  ![OCI create Compute Instance](./images/create-instance-bootvolume.png "OCI create Compute Instance")

7. The Compute Instance will be in a provisioning state shown in the below image.

  ![OCI Compute Instance status](./images/create-instance-provisioning-msdc.png "OCI Compute Instance status")

8. Once the Compute Instance provisioning is completed, you will be able to see the Instance state is running.

  ![OCI Compute Instance status](./images/create-instance-running-msdc.png "OCI Compute Instance status")

9. You can connect to the newly created Instance via Remote Desktop using the **opc** username and the initial password shown in the console; the user must change the password at the next logon. The Compute Instance must allow RDP TCP port **3389** in the security list.

  ![OCI Compute Instance RDP username](./images/create-instance-userdetails-msdc.png "OCI Compute Instance RDP username")

10. From the Bastion host server using the username **opc** and password, open the Remote Desktop and connect to the Domain Controller server using the private IP address.

11. From the taskbar, click the **search button** and search for **run**. Once the run command opens, type **lusrmgr.msc** to open the local users.

  ![Windows run command](./images/windows-run-command.png "Windows run command")

12. Once open, click on **Local Users and Group**. Click on **Users** and right-click on **Administrator** to set the password. The password reset is needed to run successful  **Prerequisites**  during the Domain creation.

  ![Windows local users and groups wizard](./images/windows-command-lusrmgr.png "Windows local users and groups wizard")
  ![Windows local users and groups Administrator password reset](./images/windows-user-pass-reset.png "Windows local users and groups Administrator password reset")

13. From the taskbar, click the **search button**, search for Server Manager, and click on Server Manager.

  ![Windows server manager search](./images/windows-command-search.png "Windows server manager search")

14. Click on **Add roles and features**.

  ![Windows server manager add roles and features](./images/windows-servermanager-addrole.png "Windows server manager add roles and features")

15. The Add Roles and Features Wizard look like the following image and then click on **Next**.

  ![Windows server manager add roles and features wizard](./images/windows-servermanager-begin.png "Windows server manager add roles and features wizard")

16. Choose the Installation Type **Role-based or feature-based Installation**, and then click on **Next**.

  ![Windows server manager installation type](./images/windows-servermanager-installtype.png "Windows server manager installation type")

17. Choose the Server Selection Type **Select a server from the server pool**, and then click on **Next**.

  ![Windows server manager server selection](./images/windows-servermanager-serverselection.png "Windows server manager server selection")

18. Choose the Server Roles **Active Directory Domain Services**, click on **Add Features**, and then click on **Next**.

  ![Windows server manager roles selection](./images/windows-servermanager-serverroles.png "Windows server manager roles selection")

19. Select the features **Telnet Client**, which will be required to perform the ping test, and then click **next**.

  ![Windows server manager features selection](./images/windows-servermanager-featuresselect.png "Windows server manager features selection")

20. In the AD DS section, and then click on **next**.

    ![Windows server manager AD DS selection](./images/windows-servermanager-ADDS.png "Windows server manager AD DS selection")

21. The confirmation will show the details for roles, role services, or features on selected servers. Select **Restart the destination server automatically if required**. A pop-up will appear asking you to confirm the auto restart. Click **Install** to continue with the installation.

    ![Windows server manager confirmation](./images/windows-servermanager-restart.png "Windows server manager confirmation")

22. The **Results** section in the installation progress shows that the installation succeeded and the configuration required message, as shown in the image below, and then click **close**.

    ![Windows server manager progress results](./images/windows-servermanager-results.png "Windows server manager progress results")

23. Click the **search button** in the taskbar, search for "Server Manager," and click on "Server Manager." Click on the flag and click on **Promote the server to a Domain Controller**.

    ![Windows server manager promotes the server to a Domain Controller](./images/windows-servermanager-prompt.png "Windows server manager promotes the server to a Domain Controller")

24. From the **Deployment Configuration**, select **Add a new forest** and provide the desired Domain name in **Root Domain name:**, click on **Next**.

    ![Windows AD deployment configuration](./images/windows-servermanager-addnew.png "Windows AD deployment configuration")

25. In the **Domain Controller Options**, enter the **DSRM** password and click **Next**.

    ![Windows Domain Controller options](./images/windows-servermanager-dsrm.png "Windows Domain Controller options")

26. In the **DNS Options**, ignore the warning and click on **Next**.

    ![Windows DNS options](./images/windows-servermanager-dnsoptions.png "Windows DNS options")

27. The **NetBIOS Domain name:** will resolve automatically. Click on **Next**.

    ![Windows AD additional options](./images/windows-servermanager-netbios.png "Windows AD additional options")

28. choose the required paths for log files, and click on **Next**.

    ![Windows AD log location](./images/windows-servermanager-logpath.png "Windows AD log location")

29. In the **Review Options**, you can see the details settings. Click on **Next**.

    ![Windows AD review configuration](./images/windows-servermanager-reviewoptions.png "Windows AD review configuration")

30. The configuration will verify the required prerequisites checks, as shown in the image below. Click **Install** to complete the installation.

    ![Windows AD prerequisites](./images/windows-servermanager-prerequisites.png "Windows AD prerequisites")

31. Once the server is configured with the Domain Controller, the system will automatically restart.

    ![Windows AD success](./images/windows-servermanager-dc.png "Windows AD success")

32. To verify the Domain details, click the search button on the taskbar and type **dsa.msc** into the run command to open the Active Directory users and computers.

    ![Windows AD users and computers](./images/windows-command-dsa.png "Windows AD users and computers")

33. Open **Control Panel**, and navigate to   **Control Panel\System and Security\Windows Defender Firewall**.

    ![Control Panel\System and Security\Windows Defender Firewall](./images/windows-firewallbrowse.png "Control Panel\System and Security\Windows Defender Firewall")

34. In the **Customize settings**and choose the **Turn off Windows Firewall**, and then click on **OK** to apply the changes.

    ![Windows turn off Firewall](./images/windows-firewall-customsettings.png "Windows turn off Firewall")

35. To create Domain Administrator users, go to the taskbar and search for the run command; once the run command opens, type **dsa.msc** to open the Active Directory users and computers, then click on **users**.

    ![Create Domain user](./images/windows-create-ad-account.png "Create Domain user")

36. Provide the username details, and then click on **Next**.

    ![Create domain user details](./images/windows-create-ad-name.png "Create domain user details")

37. Provide the password and confirm the password, and then click on **Next**.

    ![Domain user password](./images/windows-create-ad-password.png "Domain user password")

38. Click on **Finish** to create the Domain user.

    ![Domain user successful creation](./images/windows-create-ad-finish.png "Domain user successful creation")

39. Double click on the newly created user, click on **Member of**, and then add the **Domain Admins** and click on **Apply** to add the **Domain Admins** to the newly created user.

    ![Granting Domain admins to users](./images/windows-create-ad-user-memberof.png "Granting Domain admins to users")

    You may now **proceed to the next lab**.

## Learn More
- You can find more information about Launching a Windows Instance [here](https://docs.oracle.com/en-us/iaas/Content/GSG/Tasks/launchinginstanceWindows.htm)


## Acknowledgements
* **Author** - Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering
* **Contributors** -  Devinder Pal Singh, Senior Cloud Engineer, NA Cloud Engineering
* **Last Updated By/Date** - Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering, June 2022
