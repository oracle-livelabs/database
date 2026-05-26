# Retail LiveStack Backend Provisioning

## Introduction

This support note summarizes the compact learner database setup bundle for instructors and workshop maintainers. Learners use the Getting Started lab and SQL Worksheet exercises; this file supports instructors and maintainers.

Estimated Time: 20 minutes

### Objectives

In this support note, you will:

- Review the compact learner setup used to create the workshop schema. LiveLabs Sandbox reservations use `LLUSER`; the script also supports `RETAILDB`.
- Confirm that the workshop uses fixed INSERT data so learner queries and expected results match.
- Verify that setup files avoid environment-specific secrets.

## Task 1: Run the compact learner setup

1. Run the compact learner script from `backend-provisioning/database-source` when preparing a clean Autonomous Database instance. This setup path creates the workshop schema, grants required privileges, builds tables, loads fixed learner rows, creates views, graph objects, OML models, PL/SQL tools, VPD policy functions, and readiness checks.

    ```text
    <copy>
    1. Connect as ADMIN.
    2. Substitute the ${user_password} placeholder in retail_workshop_admin_create_lab_seed.sql with the runtime workshop schema password.
    3. Run @retail_workshop_admin_create_lab_seed.sql.
    4. Connect as the workshop schema user, usually LLUSER.
    5. Run @verify_retail_workshop_ready.sql when you want an explicit readiness check.
    </copy>
    ```

2. Use the compact learner seed for workshop builds. It keeps the fixed rows that reproduce the lab result tables, omits unused high-volume post embedding rows, and keeps only the semantic-match rows printed in the MiniLM lab.

3. Keep `retail_workshop_admin_create_all_exact_data.sql` only when you need the full exported demo-application dataset. Do not use the legacy staged loader path for learner builds. That path calls random data-generation scripts, which can make worksheet results drift away from the values printed in the labs.

## Task 2: Verify workshop readiness

1. Run the readiness script after the compact learner setup completes.

    Instructors need a repeatable readiness check before students begin. This script runs database-side assertions against the loaded schema. It confirms that the expected models, tables, views, graph objects, policy functions, comments, and agent tools are present before learners start.

    ```sql
    <copy>
    @verify_retail_workshop_ready.sql
    </copy>
    ```

2. Confirm the readiness output reports the MiniLM model, OML models, agent tools, base tables, JSON duality views, property graph, and retail semantic views.

## Acknowledgements

* **Author** - Pat Shepherd, Senior Principal Database Product Manager
* **Last Updated By/Date** - Oracle Database Product Management, May 2026
