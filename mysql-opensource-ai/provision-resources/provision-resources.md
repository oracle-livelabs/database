# Lab 1: Provision the Required Resources for the Workshop


In this lab, you will:
* TODO: Add objectives


Estimated Time: 30-40 minutes


### Objectives

In this lab, you will provision the infrastructure required for the AI-powered eCommerce application using Oracle Cloud Infrastructure (OCI) Resource Manager and Terraform. You will also validate connectivity to the Compute VM and MySQL HeatWave database and configure Visual Studio Code with OCI Generative AI integration.

---

## Task 1: Provision Infrastructure Using OCI Resource Manager

1. Download the Resource File

Download the ZIP package containing the Terraform infrastructure scripts.

**Download URL:**  
https://objectstorage.us-chicago-1.oraclecloud.com/p/3rSJn8VsfglY8wWlj0Q_bxwQZRNvZOnAoURiGMzV3AbbTa0aUj8ZyFsvh_X4Vmzq/n/sehubjapaciaas/b/heatwave_genai/o/Version_3_AI_Demo_infrastructure.zip

---

2. Login to OCI Console

1. Login to the OCI Console.
2. Navigate to:
   - **Developer Services → Resource Manager → Stacks**

![Navigate to resource manager](images/lab1image1.png "Navigate to resource manager")
![Navigate to stack](images/lab1image2.png "Navigate to stack")
---

3. Create a Stack

1. Click **Create Stack**
2. Choose:
   - **My Configuration**
3. Upload the downloaded ZIP file.

![Create Stack](images/lab1image3.png "Create Stack")
---

4. Upload Terraform ZIP File

1. Browse and select the ZIP file.
2. Click **Next**.

---

5. Configure Stack Variables

Fill in the required details:

| Parameter | Description |
|---|---|
| Compartment OCID | Update with your workshop compartment |
| mysql_admin_password | Set your MySQL administrator password |

> Note: Other values are automatically populated from the Terraform scripts and can be modified if needed.

![add details](images/lab1image4.png "add details")
![add details](images/lab1image5.png "add details")
---

6. Save Stack

Click **Save Changes**.

![save stack](images/lab1image6.png "save stack")
---

7. Run Terraform Plan

1. Click **Plan**
2. Wait for validation and resource planning to complete successfully.

![run Plan](images/lab1image7.png "run Plan")
![run plan](images/lab1image8.png "run plan")
---

8. Apply the Stack
![apply plan](images/Lab1Image9.png "apply plan")

1. Once the plan succeeds, click **Apply**
2. Wait for the infrastructure deployment to complete.

Resources created include:
- Virtual Cloud Network (VCN)
- Compute VM
- MySQL HeatWave DB System
- Networking Components

---

9. Validate Infrastructure Deployment

After deployment completes successfully, verify that the infrastructure resources are available in your OCI compartment.

---

# Important Notes

- The delivered ZIP file contains the SSH key pair required for VM access.
- The compute instance is configured with the public key from the ZIP package.
- Use the corresponding private key to SSH into the VM.

You may also modify:
- MySQL version
- HeatWave version

using the `terraform.tfvars` configuration file.

![update terraform variables](images/lab1image10.png "update terraform variables")

---

## Task 2: Validate Compute VM Access

1. Retrieve Public IP Address

1. Navigate to:
   - **Compute → Instances**
2. Select your VM instance.
3. Copy the **Public IP Address**.

---

2. Locate SSH Private Key

Extract the downloaded infrastructure ZIP package and locate the `.key` file.

---

3. Set Key Permissions (Linux/macOS)

```bash
chmod 400 ~/Downloads/workshop-key.key
```

---

4.  Connect to the VM

```bash
ssh -i ~/Downloads/workshop-key.key opc@<PUBLIC_IP>
```

Example:

```bash
ssh -i ~/Downloads/workshop-key.key opc@129.154.xx.xx
```

---

5. Verify SSH Access

Successful connection should display:

```bash
[opc@workshop-vm ~]$
```

> Note: Default Oracle Linux username is `opc`.

---

## Task 3: Validate MySQL HeatWave Connectivity

1. Retrieve Database Private IP

1. Navigate to:
   - **Databases → MySQL HeatWave → DB Systems**
2. Select the deployed DB System.
3. Copy the **Private IP Address**.

---

## Task 4: Connect MySQL HeatWave Using Visual Studio Code

Since the database resides in a private subnet, connectivity is established through the Compute VM using SSH tunneling.

---

1. Install Required VS Code Extensions

Install:
- **MySQL Shell Extension**

![Install mysql shell extension](images/mysqlshell.png "Install mysql shell extension")
---

2. Configure Database Connection

In Visual Studio Code:

1. Open the MySQL Shell Extension.
2. Click **+ New Connection**
3. Enter the following details:

| Field | Value |
|---|---|
| Host | Private DB IP |
| Port | 3306 |
| Username | admin |
| Password | Your DB password |


![Create Connection](images/mysqlconn.png "Create Connection")

![Add connection details](images/mysqlconn2.png "Add connection details")
---

3. Configure SSH Tunnel

Enter:

| Field | Value |
|---|---|
| SSH Username | opc |
| SSH Host | Public VM IP |
| SSH Private Key | Path to private key |

![Add SSH details](images/mysqlconn3.png "Add SSH details")
---

4. Test Database Connectivity

Execute:

```sql
SELECT NOW();
```

You should receive the current database server timestamp.

---

# Final Validation Checklist

- [x] VM accessible through SSH
- [x] MySQL HeatWave reachable from VS Code
- [x] Database query execution successful

---

## Task5: Configure OCI Generative AI with Cline in Visual Studio Code

## Objective

Configure OCI Generative AI integration with the Cline extension inside Visual Studio Code for prompt-driven AI application development.

---

1. Create IAM Policy for Generative AI Access

Navigate to:

- **Identity & Security → Policies**


![Navigate to Policies](images/policies.png "Navigate to Policies")
![Create Policy](images/policies2.png "Create Policy")

Create the following policy:

```text
Allow any-user to use generative-ai-family in compartment poc-compartment
```

This policy grants access to OCI Generative AI services.

Reference Documentation:  
https://docs.oracle.com/en-us/iaas/Content/Identity/policieshow/Policy_Basics.htm

---

2. Create OCI Generative AI API Key

Navigate to:

- **Analytics & AI → Generative AI**

![Navigate to Generative AI services](images/genaikey.png "Navigate to Generative AI services")

Select:
- Compartment: Your workshop compartment
- Region: Chicago

From the left navigation:
- Select **API Keys**
- Click **Create API Key**

![Navigate to API Keys](images/genaikey2.png "Navigate to API Keys")

![Create API Keys](images/genaikey3.png "Create API Keys")
Provide:
- Name
- Optional Description

![Create API Keys](images/genaikey4.png "Create API Keys")

![Copy keys](images/genaikey5.png "Copy keys")
---

3. Install Cline Extension in VS Code

1. Open Visual Studio Code
2. Navigate to:
   - **Extensions**
3. Search for:
   - `Cline`
4. Click **Install**

![Install cline extension](images/cline.png "Install cline extension")
---

4. Configure Cline Settings

Open Cline settings and configure:

| Field | Value |
|---|---|
| Provider | Open AI Compatible |
| Base URL | https://inference.generativeai.us-chicago-1.oci.oraclecloud.com |
| Model ID | ocid1.generativeaimodel.oc1.us-chicago-1.amaaaaaask7dceya3bsfz4ogiuv3yc7gcnlry7gi3zzx6tnikg6jltqszm2q |

![Cline settings](images/clinesetup.png "Cline settings")
---

# Expected Outcome

At the end of this lab, you will have:

- Provisioned OCI infrastructure using Terraform
- Configured MySQL HeatWave
- Connected Visual Studio Code to OCI resources
- Configured OCI Generative AI integration
- Enabled Cline for prompt-driven AI development
- Prepared the environment for building the AI-powered eCommerce application

You may now **proceed to the next lab**.

## Acknowledgements

**Authors:**  
Lohith R and Jayshri Dhar from SEHUB

**Contributors:**  
Rahul Shringarpure from Mysql Heatwave
