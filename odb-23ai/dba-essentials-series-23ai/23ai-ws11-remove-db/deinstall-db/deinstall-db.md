# Deinstall Oracle Database and remove Oracle home

## Introduction

This lab walks you through the steps for removing the Oracle Database software from your host. It not only shows how to delete the database but also removes Oracle home and the database components completely.

Estimated time: 10 minutes

### Objectives

Remove the Oracle Database software, delete Oracle Database, and remove *Oracle home 2* from your host system using the *deinstall* command.

> **Note**: [](include:user-data)

### Prerequisites

This lab assumes you have -

 - An Oracle Cloud Account
 - Completed all previous labs successfully

You are logged in to your host as *oracle*, the user who can remove Oracle Database.

> **Note**: [](include:example-values)

## Task 1: Remove Oracle Database software and delete Oracle Database

In this task, you will remove the database, *orcl1*, from Oracle home 2 using the *`deinstall`* command.

> **Note**: The `deinstall` command deletes Oracle Database configuration files, user data, and fast recovery area (FRA) files even if they are outside the Oracle base directory.

1. Open a terminal window and go to Oracle home 2 where the `deinstall` command resides.   
	In the Livelabs environment, `deinstall` resides in the following directory.

    ```
	$ <copy>cd /u01/app/oracle/product/23.4.0/dbhome_2/deinstall</copy>
	```

	> **Caution**: Do not shut down the database or stop any processes for the database that you are removing before running `deinstall`.

1.  Run this command to start the deinstallation process.  

    ```
	$ <copy>./deinstall</copy>
	```

    > **Note**: For every step, `deinstall` displays the values in square brackets `[ ]`. You can press **Enter** to use the default or specify a different value manually. 

	## Output

	It returns the following.

	```
	Checking for required files and bootstrapping ...
	Please wait ...
	Location of logs /u01/app/oracle/oraInventory/logs/

	############ ORACLE DECONFIG TOOL START ############


	######################### DECONFIG CHECK OPERATION START #########################
	## [START] Install check configuration ##


	Checking for existence of the Oracle home location /u01/app/oracle/product/23.4.0/dbhome_2
	Oracle Home type selected for deinstall is: Oracle Single Instance Database
	Oracle Base selected for deinstall is: /u01/app/oracle
	Checking for existence of central inventory location /u01/app/oracle/oraInventory

	## [END] Install check configuration ##


	Network Configuration check config START

	Network de-configuration trace file location: /u01/app/oracle/oraInventory/logs/netdc_check20XX-06-17_10-32-43AM.log
	```

1.  The window prompts to specify the listeners that you want to unconfigure.

	```
	Specify all Single Instance listeners that are to be de-configured. Enter .(dot) to deselect all.
	[LISTENER]: **Enter**
	```

    For this task, press **Enter** to remove the current listener.

	It returns the following.

	```
	Network Configuration check config END

	Database Check Configuration START

	Database de-configuration trace file location: /u01/app/oracle/oraInventory/logs/databasedc_check20XX-06-17_10-35-37AM.log
	```

1. The window provides an option to specify the database instances that you want to remove from the current Oracle home. 

    > **Tip**: If you have multiple database instances in an Oracle home, then you can either remove a specific database instance or remove all database instances together using `deinstall`. To specify multiple databases, enter the database name followed by a comma.

	```
	Use comma as separator when specifying list of values as input

	Specify the list of database names that are configured in this Oracle home [orcl1]: **Enter**
	```

	For this task, press **Enter** to remove the default database instance from Oracle home 2.

	## Output

	It returns the following.

	```
	###### For Database 'orcl1' ######

	Single Instance Database
	The diagnostic destination location of the database: /u01/app/oracle/diag/rdbms/orcl1
	Storage type used by the Database: FS
	Database file location: /u01/app/oracle/oradata/orcl1,/opt/oracle/recovery_area/orcl1
	Fast recovery area location: /u01/app/oracle/recovery_area/orcl1
	database spfile location: /u01/app/oracle/product/23.4.0/dbhome_2/dbs/spfileorcl1.ora
	```

1.  The `deinstall` command discovers the details of the databases automatically in the current Oracle home and asks if you want to modify them. The default option is *n*, which means no.

	```
	The details of database(s) orcl1 have been discovered automatically. Do you still want to modify the details of orcl1 database(s)? [n]: **Enter**
	```

	For this task, press **Enter** to continue with the default values.

	> **Note**: To verify each detail and to specify this information manually, enter `y`. You can then provide the details of your database, for example, the database name, storage type, location for diagnostic destination, fast recovery area, spfile, and so on. 

	## Output

	It returns the following.

	```
	Database Check Configuration END

	######################### DECONFIG CHECK OPERATION END #########################


	####################### DECONFIG CHECK OPERATION SUMMARY #######################
	Oracle Home selected for deinstall is: /u01/app/oracle/product/23.4.0/dbhome_2
	Inventory Location where the Oracle home registered is: /u01/app/oracle/oraInventory
	Following Single Instance listener(s) will be de-configured: LISTENER
	The following databases were selected for de-configuration. The databases will be deleted and will not be useful upon de-configuration : orcl1
	Database unique name : orcl1
	Storage used : FS
	```

1.  The window awaits for your confirmation to remove the Oracle Database instance from your host.

    ```
	Do you want to continue (y - yes, n - no)? [n]: y
    ```

    Enter ***y*** to start removing the database.

	> **Tip**: The default option is **n**, which means no. If you press Enter or type **n** here, then `deinstall` exits without removing the database.

    The deinstallation process creates log files and starts removing the database.

	## Output

	It returns the following.

	```
	A log of this session will be written to: '/u01/app/oracle/oraInventory/logs/deinstall_deconfig20XX-06-17_10-37-24-AM.out'
	Any error messages from this session will be written to: '/opt/oracle/oraInventory/logs/deinstall_deconfig20XX-06-17_10-37-24-AM.err'

	######################## DECONFIG CLEAN OPERATION START ########################
	Database de-configuration trace file location: /u01/app/oracle/oraInventory/logs/databasedc_clean20XX-06-17_10-37-25AM.log
	Database Clean Configuration START orcl1
	This operation may take few minutes.
	Database Clean Configuration END orcl1

	Network Configuration clean config START

	Network de-configuration trace file location: /u01/app/oracle/oraInventory/logs/netdc_clean20XX-06-17_10-37-25AM.log

	De-configuring Single Instance listener(s): LISTENER

	De-configuring listener: LISTENER
		Stopping listener: LISTENER
		Listener stopped successfully.
		Deleting listener: LISTENER
		Listener deleted successfully.
	Listener de-configured successfully.

	De-configuring Naming Methods configuration file...
	Naming Methods configuration file de-configured successfully.

	De-configuring backup files...
	Backup files de-configured successfully.

	The network configuration has been cleaned up successfully.

	Network Configuration clean config END


	######################### DECONFIG CLEAN OPERATION END #########################


	####################### DECONFIG CLEAN OPERATION SUMMARY #######################
	Successfully de-configured the following database instances : orcl1
	Following Single Instance listener(s) were de-configured successfully: LISTENER
	#######################################################################


	############# ORACLE DECONFIG TOOL END #############

	Using properties file /tmp/deinstall20XX-06-17_10-37-05AM/response/deinstall_20XX-06-17_10-37-24-AM.rsp
	Location of logs /u01/app/oracle/oraInventory/logs/

	############ ORACLE DEINSTALL TOOL START ############





	####################### DEINSTALL CHECK OPERATION SUMMARY #######################
	A log of this session will be written to: '/u01/app/oracle/oraInventory/logs/deinstall_deconfig20XX-06-17_10-37-24-AM.out'
	Any error messages from this session will be written to: '/u01/app/oracle/oraInventory/logs/deinstall_deconfig20XX-06-17_10-37-24-AM.err'

	######################## DEINSTALL CLEAN OPERATION START ########################
	## [START] Preparing for Deinstall ##
	Setting LOCAL_NODE to localhost
	Setting CRS_HOME to false
	Setting oracle.installer.invPtrLoc to /tmp/deinstall20XX-06-17_10-37-05AM/oraInst.loc
	Setting oracle.installer.local to false

	## [END] Preparing for Deinstall ##

	Oracle Universal Installer clean START

	Detach Oracle home 'OraDB23Home2' from the central inventory on the local node : Done

	Delete directory '/u01/app/oracle/product/23.4.0/dbhome_2' on the local node : Done

	The Oracle Base directory '/u01/app/oracle' will not be removed on local node. The directory is in use by Oracle Home '/u01/app/oracle/product/23.4.0/dbhome_1'.

	You can find a log of this session at:
	'/u01/app/oracle/oraInventory/logs/Cleanup20XX-06-17_10-40-22AM.log'

	Oracle Universal Installer clean END


	## [START] Oracle install clean ##


	## [END] Oracle install clean ##


	######################### DEINSTALL CLEAN OPERATION END #########################


	####################### DEINSTALL CLEAN OPERATION SUMMARY #######################
	Successfully detached Oracle home 'OraDB23Home2' from the central inventory on the local node.
	Successfully deleted directory '/u01/app/oracle/product/23.4.0/dbhome_2' on the local node.
	Oracle Universal Installer cleanup was successful.

	Review the permissions and contents of '/u01/app/oracle' on nodes(s) 'localhost'.
	If there are no Oracle home(s) associated with '/u01/app/oracle', manually delete '/u01/app/oracle' and its contents.
	Oracle deinstall tool successfully cleaned up temporary directories.
	#######################################################################


	############# ORACLE DEINSTALL TOOL END #############
	```

	You have completed the deinstallation process and removed the database, *`orcl1`*, from your host.

You have successfully reached the end of this workshop on *Oracle Database Deinstallation*. 

In this workshop, you learned how to: 
 - Delete an Oracle Database from an Oracle home keeping the database software and Oracle home intact. 
 - You deleted another Oracle Database from a different Oracle home, removed the database software and the components, and also deleted the Oracle home from the host.

## Acknowledgments

 - **Author** - Manish Garodia, Database User Assistance Development
 - **Contributors** - Prakash Jashnani, Subhash Chandra, Subrahmanyam Kodavaluru, Manisha Mati
 - **Last Updated By/Date** - Manish Garodia, October 2024
