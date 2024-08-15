# Get Started with Livelabs

## Introduction

Welcome to your LiveLabs Sandbox environment. In order to start your workshop, you need to login to our LiveLabs Sandbox.

In this lab, we are going to show you where you can find the login information and how to log in to the LiveLabs Sandbox.

Estimated Time: 5 minutes

### Objectives

-   View login information to LiveLabs Sandbox
-   Identify DB Server Public IP Addresses

### Prerequisites

* Requested a Green Button environment with:-
  - An assigned Oracle LiveLabs Cloud account
  - An assigned compartment
  - An Assigned OCI username
  - An assigned OCI Password

## Task 1: Log in to the Oracle Cloud Console

1. Click the **View Login Info** link in the banner.

    ![Click View Login Info.](./images/ll-view-login-info.png " ")

     This panel displays important information that you will need throughout this workshop.

    ![The Workshop is displayed.](./images/ll-reservation-information.png " ")

2. Click **Copy Password** to copy your initial password, and then click **Launch OCI**.

3. On the Sign In page, in the **Oracle Cloud Infrastructure Direct Sign-In** section, your assigned username is already displayed in the **User Name** field. Paste your password in the **Password** field, and then click **Sign In**.

    ![The Oracle Cloud Infrastructure Direct Sign-In section with the populated username and password is displayed. The Sign In button is highlighted.](./images/ll-signin.png " ")

4. The **Change Password** dialog box is displayed. Paste your assigned password that you copied in the **Current Password**. Enter a new password in the **New Password** and **Confirm New Password** fields, and then click **Save New Password**. Make a note of your new password as you will need it in this workshop.

    ![The completed Change Password dialog box is displayed. The Save New Password button is highlighted.](./images/ll-change-password.png " ")

    The **Oracle Cloud Console** Home page is displayed. Make sure that the displayed region is the same that was assigned to you in the **Reservation Information** panel of the **Run Workshop *workshop-name*** page, **Canada Southeast (Toronto)** in this example.

    ![The Oracle Cloud Console Home page is displayed with the LiveLabs assigned region highlighted.](images/console-home.png)

    >**Note:** Bookmark the workshop page for quicker access.

## Task 2: Determine the IP addresses of your two Sandbox Nodes

You should already be logged in to the OCI console from Task 1.

1.  Open up the hamburger menu in the left hand corner.  

2.  From the hamburger menu, select **Oracle Database, and then Oracle Base Database** in the Oracle Database category.

  ![Oracle Cloud DBCS Page](https://oracle-livelabs.github.io/common//images/console/database-dbcs.png " ")

3.  Select the compartment you were assigned in LiveLabs and identify your database system from your My Reservations page. Click on the database system name to see the details.

  ![Select DB System](./images/setup-compute-2.png " ")

4. Explore the DB Systems home page.  On the left hand side, scroll down to view the Resources section.  Click Nodes.

  ![Examine DB System](./images/setup-compute-3.png " ")

5. Locate your two nodes and jot down their public IP addresses.

  ![Confirm node IP Addresses](./images/setup-compute-4.png " ")

6. Now that you have the IP Addresses for your cluster nodes you will need to get the SSH keys to connect to those Nodes.
   
   Follow the instructions in Task 1.  **'Oracle Cloud Shell'** in [Your LiveLabs SSH Key Lab](#next)



## Acknowledgements

* **Author** - Rene Fontcha, Master Principal Platform Specialist, NA Technology
* **Contributors** - Kay Malcolm, Product Manager, Database Product Management
* **Last Updated By/Date** - Bill Burton, August 2024
