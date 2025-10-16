# Get Started with Livelabs

## Introduction

Welcome to your LiveLabs Sandbox environment. In order to start your workshop, you need to login to our LiveLabs Sandbox.

In this lab, we are going to show you where you can find the login information and how to log in to the LiveLabs Sandbox.

Estimated Time: 5 minutes


### Objectives

* View login information to LiveLabs Sandbox
* Login to LiveLabs Sandbox

### Prerequisites

* Requested a Green Button environment

## Task 1: Log in to the Oracle Cloud Console

1. Click the **View Login Info** link in the banner.

    ![Click View Login Info.](./images/ll-view-login-info.png =50%x* " ")

     This panel displays important information that you will need throughout this workshop.

    ![The Workshop is displayed.](./images/ll-reservation-information.png =50%x* " ")

2. Click **Copy Password** to copy your initial password, and then click **Launch OCI**.

3. On the Sign In page, in the **Oracle Cloud Infrastructure Direct Sign-In** section, your assigned username is already displayed in the **User Name** field. Paste your password in the **Password** field, and then click **Sign In**.

    ![The Oracle Cloud Infrastructure Direct Sign-In section with the populated username and password is displayed. The Sign In button is highlighted.](./images/ll-signin.png =50%x* " ")

4. The **Change Password** dialog box is displayed. Paste your assigned password that you copied in the **Current Password**. Enter a new password in the **New Password** and **Confirm New Password** fields, and then click **Save New Password**. Make a note of your new password as you will need it in this workshop.

    ![The completed Change Password dialog box is displayed. The Save New Password button is highlighted.](./images/ll-change-password.png =50%x* " ")

    The **Oracle Cloud Console** Home page is displayed. Make sure that the displayed region is the same that was assigned to you in the **Reservation Information** panel of the **Run Workshop *workshop-name*** page, **Canada Southeast (Toronto)** in this example.

    ![The Oracle Cloud Console Home page is displayed with the LiveLabs assigned region highlighted.](images/console-home.png =50%x*)

    >**Note:** Bookmark the workshop page for quicker access.


## Task 2: Navigate to the Autonomous AI Database

1. You should be already logged in to the Console using the instructions in the **Task 1** above in this lab.

2. Open the **Navigation** menu (top left hand corner)and click **Oracle Database**. Under **Oracle Database**, click **Autonomous AI Database**. 

    ![Screenshot of the Oracle Cloud Console showing the Autonomous Database section highlighted in the navigation menu. The wider environment includes the Console interface with various database options visible. The emotional tone is neutral and instructional. Visible text includes Oracle Database and Autonomous Database in the navigation menu, guiding users to locate their Autonomous Database instance.](./images/adb.png =50%x*)


3. You may see an error message if you're in the wrong compartment. Your resources are in your assigned LiveLabs compartment, not the root compartment.

    ![Warning that you might get if you are in the root compartment and not in your own LiveLabs assigned compartment.](./images/wrong-compartment.png =50%x* " ")

4. Switch to your assigned compartment:
    - in the center (see the picture below), click the **Compartment** button
    - Search for your compartment name (looks like **LL#####-COMPARTMENT** with 5 numbers)
    - Select your assigned compartment when it appears
    - Verify you're in the correct region shown in your **Reservation Information**

    ![The Data Catalogs page in your assigned LiveLabs compartment is displayed. The training-dcat-instance Data Catalog instance provided for you is displayed on this page.](./images/compartment.png =50%x* " ")

    >**Note:** Refer to the **Reservation Information** panel that you can access from the **Run Workshop *workshop-name*** tab for information about your assigned resources.
    ![The LL assigned resources are displayed in the **Reservation Information** panel.](./images/ll-resources.png =50%x* " ")

5. Now, On the **Autonomous AI Databases** page, click your ADB instance.
    ![On the Autonomous Databases page, the Autonomous Database that is assigned to your LiveLabs workshop reservation is displayed.](./images/ll-adb-page.png =50%x* " ")

6. On the **Autonomous AI Database details** page, click the **Database actions** drop-down list, and then click **Database Users**.

    ![The Database Actions button is highlighted.](./images/im1.png =50%x* " ")

7. From the Database Users page, click the icon to open the `AIWORLD25` users login page.

    ![The Database Actions button is highlighted.](./images/im2.png =50%x* " ")

8. Sign in with the following info:
    * Username: AIWORLD25
    * Password: OracleAIworld2025

    ![The Database Actions button is highlighted.](./images/im3.png =50%x* " ")

9. This is the database actions launchpad. From here, select open (in the bottom right hand corner) to launch the SQL Editor

    ![The Database Actions button is highlighted.](./images/im4.png =50%x* " ")

10. Before we begin, this lab will be using Database Actions Web. If you're unfamiliar, please see the picture below for a simple explanation of the tool. You can click on the photo to enlarge it.

    ![The Database Actions button is highlighted.](../common-images/simple-db-actions.png =50%x* " ")

You may now proceed to the next lab.

## Learn More

* [Oracle Cloud Infrastructure Documentation](https://docs.cloud.oracle.com/en-us/iaas/Content/GSG/Concepts/baremetalintro.htm)
* [Using Oracle Autonomous AI Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)

## Acknowledgements

* **Author:** Killian Lynch, Oracle Database Product Manager
* **Contributors:**
    * Mike Matthews, Autonomous AI Database Product Management
    * Marty Gubar, Autonomous AI Database Product Management
    * Lauran K. Serhal, Consulting User Assistance Developer
* **Last Updated By/Date:** Killian Lynch, September 2025
