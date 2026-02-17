# Getting Started

## Introduction
HorizonCare’s coordination team will build and test the prior authorization agents inside an Oracle LiveLabs-provided environment. This guide walks you through claiming the tenancy, launching the notebook workspace, and loading the healthcare dataset required for the labs.

### Objectives
* Claim your LiveLabs reservation and credentials
* Provision the Autonomous Database with the healthcare schema
* Launch the prebuilt JupyterLab workspace with notebook assets

### Prerequisites
* Oracle account with LiveLabs access
* Ability to run SQL commands or use SQL Developer Web
* Optional: familiarity with OCI Data Studio or Cloud Shell

## Task 1: Reserve Your LiveLabs Environment
1. Visit the workshop reservation link and sign in with your Oracle account.
2. Choose the “AI Agents with Agentic Memory – Healthcare Edition” workshop and click **Launch**.
3. Note the generated tenancy OCID, username, and password. These credentials expire when the reservation ends.

## Task 2: Access SQL Developer Web
1. From the LiveLabs dashboard click **Open Development Environment**.
2. Choose **SQL Developer Web** and authenticate with your reservation credentials.
3. Run the provided `setup_healthcare_schema.sql` script to create the tables (`PRIOR_AUTH_REQUESTS`, `PATIENT_PROFILE`, `MEDICAL_POLICIES`, `AUTH_WORKFLOW_LOG`, `AGENT_MEMORY`).

## Task 3: Launch the Notebook Workspace
1. Return to the LiveLabs dashboard and click **Open Notebook**.
2. Select the “Healthcare AI4U” project; a JupyterLab workspace opens with all lab notebooks preloaded.
3. Confirm that the `config/connection.json` file contains your database credentials; update if necessary.

## Task 4: Test the Connection
1. Open `notebooks/connection-smoke-test.ipynb` inside JupyterLab.
2. Run the notebook cells to verify database connectivity and confirm that the healthcare tables were created.

## Summary
Your environment now has the healthcare schema, notebooks, and credentials required for the labs. Keep the notebook workspace and SQL Developer Web tabs open for faster switching during the workshop.

## Learn More
* [LiveLabs Getting Started Guide](https://livelabs.oracle.com)
* [Autonomous Database Quick Start](https://docs.oracle.com/en/cloud/paas/autonomous-database)

## Acknowledgements
* **Author** - Kay Malcolm, Product Management
* **Last Updated By/Date** - Kay Malcolm, February 2026
