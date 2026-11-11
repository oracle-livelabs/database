# Check the Existing ADB and Verify Admin Access

## Introduction

In this lab, you will locate the Oracle Autonomous AI Lakehouse created in Lab 1 and sign in to Database Actions as the database ADMIN user. You will create the workshop user in Lab 3, after enabling and provisioning Essbase.

Estimated Time: 10 minutes

### About Database Actions

Database Actions is a browser-based interface for working with your Autonomous AI Database. Access from the OCI Console and access to database tools are controlled separately. In this lab, you will use the OCI Console to find the Lakehouse, then use database credentials to sign in to Database Actions.

### Objectives

In this lab, you will:

- Locate the Autonomous AI Lakehouse created in Lab 1 in your tenancy.
- Open Database Actions using the database ADMIN credentials.
- Verify ADMIN access to Database Actions and locate Data Studio.

### Prerequisites

This lab assumes you have:

- The Autonomous AI Lakehouse created in Lab 1, with lifecycle state **Available**.
- An OCI ADMIN account that can view the AI Lakehouse in the Console.
- Access to Database Actions in AI Lakehouse.

## Task 1: Locate the Existing Autonomous AI Lakehouse

1. Within OCI, open the hamburger menu in the top left corner and select **Oracle AI Database**, then **Autonomous AI Database**.

    ![OCI navigation menu with Oracle AI Database and Autonomous AI Database highlighted](images/ailh_step1.png)

2. Select the region and compartment where your Autonomous AI Lakehouse instance is located.

    ![Autonomous AI Databases page with the selected region and compartment highlighted](images/ailh_2.png)

3. Find the AI Lakehouse you created in Lab 1, such as **ESSBASELAB**, in the database list. Confirm the database name and the lifecycle state is **Available**.

    ![Database list with the Lakehouse instance Available status highlighted](images/ailh_2b.png)

4. Click on the AI Lakehouse to access the database details page.

    ![Database list with the Lakehouse instance name highlighted for selection](images/ailh_2a.png)

## Task 2: Open Database Actions

1. On the details page, open the **Database actions** menu and select **View all database actions**.

    ![Database details page with the Database actions menu open and View all database actions highlighted](images/ailh_3.png)

2. If prompted, sign in as the database **ADMIN** user.

    ![Database Actions sign-in form with ADMIN username, masked password, and Sign in button](images/ailh_4.png)

3. Confirm that the Database Actions launchpad opens and **Admin** is in the top right. Locate the **Data Studio** area and its available tools. This will be used later in the workshop.

    > **Note:** The Database Actions screenshots in this lab use Dark Mode, but the steps are the same in either theme. To enable Dark Mode, click your name in the upper-right corner, then select Preferences → Code Editor → Theme.

    Keep the database ADMIN credentials available. In Lab 3, you will enable and provision Essbase before creating the workshop user and assigning its Essbase role.

    You may now **proceed to the next lab**.

## Learn More

- [Connect with Built-In Oracle Database Actions](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/connect-database-actions.html)
- [Create and Manage Users on Autonomous AI Database](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/manage-users-create.html)
- [Manage User Roles and Privileges on Autonomous AI Database](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/manage-users-privileges.html)

## Acknowledgements

* **Author** - Ty Wolber, Cloud Engineer
* **Last Updated By/Date** - Ty Wolber, October 2026
