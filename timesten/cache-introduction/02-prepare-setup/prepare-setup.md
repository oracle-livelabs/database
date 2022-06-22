# Prepare Setup

## Introduction

In this lab, you will download the Oracle Resource Manager (ORM) stack zip file needed to setup the resource needed to run this workshop. This workshop requires a compute instance and a Virtual Cloud Network (VCN) and subnet.

Estimated Time: 15 minutes

### Objectives

-   Download the workshop's ORM stack
-   Configure an existing Virtual Cloud Network (VCN) - optional

### Prerequisites

This lab assumes you have:

- An Oracle Cloud account with enough resources to run this workshop (minimum requirements are 4 OCPUS, 32 GB RAM, 100 GB storage and one VCN/subnet)

## Task 1: Download Oracle Resource Manager (ORM) stack zip file

1.  Click on the link below to download the Resource Manager zip file you need to build your environment: [tt-cache-intro.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/7x622_b5P2kJ5NnOo6fEg2u1Ez-UsH1KdO7u-974LcaydzFh6X2TjDv86lEafzGT/n/natdsecurity/b/stack/o/upgr2db19c-mkplc-freetier.zip)

2.  Save in your downloads folder.

We strongly recommend using this stack to create a self-contained/dedicated VCN with your instance(s). Skip to *Task 3* to follow our recommendations. If you would rather use an exiting VCN then proceed to the next task to update your existing VCN with the required Egress rules.

## Task 2: Adding security rules to an existing VCN

This workshop requires a certain number of ports to be available, a requirement that can be met by using the default ORM stack execution that creates a dedicated VCN. In order to use an existing VCN/subnet the following ports should be added to the Egress rules.

| Port           |Description                            |
| :------------- | :------------------------------------ |
| 22             | SSH                                   |
| 6080           | Remote Desktop using noVNC            |

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

Using the details from the two steps above, proceed to the lab *Environment Setup* to setup your workshop environment using Oracle Resource Manager (ORM) using one of the following options:

  -  Create Stack:  *Compute + Networking*
  -  Create Stack:  *Compute only* using an existing VCN where security lists have been updated as per *Task 2* above

You may now *proceed to the next lab*.

## Acknowledgements

* **Author** - Chris Jenkins, Senior Director, TimesTen Product Management
* **Contributors** -  Doug Hood & Jenny Bloom, TimesTen Product Management
* **Last Updated By/Date** - Chris Jenkins, July 2022
