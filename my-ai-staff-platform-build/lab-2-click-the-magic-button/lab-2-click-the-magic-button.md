# Fast Path: Click the Magic Button

## Introduction

This is the fast deployment path for My AI Staff. It is an alternative to the
manual infrastructure work in Lab 1 and the runtime installation in Lab 2. The
Deploy to Oracle Cloud button creates an OCI Resource Manager stack that
provisions the network, ARM host, Autonomous AI Database, wallet, and a
bootstrap environment.

Estimated Time: 45 minutes to create the stack, plus up to 45 minutes for the
host bootstrap.

### Objectives

In this lab, you will:

- Create an OCI Resource Manager stack from the versioned My AI Staff Terraform ZIP.
- Provision a VCN, SSH-only public host, Always Free Autonomous AI Database, and database wallet.
- Bootstrap the platform files, local Codex plugin, labeled virtual environments, application schema, and `MINILM_V2` model.
- Verify the deployment before continuing directly to Lab 3.

### Before You Begin

- Complete the workshop Introduction and have OCI permissions for networking,
  Compute, Autonomous Database, Object Storage, and the tenancy-level dynamic
  group and policy used only during model bootstrap.
- Generate an SSH key pair locally and have the public key ready. Do not upload
  the private key or enter it as a Resource Manager variable.
- Know your current public IP CIDR, normally `your.public.ip/32`.
- Have strong, distinct values for the Autonomous Database ADMIN password,
  wallet password, and `AI_FOR_YOU` password. Resource Manager masks these
  inputs; do not record them in the workshop repository.

## Task 1: Create the Resource Manager Stack

1. Select the button below. It opens OCI Resource Manager's **Create stack**
   page with the versioned Terraform configuration already selected. The button
   uses the read-only pre-authenticated Object Storage URL for the release ZIP.

    [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https%3A%2F%2Fc4u02.objectstorage.us-ashburn-1.oci.customer-oci.com%2Fp%2F9DEArLjsgbKXuJgQtSG95E8hMXRFtxgHR8jiHbqz4HgyVYXVnSo0SC_s-zq5CJA3%2Fn%2Fc4u02%2Fb%2Fhosted-files%2Fo%2Fmy-ai-staff-oci-stack-v1.0.0.zip)

2. Sign in if prompted. Give the stack a non-sensitive name, select the target
   compartment, select Terraform 1.5.x, and select **Next**.
3. Supply the required values. Use the following guidance for each field:

   - **Compartment:** Select the compartment where you want to create the
     workshop resources. If you are using a tenancy provided for this
     workshop, this is usually the assigned or root compartment.
   - **Tenancy OCID:** Paste your tenancy OCID. In OCI Console, open your
     profile menu, select **Tenancy**, and copy the value labeled **OCID**. It
     starts with `ocid1.tenancy...`.
   - **Region:** Select the OCI region where you want to deploy. Use the same
     region selected for the stack and make sure it offers the Always Free ARM
     shape and Autonomous Database 26ai.
   - **Administrator SSH CIDR:** Enter the public IPv4 address of the computer
     or network you will use to connect, followed by `/32`. To find it, open a
     browser and search for **what is my IP**, or visit a site that displays
     your public IP, such as [ifconfig.me](https://ifconfig.me). For example, if
     the site shows `203.0.113.10`, enter `203.0.113.10/32`. Do not enter a
     private address such as `192.168.x.x` or `10.x.x.x`, and do not use
     `0.0.0.0/0`. If your public IP changes or you connect from another
     network, update the security rule before connecting.

4. Provide the SSH public key:

   - If you do not already have an SSH key pair, run these commands in a
     terminal on your computer:

     ```bash
     mkdir -p ~/.ssh
     chmod 700 ~/.ssh
     ssh-keygen -t ed25519 -f ~/.ssh/my-ai-staff-oci.key -C "my-ai-staff-oci"
     ```

     Accept the suggested file path if prompted. The command creates the
     private key at `~/.ssh/my-ai-staff-oci.key` and the public key at
     `~/.ssh/my-ai-staff-oci.key.pub`. Protect the private key and never paste
     or upload it to Resource Manager.
   - Copy only the public key. On macOS, run:

     ```bash
     pbcopy < ~/.ssh/my-ai-staff-oci.key.pub
     ```

     On Linux, you can display it and copy the complete single line manually:

     ```bash
     cat ~/.ssh/my-ai-staff-oci.key.pub
     ```

     Paste that line, which starts with `ssh-ed25519`, into **SSH public key**.

   - **Autonomous Database ADMIN password:** Create a strong password of at
     least 12 characters. This is the password for the database `ADMIN` user.
   - **Wallet password:** Create a different strong password of at least 12
     characters. This protects the downloaded database wallet.
   - **AI_FOR_YOU password:** Create a third different strong password of at
     least 12 characters. This is used for the `AI_FOR_YOU` application schema.

     Use letters, numbers, and symbols, do not reuse your OCI password, and
     keep all three values in a secure password manager. Resource Manager masks
     these fields; do not save the passwords in the workshop repository.
5. Leave the pinned ZIP and ONNX model URL/checksum unchanged unless you are
   intentionally deploying a reviewed replacement. The default model source is
   public, but bootstrap verifies its SHA-256 before importing it.
6. Select **Next**, review the values, leave **Run apply** selected, then
   select **Create**. Resource Manager starts the apply automatically.

## Task 2: Monitor Provisioning

1. On the stack page, open the apply job and wait for it to reach **Succeeded**.
   If the A1 shape has no capacity or the selected region does not offer the
   configured 26ai database version, stop and choose a region/availability
   domain with capacity; the stack deliberately does not fall back to another
   shape or database tier.
2. Copy the `instance_public_ip`, `ssh_command`, and
   `autonomous_database_service_name` outputs. No wallet or password is
   displayed as an output.
3. Connect using the private key that matches the supplied public key:

    ```bash
    ssh -i ~/.ssh/my-ai-staff-oci.key opc@<instance_public_ip>
    ```

4. Follow the bootstrap log until completion. It may take time while packages,
   Python dependencies, the public model, and database initialization finish.

    ```bash
    sudo tail -f /var/log/my-ai-staff-bootstrap.log
    ```

5. A successful bootstrap creates `/var/lib/my-ai-staff-bootstrap.complete`.
   If it does not appear, preserve the log and correct the reported failure
   before moving forward. Do not rerun the manual Lab 1 DDL or Lab 2 runtime
   installation tasks on this host.

## Task 3: Verify the Fast Path

1. Confirm the platform, wallet, virtual environments, and completion marker:

    ```bash
    test -f ~/livelabs-ai-staff/schema/ai_for_you_full_ddl.sql
    test -f ~/oracle/wallet/tnsnames.ora
    test -x ~/livelabs-ai-staff/agents/data/venv/bin/python
    sudo test -f /var/lib/my-ai-staff-bootstrap.complete
    ```

2. Confirm that ports 8001 through 8005 are not publicly allowed. The stack
   security list permits inbound TCP/22 only from the CIDR entered in Task 1.
3. Continue with **Lab 3: Configure Slack Agents, Environment Files, and
   Services**. That lab configures the interactive identities and credentials
   intentionally excluded from this bootstrap: Codex login, Slack, Google, and
   publishing integrations.

## Acknowledgements

- Authors: Cyrce Salinas Rojas and Ilan Gomez Guerrero
- Last Updated: September 2026