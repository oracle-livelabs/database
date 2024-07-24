# Prepare Setup Daniel Was Here

## Introduction

In this lab, you will download the Oracle Resource Manager (ORM) stack zip file needed to setup the resource needed to run this workshop. This workshop requires a compute instance and a Virtual Cloud Network (VCN).

Estimated Time: 15 minutes

### Objectives

-   Download ORM stack
-   Configure an existing Virtual Cloud Network (VCN)

### Prerequisites

This lab assumes you have:

- An Oracle Cloud account

## Task 1: Download Oracle Resource Manager (ORM) stack zip file

1.  Click on the link below to download the Resource Manager zip file you need to build your environment: [xtts.zip](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/data-management-library-files/upgrade-and-patching/xtts.zip)

2.  Save in your downloads folder.

We strongly recommend using this stack to create a self-contained/dedicated VCN with your instance(s). Skip to *Step 3* to follow our recommendations. If you would rather use an exiting VCN then proceed to the next step as indicated below to update your existing VCN with the required Egress rules.

## Task 2: Adding security rules to an existing VCN

This workshop requires a certain number of ports to be available, a requirement that can be met by using the default ORM stack execution that creates a dedicated VCN. In order to use an existing VCN the following ports should be added to Egress rules

| Port | Description             |
| :--- | :---------------------- |
| 22   | SSH                     |
| 6080 | Remote Desktop noVNC () |

1.  Go to *Networking >> Virtual Cloud Networks*

2.  Choose your network

3.  Under Resources, select Security Lists

4.  Click on Default Security Lists under the Create Security List button

5.  Click Add Ingress Rule button

6.  Enter the following:
    - Source CIDR: 0.0.0.0/0
    - Destination Port Range: *Refer to above table*

7.  Click the Add Ingress Rules button

## Task 3: Setup compute

Using the details from the two steps above, proceed to the lab *Environment Setup* to setup your workshop environment using Oracle Resource Manager (ORM) and one of the following options:
  -  Create Stack:  *Compute + Networking*
  -  Create Stack:  *Compute only* with an existing VCN where security lists have been updated as per *Step 2* above

You may now *proceed to the next lab*.

## Acknowledgments
* **Author** - Daniel Overby Hansen
* **Contributors** - Klaus Gronau, Rodrigo Jorge, Mike Dietrich
* **Last Updated By/Date** - Daniel Overby Hansen, July 2024
