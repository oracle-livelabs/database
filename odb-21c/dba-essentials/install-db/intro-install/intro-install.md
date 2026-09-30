# Oracle Database 21c Installation

## About this Workshop

**Oracle Database Administration Essentials** is a task-oriented, quick start approach to familiarize you with Oracle Database administration. It features the basic know-hows of Oracle Database and helps you perform tasks essential to administer Oracle Database.

> **Note**: Upgrading an existing Oracle Database to a later version is not within the scope of this workshop. 

Estimated Workshop Time: 2 hours 

Watch this video to learn about the core *Oracle Database Breakthrough Innovations*.

[](youtube:sFQqiGCSh9c)

### Objectives

In this workshop, you will do the following.
 - Install Oracle Database with -
	 - *Desktop class*
	 - *Server class*
 - Create a database with -
	 - *Typical configuration*
	 - *Advanced configuration*

### Prerequisites

This lab assumes you have -

 - An Oracle Cloud account

## Appendix 1: How to Install Oracle Database?

Setting up Oracle Database is a two-step process, which involves installing the Oracle Database software and creating a database.

 - Install the Oracle Database software and configure your database using Oracle Database Setup Wizard (Installer).
 - Create additional databases using Oracle Database Configuration Assistant (Oracle DBCA).

### About database installer

The database installer is a graphical user interface utility to systematically install the Oracle Database software and create the database through a wizard. Depending on the type of installation, the installer can run Oracle DBCA automatically. However, you can also run Oracle DBCA manually after the installation.

During the installation:

 - If you select *Create and configure a single instance database*, the setup wizard not only installs the Oracle Database software but also runs Oracle DBCA automatically to create a single instance database.

 - If you select *Set Up Software Only*, the setup wizard installs only the Oracle Database software but does not create the database. To create a container database, run Oracle DBCA after you complete the software installation.

The database installer offers two types of installation - *Desktop class* with minimal configuration and *Server class* with advanced configuration. 

To install both system classes on the same host, you need different Oracle home locations.  
For this workshop, select any one installation type, *Desktop class* or *Server class*, in the database installer.

**About Oracle Database Configuration Assistant (Oracle DBCA)**

The Oracle DBCA tool helps you create and configure your Oracle Database but does not install the database software.

Consider the scenarios:

 - **Case #1**: You have installed only the database software with the database installer. Then, you must run Oracle DBCA to create a database.

 - **Case #2**: Along with installing the database software, you have also created a database with the installer. You can still run Oracle DBCA to create additional databases.

You can run Oracle DBCA only after you install the Oracle Database software using the database installer.  

Oracle DBCA offers two database creation modes - typical and advanced.

With the *Advanced* mode, you can customize the configurations of Oracle Database, such as storage locations, initialization parameters, management options, database options, passwords for administrator accounts, and so on.

Whereas if you select the *Typical* mode, though it gives fewer choices to configure, you can create an Oracle Database very quickly.

Let us install Oracle Database 21c as explained in the subsequent labs and explore these options in detail.

### Installation prerequisites

Before installing the Oracle Database software, the installer performs several automated checks to verify whether the hardware and the software required for installation are available. If your system does not meet any specific requirement, it displays a corresponding error message. The requirements may vary depending upon the system and the operating system you are using.

### Minimum recommendations

 - 1 GB RAM
 - Sufficient swap space
 - Installation of service packages and patches
 - Use the correct file system format
 - Access to the database installer
 - General knowledge about product installation

Oracle Database Enterprise Edition requires *7.8 GB* of local disk storage space to install the Oracle Database software.

Oracle recommends that you allocate approximately *100 GB* to provide additional space for applying any future patches on top of the existing Oracle home.

Click the next lab to **Get Started**.

## Learn more

 - [Blog on Introducing Oracle Database 21c](https://blogs.oracle.com/database/introducing-oracle-database-21c)
 - [Oracle Database Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/index.html)
 - [Oracle Cloud Infrastructure Documentation](https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/overview.htm)


## Acknowledgments

 - **Author**: Manish Garodia, Database User Assistance Development
 - **Contributors**: Suresh Rajan, Prakash Jashnani, Subhash Chandra, Subrahmanyam Kodavaluru, Dharma Sirnapalli
 - **Last Updated By/Date**: Manish Garodia, August 2024
