# Click the Magic Button

## Introduction

This is the fast deployment path for My AI Staff. It is an alternative to the
manual infrastructure work in Lab 1 and the runtime installation in Lab 3. The
Deploy to Oracle Cloud button creates an OCI Resource Manager stack that
provisions the network, ARM host, Autonomous AI Database, wallet, and a
bootstrap environment.

Estimated Time: 45 minutes to create the stack, plus up to 45 minutes for the
host bootstrap.

### Objectives

In this lab, you will:

- Create an OCI Resource Manager stack from the versioned My AI Staff Terraform ZIP.
- Provision a VCN, SSH-only public host, Always Free Autonomous AI Database, and database wallet.
- Bootstrap the platform files, virtual environments, application schema, and `MINILM_V2` model.
- Verify the deployment before continuing directly to Lab 4.

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

    [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https%3A%2F%2Fobjectstorage.us-ashburn-1.oraclecloud.com%2Fp%2F9DEArLjsgbKXuJgQtSG95E8hMXRFtxgHR8jiHbqz4HgyVYXVnSo0SC_s-zq5CJA3%2Fn%2Fc4u02%2Fb%2Fhosted-files%2Fo%2Fmy-ai-staff-oci-stack-v1.0.0.zip)

2. Sign in if prompted. Give the stack a non-sensitive name, select the target
   compartment, select Terraform 1.5.x, and select **Next**.
3. Supply the required values. Use the same region as the stack, your tenancy
   OCID, and the target compartment OCID. For **Administrator SSH CIDR**, use
   one trusted network only; do not use `0.0.0.0/0`.
4. Paste only the contents of the public half of your SSH key into **SSH public
   key**. Enter the three passwords in their masked fields.
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
    ssh opc@<instance_public_ip>
    ```

4. Follow the bootstrap log until completion. It may take time while packages,
   Python dependencies, the public model, and database initialization finish.

    ```bash
    sudo tail -f /var/log/my-ai-staff-bootstrap.log
    ```

5. A successful bootstrap creates `/var/lib/my-ai-staff-bootstrap.complete`.
   If it does not appear, preserve the log and correct the reported failure
   before moving forward. Do not rerun the manual Lab 1 DDL or Lab 3 runtime
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
3. Continue with **Lab 4: Configure Slack Agents, Environment Files, and
   Services**. That lab configures the interactive identities and credentials
   intentionally excluded from this bootstrap: Codex login, Slack, Google, and
   publishing integrations.

## Acknowledgements

- Authors: Cyrce Salinas Rojas and Ilan Gomez Guerrero
- Last Updated: September 2026
