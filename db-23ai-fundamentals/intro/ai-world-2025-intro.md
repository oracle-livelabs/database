# Introduction to Oracle Database 23ai: Hands-On Lab Session

Welcome to the Oracle AI World hands-on lab session featuring Oracle Database 23ai! In this interactive workshop, we'll explore how Oracle Database 23ai's revolutionary features solve real-world challenges through the lens of **LumenCare**, a healthcare technology company modernizing their application and  data management infrastructure.

[](youtube:MPOYjrGhvZk)

## About Oracle Database 23ai

Oracle Database 23ai is the current long term support release version of the database. This means that it is the suggested version for all enterprise workloads by Oracle Corporation. Oracle Database 23ai combines all the features developed over the past 45 years, building upon the foundation of version 19c and incorporating innovations from release 21c.

The Oracle Database is what is called a 'converged' database. This means the database supports multiple different data types like Relational, JSON, XML, Graph, Vector, and more. Converged also means it has the ability to run all sorts of workloads, from Transactional to IoT to Analytical to Machine Learning and more. All of this functionality can be used right 'out of the box'. All while still benefiting from Oracle's leading performance, security, scalability and availability.

Oracle Database was built on 3 key themes:
* AI for Data
* Dev for Data
* Mission Critical for Data

### AI for Data
AI for Data brings in a new era for the Oracle Database. The goal of AI in the database is to help developers add AI functionality to all their applications in the easiest way possible, as well as adding GenAI capabilities to all of our products to help improve the productivity of developers, DBAs, and data analysts. AI Vector Search is part of Oracle Database 23ai and is available at no additional cost in Enterprise Edition, Standard Edition 2, Database Free, and all Oracle Database Cloud services.

### Dev for Data
Dev for Data in Oracle Database 23ai makes it easier than ever to develop using the Oracle Database. Oracle now offers multiple free versions of the database (built on the same code as the paid version) like Oracle Database Free, Oracle Free Autonomous Database on the cloud, and Oracle Free Autonomous Database on-premises. In addition, new features like JSON-Relational Duality Views allow you to build your applications using BOTH relational and JSON in the same app. Property Graphs allow you to build and model relations (like those found in the real world) in a new and simple way through the database's built-in support for property graph views and the ability to query them using the new SQL/PGQ standard.

### Mission Critical for Data
Oracle Database focuses on providing the highest availability for companies and some of the [world's most important systems](https://www.oracle.com/docs/tech/database/con8821-nyse.pdf). From functionality like Oracle Real Applications Clusters to Oracle Active DataGuard and much more, the Oracle Database allows you to safeguard your critical systems against unforeseen downtime.

## Today's Workshop: LumenCare Analytics Case Study

**Duration**: 85 minutes  
**Audience**: Database administrators, IT professionals, application developers  
**Prerequisites**: Basic SQL knowledge

### Company Background

**LumenCare** is a rapidly growing fictitious healthcare technology company founded in 2019, specializing in patient data management and clinical analytics. With over 150 healthcare providers as clients across North America, LumenCare processes millions of patient records, medical imaging data, clinical notes, doctor-patient messaging and research documents daily.

Their application, **MedInsight**, serves as a comprehensive healthcare data platform that helps doctors and clinics store and analyze patient medical records, process unstructured clinical notes, provide intelligent search across medical literature, and ensure HIPAA compliance.

### The Challenge

LumenCare faces several critical challenges with their existing database infrastructure:

1. **Security Vulnerabilities**: Recent SQL injection attempts have exposed weaknesses in their data protection
2. **Limited Search Capabilities**: Healthcare professionals struggle to find relevant information across vast amounts of unstructured medical data
3. **Data Model Complexity**: Managing both structured patient data and unstructured clinical documents requires complex data transformations
4. **Scalability Issues**: Growing data volumes are impacting query performance and system reliability

### The Oracle 23ai Solution

In this hands-on workshop, we'll explore how Oracle Database 23ai's features address these challenges:

#### 1. Schema Annotations



SQL Firewall - Protecting Patient Data (15 minutes)
Real-time protection against SQL injection attacks while maintaining zero impact on legitimate applications. We'll demonstrate how LumenCare protects sensitive medical data and maintains HIPAA compliance through automated threat detection and audit trails.

#### 2. AI Vector Search - Intelligent Medical Document Search (20 minutes)
Transform how healthcare professionals find information across thousands of medical research papers and clinical guidelines. Experience semantic search that understands medical terminology and returns contextually relevant results through natural language queries.

#### 3. JSON Relational Duality Views - Simplifying Healthcare Data (15 minutes)
See how LumenCare manages complex healthcare data using both relational and document models seamlessly. Patient data stored in normalized tables can be accessed as JSON documents, with automatic synchronization across different application interfaces.

#### 4. Property Graphs - Healthcare Relationship Analytics (15 minutes)
Analyze complex relationships between patients, healthcare providers, treatments, and medical conditions. Discover how SQL/PGQ queries help identify care patterns, potential drug interactions, and optimal referral paths across healthcare networks.

#### 6. Integration Showcase - Unified Healthcare Platform (10 minutes)
See how all features work together to create a comprehensive solution that delivers measurable business value across all healthcare operations.

### Real-World Results

LumenCare's implementation of Oracle Database 23ai delivered impressive outcomes:
- **Security Incidents**: Reduced from 12/month to 0
- **Query Response Time**: Improved by 60% for complex searches
- **Development Velocity**: Increased by 45% for new features
- **Care Coordination Efficiency**: Improved by 40% through relationship analytics
- **Compliance Audit Time**: Reduced by 60% with automated documentation
- **User Satisfaction**: 92% of healthcare professionals report improved productivity

## Workshop Structure

This hands-on workshop provides an opportunity to work with Oracle Database 23ai's new features through realistic healthcare scenarios. Each session includes practical demonstrations and hands-on activities that you can apply to your own use cases.

## Learn More

* [Announcing Oracle Database 23ai : General Availability](https://blogs.oracle.com/database/post/oracle-23ai-now-generally-available) 
* [Oracle Database Features and Licensing](https://apex.oracle.com/database-features/)
* [Oracle Database 23ai : Where to find information](https://blogs.oracle.com/database/post/oracle-database-23ai-where-to-find-more-information)
* [Free sandbox to practice with 23ai!](https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=3943)

## Acknowledgements
* **Author** - Killian Lynch, Database Product Management
* **Contributors** - Dom Giles, Distinguished Database Product Manager
* **Last Updated By/Date** - Killian Lynch, August 2025