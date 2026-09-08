# Prepare OCI Infrastructure and Database

## Introduction

In this lab, you will prepare the base OCI environment and database foundation for My AI Staff. You will create compute and network resources, provision Autonomous Database 26ai, load the schema, and validate in-database vector embeddings.

Estimated Time: 90 minutes

### Objectives

In this lab, you will:

- Create OCI compute and ingress rules for secure access.
- Provision Autonomous Database 26ai and wallet files.
- Create the AI FOR YOU schema and load the application DDL.
- Load and validate the MiniLM ONNX embedding model.

### Prerequisites

- Completion of the workshop Introduction.
- OCI tenancy access with permissions to create compute and database resources.
- SSH key pair ready for instance access.

## Task 1: Create Compute and Network Access

1. In OCI Console, create one Oracle Linux 9 ARM instance using shape VM.Standard.A1.Flex 
    (If not available choose a similar Shape, check documentation for more info [here](https://docs.oracle.com/es-ww/iaas/Content/Compute/References/computeshapes.htm#flexible)).
2. Configure the instance to use 4 OCPUs and 24 GB memory.
3. In the VCN security list, allow inbound access for port 22 only from your administration network.
4. Keep agent ports 8001 through 8005 loopback-only and do not expose them publicly. The runtime services bind to `127.0.0.1`.

    ![Where to Create a Compute Instance](./images/01_create_instance.png)

## Task 2: Provision Autonomous Database 26ai

1. In OCI Console, create an Autonomous Database with workload type Transaction Processing.
    ![Where to Create an Autonomous Database](./images/02_create_database.png)

2. Choose Always Free and Oracle Database 26ai.
3. Enable secure access and download the wallet.
    ![Where to Download a Wallet](./images/03_wallet_download.png)
4. Copy the wallet zip file to the compute instance and extract it under the deployment user's home directory.

    ```
    <copy>
    mkdir -p ~/oracle/wallet
    unzip ~/wallet_<db-name>.zip -d ~/oracle/wallet
    ls ~/oracle/wallet/{sqlnet.ora,tnsnames.ora,cwallet.sso}
    </copy>
    ```

5. Verify the extracted wallet files include `sqlnet.ora`, `tnsnames.ora`, `cwallet.sso`, `ewallet.p12`, and `ewallet.pem`.

6. Record the wallet directory as `ADB_WALLET_DIR` for Lab 3. The agents pass the database ADMIN password as the wallet passphrase because `ewallet.pem` is passphrase-protected; do not confuse it with the separate password used when downloading the wallet zip.

## Task 3: Create Application Schema and Load DDL

1. Connect to the database as ADMIN using SQL Developer Web or SQLcl.
    ![Where to Enter SQL Actions](./images/04_sql_actions.png)
2. Create the AI_FOR_YOU schema.

    ```
    <copy>
    CREATE USER AI_FOR_YOU IDENTIFIED BY "<strong-password>";
    GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE VIEW TO AI_FOR_YOU;
    ALTER USER AI_FOR_YOU QUOTA UNLIMITED ON DATA;
    </copy>
    ```

3. Set the current schema before you run application DDL. The platform connects as `admin` and uses `ALTER SESSION SET CURRENT_SCHEMA = AI_FOR_YOU`; keep that convention unless you also update every database module.

    ```
    <copy>
    ALTER SESSION SET CURRENT_SCHEMA = AI_FOR_YOU;
    </copy>
    ```

4. Run `schema/ai_for_you_full_ddl.sql` from the platform repository, top to bottom. The file is the current schema snapshot for a fresh deployment, not a migration sequence.
5. Do not run `agents/data/migrations/` for a new deployment: the files are historical changes already folded into the snapshot.
6. Skip only the DDL blocks marked in the file for `OAM_*` and `REMINDERS`. The memory package creates `OAM_*` objects on first memory use, and Assistant Agent creates `REMINDERS` on first reminder use.
7. Run the remaining content pipeline tables, `AISTAFF_*` tables, `AGENT_*` memory tables, foreign keys, duality views, and indexes. The `*_SUB_UX` unique indexes are required for public-intake idempotency.
8. Ensure table, foreign key, duality view, and index creation complete successfully.

## Task 4: Load and Validate the ONNX Embedding Model

1. As ADMIN, load the all-MiniLM-L12-v2 ONNX model into Oracle Database with model name MINILM_V2.
2. Validate model availability with a VECTOR_EMBEDDING test query.

    ```
    <copy>
    SELECT VECTOR_EMBEDDING(ADMIN.MINILM_V2 USING 'hello' AS data) FROM DUAL;
    </copy>
    ```

3. Confirm the query returns a vector. The Data Agent memory endpoints require this model; if it is omitted, recall fails after the rest of the platform appears healthy.

## Acknowledgements

- Authors: Cyrce Salinas Rojas and Ilan Gomez Guerrero
- Last Updated: Ilan Gomez Guerrero, September 2026
