# Lab 2: Install and Configure Trusted Answer Search

## Introduction
Oracle Trusted Answer Search ships two APEX applications: an **Admin App** for managing the search system and a **Portal App** for end-users to issue queries. In this lab, you will deploy these applications by creating a dedicated workspace linked to your previously installed backend.

**Estimated time:** 20 minutes.

### Objectives
* Access Oracle APEX from the OCI Console.
* Create and configure a dedicated APEX workspace for **TASADMIN**.
* Import and configure the Admin and Portal applications.
* Launch the management interface.

## Task 1: Access Oracle APEX from OCI
1. In the OCI Console, navigate to your **Autonomous Database** instance.
2. Click on the **Tool configuration** tab.
3. Locate **Oracle APEX** and click **Copy** next to the **Public access URL**.
4. Paste the URL into your browser to launch the APEX login screen.

![OCI APEX URL](images/apex-from-oci.png)
*This tab in the OCI console provides the direct access link to your database's low-code development environment.*

## Task 2: Create the TASADMIN Workspace
1. Sign in to the **INTERNAL** workspace using your database `ADMIN` credentials.
2. From the **Administration Services** dashboard, click the green **Create Workspace** button.

![Administration Services](images/first-apex-screen.png)
*The landing page for APEX Instance Administration.*

3. Choose the **Existing Schema** option to associate the workspace with your pre-provisioned TASADMIN backend schema.

![Create Workspace Choice](images/create-workspace-existing-schema.png)
*Selecting 'Existing Schema' allows applications in your workspace to access data stored within that schema.*

4. **Configure the workspace details**:
    * **Database User:** `TASADMIN`
    * **Workspace Name:** `TASADMIN`
    * **Workspace Username:** `ADMIN`
    * **Workspace Password:** [Provide a secure password]
5. Click **Create Workspace**.

![Workspace Configuration](images/configure-workspace.png)
*Linking the workspace to the TASADMIN database user.*

## Task 3: Sign In to the New Workspace
1. **Sign Out** of the INTERNAL workspace by clicking the profile icon in the top-right and selecting **Sign out**.

![Sign Out](images/sign-out.png)
*Ensure you exit the internal administration environment before signing in to your app workspace.*

2. On the login screen, select or enter the **TASADMIN** workspace and sign in with the credentials you just created.

![Sign In TASADMIN](images/sign-in-tas-workspace.png)
*Sign in to the specific workspace where the TAS applications will be hosted.*

## Task 4: Import the Admin App
The Admin App is the primary tool for administrators to manage search spaces and targets.

1. From the dashboard, navigate to the **App Builder**.

![Navigate to App Builder](images/navigate-to-app-builder.png)
*The App Builder is where you create and import APEX applications.*

2. Click the **Import** button.

![Import Choice](images/import-app.png)
*Select the Import option to load the TAS application packages.*

3. Upload the `admin.zip` file. Ensure the **File Character Set** is set to **Unicode UTF-8**.

![Upload Admin Zip](images/import-admin-app.png)
*Uploading the Admin App export file.*

4. On the **Install Application** page:
    * Verify the name is **Oracle Trusted Answer Search - Admin App**.
    * Select the **Parsing Schema** as **TASADMIN**.
    * Ensure **Build Status** is set to **Run Application Only**.
5. Click **Install Application**.

![Configure Admin App](images/configure-admin-app.png)
*Installation parameters for the Admin App.*

## Task 5: Import the Portal App
The Portal App provides a ready-to-use search interface for end-users.

1. Repeat the import steps from Task 4 using the `portal.zip` file.
2. Ensure it is installed into the same **TASADMIN** workspace and parsing schema as the Admin app.

![Configure Portal App](images/configure-portal-app.png)
*Installation parameters for the Portal App.*

## Task 6: Launch the Admin App
1. Once installation is complete, click the **Run Application** button.
2. Sign in using the **TASADMIN** username and the **TASADMIN_PASSWORD** you defined in your `install_backend.conf` file during the backend installation.


You have successfully installed the Trusted Answer Search applications! You may now **proceed to the next lab** to begin curating your search mapping.

## Acknowledgements
**Authors**
* Allen Hosler, Principal Product Manager, Database Applied AI

**Last Updated Date** - April, 2026
