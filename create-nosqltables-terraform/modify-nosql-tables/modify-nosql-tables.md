# Modify NoSQL tables using Terraform

## Introduction

This lab walks you through the steps to modify or update a NoSQL table using Terraform. You can modify both a singleton table and a Global Active table using Terraform.

Estimated Lab Time: 20 Minutes

### Prerequisites

* An Oracle Free Tier, Always Free, Paid or LiveLabs Cloud Account
* Successful completion of Lab 1 : Create an API Signing Key and SDK CLI Configuration File
* Successful completion of either [Lab 2 : Create singleton tables using Terraform](?lab=create-singleton-tables) or [Lab 3: Create Global Active tables using Terraform](?lab=create-gat-tables). You will use the various Terraform Configuration files created in one of these two labs.

To modify resources in OCI, you need to configure terraform. To modify a NoSQL table, you need to create the override NOSQL Terraform configuration file with the necessary changes. You can then use the same steps described in [Lab 2 : Create singleton tables using Terraform](?lab=create-singleton-tables) or in [Lab 3: Create Global Active tables using Terraform](?lab=create-gat-tables) to save the configuration files and use terraform to run the scripts.

## **Step 1:**  Create OCI Terraform provider configuration

See Step 1 in [Lab 2 : Create singleton tables using Terraform](?lab=create-singleton-tables#Step1:CreateOCITerraformproviderconfiguration) to create the Terraform provider configuration file.

## **Step 2:**  Overwrite or update the NoSQL Terraform configuration file

**Option 1: Modifying a singleton table:**

If you have a singleton table, you can update the existing schema or different capacities (read units or write units or storage capacity) using Terraform.

Create a new file named **override.tf** and provide the specific portion of the NoSQL Database table object that you want to override. For example, you may want to add or drop a column from the table or change the data type of an existing column, or change table limits (read/write and storage units).
In the below example, You are modifying the demo table. You drop an existing column, named fullName, and add a new column, named shortName.
```
<copy>
variable "compartment_ocid" {
}

resource "oci_nosql_table" "nosql_demo" {
    compartment_id = var.compartment_ocid
    ddl_statement = "CREATE TABLE if not exists demo (ticketNo INTEGER, contactPhone STRING,
    confNo STRING, gender STRING, bagInfo JSON, PRIMARY KEY (ticketNo))"
    name = "demo"   
}
resource "oci_nosql_table" "nosql_demoKeyVal" {
    compartment_id = var.compartment_ocid
    ddl_statement = "CREATE TABLE if not exists demoKeyVal (key INTEGER GENERATED ALWAYS AS IDENTITY
    (START WITH 1 INCREMENT BY 1 NO CYCLE), value JSON, shortName STRING, PRIMARY KEY (key))"
    name = "demoKeyVal"  
}
</copy>
```
When Terraform processes this file **override.tf**, internally it parses the DDL statement (CREATE TABLE statement) and compares it with the existing table definition and generates an equivalent ALTER TABLE statement, and applies it.

**Option 2: Modifying a Global Active table:**

You can add a regional replica or drop a regional replica or change the table capacity of a Global Active table.

**Add a regional replica**

In this example, the Global Active table mr_test already exists and has a regional replica in the Canada Southeast(Montreal) region. To add a regional replica of this table in another region Canada Southeast(Toronto), use the following nosql.tf file to define the regional replica.

```
<copy>
variable "compartment_ocid" {
}

variable "table_ddl_statement" {
  default = "CREATE TABLE IF NOT EXISTS mr_test(id INTEGER,
             name STRING, info JSON,PRIMARY KEY(id))
             using TTL 10 days with schema frozen"
}
resource "oci_nosql_table" "mr_test" {
  #Required
  compartment_id = var.compartment_ocid
  ddl_statement  = var.table_ddl_statement
  name           = "mr_test"
  table_limits {
    #Required
    max_read_units = 51
    max_write_units = 51
    max_storage_in_gbs = 2     
  }
}
resource "oci_nosql_table_replica" "replica_montreal" {
  table_name_or_id = oci_nosql_table.mr_test.id
  region = "ca-montreal-1"
  #Optional
  max_read_units     = "60"
  max_write_units    = "60"
}
#add a regional replica
resource "oci_nosql_table_replica" "replica_toronto" {
  compartment_id = var.compartment_ocid
  table_name_or_id = "mr_test"
  region = "ca-toronto-1"  
  depends_on = [oci_nosql_table.mr_test]
}
</copy>
```
*Note: The definitions of the singleton table (CREATE TABLE IF NOT EXISTS mr_test...) and the existing replicas must always be included in the terraform script even if the source table and replicas already exist. Removing the CREATE TABLE definition from the terraform script drops the table from the region. Similarly removing the existing replica definition from the terraform script drops the regional table replica.*

**Drop a regional replica**

In this example, the Global Active table mr_test already exists and has a replica in the region Canada Southeast(Montreal) and Canada Southeast(Toronto). To drop the replica from the Canada Southeast(Toronto) region, use the following nosql.tf file where you need to comment (or remove) the code pertaining to adding the replica in Canada Southeast(Toronto).

```
<copy>
variable "compartment_ocid" {
}

variable "table_ddl_statement" {
  default = "CREATE TABLE IF NOT EXISTS mr_test(id INTEGER,
             name STRING, info JSON,PRIMARY KEY(id))
             using TTL 10 days with schema frozen"
}
resource "oci_nosql_table" "mr_test" {
  #Required
  compartment_id = var.compartment_ocid
  ddl_statement  = var.table_ddl_statement
  name           = "mr_test"
  table_limits {
    #Required
    max_read_units = 51
    max_write_units = 51
    max_storage_in_gbs = 2     
  }
}
resource "oci_nosql_table_replica" "replica_montreal" {
  table_name_or_id = oci_nosql_table.mr_test.id
  region = "ca-montreal-1"
  #Optional
  max_read_units     = "60"
  max_write_units    = "60"
}
#resource "oci_nosql_table_replica" "replica_toronto" {
#  compartment_id = var.compartment_ocid
#  table_name_or_id = "mr_test"
#  region = "ca-toronto-1"  
#  depends_on = [oci_nosql_table.mr_test]
#}
</copy>
```
*Note: The definition of the singleton table (CREATE TABLE IF NOT EXISTS mr_test...) must always be included in the terraform script even if the source table already exists. Removing the CREATE TABLE definition from the terraform script drops the table from the region.*

**Change the table capacity of a Global Active Table**

In a Global Active table, changing the read capacity limit or write capacity limit applies only to the local region where it is changed. However, changing the storage capacity or changing the default table level TTL value applies the changes to all the regional replicas of the table.
To change the table capacity of the mr_test table, use the following nosql.tf file to change the table properties(default table TTL) and change the table limits.

```
<copy>
variable "compartment_ocid" {
}

variable "table_ddl_statement" {
  default = "CREATE TABLE IF NOT EXISTS mr_test(id INTEGER,
            name STRING, info JSON,PRIMARY KEY(id))
            using TTL 15 days with schema frozen"
}
resource "oci_nosql_table" "mr_test" {
  #Required
  compartment_id = var.compartment_ocid
  ddl_statement  = var.table_ddl_statement
  name           = "mr_test"
  table_limits {
    #Required
    max_read_units = 60
    max_write_units = 60
    max_storage_in_gbs = 2     
  }
}
resource "oci_nosql_table_replica" "replica_montreal" {
  table_name_or_id = oci_nosql_table.mr_test.id
  region = "ca-montreal-1"
}
resource "oci_nosql_table_replica" "replica_toronto" {
  compartment_id = var.compartment_ocid
  table_name_or_id = "mr_test"
  region = "ca-toronto-1"  
  depends_on = [oci_nosql_table.mr_test]
}
</copy>
```
*Note: A Global Active table has a symmetrical table definition including schema, index, TTL, and storage size in all the regional replicas. If you make a change to an index, TTL or storage size in one regional replica, it is automatically applied to all other regional replicas. So it is recommended that you manage these table definitions from one region only.*

## **Step 3:**  Loading Terraform Configuration Variables

See Step 3 in [Lab 2 : Create singleton tables using Terraform](?lab=create-singleton-tables#Step3:LoadingTerraformConfigurationVariables)

## **Step 4:**  Use terraform to run the scripts

See Step 5 in [Lab 2 : Create singleton tables using Terraform](?lab=create-singleton-tables#Step5:Useterraformtorunthescripts)
The Terraform script is run and the NoSQL table (singleton or Global Active table) is modified.

## Learn More

* [About Oracle NoSQL Database Cloud Service](https://docs.oracle.com/en/cloud/paas/nosql-cloud/dtddt/index.html)
* [Oracle NoSQL Database Cloud Service page](https://cloud.oracle.com/en_US/nosql)
* [Learn more on Terraform](https://www.terraform.io/)

## Acknowledgements
* **Author** - Vandana Rajamani, Consulting UA Developer, DB Cloud Technical Svcs & User Assistance
* **Last Updated By/Date** - Vandana Rajamani, Consulting UA Developer, DB Cloud Technical Svcs & User Assistance, May 2024
