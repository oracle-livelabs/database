# Retail LiveStack Backend Provisioning

## Introduction

This support note summarizes the database provisioning bundle for instructors and workshop maintainers. Learners use the Getting Started lab and SQL Worksheet exercises instead of this file.

Estimated Time: 20 minutes

### Objectives

In this support note, you will:

- Review the script order for creating the RETAILDB schema.
- Confirm the MiniLM model load point.
- Verify that setup files avoid environment-specific secrets.

## Task 1: Review the provisioning order

1. Run the staged scripts from `backend-provisioning/database-source` in this order when preparing a clean Autonomous Database instance.

    ```text
    <copy>
    1. Connect as ADMIN and run @run_as_admin.sql.
    2. Upload all_MiniLM_L12_v2.onnx to DATA_PUMP_DIR when needed.
    3. Connect as RETAILDB and run @run_as_retaildb_core.sql.
    4. Reconnect as ADMIN and run @run_as_admin_security.sql.
    5. Reconnect as RETAILDB and run @run_as_retaildb_finish.sql.
    </copy>
    ```

2. Replace the placeholder schema password in `run_as_admin.sql` before instructor provisioning.

## Task 2: Verify workshop readiness

1. Run the readiness script after the staged setup completes.

    ```sql
    <copy>
    @verify_retail_workshop_ready.sql
    </copy>
    ```

2. Confirm the readiness output reports the MiniLM model, OML models, agent tools, base tables, JSON duality views, property graph, and retail semantic views.

## Acknowledgements

* **Author** - Oracle LiveLabs
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
