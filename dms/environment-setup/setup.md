# Prepare Virtual Cloud Network

## Introduction

This lab walks you through the steps of creating your own virtual cloud network and updating the security list, allowing for future Database access. You will also walk through the steps of creating a vault, an encrypted key, and the steps to create an empty Object Storage Bucket for use in the migration. The OCI Object Storage service is an internet-scale, high-performance storage platform that offers reliable and cost-efficient data durability. In this lab, Object Storage is used as temporary storage between the source and target databases with Data Pump. For more information visit the *Learn More* tab at the bottom of the page.

For a full understanding of the network components and their relationships view the linked video, or visit the *Learn More* tab below.

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

* An Oracle Cloud Account - Please view this workshop's LiveLabs landing page to see which environments are supported
* This lab requires completion of the preceding labs in the Contents menu on the left.

*Note: If you have a **Free Trial** account, when your Free Trial expires your account will be converted to an **Always Free** account. You will not be able to conduct Free Tier workshops unless the Always Free environment is available. **[Click here for the Free Tier FAQ page.](https://www.oracle.com/cloud/free/faq.html)***

## Task 1: Create Virtual Cloud Network

The following task is *optional* if a suitable VCN is already present.

1. In the OCI Console Menu, go to **Networking** > **Virtual Cloud Networks**.

  ![Virtual Cloud Networks navigation](images/vcn-location.png)

2. Pick a compartment on the left-hand side **Compartment** list. You need to have the necessary permissions for the compartment.

  ![Pick a compartment for your vcn](images/create-vcn-in-compartment.png)

3. Press **Start VCN Wizard** and pick **VCN with Internet Connectivity**.

  ![start VCN Wizard](images/vcn-with-internet-wizard.png )
  

4. Enter a **VCN Name**, such as VCN\_DMS\_LA. Leave CIDR block defaults, unless you need non-overlapping addresses for peering later. Press **Next**.

  ![Enter a VCN Name](images/vcn-configuration.png)

5. Review Summary and press **Create**.

  ![Review Summary](images/vcn-review-and-create.png)

## Task 2: Update Security List for Virtual Cloud Network Subnet

This task assumes default permissions in your public subnet. If you disabled or restricted your default permissions such as port 22 SSH access or restricted egress, please add default permissions as needed.

1. In the OCI Console Menu, go to **Networking** > **Virtual Cloud Networks** and pick your VCN.

  ![pick your VCN](images/created-vcn.png)

2. In the **Subnets** list, pick **Public Subnet-VCN NAME**.

  ![pick Public Subnet](images/vcn-public-subnet.png)

3. In the **Security Lists** list, pick **Default Security List for VCN NAME**.

  ![pick Default Security List](images/public-subnet-default-sl.png)

4. In the **Ingress Rules** list press **Add Ingress Rules**.

  ![press Add Ingress Rules](images/add-ingress.png)

5. Enter the following values, otherwise leave defaults:
    - Source CIDR: **0.0.0.0/0**
    - Destination Port Range: **443**
    - Description: **OGG HTTPS**
    - Close dialog by pressing **Add Ingress Rules**.

  ![enter values for source,destination port range and description](images/ogg-ingress.png =50%x50%)

6. In the **Ingress Rules** list press **Add Ingress Rules**.

7. Enter the following values, otherwise leave defaults:
    - Source CIDR: **10.0.0.0/16**
    - Destination Port Range: **1521**
    - Description: **Oracle DB access for PEs**
    - Close dialog by pressing **Add Ingress Rules**.

  ![Enter values for source,destination port range and description](images/oracle-db-access-ingress.png =50%x50%)

![display ingress rules](images/ingress-rules.png)

You may now [proceed to the next lab](#next).


## Task 3: Create Vault

These steps walks you through the steps of creating a vault and encrypted key. For more information visit the *Learn More* tab at the bottom of the page.

The following task is *optional* if a Vault is already present.

1. In the OCI Console Menu, go to **Identity & Security** > **Vault**.

  ![vault menu navigation](images/vault-oci-menu.png)

2. Pick a compartment on the left-hand side **Compartment** list.

3. Press **Create Vault**.

  ![pick a compartment for the vault creation](images/create-vault.png)

4. In the **Create Vault** dialog, enter a Name such as **DMS\_Vault**.

5. Close the dialog by pressing **Create Vault**.

  ![press create Vault](images/vault-name.png =50%x50%)

6. Wait until the state of the new vault is **Active**. This takes about 5 minutes.

  ![vault displays as active](images/active-vault.png)

7. Click on the new vault and press **Create Key** in the **Master Encryption Keys** list.

  ![press create key](images/create-key.png)

8. In the **Create Key** dialog, enter a Name such as **DMS\_Key**.

9. Close the dialog by pressing **Create Key**.

  ![press create key after entering a name](images/name-key.png =50%x50%)

![display key status](images/created-key.png)



## Task 4: Create Object Storage Bucket

Create an empty Object Storage bucket for use in the migration.

1. In the OCI Console Menu, go to **Storage > Object Storage & Archive Storage**

  ![Object Storage menu navigation](images/menu-navigation.png =50%x*)

2. Press **Create Bucket**

  ![press create bucket](images/create-bucket-button.png =50%x*)

3. On the page Create Bucket, fill in the following entries, otherwise leave defaults:

    - Bucket Name: **DMSStorage**

4. Press **Create**

  ![Enter a name and complete by pressing create](images/bucket-create.png =50%x*)

You may now [proceed to the next lab](#next).


## Learn More

* [Networking Overview](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm)
* [Overview of Vault](https://docs.oracle.com/en-us/iaas/Content/KeyManagement/Concepts/keyoverview.htm)
* [Overview of Object Storage](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm)

## Acknowledgements
* **Author** - Alex Kotopoulis, Director, Product Management
* **Contributors** -  Hanna Rakhsha, Kiana McDaniel, Killian Lynch, Solution Engineers, Austin Specialist Hub
* **Last Updated By/Date** - Hanna Rakhsha, Kiana McDaniel, Killian, Lynch Solution Engineers, July 2021
