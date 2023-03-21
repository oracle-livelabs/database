# Prepare Setup

## Introduction
This lab will show you how to download the Oracle Resource Manager (ORM) stack zip file needed to setup the resource needed to run this workshop. This workshop requires a compute instance running the Oracle Enterprise Manager 13c Marketplace image with monitored database targets and a Virtual Cloud Network (VCN).

*Estimated Time:* 15 minutes

### Objectives
-   Download ORM stack
-   Configure an existing Virtual Cloud Network (VCN)

### Prerequisites
This lab assumes you have -
- An Oracle Free Tier or Paid Cloud account

## Task 1: Download Oracle Resource Manager (ORM) stack zip file
1.  Click on the link below to download the Resource Manager zip file you need to build your environment: [emcc-de-mkplc-freetier.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/g-lr0Sxu62wacBSXQDDS-YmOgDrXLvjEPLbiQ7_8FKHLf7DZ8VJ1vc7ITJGvduWi/n/natdsecurity/b/stack/o/emcc-de-mkplc-freetier.zip)

2.  Save in your downloads folder.

We recommend using this stack to create a self-contained/dedicated VCN with your instance(s). Skip to *Task 3* to follow our recommendations. If you would rather use an exiting VCN then proceed to the next task as indicated below to update your existing VCN with the required Egress rules.

## Task 2: Adding Security Rules to an Existing VCN   
This workshop requires a certain number of ports to be available, a requirement that can be met by using the default ORM stack execution that creates a dedicated VCN. In order to use an existing VCN, the following ports should be added to Egress rules.

| Port           |Description                            |
| :------------- | :------------------------------------ |
| 22             | SSH                                   |
| 7803           | Enterprise Manager 13c Server         |
| 6080           | noVNC Remote Desktop                  |

1.  Go to **Networking** > **Virtual Cloud Networks**
2.  Choose your network
3.  Under Resources, select Security Lists
4.  Click on Default Security Lists under the Create Security List button
5.  Click Add Ingress Rule button
6.  Enter the following:  
    - Source CIDR: 0.0.0.0/0
    - Destination Port Range: *Refer to above table*
7.  Click the Add Ingress Rules button

## Task 3: Setup Compute   
Using the details from the two tasks above, proceed to the lab **Setup Compute Instance** to setup your workshop environment using Oracle Resource Manager (ORM) and one of the following options:
-  Create Stack:  **Compute + Networking**
-  Create Stack:  **Compute only** with an existing VCN where security lists have been updated as per *Task 2* above

## Acknowledgements
- **Author** - Rene Fontcha, LiveLabs Platform Lead, NA Technology
- **Contributors** -  
- **Last Updated By/Date** - Rene Fontcha, LiveLabs Platform Lead, NA Technology, December 2021
