# Setup the APEX application and Workspace

![mysql heatwave](./images/mysql-heatwave-logo.jpg "mysql heatwave")

## Introduction

MySQL HeatWave can easily be used for development tasks with existing Oracle services, such as Oracle Cloud Analytics. We will add 2 more applications to this LAMP server.


_Estimated Lab Time:_ 10 minutes

### Objectives

In this lab, you will be guided through the following tasks:

- Download and import the sample application
- Configure the newly imported application
- Add users to the app
- Configure the APEX Workspace

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- Some Experience with MySQL Shell
- Some Experience with Oracle Autonomous and Oracle APEX
- Must Complete Lab 8
- Must Complete Lab 9

## Task 1: Download the sample application - MovieHub

1. Download the MovieHub application template:

    Click on this link to **Download file** [MovieHub.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/IV9G5YNe0k7TxBeL-kIs7APtLwgHBEXHGc9nxARpsgS1lxcNg6tm6qTVIsbOdnw6/n/idi1o0a010nx/b/Bucket-CA/o/LiveLab-MovieHub-images/MovieHub_V3.zip) to your local machine

## Task 2: Import the sample application - MovieHub

1. Connect to your APEX Workspace:

    a. Connect to your APEX workspace

    b. Go to App Builder

    ![Connect to APEX , menu](./images/apex-workpace-menu.png "apex-workpace-menu ")

    ![APEX App Builder](./images/apex-app-builder.png "apex-app-builder ")

2. Import the MovieHub file

    a. Click on Import

    ![APEX Import](./images/apex-import-moviehub.png "apex-import-moviehub ")

    b. Select the downloaded file **MovieHub.zip** . Click on **Next** two times

    c. Click **Install Application**

    ![APEX Import Install](./images/apex-import-install-moviehub.png "apex-import-install-moviehub ")

    d. Click on Edit Application after the application ends installing

    ![MovieHub App Installed](./images/apex-app-installed.png "apex-app-installed ")

## Task 3: Modify the REST Enabled SQL Endpoint for the App

The imported app will import a broken REST Enabled SQL Endpoint from the export source

1. Navigate to **REST Enabled SQL**

    a. Navigate to the Workspace Utilities from the App Builder Menu

    ![Workspace Utilities](./images/apex-menu-workspace-utilities.png "apex-menu-workspace-utilities ")

    b. Click on **REST Enabled SQL Services**

    ![workspace utilities rest services](./images/workspace-utilities-rest-services.png "workspace-utilities-rest-services ")

    c. Select the Endpoint that was imported "hw-endpoint-rest"

    ![RESTful services endpoints](./images/restful-services-endpoints-menu.png "restful-services-endpoints-menu ")

2. You can delete the **REST** resource or edit it

    a. Edit the endpoint with your current endpoint (The connection endpoint that was previously created)

    b. Edit the credentials and select your previously created credentials

    c. Make sure the correct default database is selected

    ![Edit RESTful resource](./images/restful-resource-edit.png "restful-resource-edit ")

## Task 4: Add Users to the App

As this is an imported app, your current workspace user will not have administration access to it

1. Register an Administrator account

    a. Navigate to Shared Components

    ![App Builder Menu](./images/apex-app-builder-2.png "app-builder-menu ")

    ![Shared Components Menu](./images/apex-shared-components.png "shared-components-menu ")

    b. Go to Application Access Control

    c. Click on Add User Role Assignment. Create a user 'ADMIN' and assign **administrator role** to it. This administrator account would be referred as '**admin account**'

    ![Add User Role Assignment for APEX user](./images/apex-add-role-assignment.png "apex-add-role-assignment ")

2. Create a 'Public' Role Assignment to simulate the difference in application usage between an administrative account and a non-administrative user account.

    a. Navigate to Shared Components

    b. Go to Application Access Control

    c. Click on Add User Role Assignment. Create a User Role Assignment, **Contributor role** and **Reader role**. This non administrative account would be referred as '**public account**'

    ![Create User Role Assignment for APEX user](./images/apex-create-role-assignment-public.png "apex-create-role-assignment-public ")

    d. You should have 2 roles like this

    ![Role Assignment list](./images/apex-role-assignments-list.png "apex-role-assignments-list ")

3. Create a 'Public' account in the Administration - Users And Groups configuration

    a. In the APEX workspace. Click on the administration tab

    b. Navigate to **Manage Users and Groups**

    ![Administration tab list](./images/administration-tab-list.png =60%x* "administration-tab-list ")

    c. Click **Create User** with **username** 'public'

    ![Create Public User Workspace](./images/public-create-user.png =80%x* "public-create-user ")

    d. Add an email address

    e. Set a password

    f. Assign all group assignments to the user

    ![Create Public User Workspace 2](./images/public-create-user2.png =80%x* "public-create-user2 ")

    g. Click **Create User**

## Task 5 (BONUS): Increase the Web Service requests

When using Web Services with Oracle Autonomous Database, there is a limit in the number of 50,000 outbound web service requests per APEX workspace in a rolling 24-hour period. If the limit of outbound web service calls is reached, the following SQL exception is raised on the subsequent request and the request is blocked:
ORA-20001: You have exceeded the maximum number of web service requests per workspace. Please contact your administrator.

You may want to increase this limit if it is being reached

1. Navigate to your Autonomous Database in OCI Console

2. Click on the dropdown menu Database Actions

3. Select SQL

    ![Autonomous actions menu](./images/autonomous-actions-menu-sql.png "autonomous-actions-menu-sql ")

4. Run the query to increase the **MAX\_WEBSERVICE\_REQUESTS** limit

    ```bash
    <copy>BEGIN
        APEX_INSTANCE_ADMIN.SET_PARAMETER('MAX_WEBSERVICE_REQUESTS', '250000');
        COMMIT;
    END;
    / </copy>
    ```

    ![Increase Web services request limit Autonomous actions menu](./images/autonomous-sql-increase-limit.png "autonomous-sql-increase-limit ")

You may now **proceed to the next lab**

## Learn More

- [Oracle Autonomous Database Serverless Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/index.html#Oracle%C2%AE-Cloud)
- [Using Web Services with Oracle APEX Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/apex-web-services.html#GUID-DA24C605-384D-4448-B73C-D00C02F5060E)

## Acknowledgements

- **Author** - Cristian Aguilar, MySQL Solution Engineering
- **Contributors** - Perside Foster, MySQL Principal Solution Engineering
- **Last Updated By/Date** - Cristian Aguilar, MySQL Solution Engineering, November 2024