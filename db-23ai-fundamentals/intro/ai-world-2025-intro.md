# Introduction to Oracle AI Database 26ai: Hands-On Lab Session

Welcome to the Oracle AI World hands-on lab session featuring Oracle AI Database 26ai! In this interactive workshop, we'll explore how Oracle AI Database 26ai's features solve real-world challenges through the lens of **LumenCare**, a fictitious healthcare technology company modernizing their application and  data management infrastructure, along with other mock scenarios.

<!-- [](youtube:MPOYjrGhvZk) -->
![Oracle AI Database 26ai Overview](./images/image.png =50%x*)



## What is Oracle AI Database and what is 26ai 

### About Oracle AI Database 26ai

Oracle AI Database 26ai is the current long term support release version of the database. This means that it is the suggested version for all enterprise workloads by Oracle Corporation. Oracle AI Database 26ai combines all the features developed over the past 45 years, building upon the foundation of version 19c and incorporating innovations from release 21c.




The Oracle AI Database is what is called a 'converged' database. This means the database supports multiple different data types like Relational, JSON, XML, Graph, Vector, and more. Converged also means it has the ability to run all sorts of workloads, from Transactional to IoT to Analytical to Machine Learning and more. All of this functionality can be used right 'out of the box'. All while still benefiting from Oracle's leading performance, security, scalability and availability.

Oracle AI Database was built on 3 key themes:
* AI for Data
* Dev for Data
* Mission Critical for Data

### AI for Data
AI for Data brings in a new era for the Oracle AI Database. The goal of AI in the database is to help developers add AI functionality to all their applications in the easiest way possible, as well as adding GenAI capabilities to all of our products to help improve the productivity of developers, DBAs, and data analysts. AI Vector Search is part of Oracle AI Database 26ai and is available at no additional cost in Enterprise Edition, Standard Edition 2, Database Free, and all Oracle AI Database Cloud services.

### Dev for Data
Dev for Data in Oracle AI Database 26ai makes it easier than ever to develop using the Oracle AI Database. Oracle now offers multiple free versions of the database (built on the same code as the paid version) like Oracle AI Database Free, Oracle Free Autonomous Database on the cloud, and Oracle Free Autonomous Database on-premises. In addition, new features like JSON-Relational Duality Views allow you to build your applications using BOTH relational and JSON in the same app. Property Graphs allow you to build and model relations (like those found in the real world) in a new and simple way through the database's built-in support for property graph views and the ability to query them using the new SQL/PGQ standard.

### Mission Critical for Data
Oracle AI Database focuses on providing the highest availability for companies and some of the world's most important systems. From functionality like Oracle Real Applications Clusters to Oracle Active DataGuard and much more, the Oracle AI Database allows you to safeguard your critical systems against unforeseen downtime.



## Setting the Stage: LumenCare demo 

This hands-on workshop provides an opportunity to work with Oracle AI Database 26ai's new features through realistic healthcare scenarios. Each session includes practical demonstrations and hands-on activities that you can apply to your own use cases.

### Fictitious Company Background

**LumenCare** is a new fictitious platform for a major US healthcare provider, specializing in patient data management and clinical analytics. With over 150 healthcare providers as clients across North America, LumenCare processes millions of patient records, medical imaging data, clinical notes, doctor-patient messaging and research documents daily.

The application serves as a comprehensive healthcare data platform that helps doctors and clinics store and analyze patient medical records, process unstructured clinical notes, provide intelligent search across medical literature, and ensure HIPAA compliance.

### The Challenge

LumenCare faces several critical challenges with their existing database infrastructure:

1. **Limited Search Capabilities**: Healthcare professionals struggle to find relevant information across vast amounts of unstructured medical data
2. **Data Model Complexity**: Managing both structured patient data and unstructured clinical documents requires complex data transformations
3. **Lack of Data Governance**: No strong data governance strategy to help manage the existing onboarding of clinics across the country.

### The Oracle 26ai Solution

In this hands-on workshop, we'll explore how Oracle AI Database 26ai's features address these challenges:

#### 1. Data Use Case Domains & Schema Annotations
Data Use Case Domains and Schema Annotations - Enhancing Business Data Usage (15 minutes)
We'll demonstrate how LumenCare is creating new database level Annotations to improve their understanding of data and enhance their applications with Data Use Case Domains.

#### 2. Converged Capabilities - JSON and SQL in the database (10 minutes)
Use the new JSON data type and syntax for building with JSON in the Oracle AI Database alongside relational data. Use the data you need, how you need it, when you need it. 

#### 3. AI Vector Search - Intelligent Medical Document Search (20 minutes)
Experience semantic search that understands medical terminology and returns contextually relevant results through natural language queries.

#### 4. JSON Relational Duality Views - Simplifying Healthcare Data (15 minutes)
See how LumenCare manages complex healthcare data using both relational and document models seamlessly. Patient data stored in normalized tables can be accessed as JSON documents, with automatic synchronization across different application interfaces.

#### 5. BONUS - New 26ai SQL Enhancements (10 minutes)
See new SQL Enhancements in the database.

#### 6. BONUS - SQLcl MCP Server and the Oracle AI Database (20 minutes)
See the new MCP tool that allows AI agents and LLMs to interact with the database



## Learn More

* [Announcing Oracle AI Database 26ai : General Availability](https://blogs.oracle.com/database/post/oracle-26ai-now-generally-available) 
* [Oracle AI Database Features and Licensing](https://apex.oracle.com/database-features/)
* [Oracle AI Database 26ai : Where to find information](https://blogs.oracle.com/database/post/oracle-database-26ai-where-to-find-more-information)
* [Free sandbox to practice with 26ai!](https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=3943)

## Acknowledgements
* **Author** - Killian Lynch, Database Product Management
* **Contributors** - Dom Giles, Distinguished Database Product Manager
* **Last Updated By/Date** - Killian Lynch, September 2025