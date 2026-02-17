# Getting Started

## Introduction
The EternaGrid DER team will build and test agents inside an Oracle LiveLabs environment, just like other AI4U workshops. This guide helps you claim the tenancy, provision the schema, and launch the JupyterLab notebooks tailored to DER interconnection workflows.

### Objectives
* Reserve the LiveLabs environment and collect credentials
* Load DER sample data into Autonomous Database 26ai
* Launch the notebook workspace used throughout the labs

### Prerequisites
* Oracle account with LiveLabs access
* Ability to run SQL scripts (SQL Developer Web or CLI)
* Optional: familiarity with OCI Cloud Shell for automation

## Task 1: Reserve Your Environment
1. Sign in to LiveLabs and launch the "AI Agents with Agentic Memory – Energy Utilities Edition" workshop.
2. Record the generated tenancy OCID, database credentials, and reservation duration.

## Task 2: Initialize the Database
1. Open SQL Developer Web via the LiveLabs dashboard.
2. Run `sql/setup_der_schema.sql` to create `DER_APPLICATIONS`, `FEEDER_CAPACITY`, `INTERCONNECTION_POLICIES`, and related tables.
3. Execute `sql/seed_der_samples.sql` to insert sample interconnection requests and feeder data.

## Task 3: Launch JupyterLab
1. Return to LiveLabs and click **Open Notebook**.
2. Select the "Energy Utilities AI4U" project; JupyterLab opens with all lab notebooks preloaded.
3. Update `config/connection.json` with your reservation credentials if needed.

## Task 4: Verify Connectivity
1. Run `notebooks/connection-check.ipynb` to confirm connectivity and data load.
2. Ensure vector search extensions are enabled for the labs that require `DER_PRECEDENTS`.

## Summary
Your environment now includes the DER schema, notebooks, and credentials required for the labs. Keep both SQL Developer Web and JupyterLab tabs available for quick context switching.

## Learn More
* [Oracle LiveLabs Getting Started](https://livelabs.oracle.com)
* [Autonomous Database Utilities Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-database)

## Acknowledgements
* **Author** - Kay Malcolm, Product Management
* **Last Updated By/Date** - Kay Malcolm, February 2026
