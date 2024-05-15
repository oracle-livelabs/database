# Create singleton tables using Terraform

## Introduction

This lab walks you through the steps to create a singleton table using Terraform.

Estimated Lab Time: 20 Minutes

### About Oracle NoSQL Database Cloud Service

Oracle NoSQL Database Cloud Service is a fully managed database cloud service that handles large amounts of data at high velocity. It’s easy to deploy NDCS tables on Oracle Cloud Infrastructure (OCI) using Terraform.

### Prerequisites

*  An Oracle Free Tier, Always Free, Paid or LiveLabs Cloud Account
*  Successful completion of [Lab 1 : Create an API Signing Key ](?lab=create-api-signing-keys)

To create resources in OCI, you need to configure terraform. You need to create the basic terraform configuration files for terraform provider definition, NoSQL resource definitions, authentication, and input variables.

## **Step 1:**  Create OCI Terraform provider configuration
You will create a new file named **provider.tf** that contains the OCI Terraform provider definition, and also associated variable definitions. The OCI Terraform provider requires ONLY the region argument. However, you might have to configure additional arguments with authentication credentials for an OCI account based on the authentication method.

The region argument specifies the geographical region in which your provider resources are created. To target multiple regions in a single configuration, you simply create a provider definition for each region and then differentiate by using a provider alias, as shown in the following example. Notice that only one provider, named **oci** is defined, and yet the oci provider definition is entered twice, once for the us-phoenix-1 region (with the alias "phx"), and once for the region us-ashburn-1 (with the alias "iad").
```
<copy>
provider "oci" {
region = "us-phoenix-1"
alias = "phx"
}
provider "oci" {
region = "us-ashburn-1"
alias = "iad"
}
</copy>
```
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

In the example below, a region argument is required for the OCI Terraform provider, and an auth argument is required for Instance Principal Authorization.
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
In the example below, a region argument is required for the OCI Terraform provider. The auth and config\_file_profile arguments are required for Security Token authentication.
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
You create a file named **nosql.tf** that contains the NoSQL terraform configuration resources for creating NoSQL Database Cloud Service tables or indexes.
In the example below, you are creating 2 NoSQL tables. The argument compartment_ocid is required for NoSQL Database resources such as tables and indexes. The value for this variable will be provided in [Step 3: Loading Terraform Configuration Variables ](#Step3:LoadingTerraformConfigurationVariables).
```
<copy>
variable "compartment_ocid" {
}

resource "oci_nosql_table" "nosql_demo" {
    compartment_id = var.compartment_ocid
    ddl_statement = "CREATE TABLE if not exists demo (ticketNo INTEGER, fullName STRING,
                                                      contactPhone STRING, confNo STRING,
                                                      gender STRING, bagInfo JSON, PRIMARY KEY (ticketNo))"
    name = "demo"
    table_limits {
        max_read_units = var.table_table_limits_max_read_units
        max_storage_in_gbs = var.table_table_limits_max_storage_in_gbs
        max_write_units = var.table_table_limits_max_write_units
    }
}

resource "oci_nosql_table" "nosql_demoKeyVal" {

    compartment_id = var.compartment_ocid
    ddl_statement = "CREATE TABLE if not exists demoKeyVal (key INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1 NO CYCLE),
    value JSON, PRIMARY KEY (key))"
    name = "demoKeyVal"
    table_limits {
       max_read_units = var.table_table_limits_max_read_units
       max_storage_in_gbs = var.table_table_limits_max_storage_in_gbs
       max_write_units = var.table_table_limits_max_write_units
    }
}
</copy>
```
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
## **Step 4:**  Declaring Input Variables

You will create **variables.tf** and assign values to input variables in the file. Click [here](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/nosql_table) to refer to Terraform documentation to check for the valid arguments or properties available for NoSQL Database. In the example, the default value of the read, write, and storage units for NoSQL table are set to 10, 10, and 1 respectively.
```
<copy>
variable "table_table_limits_max_read_units" {
default = 10
}
variable "table_table_limits_max_write_units" {
default = 10
}
variable "table_table_limits_max_storage_in_gbs" {
default = 1
}
</copy>
```
## **Step 5:**  Use terraform to run the scripts

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
On confirmation, both the singleton tables are created.

## Learn More

* [About Oracle NoSQL Database Cloud Service](https://docs.oracle.com/en/cloud/paas/nosql-cloud/dtddt/index.html)
* [Oracle NoSQL Database Cloud Service page](https://cloud.oracle.com/en_US/nosql)
* [Learn more on Terraform](https://www.terraform.io/)

## Acknowledgements
* **Author** - Vandana Rajamani, Consulting UA Developer, DB Cloud Technical Svcs & User Assistance
* **Last Updated By/Date** - Vandana Rajamani, Consulting UA Developer, DB Cloud Technical Svcs & User Assistance, May 2024
