# Prepare setup

## Introduction

This lab will show you how to download the Oracle Resource Manager (ORM) stack zip file needed to setup the resource needed to run this workshop. This workshop requires a compute instance running a marketplace image and a Virtual Cloud Network (VCN).

Estimated time: 10 minutes

### Objectives

 -   Download ORM stack
 -   Configure an existing Virtual Cloud Network (VCN)

### Prerequisites

This lab assumes you have -
 -   An Oracle Cloud account

## Task 1: Download Oracle Resource Manager (ORM) stack zip file

1.  Click on the link below to download the Resource Manager zip file you need to build your environment:

    - [db21c-dbae-mkplc-freetier.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/ZdyeiKou7tdfayF1zF1NmPtpUGFTvKjSY5SC46H8NBNlPAxtOWmZJUDsWoeFHQJF/n/natdsecurity/b/stack/o/db21c-dbae-mkplc-freetier.zip)

1.  Save in your downloads folder.

We recommend using this stack to create a self-contained/dedicated VCN with your instance(s). Skip to *Task 3* to follow our recommendations. If you would rather use an existing VCN, then proceed to the next task as indicated below to update your existing VCN with the required Egress rules.

## Task 2: Add security rules to an existing VCN

This workshop requires a certain number of ports to be available, a requirement that can be met by using the default ORM stack execution that creates a dedicated VCN. In order to use an existing VCN, the following ports should be added to Egress rules.

| Port           | Description                           |
| :------------- | :------------------------------------ |
| 22             | SSH                                   |
| 6080           | noVNC Remote Desktop                  |
{: title="Add ports to VCN"}

1.  Go to **Networking** &gt; **Virtual Cloud Networks**.
1.  Choose your network.
1.  Under **Resources**, select **Security Lists**.
1.  Click on **Default Security Lists** under the **Create Security List** button.
1.  Click the **Add Ingress Rule** button.
1.  Enter the following:  
    - Source CIDR: 0.0.0.0/0
    - Destination Port Range: *Refer to the table*
1.  Click the **Add Ingress Rules** button.

## Task 3: Setup compute

Using the details from the previous two tasks, proceed to the lab **Setup compute instance** to setup your workshop environment using Oracle Resource Manager (ORM) and one of the following options:

 -  Create Stack:  **Compute + Networking**
 -  Create Stack:  **Compute only** with an existing VCN where security lists have been updated as per *Task 2* of this lab

You may now **proceed to the next lab**.

## Acknowledgments

 - **Author** - Rene Fontcha, LiveLabs Platform Lead, NA Technology
 - **Contributors** - Meghana Banka, Manish Garodia
 - **Last Updated By/Date** - Rene Fontcha, LiveLabs Platform Lead, NA Technology, April 2022
