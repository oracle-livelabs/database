# Connect to Standalone and High Availability Db Systems

## Introduction

When working in the cloud, there are often times when your servers and services are not exposed to the public internet. The Oracle Cloud Infrastructure (OCI) MySQL HeatWave Dabase Service instances is an example of a service that is only accessible through private networks. Since the service is fully managed, we keep it siloed away from the internet to help protect your data from potential attacks and vulnerabilities. It’s a good practice to limit resource exposure as much as possible, but at some point, you’ll likely want to connect to those resources. That’s where Compute Instance, also known as a Bastion host, enters the picture. This Compute Instance Bastion Host is a resource that sits between the private resource and the endpoint which requires access to the private network and can act as a “jump box” to allow you to log in to the private resource through protocols like SSH.  

Today, you will use the already created Compute Instance with MySQL Shell to connect to the DB Systems. 

_Estimated Lab Time:_ 30 minutes


### Objectives

In this lab, you will be guided through the following tasks:


- Setup Compute Instance with MySQL Shell
- Connect to MySQL Standalone DB System
- Switchover and Connect to MySQL High Availability DB System

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- Some Experience with MySQL Shell
- Must Complete Lab 3

## Task 1: Connect to MySQL Database - Standalone

MySQL Database Service Standalone has daily automatic backups and is resilient to failures because it leverages Block Volumes to store user data. Consequently, it offers the same durability, security, and performance guarantees. Automatic and manual backups are replicated to another availability domain and can be restored in the event of a disaster or user error. Data loss is limited by the last successful backup.

1. If not already connected with SSH, connect to Compute instance using Cloud Shell

   (Example: ssh -i ~/.ssh/id_rsa opc@132.145.17….)

2. Use the following command to connect to MySQL using the MySQL Shell client tool. Be sure to add the MDS-SA private IP address at the end of the cammand. Also enter the admin user password

    (Example  **mysqlsh -uadmin -p -h10.0.1..**)

 **[opc@...]$**
    ````
    <copy>mysqlsh -uadmin -p -h 10.0.1....</copy>
    ````
3. On MySQL Shell, switch to SQL mode  to try out some SQL commands

   a. Enter the following command at the prompt:
     ````
    <copy>\sql</copy>
    ````
   b. To display a list of databases, Enter the following command at the prompt:
      ````
    <copy>SHOW DATABASES;</copy>
    ````  

   c. To display the database version, current_date, and user enter the following command at the prompt:
      ````
    <copy>SELECT VERSION(), CURRENT_DATE, USER();</copy>
    ````  
   d. To display MySQL user and host from user table enter the following command at the prompt:
       ````
    <copy>SELECT USER, HOST FROM mysql.user;</copy>
      ````
   e. Type the following command to exit MySQL:
      ````
    <copy>\q</copy>
    ```` 
  

## Task 2:  Download, unpack, Import the Sakila sample dataset

1. Download Sakila sample dataset

      ````
      <copy> wget https://downloads.mysql.com/docs/sakila-db.tar.gz </copy>
      ````  

2. Unpack  Sakila Sample Dataset.

      ````
      <copy>tar xvzf sakila-db.tar.gz</copy>
      ```` 
3. Connect to MDS-SA  using MySQL Shell (Be sure to replace the IP address with MDS-SA IP)

      ````
      <copy>mysqlsh -uadmin -p -h 10.0.1.. --sql</copy>
      ````
4. Import  Sakila schema 

      ````
      <copy>\source sakila-db/sakila-schema.sql</copy>
      ```` 
5. Import  Sakila data.

      ````
      <copy>\source sakila-db/sakila-data.sql</copy>
      ```` 

   a. List all of the databases

      ````
      <copy>show databases;</copy>
      ```` 
   
   b. Point to Sakila schema

      ````
      <copy> use sakila</copy>
       ```` 
   
   c. List Sakila tables

      ````
      <copy>show tables;</copy>
      ```` 
   d. Display Sakila  actors

      ````
      <copy>select * from sakila.actor limit 3;</copy>
      ```` 
   e. Display Sakila countries

      ````
      <copy>SELECT country_id, country from country WHERE country = 'Afghanistan' OR 'Bangladesh' OR 'China';</copy>
      ```` 
   f. Type the following command to exit MySQL:
      ````
      <copy>\q</copy>
      ````
## Task 3: Convert Standalone database to High Availability database

Use the Console to enable or disable high availability on a DB system
   1. Open the navigation menu. Under Databases >MySQL > DB Systems
    ![MDS](./images/04mysql01.png " ")

   2. Click the **MDS-SA** Standalone Dabase link

   3. Click the **More Actions** button

   4. Select **Enable high availability**
      ![MDS](./images/en-ha.png " ")  

   5. Click the **Enable** button
         ![MDS](./images/ha-enable.png " ")  

   6. Select the HA-compatible configuration **MySQL.VM.Standard.E3.1.8GB.HA** and click Enable.
            ![MDS](./images/ha-select-config.png " ")     

      The configuration is updating. The DB System  will enter the UPDATING state. 

      The selected configuration will be applied to the DB System.

      The secondary instances will be  cloned from the primary instance. 

**This conversion will take a while Go to the next Lab and come back in 15 minutes** 

## Task 4: Connect to MySQL Database High Availability

A highly available database system is one which guarantees if one instance fails, another takes over, with zero data loss and minimal downtime.
MySQL Database High Availability uses MySQL Group Replication to provide standby replicas to protect your data and provide business continuity. It is made up of three MySQL instances, a primary, and two secondaries. All data written to the primary instance is also written to the secondaries. In the event of failure of the primary, one of the secondaries is automatically promoted to primary, is set to read-write mode, and resumes availability to client applications with no data loss. This is called a failover. It is also possible to switch manually, and promote a secondary to primary. This is called a switchover.

1. If not already connected with SSH, connect to Compute instance using Cloud Shell

   (Example: ssh -i ~/.ssh/id_rsa opc@132.145.17….)

2. From your Compute instance, connect to MDS-HA MySQL using the MySQL Shell client tool.

   The endpoint (IP Address) can be found in the MDS-HA MySQL DB System Details page, under the "Endpoint" "Private IP Address".

    ![Connect](./images/06connect03.png " ")

3.  Use the following command to connect to MySQL using the MySQL Shell client tool. Be sure to add the MDS-HA private IP address at the end of the cammand. Also enter the admin user password

    (Example  **mysqlsh -uadmin -p -h10.0.1..**)

 **[opc@...]$**

    ````
    <copy>mysqlsh -uadmin -p -h 10.0.1....</copy>
    ````
4. On MySQL Shell, switch to SQL mode  to try out some SQL commands

   a. Enter the following command at the prompt:
     ````
    <copy>\sql</copy>
    ````
   b. Display all of the databases
      ````
    <copy>SHOW DATABASES;</copy>
    ````  

   c. To display the database version, current_date, and user enter the following command at the prompt:
      ````
    <copy>select * from sakila.actor limit 3;</copy>
    ````  

   d. Type the following command to exit MySQL:
      ````
    <copy>\q</copy>
    ````   

## Task 5: Switchover MySQL Database  High Availability

To switch from the current primary instance to one of the secondary instances, do the following:

1. Open the navigation menu  Database > MySQL > DB Systems
2. Choose **(root)** Compartment.
3. In the list of DB Systems, Click MDS-SA DB System to display the details page and do the following:
    * Save the current endpoint values for a before and after comparisson of the switch
    ![Connect](./images/07switch01.png " ")  
    * Select Switchover from the More Actions menu. The Switchover dialog is displayed
     ![Connect](./images/07switch02.png " ")   
    * Switch the PRimary from AD-1 to AD-2  
    * Click Switchover to begin the switch process.
    ![Connect](./images/07switch03.png " ")  
    * The DB System's status changes to Updating, and the selected instance becomes the primary.
        ![Connect](./images/07switch04.png " ")  

4. To view the new praimary database go back to **Task 4**

## Acknowledgements

- **Author** - Perside Foster, MySQL Solution Engineering

- **Contributors** - Mandy Pang, Principal Product Manager, Salil Pradhan, Principal Product Manager, Nick Mader, MySQL Global Channel Enablement & Strategy Manager
- **Last Updated By/Date** - Perside Foster, MySQL Solution Engineering, May 2022
