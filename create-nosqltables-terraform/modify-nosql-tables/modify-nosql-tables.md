# Modify NoSQL tables using Terraform

## Introduction

This lab walks you through the steps to modify or update a NoSQL table using Terraform. You can modify both singleton table and Global Active table using Terraform.

Estimated Lab Time: 15 Minutes

### Prerequisites

* An Oracle Free Tier, Always Free, Paid or LiveLabs Cloud Account
* Successful completion of [Lab 1 : Create an API Sign-In Key ](?lab=create-api-signing-keys)
* Successful completion of [Lab 2 : Create singleton tables using Terraform](?lab=create-singleton-tables)

You can modify resources in OCI using terraform. To modify a NoSQL table, you need to create an override NOSQL Terraform configuration file with the necessary changes. You can use terraform to run the new configuration files.

## Task 1:  Overwrite or update the NoSQL Terraform configuration file

**Option 1: Modifying a singleton table:**

You can use Terraform to modify the table schema of a singleton table by adding or dropping columns. You can also modify the Time-To-Live value of the table and change the table limits (read units or write units or storage capacity). 

Create a new file named **override.tf** and provide the specific portion of the NoSQL Database table object that you want to override. In the below example, you are modifying the *nosql_demoKeyVal* table. You drop an existing column, named **name**, and add a new column, named **fullName**.

```
<copy>
variable "compartment_ocid" {
}

resource "oci_nosql_table" "nosql_demoKeyVal" {

    compartment_id = var.compartment_ocid

    ddl_statement = "CREATE TABLE if not exists nosql_demoKeyVal (key INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1 NO CYCLE), value JSON, fullName STRING, PRIMARY KEY (key))"
    name = "nosql_demoKeyVal"

    table_limits {
       max_read_units = var.table_table_limits_max_read_units
       max_storage_in_gbs = var.table_table_limits_max_storage_in_gbs
       max_write_units = var.table_table_limits_max_write_units
    }
	
	  lifecycle {
        ignore_changes = [ table_limits, freeform_tags, defined_tags ]
    }

}
</copy>
```
When Terraform processes this file **override.tf**, internally it parses the DDL statement (CREATE TABLE statement) and compares it with the existing table definition and generates an equivalent ALTER TABLE statement, and applies it.

*Note: It is possible to modify a NoSQL table object outside of Terraform. For example, the table limits can be modified from the Cloud console or through Oracle NoSQL SDKs. If your current table state and terraform configuration don't match, the terraform script overwrites the existing definition. You can configure Terraform to ignore these changes by including a lifeycle block in your terraform script as shown above. In this example, you configure the Terraform to ignore changes to the table limits, if any.*

**Option 2: Modifying a Global Active table:**

You can add a regional replica or drop a regional replica or change the table capacity of a Global Active table.

**Add a regional replica**

In this example, the Global Active table *nosql_demo* already exists and has a regional replica in the Canada Southeast(Montreal) region. To add a regional replica of this table in another region Canada Southeast(Toronto), use the following *nosql.tf* file to define the regional replica.

*Note: See [Lab 3: Create Global Active tables using Terraform](?lab=create-gat-tables) for the steps to create the Global Active table nosql_demo.*

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

resource "oci_nosql_table_replica" "replica_montreal" {
  table_name_or_id = oci_nosql_table.nosql_demo.id
  region = "ca-montreal-1"
  #Optional
  max_read_units     = "60"
  max_write_units    = "60"
}

#add a regional replica
resource "oci_nosql_table_replica" "replica_toronto" {
  compartment_id = var.compartment_ocid
  table_name_or_id = "nosql_demo"
  region = "ca-toronto-1"  
  depends_on = [oci_nosql_table.nosql_demo]
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

*Note: The definitions of the GAT table (CREATE TABLE IF NOT EXISTS nosql_demo...) and the definitions of the existing replicas must always be included in the terraform script even if the table (nosql_demo) and the replica replica_montreal already exist. If the table already exists, Terraform compares the existing definition of the table to the new definition in the script. If there are no changes, the CREATE TABLE definition is ignored. If there are any changes to the definition, the terraform script overwrites the existing definition of the table with the new script (This is equivalent to an ALTER TABLE statement).This is also applicable for creating the replica resource. If you do not include the CREATE TABLE definition in the script and terraform sees the table existing, then terraform drops the table from the  existing region. Removing the CREATE TABLE definition from the terraform script drops the table from the region. Similarly removing the existing replica definition from the terraform script drops the regional table replica.*

**Drop a regional replica**

In this example, the Global Active table nosql_demo already exists and has a replica in the region Canada Southeast(Montreal) and Canada Southeast(Toronto). To drop the replica from the Canada Southeast(Toronto) region, use the following *nosql.tf* file where you need to comment (or remove) the code pertaining to adding the replica in Canada Southeast(Toronto).

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
resource "oci_nosql_table_replica" "replica_montreal" {
  table_name_or_id = oci_nosql_table.nosql_demo.id
  region = "ca-montreal-1"
  #Optional
  max_read_units     = "60"
  max_write_units    = "60"
}
#resource "oci_nosql_table_replica" "replica_toronto" {
#  compartment_id = var.compartment_ocid
#  table_name_or_id = "nosql_demo"
#  region = "ca-toronto-1"  
#  depends_on = [oci_nosql_table.nosql_demo]
#}

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
*Note: The definition of the GAT table (CREATE TABLE IF NOT EXISTS nosql_demo...) must always be included in the terraform script even if the table (nosql_demo) already exists. If the table already exists, Terraform compares the existing definition of the table to the new definition in the script. If there are no changes, the CREATE TABLE definition is ignored. If there are any changes to the definition, the terraform script overwrites the existing definition of the table with the new script (This is equivalent to an ALTER TABLE statement).If you do not include the CREATE TABLE definition in the script and terraform sees the table existing, then terraform drops the table from the  existing region.*

**Change the table limits of a Global Active Table**

In a Global Active table, changing the read capacity limit or write capacity limit applies only to the local region where it is changed. However, changing the storage capacity or changing the default table level TTL value applies the changes to all the regional replicas of the table.
To change the properties of the *nosql_demo* table, use the *nosql.tf* file to change the table properties (default table TTL) and change the table limits.

```
<copy>
variable "compartment_ocid" {
}

variable "table_ddl_statement" {
  default = "CREATE TABLE IF NOT EXISTS nosql_demo(id INTEGER, name STRING, info JSON,PRIMARY KEY(id)) using TTL 15 days with schema frozen"
}
           
resource "oci_nosql_table" "nosql_demo" {
  #Required
  compartment_id = var.compartment_ocid
  ddl_statement  = var.table_ddl_statement
  name           = "nosql_demo"
  table_limits {
    #Required
    max_read_units = 60
    max_write_units = 60
    max_storage_in_gbs = 2     
  }
}
resource "oci_nosql_table_replica" "replica_montreal" {
  table_name_or_id = oci_nosql_table.nosql_demo.id
  region = "ca-montreal-1"
}
resource "oci_nosql_table_replica" "replica_toronto" {
  compartment_id = var.compartment_ocid
  table_name_or_id = "nosql_demo"
  region = "ca-toronto-1"  
  depends_on = [oci_nosql_table.nosql_demo]
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
*Note: A Global Active table has a symmetrical table definition including schema, index, TTL, and storage size in all the regional replicas. If you make a change to an index, TTL or storage size in one regional replica, it is automatically applied to all other regional replicas. So it is recommended that you manage these table definitions from one region only.*

## Task 2:  Use terraform to run the scripts

Save the config files created above in the same folder where Terraform is installed.
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
Terraform shows the plan to be applied and prompts for confirmation. Once confirmed the scripts are run and the NoSQL table is modified.

## Learn More

* [Deploying Oracle NoSQL Table Using Terraform and OCI Resource Manager](https://docs.oracle.com/en/cloud/paas/nosql-cloud/hknsq/)
* [Global Active Tables in NDCS](https://docs.oracle.com/en/cloud/paas/nosql-cloud/gasnd/)
* [Table Resource in Terraform](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/nosql_table)
* [Table Replica Resource in Terraform](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/nosql_table_replica)

## Acknowledgements
* **Author** - Vandana Rajamani, Consulting UA Developer, DB Cloud Technical Svcs & User Assistance
* **Last Updated By/Date** - Ramya Umesh, Principal UA Developer, DB OnPrem Tech Svcs & User Assistance, March 2025
