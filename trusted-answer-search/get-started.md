# Get Started

## Introduction

In this lab, you will gather the required data and prepare the environment for installing **Oracle Trusted Answer Search**. This platform is a purpose-built “language-to-report” mapping system that reliably routes natural-language questions to the correct reports or actions. By the end of this lab, you will have the core infrastructure and configuration details ready for the backend installation.

> **Note:** Trusted Answer Search can be deployed on **Oracle Autonomous Database Serverless (ADB-S)** or **on-premises** using Oracle Database 23ai or later. This workshop specifically focuses on the verified deployment path for **OCI ADB-S**.

**Estimated time:** 5 minutes.

### Objectives
* Understand prerequisites and gather required information for installation.
* Provision the foundational OCI resources required for the workshop.

### Prerequisites
* Access to an **Oracle Cloud Infrastructure (OCI) tenancy**.
* Basic familiarity with the **Oracle Autonomous AI Database**.
* Basic familiarity with **Linux (x86-64)** and **Python** environments.
* Oracle Database version **23ai or later**.

## Task 1: Create Oracle Autonomous AI Database
1. In the OCI Console, navigate to **Oracle Database** and create a new **Autonomous Database**.
2. Ensure you select **Database version 23ai or later** (26ai is recommended).
3. Set a strong **ADMIN password** and note it down, as it is required for the installation script.
4. Once provisioned, go to **Database Connection**, download the **Database Wallet**, and note your preferred **TNS alias** (e.g., `_high`).

## Task 2: Create OCI Compute VM
1. Create an **Oracle Linux 9 (x86-64)** Compute VM in the same region as your database.
2. This VM will serve as your environment for converting your **ONNX embedding model** via **OML4Py** and for running the backend installer shell script.

## Task 3: Gather installation prerequisites for the next lab
1. Your **Database Wallet** zip file and associated **TNS alias**.
2. Your **Autonomous Database ADMIN password**.
3. A chosen **TASADMIN password**, which will be used to log in to the APEX Admin App.
4. A **Pre-Authenticated Request (PAR) URL** for your embedding model (e.g., `multilingual-e5-base.onnx`) stored in OCI Object Storage.

You may now **proceed to the next lab**

## Acknowledgements

**Authors** 

* Allen Hosler, Principal Product Manager, Database Applied AI

**Last Updated Date** - April, 2026
