# Provision OCI services

## Introduction

This lab walks you through the steps to provision Redis, ATP and OCI VM instance.

Estimated Time: 45 minutes

### Objectives

In this lab, you will:
* Provision ATP database
* Provision Redis cluster
* Provision VM instance

### Prerequisites

This lab assumes you have:
* OCI Compartment created
* IAM policies setup done already

## Task 1: Prepare Redis Cluster

1. Log in to the Oracle Cloud Console as the Cloud Administrator, if you are not already logged in. On the Sign In page, select your tenancy, enter your username and password, and then click Sign In. The Oracle Cloud Console Home page is displayed

2. Follow below link to create VCN

  [Create OCI VCN](https://docs.oracle.com/en/learn/lab_virtual_network/index.html#introduction)

3. Click the Navigation menu and navigate to Databases > Redis > Clusters

  ![navigate to redis cluster](images/redis_cluster.png) 
  
  Choose the Compartment you created and click **Create cluster**.

4. Provide the cluster name **redis-livelab-cluster** , choose compartment  and click **Next**.
   ![cluster name](images/create_cluster_pg01.png)

5. Keep the default configuration in Configure nodes tab and click **Next**.
   ![configure cluster](images/create_cluster_pg02.png)

6. Choose your VCN and Subnet created as part of prerequisite and click **Next**.
   ![cluster vcn](images/create_cluster_pg03.png)

7. Review the details filled in and click **Create Cluster**.
   ![review and create cluster](images/create_cluster_pg04.png)

8. Once cluster up and running, copy **OCID** and **Primary endpoint** and keep it ready for flask app configuration in lab-3.
   ![copy cluster info](images/create_cluster_pg05.png)

## Task 2: Provision ATP Database

1. Click the Navigation menu and navigate to Databases > Autonomous Transaction Processing

  ![navigate to ATP](images/atp.png) 

2. Choose the compartment and click **Create Autonomous Database**

  ![create ATP](images/atp_2.png) 

3. Give Database name as **REDISLABATP**

  ![give ATP a name](images/atp_3.png)

4. Choose a password and keep rest of the fields with default values and click **Create Autonomous Databse**

  ![choose password](images/atp_4.png)

5. Once the ATP is created , click on **Database Connection**.

  ![database connection](images/atp_5.png)

6. Click on **Download Wallet** and keep this wallet zip file for lab-3.

  ![download wallet](images/atp_6.png)


## Task 3: Provision Linux Instance

1. Click the Navigation menu and navigate to Compute > Instances 

  ![navigate to compute](images/compute_1.png)
 
2. Choose the compartment and click **Create Instance**. 

  ![create instance](images/compute_2.png)

3. Give Instance name **redis-livelab-instance** , choose VCN and public subnet of that VCN , and choose 'Generate a key pair for me' option and leave rest values as default and hit 'Create'

  ![give instance a name](images/compute_3.png)

  ![choose vcn and subnet](images/compute_4.png)

  ![generate and download key pair](images/compute_5.png)

   **Note:** Please save private & public key for login into instance in lab-3

  You may now **proceed to the next lab**.
  
## Learn More

* [About create Compartment](https://docs.oracle.com/en-us/iaas/Content/Identity/compartments/To_create_a_compartment.htm)
* [About creating IAM policies for Redis](https://docs.oracle.com/en-us/iaas/Content/redis/permissions.htm)
* [About creating IAM policies for ATP](https://docs.oracle.com/en-us/iaas/Content/Identity/Reference/adbpolicyreference.htm)

## Acknowledgements
* **Author** 
* Pavan Upadhyay, Principal Cloud Engineer, NACI 
* Saket Bihari, Principal Cloud Engineer, NACI
* **Last Updated By/Date** - Pavan Upadhyay, Saket Bihari, Feb 2024
