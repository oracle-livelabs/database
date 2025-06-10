# Prepare setup

## Introduction

In this lab, you will download the Oracle Resource Manager (ORM) stack zip file needed to set up the resources needed to run this workshop. This workshop requires a compute instance and a Virtual Cloud Network (VCN) and subnet.

**Estimated Lab Time:** 10 minutes

### Objectives

-   Download the workshop's ORM stack.
-   Configure an existing Virtual Cloud Network (VCN) - optional.

### Prerequisites

This lab assumes you have:

- An Oracle Cloud account with enough resources to run this workshop. The minimum requirements are **4 CPUs, 32 GB RAM, 100 GB storage and one VCN/subnet**.

## Task 1: Download Oracle Resource Manager (ORM) stack zip file

1.  Click on the link below to download the Resource Manager zip file you need to build your environment:

 [ll-timesten-cache-intro.zip](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/data-management-library-files/ll-timesten-cache-intro.zip)

2.  Save in your downloads folder.



## Task 2: Prepare to setup your OCI compute instance

Using the ORM zip file from the previous step, you can setup your workshop environment in one of two ways:

- Let the stack create both the compute and network resources (recommended).

- Let the stack create the compute resources and connect them to an existing VNC.

For simplicity, we recommend allowing the stack to create a self-contained, dedicated VCN for this workshop. If you would rather use an existing VCN, consult the appendix below to learn how to update an existing VCN with the required Ingress rules.

The detailed steps for both options are covered in the next lab.

**IMPORTANT**

When deploying the workshop compute instance using the ORM stack, as described in the next lab:

1. By default, SSH access using a system generated SSH private key is enabled.

2. If you wish to provide your own SSH public key, uncheck the option *Auto Generate SSH Key Pair* and follow the on-screen instructions to either upload or copy/paste your SSH public key.  

3. Unless you wish to customize SSH connectivity as described in (2), you can accept all the other defaults provided by the ORM stack.

You can now **proceed to the next lab**.

## Appendix: Adding security rules to an existing VCN

This workshop requires a certain number of ports to be available, a requirement that can be met by using the default ORM stack execution that creates a dedicated VCN. In order to use an existing VCN/subnet, the following ports should be added to the **Ingress** rules.

| Port | Description                |
| :--- | :------------------------- |
| 22   | SSH                        |
| 80   | Remote Desktop using noVNC |
| 6080 | Remote Desktop using noVNC |

**Note:** If you plan to only use SSH connectivity, or only Remote Desktop connectivity, then you only need to open the appropriate port(s).


1.  Go to *Networking >> Virtual Cloud Networks*.

2.  Choose your network.

3.  Select *Security* tab from the sub-menu bar.

4.  Under *Security Lists*, click on the Create Security List button.

5.  Click the *Add Ingress Rule* button.

6.  Enter the following:
    - Source CIDR: 0.0.0.0/0
    - Destination Port Range: *Refer to the above table*

7.  Click the **Add Ingress Rules** button.

## Acknowledgements

* **Author** - Chris Jenkins, Senior Director, TimesTen Product Management
* **Contributors** -  Doug Hood & Jenny Bloom, TimesTen Product Management
* **Last Updated By/Date** - Jenny Bloom, June 2025
