# Manage Users and Roles

## Introduction

In this lab, you will create and manage users in Oracle Linux Virtualization Manager (OLVM) 4.5.

OLVM 4.5 supports more than one user source. Users similar to the default portal administrator (`admin@ovirt`) are created through the integrated Keycloak service. OLVM also supports local internal users, which are created on the engine host with `ovirt-aaa-jdbc-tool`.

In this lab, you will create both:
- a Keycloak-backed administrative user
- a local internal user

Estimated Time: 20-30 minutes

### Objectives

In this lab, you will:

- Create a new user in the Keycloak `Ovirt-internal` realm
- Import the Keycloak user into OLVM
- Assign the `SuperUser` role to the Keycloak user
- Create a local internal user with `ovirt-aaa-jdbc-tool`
- Import the local user into OLVM
- Assign a role to the local user
- Understand the difference between Keycloak-backed users and local internal users

## Prerequisites

This lab assumes you have:

- Completed the OLVM Engine deployment
- Access to the OLVM Administration Portal as `admin@ovirt`
- Access to the Keycloak Administration Console as `admin`
- SSH access to the OLVM engine host

> **Important:** In OLVM 4.5, users created with `ovirt-aaa-jdbc-tool` are local internal users. They are different from Keycloak-backed users such as `admin@ovirt`.

## Task 1: Create a Keycloak-Backed Administrative User

1. Open your local browser (Chrome, Firefox, or Edge).

2. Navigate to the Keycloak Administration Console:

    ```text
    <copy>https://<olvm-fqdn>/ovirt-engine-auth</copy>
    ```

    Example: https://olvm.pub.olv.oraclevcn.com/ovirt-engine-auth

3. Log in using the Keycloak administrative account:

    - **Username:** `admin`
    - **Password:** *(the password configured during `engine-setup`)*

4. Confirm that the selected realm is:

    ```text
    <copy>Ovirt-internal</copy>
    ```

    > **Important:** Make sure the realm selector in the top-left of the Keycloak console shows **Ovirt-internal** — not **master**. If it shows **master**, click the realm name and switch to **Ovirt-internal** before continuing.

5. In the left navigation menu, click **Users**.

6. Click **Add user**.

7. Enter values similar to the following:

    | Field | Value |
    |---|---|
    | Username | `newadmin` |
    | Email | *(optional)* |
    | First name | `New` |
    | Last name | `Admin` |
    | Enabled | On |

8. Click **Save**.

## Task 2: Set the Keycloak User Password

1. With the new user selected, click the **Credentials** tab.

2. Enter a password for the new user.

3. Set **Temporary** to **Off**.

4. Click **Set Password**.

5. Confirm the password reset when prompted.

## Task 3: Import the Keycloak User into OLVM

1. Return to the **OLVM Administration Portal**.

2. Log in as:

    ```text
    <copy>admin@ovirt</copy>
    ```

3. Go to **Administration** → **Users**.

    ![Show OLVM Administration Portal with Users pane](images/olvm-admin-portal.png "Show OLVM Administration Portal with Users pane")

4. Under **Search** select **internalsso (internalkeycloak-authz)**

5. Click **Add**.

6. In the search field, enter the username you created in Keycloak:

    ```text
    <copy>newadmin</copy>
    ```

7. Click **Go**.

8. Select the user from the results and click **Add**.

    > **Troubleshooting Tip:** If the user does not appear, verify that the account was created in the `Ovirt-internal` Keycloak realm and that you are searching the correct authorization provider.

## Task 4: Assign the SuperUser Role to the Keycloak User

1. In **Administration** → **Users**, select the newly added user.

2. In the details pane, click the **Permissions** tab.

3. Click **Add System Permission**.

4. Select the following role:

    ```text
    <copy>SuperUser</copy>
    ```

5. Click **OK**.

## Task 5: Create a Local Internal User

> **Important:** In a Keycloak-enabled OLVM 4.5 environment, a local internal user created with `ovirt-aaa-jdbc-tool` may not be usable for normal web portal login. For browser-based administrative access, use a Keycloak-backed user such as the one created in Tasks 1–4.

To create a local internal user in OLVM 4.5, use the `ovirt-aaa-jdbc-tool` on the engine host.

1. Connect to the OLVM engine host using SSH.

2. Create the user account.

    ```bash
    <copy>sudo ovirt-aaa-jdbc-tool user add test1 --attribute=firstName=John --attribute=lastName=Doe</copy>
    ```

    The `--attribute` flags are optional, but they are recommended because they make the user easier to identify in the Administration Portal.

## Task 6: Set the Local User Password

1. Run the following command on the engine host:

    ```bash
    <copy>sudo ovirt-aaa-jdbc-tool user password-reset test1</copy>
    ```

2. Enter and confirm the password when prompted.

## Task 7: Add the Local User to the Administration Portal

Even after the local user is created, the account will not appear in the Administration Portal until you manually add it.

1. Log in to the OLVM Administration Portal as an administrator.

2. Go to **Administration** → **Users**.

3. Click **Add**.

4. In the **Search** dropdown, select **internal (internal-authz)** — this is the provider for local users created with `ovirt-aaa-jdbc-tool`, not the Keycloak provider.

5. In the search field, type the name of the user you just created.

6. Click **Go**.

7. Select the user from the results and click **Add**.

## Task 8: Assign a Role to the Local User

Once added to the portal, you must assign a role.

1. Select the local user in the **Users** pane.

2. Click the **Permissions** tab in the details section.

3. Click **Add System Permission**.

4. Select a role such as:

    - `UserRole` for VM Portal access
    - `SuperUser` for full administrative rights

5. Click **OK**.

## Task 9: Verify User Access

1. Log out of the OLVM Administration Portal.

2. Log in using the new Keycloak-backed administrative user and verify full access.

3. Confirm that the local internal user appears in **Administration** → **Users**.

4. Verify that the local internal user has the expected role assigned in the **Permissions** tab.


## Key Concepts

- **Keycloak-backed users** are used for users similar to `admin@ovirt`.
- **Local internal users** are created with `ovirt-aaa-jdbc-tool`.
- Both types of users must be added to OLVM and assigned roles before they can be used effectively.
- A user without permissions can authenticate but may not have usable access in the portal.

## Manage Users and Roles Checkpoint

At this point, you should have:

- A new Keycloak-backed administrative user
- The `SuperUser` role assigned to that user
- A local internal user created with `ovirt-aaa-jdbc-tool`
- A role assigned to the local user
- Verified login and access for both user types

You may now **proceed to the next lab**

## Learn More

- Oracle Linux Virtualization Manager install lab (official): https://docs.oracle.com/en/learn/olvm-install/index.html
- Keycloak Administration Console documentation

## Acknowledgements

- **Author** - Shawn Kelley, Perside Foster
- **Contributor** - Marvin Kim
- **Last Updated By/Date** - Perside Foster, May 20, 2026
