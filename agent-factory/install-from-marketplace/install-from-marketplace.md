# Installing the Oracle AI Database 26ai Private Agent Factory from the OCI Marketplace

> **Purpose**: This Live Lab walks customers through deploying the **Private Agent Factory** using the OCI Marketplace. It is designed to be accurate, customer-friendly, and aligned with how the product actually behaves today, while preserving the useful screenshots and flow from the original engineer-authored lab.

This lab assumes a *public, internet-reachable* deployment for learning purposes. Production deployments typically use private subnets, bastion access, and stricter security controls.

---

## Introduction

The **Private Agent Factory** is a no-code platform for building and operating enterprise-grade AI agents that run close to your data inside **Oracle AI Database 26ai**. Agents gain their power from direct access to converged enterprise data (relational, vector, JSON, files) and from the actions they can securely perform.

The OCI Marketplace deployment provides a **pre-built Resource Manager stack** that provisions:

* A compute instance running the Agent Factory container
* Supporting networking configuration (using your selected VCN/subnet)
* Application bootstrap logic that exposes the Agent Factory UI

---

## Objectives

By the end of this lab, you will be able to:

* Prepare networking suitable for a Private Agent Factory deployment
* Provision an Oracle Autonomous AI Database (26ai)
* Install the Private Agent Factory from the OCI Marketplace
* Complete the initial application configuration (user, database, API keys)

---

## Prerequisites

* An OCI tenancy with permissions for:

  * Networking (VCN, Subnet, Security Lists)
  * Autonomous Databases
  * OCI Marketplace and Resource Manager
* Access to an OCI region where **Oracle AI Database 26ai** is available
* Familiarity with the OCI Console

---

## Task 1: Prepare the Networking Environment

The Agent Factory UI runs as a web application and must be reachable from your browser. For this lab, we use a **public subnet**.

### 1. Create a Virtual Cloud Network (VCN)

* CIDR block: `10.0.0.0/16`
* Example name: `agent-factory-vcn`

### 2. Create an Internet Gateway

* Attach the Internet Gateway to the VCN
* This allows outbound internet access and inbound browser access

### 3. Update the Route Table

* Add a route rule:

  * Destination CIDR: `0.0.0.0/0`
  * Target: Internet Gateway

### 4. Update Security List Rules

Add **Ingress Rules** for TCP:

* **Port 22** – SSH access (administration/debugging)
* **Port 8080** – Agent Factory web UI
* **Port 1521** – Oracle Database access

> ⚠️ These open rules are for workshop purposes only. In production, restrict source CIDRs and prefer private networking.

### 5. Create a Public Subnet

* CIDR example: `10.0.1.0/24`
* Associate with:

  * The route table pointing to the Internet Gateway
  * The security list updated above
* Enable **Public IPs on VNICs**

---

## Task 2: Provision the Autonomous AI Database (26ai)

The Private Agent Factory uses Oracle AI Database to store:

* Agent configuration and metadata
* Vector embeddings
* Conversational memory and evaluation artifacts

### 1. Create the Database

* Navigate to **Oracle AI Database → Autonomous Database**
* Choose **Autonomous AI Database**

### 2. Configuration

* Database version: **26ai**
* Workload type: *Transaction Processing* or *Lakehouse* (either is fine for this lab)
* Select ECPU and storage appropriate for a demo

### 3. Network Access

* For this lab, you may select **Secure access from everywhere**
* Alternatively, restrict access to your VCN CIDR

### 4. Credentials (Important)

* Set and **record** the `ADMIN` password
* Download the **database wallet** and remember the **wallet password**

You will need all of these during the Agent Factory setup wizard.

---

## Task 3: Install the Private Agent Factory from the OCI Marketplace

This task uses a Resource Manager stack published in the OCI Marketplace.

### 1. Open the Marketplace Listing

* Navigate to the **Oracle AI Database – Private Agent Factory** listing:
  [https://cloudmarketplace.oracle.com/marketplace/en_US/listing/201588705](https://cloudmarketplace.oracle.com/marketplace/en_US/listing/201588705)

*(Screenshot: Agent Factory Application in Marketplace)*

### 2. Launch the Stack

* Click **Get App** and authenticate to your tenancy
* Review the product overview
* Click **Launch Stack**

*(Screenshot: Launch Stack)*

### 3. Accept Terms

* Review and accept the Oracle Standard Terms and Restrictions
* Click **Launch Stack**

### 4. Stack Configuration

Under **General Settings**:

* Select your **Region**
* Select the **Compartment** where resources will be created

Under **Network Configuration**:

* Select the **VCN** created in Task 1
* Select the **Public Subnet** created in Task 1

> The stack assumes a subnet that allows public IPs and inbound access on ports 22, 8080, and 1521.

### 5. Compute Configuration

* Provide a display name for the Agent Factory instance
* Select an instance shape (for example, `VM.Standard.E5.Flex`)
* Choose appropriate OCPU and memory (larger memory improves agent performance)

### 6. Create the Stack

* Review the configuration
* Click **Create**

Resource Manager will now run a Terraform **Apply** job to provision the instance and install the Agent Factory container.

*(Screenshot: Stack creation in progress)*

### 7. Retrieve the Application URL

Once the job completes successfully:

* Open the **Logs** or **Outputs** tab
* Copy the application URL, which has the format:

```
https://<instance_public_ip>:8080/studio/installation
```

*(Screenshot: Creation succeeded)*

---

## Task 4: Initial Application Configuration (Warm Start)

### 1. Create the Agent Factory User

* Open the application URL in your browser
* Set the **username and password** for the Agent Factory administrator

### 2. Configure the Database Connection

Provide the following:

* Upload the **Autonomous Database wallet**
* Wallet username and password
* Database user: `ADMIN`
* Database password

Click **Test Connection** before proceeding.

### 3. Configure AI Provider Access

Provide credentials for your LLM provider, such as:

* OCI Generative AI (using OCI API keys)
* Other supported providers, depending on your environment

This enables:

* Agent reasoning
* Embedding generation
* Evaluation and summarization workflows

### 4. Finalize Setup

* Complete the wizard
* Log back in to access the Agent Factory UI

You are now ready to start building agents using:

* Pre-built agent templates
* The visual Agent Builder
* Open Agent Specification–compatible workflows

---

## Summary

In this lab, you:

* Prepared networking for a public Agent Factory deployment
* Provisioned an Oracle Autonomous AI Database (26ai)
* Installed the Private Agent Factory from the OCI Marketplace
* Completed the initial configuration and login

You can now proceed to the next labs to:

* Explore pre-built agents
* Build custom agents with the Agent Builder
* Connect enterprise data sources
* Evaluate and govern agent behavior

---

## References

* Private Agent Factory product overview and architecture slides fileciteturn0file0
* OCI Marketplace listing: [https://cloudmarketplace.oracle.com/marketplace/en_US/listing/201588705](https://cloudmarketplace.oracle.com/marketplace/en_US/listing/201588705)
* Product documentation: [https://docs.oracle.com/en/database/oracle/agent-factory/](https://docs.oracle.com/en/database/oracle/agent-factory/)


- **Authors** 
* Emilio Perez, Member of Technical Staff, Database Applied AI
* Allen Hosler, Principal Product Manager, Database Applied AI

- **Last Updated Date** - January, 2026