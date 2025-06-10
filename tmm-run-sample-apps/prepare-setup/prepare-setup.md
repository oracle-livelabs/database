# Prepare Setup

## Introduction
This lab will show you how to download the Oracle Resource Manager (ORM) stack zip file needed to set up the resource needed to run this workshop. This workshop requires a compute instance running the Transaction Manager for Microservices image with a Virtual Cloud Network (VCN).

*Estimated Lab Time:* 10 minutes

Watch the video below for a quick walk-through of the lab.
[Prepare Setup](videohub:1_ycv4qeb2)

### Objectives
-   Download ORM stack
-   Configure an existing Virtual Cloud Network (VCN)

### Prerequisites

This lab assumes you have:

- An Oracle Cloud account

## Task 1: Download Oracle Resource Manager (ORM) stack ZIP file
1.  Click the following link to download the Resource Manager ZIP file that you need to build your environment.

    - [tmm-mkplc-freetier.zip](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/data-management-library-files/ll-orm-microtx-xa-free-freetier.zip)

2. Save the ZIP file in your downloads folder.

Oracle strongly recommends that you use this stack to create a self-contained or dedicated VCN with your instance(s). Skip to *Task 3* to follow our recommendations. If you would rather use an existing VCN, then proceed to the next task to update your existing VCN with the required Ingress rules.

## Task 2: Add security rules to an existing VCN

This workshop requires a certain number of ports to be available, a requirement that can be met by using the default ORM stack execution that creates a dedicated VCN. To use an existing VCN/subnet, the following rules should be added to the security list.

| Type    | Source Port | Source CIDR | Destination Port | Protocol | Description                |
| :------ | :---------: | :---------: | :--------------: | :------: | :------------------------- |
| Ingress |     All     |  0.0.0.0/0  |        22        |   TCP    | SSH                        |
| Ingress |     All     |  0.0.0.0/0  |        80        |   TCP    | Remote Desktop using noVNC |
| Egress  |     All     |     N/A     |        80        |   TCP    | Outbound HTTP access       |
| Egress  |     All     |     N/A     |       6080       |   TCP    | noVNC Remote Desktop       |
{: title="List of Required Network Security Rules"}

<!-- **Notes**: This next table is for reference and should be adapted for the workshop. If optional rules are needed as shown in the example below, then uncomment it and add those optional rules. The first entry is just for illustration and may not fit your workshop -->

<!--
| Type    | Source Port | Source CIDR | Destination Port | Protocol | Description                    |
| :------ | :---------: | :---------: | :--------------: | :------: | :----------------------------- |
| Ingress |     All     |  0.0.0.0/0  |       443        |   TCP    | e.g. Remote access for web app |
{: title="List of Optional Network Security Rules"}
-->

1. Go to **Networking** >> **Virtual Cloud Networks**
2. Choose your network.
3. Under **Resources**, select **Security Lists**.
4. Click **Default Security Lists** under **Create Security List**.
5. Click **Add Ingress Rule**.
6. Enter the following:
    - Source Type: CIDR
    - Source CIDR: 0.0.0.0/0
    - IP Protocol: TCP
    - Source Port Range: All (Keep Default)
    - Destination Port Range: *Select from the above table*
    - Description: *Select the corresponding description from the above table*
7. Click **Add Ingress Rules**.
8. Repeat steps [5-7] until you create a rule for each port listed in the table.

## Task 3: Setup Compute
Using the details from the two tasks that you have previously completed, proceed to the next lab *Environment Setup* to set up your workshop environment using Oracle Resource Manager (ORM) and use one of the following options:

-  Create Stack:  *Compute + Networking* (Oracle strongly recommends that you use this option.)
-  Create Stack:  *Compute only* with an existing VCN where security lists have been updated as per *Task 2* above

You may now **proceed to the next lab**.

## Acknowledgements
* **Author** - Rene Fontcha, LiveLabs Platform Lead, NA Technology
* **Contributors** - Meghana Banka
* **Last Updated By/Date** - Sylaja Kannan, December 2022
