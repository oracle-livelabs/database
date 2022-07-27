# Prepare Setup

## Introduction

In this lab, you will download the Oracle Resource Manager (ORM) stack zip file needed to set up the resources needed to run this workshop. This workshop requires a compute instance and a Virtual Cloud Network (VCN) and subnet.

Estimated Time: **15 minutes**

### Objectives

-   Download the workshop's ORM stack
-   Configure an existing Virtual Cloud Network (VCN) - optional

### Prerequisites

This lab assumes you have:

- An Oracle Cloud account with enough resources to run this workshop. The minimum requirements are **4 CPUs, 32 GB RAM, 100 GB storage and one VCN/subnet**.

## Task 1: Download Oracle Resource Manager (ORM) stack zip file

1.  Click on the link below to download the Resource Manager zip file you need to build your environment:

 [timesten-mkplc-freetier.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/47ShQ4Xe1mUQOSeXXJGUL1zM1jYfYXR1YNJTIH0jTDHRYzsZjR5UQx37cCSXsxdt/n/natdsecurity/b/stack/o/timesten-mkplc-freetier.zip)

2.  Save in your downloads folder.

We strongly recommend using this stack to create a self-contained/dedicated VCN with your instance(s). Skip to *Task 3* to follow our recommendations. If you would rather use an exiting VCN then proceed to the next task to update your existing VCN with the required Egress rules.

## Task 2: Adding security rules to an existing VCN

This workshop requires a certain number of ports to be available, a requirement that can be met by using the default ORM stack execution that creates a dedicated VCN. In order to use an existing VCN/subnet, the following ports should be added to the Ingress rules.

| Port           |Description                            |
| :------------- | :------------------------------------ |
| 22             | SSH                                   |
| 80             | Remote Desktop using noVNC            |


1.  Go to *Networking >> Virtual Cloud Networks*

2.  Choose your network

3.  Under Resources, select *Security Lists*

4.  Click on *Default Security Lists* under the Create Security List button

5.  Click the *Add Ingress Rule* button

6.  Enter the following:
    - Source CIDR: 0.0.0.0/0
    - Destination Port Range: *Refer to the above table*

7.  Click the Add Ingress Rules button

## Task 3: Setup your OCI compute instance

Using the details from the two steps above, proceed to the lab *Environment Setup* to set up your workshop environment using Oracle Resource Manager (ORM) using one of the following options:

  -  Create Stack:  *Compute + Networking*
  -  Create Stack:  *Compute only* using an existing VCN where security lists have been updated as per *Task 2* above

**IMPORTANT**

When deploying the workshop compute instance via the ORM stack, as described in the next lab:

1. By default SSH access using a system generated SSH private key is enabled. SSH access is recommended for this workshop as it offers a better user experience, especially for copy/paste, than noVNC connectivity.

2. If you wish to provide your own SSH public key, uncheck the option *Auto Generate SSH Key Pair* and follow the on-screen instructions to either upload or copy/paste your SSH public key.  

3. Unless you wish to customize SSH connectivity as described in (2), you can accept all the defaults provided by the ORM stack.

You may now *proceed to the next lab (Environment setup)*.

## Acknowledgements

* **Author** - Chris Jenkins, Senior Director, TimesTen Product Management
* **Contributors** -  Doug Hood & Jenny Bloom, TimesTen Product Management
* **Last Updated By/Date** - Chris Jenkins, July 2022
