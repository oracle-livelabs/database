# Introduction

## About this Workshop

In this workshop you will learn how to create and modify a NoSQL table in Oracle Cloud Infrastructure (OCI) using Terraform. You will learn the steps to create both a singleton table and a Global Active table using Terraform. You will also learn how to modify or update both a singleton table and a Global Active table using Terraform.

This lab walks you through the steps to create and modify tables in Oracle NoSQL database cloud service using Terraform.

Estimated Lab Time: 40 Minutes

### About NoSQL Database

Modern application developers have many choices when faced with deciding when and how to persist a piece of data. In recent years, NoSQL databases have become increasingly popular and are now seen as one of the necessary tools in the toolbox that every application developer must have at their disposal. Many of the more recent applications have been designed to personalize the user experience to the individual, ingest huge volumes of machine generated data, deliver blazingly fast, crisp user interface experiences, and deliver these experiences to large populations of concurrent users. In addition, these applications must always be operational, with zero down-time, and with zero tolerance for failure. The approach taken by Oracle NoSQL Database is to provide extreme availability and exceptionally predictable, single digit millisecond response times to simple queries at scale. Largely, this is due to Oracle NoSQL Database’s shared nothing, replicated, horizontal scale-out architecture and by using the Oracle NoSQL Database Cloud Service, Oracle manages the scale out, monitoring, tuning, and hardware/software maintenance, all while providing your application with predictable behavior.

### About Terraform
Terraform is an infrastructure as code (IaC) software tool that allows DevOps teams to automate infrastructure provisioning using reusable, shareable, human-readable configuration files. Terraform uses providers to interface between the Terraform engine and the supported cloud platform. The Oracle Cloud Infrastructure (OCI) Terraform provider is a component that connects Terraform to the OCI services that you want to manage.

### Objectives

In this workshop you will:
* Create an API Signing Key
* Create a singleton table with provisioned reads/sec, writes/sec, and GB storage using Terraform
* Create a Global Active table with provisioned reads/sec, writes/sec, and GB storage using Terraform
* Update a singleton table using Terraform
* Modify a Global Active table using Terraform

*Note: If you have a **Free Trial** account, when your Free Trial expires your account will be converted to an **Always Free** account. You will not be able to conduct Free Tier workshops unless the Always Free environment is available. **[Click here for the Free Tier FAQ page.](https://www.oracle.com/cloud/free/faq.html)***

### Prerequisites

* An Oracle Free Tier, Always Free, Paid or LiveLabs Cloud Account.
* Basic understanding of Terraform. Read the brief introduction [here](https://developer.hashicorp.com/terraform/intro).
* OCI Terraform provider [installed](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraforminstallation.htm).

## Task 1: Getting started with using Terraform to provision and manage tables
The Oracle NoSQL Database Cloud Service is a server-less, fully managed data store that delivers predictable single digit response times and allows application to scale on demand via provisioning API calls. There are simple steps to provision or manage singleton and Global Active tables in the Oracle NoSQL Database Cloud Service using Terraform.

1. Create OCI Terraform provider configuration
2. Create NoSQL Terraform configuration file
3. Connect to the Oracle NoSQL Database Cloud Service
4. Invoke terraform and run the scripts

You may proceed to the next lab.

## Learn More

* [About Oracle NoSQL Database Cloud Service](https://docs.oracle.com/en/cloud/paas/nosql-cloud/dtddt/index.html)
* [Learn more on Terraform](https://www.terraform.io/)

## Acknowledgements
* **Author** - Vandana Rajamani, Consulting UA Developer, DB Cloud Technical Svcs & User Assistance
* **Last Updated By/Date** - Ramya Umesh, Principal UA Developer, DB OnPrem Tech Svcs & User Assistance, March 2025
