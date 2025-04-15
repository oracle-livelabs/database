# Provision Analytics Cloud

<!--![Banner](images/banner.png)-->

### Introduction

During this lab you will deploy an Oracle Analytics Cloud instance on Oracle Cloud Infrastructure.

_Estimated Lab Time_: 15 minutes (OAC provisioning time may vary)

### Objectives

In this lab, you will:

- Login as a federated user.
- Create an Oracle Analytics Cloud Instance.

### Prerequisites

- Oracle Free Trial Account.

##  
## Task 1: Create an Oracle Analytics Cloud (OAC) Instance

1. Return to the Home Page and go to the **Menu** > **Analytics & AI** > **Analytics Cloud**.

      ![OAC Menu](images/analytics-oac.png)

2. Create the OAC instance in the Demo compartment and click **Create Instance**.

      ![OAC Create Button](images/oac_create_button.png)

3. (a) Fill the web form with the following information and click **Create**:

      - **Compartment**: `e2e-demo-specialist-eng` compartment, unless you have permissions and experience selecting a different one.
      - **Name**: `WorkshopAnalytics`
      - **Description**: `Analytics Instance for Data Science workshop`
      - **Capacity**: `OCPU` and `1 - Non Production`
      - **License Type**: `License Included` and `Enterprise Analytics`

      ![OAC Form](images/oac_form.png)

      Your Analytics Instance will start provisioning.

      ![pic3](images/oac_creating.png)

      (b) Now Configure Private Access Channel of OAC.
      Go to the private Access Channel under Resources and Configure Private Access Channel:

      ![oacpac_1](images/oacpac1.png)

      (c) Fill the details and click on configure button:

      ![oacpac_2](images/oacpac2.png)

4. Deploy the DVX file to OAC project

      - Collect the OAC dashboard extract file (.DVA) file from this location.[MYSQLLakehouse_labfiles\Lab5\OAC]
      - Upload these files to OAC console and Visualize Dashboards .
      - Predictive Streaming Analytics.dva
      - **DVA password - Admin123

      ![DVA File Deployment](images/oac_dashbaord.png)
      ![DVA File Deployment](images/oac_import.png)

5. Changing the connection for MYSQL Heatwave for Live Dashboard

      - Navigate to `OAC Home page` and click on Navigate `option` -> `Data` as shown below.

      ![Navigation](images/analytics-navigate.png)

      - Click on `Data`

      ![Connection Navigation](images/analytics-navigate-data.png)

      - In the below window click on `Data` then on the existing LiveDs, click on vertical dots and then click on Inspect option to re-point the existing MYSQLHW connection to the MYSQL HW instance in your Demo environment.

      ![Connection Navigation](images/analytics-navigate-connection.png)

      - Click on `Inspect` and edit the MYSQL connections and click on Save.

      ![Connection Navigation](images/analytics_mysqlconnection.png)

6. Navigate to the `Workbooks and Reports` and double click on the `Predictive Streaming Analytics` icon and reload all the demo Dashboard.

      - Live Dashboard - Contains the live data being sourced from the SQL table to OAC.

      ![Live Dashboard](images/analytics_realtime.png)

      - There are a couple more static dashboards for your reference which shows visualization on different sensor KPI and fabricated Operational datasets.These dashboards are designed for your reference only.

      ![Live Dashboard](images/analytics_dashbaord1.png)
      ![Live Dashboard](images/analytics_dashbaord2.png)

- NOTE: Provisioning an Oracle Analytics Cloud instance can take from 10 (most likely) to 40 minutes.

   We will get back to your Oracle Analytics Cloud instance later in the workshop.

You may now **proceed to the next lab**

## Acknowledgements

* **Author** - Biswanath Nanda, Principal Cloud Architect, North America Cloud Infrastructure - Engineering
* **Contributors** -  Biswanath Nanda, Principal Cloud Architect,Bhushan Arora ,Principal Cloud Architect,Sharmistha das ,Master Principal Cloud Architect,North America Cloud Infrastructure - Engineering
* **Last Updated By/Date** - Biswanath Nanda, November 2024