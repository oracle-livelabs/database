# Introduction

## About this Workshop

**Community Contributed Workshop**
![Logo](images/zdc-logo.png)

**Author:** _Jim Czuprynski - Oracle ACE Director, Zero Defect Computing, Inc._

This LiveLab session focuses on a real-world environmental and climate issue: how to effectively plant trees in urban "heat islands" to mitigate increasing temperatures by creating shaded areas. [Recent environmental studies](https://docs.oracle.com/ReplaceThisLink.html) reveal that disadvantaged urban areas have disproportionally higher temperatures during summer months because so few trees exist; in fact, suburban areas of the same metropolitan geographies may experience temperatures as much as 20 F cooler when compared to their urban counterparts, simply because those areas have much denser shade tree coverage.

The database tables we will populate contain dozens of variables, including publicly-available data to plot geospatial boundaries of 25 heat islands within the City of Chicago, Illinois. We will also track the activity of three volunteer teams as they plant various tree species within those heat islands. These data will be stored in various formats within Oracle Database tables, including the native JSON datatype introduced in Oracle 21c.

We will then explore how JSON Relational Duality Views (JRDVs) introduced in Oracle Database 23ai make short work of reporting on and maintaining data within these tables without ever having to write SQL query statements or data manipulation language (DML) statements. Instead, we will use JSON to perform all required tasks, thus empowering DevOps teams to use the same language they're already using with other NoSQL implementations without the steeper learning curve required to master SQL.

Finally, we'll create a simple Oracle Spatial Suite environment and use it to quickly map out the results of our volunteer teams' tree planting efforts.

Estimated Time: 50 minutes

### Objectives

In this lab, you will learn how to:

* Connect to a Remote Desktop instance reservation.
* Create and populate database objects in SQL Developer.
* Create JSON Relational Duality Views (JRDVs) that overlay those database objects. 
* Use JSON to report against and manipulate data via JRDVs without ever writing a SQL statement.
* Visualize and analyze geospatial data with Oracle APEX Native Map Region capabilities.

### Labs

| # | Lab | Est. Time |
| --- | --- | --- |
| 1 | [Setup User](?lab=initialize-ords) | 5 min |
| 2 | [Prepare Database Objects](?lab=prepare-database-objects) | 10 min |
| 3 | [Prepare JSON Relational Duality Views (JRDVs)](?lab=prepare-jrdvs) | 5 min |
| 4 | [Explore JRDV Features](?lab=explore-jrdvs) | 25 min |
| 5 | [Visualize Geospatial Attributes](?lab=visualize-jrdvs) | 5 min |
{: title="Labs with Times"}

### Let's Get Started!

Click [here](?lab=initalize-livelabs-environment), select **Get Started** from the menu on the left, or click the arrow below to start the workshop.

## Learn More

* [Oracle SQL Developer 23.1 Concepts and Usage](https://docs.oracle.com/en/database/oracle/sql-developer/23.1/rptug/sql-developer-concepts-usage.html)
* [Oracle JSON Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/adjsn/)
* [Oracle JSON-Relational Duality Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/jsnvu/)
* [Spatial Map Visualization Developer's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/23/jimpv/)

## Acknowledgements
* **Author** - Kaylien Phan, William Masdon, Jim Czuprynski
* **Contributors** - Jim Czuprynski, LiveLabs Contributor, Zero Defect Computing, Inc.
* **Last Updated By/Date** - Jim Czuprynski, July 2023
