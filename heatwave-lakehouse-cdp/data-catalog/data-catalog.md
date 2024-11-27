# Introduction

## About this Workshop

This workshop introduces you to Oracle Cloud Infrastructure Data Catalog and will give you a full tour of the service in a hands-on manner. Data Analysts, Data engineers and Data Stewards are some of the data professionals who can use Oracle Cloud Infrastructure Data Catalog and would benefit from this Live Lab.

In this Live Lab, you will create a catalog, connect to data sources like Autonomous Data Warehouse and Object Storage, harvest metadata from them and enrich the technical metadata with business context. Finally, you will see how the catalog can be used to search, discover and understand data available in the data sources.

Estimated Time: 6 hours

### What is Data Catalog?

Oracle Cloud Infrastructure Data Catalog is a fully managed, self-service data discovery and governance solution for your enterprise data. With Data Catalog, you get a single collaborative environment to manage technical, business, and operational metadata. You can collect, organize, find, access, understand, enrich, and activate this metadata.

Using the Data Catalog service, you can:

* Harvest technical metadata from a wide range of supported data sources that are accessible using public or private IPs.
* Easily add data assets by auto-discovering the data sources present in your tenancy.
* Efficiently organize large number of related files in your data lake using Logical Entities.
* Create and manage a common enterprise vocabulary with a business glossary.
* Build a hierarchy of categories, subcategories, and terms in the glossary with detailed rich text descriptions.
* Create user defined custom properties to capture information specific to each object in the catalog.
* Use AI/ML based recommendations to easily link data entities and attributes to appropriate business terms.
* Enrich the harvested technical metadata with annotations by adding free-form tags and populating custom properties.
* Find the information you need by exploring the data assets, browsing the data catalog, or using the quick search bar.
* Automate and manage harvesting jobs using schedules.
* Integrate the enterprise class capabilities of your data catalog with other applications using REST APIs and SDKs.
* Use hive-compatible meta store to process files in the data lake using Oracle Cloud Infrastructure Data Flow. [Learn more](https://docs.oracle.com/en-us/iaas/data-flow/using/hive-metastore.htm#hive-metastore-using)
* Use SQL queries in Autonomous Database to seamlessly query external tables based on files in the data lake. [Learn more](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/query-external-data-catalog.html#GUID-480FAF23-453D-4B15-BF92-8435805EB8A5)

Watch our short overview video that explains key features in Data Catalog.

[](youtube:nY7mG2u6-Ew)

### Workshop Objectives

In this workshop, you will:
* Set up the required Oracle Cloud Infrastructure resources for Live Lab and Data Catalog
* Create required users and associated IAM Policies for the Live Lab
* Harvest metadata from MYSQL HW and Object storage
* Create a business glossary and custom properties
* Enrich the harvested metadata with business context
* Search and Discover data using the catalog

### Lab Breakdown

- **Lab 0:** Prerequisites
- **Lab 1:** Create a data catalog
- **Lab 2:** Harvest metadata from MYSQL HW
- **Lab 3:** Harvest metadata from Oracle Object Storage
- **Lab 4:** Create a Business Glossary and Custom Property
- **Lab 5:** Enrich metadata
- **Lab 6:** Search and discover your data

## Learn More

* [Get Started with Data Catalog](https://docs.oracle.com/en-us/iaas/data-catalog/using/index.htm)
* [Data Catalog Overview](https://docs.oracle.com/en-us/iaas/data-catalog/using/overview.htm)
* [Autonomous Data Warehouse](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/index.html)
* [Object Storage](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm)
* [Oracle Cloud Infrastructure Identity and Access Management](https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/overview.htm)
* [Managing Groups in Oracle Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managinggroups.htm)
* [Overview of VCNs and Subnets](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingVCNs_topic-Overview_of_VCNs_and_Subnets.htm#Overview)
* [Managing Compartments in Oracle Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcompartments.htm)

You may now **proceed to the next lab**

## Acknowledgements
* **Author** - Biswanath Nanda, Principal Cloud Architect, North America Cloud Infrastructure - Engineering
* **Contributors** -  Biswanath Nanda, Principal Cloud Architect,Bhushan Arora ,Principal Cloud Architect,Sharmistha das ,Master Principal Cloud Architect,North America Cloud Infrastructure - Engineering
* **Last Updated By/Date** - Biswanath Nanda, March 2024