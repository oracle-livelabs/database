# Get Started

## Introduction

In this section, you will confirm which workshop path you are using.

Trusted Answer Search can be deployed on **Oracle Autonomous Database Serverless (ADB-S)** or on-premises using Oracle Database 23ai or later. This workshop focuses on OCI ADB-S.

**Estimated time:** 5 minutes

### Objectives

* Choose the green button path or the manual walkthrough path.
* Gather the values needed for manual installation.
* Confirm where to start the hands-on labs.

### Prerequisites

For the **green button path**, you need:

* The **Admin URL** from your LiveLabs reservation or Terraform `admin_url` output.
* The **Published Wiki Search URL** from your LiveLabs reservation or Terraform `published_wiki_search_url` output.
* The `TASADMIN` username.
* The `TASADMIN` password.

For the **manual walkthrough path**, you need:

* Access to an Oracle Cloud Infrastructure tenancy.
* Permission to create an Autonomous Database and a small Compute VM.
* Basic familiarity with Linux command-line work.
* Oracle Database 23ai or later. Oracle Database 26ai is recommended.

## Task 1: If You Are Using Green Button

If your environment was provisioned for you, do not install anything manually.

Confirm that you have these values:

```text
<copy>
Admin URL
Published Wiki Search URL
TASADMIN username
TASADMIN password
</copy>
```

Then skip directly to **Lab 4: Trusted Continuous Improvement of Search**.

Lab 4 is the product story: an end-user search experience, a governed draft, expert feedback, and a corrected Rank #1 result.

### If the Direct Admin App URL Does Not Open

The green-button stack normally gives you a direct Admin app URL. If that URL does not open the app, use the APEX home URL instead.

1. Change the URL so it ends with:

    ```text
    <copy>
    /ords/apex
    </copy>
    ```

2. Sign in to the `TASADMIN` workspace with the same username and password.

    ![Sign in to TAS workspace](images/sign-in-tas-workspace.png)

3. Click **App Builder**.

    ![Navigate to App Builder](images/navigate-to-app-builder.png)

4. Open or run **Oracle Trusted Answer Search - Admin App**.

After the Admin app opens, continue to **Lab 4**.

## Task 2: If You Are Doing the Manual Walkthrough

You will complete the setup labs first:

1. **Lab 1:** Prepare the ONNX embedding model and database connectivity.
2. **Lab 2:** Run the backend installer.
3. **Lab 3:** Load the Admin app, Portal app, and Wikimedia sample data.
4. **Lab 4:** Start the main trusted-search storyline.

The setup labs are intentionally practical. They get the database, backend, APEX apps, and sample data ready so that Lab 4 can focus on the value of the product.

## Task 3: Gather Manual Installation Values

Before continuing to Lab 1, gather or plan for:

* Autonomous Database `ADMIN` password.
* A `TASADMIN` password for the Trusted Answer Search admin user.
* A database connect string or wallet/TNS alias.
* A Pre-Authenticated Request URL for the ONNX embedding model.
* The Trusted Answer Search product zip containing `backend_ship.zip` and `apex_ship.zip`.

You may now **proceed to the next lab**.

## Acknowledgements

**Authors** 

* Allen Hosler, Principal Product Manager, Database Applied AI

**Last Updated Date** - May, 2026
