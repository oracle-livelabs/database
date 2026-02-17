# Lab 1: Build the Prior Authorization Intake Agent

## Introduction
Prior authorization reviewers at HorizonCare start every case by hunting through disconnected systems. They log into payer portals, sift through PDF submissions, and manually cross-check policy rules. In this lab you will create the first AI agent that centralizes the intake step. The agent will return real authorization statuses from Oracle Database 26ai instead of providing vague instructions.

### Objectives
* Create the healthcare schema objects and seed data for prior authorization cases
* Register a SQL tool for the agent to query `PRIOR_AUTH_REQUESTS`
* Build and test the PRIOR_AUTH_INTAKE_AGENT that answers status questions with real data

### Prerequisites
* LiveLabs environment from Getting Started
* SQL Developer Web or equivalent tool to run provided scripts
* Basic knowledge of executing notebooks within the supplied JupyterLab workspace

## Task 1: Create the Prior Authorization Table
1. Open SQL Developer Web.
2. Run the following script to create the table that stores requests:

```sql
CREATE TABLE prior_auth_requests (
    request_id           VARCHAR2(20) PRIMARY KEY,
    patient_id           VARCHAR2(20) NOT NULL,
    procedure_code       VARCHAR2(10) NOT NULL,
    request_type         VARCHAR2(30) CHECK (request_type IN ('DIAGNOSTIC_IMAGING','SPECIALTY_MEDICATION')),
    submission_date      DATE,
    status               VARCHAR2(30) CHECK (status IN ('PENDING','APPROVED','DENIED','NEEDS_INFO')),
    reviewer_notes       CLOB
);
```

3. Insert the sample data set from `sql/lab1_seed_data.sql` located in the repo (`industries/healthcare/sql`).

## Task 2: Build the SQL Tool
1. In JupyterLab open `notebooks/lab1_prior_auth_agent.ipynb`.
2. Run the cell that defines the SQL tool using `DBMS_CLOUD_AI_AGENT.CREATE_TOOL`. Provide a description explaining the table columns and when to use the tool.
3. Execute the notebook cell that registers the PRIOR_AUTH_INTAKE_AGENT. Confirm it references the tool you just created.

## Task 3: Test the Agent
1. Still inside the notebook, run the cell that asks: “What is the status of request PA-1007?”
2. Observe that the agent returns the actual status from the table (e.g., `NEEDS_INFO`).
3. Ask follow-up questions such as “Why is PA-1007 pending?” and verify that the agent cites reviewer notes.

## Summary
You built the healthcare schema starter table and registered your first agentic tool. The PRIOR_AUTH_INTAKE_AGENT now responds with real authorization status data instead of canned guidance.

## Learn More
* [DBMS_CLOUD_AI_AGENT Documentation](https://docs.oracle.com)
* [Oracle SQL Developer Web](https://docs.oracle.com/en/database/oracle/sql-developer-web)

## Acknowledgements
* **Author** - Kay Malcolm, Product Management
* **Last Updated By/Date** - Kay Malcolm, February 2026
