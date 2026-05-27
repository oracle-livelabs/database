# Retail LiveStack Backend Provisioning

## Introduction

This support note summarizes the deterministic database provisioning bundle for instructors and workshop maintainers. Learners use the Getting Started lab and SQL Worksheet exercises instead of this file.

Estimated Time: 20 minutes

### Objectives

In this support note, you will:

- Review the exact-data setup used to create the workshop schema. LiveLabs Sandbox reservations use `LLUSER`; the script also supports `RETAILDB`.
- Confirm that the workshop uses fixed INSERT data so learner queries and expected results match.
- Verify that setup files avoid environment-specific secrets.

## Task 1: Run the deterministic setup

1. Run the exact-data script from `backend-provisioning/database-source` when preparing a clean Autonomous Database instance.

    ```text
    <copy>
    1. Connect as ADMIN.
    2. Substitute the ${user_password} placeholder in retail_workshop_admin_create_all_exact_data.sql with the runtime workshop schema password.
    3. Run @retail_workshop_admin_create_all_exact_data.sql.
    4. Connect as the workshop schema user, usually LLUSER.
    5. Run @verify_retail_workshop_ready.sql when you want an explicit readiness check.
    </copy>
    ```

2. Do not use the legacy staged loader path for learner builds. That path calls random data-generation scripts, which can make worksheet results drift away from the values printed in the labs.

## Task 2: Verify workshop readiness

1. Run the readiness script after the exact-data setup completes.

    Instructors need a repeatable readiness check before students begin. This script confirms that the models, tables, views, graph objects, and tools required by the learner labs are available.

    ```sql
    <copy>
    @verify_retail_workshop_ready.sql
    </copy>
    ```

2. Confirm the readiness output reports the MiniLM model, OML models, agent tools, base tables, JSON duality views, property graph, and retail semantic views.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
