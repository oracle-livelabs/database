# Prepare Setup

## Introduction
This lab will show you how to download the Oracle Resource Manager (ORM) stack zip file needed to setup the resource needed to run this workshop. This workshop requires a compute instance running the Oracle GoldenGate Veridata Marketplace image and a Virtual Cloud Network (VCN).

*Estimated Lab Time:* 15 minutes

### Objectives
-   Download ORM stack
-   Configure an existing Virtual Cloud Network (VCN)

### Prerequisites
This lab assumes you have:
- An Oracle Free Tier or Paid Cloud account
- SSH Keys (optional)

## Task 1: Download Oracle Resource Manager (ORM) stack zip file
1.  Click on the link below to download the Resource Manager zip file you need to build your environment:

<if type="sql-duality">
    - [sql-duality.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/23c/sql-duality.zip)
</if>
<if type="java-dvs">
    - [java-dvs.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/23c/java-dvs.zip)
</if>
<if type="js-generic">
    - [js-generic.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/23c/js-generic.zip)
</if>
<if type="json-autorest">
    - [json-autorest.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/23c/json-autorest.zip)
</if>
<if type="json-enhancements">
    - [json-enhancements](https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/23c/json-enhancements.zip)
</if>
<if type="property-graphs">
    - [property-graphs](https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/23c/property-graphs.zip)
</if>
<if type="unify-ocw23">
    - [unify-ocw23](https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/23c/unify-ocw23.zip)
</if>


2.  Save in your downloads folder.

## Task 2: Setup Compute   
The following lab will be *Environment Setup* where you can setup your workshop environment using Oracle Resource Manager (ORM) and one of the following options:
-  Create Stack:  *Compute + Networking*
-  Create Stack:  *Compute only* with an existing VCN where security lists have been updated as per the steps below

This workshop requires a certain number of ports to be available. The default VCN that is created during ORM stack creation for option 1, *Compute + Networking*, configures these ports for you automatically. We strongly recommend this option to create a self-contained/dedicated VCN with your instance(s).

If you choose the second option, *Compute only*, then you will need to manually add these rules onto an existing VCN. Egress:

| Port           |Description                            |
| :------------- | :------------------------------------ |
| 22             | SSH                                   |
| 80             | Application (http)                    |
| 6080           | noVNC Remote Desktop                  |

1.  Go to *Networking >> Virtual Cloud Networks*
2.  Choose your network
3.  Under **Resources**, select **Security Lists**.
4.  Click Default Security Lists under **Create Security**.
5.  Click **Add Ingress Rules**.
6.  Enter the following:  
    - Source CIDR: 0.0.0.0/0
    - Destination Port Range: *Refer to above table*
7.  Click **Add Ingress Rules**.

## Acknowledgements
* **Author** - Kaylien Phan, William Masdon
* **Contributors** -  Dan Williams, David Start
* **Last Updated By/Date** - Kaylien Phan, June 2023