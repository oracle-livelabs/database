# Oracle Database deletion and deinstallation

## About this workshop

This workshop explains how to delete an Oracle Database, remove the database software and its components, and delete Oracle home from your host.

Estimated workshop time: 45 mins

### Objectives

In this workshop, you will do the following:
 - Delete an Oracle Database but retain Oracle home.
 - Remove the database including the database software, its components, and Oracle home.

### Prerequisites

This lab assumes you have -
 - An Oracle Cloud account
 - Oracle Database installed on your host

## About database removal

Oracle provides different options to remove Oracle Database from your host.

You can do the following:
 - Delete only the database but keep the database software and its components intact. For this, you can use Oracle Database Configuration Assistant (Oracle DBCA).
 - Remove the database completely along with the database software, its components, and Oracle home. For this, you can use the *deinstall* command.

[](include:user-data)

> **Note:**  This workshop uses two Oracle homes for demonstration purpose. It is not a requirement for Oracle Database to have two homes. You can delete or deinstall an Oracle Database from a single Oracle home. 

## Oracle Database Configuration Assistant (Oracle DBCA)

Oracle DBCA is a tool that helps you manage the databases. You can perform various operations, such as create databases, configure existing databases, delete databases, and so on. 

When you delete a database, it also deletes user data but does not remove the database software or Oracle home. You can create another database in this Oracle home and use the existing database software.

## The deinstall command

The `deinstall` command wipes out Oracle Database completely from your host.

It performs various activities, such as:

 - Stops and removes the Oracle Database software
 - Deletes database components, such as listener, Oracle base, and so on
 - Removes the inventory location, if you have a single instance database
 - Removes the database instance including the CDB and all PDBs
 - Deletes user data and schemas
 - Deletes Oracle home

The `deinstall` command resides in Oracle home under the subdirectory `deinstall`.

For example -

```
$ /u01/app/oracle/product/23.4.0/dbhome_1/deinstall
```

The path may differ depending on the system you are using.

If the database software in Oracle home is not running for any reason (let's say, due to an unsuccessful installation), then `deinstall` cannot determine the configuration. You must provide all the configuration details either interactively or in a response file. A response file contains configuration values for Oracle home that `deinstall` uses.

> **Note**: If you have a standalone Oracle Database on a node in a cluster, and if multiple databases have the same Global Database Name (GDN), then you cannot use `deinstall` to remove only one database.

The location of the `deinstall` log files depends on the number of Oracle homes on the host. For a single Oracle home, `deinstall` removes the *oraInventory* folder and saves the log files in the */tmp* directory.

### For multiple Oracle homes

If the host contains more than one Oracle home, then the `deinstall` command functions as follows:

 - Does not delete the inventory location
 - Saves the log files in the *oraInventory* folder
 - Removes details of the Oracle home from where you run `deinstall`, for example *OraDB23Home1*, from the `inventory.xml` file

If you have removed all other Oracle homes from your host, then `deinstall` deletes the inventory directory also.

### Files that deinstall removes

The `deinstall` command removes the following files and directory contents in the Oracle base directory of the Oracle Database installation user (oracle):

 - `admin`
 - `cfgtoollogs`
 - `checkpoints`
 - `diag`
 - `oradata`
 - `fast_recovery_area`

This is true for a single instance Oracle Database where the central inventory, `oraInventory`, contains no other registered Oracle homes besides the Oracle home that you are unconfiguring and removing.

Oracle recommends that you configure your installations using an *Optimal Flexible Architecture (OFA)* guidelines, and that you use the Oracle base and Oracle home locations exclusively for the Oracle software. If you have any user data in the Oracle base locations for the user account who owns the database software, then `deinstall` deletes this data.

> **Note**: The `deinstall` command deletes Oracle Database configuration files, user data, and fast recovery area (FRA) files even if they are located outside of the Oracle base directory path. 

Click the next lab to **Get started**.

## Learn more

 - [Removing Oracle Database Software](https://docs.oracle.com/en/database/oracle/oracle-database/23/ladbi/removing-oracle-database-software.html#GUID-5619EBF0-C89E-4349-AE6F-A8F8B3B06BD1)

 - Workshop on how to [Install Oracle Database 23ai on OCI Compute](https://livelabs.oracle.com/pls/apex/r/dbpm/livelabs/view-workshop?wid=4055)

## Acknowledgments

 - **Author** - Manish Garodia, Database User Assistance Development
 - **Contributors** - Prakash Jashnani, Subhash Chandra, Subrahmanyam Kodavaluru, Manisha Mati
 - **Last Updated By/Date** - Manish Garodia, October 2024
