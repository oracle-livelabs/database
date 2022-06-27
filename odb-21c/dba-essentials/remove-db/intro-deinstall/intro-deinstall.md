# Oracle Database 21c deinstallation

## About this workshop

This workshop will guide you how to stop and remove Oracle Database software and delete database components from your host.

Estimated Workshop Time: 45 mins

### Objectives

In this workshop, you will learn how to use the *deinstall* command to remove Oracle Database from your host. During database removal, *deinstall* will delete the Oracle home and the Oracle Database components along with removing the database software.

> **Note:** If you have any user data in Oracle base or Oracle home locations, then `deinstall` deletes this data also. To safeguard your data and files, move them outside Oracle base and Oracle home before running `deinstall`. 

### Prerequisites

- An Oracle Cloud Account - Please view this workshop's LiveLabs landing page to see which environments are supported.

> **Note:** If you have a **Free Trial** account, when your Free Trial expires, your account will be converted to an **Always Free** account. You will not be able to conduct Free Tier workshops unless the Always Free environment is available. 
**[Click here for the Free Tier FAQ page.](https://www.oracle.com/cloud/free/faq.html)**

## Appendix 1: The Deinstall Command

The `deinstall` command performs various functions, such as:

 - Stops and removes the Oracle Database software
 - Deletes database components, such as listener, Oracle base, and so on
 - Removes the inventory location, if you have only one Database Instance on your host
 - Removes the Oracle Database instances including CDB and all PDBs
 - Deletes Oracle home

The `deinstall` command is located in Oracle home under the subdirectory `deinstall`. 

For example -

```
$ /opt/oracle/product/21c/dbhome_1/deinstall
```

The path may differ depending on the system you are using.

If the database software in Oracle home is not running for any reason (let's say, due to an unsuccessful installation), then `deinstall` cannot determine the configuration. You must provide all the configuration details either interactively or in a response file. A response file contains configuration values for Oracle home that `deinstall` uses.

> **Note:** If you have a standalone Oracle Database on a node in a cluster, and if multiple databases have the same Global Database Name (GDN), then you cannot use `deinstall` to remove only one database.

The location of the `deinstall` log files depends on the number of Oracle homes on the host. For a single Oracle home, `deinstall` removes the *oraInventory* folder and saves the log files in the */tmp* location.

### Behavior of `Deinstall` for multiple Oracle homes

If you have multiple Oracle homes on your host, then:

-   The `deinstall` command does not delete the inventory location.
-   The `deinstall` command saves the log files in the *oraInventory* folder.
-   The `deinstall` command removes the details of your Oracle home, for example *OraDB21Home1*, from the `inventory.xml` file.

If you remove all Oracle homes from your host, then `deinstall` deletes the inventory location.   

### Files Deleted by Deinstall

The `deinstall` command removes the following files and directory contents in the Oracle base directory of the Oracle Database installation user (oracle):

-   `admin`
-   `cfgtoollogs`
-   `checkpoints`
-   `diag`
-   `oradata`
-   `fast_recovery_area`

This is true for a single instance Oracle Database where the central inventory, `oraInventory`, contains no other registered Oracle homes besides the Oracle home that you are deconfiguring and removing.

Oracle recommends that you configure your installations using an *Optimal Flexible Architecture (OFA)* configuration, and that you use the Oracle base and Oracle home locations exclusively for the Oracle software. If you have any user data in the Oracle base locations for the user account who owns the database software, then `deinstall` deletes this data.

> **Note**: The `deinstall` command deletes Oracle Database configuration files, user data, and fast recovery area (FRA) files even if they are located outside of the Oracle base directory path. 

Click on the next lab to **Get Started**.

## Learn More

- [Blog on Introducing Oracle Database 21c](https://blogs.oracle.com/database/introducing-oracle-database-21c)
- Workshop on how to [Install Oracle Database 21c on OCI Compute](https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=871)

## Acknowledgements

-   **Author** - Manish Garodia, Principal User Assistance Developer, Database Technologies

-   **Contributors** - Subrahmanyam Kodavaluru, Suresh Rajan, Prakash Jashnani, Malai Stalin, Subhash Chandra, Dharma Sirnapalli

-   **Last Updated By/Date** - Manish Garodia, March 2022
