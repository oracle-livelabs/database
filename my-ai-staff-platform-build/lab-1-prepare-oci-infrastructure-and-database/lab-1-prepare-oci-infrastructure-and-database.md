# Prepare OCI Infrastructure and Database

## Introduction

In this lab, you will prepare the base OCI environment and database foundation for My AI Staff. You will create compute and network resources, configure DNS, provision Autonomous Database 26ai, load the schema, and validate in-database vector embeddings.

Estimated Time: 90 minutes

### Objectives

In this lab, you will:

- Create OCI compute and ingress rules for secure access.
- Configure DNS for the editor endpoint.
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
3. Reserve a static public IP for the instance.
4. In the VCN security list, allow inbound access for port 22 only from your administration network, and ports 80 and 443 for the editor endpoint.
5. On the instance, open HTTP/HTTPS services in firewalld.

    ```
    <copy>
    sudo firewall-cmd --permanent --add-service=http --add-service=https
    sudo firewall-cmd --reload
    </copy>
    ```

6. Keep agent ports 8001 through 8005 loopback-only and do not expose them publicly. nginx is the public reverse proxy; internal services bind to `127.0.0.1`.

## Task 2: Configure DNS for the Editor Host

1. Add an A record at your domain registrar: editor.<your-domain> -> your instance public IP.
2. Use a low TTL while configuring.
3. Validate DNS propagation from the instance.

    ```
    <copy>
    dig editor.<your-domain> +short
    </copy>
    ```

4. Confirm that the command returns the expected public IP.

## Task 3: Provision Autonomous Database 26ai

1. In OCI Console, create an Autonomous Database with workload type Transaction Processing.
2. Choose Always Free and Oracle Database 26ai.
3. Enable secure access and download the wallet.
4. Copy the wallet zip file to the compute instance and extract it under the deployment user's home directory.

    ```
    <copy>
    mkdir -p ~/oracle/wallet
    unzip ~/wallet_<db-name>.zip -d ~/oracle/wallet
    ls ~/oracle/wallet/{sqlnet.ora,tnsnames.ora,cwallet.sso}
    </copy>
    ```

5. Verify the extracted wallet files include sqlnet.ora and tnsnames.ora.

## Task 4: Create Application Schema and Load DDL

1. Connect to the database as ADMIN using SQL Developer Web or SQLcl.
2. Create the AI_FOR_YOU schema.

    ```
    <copy>
    CREATE USER AI_FOR_YOU IDENTIFIED BY "<strong-password>";
    GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE VIEW TO AI_FOR_YOU;
    ALTER USER AI_FOR_YOU QUOTA UNLIMITED ON DATA;
    </copy>
    ```

3. Set the current schema, then run `schema/ai_for_you_full_ddl.sql` from the platform repository, top to bottom.
4. Do not run `agents/data/migrations/` for a new deployment: the files are historical changes already folded into the snapshot. Leave the marked `OAM_*` and `REMINDERS` objects to their owning runtime components.
5. Ensure table, foreign key, and index creation complete successfully.

## Task 5: Load and Validate the ONNX Embedding Model

1. As ADMIN, load the all-MiniLM-L12-v2 ONNX model into Oracle Database with model name MINILM_V2.
2. Validate model availability with a VECTOR_EMBEDDING test query.

    ```
    <copy>
    SELECT VECTOR_EMBEDDING(ADMIN.MINILM_V2 USING 'hello' AS data) FROM DUAL;
    </copy>
    ```

3. Confirm the query returns a vector. The Data Agent memory endpoints require this model; if it is omitted, recall fails after the rest of the platform appears healthy.

## Acknowledgements

- Author: CYRCE SALINAS ROJAS
