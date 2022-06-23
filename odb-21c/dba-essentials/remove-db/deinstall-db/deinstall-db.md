# Deinstall Oracle Database

## Introduction

This lab walks you through the steps for stopping and removing the Oracle Database software and deleting the database.  

Estimated Time: 10 minutes

### Objectives

Remove the Oracle Database software, delete Oracle Database, and remove Oracle home from your host system using the *deinstall* command.

> **Note:** If you have any user data in Oracle base or Oracle home locations, then `deinstall` deletes this data. Move your data and files outside Oracle base and Oracle home before running `deinstall`.  

### Prerequisites
This lab assumes you have -
- An Oracle Cloud Account - Please view this workshop's LiveLabs landing page to see which environments are supported.
- Oracle Database 21c installed and configured.
- Completed -
	- Lab: Prepare setup (*Free-tier* and *Paid Tenants* only)
	- Lab: Setup compute instance


## **Task 1:** Remove Oracle Database

For this lab, remove the Oracle Database, *CDB1*, using the `deinstall` command. 

To remove Oracle Database from your host system, do the following. 

1.  Log in to your host as *oracle*, the user who can remove Oracle Database.

1.  Change the current working directory to `$ORACLE_HOME/deinstall`. This is the directory where `deinstall` is located.   
    The path may differ depending on the system you are using. For this lab, `deinstall` is located in the following directory. 

    ```
	$ <copy>cd /opt/oracle/product/21c/dbhome_1/deinstall</copy>
	```

	> **Note:** Do not shut down the Oracle Database or stop any database processes before running `deinstall`.

1.  Start the Oracle Database deinstallation process with this command.  

    ```
	$ <copy>./deinstall</copy>
	```

    > **Note:** For every step, `deinstall` displays the default input options in brackets [ ]. You can either specify the options manually or press **Enter** to leave the default option and proceed. 

	## Output

	The values may differ depending on the system you are using.
	
	```
	Checking for required files and bootstrapping ...
	Please wait ...
	Location of logs /opt/oracle/oraInventory/logs/

	############ ORACLE DECONFIG TOOL START ############


	######################### DECONFIG CHECK OPERATION START #########################
	## [START] Install check configuration ##


	Checking for existence of the Oracle home location /opt/oracle/product/21c/dbhome_1
	Oracle Home type selected for deinstall is: Oracle Single Instance Database
	Oracle Base selected for deinstall is: /opt/oracle
	Checking for existence of central inventory location /opt/oracle/oraInventory

	## [END] Install check configuration ##

	## [START] GIMR check configuration ##
	Checking for existence of GIMR 
	GIMR Home not detected
	## [END] GIMR check configuration ##

	Network Configuration check config START

	Network de-configuration trace file location: /opt/oracle/oraInventory/logs/netdc_check2022-02-27_10-32-43AM.log
	```

1.  The `deinstall` command prompts to specify all single instance listeners that you want to deconfigure.  

	```
	Specify all Single Instance listeners that are to be de-configured. Enter .(dot) to deselect all. 
	[LISTENER]: **Enter**
	```

    Press **Enter** to remove the current listener.

	## Output

	The values may differ depending on the system you are using.

	```
	Network Configuration check config END

	Database Check Configuration START

	Database de-configuration trace file location: /opt/oracle/oraInventory/logs/databasedc_check2022-02-27_10-35-37AM.log
	```

1.  If you have multiple Database Instances in your Oracle home, then you can either delete specific database instances or remove all instances together using `deinstall`.   

    > **Note:** To enter specific instance names that you want to delete, use comma as the separator. To remove all the instances, press **Enter**.

	```
	Use comma as separator when specifying list of values as input

	Specify the list of database names that are configured in this Oracle home [CDB1]: **Enter**
	```

    For this lab, the Database Instance name is *CDB1*. Press **Enter** to remove the default single instance database.

	## Output

	The values may differ depending on the system you are using.

	```
	###### For Database 'CDB1' ######

	Single Instance Database
	The diagnostic destination location of the database: /opt/oracle/diag/rdbms/cdb1
	Storage type used by the Database: FS
	Database file location: /opt/oracle/oradata/CDB1,/opt/oracle/recovery_area/CDB1
	Fast recovery area location: /opt/oracle/recovery_area/CDB1
	database spfile location: /opt/oracle/dbs/spfileCDB1.ora
	```


1.  The `deinstall` command prompts you to modify the details of the discovered databases. The default option is *n* which means no.

	```
	The details of database(s) CDB1 have been discovered automatically. Do you still want to modify the details of CDB1 database(s)? [n]: **Enter**
	```

    > **Note:** If you enter `y` in this prompt, `deinstall` allows you to specify the details of your Oracle Database. You can manually enter each detail, such as the type of database, the diagnostic destination location, the storage type, the fast recovery area location, the spfile location, whether Archive Mode is enabled, and so on.  

    For this lab, press **Enter** to select the default option and `deinstall` automatically discovers the details of your Oracle Database.

	## Output

	The values may differ depending on the system you are using.

	```
	Database Check Configuration END

	######################### DECONFIG CHECK OPERATION END #########################


	####################### DECONFIG CHECK OPERATION SUMMARY #######################
	Oracle Home selected for deinstall is: /opt/oracle/product/21c/dbhome_1
	Inventory Location where the Oracle home registered is: /opt/oracle/oraInventory
	Following Single Instance listener(s) will be de-configured: LISTENER
	The following databases were selected for de-configuration. The databases will be deleted and will not be useful upon de-configuration : CDB1
	Database unique name : CDB1
	Storage used : FS
	```

1.  The `deinstall` command prompts you to confirm removing your Oracle Database. 

    ```
	Do you want to continue (y - yes, n - no)? [n]: y
    ```

    Enter ***y*** to initiate the removal process.

	> **Note:** The default option is **n** which means no. If you directly press Enter or specify **n** here, then `deinstall` exits without removing the Oracle Database.   

    The deconfiguration clean operation creates log files and completes removing the database.

	## Output

	The values may differ depending on the system you are using.

	```
	A log of this session will be written to: '/opt/oracle/oraInventory/logs/deinstall_deconfig2022-02-27_10-37-24-AM.out'
	Any error messages from this session will be written to: '/opt/oracle/oraInventory/logs/deinstall_deconfig2022-02-27_10-37-24-AM.err'

	######################## DECONFIG CLEAN OPERATION START ########################
	## [START] GIMR configuration update ##
	## [END] GIMR configuration update ##
	Database de-configuration trace file location: /opt/oracle/oraInventory/logs/databasedc_clean2022-02-27_10-37-25AM.log
	Database Clean Configuration START CDB1
	This operation may take few minutes.
	Database Clean Configuration END CDB1

	Network Configuration clean config START

	Network de-configuration trace file location: /opt/oracle/oraInventory/logs/netdc_clean2022-02-27_10-37-25AM.log

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
	Successfully de-configured the following database instances : CDB1
	Following Single Instance listener(s) were de-configured successfully: LISTENER
	#######################################################################


	############# ORACLE DECONFIG TOOL END #############

	Using properties file /tmp/deinstall2022-02-27_10-37-05AM/response/deinstall_2022-02-27_10-37-24-AM.rsp
	Location of logs /opt/oracle/oraInventory/logs/

	############ ORACLE DEINSTALL TOOL START ############





	####################### DEINSTALL CHECK OPERATION SUMMARY #######################
	A log of this session will be written to: '/opt/oracle/oraInventory/logs/deinstall_deconfig2022-02-27_10-37-24-AM.out'
	Any error messages from this session will be written to: '/opt/oracle/oraInventory/logs/deinstall_deconfig2022-02-27_10-37-24-AM.err'

	######################## DEINSTALL CLEAN OPERATION START ########################
	## [START] Preparing for Deinstall ##
	Setting LOCAL_NODE to localhost
	Setting CRS_HOME to false
	Setting oracle.installer.invPtrLoc to /tmp/deinstall2022-02-27_10-37-05AM/oraInst.loc
	Setting oracle.installer.local to false

	Removing directory '/opt/oracle/homes/OraDB21Home2' on node(s) 'localhost'
	## [END] Preparing for Deinstall ##

	Oracle Universal Installer clean START

	Detach Oracle home 'OraDB21Home2' from the central inventory on the local node : Done

	Delete directory '/opt/oracle/product/21c/dbhome_1' on the local node : Done

	The Oracle Base directory '/opt/oracle' will not be removed on local node. The directory is in use by Oracle Home '/opt/oracle/product/21c/dbhome_1'.

	You can find a log of this session at:
	'/opt/oracle/oraInventory/logs//Cleanup2022-02-27_10-40-22AM.log'

	Oracle Universal Installer clean END


	## [START] Oracle install clean ##


	## [END] Oracle install clean ##


	######################### DEINSTALL CLEAN OPERATION END #########################


	####################### DEINSTALL CLEAN OPERATION SUMMARY #######################
	Successfully detached Oracle home 'OraDB21Home2' from the central inventory on the local node.
	Successfully deleted directory '/opt/oracle/product/21c/dbhome_1' on the local node.
	Oracle Universal Installer cleanup was successful.

	Review the permissions and contents of '/opt/oracle' on nodes(s) 'localhost'.
	If there are no Oracle home(s) associated with '/opt/oracle', manually delete '/opt/oracle' and its contents.
	Oracle deinstall tool successfully cleaned up temporary directories.
	#######################################################################


	############# ORACLE DEINSTALL TOOL END #############
	```

    The above message confirms that you have completed the deinstallation and deleted Oracle Database from your host. You can close the terminal window.

> **Note:** The `deinstall` command deletes Oracle Database configuration files, user data, and fast recovery area (FRA) files even if they are located outside of the Oracle base directory path.

You have successfully completed this workshop on *Oracle Database 21c Deinstallation*. 

In this workshop, you have learned how to remove the database software, delete Oracle home and the database components, and remove Oracle Database from your host system.

## Acknowledgements

- **Author** - Manish Garodia, Principal User Assistance Developer, Database Technologies

- **Contributors** - Subrahmanyam Kodavaluru, Suresh Rajan, Prakash Jashnani, Malai Stalin, Subhash Chandra, Dharma Sirnapalli

- **Last Updated By/Date** - Manish Garodia, March 2022
