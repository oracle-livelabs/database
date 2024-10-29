# Create a Low Code Application with Oracle APEX and REST SERVICES for MySQL

![mysql heatwave](./images/mysql-heatwave-logo.jpg "mysql heatwave")

## Introduction

The Oracle Database Development Tools team launched the Database Tools service in OCI providing instance web browser to create connections to the MySQL Database Service in OCI.

Using APEX, developers can quickly develop and deploy compelling apps that solve real problems and provide immediate value. You don't need to be an expert in a vast array of technologies to deliver sophisticated solutions. Focus on solving the problem and let APEX take care of the rest. [https://apex.oracle.com/en/platform/why-oracle-apex/](https://apex.oracle.com/en/platform/why-oracle-apex/)

**Tasks Support Guides**
- [https://medium.com/oracledevs/get-insight-on-mysql-data-using-apex](https://medium.com/oracledevs/get-insight-on-mysql-data-using-apex-22-1-7fe613c76ca5)
- [https://peterobrien.blog/2022/06/15/](https://peterobrien.blog/2022/06/15/)
- [https://peterobrien.blog/2022/06/15/how-to-use-the-oracle-database-tools-service-to-provide-data-to-apex/](https://peterobrien.blog/2022/06/15/how-to-use-the-oracle-database-tools-service-to-provide-data-to-apex/)

_Estimated Time:_ 30 minutes

### Objectives

In this lab, you will be guided through the following task:

- Setup Identity and Security tools and services
- Configure a Private Connection
- Create and configure an APEX Instance
- Configure APEX Rest Service

### Prerequisites

- An Oracle Trial or Paid Cloud Account
- Some Experience with OCI Console
- Some Experience with Oracle Autonomous and Oracle APEX
- Completed Lab 8

## Task 1 Setup Identity & Security tools in OCI to Create a Secret

1. From the OCI Menu, navigate to **Identity & Security** and click **Vault**

    ![Identity & Security Vault](./images/OCI-menu-vault.png "OCI-menu-vault ")

2. Create a Vault

    a. Click **Create Vault**

    ![Create Vault](./images/create-vault.png "create-vault ")

    b. Select the movies compartment

    c. Give the vault a name

    ```bash
    <copy> HW-DB </copy>
    ```

    d. Click **Create Vault**

3. Create a Master Encryption Key

    a. Click on the newly created Vault

    b. Click **Create Key**

    ![Create Master Encryption Key](./images/vault-menu-create-key.png "vault-menu-create-key ")

    c. Select the movies compartment

    d. Give the key a name

    ```bash
    <copy> HW-DB </copy>
    ```

    e. Leave the rest configurations in default values

    ![Create Key Details](./images/create-key-details.png "create-key-details ")

    f. Click **Create Key**

4. Create a Secret

    a. Click on **Secrets** to navigate to the secrets panel

    ![Navigate to Secrets Panel](./images/navigate-secret-panel.png =60%x* "navigate-secret-panel ")

    b. Click **Create Secret**

    ![Create Secrets Panel](./images/create-secret-panel.png "create-secret-panel ")

    c. Select the movies compartment

    d. Give the secret a name

    ```bash
    <copy> HW-DB </copy>
    ```

    e. Select the created Encryption Key

    f. In **Secret Contents**, write the password for the admin user created for your MySQL HeatWave DB System

    ![Create Secrets details](./images/create-secret-details.png "create-secret-details ")

    g. Leave the rest configurations in default values

    h. Click **Create Secret**

## Task 2 Configure a Private Connection

1. From the OCI Menu, navigate to **Developer Services** and click **Connections**

    ![Developer Services Connections](./images/oci-developer-services-menu-connections.png "oci-developer-services-menu-connections ")

2. Create a Private Endpoint

    a. Navigate to Private Endpoints and click **Create private endpoint**

    ![Create Private Endpoint Panel](./images/create-private-endpoint.png "create-private-endpoint-panel ")

    b. Give the Endpoint a name

    ```bash
    <copy> HW-MovieHub-endpoint </copy>
    ```

    c. Select the movies compartment

    d. Select **Enter network information**

    e. Select the **private subnet** from the movies compartment

    ![Create Private Endpoint Details](./images/create-private-endpoint-details.png "create-private-endpoint-details ")

    f. Click **Create**

3. Create a Connection

    a. Navigate to Connections and click **Create connection**

    ![Create Connection Panel](./images/create-connection-panel.png "create-connection-panel ")

    b. Give the Endpoint a name

    ```bash
    <copy> HW-MovieHub-Connection </copy>
    ```

    c. Select the movies compartment

    d. Select **Select database** option

    e. Select **MySQL Database** for Database cloud service

    f. Introduce the MySQL DB System created administrator user

    g. Select the created secret that contains the matching mysql password

    ![Create Connection Details](./images/create-connection-details.png "create-connection-details ")

    h. Click **Next** and **Create**

## Task 3 Run SQL Worksheet

1. From the OCI Menu, navigate to **Developer Services** and click **SQL Worksheet**

    ![Developer Services SQL Worksheet](./images/OCI-developer-services-sql-worksheets.png "OCI-developer-services-sql-worksheets ")

2. Select the movies compartment and the created **HW-MovieHub-Connection**

3. You can run SQL queries, in the SQL Worksheet.

    a. List the schemas

    ```bash
    <copy> SHOW SCHEMAS;</copy>
    ```

4. Get the MySQL Connection Endpoint URL

    The OCI Services connect to the MySQL DB System though the created Connection. This Connection Endpoint Consists of a URL Pattern:

    **Note** The pattern is `https://sql.dbtools.< region >.oci.oraclecloud.com/20201005/ords/< connection ocid >/_/sql`

    **Example** <https://sql.dbtools.us-ashburn-1.oci.oraclecloud.com/20201005/ords/ocid1.databasetoolsconnection.oc1.iad.amaaaaaao27h4wiamnbgbmuznwvg4nenu4j7nzbecnvpmzgs2fkgiugwueyq/_/sql>

    This URL can be also obtained by retrieving it from the network logs from the developer console in a Web Browser.

    a. Open the Developer Console from your web browser. This can be done by right clicking on the page and clicking **inspect/inspect element**

    ![inspect developer console](./images/inspect-developer-console.png =70%x* "inspect-developer-console ")

    b. In the developer **console** tab, look up for **dbtools-sqldev__LogEvent**. There you can click on the object to see its details

    ![inspect connection object url](./images/inspect-url-connection-endpoint.png "inspect-url-connection-endpoint ")

    c. The Endpoint URL will be visible. Right Click to Copy the Link

    ![inspect copy object url](./images/inspect-copy-url.png "inspect-copy-url ")

    d. Notice the pattern of the URL

    e. Save the Endpoint URL for later

## Task 4 Create API Keys

1. From the OCI Menu, navigate to **Identity & Security** and click **Domains**

    ![oci identity security domains](./images/oci-identity-security-domains.png "oci-identity-security-domains ")

2. Click on **Default** domain and navigate to **Users**

    ![domains default user](./images/domains-default-user.png "domains-default-user ")

3. Click on your current user

    ![Create API Key](./images/user-panel-create-apikey.png "user-panel-create-apikey ")

4. Click **Add API Key**

5. Save the generated API Key Pair

    ![Add API Key](./images/add-api-key.png "add-api-key ")

6. Save the content of the Configuration file preview by **copying** it. Then click **Close**

    ![Configuration file preview](./images/api-config-fingerprint.png "api-config-fingerprint ")

    **Notice the Values for your Username, Tenancy, Region, Fingerprint**

## Task 5 Create and Configure an APEX Instance

1. Create and Launch APEX

    a.
    ![start apex deploy](./images/start-apex-deploy.png "start apex deploy ")
    ![continue apex deploy](./images/continue-apex-deploy.png "continue apex deploy ")
    b. Choose movies compartment and set APEX password
    ![set apex password](./images/set-password-apex-deploy.png "set apex password")
    ![completed apex deploy](./images/completed-apex-deploy.png "completed apex deploy")

2. Create Workspace

    a.
    ![login apexd](./images/login-apexd.png "login apexd ")

    ![create apex workspace](./images/create-apex-workspace.png "create apex workspace" )
    b. Name the APEX workspace

    ```bash
    <copy> heatwave-movies </copy>
    ```

    c. Set an Admin user and password for the workspace
    ![name apex workspace](./images/name-apex-workspace.png "name apex workspace")
    d. Log out from APEX
    ![apex logout](./images/apex-logout.png "apex logout")


## Task 6 Create APEX Credentials

1. Create Web Credentials

    a. Log In to the APEX Workspace
    ![Log in APEX workspace](./images/log-in-apex-workspace.png "log-in-apex-workspace ")
    b. Navigate to the Workspace Utilities from the App Builder Menu
    ![Workspace Utilities](./images/apex-menu-workspace-utilities.png "apex-menu-workspace-utilities ")
    c. Click on **Web Credentials**
    ![workspace utilities web credential](./images/workspace-utilities-web-credentials.png "workspace-utilities-web-credentials ")

    d. You can obtain the OCID values and fingerprint from the **Configuration File Preview** generated with the API Key or retrieve them from the OCI Console. Open the Private Key file in a text editor to copy the content.

    | Attributes | Value |
    | --------| -------:|
    | Name | mysqlheatwave |
    | Static ID | mysqlheatwave |
    | Authentication Type | OCI Native Authentication |
    | OCI User ID | **< YourUserOCID >** |
    | OCI Private Key | **< ContentOfYourSavedPrivateKey >** |
    | OCI Tenancy ID | **< YourTenancyOCID >** |
    | OCI Public Key Fingerprint | **< YourPublicKeyFingerprint >** |
    | Valid for URLs | **< EndpointURL >** |
    {: title="Web Credentials \| Attributes"}

    e. Create new Web Credentials. Click **Create**
    ![apex web credentials ](./images/apex-web-credentials.png "apex web credentials")

## Task 7 Create APEX Rest Service

1. Navigate to the Workspace Utilities from the App Builder Menu
    ![Workspace Utilities](./images/apex-menu-workspace-utilities.png "apex-menu-workspace-utilities ")

2. Click on **REST Enabled SQL Services**
    ![workspace utilities rest services](./images/workspace-utilities-rest-services.png "workspace-utilities-rest-services ")

3. Click **Create**

    ![Create rest services](./images/rest-service-create.png "rest-service-create ")

4. Give the REST service a name

    ```bash
    <copy> MovieHub-moviesdb </copy>
    ```

5. For Endpoint URL, Introduce the Endpoint URL **without** the "**`/_/sql`**" at the end. Notice the help message.

6. Click **Next**

7. Select the previously created credentials. Click **Create**

    ![rest services credentials](./images/rest-service-credentials.png "rest-service-credentials ")

8. If previous steps were performed correctly, you should see a successful connection. Select the default database **movies**

    ![rest services successful connection](./images/rest-service-success.png "rest-service-success ")


You may now **proceed to the next lab**

## Learn More

- How to use the Oracle Database Tools Service to provide MySQL data to APEX - [APEX and the MySQL Database Service](https://asktom.oracle.com/pls/apex/asktom.search?oh=18245)

- [Oracle Autonomous Database Serverless Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/index.html#Oracle%C2%AE-Cloud)

- [Using Web Services with Oracle APEX Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/apex-web-services.html#GUID-DA24C605-384D-4448-B73C-D00C02F5060E)


## Acknowledgements

- **Author** - Cristian Aguilar, MySQL Solution Engineering
- **Contributors** - Perside Foster, MySQL Principal Solution Engineering
- **Last Updated By/Date** - Cristian Aguilar, MySQL Solution Engineering, November 2024
