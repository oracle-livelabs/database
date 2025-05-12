# Create Global Active tables using Terraform

## Introduction

This lab walks you through the steps to create a Global Active table (GAT) using Terraform.

Estimated Lab Time: 15 Minutes

### About Global Active tables

Oracle NoSQL Database Cloud Service supports a global active table architecture in which you can create tables, replicate them across multiple regions, and maintain synchronized data across the regional replicas. Today's businesses need to provide faster and better services to their customers. Network latency is a crucial parameter for assessing the performance of any application. Users expect to complete their online activities smoothly and quickly from anywhere. To meet such expectations, enterprises need to host applications and data in distributed regions closest to their users. Oracle NoSQL Database Cloud Service provides a solution to these requirements through Global Active tables. This feature enables application data written in a region to be replicated transparently across multiple regions.

### Prerequisites

*  An Oracle Free Tier, Always Free, Paid or LiveLabs Cloud Account
*  Successful completion of [Lab 1 : Create an API Sign-In Key ](?lab=create-api-signing-keys)
* Successful completion of [Lab 2 : Create singleton tables using Terraform](?lab=create-singleton-tables)

It is easy to deploy a Global Active table on OCI using Terraform. In [Lab 2 : Create singleton tables using Terraform](?lab=create-singleton-tables), you have created a singleton table called **nosql_demo**. In this lab, you will create a regional replica of this table and make it a Global Active table.

## Task 1:  Create NoSQL Terraform configuration file
Resources are the most important element in the Terraform language. Terraform creates a NoSQL table and a table replica as a resource. The NoSQL Terraform configuration file will define the resources to be created. In this lab the resources created are a NoSQL table and a table replica.

When you create a Global Active table:
* The table should contain at least one JSON column.
* The table DDL definition must include **with schema frozen** clause.

When you add a regional table replica, you can either specify the name of the table or the OCID of the table. If you specify the name of the table, then you need to specify the OCID of your compartment and the **depends\_on** clause while defining the regional replica. If you are specifying the OCID of the table as shown below, then **depends_on** clause, and compartment OCID are optional.

You create a new file named **nosql.tf** that contains the NoSQL terraform configuration resources for creating NoSQL Database Cloud Service tables.
In the example below, you are creating a table **nosql_demo** with a json column and schema frozen. You then add a regional replica to the table and make it a Global Active table.

```
<copy>
variable "compartment_ocid" {
}

variable "table_ddl_statement" {
  default = "CREATE TABLE IF NOT EXISTS nosql_demo(id INTEGER, name STRING, info JSON,PRIMARY KEY(id)) with schema frozen"
}

resource "oci_nosql_table" "nosql_demo" {
  #Required
  compartment_id = var.compartment_ocid
  ddl_statement  = var.table_ddl_statement
  name           = "nosql_demo"

  table_limits {
    #Required
    max_read_units = 51
    max_write_units = 51
    max_storage_in_gbs = 2     
  }
}
#add a regional replica
resource "oci_nosql_table_replica" "replica_montreal" {
  table_name_or_id = oci_nosql_table.nosql_demo.id
  region = "ca-montreal-1"
  #Optional
  max_read_units     = "60"
  max_write_units    = "60"
}

# Retain the CREATE TABLE definition for nosql_demoKeyVal table to avoid table deletion 
resource "oci_nosql_table" "nosql_demoKeyVal" {

    compartment_id = var.compartment_ocid
    ddl_statement = "CREATE TABLE if not exists nosql_demoKeyVal (key INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1 NO CYCLE), value JSON, name STRING, PRIMARY KEY (key))"
    name = "nosql_demoKeyVal"
    table_limits {
       max_read_units = var.table_table_limits_max_read_units
       max_storage_in_gbs = var.table_table_limits_max_storage_in_gbs
       max_write_units = var.table_table_limits_max_write_units
    }
}

</copy>
```
*Note: The definition of the singleton table (CREATE TABLE IF NOT EXISTS nosql\_demo...) must always be included in the terraform script even if the table (nosql\_demo) already exists. If the table already exists, Terraform compares the existing definition of the table to the new definition in the script. If there are no changes, the CREATE TABLE definition is ignored. If there are any changes to the definition, the terraform script overwrites the existing definition of the table with the new script (This is equivalent to an ALTER TABLE statement).If you do not include the CREATE TABLE definition in the script and terraform sees the table existing, then terraform drops the table from the  existing region.*

## Task 2:  Use terraform to run the scripts

Save the config file created above in the same folder where Terraform is installed.
Invoke terraform and initialize the setup.
```
<copy>
terraform init
</copy>
```
Run the following command to invoke the terraform script.
```
<copy>
terraform apply
</copy>
```
Terraform shows the plan to be applied and prompts for confirmation as shown below.
```
<copy>
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols: + create

Terraform will perform the following actions:
# oci_nosql_table.nosql_demo will be created

 + resource "oci_nosql_table" "nosql_demo" {
     + compartment_id                          = "<COMPARTMENT_ID>"
     + ddl_statement                           = "CREATE TABLE IF NOT EXISTS nosql_demo(id INTEGER, name STRING, info JSON, PRIMARY KEY(id)) with schema frozen"
     + defined_tags                            = (known after apply)
     + freeform_tags                           = (known after apply)
     + id                                      = (known after apply)
     + is_auto_reclaimable                     = (known after apply)
     + is_multi_region                         = (known after apply)
     + lifecycle_details                       = (known after apply)
     + local_replica_initialization_in_percent = (known after apply)
     + name                                    = "nosql_demo"
     + replicas                                = (known after apply)
     + schema                                  = (known after apply)
     + schema_state                            = (known after apply)
     + state                                   = (known after apply)
     + system_tags                             = (known after apply)
     + time_created                            = (known after apply)
     + time_of_expiration                      = (known after apply)
     + time_updated                            = (known after apply)

     + table_limits {
         + capacity_mode      = (known after apply)
         + max_read_units     = 60
         + max_storage_in_gbs = 1
         + max_write_units    = 60
      }
   }

 # oci_nosql_table_replica.replica_yul will be created
 + resource "oci_nosql_table_replica" "replica_yul" {
     + compartment_id   = (known after apply)
     + id               = (known after apply)
     + max_read_units   = (known after apply)
     + max_write_units  = (known after apply)
     + region           = "ca-montreal-1"
     + table_name_or_id = (known after apply)
   }

Do you want to perform these actions?
Terraform will perform the actions described above.
Only 'yes' will be accepted to approve.
<copy>
```
On confirmation, a regional replica of the *nosql_demo* table is created, converting the singleton table to a GAT.

You may proceed to the next lab.

## Learn More

* [Global Active Tables in NDCS](https://docs.oracle.com/en/cloud/paas/nosql-cloud/gasnd/)
* [Table Replica Resource in Terraform](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/nosql_table_replica)

## Acknowledgements
* **Author** - Vandana Rajamani, Consulting UA Developer, DB Cloud Technical Svcs & User Assistance
* **Last Updated By/Date** - Ramya Umesh, Principal UA Developer, DB OnPrem Tech Svcs & User Assistance, March 2025
