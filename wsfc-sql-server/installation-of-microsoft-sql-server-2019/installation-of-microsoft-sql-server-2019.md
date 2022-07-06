# Provision of the Compute Instance from Market Place Image for SQL Server 2019

## Introduction

This lab demonstrates how to provision Microsoft SQL Server 2019 from the Market Place Image in a Compute Instance.

Estimated Time:  1 hour

### Objectives
In this lab, you will learn to:
* Deploy Microsoft SQL Server 2019 from the marketplace image
* Register the Computer Instances to Active Directory Domain Controller

### Prerequisites

This lab assumes you have:
- A Free or LiveLabs Oracle Cloud account
- IAM policies to create resources in the compartment
- Required Subnets are available in VCN

##  Task 1: Provision the SQL Server 2019 from Market Place for Node1

1. Open the navigation menu, click **Marketplace**, and then click **All Applications**.

  ![OCI Marketplace](./images/compute-instance-oci.png "OCI Marketplace")

2. Marketplace **All Applications** will be shown below. Search for **SQL Server 2019** image and select the desired edition for SQL Server. The marketplace image is available in Enterprise and Standard Edition. Always On Basic Availability Groups provide a high availability solution for SQL Server from version 2016 and above on Standard Edition. An Availability Group supports a failover environment for a single database in Standard Edition.

  ![Search SQL server](./images/compute-instance-marketplace.png "Search SQL server")

3. Choose the compartment and click on **Launch Instance**. The screen will be taken to the launch Compute Instance.

  ![OCI launch Instance](./images/compute-instance-compartment.png "OCI launch Instance")

> **Note: You will be charged a minimum of 744 hours for the MS SQL Server Marketplace image.

4. Choose the Instance name and compartment, and select the desired Availability Domain.

  ![OCI create Compute Instance](./images/compute-instance-ad.png "OCI create Compute Instance")

5. Click on **Change Shape** to select the shape of the Instance.

  ![OCI Compute Instance shape](./images/compute-instance-shape.png "OCI Compute Instance shape")

6. Choose the compartment where the Compute Instance should reside, and then choose the private subnet as shown below the image.

  ![OCI Compute Instance VCN](./images/compute-instance-compart.png "OCI Compute Instance VCN")

7. Choose the default values and click on the **Create** Instance.

  ![OCI Compute Instance boot volume](./images/compute-instance-default.png "OCI Compute Instance boot volume")

8. Once the Compute Instance provisioning is completed, you will be able to see the Instance state is running.

  ![OCI Compute Instance status](./images/compute-instance-provision.png "OCI Compute Instance status")

##  Task 2: Provision the SQL Server 2019 from Market Place for Node2

* Repeat all steps from Task 1 to provision the Microsoft SQL Server from Marketplace for Node2 in the different private subnet.

##  Task 3:  Add the Node1 Server to Active Directory Domain

1. RDP to the bastion host and login to the Node1 server using the private IP.

2. Open **Control Panel**and navigate to **Network and Internet\Network and Sharing Center**.

  ![Windows network and sharing center](./images/windows-controlpanel.png "Windows network and sharing center")

3. Click on **Ethernet** connection, then click on **properties**.

  ![network and sharing ethernet properties](./images/windows-network-ethernet.png " ")
4. Click on **IPv4**, and then click on **properties**. Choose the ****Use the following DNS Server Addresses:** and enter the private IP address of the Domain you created in Lab1, then click **OK** to save the changes.

  ![Ethernet IP addresses](./images/windows-network-ip.png "Ethernet IP addresses")

5. Open the File Explorer, right-click on **This PC**, and then click on **properties**.
  ![Windows system properties](./images/windows-network-properties.png "Windows system properties")

6. The following popup will be opened, and click on **Change Settings**.

  ![Windows system change settings](./images/windows-network-changesettings.png " ")

7. Click on **Computer Name**, and then click on **Change**. Choose **Domain** and enter the domain name, then click **OK** to save the changes.

  ![Windows system name change](./images/windows-network-changedomain.png "Windows system name change")

8. The system will prompt for the domain administrator **username** and **password**. Provide the **domainname\username**and **password**, and then click on **OK** to apply the changes.

  ![Domain credentials](./images/windows-network-changepass.png "Domain credentials")

9. On successfully adding the server to the Domain, you can see the successful message shown below.

  ![Change in computer name](./images/windows-network-successful.png "Change in computer name")

10. The system will ask for a restart popup message on the screen. Click on "OK" to reboot the system.

  ![System restart popup message](./images/windows-restart.png "System restart popup message")

11. The system will prompt the popup on the screen, and then click on **Restart Now**.  

  ![System restart](./images/windows-restart-popup.png "System restart")

12. To view the **complete computer name**, open the **Control Panel** and then go to **System and SecuritySystem**.

  ![Computer name verification](./images/windows-domain-verify.png "Computer name verification")

##  Task 4:  Add the Node2 Server to Active Directory Domain

* Repeat all steps from Task 3 to add the Node2 server to Active Directory Domain.

  You may now **proceed to the next lab.**

## Learn More
- You can find more information about Launching a Windows Instance [here](https://docs.oracle.com/en-us/iaas/Content/GSG/Tasks/launchinginstanceWindows.htm)


## Acknowledgements
* **Author** - Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering
* **Contributors** -  Devinder Pal Singh, Senior Cloud Engineer, NA Cloud Engineering
* **Last Updated By/Date** - Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering, April 2022