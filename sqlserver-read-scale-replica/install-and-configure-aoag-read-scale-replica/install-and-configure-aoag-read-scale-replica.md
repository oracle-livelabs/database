# Setup and Configure Always On Availability Group

## Introduction

This lab walks you through the steps to create the Always On Availability Group in SQL Server.

Estimated Time:  1 hour

### Objectives
In this lab, you will learn to :
* Create Sample database creation
* Enable the Always-on feature for SQL Server Engine
* Create Always On Availability Group Read-Scale Replica

### Prerequisites  

This lab assumes you have:
- A Free or LiveLabs Oracle Cloud account
- IAM policies to create resources in the compartment

##  Task 1: Create Sample Database

1. RDP to the Bastion host server using the username **.\opc** and password. From the Bastion host, opens the Remote Desktop and connect to the Node1 server using the private IP Address.

2. Open SSMS from **Windows Start Menu**, once opened choose the Server type **Database Engine**, provide the Node1 server name, Choose the **Authentication** type Windows Authentication, and then click on **Connect**.

  ![Microsoft SQL Server Management Studio](./images/msql-managementstudio.png "Microsoft SQL Server Management Studio")

3. Once successfully connected to the database engine, click on **New Query** and create the sample database using the following script. Click on the **Execute** command to create the sample database.  

    **Create database TestAOAG;**

  ![Microsoft SQL Server Management Studio query](./images/msql-mgmtstudiocreatedb.png "Microsoft SQL Server Management Studio query")

4. The database will be visible in the following image.

  ![Microsoft SQL Server database details](./images/msql-mgmtstudiocreateview.png "Microsoft SQL Server database details")

5. Select **databases**, right-click on newly created database, and then select **tasks**, choose **Backup**

  ![Microsoft SQL Server database backup](./images/msql-mgmtstudio-dbbackup.png "Microsoft SQL Server database backup")

6. Choose the backup location and click on **OK**.

  ![Microsoft SQL Server database backup location](./images/msql-mgmtstudio-dbbackupconfirm.png "Microsoft SQL Server database backup location")

  You may now **proceed to the next lab**.

##  Task 2: Enable the Always-On feature for Primary Replica Database Engine

1. From the Windows taskbar, click the search button, search for **SQL Server 2019 Configuration Manager**, and click on the SQL Server 2019 Configuration Manager app.

  ![Windows search command](./images/mssql-configmanager-search.png "Windows search command")

2. Right-click on database Engine **SQL Server (MSSQLSERVER)**, and then click on **Properties**.

  ![Microsoft SQL Server configuration manager](./images/mssql-configmanager-dbservices.png "Microsoft SQL Server configuration manager")

3. Click on **Always on Availability Groups**, select the check box **Enable Always on Availability Groups**, and then click on Apply.

  ![Microsoft SQL Server engine properties](./images/mssql-configmanager-dbservices-properties.png "Microsoft SQL Server engine properties")

4. The following **Warning** message will appear on the screen, and then click on **OK**.

  ![Microsoft SQL Server engine Always On Availability Groups](./images/mssql-configmanager-warring.png "Microsoft SQL Server engine Always On Availability Groups")

5. Finally, click on **OK** to apply the changes.

  ![Microsoft SQL Server engine Always On Availability Groups](./images/mssql-configmanager-apply.png "Microsoft SQL Server engine Always On Availability Groups")

6. To apply the changes, restart the SQL Engine, Right-click on database Engine **SQL Server (MSSQLSERVER)**, and then click Restart.

  ![Microsoft SQL Server restart](./images/ms-sql-restart.png "Microsoft SQL Server restart")

7. To create the SQL service domain service account: From the taskbar, click the search button and search for the run command. Once the run command opens, type **dsa.MSC** to open the Active Directory users and computer, then click on **users**.

  ![Windows AD users and computers](./images/windows-command-dsa.png "Windows AD users and computers")  

8. Provide the username details, and then click on **Next**.

  ![Windows AD create users](./images/mssql-serviceaccount-name.png "Windows AD create users")

9. Provide the password and confirm the password, then click on **Next** and click on **Finish** to close the create window.

  ![Windows AD users details](./images/mssql-serviceaccount-password.png "Windows AD users details")

  ![Windows AD users password](./images/mssql-config-manager-search.png "Windows AD users password")

11. From the taskbar, click the search button, search for **SQL Server 2019 Configuration Manager**, and click on the SQL Server 2019 Configuration Manager app.

12. Right-click on database Engine **SQL Server (MSSQLSERVER)** and then click on **Properties**. Click on **Log On** and provide the user name and password created in the above step, and then click on **apply** and **OK** to apply changes.

 ![Microsoft SQL Server engine log on account](./images/mssql-configmanager-logon.png "Microsoft SQL Server engine log on account")


##  Task 3: Enable the Always-On feature for Secondary Replica Database Engine

  * Repeat all the steps from Task 2 to enable the **Always On feature for Node2**.
  
##  Task 4: Configure Always On Availability Group Read-Scale Replica without a Cluster

1. Open SSMS from **Windows Start Menu**, once opened choose the Server type **Database Engine**, provide the Node1 server name, Choose the **Authentication** type Windows Authentication, and then click on **Connect**.

  ![Microsoft SQL Server Management Studio](./images/msql-managementstudio.png "Microsoft SQL Server Management Studio")

2. Navigate to **Always On High Availability**, right-click, and click on **New Availability Group Wizard**.

  ![Microsoft SQL Server Always On High Availability](./images/mssql-aoag-newwizard.png "Microsoft SQL Server Always On High Availability")

3. This screen shows the **Introduction** of setup Wizard.

  ![Microsoft SQL Server Always On High Availability wizard](./images/mssql-aoag-intro.png "Microsoft SQL Server Always On High Availability wizard")

4. In **Specify Options**, provide the **Availability group name**, and then click on **Next**.

  ![Microsoft SQL Server Always On High Availability name](./images/mssql-aoag-name.png "Microsoft SQL Server Always On High Availability name")

5. Select the database you need to create in the **Select Databases** section.

  ![Microsoft SQL Server Always On High Availability primary DB](./images/mssql-aoag-selectdb.png "Microsoft SQL Server Always On High Availability primary DB")

6. In **Specify Replicas**, click on **Replicas**, and then click on **Add Replica**. The setup will pop up **Connect to Server**.

  ![Microsoft SQL Server Always On High Availability read replica](./images/mssql-aoag-replica.png "Microsoft SQL Server Always On High Availability read replica")

7. click on **Connect**.

  ![Microsoft SQL Server Always On High Availability read replica connect](./images/mssql-aoag-secondnodeconnect.png "Microsoft SQL Server Always On High Availability read replica connect")

8. The **Replicas** screen is shown as follows.

  ![Microsoft sql server always on high availability read replicas](./images/mssql-aoag-replica-show.png "Microsoft sql server always on high availability read replicas")

9. In **Select Data synchronization**, and then select the **Automatic Seeding**.

  ![Microsoft sql server always on high availability automatic seeding](./images/mssql-aoag-autoseeding.png "Microsoft sql server always on high availability automatic seeding")

10. The **Validation** screen shown as follows.

  ![Microsoft sql server always on high availability validation](./images/mssql-aoag-validation.png "Microsoft sql server always on high availability validation")

11. The **Summary** screen shows as follows, and then click on **Finish**

  ![Microsoft sql server always on high availability Summary](./images/mssql-aoag-summary.png "Microsoft sql server always on high availability Summary")

12. The **Results** section shows the **The wizard completed successfully** message as shown in the following image, and then click on **Close**.

  ![Microsoft SQL server always on high availability wizard results](./images/mssql-aoag-result.png "Microsoft SQL server always on high availability wizard results")

13. Open the show dashboard on the newly created Availability Group. You can see the successfully primary and read replica shown in the following image.

  ![Microsoft SQL server always on high availability dashboard](./images/mssql-aoag-dashboard.png "Microsoft SQL server always on high availability dashboard")

  Congratulations !!! You Have Completed Successfully The Workshop. 

## Acknowledgements
* **Author** - Devinder Pal Singh, Senior Cloud Engineer, NA Cloud Engineering
* **Contributors** -  Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering
* **Last Updated By/Date** - Devinder Pal Singh, Senior Cloud Engineer, NA Cloud Engineering, July 2022