# Create Global Active tables using Terraform

## Introduction

This lab walks you through the steps to create a Global Active table (GAT) using Terraform.

Estimated Lab Time: 20 Minutes

### About Global Active tables

Oracle NoSQL Database Cloud Service supports a global active table architecture in which you can create tables, replicate them across multiple regions, and maintain synchronized data across the regional replicas. Today's businesses need to provide faster and better services to their customers. Network latency is a crucial parameter for assessing the performance of any application. Users expect to complete their online activities smoothly and quickly from anywhere. To meet such expectations, enterprises need to host applications and data in distributed regions closest to their users. Oracle NoSQL Database Cloud Service provides a solution to these requirements through Global Active tables. This feature enables application data written in a region to be replicated transparently across multiple regions.

### Prerequisites

*  An Oracle Free Tier, Always Free, Paid or LiveLabs Cloud Account
*  Successful completion of [Lab 1 : Create an API Signing Key ](?lab=create-api-signing-keys)

To create resources in OCI, you need to configure terraform. You need to create the basic terraform configuration files for terraform provider definition, NoSQL resource definitions, authentication, and input variables.

## **Step 1:**  Create OCI Terraform provider configuration
You will create a file named **provider.tf** that contains the OCI Terraform provider definition, and also associated variable definitions. The OCI Terraform provider requires ONLY the region argument. However, you might have to configure additional arguments with authentication credentials for an OCI account based on the authentication method.

The OCI Terraform provider supports the following authentication methods:
* API Key Authentication
* Instance Principal Authorization
* Resource Principal Authorization
* Security Token Authentication

**Option 1: API Key Authentication**

Here you use an OCI user and an API key for authentication. The credentials that are used for connecting your application are associated with a specific user.
For API Key authentication, you need the following arguments
* tenancy_ocid
* user_ocid
* private_key\_path
* fingerprint
```
<copy>
variable "tenancy_ocid" {
}
variable "user_ocid" {
}
variable "fingerprint" {
}
variable "private_key_path" {
}
variable "region" {
}

provider "oci" {
   region = var.region
   tenancy_ocid = var.tenancy_ocid
   user_ocid = var.user_ocid
   fingerprint = var.fingerprint
   private_key_path = var.private_key_path
}
</copy>
```
**Option 2: Instance Principal Authorization**

Instance Principals is a capability in Oracle Cloud Infrastructure Identity and Access Management (IAM) that lets you make service calls from an instance. With instance principals, you don’t need to configure user credentials for the services running on your compute instances or rotate the credentials.

Using instance principals authentication, you can authorize an instance to make API calls on Oracle Cloud Infrastructure services. After you set up the required resources and policies, an application running on an instance can call Oracle Cloud Infrastructure public services, removing the need to configure user credentials or a configuration file. Instance principal authentication can be used from an instance where you don't want to store a configuration file.

In the example below, an region argument is required for the OCI Terraform provider, and an auth argument is required for Instance Principal Authorization.
```
<copy>
variable "region" {
}
provider "oci" {
   auth = "InstancePrincipal"
   region = var.region
}
</copy>
```
**Option 3: Resource Principal Authorization**

You can use a resource principal to authenticate and access Oracle Cloud Infrastructure resources. The resource principal consists of a temporary session token and secure credentials that enable other Oracle Cloud services to authenticate themselves to Oracle NoSQL Database. Resource principal authentication is very similar to instance principal authentication, but is intended to be used for resources that are not instances, such as server-less functions.

A resource principal enables resources to be authorized to perform actions on Oracle Cloud Infrastructure services. Each resource has its own identity, and the resource authenticates using the certificates that are added to it. These certificates are automatically created, assigned to resources, and rotated, avoiding the need for you to create and manage your own credentials to access the resource. When you authenticate using a resource principal, you do not need to create and manage credentials to access Oracle Cloud Infrastructure resources.

In the example below, a region argument is required for the OCI Terraform providerand an auth argument is required for Resource Principal Authorization.
```
<copy>
variable "region" {
}

provider "oci" {
  auth = "ResourcePrincipal"
  region = var.region
}
</copy>
```
**Option 4: Security Token Authentication**

Security Token authentication allows you to run Terraform using a token generated with [Token-based Authentication for the CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/clitoken.htm#Tokenbased_Authentication_for_the_CLI).

*Note: This token expires after one hour. Avoid using this authentication method when provisioning of resources takes longer than one hour.*  
In the example below, region an argument is required for the OCI Terraform provider. The auth and config\_file_profile arguments are required for Security Token authentication.
```
<copy>
variable "region" {
}
variable "config_file_profile" {
}
provider "oci" {
auth = "SecurityToken"
config_file_profile = var.config_file_profile
region = var.region
}
</copy>
```

## **Step 2:**  Create NoSQL Terraform configuration file
Resources are the most important element in the Terraform language. Terraform creates a singleton table, an index, and a table replica as a resource. In this file, you provide the definition of NoSQL terraform configuration resources for creating a Global Active table.

When you want to create a Global Active table:
* The table should contain at least one JSON column.
* The table DDL definition must include **with schema frozen** on the singleton table.
* The table limits of the sender table (read unit, write unit, and storage capacity) must be provided.
* When you add a regional table replica, you can either specify the name of the table or the OCID of the table. If you specify the name of the table, then you need to specify the OCID of your compartment and the depends\_on clause while defining the regional replica as shown below. If you are specifying the OCID of the table, then depends_on clause, and compartment OCID is optional.

You create a new file named **nosql.tf** that contains the NoSQL terraform configuration resources for creating NoSQL Database Cloud Service tables.
In the example below, you are creating a table **mr_test** with a json column and schema frozen. You then add a regional replica to the table and make it a Global Active table.

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
#add a regional replica
resource "oci_nosql_table_replica" "replica_montreal" {
  table_name_or_id = oci_nosql_table.mr_test.id
  region = "ca-montreal-1"
  #Optional
  max_read_units     = "60"
  max_write_units    = "60"
}
</copy>
```
*Note: The definition of the singleton table (CREATE TABLE IF NOT EXISTS mr_test...) must always be included in the terraform script even if the source table already exists. Removing the CREATE TABLE definition from the terraform script drops the table from the region.*

## **Step 3:**  Loading Terraform Configuration Variables

The next step is to create a file named **terraform.tfvars** and provide values for the required OCI Terraform provider arguments based on the authentication method.

**Option 1: API Key Authentication**

Provide values for your tenancy\_ocid, user\_ocid, private_key\_path, and fingerprint, region, and compartment\_ocid arguments. You should already have an OCI IAM user with access keys having sufficient permissions on NoSQL Database Cloud Service. Use the values recorded from [Lab 1 : Create an API Signing Key ](?lab=create-api-signing-keys).
```
<copy>
tenancy_ocid = <TENANCY_OCID>
user_ocid = <USER_OCID>
fingerprint = <FINGERPRINT_VALUE>
private_key_path = <PATH_PRIVATE_KEY_FILE>
compartment_ocid = <COMPARTMENT_OCID>
region = <YOUR_REGION>
</copy>
```
**Option 2: Instance Principal Authorization**

Provide values for region and compartment_ocid arguments.

```
<copy>
region = <YOUR_REGION>
compartment_ocid = <COMPARTMENT_OCID>
</copy>
```
**Option 3: Resource Principal Authorization**

Provide values for region and compartment_ocid arguments.

```
<copy>
region = <YOUR_REGION>
compartment_ocid = <COMPARTMENT_OCID>
</copy>
```
**Option 4: Security Token Authentication**

Provide values for the region, compartment\_ocid, and config\_file_profile arguments.

In the example below, region an argument is required for the OCI Terraform provider. The auth and config\_file_profile arguments are required for Security Token authentication.
```
<copy>
region = <YOUR_REGION>
compartment_ocid = <COMPARTMENT_OCID>
config_file_profile = <PROFILE_NAME>
</copy>
```

## **Step 4:**  Use terraform to run the scripts

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
Terraform shows the plan to be applied and prompts for confirmation as shown below.
```
<copy>
Do you want to perform these actions?
Terraform will perform the actions described above.
Only 'yes' will be accepted to approve.
</copy>
```
On confirmation, the singleton table is created. A regional replica of the table is then created, converting the singleton table to a GAT.

## Learn More

* [About Oracle NoSQL Database Cloud Service](https://docs.oracle.com/en/cloud/paas/nosql-cloud/dtddt/index.html)
* [Oracle NoSQL Database Cloud Service page](https://cloud.oracle.com/en_US/nosql)
* [Learn more on Terraform](https://www.terraform.io/)

## Acknowledgements
* **Author** - Vandana Rajamani, Consulting UA Developer, DB Cloud Technical Svcs & User Assistance
* **Last Updated By/Date** - Vandana Rajamani, Consulting UA Developer, DB Cloud Technical Svcs & User Assistance, May 2024
