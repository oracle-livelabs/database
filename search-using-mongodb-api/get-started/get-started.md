# Get Started with Your LiveLabs Sandbox

## Introduction

In this lab, sign in to the OCI Console with your LiveLabs Sandbox credentials. Locate the provisioned Autonomous AI Database and open its SQL worksheet. Install MongoDB Shell in Cloud Shell. Then retrieve and verify the MongoDB API connection.

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

- Access the OCI Console with the credentials supplied by LiveLabs
- Locate the provisioned Autonomous AI Database and open its SQL worksheet
- Retrieve the MongoDB API connection string
- Install MongoDB Shell in OCI Cloud Shell
- Connect to the database and verify the MongoDB API endpoint

### Prerequisites

- An active LiveLabs Sandbox reservation
- The OCI and database credentials shown under **View Login Info**
- A supported web browser

## Task 1: Access the OCI Console

1. Return to your LiveLabs reservation and select **View Login Info**.

2. Record the values supplied for your environment:

    - Cloud account or tenancy name
    - OCI username
    - OCI password
    - OCI region
    - Autonomous AI Database `ADMIN` password, if listed separately

    The OCI password signs you in to the cloud console. The database `ADMIN` password authenticates SQL and MongoDB API connections. Treat them as separate credentials even if the sandbox assigns the same value to both.

3. Select **Launch OCI**. If that option is not available, open [cloud.oracle.com](https://cloud.oracle.com) in a new browser tab.

4. Enter the cloud account or tenancy name from **View Login Info**.

5. Use OCI direct sign-in with the supplied username and password.

6. Confirm that the region displayed in the OCI Console matches the region assigned to your sandbox.

## Task 2: Locate the database and open SQL

1. Open the OCI navigation menu, select **Oracle AI Database**, and then select **Autonomous AI Database**.

    ![OCI navigation menu with Oracle AI Database and Autonomous AI Database highlighted](./images/navigate-to-autonomous-ai-database.png)

2. Select the compartment supplied for your LiveLabs Sandbox.

3. Open the provisioned Autonomous AI Database and confirm that its lifecycle state is **Available**.

4. Select **Database Actions**, and then open **SQL**.

    ![Autonomous AI Database details page with the Database Actions menu open and SQL selected](./images/open-database-actions.png)

5. Keep the SQL worksheet open in a browser tab. You use it in Lab 1.

## Task 3: Prepare the embedding model in Object Storage

1. Download the multilingual E5-base archive provided for this workshop to your local computer:

    [Download multilingual E5-base ONNX model](https://objectstorage.us-ashburn-1.oraclecloud.com/p/SixA8FrMqul15N-qFEm5EsxusdyVzxEarw_GVAoNesn13VFy0EtdEsGUhtU0i8S8/n/adwc4pm/b/OML-ai-models/o/multilingual_e5_base_augmented.zip)

2. Extract the ZIP archive on your local computer and locate `multilingual_e5_base.onnx`.

    The embedding model shapes semantic-search results. Models represent meaning differently. More dimensions can capture finer distinctions and may improve results. This workshop uses the 768-dimension multilingual E5-base model. If you choose another model, use its dimension count for the checks and vector index.

    If you want to learn more, see [AI Vector Search Overview](https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/overview-ai-vector-search.html).

3. Open the OCI navigation menu. Select **Storage**, then **Buckets**. Select the workshop compartment. Create or open a bucket for the model. Upload the extracted `multilingual_e5_base.onnx` file, not the ZIP archive.

    ![OCI navigation menu with Storage and Buckets highlighted](./images/open-object-storage-buckets.png)

4. Open the menu for `multilingual_e5_base.onnx` and select **Create Pre-Authenticated Request**. Allow **Object Read** access. Set an expiry date after your workshop session, then copy the PAR URL.

5. Keep the PAR URL available. In Lab 1, replace `<multilingual-e5-base-onnx-model-url>` with this URL so Autonomous AI Database can load the model.

## Task 4: Retrieve the MongoDB API connection string

1. Return to the Autonomous AI Database details page.

2. Select the **Tool configuration** tab.

3. Locate **MongoDB API**, and then select **Copy** under **Access URL**.

    ![Tool configuration page with the MongoDB API access URL and Copy button highlighted](./images/copy-mongodb-api-url.png)

4. Paste the connection string into a temporary text editor. It has the following shape:

    ```text
    mongodb://[user:password@]<adb-host>:27017/[user]?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true
    ```

5. Keep this temporary copy available for Task 6. Do not share or publish the completed connection string after you add the password.

## Task 5: Install MongoDB Shell in Cloud Shell

**NOTE**: MongoDB Shell is a tool provided by MongoDB Inc. Oracle is not associated with MongoDB Inc, and has no control over the software. These instructions are provided simply to help you learn about MongoDB Shell. Links may change without notice.

Check the official MongoDB download website for latest versions and instructions, e.g.:

[https://www.mongodb.com/try/download/shell](https://www.mongodb.com/try/download/shell)

1. In the OCI Console header, select the **Cloud Shell** icon and wait for the terminal to open.

    ![OCI Console with Cloud Shell open at the bottom of the page](./images/open-cloud-shell.png)

2. Create a directory for MongoDB Shell and change to that directory.

    ```bash
    mkdir -p $HOME/mongosh
    cd $HOME/mongosh
    ```

3. Download the MongoDB Shell 2.9.2 archive for Linux x64.

    ```bash
    curl https://downloads.mongodb.com/compass/mongosh-2.9.2-linux-x64.tgz -o mongosh.tgz
    ```

4. Extract the archive.

    ```bash
    tar -xzf mongosh.tgz --strip-components=1
    ```

5. Add MongoDB Shell to `PATH` for the current Cloud Shell session.

    ```bash
    export PATH="$HOME/mongosh/bin:$PATH"
    ```

6. Verify the installation.

    ```bash
    mongosh --version
    ```

7. Confirm that the command returns version `2.9.2`. If you close Cloud Shell during this workshop, run the `export PATH` command again after reopening it.

## Task 6: Complete the connection string and connect

1. In your temporary text editor, replace `[user:password@]` with `ADMIN:<encoded-password>@`.

2. Replace `[user]` after port `27017` with `admin`.

3. Percent-encode any reserved characters in the database password before placing it in the URI. Use these common replacements:

    - Replace `#` with `%23`.
    - Replace `$` with `%24`.
    - Replace `%` with `%25`.
    - Replace `&` with `%26`.
    - Replace `/` with `%2F`.
    - Replace `:` with `%3A`.
    - Replace `?` with `%3F`.
    - Replace `@` with `%40`.

4. Review this fictional example. It uses database password `Welcome#123`, encoded as `Welcome%23123`:

    ```text
    mongodb://ADMIN:Welcome%23123@moviesdb.adb.us-ashburn-1.oraclecloudapps.com:27017/admin?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true
    ```

5. In Cloud Shell, run `mongosh` followed by your completed connection string in single quotation marks.

    ```bash
    mongosh 'mongodb://ADMIN:<encoded-password>@<adb-host>:27017/admin?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true'
    ```

    Replace `<encoded-password>` and `<adb-host>` with the values from your sandbox. Keep the entire command on one line. Single quotation marks prevent Cloud Shell from interpreting `$external` as a shell variable.

6. Wait for the MongoDB Shell prompt. Do not save, share, or capture a screenshot of the completed connection string.

## Task 7: Verify the connection

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

4. Confirm that the current database is `admin`. The collection list can be empty because Lab 1 loads the `MOVIES` collection.

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
