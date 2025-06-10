# Prepare Virtual Cloud Network

## Introduction

This lab walks you through the steps of creating your own virtual cloud network and updating the security list, allowing for future Database access. You will also walk through the steps of creating a vault, an encrypted key, and the steps to create an empty Object Storage Bucket for use in the migration. The OCI Object Storage service is an internet-scale, high-performance storage platform that offers reliable and cost-efficient data durability. In this lab, Object Storage is used as temporary storage between the source and target databases with Data Pump. For more information visit the *Learn More* tab at the bottom of the page.

For a full understanding of the network components and their relationships view the linked video or visit the *Learn More* tab below.

  [](youtube:mIYSgeX5FkM)

Estimated Lab Time: 20-30 minutes

### Objectives

In this lab, you will:
* Create a virtual cloud network (VCN) with Internet Connectivity
* Update Security List for Virtual Cloud Network Subnet (VCN)
* Create a vault
* Create a key
* Provision an empty bucket

### Prerequisites

* An Oracle Cloud Account - Please view this workshop's LiveLabs landing page to see which environments are supported.
* This lab requires completion of the preceding labs in the Contents menu on the left.

*Note: If you have a **Free Trial** account when your Free Trial expires your account will be converted to an **Always Free** account. You will not be able to conduct Free Tier workshops unless the Always Free environment is available. **[Click here for the Free Tier FAQ page.](https://www.oracle.com/cloud/free/faq.html)***

## Task 1: Create Virtual Cloud Network

The following task is *optional* if a suitable VCN is already present.

1. In the OCI Console Menu, go to **Networking** > **Virtual cloud networks**.

  ![screenshot of VCN menu navigation](images/vcn-location.png =50%x*)

2. Pick a compartment in the **Applied filters**/**Compartment**  list. You need to have the necessary permissions for the compartment.

  ![screenshot where to select compartment](images/create-vcn-in-compartment.png =50%x*)

3. Press **Actions**/**Start VCN Wizard** and pick **VCN with Internet Connectivity**.

  ![screenshot of start VCN wizzard ](images/vcn-with-internet-wizard.png =50%x*)

4. Enter a **VCN Name**, such as VCN\_DMS. Leave CIDR block defaults, unless you need non-overlapping addresses for peering later. Press **Next**.

  ![screenshot of where to enter VCN name](images/vcn-configuration.png =50%x*)

5. Review Summary and press **Create**.

  ![screenshot of summary](images/vcn-review-and-create.png =50%x*)

## Task 2: Update Security List for Virtual Cloud Network Subnet

This task assumes default permissions in your public subnet. If you disabled or restricted your default permissions such as port 22 SSH access or restricted egress, please add default permissions as needed.

1. In the OCI Console Menu, go to **Networking** > **Virtual cloud networks** and pick your VCN.

  ![screenshot of navigation to Virtual Cloud Networks](images/created-vcn.png =50%x*)

2. In the **Subnets** list, pick **Public Subnet-VCN NAME**.

  ![Screenshot of subnets selection ](images/vcn-public-subnet.png =50%x*)

3. Click in the **Security** tab and in the **Security Lists** list, pick **Default Security List for VCN NAME**.

  ![screenshot of Default Security List for VCN NAME](images/public-subnet-default-sl.png =50%x*)

4. Click to the **Security rules** tab and in the **Ingress Rules** section press **Add Ingress Rules**.

  ![Screenshot of Ingress rules navigation and add ingress rules](images/add-ingress.png =50%x*)

5. Enter the following values, otherwise leave defaults:
    - Source CIDR: **0.0.0.0/0**
    - Destination Port Range: **443**
    - Description: **OGG HTTPS**
    - Close dialog by pressing **Add Ingress Rules**.

  ![Screenshot of values for ingress rules](images/ogg-ingress.png =50%x*)

6. In the **Ingress Rules** list press **Add Ingress Rules**.

7. Enter the following values, otherwise leave defaults:
    - Source CIDR: **10.0.0.0/16**
    - Destination Port Range: **1521**
    - Description: **Oracle DB access for PEs**
    - Close dialog by pressing **Add Ingress Rules**.

  ![Screenshot of values for ingress rules](images/oracle-db-access-ingress.png =50%x*)


You may now [proceed to the next lab](#next).


## Task 3: Create Vault

These are the steps to create a vault and encrypted key. For more information visit the *Learn More* tab at the bottom of the page.

The following task is *optional* if a Vault is already present.

1. In the OCI Console Menu, go to **Identity & Security** > **Vault**.

  ![Screenshot of Vault navigation](images/vault-oci-menu.png =50%x*)

2. Pick a compartment in the **Applied filters**/**Compartment**  list.

3. Press **Create Vault**.

  ![Screenshot of create vault](images/create-vault.png =50%x*)

4. In the **Create Vault** dialog, enter a Name such as **DMS\_Vault**.

5. Close the dialog by pressing **Create Vault**.

  ![screenshot of vault creation](images/vault-name.png =50%x*)

6. Wait until the state of the new vault is **Active**. This takes about 5 minutes.

  ![Screenshot where Vault is active](images/active-vault.png =50%x*)

7. Click on the new vault and press **Create Key** in the **Master Encryption Keys** list.

  ![Screenshot of create new key ](images/create-key.png =50%x*)

8. In the **Create Key** dialog, enter a Name such as **DMS\_Key**.

9. Close the dialog by pressing **Create Key**.

  ![Screenshot of create key confirmation](images/name-key.png =50%x*)



## Task 4: Create Object Storage Bucket

Create an empty Object Storage bucket for use in the migration.

1. In the OCI Console Menu, go to **Storage > Object Storage & Archive Storage**

  ![Screenshot of Object Storage & Archive Storage nvigation](images/object-storage-location.png =50%x*)

2. Press **Create Bucket**

  ![Screenshot of create bucket](images/create-bucket.png =50%x*)

3. On the page Create Bucket, fill in the following entries, otherwise leave defaults:

    - Bucket Name: **DMSStorage**

4. Press **Create**

  ![Screenshot of create bucket confirmation](images/create-bucket-configm.png =50%x*)

You may now [proceed to the next lab](#next).


## Learn More

* [Networking Overview](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm)
* [Overview of Vault](https://docs.oracle.com/en-us/iaas/Content/KeyManagement/Concepts/keyoverview.htm)
* [Overview of Object Storage](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm)

## Acknowledgements
* **Author** - Alex Kotopoulis, Director, Product Management
* **Contributors** -  Hanna Rakhsha, Kiana McDaniel, Killian Lynch, Solution Engineers, Austin Specialist Hub
* **Last Updated By/Date** - Jorge Martinez, Product Management, May 2025
