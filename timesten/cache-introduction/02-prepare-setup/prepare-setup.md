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

 [ll-timesten-cache-intro.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/zXF3WR--V6CG3ZmB1vgQcEcYYidDhuejeplM9oBUwiYGs-7BnN4YI2_TLVY82_-b/n/natdsecurity/b/stack/o/ll-timesten-cache-intro.zip)

2.  Save in your downloads folder.

We strongly recommend using this stack to create a self-contained/dedicated VCN with your instance(s). Skip to *Task 3* to follow our recommendations. If you would rather use an exiting VCN then proceed to the next task to update your existing VCN with the required Ingress rules.

## Task 2: Adding security rules to an existing VCN

This workshop requires a certain number of ports to be available, a requirement that can be met by using the default ORM stack execution that creates a dedicated VCN. In order to use an existing VCN/subnet, the following ports should be added to the Ingress rules.

| Source Port    | Source CIDR | Destination Port | Protocol | Description                           |
|   :--------:   |  :--------: |    :----------:  | :----:   | :------------------------------------ |
| All            | 0.0.0.0/0   | 22               | TCP      | SSH                                   |
| All            | 0.0.0.0/0   | 80               | TCP      | Remote Desktop using noVNC            |
{: title="List of Ports Required Opened (Ingress Rules)"}


1.  Go to *Networking >> Virtual Cloud Networks*
2.  Choose your network
3.  Under Resources, select Security Lists
4.  Click on Default Security Lists under the Create Security List button
5.  Click Add Ingress Rule button
6.  Enter the following:  
    - Source Type: CIDR
    - Source CIDR: 0.0.0.0/0
    - IP Protocol: TCP
    - Source Port Range: All (Keep Default)
    - Destination Port Range: *Select from above table*
    - Description: *Select corresponding description from above table*
7.  Click the Add Ingress Rules button
8. Repeat steps [5-7] until a rule is created for each port listed in the table

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
* **Contributors** -  Doug Hood, Jenny Bloom, Rene Fontcha
* **Last Updated By/Date** - Rene Fontcha, July 2022
