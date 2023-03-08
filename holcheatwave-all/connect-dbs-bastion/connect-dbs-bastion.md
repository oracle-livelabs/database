# Connect to MySQL HeatWave Using Bastion

![INTRO](./images/00_mds_heatwave_2.png " ") 

## Introduction

When working in the cloud, there are often times when your servers and services are not exposed to the public internet. The Oracle Cloud Infrastructure (OCI) MySQL cloud service is an example of a service that is only accessible via private networks. Since the service is fully managed, we keep it siloed away from the internet to help protect your data from potential attacks and vulnerabilities. It’s a good practice to limit resource exposure as much as possible, but at some point, you’ll likely want to connect to those resources. That’s where bastion hosts enter the picture. A bastion host is a resource that sits between the private resource and the endpoint which requires access to the private network and can act as a “jump box” to allow you to log in to the private resource via protocols like SSH or RDP.  The bastion host requires a Virtual Cloud Network to connect with the MySQL DB Systems. 

Oracle added a Bastion Service to OCI. And you may also have noticed that the OCI Dashboard offers you the possibility to use a browser based terminal: Cloud Shell.

Today, you will use these two components to connect from the browser to a MDS DB System

Estimated Lab Time 15 minutes

### Objectives

In this lab, you will be guided through the following tasks:

- Setup Bastion Service
- Create Bastion session 
- Connect to MySQL DB System

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- Some Experience with MySQL Shell
- Must Complete Lab 1

## Task 1: Create Bastion Service

The new Bastion Service will allow you to create a SSH Tunnel to your MySQL DB System.

1. Go to Navigation Menu > Identity Security > Bastion

    ![](./images/bastion-01.png " ")

2. Click Create Bastion

    ![](./images/bastion-02.png " ")

3. On Create bastion, complete the following fields:   

    Bastion Name
     ```
     <copy>MDSBastion</copy>
     ```
    Target virtual Cloud network in .. (root)
    
    Select  `MDS-VCN`
    
    Target subnet in .. (root)

    Select  `Private Subnet-MDS-VCN`

    CIDR block allowlist (As you don’t know the IP of the Cloud Shell, use 0.0.0.0/0)

     ```
     <copy>0.0.0.0/0</copy>
     ```
    
    Click `0.0.0.0/0(New)`

     ![](./images/bastion-03.png " ")

4. Click `Create Bastion` button 

    When completed your screen should look like this:

    ![](./images/bastion-04.png " ")


## Task 2: Create Bastion Session

1. Before creating the Bastion Session open a notepad. Do the following steps to record the MySQL Database System private IP address:

    - Go to Navigation Menu > Databases > MySQL
     ![](./images/db-list.png " ")

    - Click on the `MDS-HW` Database System link

     ![](./images/db-active.png " ")
    
    - Copy the `Private IP Address` to the notepad

2. Do the followings steps to copy  the public SSH key to the  notepad 
 
    - Open the Cloud shell
     ![](./images/cloudshell-10.png " ")    

    - Enter the following command   
        ```
     <copy>cat .ssh/id_rsa.pub</copy>
        ``` 
    ![](./images/cloudshell-11.png " ") 

3.  Copy the id_rsa.pub content the notepad
        Your notepad should look like this
        ![](./images/notepad1.png " ")  
        
4. Go to Navigation Menu > Identity Security > Bastion

5. Click the `MDSBastion` link

     ![](./images/bastion-05.png " ")

6. Click `Create Session`

7. Set up the following information
    - Session type
      Select `SSH port forwarding session`
    - Session Name 
        *Keep Default*
    - IP address
        *Enter IP addtess from notepad*

8. Enter the Port

    ```      
        <copy>3306</copy>
    ```
9. Add SSH Key -  Copy SSH Key from notepad
    - The screen should look like this
    ![](./images/bastion-06.png " ") 
    - Click the `Create Session` button 
10. The completed Bastion Session should look like this
    ![](./images/bastion-07.png " ") 

**Note: The Session will expire in 180 minutes**

## Task 3: Connect to MySQL HeatWave with Bastion Session

1. Click on the 3 vertical dots on the Bastion Session

    ![](./images/bastion-08.png " ") 

2. Click `View SSH Command`  

    ![](./images/bastion-09.png " ") 

3. Click copy and paste the information to your notepad and hit Close

4.  update the session command on notepad
    - Set the beginning of the command `ssh -4 -i ~/.ssh/id_rsa -N -L 3306`
    - *add the `-v` character* at the end of the command or the connection will not be successful


    The command from your notepad should look like this

    ![](./images/notepad2.png " ") 
    
5. Open the cloud shell and enter the command from the notepad. It should like this..
    *Don't forget the -v  character*

    `ssh  -i ~/.ssh/id_rsa -N -L 3306:10.0.1...:3306 -p 22 ocid1.bastionsession.oc1.iad.amaaaaaacalccniavpdipmbwvxk...ybm2g7fuaea@host.bastion.us-ashburn-1.oci.oraclecloud.com -v`

6. Use MySQL Shell to connect to the MySQL Database Service. Enter: 

     ```
     <copy>mysqlsh admin@127.0.0.1 --sql</copy>
     ``` 
7. View  the airportdb total records per table in 


    ```
    <copy>SELECT table_name, table_rows FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'airportdb';</copy>
    ```
        
    ![Connect](./images/airport-db-view02.png " ") 

**Note** You can also use  the bastion service to connect to your local computer and access  MySQL  with Workbench or Visual Studio Code

Watch the video below for a quick walk through.

[](youtube:3R0DBBer26E)

You may now [proceed to the next lab](#next).

## Learn More

* [Cloud Shell](https://www.oracle.com/devops/cloud-shell/?source=:so:ch:or:awr::::Sc)
* [Virtual Cloud Network](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm)
* [OCI Bastion Service ](https://docs.public.oneportal.content.oci.oraclecloud.com/en-us/iaas/Content/Bastion/Tasks/connectingtosessions.htm)
## Acknowledgements
* **Author** - Perside Foster, MySQL Solution Engineering 
* **Contributor** - Frédéric Descamps, MySQL Community Manager 
* **Last Updated By/Date** - Perside Foster, May 2022
