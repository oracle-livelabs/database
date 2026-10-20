# Import the Prepared PeakGear Application

## Introduction

In this lab, you will download the prepared PeakGear application package, extract its application workbook, and import the workbook into Essbase. You will then check the import job, cube outline, and a known sales value.

Estimated Time: 20 minutes

### About Application Workbooks

An Essbase application workbook is an Excel file that defines an application, cube, dimensions, and optional data. Importing the prepared PeakGear workbook creates the cube and loads its data without requiring you to build the outline manually.

### Objectives

In this lab, you will:

- Download and extract the PeakGear application package.
- Import the application workbook and load its data.
- Verify the import job, cube outline, and a known sales value.

### Prerequisites

This lab assumes you have:

- Access to embedded Essbase with the Essbase user credentials.
- Essbase Power User permissions for application upload.

## Task 1: Import the Application and Load Data

1. Download and extract the [PeakGear Sporting Goods Data](files/peakgear-sales.zip) on your computer. This will be uploaded to Essbase to build the Sales Cube.

2. Log in to Essbase as the **Workshop** user created in Lab 2.
![Essbase sign-in form with ESSBASEUSER entered as the user name](images/essbase1.png)
    > **Note:** If the Workshop user cannot sign-in to Essbase, return to Data Actions as the ADMIN user and refer to Lab 2 Task 3.

3. On the Essbase home page select **Import**.
![Essbase Applications page with Import button highlighted](images/ess2.png)

4. Select **File Browser**.
![Essbase Import dialog with File Browser button highlighted](images/temp5.png)

5. Select `peakgear_sales.xlsx` from the extracted package and select `Open`. Do not select the ZIP file.
![File picker with peakgear_sales.xlsx selected and Open button highlighted](images/import2.png)
    > **Note:** Confirm the file name does not contain a space such as `peakgear_sales 2.xlsx`. If it does, right-click on the file and rename it.

6. Confirm that the application name is `peakgear_sales` and the cube name is `Sales`, then select **OK**.
![Essbase Import dialog showing peakgear_sales application, Sales database, and OK button](images/import.png)

7. Confirm that one new application, `peakgear_sales`, appears on the Applications page.
![Applications page showing the new peakgear_sales application with Live status](images/import3.png)

## Task 2: Review the Import Job

1. Open **Jobs** in Essbase and find the most recent import job for the PeakGear application. Open the job details and confirm that the job completed successfully.
![Essbase Jobs page with PeakGear job Details action highlighted](images/importtemp.png)
![PeakGear job details with Completed result highlighted](images/import6.png)

2. If the job reports an error, review its details before continuing.

## Task 3: Inspect the Cube Outline

1. On the Essbase Applications page, open `peakgear_sales`.
![Essbase Applications page with peakgear_sales application highlighted](images/import7.png)

2. Under **Database** click the three dots next to **Sales** then **Outline**.
![PeakGear Sales cube menu with Outline option highlighted](images/cube1.png)

3. Expand the `Time`, `Store`, `Product`, and `Measures` dimensions. Confirm that the outline includes years, quarters, months, cities, stores, product categories, SKUs, and the `Units` and `Sales` measures.
![Sales cube outline with Measures, Time, Store, and Product dimensions expanded](images/cube2.png)

## Task 4: Verify a Known Sales Value

1. Go back to the Home Page and open the `peakgear_sales` application again.
![Essbase Applications page with peakgear_sales application highlighted](images/import7.png)

2. Under **Database** click the **Analyze Data** button to the right of **Sales**.
![PeakGear Sales cube page with Analyze Data icon highlighted](images/cube3.png)

3. In **Ad Hoc Analysis**, select a member and click **Zoom In** in the upper-left toolbar. Repeat along each path:

   - `Time` → `FY2021` → `2021-Q1` → `2021-01`
   - `Product` → `ACTIVEWEAR` → `SKU-100002`
   - `Store` → `Austin` → `Store_004`
   - `Measures` → `Sales`

> **Note:** Alternatively, go directly to the same POV by renaming each dimension to the last value in its path: Time = 2021-01, Product = SKU-100002, Store = Store_004, and Measures = Sales.

4. Select each final member and click **Keep Only**. Confirm the resulting sales value is **1,448.55**.
![Ad hoc analysis grid showing Sales of 1,448.55 for Store_004, 2021-01, and SKU-100002](images/cube5.png)

You have imported the prepared PeakGear sales cube and verified its outline and data.

You may now **proceed to the next lab**.

## Learn More

- [Create and Update a Cube from Tabular Data](https://docs.oracle.com/en/database/other-databases/essbase/21/esscd/create-and-update-cube-tabular-data.html)
- [Analyze Data in the Web Interface](https://docs.oracle.com/en/database/other-databases/essbase/26/ugess/analyze-data-web-interface.html)

## Acknowledgements

* **Author** - Ty Wolber, Cloud Engineer
* **Last Updated By/Date** - Ty Wolber, October 2026
