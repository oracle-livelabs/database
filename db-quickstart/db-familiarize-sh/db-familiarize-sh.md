# Get Familiar with the SH Sample Schema using the SQL Worksheet

## Introduction

In this lab, you will connect to the database using SQL Worksheet, a browser-based tool that is easily accessible from the **Oracle Autonomous AI Lakehouse (LH)** or **Oracle Autonomous AI Transaction Processing (ATP)** consol and examine the structures and data in the Sales History (SH) sample schema that comes with the database.

Estimated lab time: 10 minutes

### Objectives

-   Learn how to connect to your new Oracle Autonomous AI Database using the SQL Worksheet
-   Familiarize with the tables and their relationships within the SH sample schema
-   Use the DESCRIBE command to examine the details of an SH table

### Prerequisites

-   This lab requires completion of the preceding labs in the **Contents** menu on the left. 

## Task 1: Connect to Oracle Autonomous AI Database with the SQL Worksheet

Although you can connect to your Oracle Autonomous AI Database from local PC desktop tools like Oracle SQL Developer, you can conveniently access the browser-based SQL Worksheet directly from your Oracle Autonomous AI Lakehouse or Oracle Autonomous AI Transaction Processing console.

1. On your Oracle Autonomous AI Database details page, click the **Database Actions** drop-down list.

    ![Click the Database Actions drop-down list](./images/click-database-actions-drop-down.png =65%x*)

2. The SQL Worksheet is displayed. The first time you access the SQL Worksheet, informational boxes might be displayed. Click the **X** icons to close those boxes. You can also click the **Collapse** icon to increase the worksheet area.

    ![The SQL Worksheet is displayed.](./images/sql-worksheet-displayed.png =65%x*)

3. You can also click the **Tour** icon on the toolbar to go through a tour of the SQL Worksheet. 

    ![Click Tour to take the tour.](./images/click-tour-to-take-tour.png =65%x*)

4. A series of informational boxes will be displayed such as the following. Click the **Run Statement** button.

    ![Tour screen 1.](./images/tour-screen-1.png =65%x*)

5. Click **Next** and follow the prompts to continue the tour.

    ![Tour screen 2.](./images/tour-screen-2.png =65%x*)

6. When the tour is completed, click the **Done** button. 

    ![Click Done.](./images/click-done.png =50%x*)

    > **Note:** Keep the SQL Worksheet open. You will use it in the next tasks and labs.

## Task 2: Examine the SH Schema Tables and Their Relationships

A database schema is a collection of metadata that describes the relationship between the data in a database. A schema can be simply described as the "layout" of a database or the blueprint that outlines how data is organized into tables.

Schema objects are database objects that contain data or that govern or perform operations on data. By definition, each schema object belongs to a specific schema. The following are commonly used schema objects:
-   **Tables**: Basic units of data storage in an Oracle database. Here, data is stored in rows and columns. You define a table with a table name and a set of columns.
-   **Indexes**: Performance-tuning methods for allowing faster retrieval of records.
-   **Views**: Representations of SQL statements that are stored in memory so that they can be reused.

The **Sales History (SH)** sample schema that comes with the Oracle Autonomous AI Database is based on a fictitious company that sells goods through various channels. The company operates worldwide to fill orders for products. It has several divisions, each of which is represented by a sample database schema. The SH schema tracks business statistics to facilitate business decisions.

This fictitious company does a high volume of business, so it runs business statistics reports to aid in decision making. Many of these reports are time-based and nonvolatile. That is, they analyze past data trends. The company loads data into its data warehouse regularly to gather statistics for these reports. These reports include annual, quarterly, monthly, and weekly sales figures by product. It also analyzes sales by geographical area. These reports are stored with the help of the Sales History (SH) schema.

Here is the entity-relationship diagram of the SH schema:

![Entity-relationship diagram of SH schema](./images/sales-history-sh-schema-er-diagram.png =65%x*)

## Task 3: Use the DESCRIBE Command to Examine the Details of an SH Table

The `DESCRIBE` command provides a description of a specified table or view. The description for tables and views contains the following information:
-   Column names
-   Whether null values are allowed (`NULL` or `NOT NULL`) for each column
-   Data type of columns, such as `DATE`, `NUMBER`, `VARCHAR2`
-   Precision of columns, such as `VARCHAR2(50)`

    **Syntax:** 

    ```
    <copy>
    DESC[RIBE] schema_name.table_name
    </copy>
    ```

    > **Note:** The first time you attempt to paste code in your SQL Worksheet, a dialog box is displayed. Click **Allow**.

    ![Click Allow.](images/click-allow.png =40%x*)

1. View the description of the `COUNTRIES` table. Copy and paste the following code into your SQL Worksheet, and then click the **Run Script (F5)** icon in the Worksheet toolbar.

    ```
    <copy>DESCRIBE SH.COUNTRIES;</copy>
    ```

    ![Click the Run Script icon.](images/describe-countries.png =65%x*)

2. You can use the `DESCRIBE` command to view descriptions of other tables in the `SH schema` such as `CHANNELS`, `CUSTOMERS`, and `SALES`.

3. To clear the worksheet area, click the **Clear** icon in the Worksheet toolbar. To clear the script output area, click the **Clear output** icon in **Script output** toolbar.

    ![Click the worksheet and Script output areas.](images/clear-and-clear-output-icons.png =65%x*)

    You may now **proceed to the next lab.**

## Want to Learn More?

* [Sample Schemas](https://docs.oracle.com/en/database/oracle/oracle-database/19/comsc/introduction-to-sample-schemas.html#GUID-844E92D8-A4C8-4522-8AF5-761D4BE99200)
* [Schema Diagrams](https://docs.oracle.com/en/database/oracle/oracle-database/19/comsc/schema-diagrams.html#GUID-D268A4DE-BA8D-428E-B47F-80519DC6EE6E)

## Acknowledgements

- **Author:** Lauran K. Serhal, Consulting User Assistance Developer
- **Last Updated By/Date:** Lauran K. Serhal, October 2025
