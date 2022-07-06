# Setup Windows Witness server for Windows Server Failover Cluster

## Introduction

This lab walks you through how to set up the Windows Server. This server is configured as the Witness server for the Cluster.  

Estimated Time:  30 min

### Objectives
In this lab, you will learn to :
* Setup the Windows Server for Witness
* Configure the Witness for the Windows Server Failover Cluster

### Prerequisites  

This lab assumes you have:
- A Free or LiveLabs Oracle Cloud account
- IAM policies to create resources in the compartment
- Required Subnets are available in VCN

##  Task 1: Create the Witness server in Private Subnet

1. Open the navigation menu, click **Compute**, and then click **Instances**.

  ![OCI Compute Instance](./images/compute-instance-oci.png "OCI Compute Instance")

2. Compute will show the page below. The Compute service helps you provision VMs and bare metal instances to meet your compute and application requirements. Navigate to **Instances**, and then click on **Create Instance**.

  ![OCI create Compute Instance](./images/compute-instance-create.png "OCI create Compute Instance")

3. Choose the Instance name and compartment where the Compute Instance needs to be created, and select the desired Availability Domain.

  ![OCI Compute Instance name](./images/compute-instance-name.png "OCI Compute Instance name")

4. Click on **Change image** to select the edition of Windows image build and Click on **Change shape** to choose the shape of the Instance.

  ![OCI Compute Instance shape](./images/compute-instance-shape.png "OCI Compute Instance shape")

5. Choose the compartment where the Compute Instance should reside, then choose the public subnet as shown below. Click on assign a public IPv4 address to connect from the public internet.

  ![OCI Compute Instance VCN](./images/compute-instance-ip.png "OCI Compute Instance VCN")

6. Choose the default values and click on **Create** Instance.

7. You can use the Remote Desktop to connect to the newly created Instance using the **opc** username and the initial password shown in the console. You need to change the password at the first login. The network that the Instance is in must allow RDP TCP port **3389** in the security list.
  ![OCI Compute Instance status](./images/compute-instance-successful.png "OCI Compute Instance status")

  You may now **proceed to the next Task**.

##  Task 2: Add the Witness Server to Active Directory Domain

  * Repeat steps from Lab 2: Task 3 to add the server to Active Directory Domain.

##  Task 3: Configure the Witness for the Windows Server Failover Cluster

1. RDP to the Bastion host server using the username **opc** and password. From the Bastion host, open the Remote Desktop and connect to the witness server using the private IP Address.

2. Create a folder name as a Witness and share the folder for read and write, and then click on Share folder.

  ![Windows Share folder](./images/windows-sharefolder.png "Windows Share folder")

  The settings will show in the following image.

  ![Windows Share folder network access](./images/windows-sharefolder-details.png "Windows Share folder network access")

3. The successful share folder shows as follows.
  ![Windows Share folder network access](./images/windows-sharefolder-successful.png "Windows Share folder network access")

##  Task 4: Configure the Witness in the Windows Server Failover Cluster

1. RDP to the Bastion host server using the username **opc** and password. From the Bastion host, open the Remote Desktop and connect to the Node1 or node2 server using the private IP Address.

2. From the taskbar, click the **search button** and search for **Failover Cluster**.

  ![Windows search command](./images/windows-command-search.png "Windows search command")

3. The Failover Cluster Manager opens as shown in the following image, and then right-click on the Cluster name, choose **More Actions**and then select the **Configure Cluster Quorum Settings**.

  ![Configure Cluster quorum from failover Cluster manager](./images/wsfc-quorum.png "Configure Cluster quorum from failover Cluster manager")

4. The configuration wizard shows as follows.

  ![Cluster quorum wizard](./images/wsfc-quorum-configruation.png "Cluster quorum wizard")

5. Select the **Select the Quorum Witness** option, and then click on **Next**.

  ![Cluster quorum options](./images/wsfc-quorum-configruation-select.png "Cluster quorum options")

6. Select the **Configure a file share Witness**, and then click on **Next**.

  ![Cluster quorum file share Witness](./images/wsfc-quorum-configruation-fileshare.png "Cluster quorum file share Witness")

7. Provide the path for the shared folder created in Task 3, then click on **Next**.

  ![Cluster quorum file Witness share path](./images/wsfc-quorum-sharepath.png "Cluster quorum file Witness share path")

8. The configuration **Confirmation** tab shows as follows, and then click on **Next**.

  ![Cluster quorum Witness share path confirmation](./images/wsfc-quorum-sharepath-confirmation.png "Cluster quorum Witness share path confirmation")

9. The **Summary** page shows as follows with a successful message, and then click on **Finish**.

  ![Cluster quorum file Witness configure status](./images/wsfc-quorum-sharepath-summary.png "Cluster quorum file Witness configure status")

10. The file share Witness will be online in the Cluster Manager.

  ![Cluster quorum Witness status](./images/wsfc-quorum-sharepath-online.png "Cluster quorum Witness status")

    Congratulations !!! You Have Completed Successfully The Workshop.

## Acknowledgements
* **Author** - Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering
* **Contributors** -  Devinder Pal Singh, Senior Cloud Engineer, NA Cloud Engineering
* **Last Updated By/Date** - Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering, June 2022