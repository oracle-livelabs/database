# Enable Embedded Essbase and Create the Workshop User

## Introduction

In this lab, you will enable embedded Essbase from the OCI Console and sign in as the database ADMIN user for initial provisioning and catalog setup. After provisioning completes, you will create the workshop database user, grant the Essbase role, and verify access before importing the PeakGear Sporting Goods application in the next lab.

Estimated Time: 35 minutes

### About Essbase

Essbase provides multidimensional cubes for analyzing business data. In this workshop, Essbase is available from the Data Studio area of Database Actions in your existing Autonomous AI Lakehouse.

### Objectives

In this lab, you will:

- Enable and provision Essbase from the OCI Console.
- Sign in to Essbase and verify that it provisioned properly.
- Create a workshop user with Web Access and the Essbase Power User role after provisioning.
- Confirm the Import action is available for the workshop user.

### Prerequisites

This lab assumes you have:

- Access to the existing Autonomous AI Lakehouse and permission to enable embedded Essbase.
- OCI Console access and the database ADMIN credentials verified in Lab 2.

## Task 1: Enable and Provision Essbase from AI Lakehouse

1. Return to your AI Lakehouse details page.

    ![Autonomous AI Databases list with the available Lakehouse instance highlighted](images/ailh_2a.png)

2. Click on **Tool Configuration** from the ribbon options.

    ![Autonomous AI Database details page with Tool configuration tab highlighted](images/t1.png)

3. Scroll down to **Essbase** then click **Edit**.

    ![Tool configuration page with Essbase Edit button highlighted](images/t2.png)

4. Toggle on **Enable Essbase** and click apply. You can configure the OCPU count and idle time here as well.

    ![Configure tools panel with Enable Essbase switch and Apply button highlighted](images/t3.png)

5. After AI Lakehouse finishes updating, copy the URL under Essbase and paste it in a new browser window.

    ![Enabled Essbase section with Copy button beside its public access URL](images/t4.png)

6. On the Essbase sign-in page, enter the database **ADMIN** credentials.

    ![Essbase sign-in form with ADMIN entered as the user name](images/temp6.png)

7. Select **Sign In**. Essbase will take a few minutes to provision when the first user logs in. After provisioning starts proceed to Task 2.

## Task 2: Catalog Object Storage Configuration

1. While Essbase provisions, go back to your OCI console tab. Click the **Navigation Menu** in the top left then **Storage → Buckets**.

    ![OCI navigation menu with Storage and Buckets highlighted](images/ob1.png)

2. Select the compartment designated for the lab, then click **Create bucket**.

    ![Buckets page with compartment filter and Create bucket button highlighted](images/ob2.png)

3. Enter a unique name, such as `essbase-embedded-ailakehouse-catalog`. Select the **Standard** storage tier and leave the rest as default, then click **Create Bucket**.

    ![Create bucket form with bucket name, Standard tier, and Create bucket button highlighted](images/ob3.png)

4. Open the new bucket. Record its **Bucket name** and **Namespace** from the bucket details. Essbase needs the bucket name, not the bucket OCID.

    ![Bucket details page showing the bucket name and Object Storage namespace](images/ob4.png)

5. Open the OCI profile menu for the user whose API signing key will access the bucket, then select **User settings** and copy the **User OCID**. This user may differ from the bucket creator, but must have access to the bucket.

    ![OCI profile menu with User settings highlighted](images/ob5.png)

    ![User profile page with Copy button beside the user OCID](images/ob6.png)

6. On the same user page, open **Tokens and keys**. If you already have the matching private key file, copy its **Fingerprint** and skip Step 7 and 8. Otherwise, click **Add API Key**.

    ![Tokens and keys tab with Add API key button highlighted](images/ob7.png)

7. Download the new **private key** `.pem` file, then click **Add**.

    ![Add API key panel with Download private key and Add button highlighted](images/ob8.png)

8. Copy the displayed fingerprint under **Fingerprint**. Keep the private key in a secure location.

    ![API keys list with the key fingerprint highlighted](images/ob9.png)

9. Open the profile menu and select your tenancy name. Copy the **Tenancy OCID**.

    ![OCI profile menu with tenancy name highlighted](images/ob10.png)

    ![Tenancy details page with Copy button beside the tenancy OCID](images/ob11.png)

10. Return to Essbase as **Admin** user and click **Configure** to add **Catalog Object Storage**.

    | Essbase field | Value to enter |
    | --- | --- |
    | **User ID** | The OCI **User OCID** from User settings |
    | **Fingerprint** | The fingerprint of the API key paired with your private `.pem` file |
    | **Tenancy** | The **Tenancy OCID** |
    | **Region** | The bucket's OCI region identifier, for example `us-ashburn-1` |
    | **Key file** | Select the downloaded **private API signing key** `.pem` file |
    | **Key file content** | Confirm the private key content appears after selecting the file; if needed, paste the private PEM content directly into this Essbase field |
    | **Namespace** | The Object Storage namespace shown in the bucket details |
    | **Bucketname** | The exact bucket name created above |
    | **Private key passphrase** | Enter it only if the private key was created with a passphrase |

11. Wait for initial Essbase provisioning to finish, then click **Test**. If the test succeeds, click **Save** and confirm the catalog loaded. Then sign out of the Essbase ADMIN user.

## Task 3: Create and Enable the Workshop Database User

Complete Tasks 1 and 2 before creating the workshop user. The Essbase role is available only after Essbase has been enabled and provisioned.

1. Open Database Actions for your Lakehouse and sign in as the database **ADMIN** user. Open the hamburger menu in the top left corner. Under **Administration**, select **Database Users**.

    ![Database Actions menu with Administration and Database Users highlighted](../check/images/ailh_6.png)

2. Select **Create User**.

    ![Database Users page with Create User button highlighted](../check/images/ailh_7.png)

3. Enter a username for the workshop user and create a password that meets the displayed requirements. Keep the credentials saved for future use.

    ![Create User panel with username and password fields highlighted](../check/images/ailh_8a.png)

4. Set the **Quota on tablespace DATA** to the amount approved for your workshop environment. The minimum of 25M is enough for the scope of this workshop.

    ![Create User panel with DATA tablespace quota set to 25M](../check/images/ailh_8b.png)

5. Enable **REST, GraphQL, MongoDB API, and Web Access** for the new user.

    ![Create User panel with REST, GraphQL, MongoDB API, and Web access switches enabled](../check/images/ailh_8c.png)

6. Open **Granted Roles**. For both **DWROLE** and **ESSBASEPOWERUSER** Grant and set to Default so the user can access the Data Studio tools used in this workshop. Confirm that both **CONNECT** and **RESOURCE** are Granted and Default as well.

    > **Note:** If the Essbase role is missing, return to Task 1 and confirm Essbase is enabled and its initial provisioning has completed. Reopen the Create User form after provisioning finishes.

    ![Granted Roles tab showing DWROLE and ESSBASE_POWER_USER selected in Granted and Default columns](../check/images/temp3.png)

7. Select **Create User** and confirm that Database Actions reports that the user was created.

8. Find the new user's card on the **Database Users** page. Confirm that the account is open and shows **REST Enabled**.

    ![Database Users page showing ESSBASEUSER account with REST Enabled badge](../check/images/aidp_10.png)

## Task 4: Sign In as the Workshop User and Verify Access

1. Sign out of the **ADMIN** session, or open a separate private browser window.

    ![ADMIN profile menu open with Sign Out highlighted](../check/images/ailh_11.png)

2. Sign in with the Essbase user's credentials from Task 3 to test the credentials.

    ![Database Actions sign-in form with ESSBASEUSER username, masked password, and Sign in button](../check/images/ailh_12.png)

3. Open the Essbase URL saved in Task 1 and sign in with the workshop user created in Task 3. Confirm that the Essbase Applications page opens and **Import** is available.

4. Keep the workshop user credentials for Lab 4 and the optional Smart View and MCP labs.

    You have enabled Essbase, configured its catalog, and verified the workshop user. In the next lab, you will import the PeakGear application.

    You may now **proceed to the next lab**.

## Learn More

- [Connect with Built-In Oracle Database Actions](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/connect-database-actions.html)
- [Using the Oracle Essbase Web Interface](https://docs.oracle.com/en/database/other-databases/essbase/26/ugess/index.html)

## Acknowledgements

* **Author** - Ty Wolber, Cloud Engineer
* **Last Updated By/Date** - Ty Wolber, October 2026
