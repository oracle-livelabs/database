# Setup Windows Bastion Host in Public Subnet

## Introduction

This lab walks you through creating a Windows bastion host in a Compute Instance public subnet. You will use the Bastion Host to connect the Remote Desktop sessions to private subnet servers. 

Estimated Time: 30 min

### Objectives
In this lab, you will learn to :
* Setup the Windows bastion host

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

7. The Compute Instance will be in a provisioning state, as shown in the below image.

  ![OCI create Compute Instance](./images/create-instance-provisioning.png "OCI create Compute Instance")

8. Once the Compute Instance is provisioned successfully, the Instance state will be running state.

  ![OCI Compute Instance status](./images/create-instance-running.png "OCI Compute Instance status")

9. You can connect to the newly created Instance via Remote Desktop using the **opc** username and the initial password shown in the console; the user must change the password at the next logon. The Compute Instance must allow RDP TCP port **3389** in the security list.

  ![OCI Compute Instance RDP username](./images/create-instance-userdetails.png "OCI Compute Instance RDP username")

  You may now **proceed to the next Task**.

## Learn More
- You can find more information about Launching a Windows Instance [here](https://docs.oracle.com/en-us/iaas/Content/GSG/Tasks/launchinginstanceWindows.htm)


## Acknowledgements
* **Author** - Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering
* **Contributors** -  Devinder Pal Singh, Senior Cloud Engineer, NA Cloud Engineering
* **Last Updated By/Date** - Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering, June 2022
