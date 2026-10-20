# Provision an Oracle Autonomous AI Database

## Introduction

Provision an Oracle Autonomous AI Database with the Lakehouse workload using the OCI Console. You will use this database for the embedded Essbase labs that follow.

This lab uses a paid Lakehouse instance with 2 ECPUs and 1 TB of database storage. Always Free must remain disabled because embedded Essbase is unavailable on Always Free instances. You will enable Essbase after provisioning, in Lab 3.

Estimated Time: 5 minutes

### Objectives

In this lab, you will:

- Learn how to provision a new Oracle Autonomous AI Database instance.

### Prerequisites

- Access to your own Oracle Cloud tenancy with permission to create a paid Autonomous AI Database in the workshop compartment.
- [Sign in to Oracle Cloud](https://www.oracle.com/cloud/sign-in.html) before you begin.

## Task 1: Choose Autonomous AI Database from the Services Menu

1. Open the **Navigation** menu.

    ![OCI Console home page with the navigation menu button outlined at the top left](images/open-navigation-menu.png =65%x*)

2. Under **Oracle AI Database**, click **Autonomous AI Database**.

    The **Autonomous AI Databases** page is displayed.

    ![Autonomous AI Databases page with the Compartment filter outlined above the database list](images/adb-show-compartment-button.png =65%x*)

    OCI resources are organized into compartments. Click the **Compartment** field to select the compartment where you want to create your Autonomous Database.

    > **Note:** Avoid the use of the `ManagedCompartmentforPaaS` compartment as this is an Oracle default used for Oracle Platform Services.

3. You can use the **Search and Filter** field to control the list of Autonomous Databases that are displayed on the page. This is useful when you are managing many Autonomous Databases. For example, you can use **Workload type** to filter the Autonomous Database list by selecting your workload type. You can also use the **State** filter to view databases that are `available`, `stopped`, `terminated` and much more.

    ![Search and Filter menu showing Tags, Workload type, and State filters](images/search-and-filter.png =65%x*)

4. Confirm the **region** in the top-right corner of the page. Use this region and the selected compartment throughout the workshop.

    ![OCI region selector showing US East (Ashburn) in the top navigation bar](./images/oci-region-list.png =65%x*)

## Task 2: Create the Autonomous AI Database Instance

1. On the **Autonomous AI Databases** page, select your desired **region** and **compartment**. Click **Create Autonomous AI Database** to start the instance creation process. The **Create Autonomous AI Database Serverless** page is displayed.

    ![Autonomous AI Databases page with the Create Autonomous AI Database button highlighted](images/click-create-new-adb.png =65%x*)

2. Specify the following:

    - **Display name**: Enter a memorable name for the database for display purposes. For this lab, use **ESSBASELAB**.
    - **Database Name**: Use letters and numbers only, starting with a letter. Maximum length is 30 characters. _Underscores are not supported_. For this lab, use **ESSBASELAB**.
    - **Compartment**: Select your compartment from the drop-down list.

        ![Create Autonomous AI Database form with Display name, Database name, and Compartment fields](./images/adb-create-screen-names.png =65%x*)

    >**Note:** Ensure that you use the suggested database names as instructed in this step, and not those shown in the screenshots.

3. In the **Workload type** section, choose a workload type. Select the workload type for your database from the following choices:

    - **Lakehouse**: Built for analytics and AI. Fast insights from a single lakehouse for all your data.
    - **Transaction Processing**: Provides all of the performance of the market-leading Oracle Database in an environment that is tuned and optimized to meet the demands of a variety of applications, including: mission-critical transaction processing, mixed transactions and analytics, IoT, and JSON document store.
    - **JSON**: It is Oracle Autonomous Transaction Processing, but designed for developing NoSQL-style applications that use JavaScript Object Notation (JSON) documents. You can store up to 20 GB of data other than JSON document collections. There is no storage limit for JSON collections.
    - **APEX**: It is a low cost, Oracle Cloud service offering convenient access to the Oracle APEX platform for rapidly building and deploying low-code applications.

    For this workshop, select **Lakehouse**.

    ![Workload type choices with Lakehouse selected](images/adb-create-screen-workload.png =75%x*)

4. In the **Database configuration** section, specify the following:

    - **Always Free**: Leave this disabled. Embedded Essbase cannot be enabled on an Always Free database.
    - **Developer**: Leave this disabled to provision the full paid Lakehouse service used in this workshop.
    - **Choose database version**: Select **26ai** for the database version from this drop-down list.
    - **ECPU count**: Choose the number of ECPUs for your service. For this lab, specify **2 ECPUs**.
    - **Compute auto scaling**: Disable this for the workshop. You can enable it later if your workload requires additional compute.
    - **Storage (TB)**: Select your storage capacity in terabytes. For this lab, specify **1 TB** of storage.
    - **Storage auto scaling**: For this lab, there is no need to enable storage auto scaling, which would allow the system to expand up to three times the reserved storage. Accept the default which is disabled.

        ![Database configuration showing version 26ai, 2 ECPUs, autoscaling control, and 1 TB storage](./images/adb-create-database-configuration.png =75%x*)

        >**Note:** You can drill down on the **Advanced options** option to take advantage of database consolidation savings with **elastic pools** or to use your organization's on-premise licenses with **bring your own license**.

5. In the **Backup** section, specify the following:
    - **Automatic backup retention period in days:** You can either accept the default value or specify your own preferred backup retention days value. For this lab, accept the default of `60` days.
    - **Immutable backup retention:** Accept the disabled default selection.

    ![Backup settings showing 60-day automatic retention and backup retention lock off](./images/choose-backup-retention.png =75%x*)

6. In the **Administrator credentials creation** section, specify the following:

    - **Username:** This read-only field displays the default administrator username, **`ADMIN`**. _**Important:** Make a note of this **username** as you will need it to perform later tasks._
    - **Password:** Create a unique password for the **`ADMIN`** user that meets the requirements displayed in OCI. _**Important:** Make a note of this **password** as you will need it to perform later tasks._
    - **Confirm password:** Confirm your password.

        ![Administrator credentials section with ADMIN username and masked password fields](./images/adb-create-screen-password.png =75%x*)

7. In the **Network access** section, select one of the following options:
    - For this lab, accept the default selection, **Secure access from everywhere**.
    - If you want to allow traffic only from the IP addresses and VCNs you specify - where access to the database from all public IPs or VCNs is blocked, select **Secure access from allowed IPs and VCNs only** in the Choose network access area.
    - If you want to restrict access to a private endpoint within an OCI VCN, select **Private endpoint access only** in the Choose network access area.
    - If the **Require mutual TLS (mTLS) authentication** option is selected, mTLS will be required to authenticate connections to your Autonomous AI Database. TLS connections allow you to connect to your Autonomous AI Database without a wallet, if you use a JDBC thin driver with JDK8 or above. See the [documentation for network options](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/support-tls-mtls-authentication.html#GUID-3F3F1FA4-DD7D-4211-A1D3-A74ED35C0AF5) for options to allow TLS, or to require only mutual TLS (mTLS) authentication.

        ![Network access choices with Secure access from everywhere selected and mutual TLS off](./images/adb-create-network-access.png =65%x*)

8. In the **Contacts for operational notifications and announcements** section, provide a contact email address. The **Contact email** field allows you to list contacts to receive operational notices and announcements as well as unplanned maintenance notifications.

9. Click **Create**.

10. The **Autonomous AI Database details** page is displayed. The status of your ADB instance is **`Provisioning`**.

    ![Database details showing Provisioning status and a guided tour dialog with Skip tour button](./images/adb-create-provisioning-message-new.png =75%x*)

    A **Check database lifecycle state** informational box is displayed. You can navigate through this tour or choose to skip it. Click **Skip tour**. A **Skip guided tour** dialog box is displayed. Click **Skip**.

    In a few minutes, the instance status changes to **`Available`**. At this point, your Autonomous AI Lakehouse instance is ready to use! Review your instance's details including its name, database version, ECPU count, and storage size.

    >**Note:** In the following screen sample, the database display name is **`Training-Database`** and the database name is **`TrainingDatabase`**. _In your example, your **database display name** and **database name** might be different_.

    ![Database details showing the Available state, database name, and Lakehouse workload](./images/adb-created.png =75%x*)

11. Click the **Autonomous AI Databases** link in the top left of the page. The **Autonomous AI Database** page is displayed.

    ![Autonomous AI Databases back link at the top of the database details page](./images/click-left-arrow.png =75%x*)

    Your new Autonomous AI Database instance is displayed.

    In the following sample screen capture, the instance display name is **`Training-Database`**.

    ![Autonomous AI Databases list showing the newly created Lakehouse database as Available](./images/adb-home-page.png =75%x*)

12. An email message is sent to the contact email that you provided. The email contains useful links that you can use to launch Database Actions, view the Get Started with Autonomous AI Database Web page, and access the online forums to post a question and collaborate with other Autonomous AI Database experts.

    ![Oracle Autonomous Database provisioning email with a Launch Database Actions button and getting started links](./images/provisioning-email-generic.png =65%x*)

Record the database name, region, compartment, and ADMIN credentials. Continue to **Lab 2: Check existing Lakehouse and prepare access**.

Please [proceed to the next lab](#next).

## Learn more

- [Using Oracle Autonomous AI Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/autonomous-intro-adb.html)
- [What-if Analysis, Planning, and Business Analytics with Oracle Essbase](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/use-essbase-autonomous-ai-database-tool.html)

## Acknowledgements

- **Author:** Lauran K. Serhal, Consulting User Assistance Developer
- **Source tasks:** Lauran K. Serhal, Oracle LiveLabs, March 2026
- **Workshop adaptation:** Ty Wolber, October 2026
