# Introduction

## Introduction to Oracle Fleet Patching & Provisioning ##
Oracle Database provides incredible features, performance, security and availability. But when your database fleet starts growing from a few units to a few hundreds, keeping it up to date with the latest patches and release versions can be time-consuming, and sometimes error-prone.

Oracle Fleet Patching and Provisioning, or FPP, is the product that Oracle has developed to help you maintaining your database fleet life cycle under control.
Routine operations like provisioning new clusters and databases, installing patched Oracle binaries, patching clusters and databases or upgrading them, are completely automated by Fleet Patching and Provisioning.

Patched versions of Oracle Binaries, or Gold Images, can be imported and stored on the FPP Server. From there, FPP can copy and install them as new Oracle Homes on the target hosts. They become working copies ready to run databases. The new working copies are always provisioned as new Oracle Homes.
Once you are ready to patch, with a single-command you can instruct FPP to patch one, a few, or all the databases in an Oracle Home from their current version to the new one. FPP takes care of everything. If the database is in a Real Application Clusters configuration, the services are relocated gracefully, honoring their drain timeouts, and the database is restarted one node at the time, so that your database is always available. If you use session draining and application continuity, the whole patching process is completely transparent to your applications.
At the end of the patching process FPP runs datapatch to update your database catalog.

FPP commands can be ran simultaneously on hundreds of targets, making possible to patch your whole database fleet every quarter.
A single command line, or a single RESTful API call, replaces dozens or hundreds of manual tasks.
Forget about boring and time-consuming patching campaigns: Fleet Patching and Provisioning gives you the automation, standardization and protection level that your auditors are looking for.

Estimated Workshop Time:  4 hours

Watch the video below for an overview on Oracle Fleet Patching and Provisioning.
[](youtube:jFAOPGNpcoY)

### About this Workshop

Fleet Patching and Provisioning 19c is meant to be used by customers to patch their database fleet on-premises. It is generally not recommended to use it for patching Oracle Cloud database services, because the current version does not integrate with the OCI automation tooling (please note that is not completely true: Oracle does use FPP internally to patch some OCI services, but this is not visible to our customers). However, in this workshop we will use OCI services to setup and test FPP.

For the scope of this workshop, we will use two servers:
* The **FPP server** (fpps01), created as a single-node [Virtual DB System (DBCS-VM)](https://docs.cloud.oracle.com/en-us/iaas/Content/Database/Concepts/overview.htm).
* One **FPP target** (fppc), created on a [Compute Service instance](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm).

FPP is part of the Oracle Grid Infrastructure stack: the FPP Server requires the full GI stack installed and configured on a server or cluster. This is the reason why we will use a Virtual DB System (DBCS) for it: full Grid Infrastructure stacks cannot be provisioned on compute instances.

### Workshop Objectives
* Getting acquainted with the environment and rhpctl command line tool
* Importing Gold Images
* Provisioning Oracle Restart environments
* Installing Oracle Homes (Working Copies)
* Creating and patching Oracle Databases

### Workshop Prerequisites
* A Free Tier, Paid or LiveLabs Oracle Cloud account
* SSH Private Key to access the host via SSH



## More Information on Oracle Fleet Patching & Provisioning

* [FPP documentation](https://docs.oracle.com/en/database/oracle/oracle-database/19/fppad/fleet-patching-provisioning.html)
* [FPP website](https://www.oracle.com/database/technologies/rac/fpp.html)

## Acknowledgements

- **Author** - Ludovico Caldara
- **Contributors** - Kamryn Vinson
- **Last Updated By/Date** -  Ludovico Caldara, April 2021


