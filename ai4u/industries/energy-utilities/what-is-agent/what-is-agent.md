# Lab 1: Build the DER Intake Agent

## Introduction
EternaGrid engineers juggle hundreds of DER applications, checking technical packets manually before assigning studies. In this lab you will create the first agent that centralizes intake. The agent will read the `DER_APPLICATIONS` table and return real interconnection status, study requirements, and queue position.

### Objectives
* Create and seed DER intake tables used across the workshop
* Register a SQL tool for querying `DER_APPLICATIONS`
* Build the `DER_INTAKE_AGENT` that answers status questions with live data

### Prerequisites
* LiveLabs environment provisioned in Getting Started
* SQL Developer Web access to run provided scripts
* JupyterLab session opened with notebooks for Lab 1

## Task 1: Create DER Tables
1. Open SQL Developer Web.
2. Execute `sql/lab1_create_der_tables.sql` to create the intake table:

```sql
CREATE TABLE der_applications (
    application_id      VARCHAR2(20) PRIMARY KEY,
    feeder_id           VARCHAR2(20) NOT NULL,
    project_type        VARCHAR2(30) CHECK (project_type IN ('SOLAR','STORAGE','EV_CHARGER','MICROGRID')),
    capacity_kw         NUMBER(10,2),
    submission_date     DATE,
    status              VARCHAR2(30) CHECK (status IN ('PENDING','STUDY','MITIGATION','APPROVED','REJECTED')),
    study_required      VARCHAR2(30) CHECK (study_required IN ('NONE','SCREENING','IMPACT','FACILITIES')),
    engineer_notes      CLOB
);
```

3. Load sample rows using `sql/lab1_seed_der_applications.sql`.

## Task 2: Register the SQL Tool
1. In JupyterLab open `notebooks/lab1_der_intake_agent.ipynb`.
2. Run the cell that registers a SQL tool via `DBMS_CLOUD_AI_AGENT.CREATE_TOOL` targeting `DER_APPLICATIONS`.
3. Provide a rich description enumerating the columns, study types, and when the tool should be used.

## Task 3: Create the Agent
1. Continue in the notebook to create `DER_INTAKE_AGENT`, referencing the SQL tool.
2. Supply instructions explaining how the agent should respond, including study guidance vocabulary.

## Task 4: Test the Agent
1. Ask the agent: “What is the status of application DER-1042?” and verify it returns the actual status.
2. Query “Does DER-1042 require an impact study?” and confirm it cites the study requirement and `engineer_notes` field.

## Summary
You now have a DER intake agent that returns live status and study requirements, forming the foundation for the remaining labs.

## Learn More
* [Oracle DBMS_CLOUD_AI_AGENT Reference](https://docs.oracle.com)
* [DER Interconnection Study Types](https://www.nrel.gov)

## Acknowledgements
* **Author** - Kay Malcolm, Product Management
* **Last Updated By/Date** - Kay Malcolm, February 2026
