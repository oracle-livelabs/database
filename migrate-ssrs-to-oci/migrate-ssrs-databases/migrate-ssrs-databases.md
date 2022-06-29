# Migrate Microsoft SQL Server Reporting Services (SSRS) Databases in Compute Instance

## Introduction

This lab walks you through how to Migrate Microsoft SQL Server Reporting Services (SSRS) Databases in Compute Instance and configure the Microsoft SQL Server Reporting (SSRS) services to existing SSRS databases. 

Estimated Time:  1 hour

### Objectives
In this lab, you will learn to :
* Restore the SQL Server Databases
* Configure the Microsoft SQL Server Reporting (SSRS) services with existing ReportServer and ReportServerTempdb databases. 

### Prerequisites  

This lab assumes you have:
- A Free or LiveLabs Oracle Cloud account
- IAM policies to create resources in the compartment

##  Task 1: Download the sample database backups for Microsoft SQL Server Report Server services 

1. RDP to the Bastion host server using the username .\opc and password. From the Bastion host, opens the Remote Desktop and connect to the Microsoft SSRS server using the private IP Address.

2. Download the Microsoft SSRS Sample DB Backups using the [link](https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/ssrsbackupfiles.zip) from the browser. 

  ![SSRS Backup file zip](./images/ssrsbackupzipfile.png "SSRS Backup file zip")

3. Once the **ssrsbackupfiles.zip** is downloaded successfully, unzip the files to the configured SQL Server backup folder to avoid permission issues.  Right-click on Database engine properties to get the default backup locations.

  ![SSRS Backup file unzip to SQL Backup location](./images/ssrsbackupzipsqlbackuplocation.png "SSRS Backup file unzip to SQL Backup location")

4. The unzipped folder contains ReportServer database backup files, an encryption key, and one text file, as shown in the image below.

  ![SSRS backup files and the encryption key](./images/ssrsbackupscontent.png "SSRS backup files and the encryption key")

##  Task 2: Restore the **ReportServer** Database

1. Open SSMS from Windows Start Menu. Once opened, choose the Server type Database Engine, provide the SSRS server name, Choose the Authentication type Windows Authentication, and then click on Connect.

2. Once successfully connected to the database engine, right-click on **Databases**, and then click on **Restore Database**.

  ![Restore Database Wizard](./images/restoredatabase.png "Restore Database Wizard")

3. Choose the **Device**, and then click on the three-dot button to select the backup files. 

  ![Restore Database Wizard device selection](./images/restoredatbasedevice.png "Restore Database Wizard device selection")

4. Click on **Add** to select ReportServer backup file to restore.

  ![Restore Database Wizard add files](./images/restorebackupaddfiles.png "Restore Database Wizard add files")

5. Select the ReportServer backup file **ReportServer.bak**, and then click on **OK**.

  ![Report Server database backup file](./images/ssrs-reportserverbackupfile.png "Report Server database backup file")

  ![Report Server database backup file](./images/reportserverbackupfileresult.png "Report Server database backup file")
  
6. The ReportServer database is ready to restore as shown below, and then click on **OK** to restore the Database.

  ![Report Server database restore](./images/ssrs-reportserverdbrestore.png "Report Server database restore")

7. The successful restoration image is shown as follows. 

  ![Report Server database restore success](./images/reporterverdatabaserestoresuccess.png "Report Server database restore success")

##  Task 3: Restore the **ReportServerTempdb** Database.

1. Repeat all the steps from **Task3** to restore the **ReportServerTempdb** database.

##  Task 4: Restore the **testdb** database.

1. Repeat all the steps from **Task3** to restore the **testdb** Database. 

##  Task 5: Configure the Microsoft SQL Server Reporting (SSRS) services with existing SSRS databases

1. Click on the Windows start menu, navigate to Microsoft SQL Server Reporting Services, and click on **Report server Configuration Manager** to open the configuration manager. 

  ![Report Server configuration manager](./images/ssrsconfigurationmanager.png "Report Server configuration manager")

2. Click on **Connect** to connect to ReportServer. 

  ![Connect to Report Server configuration manager](./images/ssrsconfigurationmanageropen.png "Connect to Browse Report Server configuration manager")

3. Click on **Web Service URL**, and then click on **Apply**.

  ![Report Server configuration manager web service url](./images/ssrsconfigwebserverurl.png "Report Server configuration manager web service URL")

4. The **Web Service URL** will be enabled, as shown in the following image. 

  ![Report Server web service URL success](./images/ssrsconfigwebserverurlsuccess.png "Report Server web service URL success")

5. Click on **Database** on left pane, and then click on **Change Database**.

  ![Report Server configuration manager database config](./images/ssrsselectdatabase.png "Report Server configuration manager database config")

6. Choose the database server name and click on **Test Connection**

  ![Report Server configuration manager change database](./images/ssrstestdbconnection.png "Report Server configuration manager change database")

7. You can see the successful test connection, as shown in the following image. 

  ![Report Server configuration manager database connection test](./images/ssrstestdbconnectionsuccess.png "Report Server configuration manager database connection test")

8. Choose the Database **ReportServer**, and then click on **Next**.

  ![Report Server configuration ReportServer DB](./images/ssrsdatbaseselect.png "Report Server configuration ReportServer DB")

9. Choose the Authentication Type, **Service Credentials** and then click on **Next**.

  ![Report Server service credentials](./images/ssrsservicecredentials.png "Report Server service credentials")

10. Change the Database summary as shown in the following image. 

  ![Report Server database configuration manger summary](./images/ssrschanedbsummary.png "Report Server database configuration manger summary")

11. The progress will show as successful as shown in the following image. 

  ![Report Server database configuration manger result](./images/ssrsdbfinish.png "Report Server database configuration manger result")

12. The successful configuration of the Database is shown in the following image. 

  ![Report Server database configuration database configuration](./images/ssrsdbconfigsuccess.png "Report Server database configuration database configuration")

13. Click on the **Web Portal URL**, and then click on **Apply**. 

  ![Report Server database configuration web portal url](./images/ssrswebportalurl.png "Report Server database configuration web portal url")

14. The successfully configured web portal URL is shown in the following image. 

  ![Report Server configuration web portal URL success](./images/ssrswebportalurlsuccess.png "Report Server  configuration web portal URL success")

15. Click on **Encryption Keys**, and then click on **Restore**.

  ![Report Server database configuration encryption keys](./images/ssrsencryptionkey.png "Report Server database configuration encryption keys")

16. Click on the three-dot button to select the encryption key. 

  ![Report Server database configuration encryption key location](./images/ssrsencryptionkeylocatin.png "Report Server database configuration encryption key location")

17. Choose the key **mykey.snk** created in **Task1**. 

  ![Report Server database configuration encryption key file select](./images/ssrsencryptionkeyfileopen.png "Report Server database configuration encryption key file select")

18. Type the password of the **mykey.snk** file stored in **Encryptionkey** text file, extracted in the **Task1**.

  ![Restore Encryption key](./images/ssrsencryptionkeypassword.png "Restore Encryption key")

19. The successful restore encryption key is shown in the following image. 

  ![Restore Encryption key success](./images/ssrsencryptionkeyrestoresuccessmsg.png "Restore Encryption key success")

20. Navigate to **Web Service URL** and then click on **Report Server Web Service URLs** 

  ![Report Server Web Service URLs](./images/openwebserverurl.png "Report Server Web Service URLs")

21. The URL will open in the web browser, provide the windows credentials, and click on **Sign in**. 

  ![Report Server Web Service URLs](./images/ssrsbrowserurlsignin.png "Report Server Web Service URLs")

22. The successful report execution is shown in the following image, and click on **test** report to view the report data.

  ![Report Server reports](./images/ssrsrdlfile.png "Report Server reports")

23. The test report will show the timestamp in the following image. 

  ![Report Server  report](./images/ssrsreportresults.png "Report Server report")


  Congratulations !!! You Have Completed Successfully The Workshop.

## Acknowledgements
* **Author** - Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering
* **Contributors** -  Devinder Pal Singh, Senior Cloud Engineer, NA Cloud Engineering
* **Last Updated By/Date** - Ramesh Babu Donti, Principal Cloud Architect, NA Cloud Engineering, June 2022