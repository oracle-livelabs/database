# Prepare setup

## Introduction

This lab will show you how to download the Oracle Resource Manager (ORM) stack zip file needed to setup the resource needed to run this workshop. This workshop requires a compute instance running the *Oracle Enterprise Manager 13c* Marketplace image with monitored database targets and a Virtual Cloud Network (VCN).

Estimated time: 10 minutes

### Objectives

 -   Download ORM stack
 -   Configure an existing Virtual Cloud Network (VCN)

### Prerequisites

This lab assumes you have -
 - A Free Tier, Paid or LiveLabs Oracle Cloud account

## Task 1: Download Oracle Resource Manager (ORM) stack zip file

1.  Click on the link below to download the Resource Manager zip file you need to build your environment:

	 - [emcc-dbae-2-mkplc-freetier.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/45QlbADtilX7TE3zpYeOrVyF5StsG3AOfdFU4BAiwWesx-spDYOrIbF3xqDS2lDV/n/natdsecurity/b/stack/o/emcc-dbae-2-mkplc-freetier.zip)

1.  Save in your downloads folder.

We recommend using this stack to create a self-contained/dedicated VCN with your instance(s). Skip to *Task 3* to follow our recommendations. If you would rather use an exiting VCN then proceed to the next task as indicated below to update your existing VCN with the required Egress rules.

## Task 2: Add Security Rules to an existing VCN   

This workshop requires a certain number of ports to be available, a requirement that can be met by using the default ORM stack execution that creates a dedicated VCN. In order to use an existing VCN, the following ports should be added to Egress rules.

| Port           | Description                           |
| :------------- | :------------------------------------ |
| 22             | SSH                                   |
| 7803           | Enterprise Manager 13c Server         |
| 6080           | noVNC Remote Desktop                  |

1.  Go to **Networking** > **Virtual Cloud Networks**
1.  Choose your network
1.  Under **Resources**, select **Security Lists**
1.  Click on **Default Security Lists** under the **Create Security List** button
1.  Click the **Add Ingress Rule** button
1.  Enter the following:  
    - Source CIDR: 0.0.0.0/0
    - Destination Port Range: *Refer to above table*
1.  Click the **Add Ingress Rules** button

## Task 3: Setup compute   

Using the details from the two tasks above, proceed to the lab **Setup compute instance** to setup your workshop environment using Oracle Resource Manager (ORM) and one of the following options:

 -  Create Stack:  **Compute + Networking**
 -  Create Stack:  **Compute only** with an existing VCN where security lists have been updated as per *Task 2* above

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - Rene Fontcha, LiveLabs Platform Lead, NA Technology
- **Contributors** - Meghana Banka
- **Last Updated By/Date** - Rene Fontcha, LiveLabs Platform Lead, NA Technology, April 2022
