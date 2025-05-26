# Introduction

The labs in this workshop will walk you through all the steps to get started using Oracle Cloud Infrastructure (OCI) Database Migration (DMS). You will provision a Virtual Cloud Network (VCN), an Oracle Database 19c instance, and an Oracle Autonomous Database (ADB) instance in order to perform an **offline**  database migration using DMS.

With DMS we make it quick and easy for you to migrate databases from on-premises, Oracle or third-party cloud into Oracle databases on OCI.

Watch the video below for an overview of Oracle Database Migration.

[](youtube:i4u6HREERTk)

## About OCI Database Migration

DMS provides high performance, fully managed approach to migrating databases from on-premises, Oracle or third-party cloud into OCI-hosted databases. Migrations can be in either one of the following modes:

* **Offline**: The Migration makes a point-in-time copy of the source to the target database. Any changes to the source database during migration are not copied, requiring any applications to stay offline for the duration of the migration.
* **Online**: The Migration makes a point-in-time copy and replicates all subsequent changes from the source to the target database. This allows applications to stay online during the migration and then be switched over from source to target database.

In the current release of DMS we support Oracle databases located on-premises, in third-party clouds, or on OCI as the source and Oracle Autonomous Database serverless or dedicated as the target database. Below is a table of supported configurations;

|                  |  |     
|--------------------------|-------------------------|
| Source Databases | Oracle DB 11g, 12c, 18c, 19c, 21c,23ai: <br>on-premises, third-party cloud, OCI  |   
| Target Databases | ADB serverless and dedicated <br> Co-managed Oracle Base Database (VM, BM)<br> Exadata on Oracle Public Cloud. |
| Supported Source Environments | Oracle Cloud Infrastructure co-managed databases or on-premises environments<br>Amazon Web Services RDS Oracle Database<br> Linux-x86-64, IBM AIX<br>Oracle Solaris|        
| Migration Modes  | Direct Access to Source <br>(VPN or Fast Connect) Indirect Access to Source <br>(Agent on Source Env) |                        |  
| Initial Load <br> (Offline Migration) | Logical Migration using <br>Data Pump to Object Store <br>Data Pump using SQLnet <br>Data Pump via file storage |  |
| Replication <br> (Online Migration) | GoldenGate Integrated Service<br>GoldenGate Marketplace |

The DMS service runs as a managed cloud service separate from the user's tenancy and resources. The service operates as a multitenant service in a DMS Service Tenancy and communicates with the user's resources using Private Endpoints (PEs). PEs are managed by DMS and are transparent to the user.

![DMS topology](images/dms-simplified-topology-2.png =80%x*)

* **DMS Control Plane**: Used by DMS end user to manage Migration and Database Connection objects. The control plane is exposed through the DMS Console UI as well as the REST API.
* **DMS Data Plane**: Managed by DMS Control Plane and transparent to the user. The GGS Data Plane manages ongoing migration jobs and communicates with the user's databases and GoldenGate instance using PEs. The DMS data plane does not store any customer data, as data flows through GoldenGate and Data Pump directly within the user's tenancy.
* **Migration**: A Migration contains metadata for migrating one database. It contains information about source, target, and migration methods and is the central object for users to run migrations. After creating a migration, a user can validate the correctness of the environment and then run the migration to perform the copy of database data and schema metadata from source to target.
* **Migration Job**: A Migration Job displays the state or a given Migration execution, either for validation or migration purposes. A job consists of a number of sequential phases, users can opt to wait after a given phase for user input to resume with the following phase.
* **Database Connection**: A Database Connection represents information about a source or target database, such as connection and authentication credentials. DMS uses the OCI Vault to store credentials. A Database Connection is reusable across multiple Migrations.

Estimated Lab Time: 180 minutes -- this estimate is for the entire workshop - it is the sum of the estimates provided for each of the labs included in the workshop.


### Objectives 

In this lab, you will:
* Create SSH Keys
* Create a VCN
* Create a Vault
* Create and prepare databases
* Create an Object Storage Bucket
* Create Database Connections
* Create, Validate, and Run a Migration

### Prerequisites

* An Oracle Cloud Account - Please view this workshop's LiveLabs landing page to see which environments are supported

*Note: If you have a **Free Trial** account, when your Free Trial expires your account will be converted to an **Always Free** account. You will not be able to conduct Free Tier workshops unless the Always Free environment is available. **[Click here for the Free Tier FAQ page.](https://www.oracle.com/cloud/free/faq.html)***

You may now [proceed to the next lab](#next).

## Learn More

* [Blog - Elevate your database into the cloud using Oracle Cloud Infrastructure Database Migration](https://blogs.oracle.com/dataintegration/elevate-your-database-into-the-cloud-using-oracle-cloud-infrastructure-database-migration)
* [Overview of Oracle Cloud Infrastructure Database Migration](https://docs.oracle.com/en-us/iaas/database-migration/doc/overview-oracle-cloud-infrastructure-database-migration.html)

## Acknowledgements
* **Author** - Alex Kotopoulis, Director, Product Management
* **Contributors** -  Kiana McDaniel, Hanna Rakhsha, Killian Lynch, Solution Engineers, Austin Specialist Hub
* **Last Updated By/Date** - Jorge Martinez, May 2025
