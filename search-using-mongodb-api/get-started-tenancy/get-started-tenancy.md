# Get Started in Your OCI Tenancy

## Introduction

In this lab, sign in to your Oracle Cloud Infrastructure (OCI) tenancy. Locate an Autonomous AI Database with the MongoDB API enabled and open its SQL worksheet. Install MongoDB Shell in Cloud Shell. Then retrieve and verify the MongoDB API connection.

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

- Sign in to your OCI tenancy
- Locate an Autonomous AI Database and open its SQL worksheet
- Enable the MongoDB preview as an Autonomous AI Database administrator
- Allow the preview setting to propagate and reset MongoDB Shell connections
- Retrieve the MongoDB API connection string
- Install MongoDB Shell in OCI Cloud Shell
- Connect to the database and verify the MongoDB API endpoint

### Prerequisites

- An OCI free or paid tenancy
- An Autonomous AI Database with the MongoDB API enabled
- Autonomous AI Database administrator credentials
- A nonproduction schema or database dedicated to this workshop
- A supported web browser

> **Note:** Labs 1–3 create a `MOVIES` collection, load an ONNX model, and add search indexes. Do not use a production schema or a schema that already contains objects named `MOVIES` or `MULTILINGUAL_E5_BASE`.

## Task 1: Sign in to your OCI tenancy

1. Open [cloud.oracle.com](https://cloud.oracle.com).

2. Enter your cloud account name or tenancy name, then select **Next**.

3. Sign in with an OCI user that can access your Autonomous AI Database. If your tenancy uses single sign-on, select the identity provider shown on the sign-in page and complete that sign-in flow.

4. Confirm that the OCI Console region is the region that contains the database you will use for the workshop. Use the region selector in the Console header if necessary.

## Task 2: Locate the database and open SQL

1. Open the OCI navigation menu, select **Oracle AI Database**, and then select **Autonomous AI Database**.

    ![OCI navigation menu with Oracle AI Database and Autonomous AI Database highlighted](./images/navigate-to-autonomous-ai-database.png)

2. Select the compartment that contains your workshop database.

3. Open the database and confirm that its lifecycle state is **Available**.

4. Select **Database Actions**, and then open **SQL**.

5. Sign in to Database Actions as the Autonomous AI Database `ADMIN` user. You use this administrator session in the next task.

6. Keep the SQL worksheet open in a browser tab.

## Task 3: Prepare the embedding model in Object Storage

1. Download the multilingual E5-base archive provided for this workshop to your local computer:

    [Download multilingual E5-base ONNX model](https://objectstorage.us-ashburn-1.oraclecloud.com/p/SixA8FrMqul15N-qFEm5EsxusdyVzxEarw_GVAoNesn13VFy0EtdEsGUhtU0i8S8/n/adwc4pm/b/OML-ai-models/o/multilingual_e5_base_augmented.zip)

2. Extract the ZIP archive on your local computer and locate `multilingual_e5_base.onnx`.

    The embedding model shapes semantic-search results. Models represent meaning differently. More dimensions can capture finer distinctions and may improve results. This workshop uses the 768-dimension multilingual E5-base model. If you choose another model, use its dimension count for the checks and vector index.

    If you want to learn more, see [AI Vector Search Overview](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/overview-ai-vector-search.html).

3. Open the OCI navigation menu. Select **Storage**, then **Buckets**. Select the compartment that contains your database. Create or open a bucket for the model. Upload the extracted `multilingual_e5_base.onnx` file, not the ZIP archive.

    ![OCI navigation menu with Storage and Buckets highlighted](./images/open-object-storage-buckets.png)

4. Open the menu for `multilingual_e5_base.onnx` and select **Create Pre-Authenticated Request**. Allow **Object Read** access. Set an expiry date after your workshop session, then copy the PAR URL.

5. Keep the PAR URL available. In Lab 1, replace `<multilingual-e5-base-onnx-model-url>` with this URL so Autonomous AI Database can load the model.

## Task 4: Enable the MongoDB preview

1. Confirm that you are signed in to Database Actions as the Autonomous AI Database `ADMIN` user.

2. Run the following block to enable the MongoDB preview:

    ```sql
    BEGIN
      ords_admin.set_property(
        p_key   => 'mongo.preview',
        p_value => 'true'
      );
      COMMIT;
    END;
    /
    ```

    Keep `true` lowercase and enclosed in single quotation marks.

3. Only an Autonomous AI Database administrator can run this block. The property name and value are case-sensitive: use `mongo.preview` and lowercase `'true'`. If you do not have administrator credentials, stop and ask an administrator to run it before you continue.

4. Disconnect any existing MongoDB API client sessions, including `mongosh`. New connections read the updated setting; existing connections do not.

5. You can connect immediately after setting the property. It may take up to 15 minutes for the setting to apply across the database.

## Task 5: Retrieve the MongoDB API connection string

1. Return to the Autonomous AI Database details page.

2. Select the **Tool configuration** tab.

3. Locate **MongoDB API**, and then select **Copy** under **Access URL**.

    ![Autonomous AI Database Tool configuration tab with MongoDB API access URL highlighted](./images/copy-mongodb-api-url.png)

4. Paste the connection string into a temporary text editor. It has the following shape:

    ```text
    mongodb://[user:password@]<adb-host>:27017/[user]?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true
    ```

5. If **MongoDB API** is unavailable, select **Edit tool configuration**. Enable the **MongoDB API** row and select **Apply**. Wait for the database to return to **Available**, then copy the access URL. Configure network access through an ACL or private endpoint.

6. Keep the temporary copy available for Task 7. Do not share or publish the completed connection string after you add the password.

## Task 6: Install MongoDB Shell in Cloud Shell

**NOTE**: MongoDB Shell is a tool provided by MongoDB Inc. Oracle is not associated with MongoDB Inc, and has no control over the software. These instructions are provided simply to help you learn about MongoDB Shell. Links may change without notice.

Check the official MongoDB download website for latest versions and instructions, e.g.:

[https://www.mongodb.com/try/download/shell](https://www.mongodb.com/try/download/shell)

1. In the OCI Console header, select the **Cloud Shell** icon and wait for the terminal to open.

    ![OCI Console header with the Cloud Shell menu option highlighted](./images/open-cloud-shell.png)

2. Create a directory for MongoDB Shell and change to that directory.

    ```bash
    mkdir -p $HOME/mongosh
    cd $HOME/mongosh
    ```

3. Check the Cloud Shell processor architecture.

    ```bash
    uname -m
    ```

    Use `x86_64` for an Intel or AMD Cloud Shell. Use `aarch64` for an ARM Cloud Shell.

4. Download the matching MongoDB Shell 2.9.2 archive.

    For `x86_64`:

    ```bash
    curl -L https://downloads.mongodb.com/compass/mongosh-2.9.2-linux-x64.tgz -o mongosh.tgz
    ```

    For `aarch64`:

    ```bash
    curl -L https://downloads.mongodb.com/compass/mongosh-2.9.2-linux-arm64.tgz -o mongosh.tgz
    ```

5. Extract the archive.

    ```bash
    tar -xzf mongosh.tgz --strip-components=1
    ```

6. Add MongoDB Shell to `PATH` for the current Cloud Shell session.

    ```bash
    export PATH="$HOME/mongosh/bin:$PATH"
    ```

7. Verify the installation.

    ```bash
    mongosh --version
    ```

8. Confirm that the command returns version `2.9.2`. An `Exec format error` means you downloaded the wrong architecture. Download and extract the other archive, then retry. If you close Cloud Shell, run the `export PATH` command after reopening it.

## Task 7: Complete the connection string and connect

1. In your temporary text editor, replace `[user:password@]` with `<database-user>:<encoded-password>@`.

2. Replace `[user]` after port `27017` with the same database user name.

3. Percent-encode any reserved characters in the database password before placing it in the URI. Use these common replacements:

    - Replace `#` with `%23`.
    - Replace `$` with `%24`.
    - Replace `%` with `%25`.
    - Replace `&` with `%26`.
    - Replace `/` with `%2F`.
    - Replace `:` with `%3A`.
    - Replace `?` with `%3F`.
    - Replace `@` with `%40`.

4. Review this fictional example. It uses database user `MOVIE_LAB` and database password `Welcome#123`, encoded as `Welcome%23123`:

    ```text
    mongodb://MOVIE_LAB:Welcome%23123@moviesdb.adb.us-ashburn-1.oraclecloudapps.com:27017/MOVIE_LAB?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true
    ```

5. In Cloud Shell, run `mongosh` followed by your completed connection string in single quotation marks.

    ```bash
    mongosh 'mongodb://<database-user>:<encoded-password>@<adb-host>:27017/<database-user>?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true'
    ```

    Replace `<database-user>`, `<encoded-password>`, and `<adb-host>` with your values. Keep the entire command on one line. Single quotation marks prevent Cloud Shell from interpreting `$external` as a shell variable.

6. Wait for the MongoDB Shell prompt. If you were already connected before the preview setting changed, exit that session and run this command again. Do not save, share, or capture a screenshot of the completed connection string.

## Task 8: Verify the connection

1. At the MongoDB Shell prompt, send a ping command.

    ```javascript
    db.runCommand({ ping: 1 })
    ```

2. Confirm that the result contains:

    ```javascript
    { ok: 1 }
    ```

3. Display the current database name and the available collections.

    ```javascript
    db.getName()
    show collections
    ```

4. Confirm that the current database is the database user name you placed in the URI. The collection list can be empty because Lab 1 loads the `MOVIES` collection.

5. Keep Cloud Shell and the SQL worksheet open. You use both in Lab 1.

You are ready to proceed to Lab 1, where you load and verify the movie search environment.

## Learn More

- [Using Oracle AI Database API for MongoDB](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/mongo-using-oracle-database-api-mongodb.html)
- [MongoDB Shell Download](https://www.mongodb.com/try/download/shell)
- [OCI Cloud Shell](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/cloudshellintro.htm)
- [AI Vector Search Overview](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/overview-ai-vector-search.html)

## Acknowledgements

- **Author** - Gael Palomino
- **Last Updated By/Date** - Gael Palomino, August 2026
