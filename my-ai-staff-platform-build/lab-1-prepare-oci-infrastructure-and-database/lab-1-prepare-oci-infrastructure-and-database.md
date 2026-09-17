# Lab 1: Prepare OCI Infrastructure and Database (Manual Path)

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
- A laptop with an SSH client. macOS and most Linux distributions include OpenSSH. Windows users can use PowerShell with OpenSSH, Windows Terminal, or VS Code Remote - SSH. You will create or download the SSH key and configure the connection after the instance is created and its public IP is assigned.
- A browser for OCI Console and SQL Developer Web, or SQLcl installed on the instance.

## Task 1: Create Compute and Network Access

1. In [OCI Console](https://www.oracle.com/latam/cloud/sign-in.html), create one Oracle Linux 9 ARM instance using shape VM.Standard.A1.Flex
    (If not available choose a similar Shape, check documentation for more info [here](https://docs.oracle.com/es-ww/iaas/Content/Compute/References/computeshapes.htm#flexible)).

    ![Where to Create a Compute Instance](./images/01_create_instance.png)

    ![Image Selection Example](./images/08_image_instance.png)

2. Configure the instance to use 4 OCPUs and 24 GB memory.

    ![Shape Selection Example](./images/08_instance_shape.png)

    ![Shape Details](./images/09_shape_details.png)

3. Under **Add SSH keys**, choose **Generate a key pair** and download the private key immediately, or upload a public key that you already control. OCI needs the public key during launch; the connection configuration happens after the instance is created.

    ![Example to Generate SSH Keys](./images/10_ssh_keys.png)

4. Find the security list for the instance subnet. In OCI Console, open the running instance, locate the **Primary VNIC** or **Subnet** link, open the subnet, and then open its attached **Security Lists**.

    ![Click into Instance Details](./images/11_instance_details.png)

    ![Where to Access Instance Subnet](./images/12_subnet_click.png)

    ![Where is the Security Lists](./images/05_security_list.png)

5. Add an **Ingress Rule**, not an egress rule, for SSH access. Use these values:

    ![Where to add Ingress Rules](./images/06_ingress_rules.png)

    | Field | Value |
    | --- | --- |
    | Source type | CIDR |
    | Source CIDR | Your administration network, preferably your laptop public IP as `<your-public-ip>/32` |
    | IP protocol | TCP |
    | Destination port range | `22` |
    | Description | `SSH from administrator workstation` |

    Leave the default egress rules unchanged unless your tenancy has a custom network policy. Egress controls outbound traffic from the instance; SSH access from your laptop uses an ingress rule.

6. Do not add ingress rules for ports `8001` through `8005`. These are internal agent service ports.

    Loopback-only means the services listen on `127.0.0.1`, which is the instance's local-only network address. A service bound to `127.0.0.1:8002` can be reached from the same VM with `curl http://127.0.0.1:8002/health`, but it is not reachable from the public internet. Keep these ports closed in OCI security lists and on the instance firewall.

7. After the instance reaches **Running** state, copy its public IP from OCI Console. Open the instance details page and locate **Primary VNIC** > **Public IPv4 address**. If the instance has no public IP, edit the VNIC or recreate the instance in a public subnet with public IP assignment enabled.

8. Configure the downloaded key on your laptop. Use the command set that matches your operating system, and replace the placeholder values.

    For macOS or Linux, open Terminal and run:

    ```bash
    <copy>
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    mv ~/Downloads/<downloaded-private-key> ~/.ssh/my-ai-staff-oci.key
    chmod 600 ~/.ssh/my-ai-staff-oci.key
    </copy>
    ```

    Add this host entry to `~/.ssh/config`:

    ```ssh
    Host my-ai-staff-oci
        HostName <instance-public-ip>
        User opc
        IdentityFile ~/.ssh/my-ai-staff-oci.key
        IdentitiesOnly yes
    ```

    Test the connection:

    ```bash
    <copy>
    ssh my-ai-staff-oci
    </copy>
    ```

    For Windows, open PowerShell or Windows Terminal and run:

    ```powershell
    <copy>
    mkdir $env:USERPROFILE\.ssh
    move $env:USERPROFILE\Downloads\<downloaded-private-key> $env:USERPROFILE\.ssh\my-ai-staff-oci.key
    icacls $env:USERPROFILE\.ssh\my-ai-staff-oci.key /inheritance:r
    icacls $env:USERPROFILE\.ssh\my-ai-staff-oci.key /grant:r "$env:USERNAME:R"
    ssh -i $env:USERPROFILE\.ssh\my-ai-staff-oci.key opc@<instance-public-ip>
    </copy>
    ```

    If Windows reports that `ssh` is not recognized, install the OpenSSH Client optional feature or use VS Code Remote - SSH.

9. In VS Code, open the Command Palette, choose **Remote-SSH: Connect to Host**, and select `my-ai-staff-oci`. Edit the agent `.env` files on the instance through this connection; do not copy secrets into an unprotected local project folder or commit them.

## Task 2: Provision Autonomous Database 26ai

1. In OCI Console, create an Autonomous Database with workload type Transaction Processing.
    ![Where to Create an Autonomous Database](./images/02_create_database.png)

2. Choose Always Free and Oracle Database 26ai.
3. Enable secure access and download the wallet.

    ![How to Connect to the Database](./images/07_adb_wallet_button.png)

    ![Where to Download a Wallet](./images/03_wallet_download.png)

4. Copy the wallet zip file to the compute instance.

    When you download the wallet from Autonomous Database, your browser saves a file similar to `wallet_<db-name>.zip` on your laptop. Upload that ZIP to the `opc` user's home directory on the compute instance before you try to unzip it.

    On macOS or Linux, run this command from your laptop terminal:

    ```bash
    <copy>
    scp ~/Downloads/wallet_<db-name>.zip my-ai-staff-oci:~/wallet_<db-name>.zip
    </copy>
    ```

    If you did not configure the `my-ai-staff-oci` SSH alias in Task 1, use the key and public IP directly:

    ```bash
    <copy>
    scp -i ~/.ssh/my-ai-staff-oci.key ~/Downloads/wallet_<db-name>.zip opc@<instance-public-ip>:~/wallet_<db-name>.zip
    </copy>
    ```

    On Windows, run this command from PowerShell or Windows Terminal:

    ```powershell
    <copy>
    scp -i $env:USERPROFILE\.ssh\my-ai-staff-oci.key $env:USERPROFILE\Downloads\wallet_<db-name>.zip opc@<instance-public-ip>:~/wallet_<db-name>.zip
    </copy>
    ```

    The upload succeeds when `scp` returns to your local prompt with no error.

5. SSH into the compute instance and extract the wallet under the deployment user's home directory.

    ```
    <copy>
    mkdir -p ~/oracle/wallet
    unzip ~/wallet_<db-name>.zip -d ~/oracle/wallet
    ls ~/oracle/wallet/{sqlnet.ora,tnsnames.ora,cwallet.sso}
    </copy>
    ```

6. Verify the extracted wallet files include `sqlnet.ora`, `tnsnames.ora`, `cwallet.sso`, `ewallet.p12`, and `ewallet.pem`.

7. Record the wallet directory as `ADB_WALLET_DIR` for Lab 3. The agents pass the database ADMIN password as the wallet passphrase because `ewallet.pem` is passphrase-protected; do not confuse it with the separate password used when downloading the wallet zip.

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

4. The platform ZIP is downloaded and extracted in Lab 2. After completing Lab 2 Task 2, return to this task and run `~/livelabs-ai-staff/schema/ai_for_you_full_ddl.sql` from the extracted platform files, top to bottom. Do not try to run this step before the ZIP has been installed. The file is the current schema snapshot for a fresh deployment, not a migration sequence.
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
